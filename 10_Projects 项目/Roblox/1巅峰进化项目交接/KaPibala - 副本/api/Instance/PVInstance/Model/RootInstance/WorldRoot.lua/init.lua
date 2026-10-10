---@class WorldRoot:RootInstance
local module = {}
---@type fun(origin:Vector3,direction:Vector3,raycastparams:RaycastParams):RaycastResult @使用原点，方向和可选的RaycastParams投射射线。 如果找到了合格的BasePart或Terrain单元，则返回包含操作结果的RaycastResult。 如果未提供RaycastParams对象，则使用默认值（考虑所有部分且不忽略地形水）。
---@param origin Vector3
---@param direction Vector3
---@param raycastparams RaycastParams
---@return RaycastResult
function module:Raycast(origin,direction,raycastparams)
end
function module:FindPartOnRayWithIgnoreList()
end