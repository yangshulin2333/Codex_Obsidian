---@class Trail:Instance @Trail（轨迹）对象可以用来在两点之间创造类似轨迹的视觉效果。当此两点在空间中移动时，会在两点定义的平面上绘制纹理。此效果常用来创建将移动视觉化的效果，例如子弹飞行时后面跟随的轨迹、足迹、车轮印及其它各种相似效果。
---@field Attachment0 Attachment @决定 Trail（轨迹）绘制其分段的起始位置。
---@field Attachment1 Attachment @决定 Trail（轨迹）绘制其分段的起始位置。
---@field Color ColorSequence @轨迹分段在轨迹持续时间中所呈现的颜色。
---@field Enabled boolean @切换轨迹是否会进行绘制。
---@field FaceCamera boolean @设为 true 时，轨迹纹理将会始终面对镜头。
---@field Lifetime number @轨迹的持续时间（以秒为单位）。
---@field LightEmission number @设置轨迹的颜色与其后颜色的混合程度。
---@field LightInfluence number @设置 Trail（轨迹）受周边光照的影响程度。该属性可被设为 0 和 1 间的任何值。设为 0 时其受周边光照的影响最小，为 1 时受到影响最大。 与 Trail.LightEmission 属性不同，此属性无法让轨迹发光。其所决定的是轨迹受周边光照的影响。 举例来说，让我们来考虑一下将光照的 Lighting.Brightness 值从 1 调整至 0 时会对轨迹造成怎样的影响。如果轨迹的光照影响属性为 1，则随着光照明亮度的减少，轨迹也会变得更为黯淡。但如果轨迹的光照影响属性为 0，则轨迹的外观完全不受光照明亮度改变的影响，将会保持不变。
---@field MaxLength number @设置轨迹的最大长度。
---@field MinLength number @轨迹分段的最小长度（以格为单位）。
---@field Texture string @显示在轨迹上的纹理。
---@field TextureLength number @当 Trail.TextureMode 为 Wrap（覆盖）或 Static（静止）时设置纹理的长度。如果模式为 Stretch（拉伸）则设置纹理重复的次数。
---@field TextureMode TextureMode @设置 Texture（纹理）进行绘制的方式。
---@field Transparency NumberSequence @设置 Trail（轨迹）分段在轨迹 Trail.Lifetime（持续时间）中的透明度
---@field WidthScale NumberSequence @在其持续时间周期中对 Trail 宽度进行缩放的 NumberSequence。
local module = {}
---@type fun() @清除 Trail（轨迹）的分段。
function module:Clear()
end