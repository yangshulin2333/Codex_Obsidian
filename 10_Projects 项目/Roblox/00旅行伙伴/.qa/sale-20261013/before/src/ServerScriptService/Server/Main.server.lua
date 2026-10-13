--!strict
-- 服务器启动入口：组合框架与游戏的服务清单，再统一执行生命周期；不放具体业务规则。
-- require 取得 ModuleScript 返回的服务表；放进目录不等于注册，必须加入对应清单。
local ServiceRegistry = require(script.Parent.Framework.Runtime.ServiceRegistry)
local FrameworkServiceList = require(script.Parent.Framework.Runtime.ServiceList)
local GameServiceList = require(script.Parent.Game.Runtime.GameServiceList)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lifecycle = require(ReplicatedStorage.Framework.Shared.App.Lifecycle)

-- Framework 先加入，Game 后加入；顺序决定每个阶段的调用次序，不是先启动完一组再初始化另一组。
-- 合并前分别检查原清单，避免 ipairs 在空洞处停止而漏掉后面的模块。
local frameworkServices = Lifecycle.CopyList(FrameworkServiceList, "Framework ServiceList")
local gameServices = Lifecycle.CopyList(GameServiceList, "Game GameServiceList")
local services = {}
for _, service in ipairs(frameworkServices) do
	table.insert(services, service)
end
for _, service in ipairs(gameServices) do
	table.insert(services, service)
end

local registry = ServiceRegistry.new(services)

-- Init 先登记全部服务并逐个初始化；全部 Init 返回后才进入 Start。
-- 冒号会自动传入 registry 作为 self；启动异常向外抛出，不跳过失败服务继续启动。
registry:Init()
registry:Start()
