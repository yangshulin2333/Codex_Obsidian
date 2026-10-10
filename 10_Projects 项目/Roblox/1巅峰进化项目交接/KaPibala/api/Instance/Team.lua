---@class Team:Instance @Team 类代表了 Roblox 场景中的团队或派系。Team 的唯一有效父项为 Teams 服务内。Team 类提供了一系列十分有用的功能，大致可以分成以下两种： 可以直接进行使用的功能 需要开发者编入其游戏的功能
---@field AutoAssignable boolean @此属性用来决定加入游戏的 Player（玩家）是否会被自动放置到 Team（队伍）中。如果有多个队伍的此属性都设为 true，那么在 Player 被添加进来时 Roblox 会尝试对这些队伍进行平衡。
---@field TeamColor BrickColor @此属性设置 Team 的颜色、决定团队成员的 Player.TeamColor 属性，还决定了玩家列表和玩家头顶上方显示的颜色。
---@field PlayerAdded RBXScriptSignal @当一个 Player 分配到 Team 时触发。要分配一个玩家，其 Player.Team 属性需要等于 Team 且 Player.Neutral 应为 false。
---@field PlayerRemoved RBXScriptSignal @当一名 Player 从一个 Team 中被移除时就会启动，移除原因可能是 Player 离开了游戏、Player.Neutral 被设置为 true 或者 Player 加入了另一个队伍。
local module = {}
---@type fun():Player[] @返回分配到 Team 的 Player 列表。要分配一个 Player，其 Player.Team 属性需要等于 Team 且 Player.Neutral 应为 false。
---@return Player[]
function module:GetPlayers()
end