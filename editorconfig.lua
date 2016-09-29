-- Copyright 2016 Joao Valverde joao.valverde.att.tecnico.ulisboa.pt. See LICENSE.

ec_core = require('editorconfig_core')

-- Reference: https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties

local M = {}

M.debug = {}
M.debug.enabled = false

function M.debug.print(fmt, ...)
  if not M.debug.enabled then return end
  local msg = string.format(fmt, ...)
  io.stderr:write('editorconfig: ' .. msg .. "\n")
end

local debug_print = M.debug.print

local _F = {}
local _T = ec_core.T

-- indent_style
function _F.indent_style(value)
  if value == _T.INDENT_STYLE_TAB then
    buffer.use_tabs = true
  elseif value == _T.INDENT_STYLE_SPACE then
    buffer.use_tabs = false
  end
end

-- indent_size
function _F.indent_size(value)
  if value == _T.INDENT_SIZE_TAB then
    buffer.indent = 0
  else
    buffer.indent = value
  end
end

-- tab_width
function _F.tab_width(value)
  buffer.tab_width = value
end

-- end_of_line
function _F.end_of_line(value)
  local eol_mode = {
    [_T.END_OF_LINE_LF] = buffer.EOL_LF,
    [_T.END_OF_LINE_CRLF] = buffer.EOL_CRLF,
    [_T.END_OF_LINE_CR] = buffer.EOL_CR,
  }
  local eol = eol_mode[value]
  if eol == nil then return end
  buffer.eol_mode = eol
end

-- charset
function _F.charset(value)
  local encodings = {
    [_T.CHARSET_LATIN1] = 'ISO-8859-1',
    [_T.CHARSET_UTF_8] = 'UTF-8',
    [_T.CHARSET_UTF_16BE] = 'UTF-16BE',
    [_T.CHARSET_UTF_16LE] = 'UTF-16LE',
  }
  local enc = encodings[value]
  if enc == nil then return end
  buffer:set_encoding(enc)
end

function M.load_editorconfig(filepath, confname)
  debug_print(ec_core._VERSION)
  if not filepath then return end
  debug_print('*** configuring "%s"', filepath)

  -- load table with EditorConfig properties
  for name, value in ec_core.open(filepath, confname) do
    local f = _F[name]
    if f then
      debug_print('setting property "%s" = %s', name, value)
    else
      debug_print('skipping property "%s"', name)
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
