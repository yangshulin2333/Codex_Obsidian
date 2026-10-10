local encoder = require 'encoder'

local io = io
local os = os
local string = string
local type = type
local select = select
local assert = assert

local TEMP = '0temp'
local DESC = '../config_desc/descriptor'
local TRANSFORM = '../config_desc/transform'
local GUARD = '../config_desc/guard'

local DIR_MAP = {
	TEMP = TEMP,
	DESC = DESC,
	TRANSFORM = TRANSFORM,
	GUARD = GUARD,
}

local EXT_MAP = {
	DESC = '.desc',
	TEMP = '.lua',
	GUARD = '.lua',
	TRANSFORM = '.lua',
}


local M = {
	dir = {},
	file = {}
}

function M.dir.list(type)
	local root = assert(DIR_MAP[type], 'invalid directory type')
	local ext = EXT_MAP[type]
	return os.list(root, ext)
end

function M.dir.make(path, node)
	if node then
		path = path .. '/' .. node
	end
	path = string.gsub(path, '/', '\\')
	local cmd = string.format('if not exist %s (md %s)', path, path)
	os.execute(cmd)
end

function M.dir.clear(path, node)
	if node then
		path = path .. '/' .. node
	end
	path = string.gsub(path, '/', '\\')
	local cmd = string.format('del %s\\* /q', path)
	os.execute(cmd)
end

function M.dir.temp(filename)
	return string.format('%s/%s.lua', TEMP, filename)
end

function M.file.write(path, ...)
	local f = io.open(path, 'w+b')
	for i=1, select('#', ...) do
		local content = select(i, ...)
		if type(content) == 'table' then
			content = encoder.encode(content)
		end
		f:write(content)
	end
	f:close()
end

function M.file.read(path)
	local f = io.open(path)
	if not f then
		return nil, string.format('can not open file: %q', path)
	end
	local content = f:read'*a'
	f:close()
	return content
end

function M.file.copy(src, dst)
	local content = assert(M.file.read(src))
	M.file.write(dst, content)
end

function M.file.exists(path)
	local f = io.open(path)
	if f then
		f:close()
		return true
	end
end

function M.file.name(path)
	return string.match(path, '([^/\\]+)%.%w+$')
end


M.dir.make(TEMP)
M.dir.clear(TEMP)

return M