---@class Vector3 @三维向量
---@field X number @X值
---@field Y number @Y值
---@field Z number @Z值
---@field xAxis Vector3
---@field yAxis Vector3
---@field zAxis Vector3
---@field zero Vector3 @Vector3.new(0,0,0)
---@field one Vector3 @Vector3.new(1,1,1)
---@field Magnitude number @向量的长度
---@field Unit number @向量的规格化副本-与原始方向相同，但大小为1的向量
Vector3 = {}
---@type fun(goal:Vector3,alpha:number):Vector3 @返回由分数alpha /在此Vector3和目标之间线性插值的Vector3
---@param goal Vector3 @目标三维向量
---@param alpha number @目标百分比
---@return Vector3 @差值向量
function Vector3:Lerp(goal,alpha)
end
---@type fun(other:Vector3):Vector3 @返回两个向量的叉积
---@param other Vector3 @目标向量
---@return Vector3  @叉积
function Vector3:Cross(other)
end
---@type fun(other:Vector3,epsilon:number):boolean @如果另一个Vector3落在此Vector3的epsilon半径内，则返回true
---@param other Vector3 @目标向量
---@param epsilon number @0.00001 aka 1e-5
---@return boolean @是否在半径内
function Vector3:FuzzyEq(other,epsilon)
end
---@type fun(other:Vector3):number @返回两个向量的标量点积
---@param other Vector3 @目标向量
---@return number @点积
function Vector3:Dot(other)
end
---@type fun(other:Vector3,axis:Vector3):number @返回两个矢量之间的弧度角度。如果轴是 前提是，它确定角度的符号。
---@param other Vector3
---@param axis Vector3
---@return number
function Vector3:Angle(other,axis)
end
---@type fun(other:Vector3,epsilon:number):boolean @如果其他 Vector3 的 X、Y 和 Z 分量在每个对应 epsilon 单位内，则返回 true。 此矢量3的组成部分。
---@param other Vector3
---@param epsilon number
---@return boolean
function FuzzyEq(other,epsilon)
end