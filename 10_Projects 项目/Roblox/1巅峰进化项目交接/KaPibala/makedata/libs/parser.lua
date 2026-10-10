local errors = require 'errors'
local fsystem = require 'fsystem'

local table = table
local string = string
local assert = assert
local tonumber = tonumber
local setmetatable = setmetatable


local OPTIONS = {
	out = 1,
	cols = 1,
	unique = 1,
	multlang = 1,
	conv = 1,
}

local PATTERNS = {
	['$raw'] = 1,
	['$array'] = 1,
	['$struct'] = 1,
	['$weight'] = 1,
	['$format'] = 1,
	['$ex'] = 1,
}

local SEPERATORS = "[:;{}]"

local function isdigit(ch) return string.find(ch, '%d') end
local function isalpha(ch) return string.find(ch, '[_%a]') end


local lexer = {}

function lexer.new(source, filename)
	local inst = {
		fn = filename,
		src = source,
		pos = 1,
		line = 1,
		cached_type = nil,
		cached_token = nil,
	}
	return setmetatable(inst, { __index = lexer })
end

function lexer:try(testval, patt, ...)
	if not testval then
		errors.try(false, '[%s:%s]: ' .. patt, self.fn, self.line, ...)
	end
	return testval
end

function lexer:step(field, incr)
	self[field] = self[field] + incr
end

function lexer:skip_comment()
	local pos = self:match"[^\n]*\n?()"
	self:try(pos, "match line comment failed")
	self.pos = pos
	self.line = self.line + 1
end

function lexer:skip_spaces()
	while self.pos <= #self.src do
		if self:match"//" then
			self:skip_comment()
		elseif self:match"\r\n" or self:match"\n\r" then
			self:step('pos', 2) 
			self:step('line', 2)
		elseif self:match"\r" or self:match"\n" then
			self:step('pos', 1) 
			self:step('line', 1)
		elseif self:match"%s" then
			self:step('pos', 1)
		else
			break
		end
	end
end

function lexer:skip_semicolons(do_skip)
	if not do_skip then
		return
	end
	self:expect';'
	while self:test';' do
		self:next()
	end
end

function lexer:match(patt)
	return self.src:match('^'..patt, self.pos)
end

function lexer:scan_integer()
	local str, pos = self:match"(%d+)()"
	self:try(str, 'match <integer> failed')
	self.pos = pos
	return tonumber(str)
end

function lexer:scan_identifier()
	local str, pos = self:match"([_a-zA-Z][_%-%w]*)()"
	self:try(str, 'match <identifier> failed')
	self.pos = pos
	return str
end

function lexer:scan_string()
	local ch = self:get_char()
	self:step('pos', 1)
	local str, pos
	if ch == '"' then
		str, pos = self:match'([^"]*)"()'
	else
		str, pos = self:match"([^']*)'()"
	end
	self:try(str, 'match <string> failed')
	self.pos = pos
	return str
end

function lexer:get_char()
	local pos = self.pos
	return self.src:sub(pos, pos)
end

function lexer:eof()
	self:skip_spaces()
	return self.pos > #self.src 
end

function lexer:next()
	if self.cached_type then
		local type = self.cached_type
		self.cached_type = nil
		return type, self.cached_token
	end

	if self:eof() then
		return 'eof', 'eof'
	end

	local ch = self:get_char()
	if isalpha(ch) then
		local ident = self:scan_identifier()
		if OPTIONS[ident] then
			return 'option', ident
		end
		return 'identifier', ident

    elseif ch == '$' then
		self:step('pos', 1)
		local patt = '$' .. self:scan_identifier()
		if PATTERNS[patt] then
			return 'pattern', patt
		end

    elseif ch == '"' or ch == "'" then
		return 'string', self:scan_string()

	elseif isdigit(ch) then
		return 'integer', self:scan_integer()

	elseif ch:find(SEPERATORS) then
		self:step('pos', 1)
		return ch, ch
	end

	self:try(false, "unexpected symbos near %q", ch)
end

function lexer:peek()
	local type = self.cached_type
	if type then
		return type
	end
	local type, token = self:next()
	self.cached_type = type
	self.cached_token = token
	return type
end

