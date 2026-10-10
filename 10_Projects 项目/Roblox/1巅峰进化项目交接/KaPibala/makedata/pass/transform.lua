local errors = require 'errors'
local version = require 'version'
local fsystem = require 'fsystem'
local dependence = require 'dependence'

local table = table
local debug = debug
local type = type
local next = next
local xpcall = xpcall
local dofile = dofile
local loadfile = loadfile
local setmetatable = setmetatable
local print = print

local REDIRECT_PREFIX = '__REDIRECT_'


local function do_exec(path, deps)
	-- 加载自定义转换脚本
	local chunk = errors.try(loadfile(path))

	-- 设置环境 注入依赖数据表
	local env = setmetatable({ Data = deps:load() }, { __index = _G })
	debug.setupvalue(chunk, 1, env)

	-- 开始执行
	local results = { chunk() }
	errors.try( #results ~= 0, 'return value of transform script could not be nil')

	for i=1, #results do 
		errors.try(type(results[i]) == 'table', 'return value of transform script must be a table')
	end

	local outs = deps:get_outs()
	errors.try(#outs == #results,"amount of return values and output filenames must be equal")

	-- 输出到文件
	for i=1, #outs do
		local outpath = fsystem.dir.temp(outs[i])
		fsystem.file.write(outpath, 'return ', results[i])
	end
end

local function exec()
	local redirects = {}
	local jobs = {}

	-- 分析全部自定义转换脚本 组建重定向映射
	for _, path in next, fsystem.dir.list'TRANSFORM' do
		local deps = dependence.parse(path)
		local ok, err = deps:valid()
		errors.try(ok, 'tranform script %q valid failed: %s', path, err)

		for name in next, deps:get_overlaps() do
			if version.is_dirty(name) then
				local srcpath = fsystem.dir.temp(name)
				local redpath = fsystem.dir.temp(REDIRECT_PREFIX .. name)
				fsystem.file.copy(srcpath, redpath)
				redirects[name] = REDIRECT_PREFIX .. name
			end
		end

		if deps:dirty() then
			deps:redirect(redirects)
			jobs[path] = deps
		end
	end

	for path, deps in next, jobs do
		print('transforming...', path)
		local ok, err = xpcall(do_exec, debug.traceback, path, deps)
		errors.try(ok, err)
	end
end

return {
	exec = exec
}