local errors = require 'errors'
local fsystem = require 'fsystem'
local dependence = require 'dependence'

local os = os
local io = io
local debug = debug
local table = table
local string = string
local next = next
local xpcall = xpcall
local loadfile = loadfile
local setmetatable = setmetatable
local print = print


local meta_collector = {}
meta_collector.__index = meta_collector  

function meta_collector:start(id)
    self.id = id
    self.list[id] = {}
end

function meta_collector:push(fmt, ...)
	errors.try(self.id, 'call Start(id) first')
    table.insert(self.list[self.id], string.format(fmt, ...))
end

function meta_collector:stop()
    local id = errors.try(self.id, 'call Start(id) first')
    if #self.list[id] == 0 then
        self.list[id] = nil
    end
	self.id = nil
end

function meta_collector:print(buffer)
	local name = fsystem.file.name(self.path)
	local title = string.format('------------错误文件: <%s>------------', name)
	table.insert(buffer, title)

    for id, errs in next, self.list do
        if #errs > 1 then
            table.insert(buffer, string.format('<ID: %s>', id))
            table.insert(buffer, table.concat(errs, '\n'))
        else
            table.insert(buffer, string.format('<ID: %s> %s', id, errs[1]))
        end
    end
end

function meta_collector:has_error()
	return (next(self.list))
end


local function create_env(path, deps)
	-- 生成错误收集器对象
	local collector = setmetatable({ path = path, list = {} }, meta_collector)

	-- 创建执行环境
	return setmetatable({
		Collector = collector,
		Data = deps:load(),
        Start = function(...) collector:start(...) end,
        Push = function(...) collector:push(...) end,
        Stop = function() collector:stop() end
    }
    , { __index = _G })
end


local function do_exec(path, deps, error_infos)
	-- 加载自定义转换脚本
	local chunk = errors.try(loadfile(path))

	-- 设置环境
	local env = create_env(path, deps)
    debug.setupvalue(chunk, 1, env)

	-- 开始执行
	chunk()

	-- 检测到错误 输出错误信息
	if env.Collector:has_error() then
		env.Collector:print(error_infos)
	end
end

local function exec()
	local jobs = {}
	for _, path in next, fsystem.dir.list'GUARD' do
		local deps = dependence.parse(path)
		local ok, err = deps:valid()
		errors.try(ok, 'guard script %q valid failed: %s', path, err)

		if deps:dirty() then
			jobs[path] = deps
		end
	end

	local error_infos = {}
	for path, deps in next, jobs do
		print('guarding...', path)
		local ok, err = xpcall(do_exec, debug.traceback, path, deps, error_infos)
		errors.try(ok, err)
	end

    if #error_infos > 0 then
		local errs = table.concat(error_infos, '\n')
		fsystem.file.write('error_report.txt', errs)
        os.execute('notepad error_report.txt')
        os.remove('error_report.txt')
		os.exit()
    end
end


return {
	exec = exec,
}