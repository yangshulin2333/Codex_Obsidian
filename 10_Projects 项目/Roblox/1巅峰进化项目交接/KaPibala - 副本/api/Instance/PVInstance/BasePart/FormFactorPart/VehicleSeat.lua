---@class VehicleSeat:FormFactorPart @当玩家触摸座椅时，VehicleSeat对象会将玩家焊接到座椅上。然后，它将运动键转发到任何已连接的马达关节，从而可以控制车辆
---@field AreHingesDetected number @显示VehicleSeat检测到多少个铰链。对于调试车辆设计很有用。
---@field Disabledd boolean @切换VehicleSeat是否处于活动状态。
---@field HeadsUpDisplay boolean @如果为true，则会在屏幕上显示一个速度栏，告诉您车辆以什么速度行驶。
---@field MaxSpeed number @可以达到的最大速度。
---@field Occupant Humanoid @坐在座位上的人形生物
---@field Steer number @与键A和D绑定的移动方向。必须为1（右），0（直）或-1（左）之一。除非不断设置，否则将刷新为0。
---@field SteerFloat number @功能与VehicleSeat.Steer相同，但该值不是整数。
---@field Throttle number @与键W和S关联的移动方向。必须为整数1（正向）0（空）或-1（反向）。除非不断设置，否则将刷新为0。
---@field ThrottleFloat number @功能与VehicleSeat.Throttle相同，但该值不是整数。
---@field Torque number @车辆能够达到VehicleSeat.MaxSpeed的速度。数字越大，达到最高速度的速度就越快。
---@field TurnSpeed number @车辆转弯的速度。较高的数字可能会引起问题，不一定会更好。
local module = {}
---@type fun(humanoid:Humanoid)
---@param humanoid Humanoid
function module:Sit(humanoid)
end