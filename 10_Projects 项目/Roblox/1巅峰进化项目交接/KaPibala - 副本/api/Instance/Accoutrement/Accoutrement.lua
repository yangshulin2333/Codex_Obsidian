---@class Accoutrement:Instance @Accoutrement 对象会将其名为 “Handle” 的子项 Part（部件）对玩家的角色 Head （头部）进行 Weld（接合）。Handle 这一部件的具体位置和旋转角度可以通过 AttachmentPos、Right、Forward 及 Up 属性来进行调整。
---@field AttachmentForward Vector3 @设置 Player 上对象的偏移位置。
---@field AttachmentPoint CFrame @Accoutrement 的确切 CFrame。
---@field AttachmentPos Vector3 @设置 Player 上对象的位置。
---@field AttachmentRight Vector3 @设置 Player 上对象的偏移位置。
---@field AttachmentUp Vector3 @设置 Player 上对象的偏移位置。
local module = {}