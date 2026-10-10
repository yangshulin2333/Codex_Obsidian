---@class BodyGyro:BodyMover @BodyGyro 对象可以对 BasePart 施加扭矩（旋转力），使其保持恒定的角位移或方向。这使我们可以创建指向特定方向的部件，就好像有真正的陀螺仪在影响它一样。从本质上讲，它就像是 BodyPosition 的旋转对应物。
---@field CFrame CFrame @确定目标方向（忽略平移分量）
---@field D number @决定在达到目标 CFrame 过程中使用的阻尼量
---@field MaxTorque Vector3 @确定可以施加到每个轴的最大扭矩的限制
---@field P number @确定在达到目标方向过程中应用扭矩的强度
local module = {}