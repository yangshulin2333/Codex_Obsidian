---@class Tween:TweenBase @Tween（渐变）用来对实例的属性进行插值。Tween 对象本身控制插值的播放。Tween 的创建和配置是通过 TweenService:Create 函数来完成的，这是唯一一种创建 tween 的方式。Instance.new 不能用于这一特定对象。
---属性
---@field Instance Instance @Tween 的只读 Instance 属性。其所指向 Instance 的属性正由该 Tween 进行插值。
---@field TweenInfo TweenInfo @只读属性，包括如何使用 TweenInfo 数据类型对 Tween 进行插值的信息。
---@field Completed RBXScriptSignal @Completed(playbackstate)
local c = {}
---@param speed number @播放的速度(计算方式为动画长度/想要的播放时间)
function c:AdjustSpeed(speed)
end
function c:Play(speed)
end