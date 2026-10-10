---@class BrickColor @BrickColor是提供预定义颜色列表的数据类型。要查看可用砖块颜色的完整列表，请参见《砖块颜色代码》参考。
---@field BrickColor number @标识BrickColor的唯一编号
---@field r number @红色分量（介于0和1之间）
---@field g number @绿色部分（介于0和1之间）
---@field b number @蓝色分量（介于0和1之间）
---@field Name string @与BrickColor关联的名称
---@field Color Color3 @与BrickColor关联的Color3
BrickColor = {}
---@type fun(param:number):BrickColor @根据其数字索引构造一个BrickColor。
---@param val number
---@return BrickColor
function BrickColor.new(val)
end
---@type fun(param:number,param:number,param:number):BrickColor @构造可以与指定的RGB组件匹配的最接近的BrickColor。
---@param r number
---@param g number
---@param b number
---@return BrickColor
function BrickColor.new(r,g,b)
end
---@type fun(val:string):BrickColor @从其名称构造一个BrickColor。
---@param val string
---@return BrickColor
function BrickColor.new(val)
end
---@type fun(param:Color3):BrickColor @构造可以与指定的Color3匹配的最近的BrickColor。
---@param color Color3
---@return BrickColor
function BrickColor.new(color)
end
---@type fun(param:number):BrickColor @从其调色板索引构造一个BrickColor。
---@param paletteValue number
---@return BrickColor
function BrickColor.palette(paletteValue)
end
---@type fun():BrickColor @返回随机的BrickColor。
---@return BrickColor
function BrickColor.random()
end
---@type fun():BrickColor @返回白色的BrickColor
---@return BrickColor
function BrickColor.White()
end
---@type fun():BrickColor @返回BrickColor中石灰色
---@return BrickColor
function BrickColor.Gray()
end
---@type fun():BrickColor @返回BrickColor黑色
---@return BrickColor
function BrickColor.Black()
end
---@type fun():BrickColor @返回BrickColor亮红色
---@return BrickColor
function BrickColor.Red()
end
---@type fun():BrickColor @返回BrickColor亮黄色
---@return BrickColor
function BrickColor.Yellow()
end
---@type fun():BrickColor @返回BrickColor深绿色
---@return BrickColor
function BrickColor.Green()
end
---@type fun():BrickColor @返回BrickColor亮蓝色
---@return BrickColor
function BrickColor.Blue()
end