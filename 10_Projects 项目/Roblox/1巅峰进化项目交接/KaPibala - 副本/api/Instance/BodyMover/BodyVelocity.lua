---@class BodyVelocity:BodyMover @BodyVelocity 对象对 BasePart 施加力 force，使其保持一个恒定的速度，请不要与 BasePart.Velocity 属性混淆。 BodyVelocity.Velocity 控制全局速度，是 BodyAngularVelocity 的平移对应物。如果您需要移动一个部件到目标位置，请使用 BodyPosition，如果需要进一步控制对象的受力，则可以考虑使用 BodyForce 或 BodyThrust,该对象施加的力的强度由几个因素控制：当前速度和目标速度的差异，可被 P（功率）放大或缩小；力的上限则为 MaxForce。将 BodyVelocity.Velocity 设置为 (0, 0, 0) 可以模拟不那么严格的锚固 行为。
---@field MaxForce Vector3 @确定可施加到每个轴上的力的限制
---@field P number @决定在达到目标速度过程中应用力的强度
---@field Velocity Vector3 @确定目标速度
local module = {}
---@type fun():Vector3 @返回对象中的最后一个力。
---@return Vector3
function module:GetLastForce()
end
---@type fun():Vector3 @返回对象中的最后一个力。
---@return Vector3
function module:lastForce()
end