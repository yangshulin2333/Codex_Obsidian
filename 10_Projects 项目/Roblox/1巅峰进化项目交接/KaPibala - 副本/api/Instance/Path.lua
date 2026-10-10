---@class PathWayPoint
---@field Action number
---@field Position Vector3
local module = {}

---@class Path:Instance @Path 存储由 PathfindingService:CreatePath() 创建的路径结果。
---@field Status PathStatus @是否成功生成 Path。
---@field Blocked RBXScriptSignal @路径是否被阻挡
local module = {}
---@type fun():PathWayPoint[] @返回包含路径所有点的数组。
---@return PathWayPoint[]
function module:GetWaypoints()
end
---@type fun(param:Vector3,param:Vector3)
---@param StartPoint Vector3
---@param EndPoint Vector3
function module:ComputeAsync()
end
return module