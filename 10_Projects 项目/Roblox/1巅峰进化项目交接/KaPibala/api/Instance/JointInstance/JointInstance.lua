---@class JointInstance:Instance @JointInstance是关节的基类，例如连接器，焊缝和按扣。
---@field Active boolean @确定关节当前是否在世界上活动
---@field C0 CFrame @确定偏移点如何附加到JointInstance.Part0
---@field C1 CFrame @从JointInstance.C0属性中减去以为JointInstance.Part1创建一个偏移点
---@field Enabled boolean @设置关节是否处于活动状态
---@field Part0 BasePart @关节连接的第一个BasePart。
---@field Part1 BasePart @关节连接的第二个BasePart。
local module = {}