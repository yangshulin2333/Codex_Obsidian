---@class Model:PVInstance @Model （模型）为容器对象，能够包含对象并将其进行组合。其极为适合用于存放成组的多个 BasePart ，同时也包含多个扩张实用性的函数。
---@field PrimaryPart BeatPart @指向 Model 的主要部件。当使用 Model:MoveTo 与 Model:SetPrimaryPartCFrame 设置模型位置时，将会使用该 BasePart 部件作为依据
local module = {}
---@type fun() @断开基本零件之间的连接，包括与任何相邻零件，WeldConstraints以及所有Welds和其他JointInstance的曲面连接
function module:BreakJoints()
end
---@type fun():CFrame,Vector3 @返回包含模型所有部分的卷的描述
---@return CFrame,Vector3 @CFrame 代表体积的朝向，后面紧跟的 Vector3 代表的是体积的大小
function module:GetBoundingBox()
end
---@type fun():Vector3 @返回包含 Model 中所有 BasePart 的最小边界框的大小，与 Model.PrimaryPart 对齐（如已设置）
---@return Vector3 @Model 的 Vector3 范围大小
function module:GetExtentsSize()
end
---@type fun():CFrame @返回模型的Model.PrimaryPart的CFrame。如果模型不存在主要部件，则此函数将引发错误
---@return CFrame
function module:GetPrimaryPartCFrame()
end
---@type fun() @遍历模型中的所有BasePart。如果任何零件的侧面具有可以连接的SurfaceType，则它将创建与任何相邻零件的接合
function module:MakeJoints()
end
---@type fun(poistion:Vector3) @将Model.PrimaryPart移动到给定位置。如果未指定主要部分，则将使用模型的根部分
function module:MoveTo(poistion)
end
---@type fun(cframe:CFrame) @设置模型的Model.PrimaryPart的BasePart.CFrame。 模型中的所有其他零件也将被移动，并保持其方向和相对于Model.PrimaryPart的偏移。 如果模型不存在Model.PrimaryPart，则此函数将引发错误
---@param cframe CFrame @需要设置的 CFrame
function module:SetPrimaryPartCFrame(cframe)
end
---@type fun(vector3:Vector3) @将模型移动给定的Vector3偏移量，从而保持模型的方向。如果在新位置已经存在另一个BasePart或Terrain，则模型将与所述对象重叠
---@param vector3 Vector3 @要将 Model 平移的 Vector3 量
function module:TranslateBy(vector3)
end
---@type fun(cframe:CFrame) @设置模型锚点CFrame。primarypart非必需
function module:PivotTo(cframe)
end
---@type fun() @获取模型锚点CFrame。primarypart非必需
function module:GetPivot()
end
---@type fun(scaleFactor:number) @根据当前锚点位置进行缩放,包括粒子拖尾骨骼等,注意:1.需要开启测试版对应功能,2.PrismaticConstraint / SlidingBallConstraint限制不缩放,
---@param scaleFactor number @必填,填1是重置为原始尺寸
function module:ScaleTo(scaleFactor)
end
---@type fun():number @获得当前模型的缩放系数(默认为1)
function module:GetScale()
end