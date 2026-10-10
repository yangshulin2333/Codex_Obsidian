---@class BallSocketConstraint:Constraint @BallSocketConstraint 会对其 Attachment 进行约束，使其与之占据同样的位置。在默认情况下它允许两个附件自由地绕着所有轴旋转，但如果 BallSocketConstraint.LimitsEnabled 的值为 true 时，则附件只能在有限的圆锥范围内旋转。
---@field LimitsEnabled boolean @设置 BallSocketConstraint 是否会根据 BallSocketConstraint.UpperAngle 来设置旋转的极限。
---@field MaxFrictionTorque number
---@field Radius number @BallSocketConstraint 的可视化半径。
---@field Restitution number @在 BallSocketConstraint.LimitsEnabled 的值为 true 的前提下，由 BallSocketConstraint 所连接的 Attachment 抵达由 BallSocketConstraint.UpperAngle 指定的最大距离时的弹性程度。限制在 0 和 1 之间。
---@field TwistLimitsEnabled boolean @设置 BallSocketConstraint 是否会根据 BallSocketConstraint.TwistUpperAngle 和 BallSocketConstraint.TwistLowerAngle 设置扭转限制。
---@field TwistLowerAngle number @设置 BallSocketConstraint 的扭转下限值，前提是 BallSocketConstraint.TwistLimitsEnabled 的值为 true。
---@field TwistUpperAngle number @设置 BallSocketConstraint 的扭转上限值，前提是 BallSocketConstraint.TwistLimitsEnabled 的值为 true。
---@field UpperAngle number @设置 BallSocketConstraint 的旋转上限，前提是 BallSocketConstraint.LimitsEnabled 的值为 true。
local module = {}