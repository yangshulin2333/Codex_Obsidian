---@class NumberRange
---@field Min number @最小值。始终小于或等于最大值。
---@field Max number @最小值。始终小于或等于最大值。
local module = {}
---@type fun(param:number):NumberRange @创建一个新的NumberRange，将最小值和最大值设置为value。
---@param value number
---@return NumberRange
function module.new(value)
end
---@type fun(param:number,param:number):NumberRange @创建一个新的NumberRange，将最小值和最大值设置为value。
---@param minimum number
---@param maximum number
---@return NumberRange
function module.new(minimum,maximum)
end