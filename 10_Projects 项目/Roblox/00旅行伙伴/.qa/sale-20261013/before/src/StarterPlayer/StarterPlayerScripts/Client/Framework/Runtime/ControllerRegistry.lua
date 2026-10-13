--!strict

-- 客户端控制器注册表：按 Name 索引模块，并按显式列表执行 Init/Start。
-- 只管理启动顺序，不自动管理 GUI、销毁事件连接或等待服务器数据加载。
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Framework.Shared.App.Logger)
local Lifecycle = require(ReplicatedStorage.Framework.Shared.App.Lifecycle)
local NetClient = require(ReplicatedStorage.Framework.Shared.Net.NetClient)

local ControllerRegistry = {}
-- __index 让 new 创建的实例能找到此表中的方法；冒号调用自动把实例传为 self。
ControllerRegistry.__index = ControllerRegistry

-- 检查并浅复制无空洞数组；固定成员顺序，不复制控制器表或执行 Init。
function ControllerRegistry.new(controllers)
	local snapshot = Lifecycle.CopyList(controllers, "ControllerRegistry controllers")

	local self = setmetatable({}, ControllerRegistry)
	self._controllers = snapshot
	self._controllersByName = {}
	self._state = "New"
	-- context 注入日志、客户端网络入口和控制器索引；Controllers 与内部索引共用引用。
	self._context = {
		Logger = Logger,
		Net = NetClient,
		Controllers = self._controllersByName,
	}
	return self
end

-- 返回已登记的控制器；不存在返回 nil，不触发自动注册或等待。
function ControllerRegistry:GetController(name)
	return self._controllersByName[name]
end

-- 整体预检后初始化；运行中、已完成或失败的注册器都不能重新进入 Init。
function ControllerRegistry:Init()
	if self._state ~= "New" then
		error("ControllerRegistry:Init() cannot run in state " .. self._state, 2)
	end
	self._state = "Initializing"
	local activeName = nil

	local ok, message = xpcall(function()
		local controllersByName = {}
		for index, controller in ipairs(self._controllers) do
			Lifecycle.AssertModule(controller, "Controller[" .. tostring(index) .. "]")
			if controllersByName[controller.Name] ~= nil then
				error("Duplicate controller name: " .. controller.Name)
			end
			controllersByName[controller.Name] = controller
		end

		-- 名称索引整体发布；Init 可以查到靠后模块，但不能假设它已完成初始化。
		self._controllersByName = controllersByName
		self._context.Controllers = controllersByName
		Logger.Debug("ControllerRegistry", "初始化开始")

		for _, controller in ipairs(self._controllers) do
			activeName = controller.Name
			if controller.Init ~= nil then
				Logger.Debug("ControllerRegistry", "正在初始化: " .. controller.Name)
				controller:Init(self._context)
			end
		end
		activeName = nil
		Logger.Info("ControllerRegistry", "初始化完成: " .. tostring(#self._controllers) .. " controllers")
	end, function(problem)
		return Lifecycle.FormatError("ControllerRegistry", "Init", activeName, problem)
	end)
	if not ok then
		self._state = "Failed"
		error(message, 0)
	end
	self._state = "Initialized"
end

-- 全部 Init 成功后才能调用，且不能重复 Start；不返回业务结果。
function ControllerRegistry:Start()
	if self._state ~= "Initialized" then
		error("ControllerRegistry:Start() cannot run in state " .. self._state, 2)
	end
	self._state = "Starting"
	local activeName = nil

	local ok, message = xpcall(function()
		Logger.Debug("ControllerRegistry", "Start begin")

		-- 等待期间保留 Starting；长期工作由控制器自行安排，后续模块仍顺序启动。
		for _, controller in ipairs(self._controllers) do
			activeName = controller.Name
			if controller.Start ~= nil then
				Logger.Debug("ControllerRegistry", "Start " .. controller.Name)
				controller:Start()
			end
		end
		activeName = nil
		Logger.Info("ControllerRegistry", "Start complete: " .. tostring(#self._controllers) .. " controllers")
	end, function(problem)
		return Lifecycle.FormatError("ControllerRegistry", "Start", activeName, problem)
	end)
	if not ok then
		self._state = "Failed"
		error(message, 0)
	end
	self._state = "Started"
end

return ControllerRegistry
