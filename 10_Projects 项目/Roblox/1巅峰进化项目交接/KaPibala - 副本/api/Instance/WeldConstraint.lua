---@class WeldConstraint:Instance @WeldConstraints用于将两个零件连接在一起。 约束条件确保零件彼此之间保持相同的相对位置和方向，这意味着，如果一个零件移动，则另一个零件将移动相同的量。 即使两个零件彼此不接触，也可以通过焊接约束将它们焊接在一起。
---@field Active boolean @指示WeldConstraint当前是否在世界上处于活动状态
---@field Enabled boolean @启用和禁用约束
---@field Part0 BasePart @第一部分受约束连接。
---@field Part1 BasePart @第二部分受约束连接。
local module = {}