local errors = require 'errors'
local version = require 'version'
local fsystem = require 'fsystem'
local parser = require 'parser'

local table = table
local debug = debug
local string = string
local next = next
local dofile = dofile
local xpcall = xpcall
local setmetatable = setmetatable


local obj_meta = {}
obj_meta.__index = obj_meta  

function obj_meta:valid()
	for idx=1, #self.deps do
		local name = self.deps[idx]
		local path = fsystem.dir.temp(name)
		local ok = fsystem.file.exists(path)
		if not ok then
			return nil, string.format('dependent file %q not exist', path)
		end
	end
	return true
end

function obj_meta:dirty()
	for idx=1, #self.deps do
		if version.is_dirty(self.deps[idx]) then
			return true
		end
	end
end

function obj_meta:load()
	local map = self.redirect_map or {}
	return setmetatable({}, { __index = function(self, key)
		local path = fsystem.dir.temp(map[key] or key)
		local ok, tb = xpcall(dofile, debug.traceback, path)
		errors.try(ok, 'load dependent file %q failed:\r\n%s', path, tb)
		self[key] = tb
		return tb
	end})
end

function obj_meta:get_outs()
	return self.outs
end

function obj_meta:redirect(map)
	self.redirect_map = map
end

function obj_meta:get_overlaps()
	-- 取得同时出现在输入、输出中的名字
	local d = table.project(self.deps)
	local o = table.project(self.outs)
	return table.intersection(d, o)
end

local function parse(filename)
	-- 从注释解析依赖文件和输出文件
	local result = parser.dependence(filename)
	return setmetatable(result, obj_meta)
end

return {
	parse = parse,
}