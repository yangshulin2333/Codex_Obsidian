local hotpot = _G.ServerHotpot
---@type DataStoreService
local DataStoreService = game:GetService("DataStoreService")
---@type HttpService
local HttpService = game:GetService("HttpService")
---@type ProjectConfig
local proCfg = hotpot.load.ProjectConfig()
---@type MemoryStoreService
local MemoryStoreService = game:GetService("MemoryStoreService") 
---@type PlaceManager
local placeManager = hotpot.load.PlaceManager()
---@type TeleportService
local TeleportService = game:GetService("TeleportService")

local guildSceneId = placeManager:GetIdByName('guildsence')
local GuildMap = MemoryStoreService:GetHashMap("GuildAccessCodes")
local STARTTIME = 1767139200

local GuildListDataStore = DataStoreService:GetDataStore("GuildList")--所有公会列表
local PlayerGuildDataStore = DataStoreService:GetDataStore("PlayerGuild")--玩家公会信息
local GuideNameToIdDataStore = DataStoreService:GetDataStore("GuideNameToId")--公会名称到ID的映射
local GuildRankDataStore = DataStoreService:GetOrderedDataStore("GuildRank")--公会等级排名
local GuildCodeToIdDataStore = DataStoreService:GetDataStore("GuildCodeToId")--公会代码到ID的映射
local GuildCodeCounterStore = DataStoreService:GetDataStore("GuildCodeCounter")--公会代码计数器
local GuildIndexDataStore = DataStoreService:GetDataStore("GuildIndex")--公会索引

local totalGuildList = {}
local rankList = {}
local warRankList = {}

---@class GuildManager
local c = hotpot.class.new(script)
function c.new()
    return c()
end
function c:ctor()
end

function c:CreateGuild(name,announcement,flag,icon,needPower,type_,public,uid,playerLv,playerPower)
    local r1,e1 = pcall(function()
        return GuideNameToIdDataStore:GetAsync(name)
    end)
    if r1 and e1 then
        --warn("GuildName已存在")
        return false,1
    end
    local guildId = HttpService:GenerateGUID(false)
    local guildCode
    GuildCodeCounterStore:UpdateAsync("Counter", function(v)
        v = (v or 100000) + 1
        guildCode = v
        return v
    end)
    local r,e = pcall(function()
        GuildCodeToIdDataStore:SetAsync(guildCode,guildId)
    end)
    if not r then
        warn(e)
        return false
    end
    
    local success, err = pcall(function()
        GuildListDataStore:UpdateAsync(guildId, function(old)
            if old ~= nil then
                return nil -- 已存在，不创建
            end

            return {
                guild_id = guildId,
                showId = guildCode,
                guild_name = name,
                announcement = announcement,
                flag = flag,
                icon = icon,
                need_power = needPower,
                type = type_,
                public = public,
                creater_uid = uid,
                lv = 1,
                exp = 0,

                player_list = {
                    [uid] = {
                        post = 5,
                        contribution = 0,
                        join_time = os.time(),
                        last_active = os.time(),
                        power = playerPower,
                        lv = playerLv,
                    }
                },

                apply_list = {},
                player_count = 1,
                max_player_count = 20,
                total_power = playerPower,

                last_tree_time = 0,
                last_boss_time = 0,
            }
        end)
    end)

    if not success then
        warn(err)
        return false
    end

    local r,e = pcall(function()
        GuideNameToIdDataStore:SetAsync(name,guildId)
        GuildRankDataStore:SetAsync(guildId,math.floor(math.log10(playerPower) * 1e6))
        PlayerGuildDataStore:SetAsync(uid,{
            guildId = guildId,
        })
        GuildIndexDataStore:UpdateAsync('GuildIndex',function(old)
            if not old then
                return nil
            end
            old[guildId] = {
                name = name,
                player_count = 1,
                max_player_count = 20,
                power = playerPower,
                public = public,
                needPower = needPower,
                flag = flag,
                icon = icon,
            }
            return old
        end)
    end)
    if not r then
        warn(e)
        return false
    end

    return true,guildId
end

