--服务器使用
local Hotpot = _G.CommonHotpot
---@type BadgeService
local badgeService = game:GetService("BadgeService")
---@class BadgeHelper
local module = {}
---@param player Player
---@param badgeId number
---@return boolean @根据传入的player判定玩家是否有该id的徽章
function module:CheckIfOwnBadge(player, badgeId)
    if not player then
        return false
    end
    local su, hasBadge =
        pcall(
        function()
            return badgeService:UserHasBadgeAsync(player.UserId, badgeId)
        end
    )
    --返回是否拥有徽章
    return hasBadge
end
---@param badgeId number
---@return boolean,string  @判定传入的id是否可用,返回第二个是image
function module:CheckBadgeIsEnable(badgeId)
    local su, badgeInfo =
        pcall(
        function()
            return badgeService:GetBadgeInfoAsync(badgeId)
        end
    )
    if su then
        return badgeInfo.IsEnabled, badgeInfo.IconImageId
    else
        warn("获取徽章信息时出错！")
        return false
    end
end
---@param player Player
---@param badgeId number
---@return boolean @此函数为奖励玩家徽章函数,true为成功
function module:AwardBadge(player, badgeId)
    if not player then
        warn("player miss")
    end
    --徽章可以使用且玩家未拥有
    if self:CheckBadgeIsEnable(badgeId) and not self:CheckIfOwnBadge(player, badgeId) then
        badgeService:AwardBadge(player.UserId, badgeId)
        return true
    else
        return false
    end
end

return module
