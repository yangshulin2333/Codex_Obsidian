---@class AnimationTrack:Instance
---@field Animation Animation @用于创建此 AnimationTrack 的 Animation 对象。
---@field IsPlaying boolean @播放 AnimationTrack 时返回 true 的只读属性。
---@field Length number @返回 AnimationTrack 长度（以秒为单位）的只读属性。直到动画全部加载前此属性都将返回 0，因此可能无法立即使用。
---@field Looped boolean @此属性设置动画在完成后是否重复。如果在播放时更改，则结果将在动画完成后生效。
---@field Priority AnimationPriority 此属性设置 AnimationTrack 的优先级。根据设置的等级，一次播放多个动画时将查看此属性以确定应优先播放哪个 Keyframe 的 Pose。
---@field Speed number @AnimationTrack 的 Speed 是一个只读属性，它提供 AnimationTrack 的当前播放速度。默认值为 1。当速度等于 1 时，动画完成所需的时间等于 AnimationTrack.Length（以秒为单位）。
---@field TimePosition number @返回 AnimationTrack 当前播放源动画的时间位置，单位为秒。调整该值可跳至指定的动画时间位置。
---@field WeightTarget number @WeightCurrent 是一个只读属性，表示 AnimationTrack 的当前权重。默认值为 1。当调用 AnimationTrack:Play、AnimationTrack:Stop 或 AnimationTrack:AdjustWeight 时被设置。
---@field  DidLoop RBXScriptSignal @当 AnimationTrack 前一动画循环结束后，在循环之后的下一次更新中，此事件会触发。
---@field Stopped RBXScriptSignal @当 AnimationTrack 完成播放时触发。
local module = {}
---@type fun(param:number) @此函数用于更改动画的 AnimationTrack.Speed。速度的正值向前播放动画，负值向后播放动画，0 会暂停动画。
---@param speed number
function module:AdjustSpeed(speed)
end
---@type fun(param:string):RBXScriptSignal @此函数将会返回事件：该事件将会在到达动画中指定 KeyframeMarker 时触发
---@param name string
---@return RBXScriptSignal
function module:GetMarkerReachedSignal(name)
end
---@type fun(param:string):number @返回 AnimationTrack 中指定名称的第一个 Keyframe（关键帧）的时间位置。
---@param keyFrameName string
---@return number
function module:GetTimeOfKeyframe(keyFrameName)
end
---@type fun(param:number,param:number,param:number) @播放 AnimationTrack。调用的 AnimationTrack 会按照指定的 fadeTime、权重和速度播放。
---@param fadeTime number
---@param weight number
---@param speed number
function module:Play(fadeTime,weight,speed)
end
---@type fun(param:number) @停止 AnimationTrack。对其进行调用后， AnimationTrack 的播放将会停止，且动画的权重将在 fadeTime 参数（非必须）指定的一段时间内移向零。
---@param fadeTime number
function module:Stop(fadeTime)
end
return module