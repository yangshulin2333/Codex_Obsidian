---@class Color3
---@field r number
---@field g number
---@field b number 
Color3 = {}
---@type fun(param:number,param:number,param:number):Color3 @构造函数,返回具有给定的红色，绿色和蓝色值的Color3。 数字范围为0到1。可空
---@param r number
---@param g number
---@param b number
---@return Color3
function Color3.new()
end
---@type fun(param:number,param:number,param:number):Color3 @用给定的红色，绿色和蓝色创建一个Color3。 数字范围为0到255。
---@param r number
---@param g number
---@param b number
---@return Color3
function Color3.fromRGB()
end
---@type fun(param:number,param:number,param:number) @创建具有给定色相，饱和度和值的Color3。数字范围为0到1
---@param r number
---@param g number
---@param b number
---@return Color3
function Color3.fromHSV()
end
---@type fun(param:Color3,number:number):Color3 @返回在两个Color3对象之间插入的Color3。 Alpha是从0到1的数字。
---@param color Color3
---@param alpha number
---@return Color3
function Color3:lerp()
end
---@type fun(param:Color3):number,number,number @返回Color3的色相，饱和度和值
function Color3:toHSV()
end


function Color3.fromHex (hex)
end