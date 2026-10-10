---@class BodyPosition:BodyMover
---@field D number @决定在达到目标 BodyPostion/Position|Position 过程中使用的阻尼量
---@field MaxForce Vector3 @决定可以应用至各轴的力的大小限制
---@field P number @决定在达到目标位置过程中应用力的强度
---@field Position Vector3 @确定将要施加力的目标位置
---@field ReachedTarget RBXScriptSignal @当 BodyPosition 的父项达到所需的 BodyPosition.Position（1 格以内误差）时触发。此事件一旦触发，在 BodyPosition.Position 更新之前不会再次触发。
local module = {}
---@type fun():Vector3 @返回对象中的最后一个力。
function module:GetLastForce()
end