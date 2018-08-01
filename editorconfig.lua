-- Copyright 2016 Joao Valverde joao.valverde.att.tecnico.ulisboa.pt. See LICENSE.

-- Reference: https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties

ec = require('editorconfig')

assert(ec._VERSION >= 'EditorConfig Lua Core Version 0.3.0',
        'EditorConfig Lua Core 0.3.0 or above is required')

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

local function debug_value(value)
  if value ~= 'unset' then
    debug_print('unknown or invalid value: %s (%s)', value, type(value))
  end
end

local function true_or_false(value)
  if value == 'true' then
    return true
  elseif value == 'false' then
    return false
  else
    debug_value(value)
  end
end

local function positive_or_zero(value)
  value = math.tointeger(value)
  if value ~= nil and value >= 0 then
    return value
  end
  debug_value(value)
end

local _F = {}

-- indent_style
function _F.indent_style(value)
  local tabs
  if value == 'tab' then
    tabs = true
  elseif value == 'space' then
    tabs = false
  else
    debug_value(value)
  end
  if tabs ~= nil then
    buffer.use_tabs = tabs
  end
end

-- indent_size
function _F.indent_size(value)
  local indent
  if value == 'tab' then
    indent = 0
  end
  if indent == nil then
    indent = positive_or_zero(value)
  end
  if indent ~= nil then
    buffer.indent = indent
  else
    debug_value(value)
  end
end

-- tab_width
function _F.tab_width(value)
  local width = positive_or_zero(value)
  if width ~= nil then
    buffer.tab_width = width
  else
    debug_value(value)
  end
end

-- end_of_line
function _F.end_of_line(value)
  local mode
  if value == 'lf' then
     mode = buffer.EOL_LF
  elseif value == 'crlf' then
    mode = buffer.EOL_CRLF
  elseif value == 'cr' then
    mode = buffer.EOL_CR
  else
    debug_value(value)
  end
  if mode ~= nil then
    buffer.eol_mode = mode
  end
end

-- charset
function _F.charset(value)
  local encoding
  if value == 'latin1' then
    encoding = 'ISO-8859-1'
  elseif value == 'utf-8' then
    encoding = 'UTF-8'
  elseif value == 'utf-16be' then
    encoding = 'UTF-16BE'
  elseif value == 'utf16-le' then
    encoding = 'UTF-16LE'
  else
    debug_value(value)
  end
  if encoding ~= nil and buffer.encoding ~= encoding then
    buffer.encoding = encoding
    io.reload_file()
  end
end

-- trim_trailing_whitespace
function _F.trim_trailing_whitespace(value)
  local trim = true_or_false(value)
  if trim ~= nil then
    buffer.editorconfig.trim_trailing_whitespace = trim
  else
    debug_value(value)
  end
end

-- insert_final_newline
function _F.insert_final_newline(value)
  local insert = true_or_false(value)
  if insert ~= nil then
    buffer.editorconfig.insert_final_newline = insert
  else
    debug_value(value)
  end
end

local function editorconfig_file_opened(filepath)
  if not M.enabled then return end
  debug_print(ec._VERSION)
  if not filepath then return end
  debug_print('*** configuring "%s"', filepath)
  buffer.editorconfig = buffer.editorconfig or {}

  -- load table with EditorConfig properties
  properties = ec.parse(filepath)
  for name, value in pairs(properties) do
    debug_property(name, value)
    local func = _F[name]
    if func then
      func(value)
    else
      debug_print('unknown property "%s"', name)
    end
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
