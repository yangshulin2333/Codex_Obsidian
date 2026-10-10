---@class AngularVelocity:Constraint
---@field AngularVelocity Vector3 @一个 Vector3 力，用来为个体到达并保持特定角速度
---@field MaxTorque number @约束可以应用的最大扭矩的量级
---@field ReactionTorqueEnabled boolean @
---@field RelativeTo ActuatorRelativeTo
local module = {}