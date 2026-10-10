---@class AnimationController:Instance @一种当不需要 Humanoid 时，允许动画加载并应用到角色或模型上的对象。创建一个 Animator 并加载动画以更新角色的 Motor6D，从而按照 Animation 对象引用的动画资源中描述的方式做出反应。
local module = {}
---@type fun():AnimationTrack @返回一个包含当前所有在该 AnimationController 上播放的 AnimationTrack 的数组。
---@return AnimationTrack
function module:GetPlayingAnimationTracks()
end
---@type fun(param:Animation) @此函数用于将 Animation 加载到 AnimationController 上，并返回可用于播放的 AnimationTrack 。
---@param animation Animation
---@return AnimationTrack
function module:LoadAnimation(animation)
end