---@class Motor:JointInstance @一个用于在两个部件之间制作一个可移动JointInstance的对象
---@field CurrentAngle number @显示电机当前的旋转角度，单位是弧度。
---@field DesiredAngle number @电机转动的理想角度，单位为弧度。
---@field MaxVelocity number 电机为了达到Motor.DesiredAngle所能使用的最大速度，单位是弧度/物理帧（一秒钟 60 物理帧）
local module = {}
---@type fun(value:number)
---@param value number
function module:SetDesiredAngle(value)
end