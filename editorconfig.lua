-- Copyright 2016 Joao Valverde joao.valverde.att.tecnico.ulisboa.pt. See LICENSE.

-- Reference: https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties

ec_core = require('editorconfig_core')

assert(ec_core._VERSION >= "EditorConfig Lua Core Version 0.2.0",
        "EditorConfig Lua Core 0.2.0 or above is required")

local M = {}

M.enabled = true
M.debug = {}
M.debug.enabled = false

function M.debug.print(fmt, ...)
  if not M.debug.enabled then return end
  local msg = string.format(fmt, ...)
  io.stderr:write('editorconfig: ' .. msg .. '\n')
end

local debug_print = M.debug.print

local function debug_property(name, value)
  debug_print('setting property "%s" = %s', name, value)
end

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
  if buffer.encoding ~= enc then
    buffer.encoding = enc
    io.reload_file()
  end
end

function _F.trim_trailing_whitespace(value)
  buffer.editorconfig.trim_trailing_whitespace = value
end

function _F.insert_final_newline(value)
  buffer.editorconfig.insert_final_newline = value
end

local function editorconfig_file_opened(filepath)
  if not M.enabled then return end
  debug_print(ec_core._VERSION)
  if not filepath then return end
  debug_print('*** configuring "%s"', filepath)
  buffer.editorconfig = buffer.editorconfig or {}

  -- load table with EditorConfig properties
  for name, value in ec_core.open(filepath) do
    local f = _F[name]
    if f then debug_property(name, value) end
    if f then f(value) end
  end
  events.emit(events.UPDATE_UI) -- for updating statusbar
end

-- copied from textadept/modules/textadept/editing.lua
local function strip_trailing_whitespace()
  for line = 0, buffer.line_count - 1 do
    local s, e = buffer:position_from_line(line), buffer.line_end_position[line]
    local i, byte = e - 1, buffer.char_at[e - 1]
    while i >= s and (byte == 9 or byte == 32) do
      i, byte = i - 1, buffer.char_at[i - 1]
    end
    if i < e - 1 then buffer:delete_range(i + 1, e - i - 1) end
  end
end

-- copied from textadept/modules/textadept/editing.lua
local function ensure_ending_newline()
  local e = buffer:position_from_line(buffer.line_count)
  if buffer.line_count == 1 or
     e > buffer:position_from_line(buffer.line_count - 1) then
    buffer:insert_text(e, '\n')
  end
end

-- "textadept.editing.strip_trailing_spaces" needs to be set to "false"
-- to allow per-buffer settings.
local function editorconfig_file_before_save(filepath)
  if not M.enabled then return end
  if not buffer.editorconfig then return end
  if buffer.editorconfig.trim_trailing_whitespace then
    strip_trailing_whitespace()
  end
  if buffer.editorconfig.insert_final_newline then
    ensure_ending_newline()
  end
end

events.connect(events.FILE_OPENED, editorconfig_file_opened)
events.connect(events.FILE_BEFORE_SAVE, editorconfig_file_before_save)

textadept.editing.editorconfig = M

return true
