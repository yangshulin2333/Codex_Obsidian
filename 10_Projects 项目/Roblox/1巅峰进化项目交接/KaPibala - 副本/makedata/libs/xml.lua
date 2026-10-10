local lpeg = require 'lpeg'

local type = type
local next = next
local table = table
local string = string

local P = lpeg.P
local S = lpeg.S
local R = lpeg.R
local C = lpeg.C
local Ct = lpeg.Ct
local Cg = lpeg.Cg
local V = lpeg.V
local M = lpeg.match

local eof = P(-1)
local alpha = R('az') + R('AZ')
local digit = R('09')
local space = S(' \t')
local newline = P('\r\n') + '\n'
local blank = space + newline
local blanks = blank^0
local token = alpha + digit + '-' + '_' + '.'
local ident = token^1

local function bk(patt)
	return blanks * patt
end

local HEAD = bk("<") * bk(C(ident)) * bk(">")
local TAIL = bk("</") * bk(ident) * bk(">")
local DATA = C((1 - TAIL)^0)
local CDATA_HEAD = bk("<![CDATA[")
local CDATA_TAIL = bk("]]>")
local CDATA = CDATA_HEAD * C((1-CDATA_TAIL)^0) * CDATA_TAIL
local NODE = P{ Ct( Cg(HEAD,"name") * (V(1)^1 + Cg(CDATA + DATA,"value")) * TAIL) }


local function build(node, result)
	local name = node.name
	local value = node.value
	if value then
		result[name] = value
	else
		local nesting_result = {}
		result[name] = nesting_result
		for idx=1, #node do
			build(node[idx], nesting_result)
		end
	end
end

local function decode(data)
	local root = M(NODE, data)
	if not root then
		return nil, 'parse xml string failed'
	end
	local result = {}
	build(root, result)
	return result
end

local function gen_valuenode(key, value, is_cdata)
	if is_cdata then
		return string.format('<%s><![CDATA[%s]]></%s>', key, value, key)
	else
		return string.format('<%s>%s</%s>', key, value, key)
	end
end

local function do_encode(tb, buffer, is_cdata)
	for key, value in next, tb do
		if type(value) ~= 'table' then
			buffer[#buffer+1] = gen_valuenode(key, value, is_cdata)
		else
			buffer[#buffer+1] = string.format('<%s>', key) -- node head
			do_encode(value, buffer, is_cdata)
			buffer[#buffer+1] = string.format('</%s>', key) -- node tail
		end
	end
end

local function encode(tb, is_cdata)
	local buffer = {}
	do_encode(tb, buffer, is_cdata)
	return table.concat(buffer)
end

return {
	decode = decode,
	encode = encode
}