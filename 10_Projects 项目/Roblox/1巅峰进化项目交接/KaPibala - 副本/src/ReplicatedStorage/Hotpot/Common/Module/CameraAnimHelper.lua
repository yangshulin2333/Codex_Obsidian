---@class TweenHelper
local module = {}
module.tween = game:GetService("TweenService")
---@type function 播放Tween动画
---@param instance Instance @要播放动画的父物体
---@param info Instance @tween动画的TweenInfo
---@param args table @变化的参数列表
---@param callback function @动画播完后的回调函数
---@return Tween,RBXScriptConnection @返回播放的动画和回调函数
function module:PlayTween(instance, info, args, callback)
    local t = self.tween:Create(instance, info, args)
    t:Play()
    local callBack = t.Completed:Connect(function()
        if callback then
            callback()
        end
    end)
    return t, callBack
end
function module:GetTween(instance, info, args, callback)
    local t = self.tween:Create(instance, info, args)
    local callBack = t.Completed:Connect(function()
        if callback then
            callback()
        end
    end)
    return t, callBack
end
function module:GetValue(alpha, easingStyle, easingDirection)
    return self.tween:GetValue(alpha, easingStyle, easingDirection)
end
return module
