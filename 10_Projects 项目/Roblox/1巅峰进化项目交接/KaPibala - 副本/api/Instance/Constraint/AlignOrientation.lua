---@class AlignOrientation:Constraint @AlignOrientation 是一个通过应用扭矩来使其附件对齐的约束。和其他类型的约束一样，它有两个Attachment（附件）。在这种情况下，两个附件被约束于同一方向，但位置并不一定相同。注意 由 AlignOrientation 创建的任一扭矩都将被应用到附件的父项（或与父项刚性连接的部件）的重心。另外还需注意，如果此约束将一个部件（例如 A）附加到已锚固或已连接到锚固部件（例如 Z）的另一个部件（例如 B）上，那么在与玩家互动时，部件 A 将不会进行本地模拟。
---@field MaxAngularVelocity number @约束为完成目标所能达到的最大角速度。
---@field MaxTorque number @约束为完成目标所能使用的最大扭矩。
---@field PrimaryAxisOnly boolean @如果设置为 true ，那么 AlignOrientation 将只会在其附件 Attachment0 与 Attachment1 不对齐时应用扭矩。这就意味着，围绕 Attachment0 主轴的任何旋转都不会产生扭矩。
---@field ReactionTorqueEnabled boolean @在为 true 时，约束将会对两个 Attachment 附件同时应用扭矩以达成目标。
---@field Responsiveness number @用于控制约束实现其目标的速度。值越大，附件进行对齐的速度也就会越快。取值范围在 5 到 200 之间。
---@field RigidityEnabled boolean @当设置为 true 时，解算器会尽可能快地做出反应以对齐附件。当设置为 false 时，扭矩取决于 AlignOrientation.MaxTorque， AlignOrientation.MaxAngularVelocity，以及 AlignOrientation.Responsiveness 三者。
local module = {}