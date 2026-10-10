---@class BadgeService:Instance @BadgeService 类提供关于徽章的信息。Badge（徽章）在整个平台上使用，用来表彰玩家的成就和活动。徽章是通过网站创建和编辑的，可以用来表彰玩家在游戏中的活动和成就，如游戏时间、高分和连续杀敌，或是更有创意的，比如参加限时假期活动的徽章。一旦授予玩家徽章，它就会被添加到他们的库存中，并显示在他们的个人资料页面上。
local module = {}
---函数
---@type fun(param:int64,param:int64):boolean @向某玩家 ID 授予指定 ID 的徽章。
---@param userId int64 @要授予徽章的用户的 Player.UserId
---@param badgeId int64 @要授予的徽章的 ID
---@return boolean @如果徽章授予成功，返回 true。
function module:AwardBadge()
end
---@type fun(param:int64):Dictionary @此函数获取关于指定 ID 徽章的信息。
---@param badgeId int64 @要获取信息的徽章的 badgeId。
---@return Dictionary @一个包含指定徽章信息的字典。
function module:GetBadgeInfoAsync()
end
---@type fun(param:int64,param:int64):boolean @UserHasBadgeAsync 根据 Player 的 UserId 和徽章的 id，检查玩家是否拥有徽章。
---@param userId int64 @将接受指定徽章所有权检查的玩家的 UserId。
---@param badgeId int64 @将接受所有权检查的徽章的 badgeId。
---@return boolean @用于指示指定用户是否具有指定徽章的布尔值。
function module:UserHasBadgeAsync()
end
return module
