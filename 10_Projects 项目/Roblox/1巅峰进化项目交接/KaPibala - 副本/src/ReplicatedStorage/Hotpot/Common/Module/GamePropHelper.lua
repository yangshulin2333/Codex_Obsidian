-- 获得游戏的点赞数量,最爱数量,玩家是否点了最爱
local hotpot = _G.CommonHotpot
---@type HttpService
local httpService = game:GetService("HttpService")
local UniverseId = game.GameId

local PlaceId = game.PlaceId
local GetStrs = {
    -- 最爱:需要UniverseId
    favorite = {
        need = "universeId",
        str = "https://games.roproxy.com/v1/games/%s/favorites/count",
        key = "favoritesCount"
    },
    -- 点赞数量:需要universeId,
    votes = {
        need = "universeId",
        str = "https://games.roproxy.com/v1/games/votes?universeIds=%s",
        key = "data.1.upVotes"
    },
    -- 最爱的游戏,需要玩家id,拿到他的最爱数组一一比较,1.id = game.GameId
    favoritres_list = {
        need = "userId",
        str = "https://games.roproxy.com/v2/users/1654469671/favorite/games?accessFilter=Public",
        key = "id"
    }
}
local RequestStrs = {}
---@class GamePropHelper @所有调用最好搭配协程使用
local c = {}
---@type fun() @获得最爱数量
function c:GetFavoriteNum(universeId)
    if not universeId then
        universeId = UniverseId
    end
    local su, res = pcall(function()
        return httpService:JSONDecode(httpService:GetAsync(string.format(GetStrs.favorite.str, universeId)))
    end)
    if not su then
        su, res = pcall(function()
            return httpService:JSONDecode(httpService:GetAsync(string.format(GetStrs.favorite.str, universeId)))
        end)
        if not su then
            warn("GetFavoriteNum Failed" .. res)
            return
        end
    end
    return res.favoritesCount
end
---@type fun() @获得点赞数量
function c:GetVotesNum(universeId)
    if not universeId then
        universeId = UniverseId
    end
    local su, res = pcall(function()
        return httpService:JSONDecode(httpService:GetAsync(string.format(GetStrs.votes.str, universeId)))
    end)
    if not su then
        su, res = pcall(function()
            return httpService:JSONDecode(httpService:GetAsync(string.format(GetStrs.votes.str, universeId)))
        end)
        if not su then
            warn("GetVotesNum failed pleaseTryAgain" .. res)
            return
        end
    end
    return res.data[1].upVotes
end
---@type fun() @玩家是否喜爱本游戏,最好存一个存档,如果没有才调用
function c:GetIfPlayerFavorite(player, universeId)
    -- 先拿到玩家的最爱list
    -- 一一比对,如果game.id == universeId则是玩家已经喜爱了
    if not universeId then
        universeId = UniverseId
    end
    if not player then
        warn("no player exist,please check")
        return
    end
    local su, res = pcall(function()
        return httpService:JSONDecode(httpService:GetAsync(string.format(GetStrs.favoritres_list.str, player.UserId)))
    end)
    if not su then
        su, res = pcall(function()
            return httpService:JSONDecode(
                httpService:GetAsync(string.format(GetStrs.favoritres_list.str, player.UserId)))
        end)
        if not su then
            warn("getPlayerFavList failed" .. res)
            return
        end
    end
    for __, gameInfo in ipairs(res) do
        if gameInfo.id == universeId then
            return true
        end
    end
    return false
end
return c