function lexer:test(type)
	return (type == self:peek())
end

function lexer:expect(type, testval)
	local _type, token = self:next()
	self:try(_type == type, '<%s> expected got <%s>', type, _type)
	if testval then
		self:try(token == testval, '<%s> expected got <%s>', testval, token)
	end
	return token
end


local function parse_identifiers(lex, optstr)
	local list = {}
	while not lex:test';' do
		list[#list+1] = lex:expect'identifier' .. (optstr or '')
	end
	return list
end


local handlers = {}

handlers['$raw'] = function(lex) 
	return '$raw' 
end

handlers['$array'] = function(lex) 
	return '$array' 
end

handlers['$format'] = function(lex) 
	local function filter(option)
		local ok = option == '%s' or option == '%q'
		lex:try(ok, 'invalid format option %q, consider %%s or %%q', option)
		return option
	end
	local f = lex:expect'string'
	local _, n = string.gsub(f, '%%%a', filter)
	lex:try(n > 0, 'no format option in the format string')
	return { type = '$struct', n = n, f = f } 
end

handlers['$weight'] = function(lex) 
	local rule = handlers['$struct'](lex)
	rule.type = '$weight'
	return rule
end

handlers['$struct'] = function(lex) 
	local fields = parse_identifiers(lex, '=%s')
	return {
		type = '$struct',
		n = #fields,
		f = '{' .. table.concat(fields, ',') .. '}'
	}
end

handlers['cols'] = function(lex) 
	local exclude
	if lex:test'pattern' then
		exclude = lex:expect('pattern', '$ex')
	end
	local cols = parse_identifiers(lex)
	cols.exclude = exclude
	return cols
end

handlers['multlang'] = handlers['cols']

handlers['conv'] = function(lex) 
	local prev
	local rules = {}
	lex:expect'{'
	while not lex:test'}' do
		local field = lex:expect'identifier' lex:expect':'
		if lex:test';' then
			rules[field] = lex:try(prev, 'previous rule not exist')
		else
			local patt = lex:expect'pattern'
			rules[field] = handlers[patt](lex)
			prev = rules[field]
		end
		lex:skip_semicolons(true)
	end
	lex:expect'}'
	return rules
end

handlers['out'] = function(lex) 
	return lex:expect'identifier'  
end

handlers['unique'] = function(lex) 
	return lex:expect'identifier' 
end


local function parse_descriptor(lex)
	local name = lex:expect'identifier'
	local desc = { name = name, out = name, cols = '*' }
	lex:expect'{'
	while not lex:test'}' do
		local option = lex:expect'option' lex:expect':'
		desc[option] = handlers[option] (lex)
		lex:skip_semicolons(option ~= 'conv')
	end
	lex:expect'}'
	return desc
end


local M = {}

function M.descriptor(filename)
	local source = assert(fsystem.file.read(filename))
	local result = {}
	local lex = lexer.new(source, filename)
	while not lex:eof() do
		local desc = parse_descriptor(lex)
		result[desc.name] = desc
	end
	return result
end

function M.dependence(filename)
	local source = assert(fsystem.file.read(filename))
	local default_out = fsystem.file.name(filename)

	local function getline(pos)	return string.match(source, '([^\r\n]+)\n()', pos or 1)	end
	local function gettagpos(str, patt) return string.match(str, '--[%s\t]*' .. patt .. '()') end
	local function split(str)
		local list = {}
		for one in string.gmatch(str, '[^%s]+') do
			list[#list+1] = one
		end
		return list
	end

	-- parse dep line
	local depline, next = getline()
	errors.try(depline, '"--dep:" not found in %q', filename)

	local pos = gettagpos(depline, 'dep:')
	errors.try(pos, '"--dep:" not found in %q', filename)

	local deps = split(string.sub(depline, pos))
	errors.try(#deps > 0, 'count of dependences is ZERO')

	-- try parse out line
	local outline = getline(next)
	if not outline then
		return { deps = deps, outs = { default_out } }
	end

	local pos = gettagpos(outline, 'out:')
	if not pos then
		return { deps = deps, outs = { default_out } }
	end

	return { deps = deps, outs = split(string.sub(outline, pos)) }
end

return M