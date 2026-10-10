---@class Vector2
---@field X number
---@field Y number
---@field Magnitude number
---@field Unit Vector2
---@field one Vector2
---@field zero Vector2
Vector2 = {}
---@type fun(param:Vector2,param:number):Vector2 @返回由分数alpha线性插值在此Vector2和v之间的Vector2
---@param v Vector2
---@param alpha number
---@return Vector2
function Vector2:Lerp()
end
---@type fun(param:Vector2):number @返回两个向量的标量点积
---@param v Vector2
---@return number
function Vector2:Dot()
end
---@type fun(param:Vector2):number @返回两个向量的叉积
---@param ohter Vector2
---@return number
function Vector2:Cross()
end