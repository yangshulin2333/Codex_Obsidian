---@class AgentParameters
---@field AgentRadius number @默认2，人形对象范围，用于确定与障碍物的最小间距
---@field AgentHeight number @默认5，人形对象高度。小于此值的空间将被标记为不可穿越，例如椅子下面的空间
---@field AgentCanJump boolean @默认true，设置是否允许网格外的跳跃链接
---@class PathfindingService:Instance @PathfindingService 用于在两点之间寻找路径。这些路径确保角色可以在点之间移动而不会碰到墙壁或其他障碍物。玩家控制角色和非玩家角色都可使用路径。
local module = {}