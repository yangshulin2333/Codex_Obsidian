local table = table
local string = string
local type = type
local next = next
local assert = assert
local tostring = tostring
local setmetatable = setmetatable

local MAX_DEPTH = 32

local function encode_key(key)
	if not key then
		return nil
	end
	local key_type = type(key)
	if key_type == 'number' then
		return string.format('[%d]', key)
	end
	local std_key = string.find(key, '^[_a-zA-Z][_%w]*$')
	if std_key then
		return key
	end
	return string.format('[%q]', key)
end

local function encode_value(value)
	if type(value) == 'string' then
		return string.format('%q', value)
	else
		return tostring(value)
	end
end

local encoder_meta = {}
encoder_meta.__index = encoder_meta

function encoder_meta:open(key)
	local depth = self.depth + 1
	assert(depth <= MAX_DEPTH, 'nesting is too deep or loop table')
	self.depth = depth
	self.indent = string.rep('\t', depth)
	local key_str = encode_key(key)
	if key_str then
		self[#self+1] = string.rep('\t', depth-1) .. key_str .. ' = {'
	else
		self[#self+1] = string.rep('\t', depth-1) .. '{'
	end
end

function encoder_meta:push(key, value)
	local key_str = encode_key(key)
	local val_str = encode_value(value)
	if key_str then
		self[#self+1] = self.indent .. key_str .. ' = ' .. val_str .. ','
	else
		self[#self+1] = self.indent .. val_str .. ','
	end
end

function encoder_meta:close()
	local depth = self.depth - 1
	local dot = depth == 0 and '' or ','
	self.depth = depth
	self.indent = string.rep('\t', depth)
	self[#self+1] = self.indent .. '}' .. dot
end

function encoder_meta:dump()
	return table.concat(self, '\n')
end


local encode_table

local function is_array(tb)
	if next(tb) ~= 1 then
		return false
	end
	local len = #tb
	if len > 0 then
		return (not next(tb, len))
	end
end

local function encode_pair(encoder, key, value)
	local key_type = type(key)
	assert(key_type == 'number' or key_type == 'string' or key_type == 'nil', 'type of key must be string or number')

	local val_type = type(value)
	assert(val_type == 'string' or val_type == 'number' or val_type == 'boolean' or val_type == 'table' or val_type == 'nil', 'invalid value type')

	if val_type == 'table' then
		encode_table(encoder, key, value)
	else
		encoder:push(key, value)
	end
end

function encode_table(encoder, key, tb)
	encoder:open(key)
	if is_array(tb) then
		for idx=1, #tb do
			encode_pair(encoder, nil, tb[idx])
		end
	else
		for key, value in next, tb do
			encode_pair(encoder, key, value)
		end
	end
	encoder:close()
end

return {
	encode = function(tb)
		local encoder = setmetatable({depth=0}, encoder_meta)
		encode_table(encoder, nil, tb)
		return encoder:dump()
	end
}
