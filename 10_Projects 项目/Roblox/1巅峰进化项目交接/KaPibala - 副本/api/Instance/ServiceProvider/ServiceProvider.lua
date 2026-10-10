---@class ServiceProvider:Instance @ServiceProvider 是一个抽象类，用于储存并提供某些单例类，具体取决于其成员使用的继承类。
---@field Close RBXScriptSignal @退出当前场景时触发。
---@field CloseLate RBXScriptSignal @在 ServiceProvider.Close 信号触发后立即触发。
---@field ServiceAdded RBXScriptSignal @当创建一个服务时触发。
---@field ServiceRemoving RBXScriptSignal @当一个服务即将被移除时触发。
local module = {}
---@type fun(param:string):Instance @如果已创建，返回 className 指定的服务，名称无效则报错。
---@param className string
---@return Instance
function module:FindService(className)
end
---@type fun(className:string):Instance @返回具有所请求类名的服务，如果该服务不存在，则创建该服务。
---@alias Service string | " 'Players' " | " 'RunService' " | " 'TweenService' " | " 'PhysicsService' " | " 'AnalyticsService' " | " 'AssetService' " | " 'DataStoreService' " | " 'HttpService' " | " 'LogService' " | " 'TestService' " | " 'BadgeService' " | " 'PointsService' " | " 'TeleportService' " | " 'ContextActionService' " | " 'GuiService' " | " 'HapticService' " | " 'UserInputService' " | " 'VRService' " | " 'JointsService' " | " 'LocalizationService' " | " 'GamePassService' " | " 'MarketplaceService' " | " 'PathfindingService' " | " 'ChangeHistoryService' " | " 'PluginGuiService' " | " 'GroupService' " | " 'SoundService' " | " 'CollectionService' " | " 'InsertService' " | " 'TextService' " | " 'Chat' "
---@param className Service
---@return Instance
function module:GetService(className)
end