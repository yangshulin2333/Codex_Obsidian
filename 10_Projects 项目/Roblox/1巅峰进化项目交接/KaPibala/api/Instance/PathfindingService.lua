---@class PathfindingService:Instance @PathfindingService 用于在两点之间寻找路径。这些路径确保角色可以在点之间移动而不会碰到墙壁或其他障碍物。玩家控制角色和非玩家角色都可使用路径。
local module = {}
---@type fun(param:AgentParameters):Path @根据各种行为主体参数创建一个 Path 对象。
---@return Path
function module:CreatePath(agentParameters)
end