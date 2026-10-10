---@class Teams:Instance @Teams 服务用来存储游戏的 Team 对象，这些 Team 对象必须被设置为 Teams 服务的子项。
local module = {}
---@type fun():Team[] @返回内含游戏 Team 对象的表格。返回的 Team 对象仅限 Teams 服务的子对象。
function module:GetTeams()
end