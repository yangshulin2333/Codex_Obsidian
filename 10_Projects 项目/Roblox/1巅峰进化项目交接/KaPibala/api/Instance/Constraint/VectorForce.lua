---@class VectorForce:Constraint @VectorForce 用来给某个部件或者部件的集合施加一个外力，外力强度和方向由一个 Vector3 决定且可与部件上的附件、另一个附件、或世界坐标系统相关。
---@field ApplyAtCenterOfMass boolean @当设置为 true 时，在 Attachment0 的父项 Part 的质量中心施加力，当设置为 false 时则将力施加在 Attachment0 的重心。
---@field Force Vector3 @力的大小和方向。
---@field RelativeTo ActuatorRelativeTo @力所反应的 CFrame。
local module = {}