---@class UDim2
---@field X UDim @x尺寸比例和偏移
---@field Y UDim @y尺寸比例和偏移
---@field Width UDim @x尺寸比例和偏移
---@field Height UDim  @y尺寸比例和偏移
UDim2 = {}
---@type fun(param:UDim2,param:number):UDim2 @返回在此UDim2和提供的目标之间插入的UDim2。 alpha应该是介于0和1之间的数字。
---@param goal UDim2
---@param alpha number
---@return UDim2
function UDim2:Lerp()
end
---@type fun(param:number,param:number,param:number,param:number):UDim2
---@param xScale number
---@param xOffset number
---@param yScale number
---@param yOffset number
---@return UDim2
function UDim2.new()
end
---@type fun(param:UDim,param:UDim):UDim2
---@param x UDim
---@param y UDim 
---@return UDim2
function UDim2.new()
end

function UDim2.fromScale(x,y)
end

function UDim2.fromOffset(x,y)
end