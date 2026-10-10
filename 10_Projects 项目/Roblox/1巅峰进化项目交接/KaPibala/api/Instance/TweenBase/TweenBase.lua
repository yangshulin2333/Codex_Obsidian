---@class TweenBase:Instance @用于内插处理函数的基类。
---属性
---@field PlaybackState PlaybackState @一个用于显示 Tween 的当前播放 PlaybackState 的只读属性。
---事件
---@field Completed RBXScriptSignal @Completed 事件在 Tween 完成时触发。完成意味着渐变自然结束，或被 TweenBase:Cancel 停止。
---方法
local module={}
---@type fun()@Cancel 函数用于停止 Tween 的播放并重置它的变量。如果重新调用 TweenBase:Play，那么 Tween 会继续向目标进行插值，但因为变量被重置，仍会消耗完整的动画时间。
function module:Cancel ( )
end
---@type fun()@Pause 函数会暂停其 Tween 的播放。如果后面重新调用 TweenBase/Resume ，则 Tween 将从暂停的那一刻起恢复播放。
function module:Pause ( )
end
---@type fun() @Play 函数会开始其 Tween 的播放。请注意，如果一个 Tween 已经开始播放了，除非 tween 已经完成或是被停止（TweenBase/Cancel 或 TweenBase/Pause），调用 Play 将没有效果。
function module:Play()
end
