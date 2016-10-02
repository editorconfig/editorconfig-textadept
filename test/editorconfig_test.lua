-- Copyright 2016 Joao Valverde joao.valverde.att.tecnico.ulisboa.pt. See LICENSE.

package.cpath = "./?.so;" .. package.cpath

textadept = {}
textadept.editing = {}

local ec = require("editorconfig")
local lfs = require("lfs")
local test = require("pl.test")
local dump = require("pl.pretty").dump

local EOL_LF, EOL_CRLF, EOL_CR = 1, 2, 3 -- arbitrary values

buffer = {}
buffer.EOL_LF = EOL_LF
buffer.EOL_CRLF = EOL_CRLF
buffer.EOL_CR = EOL_CR
buffer.set_encoding = function(buf, enc) buffer.set_encoding = enc end

function io.reload_file() return end

-- ec.debug.enabled = true
ec.load_editorconfig(lfs.currentdir() .. "/test/empty.txt")

-- dump(buffer)
test.asserteq(buffer.use_tabs, false)
test.asserteq(buffer.indent, 4)
test.asserteq(buffer.tab_width, 8)
test.asserteq(buffer.eol_mode, EOL_LF)
test.asserteq(buffer.encoding, "UTF-16LE")

print("Test OK.")
