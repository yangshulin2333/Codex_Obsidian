---@class ParticleEmitter:Instance @ParticleEmitter 使我们可以创建 particle systems 。它是一个特殊的效果对象，向世界中发射可定制的 2D 公告牌粒子。在 Roblox 中，粒子是一种在世界中渲染的 2D 图像，因此它总是面向镜头，就像只有一个 ImageLabel 的 BillboardGui 。
---@field Acceleration Vector3 @加速度,确定所有当前活跃粒子的全局轴加速度，单位为格的平方/秒
---@field Color ColorSequence @决定所有发射的粒子在其各自的持续时间周期内的颜色
---@field Drag number @确定例子在指数式衰减中失去一半速度的速率
---@field EmissionDirection NormalId @决定粒子发射时的朝向
---@field Enabled boolean @决定粒子是否应当被发射出去
---@field Lifetime NumberRange @决定新生成粒子的持续时间随机范围
---@field LightEmission number @决定了粒子的颜色与其后面的颜色相混合的程度
---@field LightInfluence number @决定有粒子受到环境光照的影响的程度
---@field LockedToPart boolean @判断粒子是否会随着它们被发射出的部件来做刚性移动。
---@field Rate number @决定每秒发射的粒子数量
---@field RotSpeed NumberRange @决定发射粒子的角速度范围，单位为度/秒
---@field Rotation NumberRange @决定新生成粒子旋转的范围，单位为度
---@field Size NumberSequence @决定各粒子在其持续时间内在世界中的尺寸大小
---@field Speed NumberSequence @速度，决定一个新粒子发射时的速度随机范围，单位为格/秒
---@field SpreadAngle Vector2 @决定一个粒子可能的随机发射角度，单位为度
---@field Texture string @决定粒子渲染的纹理
---@field Transparency NumberSequence @决定各粒子在其持续时间周期内的透明度
---@field VelocityInheritance number @决定粒子在发射时会继承来自父项速度的多少
---@field ZOffset number @决定粒子的前 - 后渲染位置；用于控制渲染在顶部 / 底部的粒子。
local module = {}
---@type fun() @清除所有已经发射的粒子
function module:Clear()
end
---@type fun(param:number) @发射指定数量的粒子
---@param particleCount number
function module:Emit(particleCount)
end