function c:JoinGuild(guildId,uid,lv,power)
    local r,e = pcall(function()
		return GuildListDataStore:GetAsync(guildId)
	end)
	if not r then
		warn(e,'加入失败')
		return false
	end
    local guild_info = e

    if not guild_info then
        return false,1
    end

	if guild_info.player_count >= guild_info.max_player_count then
		return false,1
	end
	if guild_info.apply_list[uid] then
		return false,2
	end 
    if guild_info.public == 2 then
		return false,3
	end
    local needPower = guild_info.need_power
    needPower = proCfg.guildNeedPower[needPower]
    if power < needPower then
        return false,4
    end

	r,e = pcall(function()
		return PlayerGuildDataStore:GetAsync(uid)
	end)
	if not r then
		warn(e)
		return false
	end
    local player_info = e
	if player_info and player_info.guild_id then
		return false
	end

    if guild_info.type == 1 then--无需同意
        local COUNT = 0
        r,e = pcall(function()
            return GuildListDataStore:UpdateAsync(guildId,function(currentData)
                if not currentData then
                    return nil
                end
                if currentData.player_count >= currentData.max_player_count then
                    return nil
                end
                if currentData.player_list[uid] then
                    return nil
                end
                
                currentData.player_list[uid] = {
                    post = 1,
                    contribution = 0,
                    join_time = os.time(),
                    last_active = os.time(),
                    power = power,
                    lv = lv,
                }
                currentData.total_power = currentData.total_power + power
                
                --计算人数
                COUNT = 0
                for k,v in pairs(currentData.player_list) do
                    COUNT = COUNT + 1
                end
                currentData.player_count = COUNT

                return currentData
            end)
        end)
        if not r then
            warn(e)
            return false
        end
        r,e = pcall(function()
            GuildIndexDataStore:UpdateAsync('GuildIndex',function(old)
                if not old then
                    return nil
                end
                old[guildId].player_count = COUNT
                old[guildId].power = old[guildId].power + power
                return old
            end)
            PlayerGuildDataStore:SetAsync(uid,{
                guildId = guildId,
            })
        end)
        if not r then
            warn(e)
            return false
        end
        return true,guildId
    elseif guild_info.type == 2 then--需要同意
        r,e = pcall(function()
            return GuildListDataStore:UpdateAsync(guildId,function(currentData)
                if not currentData then
                    return nil
                end
                if currentData.player_count >= currentData.max_player_count then
                    return nil
                end
                if currentData.player_list[uid] then
                    return nil
                end
                if currentData.apply_list[uid] then
                    return nil
                end
                
                currentData.apply_list[uid] = {
                    power = power,
                    lv = lv,
                }
                
                return currentData
            end)
        end)
        if not r then
            warn(e)
            return false
        end
        return true
    end
end

