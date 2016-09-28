-- Copyright 2016 Joao Valverde joao.valverde.att.tecnico.ulisboa.pt. See LICENSE.

ec_core = require('editorconfig_core')

-- Reference: https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties

local M = {}

M.debug = {}

M.debug.enabled = false

local function debug_print(msg)
  if not M.debug.enabled then return end
  msg = string.format('editorconfig: %s\n', msg)
  io.stderr:write(msg)
end

local function debug_filename(filename)
  local msg = string.format('*** configuring "%s"', filename)
  debug_print(msg)
end

local function debug_skip(key)
  local msg = string.format('skipping property "%s"', key)
  debug_print(msg)
end

local function debug_apply(key, val)
  local msg = string.format('setting property "%s" = %s', key, val)
  debug_print(msg)
end

M.debug.print = debug_print

local set_table = {}
local T = ec_core.T

-- indent_style
function set_table.indent_style(value)
  local tabs
  if value == T.INDENT_STYLE_TAB then
    tabs = true
  elseif value == T.INDENT_STYLE_SPACE then
    tabs = false
  end
  if tabs == nil then return end
  buffer.use_tabs = tabs
end

-- indent_size
function set_table.indent_size(value)
  local size
  if value ~= T.INDENT_SIZE_TAB then
    size = value
  end
  if size == nil then return end
  buffer.indent = size
end

-- tab_width
function set_table.tab_width(value)
  buffer.tab_width = value
end

-- end_of_line
function set_table.end_of_line(value)
  local eol
  if value == T.END_OF_LINE_LF then
    eol = buffer.EOL_LF
  elseif value == T.END_OF_LINE_CRLF then
    eol = buffer.EOL_CRLF
  elseif value == T.END_OF_LINE_CR then
    eol = buffer.EOL_CR
  end
  if eol == nil then return end
  buffer.eol_mode = eol
end

-- charset
function set_table.charset(value)
  local enc
  if value == T.CHARSET_LATIN1 then
    enc = 'ISO-8859-1'
  elseif value == T.CHARSET_UTF_8 then
    enc = 'UTF-8'
  elseif value == T.CHARSET_UTF_16BE then
    enc = 'UTF-16BE'
  elseif value == T.CHARSET_UTF_16LE then
    enc = 'UTF-16LE'
  end
  if enc == nil then return end
  buffer:set_encoding(enc)
end

function M.load_editorconfig(filepath, confname)
  if M.debug.enabled then M.debug.print(ec_core._VERSION) end
  if not filepath then return end
  if M.debug.enabled then debug_filename(filepath) end

  -- load table with EditorConfig properties
  for name, value in ec_core.open(filepath, confname) do
    local f = set_table[name]
    if M.debug.enabled then
      if f then debug_apply(name, value) else debug_skip(name) end
    end
    if f then f(value) end
  end
end

function M.enable(...)
  local enable = true
  local arg = ...
  if arg ~= nil then
    if type(arg) ~= 'boolean' then error('argument must be boolean') end
    enable = arg
  end
  if enable then
    events.connect(events.FILE_OPENED, M.load_editorconfig)
  else
    events.disconnect(events.FILE_OPENED, M.load_editorconfig)
  end
end

textadept.editing.editorconfig = M

return M
