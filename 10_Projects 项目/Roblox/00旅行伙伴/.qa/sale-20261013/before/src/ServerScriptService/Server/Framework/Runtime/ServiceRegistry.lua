--!strict
-- 服务器服务注册表：维护 Name -> 服务表的索引，并执行 Init/Start 两个阶段。
-- 不扫描目录、不自动排序依赖、不保护性吞掉启动异常；顺序由 Main 传入的列表决定。
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Framework.Shared.App.Logger)
local Lifecycle = require(ReplicatedStorage.Framework.Shared.App.Lifecycle)

local ServiceRegistry = {}
-- 实例没有某个字段时，通过 __index 到 ServiceRegistry 查找方法。
ServiceRegistry.__index = ServiceRegistry

-- 检查并浅复制无空洞的服务数组；固定成员顺序，不复制服务表或执行 Init。
function ServiceRegistry.new(services)
	local snapshot = Lifecycle.CopyList(services, "ServiceRegistry services")

	-- setmetatable 将新表与方法表关联；不同注册器有各自的索引和阶段标记。
	local self = setmetatable({}, ServiceRegistry)
	self._services = snapshot

	self._servicesByName = {}
	self._state = "New"
	-- context 是传入每个 Init 的共享上下文；Services 与内部名称索引指向同一张表。
	self._context = {
		Logger = Logger,
		Services = self._servicesByName,
	}
	return self
end

-- 按 Name 返回已登记的服务表；未找到返回 nil，不会等待或自动加载模块。
function ServiceRegistry:GetService(name)
	return self._servicesByName[name]
end

-- 整体预检后初始化；运行中、已完成或失败的注册器都不能重新进入 Init。
function ServiceRegistry:Init()
	if self._state ~= "New" then
		error("ServiceRegistry:Init() cannot run in state " .. self._state, 2)
	end
	self._state = "Initializing"
	local activeName = nil

	local ok, message = xpcall(function()
		-- 先完成全部格式与重名检查，避免后面发现错误时前面的 Init 已产生副作用。
		local servicesByName = {}
		for index, service in ipairs(self._services) do
			Lifecycle.AssertModule(service, "Service[" .. tostring(index) .. "]")
			if servicesByName[service.Name] ~= nil then
				error("Duplicate service name: " .. service.Name)
			end
			servicesByName[service.Name] = service
		end

		-- 名称索引整体发布；“查得到”不代表对方已初始化。
		self._servicesByName = servicesByName
		self._context.Services = servicesByName
		Logger.Debug("ServiceRegistry", "初始化开始")

		for _, service in ipairs(self._services) do
			activeName = service.Name
			if service.Init ~= nil then
				Logger.Debug("ServiceRegistry", "初始化 " .. service.Name)
				service:Init(self._context)
			end
		end
		activeName = nil
		Logger.Info("ServiceRegistry", "初始化完成: " .. tostring(#self._services) .. " services")
	end, function(problem)
		return Lifecycle.FormatError("ServiceRegistry", "Init", activeName, problem)
	end)
	if not ok then
		self._state = "Failed"
		error(message, 0)
	end
	self._state = "Initialized"
end

-- 必须在 Init 成功后调用一次；全部 Init 已返回，但异步加载的玩家数据不一定已就绪。
function ServiceRegistry:Start()
	if self._state ~= "Initialized" then
		error("ServiceRegistry:Start() cannot run in state " .. self._state, 2)
	end
	self._state = "Starting"
	local activeName = nil

	local ok, message = xpcall(function()
		Logger.Debug("ServiceRegistry", "启动开始")

		-- 同步调用；等待期间保留 Starting，阻止重入或其他协程重复启动。
		for _, service in ipairs(self._services) do
			activeName = service.Name
			if service.Start ~= nil then
				Logger.Debug("ServiceRegistry", "启动 " .. service.Name)
				service:Start()
			end
		end
		activeName = nil
		Logger.Info("ServiceRegistry", "启动完成: " .. tostring(#self._services) .. " services")
	end, function(problem)
		return Lifecycle.FormatError("ServiceRegistry", "Start", activeName, problem)
	end)
	if not ok then
		self._state = "Failed"
		error(message, 0)
	end
	self._state = "Started"
end

return ServiceRegistry