function c:LeaveGuild(guildId,uid)
    uid = tostring(uid)
    if not uid or not guildId then
        return false
    end
    local r,e = pcall(function()
		return GuildListDataStore:GetAsync(guildId)
	end)
	if not r then
		warn(e)
		return false
	end
    local guild_info = e
    if not guild_info then
        return false
    end
    if not guild_info.player_list[uid] then
        return false
    end

    local post = guild_info.player_list[uid].post

    local new_leader = nil
    if post == 5 then
        if guild_info.player_count == 1 then
            new_leader = nil
        end

        --找到最高权限的玩家
        local max_post = 0
        local max_uid = 0
        for k,v in pairs(guild_info.player_list) do
            if k ~= uid then
                if v.post > max_post then
                    max_post = v.post
                    max_uid = k
                end
            end
        end
        if max_uid == 0 then
            new_leader = nil
        else
            new_leader = max_uid
        end
    end

    local POWER = 0
    local del = false
    local COUNT = 0
    r,e = pcall(function()
        return GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end
            if not currentData.player_list[uid] then
                return nil
            end

            POWER = currentData.player_list[uid].power
            currentData.player_count = currentData.player_count - 1
            currentData.total_power = currentData.total_power - POWER
            currentData.player_list[uid] = nil
            if new_leader then
                if currentData.player_list[new_leader] then
                    currentData.player_list[new_leader].post = 5
                end
            end

            --计算人数
            local count = 0
            for k,v in pairs(currentData.player_list) do
                count = count + 1
            end
            currentData.player_count = count
            COUNT = count
            if COUNT == 0 then
                del = true
            end

            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end
    r,e = pcall(function()
        PlayerGuildDataStore:RemoveAsync(uid)
        if del then
            GuildListDataStore:RemoveAsync(guildId)
            GuildRankDataStore:RemoveAsync(guildId)
            GuildCodeToIdDataStore:RemoveAsync(guild_info.showId)
            GuildIndexDataStore:UpdateAsync('GuildIndex',function(old)
                if not old then
                    return nil
                end
                old[guildId] = nil
                return old
            end)
            GuideNameToIdDataStore:RemoveAsync(guild_info.guild_name)
        else
            GuildIndexDataStore:UpdateAsync('GuildIndex',function(old)
                if not old then
                    return nil
                end
                old[guildId].player_count = COUNT
                old[guildId].power = math.max(0,old[guildId].power - POWER)
                return old
            end)
        end
    end)
    if not r then
        warn(e)
        return false
    end
    return true
end

function c:AgreePlayer(guildId,uid,targetUid)
    uid = tostring(uid)
    targetUid = tostring(targetUid)
    if not uid or not guildId or not targetUid then
        return false
    end
    local r,e = pcall(function()
        return GuildListDataStore:GetAsync(guildId)
    end)
    if not r then
        warn(e)
        return false
    end
    local guild_info = e
    if not guild_info then
        return false
    end
    if not guild_info.apply_list[targetUid] then
        return false
    end
    if guild_info.player_list[targetUid] then
        return false
    end
    if guild_info.player_count >= guild_info.max_player_count then
        return false
    end

    if not guild_info.player_list[uid] then
        return false
    end
    if guild_info.player_list[uid].post < 4 then
        return false
    end

    --检查玩家是否已经有公会
    r,e = pcall(function()
        return PlayerGuildDataStore:GetAsync(targetUid)
    end)
    if not r then
        warn(e)
        return false
    end
    local player_info = e
    if player_info and player_info.guild_id then
        return false
    end

    local POWER = 0
    local LV = 0
    local COUNT = 0
    r,e = pcall(function()
        return GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end
            if currentData.player_count >= currentData.max_player_count then
                return nil
            end
            if currentData.player_list[targetUid] then
                return nil
            end
            if not currentData.apply_list[targetUid] then
                return nil
            end

            POWER = currentData.apply_list[targetUid].power
            LV = currentData.apply_list[targetUid].lv
            
            currentData.player_list[targetUid] = {
                post = 1,
                contribution = 0,
                join_time = os.time(),
                last_active = os.time(),
                power = POWER or 0,
                lv = LV or 1,
            }
            currentData.total_power = currentData.total_power + POWER or 0
            
            currentData.apply_list[targetUid] = nil

            --计算人数
            COUNT = 0
            for k,v in pairs(currentData.player_list) do
                COUNT = COUNT + 1
            end
            currentData.player_count = COUNT
            
            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end

    r,e = pcall(function()
        GuildIndexDataStore:UpdateAsync('GuildIndex',function(old)
            if not old then
                return nil
            end
            old[guildId].player_count = COUNT
            old[guildId].power = old[guildId].power + POWER or 0
            return old
        end)
        PlayerGuildDataStore:SetAsync(targetUid,{
            guildId = guildId,
        })
    end)
    if not r then
        warn(e)
        return false
    end

    return true
end

function c:RefusePlayer(guildId,uid,targetUid)
    uid = tostring(uid)
    targetUid = tostring(targetUid)
    if not uid or not guildId or not targetUid then
        return false
    end
    local r,e = pcall(function()
        return GuildListDataStore:GetAsync(guildId)
    end)
    if not r then
        warn(e)
        return false
    end
    local guild_info = e
    if not guild_info then
        return false
    end
    if not guild_info.apply_list[targetUid] then
        return false
    end

    if not guild_info.player_list[uid] then
        return false
    end
    if guild_info.player_list[uid].post < 4 then
        return false
    end

    r,e = pcall(function()
        return GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end
            if not currentData.apply_list[targetUid] then
                return nil
            end
            currentData.apply_list[targetUid] = nil
            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end
    return true
end

function c:ModifyGuildInfo(uid,guildId,info)
    uid = tostring(uid)
    local name = info.name
    local des = info.des
    local flag = info.flag
    local icon = info.icon
    local need_power = info.need_power
    local type_ = info.type_
    local public = info.public

    if not (name and des and flag and icon and need_power and type_ and public) then
        return false
    end

    local oldName = ''
    local r,e = pcall(function()
        GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end
            if not currentData.player_list[uid] then
                return nil
            end
            if currentData.player_list[uid].post < 4 then
                return nil
            end
            oldName = currentData.guild_name
            currentData.guild_name = name
            currentData.announcement = des
            currentData.flag = flag
            currentData.icon = icon
            currentData.need_power = need_power
            currentData.type = type_
            currentData.public = public
            
            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end

    r,e = pcall(function()
        GuildIndexDataStore:UpdateAsync('GuildIndex',function(old)
            if not old then
                return nil
            end
            old[guildId].needPower = need_power
            old[guildId].public = public
            return old
        end)

        if oldName ~= name then
            GuideNameToIdDataStore:SetAsync(name,guildId)
            GuideNameToIdDataStore:RemoveAsync(oldName)
        end
    end)

    return true
end

function c:PromotionPlayer(uid,guildId,targetUid)
    uid = tostring(uid)
    targetUid = tostring(targetUid)
    if not uid or not guildId or not targetUid then
        return false
    end
    local r,e = pcall(function()
        GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end
            if not currentData.player_list[uid] then
                return nil
            end
            if currentData.player_list[uid].post < 4 then
                return nil
            end

            if not currentData.player_list[targetUid] then
                return nil
            end
            if currentData.player_list[targetUid].post >= 4 then
                return nil
            end
            
            currentData.player_list[targetUid].post = math.max(currentData.player_list[targetUid].post + 1,4)
            
            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end
    return true
end

function c:DemotionPlayer(uid,guildId,targetUid)
    uid = tostring(uid)
    targetUid = tostring(targetUid)
    if not uid or not guildId or not targetUid then
        return false
    end
    local r,e = pcall(function()
        GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end
            if not currentData.player_list[uid] then
                return nil
            end
            if currentData.player_list[uid].post < 4 then
                return nil
            end

            if not currentData.player_list[targetUid] then
                return nil
            end
            if currentData.player_list[targetUid].post <= 1 then
                return nil
            end
            
            currentData.player_list[targetUid].post = math.max(currentData.player_list[targetUid].post - 1,1)
            
            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end

    return true
end

function c:KickPlayer(uid,guildId,targetUid)
    uid = tostring(uid)
    targetUid = tostring(targetUid)
    local POWER = 0
    if not uid or not guildId or not targetUid then
        return false
    end
    local COUNT = 0
    local KICKTIME = false
    local r,e = pcall(function()
        GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end
            if not currentData.player_list[uid] then
                return nil
            end
            if currentData.player_list[uid].post < 4 then
                return nil
            end

            currentData.mark = currentData.mark or 0
            local mark = math.floor((os.time() - STARTTIME) / 86400)
            if mark > currentData.mark then
                currentData.mark = mark
                currentData.kick_num = 0
            end

            if currentData.kick_num >= 5 then
                KICKTIME = true
                return nil
            end
            currentData.kick_num = currentData.kick_num + 1


            if not currentData.player_list[targetUid] then
                return nil
            end
            if currentData.player_list[targetUid].post ~= 1 then
                return nil
            end
            POWER = currentData.player_list[targetUid].power
            
            currentData.player_list[targetUid] = nil

            currentData.total_power = math.max(0,currentData.total_power - POWER)
            
            --计算人数
            COUNT = 0
            for k,v in pairs(currentData.player_list) do
                COUNT = COUNT + 1
            end
            currentData.player_count = COUNT

            currentData.kick_time = os.time()
            
            return currentData
        end)
    end)

    if not r then
        warn(e)
        return false
    end

    r,e = pcall(function()
        PlayerGuildDataStore:RemoveAsync(targetUid)
        GuildIndexDataStore:UpdateAsync('GuildIndex',function(old)
            if not old then
                return nil
            end
            old[guildId].player_count = COUNT
            old[guildId].power = math.max(0,old[guildId].power - POWER)
            return old
        end)
    end)

    if not r then
        return false
    end

    return true,KICKTIME
end

function c:AddGuildExp(guildId,uid,exp)
    uid = tostring(uid)
    local LVUp = false
    local MaxPlayerCount = 0
    local r,e = pcall(function()
        return GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end
            
            if not currentData.player_list[uid] then
                return nil
            end

            local exp_ = currentData.exp
            exp_ = exp_ + exp
            local lv = currentData.lv
            if lv >= #proCfg.guildLv then
                exp_ = math.min(exp,proCfg.guildLv[lv])
            else
                if exp_ >= proCfg.guildLv[lv] then
                    exp_ = exp_ - proCfg.guildLv[lv]
                    lv = lv + 1
                    LVUp = true
                    currentData.max_player_count = proCfg.guildPlayerCount[lv]
                    MaxPlayerCount = currentData.max_player_count
                end
            end
            currentData.exp = exp_
            currentData.lv = lv

            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end

    r,e = pcall(function()
        if LVUp then
            GuildIndexDataStore:UpdateAsync('GuildIndex',function(old)
                if not old then
                    return nil
                end
                old[guildId].max_player_count = MaxPlayerCount
                return old
            end)
        end
    end)

    return true
end

function c:AddPlayerContribution(guild_id,uid,contribution)
    uid = tostring(uid)
    local r,e = pcall(function()
        return GuildListDataStore:UpdateAsync(guild_id,function(currentData)
            if not currentData then
                return nil
            end
            if not currentData.player_list[uid] then
                return nil
            end
            currentData.player_list[uid].contribution = currentData.player_list[uid].contribution + contribution
            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end
    return true
end

function c:UpdatePlayerLoginTime(guildId,uid)
    uid = tostring(uid)
    local r,e = pcall(function()
        return GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end
            if not currentData.player_list[uid] then
                return nil
            end
            currentData.player_list[uid].last_active = os.time()
            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end
    return true
end

function c:UpdatePlayerPower(guildId,uid,power,lv)
    uid = tostring(uid)
    local POWER = 0
    local r,e = pcall(function()
        return GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end
            if not currentData.player_list[uid] then
                return nil
            end
            currentData.player_list[uid].power = power
            currentData.player_list[uid].lv = lv

            for _,v in pairs(currentData.player_list) do
                POWER = POWER + v.power
            end

            currentData.total_power = POWER

            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end

    if POWER <= 0 then
        return false
    end

    r,e = pcall(function()
        -- GuildIndexDataStore:UpdateAsync('GuildIndex',function(old)
        --     if not old then
        --         return nil
        --     end
        --     if not old[guildId] then
        --         return nil
        --     end
        --     old[guildId].power = POWER
        --     return old
        -- end)
        GuildRankDataStore:UpdateAsync(guildId,function(old)
            return math.floor(math.log10(POWER) * 1e6)
        end)
    end)
    if not r then
        warn(e)
        return nil
    end
    return e
end

function c:UpdateGuildTreeTime(guildId)
    local arg = nil
    local r,e = pcall(function()
        return GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end

            currentData.last_tree_time = currentData.last_tree_time or 0

            local now = os.time()
            if now - currentData.last_tree_time < 3600 * 12 then
                arg = true
                return nil
            end

            currentData.last_tree_time = now
            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end
    return true,arg
end

function c:UpdateGuildBossTime(guildId)
    local arg = nil
    local r,e = pcall(function()
        return GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end

            currentData.last_boss_time = currentData.last_boss_time or 0

            local now = os.time()
            if now - currentData.last_boss_time < 3600 * 72 then
                arg = true
                return nil
            end

            currentData.last_boss_time = now
            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end
    return true,arg
end

function c:UpdatePKScore(guildId,uid,score)
    uid = tostring(uid)
    local r,e = pcall(function()
        return GuildListDataStore:UpdateAsync(guildId,function(currentData)
            if not currentData then
                return nil
            end
            if not currentData.player_list[uid] then
                return nil
            end

            currentData.player_list[uid].pk_score = currentData.player_list[uid].pk_score or 0

            currentData.player_list[uid].pk_score = currentData.player_list[uid].pk_score + score
            return currentData
        end)
    end)
    if not r then
        warn(e)
        return false
    end
    return true
end

function c:SearchGuildByGuildId(guildId)
    local r,e = pcall(function()
        return GuildListDataStore:GetAsync(guildId)
    end)
    if not r then
        warn(e)
        return nil
    end
    return e
end

function c:SearchGuildByName(guildName)
    local r,e = pcall(function()
        return GuideNameToIdDataStore:GetAsync(guildName)
    end)
    if not r then
        warn(e)
        return nil
    end
    local guildId = e
    if not guildId then
        return nil
    end
    r,e = nil,nil
    r,e = pcall(function()
        return GuildListDataStore:GetAsync(guildId)
    end)
    if not r then
        warn(e)
        return nil
    end
    return e
end

function c:SearchGuildByShowId(showId)
    local r,e = pcall(function()
        return GuildCodeToIdDataStore:GetAsync(showId)
    end)
    if not r then
        warn(e)
        return false
    end
    local guild_id = e
    if not guild_id then
        return false
    end
    return self:SearchGuildByGuildId(guild_id)
end

function c:GetAllGuild()
    return totalGuildList
end

function c:GetRank()
    return rankList
end

--------------公会战
--获取某周的列表
function c:GetWarRankByWeek(num)
    local str = 'OrderGuildWarRank_'..num
    local DS = DataStoreService:GetOrderedDataStore(str)
    if not DS then
        return 
    end
    local list = DS:GetSortedAsync(false,20)
    return list
end

--增加击杀
function c:AddKillInWarRank(guildId,uid,score)
    score = score or 1
    local week = hotpot.pro_cfg.GetWeek()
    local str = 'OrderGuildWarRank_'..week
    local DS = DataStoreService:GetOrderedDataStore(str)

    local str1 = guildId..'_Week_'..week
    local DS1 = DataStoreService:GetOrderedDataStore(str1)
    if not DS or not DS1 then
        return 
    end 
    local r,e = pcall(function()
        DS:IncrementAsync(guildId,score)
        DS1:IncrementAsync(uid,score)
    end)
    if not r then
        warn(e)
    end
end

--获取排名
function c:GetRankInWarRankByWeek(guildId,num)
    local list = self:GetWarRankByWeek(num)
    if list then
        list = list:GetCurrentPage()
        for k,v in ipairs(list)do
            if v.key == guildId then
                return k
            end
        end
    end
    return 0
end

--报名
function c:Registration(guildId,uid)
    uid = tostring(uid)
    local week = hotpot.pro_cfg.GetWeek()
    local data = self:SearchGuildByGuildId(guildId)
    if not data.player_list[uid] then
        return false
    end
    if data.player_list[uid].post < 4 then
        return false,2
    end

    -- warInfo = {
    --     week = 0,
    --     is_join = false,
    -- }

    local can_join = false
    if data.warInfo then
        if data.warInfo.week == week then
            if not data.warInfo.is_join then
                can_join = true
            end
        else
            can_join = true
        end
    else
        can_join = true
    end

    if not can_join then
        return false,3
    end

    local r,e = pcall(function()
        return GuildListDataStore:UpdateAsync(guildId,function(currentData)
            currentData.warInfo = {
                week = week,
                is_join = true,
            }
            return currentData
        end)
    end)
    if not r then
        warn(e)
    else
        return true
    end
    return false,4
end

--获取公会会长id
function c:GetGuildOwnerUserId(guildId)
    local info = self:SearchGuildByGuildId(guildId)
    if not info then
        return
    end
    local uid 
    for k,v in pairs(info.player_list)do
        if v.post == 5 then
            uid = k
            break
        end
    end
    uid = uid or info.creater_uid
    return uid,info.guild_name
end

--获取总排行榜
local function GetAllRank()
    local isjoin = hotpot.pro_cfg.IsInGuildJoinTime()
    local week = hotpot.pro_cfg.GetWeek()
    if isjoin then
        week = week - 1
    end
    local str = 'OrderGuildWarRank_'..week
    local DS = DataStoreService:GetOrderedDataStore(str)
    if not DS then
        return 
    end
    local list = DS:GetSortedAsync(false,30)
    
    if not list then
        return
    end
    list = list:GetCurrentPage()
    for k,v in ipairs(list)do
        spawn(function()
            local r,e = pcall(function()
                return GuildListDataStore:GetAsync(v.key)
            end)
            if not r then
                warn(e)
                e = {
                    icon = math.random(1,#proCfg.guildIcon),
                    name = 'Unknown',
                    flag = math.random(1,#proCfg.guildFlag),
                    player_count = 50,
                    max_player_count = 50,
                    lv = 4,
                    power = 10 ^ (v.value / 1e6)
                }
            end
            if e then
                warRankList[k] = {
                    icon = e.icon or '',
                    name = e.guild_name,
                    flag = e.flag,
                    player_count = e.player_count,
                    max_player_count = e.max_player_count,
                    kill = v.value,
                    lv = e.lv,
                }
            end
        end)
    end
end

--------------公会战

local function Init()
    local r,e = pcall(function()
        return GuildIndexDataStore:GetAsync('GuildIndex')
    end)
    if not r then
        warn(e)
        return nil
    else
        if not e then
            GuildIndexDataStore:SetAsync('GuildIndex',{})
        end
    end
end

local function GetAllGuild()
    local r,e = pcall(function()
        return GuildIndexDataStore:GetAsync('GuildIndex')
    end)
    if not r then
        warn(e)
    else
        totalGuildList = e
    end
end

local function GetRank()
    local list = GuildRankDataStore:GetSortedAsync(false,100)
    local tab = list:GetCurrentPage()
    for k,v in ipairs(tab)do
        spawn(function()
            local r,e = pcall(function()
                return GuildListDataStore:GetAsync(v.key)
            end)
            if not r then
                warn(e)
                e = {
                    icon = math.random(1,#proCfg.guildIcon),
                    name = 'Unknown',
                    flag = math.random(1,#proCfg.guildFlag),
                    player_count = 50,
                    max_player_count = 50,
                    lv = 4,
                    power = 10 ^ (v.value / 1e6)
                }
            end
            rankList[k] = {
                icon = e.icon,
                name = e.guild_name,
                flag = e.flag,
                player_count = e.player_count,
                max_player_count = e.max_player_count,
                power = e.total_power,
                lv = e.lv,
            }
        end)
    end
end

local function GetTeleportCode(guildId)
	-- 尝试读取已有 accessCode
	local success, accessCode = pcall(function()
		return GuildMap:GetAsync(guildId)
	end)

	if success and accessCode then
		return accessCode
	end
	-- 没有的话，创建一个
	local newCode = TeleportService:ReserveServerAsync(guildSceneId)

	-- 存入 MemoryStore（设定 4 小时有效期，可自行调整）
	pcall(function()
		GuildMap:SetAsync(guildId, newCode, 4 * 3600)
	end)
	-- print(newCode)
	return newCode
end

--传送公会
local function Teleport(guildId,player)
	local accessCode = GetTeleportCode(guildId)
	-- print(accessCode)
	if not accessCode then
		return false
	end
	TeleportService:TeleportToPrivateServer(
		guildSceneId,
		accessCode,
		{ player }
	)
end

function c:Teleport(guildId,player)
    Teleport(guildId,player)
end

Init()
GetAllGuild()
GetRank()
spawn(function()
    while true do
        wait(250)
        GetAllGuild()
    end
end)
spawn(function()
    while true do
        wait(700)
        GetRank()
    end
end)
spawn(function()
    GetAllRank()
    while true do
        wait(600)
        GetAllRank()
    end
end)

hotpot.function_manager:SetHandle('getGuildRank',function()
    return rankList
end)

hotpot.function_manager:SetHandle('getwarrank',function()
    return warRankList
end)

return c
