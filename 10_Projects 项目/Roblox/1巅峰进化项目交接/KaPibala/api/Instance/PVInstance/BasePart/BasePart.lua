---@class BasePart:PVInstance @BasePart 是在 Workspace 内渲染并物理模拟的世界中对象的抽象基类。BasePart 有多种实现，最常见的是六面矩形棱柱体 Part。其他实现包括 Workspace 中的 SpawnLocation、WedgePart 和单例 Terrain 对象。大多数情况下，当文档引用一个部件时，大多数 BasePart 实现都将发挥作用，而不仅仅是 Part
---@field Anchored boolean @确定零件是否由物理学固定
---@field BackParamA number @确定零件背面（+ Z方向）上的SurfaceType的第一个参数
---@field BackParamB number @确定零件背面（+ Z方向）上的SurfaceType的第二个参数
---@field BackSurface SurfaceType @确定零件背面的表面类型（+ Z方向）
---@field BackSurfaceInput InputType @确定零件背面（+ Z方向）的输入类型
---@field BottomParamA number @确定零件底面（-Y方向）上的SurfaceType的第一个参数
---@field BottomParamB number @确定零件底面（-Y方向）上的SurfaceType的第二个参数
---@field BottomSurface SurfaceType @确定零件底面的表面类型（-Y方向）
---@field BottomSurfaceInput InputType @确定零件底面（-Y方向）的输入类型
---@field BrickColor BrickColor @确定零件的颜色。
---@field CFrame CFrame @确定零件在世界上的位置和旋转
---@field CanCollide boolean @确定零件是否可能与其他零件碰撞。
---@field CastShadow boolean @确定零件是否投射阴影
---@field CenterOfMass Vector3 @描述零件质心所在的世界位置。
---@field CollisionGroupId number @描述零件碰撞组的自动设置的ID号
---@field Color Color3 @确定零件的颜色
---@field CustomPhysicalProperties PhysicalProperties @确定零件的几种物理性质
---@field FrontParamA number @确定零件正面（-Z方向）上SurfaceType的第一个参数
---@field FrontParamB number @确定零件正面（-Z方向）上的SurfaceType的第二个参数
---@field FrontSurface SurfaceType @确定零件正面的表面类型（-Z方向）
---@field FrontSurfaceInput InputType @确定零件正面的输入类型（-Z方向）
---@field LeftParamA number @确定零件左表面（-Z方向）上的SurfaceType的第一个参数
---@field LeftParamB number @确定零件左表面（-Z方向）上的SurfaceType的第二个参数
---@field LeftSurface SurfaceType @确定零件左表面的表面类型（-X方向）
---@field LeftSurfaceInput InputType @确定零件左面的输入类型（+ X方向）
---@field LocalTransparencyModifier number @确定BasePart.Transparency的乘数，该乘数仅对本地客户端可见
---@field Locked boolean @确定在Studio中是否可以选择零件
---@field Massless boolean @确定零件是否有助于其刚体的总质量或惯性
---@field Material Material @确定零件的纹理和默认物理特性
---@field Orientation Vector3 描述零件在世界上的位置
---@field Position Vector3 @描述零件在世界上的位置
---@field ReceiveAge number @自上次记录物理更新以来的时间
---@field Reflectance number @确定零件在多大程度上反映了天空盒。
---@field ResizeIncrement number @描述Resize方法允许的最小尺寸变化
---@field ResizeableFaces Faces @描述可以调整零件尺寸的面
---@field RightParamA number @确定零件右侧（-X方向）上的SurfaceType的第一个参数
---@field RightParamB number @确定零件右侧（-X方向）上的SurfaceType的第二个参数
---@field RightSurface SurfaceType @确定零件右面（+ X方向）的表面类型
---@field RightSurfaceInput InputType @确定零件右面的输入类型（-X方向）
---@field RootPriority number @确定装配体根部的主要规则
---@field RotVelocity Vector3 @确定零件随时间变化的方向
---@field Rotation Vector3 @三个轴的零件旋转度数
---@field Size Vector3 @确定零件的尺寸（长度，宽度，高度）
---@field TopParamA number @确定零件顶面上的SurfaceType的第一个参数（+ Y方向）
---@field TopParamB number @确定零件顶面上（+ Y方向）的SurfaceType的第二个参数
---@field TopSurface SurfaceType @确定零件顶面（+ Y方向）的表面类型
---@field TopSurfaceInput InputType @确定零件顶面（+ Y方向）的输入类型
---@field Transparency number @确定可以看到多少零件（零件不透明度的倒数）
---@field Velocity Vector3 @确定零件随时间的位置变化
---@field TouchEnded RBXScriptSignal @当零件停止接触另一零件时触发
---@field Touched RBXScriptSignal @当零件与另一零件接触时触发
---
local module = {}
---@type fun() @断开与任何相邻零件的表面连接，包括焊接和其他JointInstance
function module:BreakJoints()
end
---@type fun(part:Instance):boolean @返回零件是否可以相互碰撞。
---@param part Instance @检查指定部件是否可碰撞
---@return boolean @部件之间可否碰撞
function module:CanCollideWith(part)
end
---@type fun():Tuple @检查是否可以设置零件的网络所有权
---@return Tuple @检查是否可以设置零件的网络所有权
function module:CanSetNetworkOwnership()
end
---@type fun(recursive:boolean):table<number,BasePart> @返回通过任何一种刚性接头连接到对象的零件表。
---@param recursive boolean @以任何 joint 连接至对象的部件表
---@return table<number,BasePart> @对象列表
function module:GetConnectedParts(recursive)
end
---@type fun():table @返回与该零件连接的所有关节或约束
---@return table @连接列表
function module:GetJoints()
end
---@type fun():number @获得质量
---@return number @质量
function module:GetMass()
end
---@type fun():Instance @返回当前玩家，该玩家是该部分的网络所有者，如果是服务器，则返回nil
---@return Instance @为此部件的网络所有者的当前玩家，如果所有者为服务器则为 nil
function module:GetNetWorkOwner()
end
---@type fun():boolean @如果游戏引擎自动决定该部分的网络所有者，则返回true
---@return boolean @游戏引擎是否自动确定该部件的网络所有者
function module:GetNetworkOwnershipAuto()
end
---@type fun():Instance @返回零件装配体的基础零件
---@return Instance @集合（一系列互相连接的部件）的根部件
function module:GetRootPart()
end
---@type fun():table<number,BasePart> @返回与该零件相交的所有CanCollide真实零件的表。
---@return table<number,BasePart> @所有与该部件相交并可与其碰撞的部件表
function module:GetTouchingParts()
end
---@type fun():boolean @如果对象连接到将其固定在其上的零件（例如，BasePart.Anchored零件），则返回true，否则返回false
---@return boolean @对象是否已连接至能使其维持静止状态的部件
function module:IsGrounded()
end
---@type fun() @在对象的任何具有曲面ID的侧面上创建一个关节，该ID可以构成关节
function module:MakeJoints()
end
---@type fun(param:NormalID,param:number):boolean @就像使用Studio调整大小工具一样更改对象的大小
---@param normalId NormalId @调整尺寸的一面
---@param deltaAmount number @指定边的增长/收缩量
---@return boolean @是否调整零件尺寸
function module:Resize()
end
---@type fun(player:Player) @将给定的播放器设置为此和所有连接的部件的网络所有者
---@param player Player @将被授予部件网络所有权的玩家
function module:SetNetworkOwner(player)
end
---@type fun(player:Player) @让游戏引擎动态决定由谁来处理部件的物理过程（客户端或服务器之一）
---@param player Player @将被授予部件网络所有权的玩家
function module:SetNetworkOwnershipAuto(player)
end
---@type fun(parts:table<number,Part>,collisionfidelity:CollisionFidelity,renderFidelity:RenderFidelity):Instance @对调用的BasePart和作为第一个参数传入的零件列表执行Union操作
---@param parts table<number,Part> @与调用部件联合的部件列表
---@param collisionfidelity CollisionFidelity @可选的枚举参数，指定此实体模型的碰撞模型与实体模型的实际几何体的相似程度。默认为 Enum.CollisionFidelity.Default,Default - 基于凸面分解表示的详细几何体 Hull - 结果的凸包 Box - 边界框
---@param renderFidelity RenderFidelity 可选的枚举参数，指定显示实体建模部件的细节水平 Automatic - 根据实体建模部件与镜头的距离动态控制其细节水平（请参阅上表） Precise - 专门设置实体建模部件的细节水平，而不考虑其与镜头的距离（最低、中等或最高）
---@return Instance @生成默认名称为 “Union” 的 UnionOperation
function module:UnionAsync(parts,collisionfidelity,renderFidelity)
end