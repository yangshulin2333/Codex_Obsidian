---@class AlignPosition:Constraint @AlignPosition 用来向特定位置施加力的约束。与其他约束类似，其拥有两个 Attachment（附件）。在此类情况下，附件会被约束在同一位置，但方向并不一定相同。默认配置下，约束只向 Attachment0 施加力，但可以设置为同时对两个附件施加力。注意 如果本约束将一个部件（A）连接到部件（B），且部件 B 被锚固或连接至另一锚固部件（Z），则部件 A 与玩家交互时将不会进行局部模拟。
---@field ApplyAtCenterOfMass boolean @当设置为 true 时，在 Attachment0 的父项 Part 的重心施加力，当设置为 false 时则将力施加在 Attachment0 的重心。
---@field MaxForce number @约束为了达成目的所能施加的最大力。只有当 RigidityEnabled 为 false 时才被使用。
---@field MaxVelocity number @Attachment 在聚合时的最大移动速度。只有当 RigidityEnabled 为 false 时才被使用 。
---@field ReactionForceEnabled boolean @在为 true 时，约束将会对两个 Attachment 附件同时施加力以达成目标。
---@field Responsiveness number @用于控制约束实现其目标的速度。值越大，附件进行聚合的速度越快。取值范围在 5 到 200 之间。
---@field RigidityEnabled boolean @当设置为 true 时，解算器会尽可能快地做出反应以聚合附件。当设置为 false 时，扭矩取决于 AlignPosition.MaxForce、AlignPosition.MaxVelocity、以及 AlignPosition.Responsiveness 。
local module = {}