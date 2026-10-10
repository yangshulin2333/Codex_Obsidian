---@class Ray @光线是一条半线，在一个方向上是有限的，而在另一个方向上是无限的。它可以由线的起点3D点和方向矢量（即行进方向）定义。
---@field Unit Ray @具有规范化方向的射线
---@field Origin Vector3 @原点位置
---@field Direction Vector3 @射线的方向向量
local module = {}
---@type fun(param:Vector3,param:Vector3) @创建具有给定原点和方向的新射线
---@param origin Vector3
---@param direction Vector3
function module.new(origin,direction)
end
---@type fun(param:Vector3):Vector3 @返回投影到射线上的Vector3，使其位于射线的视线内。 注意：射线必须是单位射线，此方法才能正常工作！
---@param point Vector3
function module:ClosestPoint(point)
end
---@type fun(param:Vector3):number @返回Ray的原点与Ray：ClosestPoint（point）之间的距离。
---@param point Vector3
function module:Distance(point)
end