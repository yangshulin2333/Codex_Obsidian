---@class TweenInfo
---@field EasingDirection EasingDirection @EasingStyle执行的方向。
---@field Time number @补间需要的时间量（以秒为单位）。
---@field DelayTime number @补间开始前的时间量（以秒为单位）。
---@field RepeatCount number @补间补间一次后重复的补间数。
---@field EasingStyle EasingStyle @补间执行的样式。
---@field Reverses boolean @初始补间完成后，补间是否进行反向补间
TweenInfo = {}
---@type fun(param:number,param:EasingStyle,param:EasingDirection,param:number,param:boolean,param:number) @创建一个新的Tweeninfo。
---@param time number
---@param easingStyle EasingStyle
---@param easingDirection EasingDirection
---@param repeatCount number
---@param reverses boolean
---@param delayTime number
function TweenInfo.new(time,easingStyle,easingDirection,repeatCount,reverses,delayTime)
end