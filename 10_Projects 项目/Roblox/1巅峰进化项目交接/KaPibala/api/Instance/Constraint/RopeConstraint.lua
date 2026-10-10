---@class RopeConstraint:Constraint @RopeConstraint 限制两个 Attachment 之间分开的距离不超过 RopeConstraint.Length 指定的长度。附件之间可以短于此长度并且自由旋转。
---@field CurrentDistance number @RopeConstraint 的两个 Attachment 之间的当前距离。
---@field Length number @连接至同一个 RopeConstraint 时两个 Attachment 之间的最大距离。以格为单位。
---@field Restitution number @Restitution（恢复系数）控制由 RopeConstraint 连接的 Attachment 在达到绳子的最大 RopeConstraint.Length 时会多么有弹性。此属性的值限制在 0 和 1 之间。
---@field Thickness number @RopeConstraint 的可视粗细。
local module = {}