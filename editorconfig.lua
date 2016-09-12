-- Copyright 2016 Joao Valverde joao.valverde.att.tecnico.ulisboa.pt. See LICENSE.

editing = require('textadept.editing')
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

local function debug_table(t)
  local all = {}
  for k, v in pairs(t) do
    all[#all +1] = string.format('"%s" = %s', k, v)
  end
  all = '{ ' .. table.concat(all, ', ') .. ' }'
  local msg = string.format('properties = %s', all)
  debug_print(msg)
end

M.debug.print = debug_print

local set_table = {}

-- indent_style
function set_table.indent_style(t)
  local tabs
  if t.indent_style == ec_core.INDENT_STYLE_TAB then
    tabs = true
  elseif t.indent_style == ec_core.INDENT_STYLE_SPACE then
    tabs = false
  end
  if tabs == nil then return end
  buffer.use_tabs = tabs
end

-- indent_size
function set_table.indent_size(t)
  local size
  if t.indent_size == ec_core.INDENT_SIZE_TAB then
    if t.tab_width ~= nil then
      size = t.tab_width
    end
  else
    size = t.indent_size
  end
  if size == nil then return end
  buffer.indent = size
end

-- tab_width
function set_table.tab_width(t)
  buffer.tab_width = t.tab_width
end

-- end_of_line
function set_table.end_of_line(t)
  local eol
  if t.end_of_line == ec_core.END_OF_LINE_LF then
    eol = buffer.EOL_LF
  elseif t.end_of_line == ec_core.END_OF_LINE_CRLF then
    eol = buffer.EOL_CRLF
  elseif t.end_of_line == ec_core.END_OF_LINE_CR then
    eol = buffer.EOL_CR
  end
  if eol == nil then return end
  buffer.eol_mode = eol
end

-- charset
function set_table.charset(t)
  local enc
  if t.charset == ec_core.CHARSET_LATIN1 then
    enc = 'ISO-8859-1'
  elseif t.charset == ec_core.CHARSET_UTF_8 then
    enc = 'UTF-8'
  elseif t.charset == ec_core.CHARSET_UTF_16BE then
    enc = 'UTF-16BE'
  elseif t.charset == ec_core.CHARSET_UTF_16LE then
    enc = 'UTF-16LE'
  end
  if enc == nil then return end
  buffer:set_encoding(enc)
end

function M.load_editorconfig(filename)
  if M.debug.enabled then M.debug.print(ec_core._VERSION) end
  if not filename then return end
  if M.debug.enabled then debug_filename(filename) end

  -- load table with EditorConfig properties
  local tbl
  local ok, err = pcall(ec_core.parse, filename)
  if not ok then
    if M.debug.enabled then debug_print(err) end
    return
  else
    tbl = err
    if M.debug.enabled then debug_table(tbl) end
  end

  for k, v in pairs(tbl) do
    local f = set_table[k]
    if M.debug.enabled then
      if f then debug_apply(k, v) else debug_skip(k) end
    end
    if f then f(tbl) end
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

editing.editorconfig = M

return M
