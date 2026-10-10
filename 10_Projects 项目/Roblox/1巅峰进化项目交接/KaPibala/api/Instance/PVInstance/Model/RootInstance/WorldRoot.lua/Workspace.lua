---@class Workspace:WorldRoot @Workspace（工作区）服务包含要在 3D 世界中渲染的所有对象。不是工作区子项的对象将不会渲染，也不会与世界进行物理交互。
---@field AllowThirdPartySales boolean @决定由其他用途创建的资源是否可以在游戏中出售。
---@field CurrentCamera Camera @本地玩家使用的 Camera 对象。
---@field DistributedGameTime number @游戏已经运行的时间（以秒为单位）。
---@field FallenPartsDestroyHeight number @确定坠落的 BaseParts（及其父 Models）被破坏时的高度
---@field FilteringEnabled boolean @确定从客户端所做的更改是否复制到服务器。
---@field Gravity number @确定应用于坠落 BasePart 的重力加速度。
---@field StreamingEnabled boolean @是否为该场景启用网络串流
---@field StreamingMinRadius number @部件会以高优先级被串流传送给玩家的最小距离
---@field StreamingPauseMode StreamingPauseMode @激活的是哪一种串流物理暂停模式
---@field StreamingTargetRadius number @部件可被串流传送给玩家的最大距离
---@field TemporaryLegacyPhysicsSolverOverride boolean
---@field Terrain Terrain @作为 Workspace 子代 Terrain 对象的引用。
---@field TouchesUseCollisionGroups boolean
workspace = {}
---@type fun(objects:BasePart[]) @遍历所有给定的 BasePart，断开与这些部件连接的所有关节。
---@param objects BasePart[] @
function workspace:BreakJoints(objects)
end
---@type fun(ray:Ray,ignore_list:BasePart[]):BasePart,Vector3
---@param ray Ray
---@param ignore_list BasePart[]
---@return BasePart,Vector3
function workspace:FindPartOnRayWithIgnoreList(ray,ignore_list)
end
---@type fun(origin:Vector3,direction:Vector3,raycastparams:RaycastParams):RaycastResult @使用原点，方向和可选的RaycastParams投射射线。 如果找到了合格的BasePart或Terrain单元，则返回包含操作结果的RaycastResult。 如果未提供RaycastParams对象，则使用默认值（考虑所有部分且不忽略地形水）。
---@param origin Vector3
---@param direction Vector3
---@param raycastparams RaycastParams
---@return RaycastResult
function workspace:Raycast(origin,direction,raycastparams)
end
---@type fun(part:Part,overlapParams:table):table @检测与提供的part相交或包含的part，返回一个列表，OverlapParams{MaxParts=false, CollisionGroup=Default, FilterDescendantsInstances={}}
---@param part Part
---@param overlapParams table
---@return Part[]
function workspace:GetPartsInPart(part,overlapParams)
end

---@type fun(pos:Vector3,radius:number,overlapParams:table):table @检测与提供的part相交或包含的part，返回一个列表，OverlapParams{MaxParts=false, CollisionGroup=Default, FilterDescendantsInstances={}}
---@param pos Vector3
---@param radius number
---@param overlapParams table
---@return Part[]
function workspace:GetPartBoundsInRadius(pos,radius,overlapParams)
end

function workspace:GetServerTimeNow()
end