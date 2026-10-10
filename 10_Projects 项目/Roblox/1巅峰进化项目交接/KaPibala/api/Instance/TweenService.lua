local TweenService = game:GetService("TweenService")

---@class TweenService:Instance @Tween（渐变）用来对实例的属性进行插值，可以用来为多种 Roblox 对象创建动画。几乎所有数字类型的属性都可以使用 TweenService 来进行 Tween 。注意，只有特定类型的属性可以与 TweenService 配合使用。
local module={}
---@type fun(instance:Instance,tween_info:TweenInfo,property_table:table):Tween @TweenService 的 Create 函数可以创建一个新的 Tween（渐变）效果。该函数需要三个参数：获取该效果的对象、所使用的 TweenInfo、以及包含了将进行渐变的属性和其目标值的表。
---@param instance  Instance @将要进行渐变插值的 Instance 属性。
---@param tween_info TweenInfo @要使用的 TweenInfo。
---@param property_table table @要进行 tween 操作的一个属性字典及其目标值。
---@return Tween  @所创建的 Tween。
function module:Create (instance,tween_info,property_table)
end
---@type fun(alpha:number,easingStyle:EasingStyle,EasingDirection:EasingDirection):number @根据给定的 EasingStyle 和 EasingDirection 计算一个新的 alpha
---@param alpha  number @在 0 和 1 之间的插入值
---@param easingStyle EasingStyle @要使用的释放风格
---@param easingDirection EasingDirection @要使用的释放方向
---@return number  @	根据给定的释放风格和方向生成的新 alpha 值。
function module:GetValue (alpha,easingStyle,easingDirection)
end