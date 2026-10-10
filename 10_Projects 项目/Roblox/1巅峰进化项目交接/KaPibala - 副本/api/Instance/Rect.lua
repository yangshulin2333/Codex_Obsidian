---@class Rect
---@field Width number @Rect的宽度（以像素为单位）
---@field Height number @Rect的高度（以像素为单位）。
---@field Min Vector2 @左上角
---@field Max Vector2 @右下角。
local module = {}
---@type fun(min:Vector2,max:Vector2):Rect @构造一个新的Rect，最小值为左上角，最大值为右下角。
---@param min Vector2
---@param max Vector2
---@return Rect
function module.new(min,max)
end
---@type fun(minX:number,minY:number,maxX:number,maxY:number):Rect @使用minX和minY作为左上角的坐标，以及maxX和maxY作为右下角的坐标，构造一个新的Rect
---@param minX number
---@param minY number
---@param maxX number
---@param maxY number
---@return Rect
function module.new(minX,minY,maxX,maxY)
end