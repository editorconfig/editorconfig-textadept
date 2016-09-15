-- Copyright 2016 Joao Valverde joao.valverde.att.tecnico.ulisboa.pt. See LICENSE.

ec_core = require('editorconfig_core')

-- Reference: https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties

local M = {}

M.debug = {}

M.debug.enabled = false

-- stand-alone mode for testing
if not textadept then
  buffer = {}
  buffer.set_encoding = function(buf, enc) buffer.set_encoding = enc end
  M.debug.enabled = true
end 

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
  for _, k in ipairs(t) do
    all[#all +1] = string.format('"%s" = %s', k, t[k])
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
  if t.indent_style == "tab" then
    tabs = true
  elseif t.indent_style == "space" then
    tabs = false
  end
  if tabs == nil then return end
  buffer.use_tabs = tabs
end

-- indent_size
function set_table.indent_size(t)
  local size
  if t.indent_size == "tab" then
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
  if t.end_of_line == "lf" then
    eol = buffer.EOL_LF
  elseif t.end_of_line == "crlf" then
    eol = buffer.EOL_CRLF
  elseif t.end_of_line == "cr" then
    eol = buffer.EOL_CR
  end
  if eol == nil then return end
  buffer.eol_mode = eol
end

-- charset
function set_table.charset(t)
  local enc
  if t.charset == "latin1" then
    enc = 'ISO-8859-1'
  elseif t.charset == "utf-8" then
    enc = 'UTF-8'
  elseif t.charset == "utf-16be" then
    enc = 'UTF-16BE'
  elseif t.charset == "utf-16le" then
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

  for _, k in ipairs(tbl) do
    local f = set_table[k]
    if M.debug.enabled then
      if f then debug_apply(k, tbl[k]) else debug_skip(k) end
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

if textadept then
  require('textadept.editing').editorconfig = M
  return M
end

if not arg[1] then
  print("Need full path to filename.")
  os.exit(1)
end
M.load_editorconfig(arg[1])
for k, v in pairs(buffer) do
  local msg = string.format("%s <- %s", k, v)
  print(msg)
end
os.exit(0)
