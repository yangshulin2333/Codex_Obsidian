--!strict

-- 每个客户端的启动入口：合并 Controller 清单，依次初始化与启动，不承担服务器权威状态修改。
-- Controller 是客户端控制模块，例如绑定按钮或刷新显示；必须显式登记才能启动。
local ControllerRegistry = require(script.Parent.Framework.Runtime.ControllerRegistry)
local FrameworkControllerList = require(script.Parent.Framework.Runtime.ControllerList)
local GameControllerList = require(script.Parent.Game.Runtime.GameControllerList)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lifecycle = require(ReplicatedStorage.Framework.Shared.App.Lifecycle)

-- Framework 在前、Game 在后；先分别检查原清单，再追加模块引用。
local frameworkControllers = Lifecycle.CopyList(FrameworkControllerList, "Framework ControllerList")
local gameControllers = Lifecycle.CopyList(GameControllerList, "Game GameControllerList")
local controllers = {}
for _, controller in ipairs(frameworkControllers) do
	table.insert(controllers, controller)
end
for _, controller in ipairs(gameControllers) do
	table.insert(controllers, controller)
end

local registry = ControllerRegistry.new(controllers)
-- 全部 Init 返回后才执行 Start；客户端这套流程独立运行，不表示服务器存档已经加载完成。
registry:Init()
registry:Start()
