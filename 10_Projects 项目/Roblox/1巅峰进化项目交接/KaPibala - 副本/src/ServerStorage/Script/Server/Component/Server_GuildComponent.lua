local hotpot = _G.ServerHotpot
---@type DataStoreService
local DataStoreService = game:GetService("DataStoreService")
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local PlayerGuildDataStore = DataStoreService:GetDataStore("PlayerGuild")--玩家公会信息

local STARTTIME = 1766534400
local guildDailyCfg = hotpot.config.guildDaily
local guildShopCfg = hotpot.config.guildShop
local expTable = {}
for k,v in pairs(hotpot.config.monster)do
    if v.id ~= 1 then
        table.insert(expTable,v.exp)
    end
end
table.sort(expTable)

local warshipList = {
    [1] = 10,
    [2] = 20,
    [3] = 50,
    [4] = 100,
    [5] = 4000,
    [6] = 10000,
    [7] = 100000,
    [8] = 200000,
    [9] = 1000000,
    [10] = 2000000,
    [11] = 20000000,
    [12] = 200000000,
}

---@class Server_GuildComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('guild')

    self:InitData()
    self:AddUpdate(self.CheckGuild,30)
    self:AddUpdate(self.UpdateLoginTime,800)
    self:AddUpdate(self.UpdatePlayerPower,900)

    self:UpdateLoginTime()
    self:UpdatePlayerPower()    
    self:AddProcess(function()
        self:Wait(3)
        if place_manager:GetIdByName('guildsence') == game.PlaceId then
            self:InitWorkspace()
        end
    end)
end

function c:GetGuildId()
    return self.data.__real.id
end

function c:InitWorkspace()
    local guildId = self.data.__real.id

    if not guildId then
        return 
    end

    local val = hotpot:GetPath_Loop('SenceModel.guildId',workspace)
    if val.Value == '' then
        val.Value = guildId 
    end
end

function c:AddCoin(num)
    self.parent.save_data:Execut(function()
        self.data.coin = self.data.coin + num
    end)
    self:Fire('addGuildCoin',num)
end

function c:AddExpTree()
    local guild_lv = self.guildInfo.lv or 1
    local lv = self.parent.prop_cmp:GetLv()
    local exp = expTable[lv]
    if not exp then
        exp = expTable[#expTable]
    end
    exp = exp * (1 + (guild_lv - 1) * 0.5)
    self.parent.reward_cmp:AddReward({{1,1,exp}})
end

function c:UpdateLoginTime()
    local guildId = self.data.__real.id
    if not guildId then
        return 
    end
    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager
    guild_manager:UpdatePlayerLoginTime(guildId,self.parent.user_id)
end

function c:UpdatePlayerPower()
    if place_manager:GetIdByName('pvpsence') == game.PlaceId then
        return
    end
    local guildId = self.data.__real.id
    if not guildId then
        return 
    end
    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    local atk = self.parent.prop_cmp:GetAttack()
    local hp = self.parent.prop_cmp:GetHp()
    local power = atk + hp

    local lv = self.parent.prop_cmp:GetLv()

    guild_manager:UpdatePlayerPower(guildId,self.parent.user_id,power,lv)
end

function c:CheckGuild()
    local r,e = pcall(function()
        return PlayerGuildDataStore:GetAsync(self.parent.user_id)
    end)
    if not r then
        warn(e)
    else
        if not e then
            self.parent.save_data:Execut(function()
                self.data.id = nil
                self.data.coin = 0
                -- self.data.shop.list = {}
                -- self.data.shop.mark = 0
                -- self.data.daily.mark = 0
                -- self.data.daily.get = 0
                -- self.data.daily.can_get = false--是否能领取
            end)

            self:Fire('updateGuildID',self.data.__real.id)
        else
            if not self.data.__real.id then
                local id = e.guildId
                self.parent.save_data:Execut(function()
                    self.data.id = id
                    self.data.coin = 0
                    -- self.data.shop.list = {}
                    -- self.data.shop.mark = 0
                    -- self.data.daily.mark = 0
                    -- self.data.daily.get = 0
                    -- self.data.daily.can_get = false--是否能领取
                end)
                self:Fire('updateGuildID',self.data.__real.id)
            end
        end
    end
end

function c:InitData()
    self:CheckGuild()

    local now = os.time()
    local sub = now - STARTTIME
    local day = math.floor(sub / 86400)
    if self.data.__real.id then
        if day > self.data.__real.daily.mark then
            self.parent.save_data:Execut(function()
                self.data.daily.mark = day
                self.data.daily.can_get = true
                self.data.shop.mark = day
                self.data.shop.list = {}
                if self.data.daily.get == 30 then
                    self.data.daily.get = 0
                end
            end)
        end
    end

    if day > self.data.worship.mark then
        self.parent.save_data:Execut(function()
            self.data.worship.get = false
            self.data.worship.mark = day
        end)
    end

end

function c:GetGuildInfo()
    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end

    local guildInfo = guild_manager:SearchGuildByGuildId(guildId)
    if not guildInfo then
        return nil
    end

    self.guildInfo = guildInfo

    local name = guildInfo.guild_name or ''
    self.parent.character:SetGuildName(name)

    return guildInfo
end

function c:CreateGuild(info)
    local gems = self.parent.prop_cmp:GetGems()
    if gems < 2000 then
        return nil
    end

    local create_mark = self.data.__real.create_mark
    create_mark = create_mark or 0
    local day = math.floor((os.time() - STARTTIME)/86400)
    if day <= create_mark then
        return false,'cold'
    end

    local uid = self.parent.user_id
    local lv = self.parent.prop_cmp:GetLv()
    local hp = self.parent.prop_cmp:GetHp()
    local atk = self.parent.prop_cmp:GetAttack()
    local power = hp + atk
    local name = info.name
    local public = info.public
    local announcement = info.announcement
    local type_ = info.type_
    local needPower = info.needPower
    local flag = info.flag
    local icon = info.icon

    if not (name and public and announcement and type_ and needPower and flag and icon) then
        return nil
    end

    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager
    local re,guildId = guild_manager:CreateGuild(
        name,
        announcement,
        flag,
        icon,
        needPower,
        type_,
        public,
        uid,
        lv,
        power
    )
    if not re then
        return false,guildId
    end
    self.parent.save_data:Execut(function()
        self.data.id = guildId

        self.data.create_mark = day
    end)

    return true,guildId
end

function c:GetJoinGuildList()
    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager
    return guild_manager:GetAllGuild()
end

function c:RequestJoinGuild(guildId)
    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    local coldTime = self.data.__real.exit_cd or 0

    if os.time() < coldTime then
        return false,5
    end 

    local atk = self.parent.prop_cmp:GetAttack()
    local hp = self.parent.prop_cmp:GetHp()
    local lv = self.parent.prop_cmp:GetLv()
    local power = hp + atk

    local uid = self.parent.user_id

    local re,gid = guild_manager:JoinGuild(guildId,uid,lv,power)
    -- print(re,gid)
    if not re then
        return false,gid
    else
        if gid then
            self.parent.save_data:Execut(function()
                self.data.id = gid
            end)
        end
    end

    return re,gid
end

function c:SearchGuild(txt)
    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager
    
    local info = guild_manager:SearchGuildByShowId(txt)
    if not info then
        info = guild_manager:SearchGuildByName(txt)
        if not info then
            return nil
        end
    end
    return true,info
end

function c:ModifyGuildInfo(info)
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end
    local uid = self.parent.user_id

    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    return guild_manager:ModifyGuildInfo(uid,guildId,info)
end

function c:PromotionPlayer(uid,targetUid)
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end

    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    return guild_manager:PromotionPlayer(uid,guildId,targetUid)
end

function c:DemotionPlayer(uid,targetUid)
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end

    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    return guild_manager:DemotionPlayer(uid,guildId,targetUid)
end

function c:KickPlayer(uid,targetUid)
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end

    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    return guild_manager:KickPlayer(uid,guildId,targetUid)
end

function c:AgreePlayer(uid,targetUid)
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end

    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    return guild_manager:AgreePlayer(guildId,uid,targetUid)
end

function c:RefusePlayer(uid,targetUid)
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end

    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    return guild_manager:RefusePlayer(guildId,uid,targetUid)
end

function c:LeaveGuild()
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end

    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    local re =  guild_manager:LeaveGuild(guildId,self.parent.user_id)
    if re then
        self.parent.save_data:Execut(function()
            self.data.id = nil
            self.data.coin = 0
            -- self.data.shop.list = {}
            -- self.data.shop.mark = 0
            -- self.data.daily.mark = 0
            -- self.data.daily.get = 0
            -- self.data.daily.can_get = false--是否能领取
            self.data.exit_cd = os.time() + 3600 * 8
        end)
        return true,self.data.__real.exit_cd
    end
    return false
end

function c:GetDailyReward()
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end
    if not self.data.__real.daily.can_get then
        return
    end
    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    local get = self.data.__real.daily.get
    get = get + 1
    if get > 30 then
        return
    end

    local re1 = guild_manager:AddGuildExp(guildId,self.parent.user_id,guildDailyCfg[get].guildExp)
    local re2 = guild_manager:AddPlayerContribution(guildId,self.parent.user_id,guildDailyCfg[get].contribute)
    if re1 and re2 then
        self.parent.save_data:Execut(function()
            self.data.daily.can_get = false
            self.data.daily.get = get
            self.data.coin = self.data.coin + guildDailyCfg[get].guildCoin
        end)

        self.parent.reward_cmp:AddReward({guildDailyCfg[get].reward})
        return true
    end
    return false
end

function c:BuyGuildShopItem(id)
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end
    local cfg = guildShopCfg[id]
    local price = cfg.price
    local limit = cfg.limit
    if self.data.__real.coin < price then
        return nil
    end
    local myLimit = self.data.__real.shop.list[id] or 0
    if myLimit >= limit then
        return nil
    end
    self.parent.save_data:Execut(function()
        self.data.coin = self.data.coin - price
        self.data.shop.list[id] = myLimit + 1
    end)

    self.parent.reward_cmp:AddReward({cfg.reward})

    return true
end

function c:TeleportToGuildSence()
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end
    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager
    return guild_manager:Teleport(guildId,self.parent.main_inst)
end

function c:OpenTree()
    if place_manager:GetIdByName('guildsence') ~= game.PlaceId then
        return nil
    end
    if not self.guildInfo then
        return nil
    end
    local guild_id = self.data.__real.id
    if not guild_id then
        return nil
    end

    local guildLv = self.guildInfo.lv or 1

    local uid = tostring(self.parent.user_id)
    local myInfo =  self.guildInfo.player_list[uid]
    if not myInfo then
        return nil
    end
    if myInfo.post < 4 then
        return false,1
    end
    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager
    local re,arg = guild_manager:UpdateGuildTreeTime(guild_id)
    if re then
        if arg then
            return false,3
        else
            ---@type GameServer
            local server = _G.server
            ---@type Server_GuildStageObj
            local guild_stage_obj = server.guild_stage_obj
            guild_stage_obj:OpenTree(guildLv)

            return true
        end
    end
    return false
end

function c:OpenBoss()
    if place_manager:GetIdByName('guildsence') ~= game.PlaceId then
        return nil
    end
    if not self.guildInfo then
        return nil
    end
    local guild_id = self.data.__real.id
    if not guild_id then
        return nil
    end
    local uid = tostring(self.parent.user_id)
    local myInfo =  self.guildInfo.player_list[uid]
    if not myInfo then
        return nil
    end
    if myInfo.post < 4 then
        return false,1
    end
    -- if not IsInUtcTimeBoss() then
    --     return false,2
    -- end
    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager
    local re,arg = guild_manager:UpdateGuildBossTime(guild_id)
    if re then
        if arg then
            return false,3
        else
            ---@type GameServer
            local server = _G.server
            ---@type Server_GuildStageObj
            local guild_stage_obj = server.guild_stage_obj
            guild_stage_obj:OpenBoss()

            return true
        end
    end
    return false
end

function c:UpdatePKScore(score)
    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end
    guild_manager:UpdatePKScore(guildId,self.parent.user_id,score)
end

function c:GetGuildName()
    if self.guildInfo then
        return self.guildInfo.guild_name
    end
    return nil
end

--公会战报名
function c:JoinGuildWar()
    if os.time() < 1777248000 then
        return false,0
    end

    if not hotpot.pro_cfg.IsInGuildJoinTime() then
        return false,1
    end
    local guildId = self.data.__real.id
    if not guildId then
        return false
    end

    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    local re,arg = guild_manager:Registration(guildId,self.parent.user_id)
    if re then
        self.guildInfo.warInfo = self.guildInfo.warInfo or {}
        self.guildInfo.warInfo.week = hotpot.pro_cfg.GetWeek()
        self.guildInfo.warInfo.is_join = true
        return true
    end
    return re,arg
end

--增加击杀
function c:AddKillInWarRank(score)
    local guildId = self.data.__real.id
    if not guildId then
        return nil
    end

    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    local re = guild_manager:AddKillInWarRank(guildId,self.parent.user_id,score)
end

--领取公会战奖励
function c:GetGuildWarReward()
    local week = hotpot.pro_cfg.GetWeek()
    local data = self.data.__real.getWarReward
    data = data or -100
    if data == (week - 1) then
        return false,1--已领取
    end

    ---@type GameServer
    local server = _G.server
    ---@type GuildManager
    local guild_manager = server.guild_manager

    local id = self.data.__real.id
    if not id then
        return false,3--失败
    end

    local rank = guild_manager:GetRankInWarRankByWeek(id,week-1)
    if rank == 0 or rank > 3 then
        return false,2--未达到前四名
    end

    local lastTime = hotpot.pro_cfg.GetLastDayTimeByWeek()
    local Owneruid = guild_manager:GetGuildOwnerUserId(id)
    Owneruid = tonumber(Owneruid)
    if rank == 1 then
        if Owneruid == self.parent.user_id then
            self.parent.title_cmp:UnlockLimitTimeTitle(20,lastTime)
        else
            self.parent.title_cmp:UnlockLimitTimeTitle(21,lastTime)
        end
    elseif rank == 2 then
        if Owneruid == self.parent.user_id then
            self.parent.title_cmp:UnlockLimitTimeTitle(22,lastTime)
        else
            self.parent.title_cmp:UnlockLimitTimeTitle(23,lastTime)
        end
    elseif rank == 3 then
        if Owneruid == self.parent.user_id then
            self.parent.title_cmp:UnlockLimitTimeTitle(24,lastTime)
        else
            self.parent.title_cmp:UnlockLimitTimeTitle(25,lastTime)
        end
    end

    self.parent.save_data:Execut(function()
        self.data.getWarReward = week - 1
    end)

    return true
end

--膜拜
function c:Worship(guild_id,rank)
    if self.data.__real.id ~= guild_id then
        return false,0
    end

    if self.data.__real.worship.get then
        return false,1
    end

    local stage = self.parent.stage_cmp:GetMaxStage()
    local gems = warshipList[stage] or warshipList[9]
    self.parent.reward_cmp:AddReward({{11,1,5},{11,2,1},{1,2,gems}})

    self.parent.save_data:Execut(function()
        self.data.worship.get = true
    end)

    return true
end

c:RegistFunction('getGuildInfo',c.GetGuildInfo)
c:RegistFunction('CreateGuild',c.CreateGuild)
c:RegistFunction('getJoinGuildList',c.GetJoinGuildList)
c:RegistFunction('RequestJoinGuild',c.RequestJoinGuild)
c:RegistFunction('SearchGuild',c.SearchGuild)
c:RegistFunction('ModifyGuildInfo',c.ModifyGuildInfo)
c:RegistFunction('PromotionPlayer',c.PromotionPlayer)
c:RegistFunction('DemotionPlayer',c.DemotionPlayer)
c:RegistFunction('KickPlayer',c.KickPlayer)
c:RegistFunction('AgreePlayer',c.AgreePlayer)
c:RegistFunction('RefusePlayer',c.RefusePlayer)
c:RegistFunction('LeaveGuild',c.LeaveGuild)
c:RegistFunction('GetGuildDailyReward',c.GetDailyReward)
c:RegistFunction('BuyGuildShopItem',c.BuyGuildShopItem)
c:RegistEvent('TeleportToGuildSence',c.TeleportToGuildSence)
c:RegistFunction('OpenGuildTree',c.OpenTree)
c:RegistFunction('OpenGuildBoss',c.OpenBoss)
c:RegistFunction('clientRegisterGuildWar',c.JoinGuildWar)
c:RegistFunction('getguildwarreward',c.GetGuildWarReward)

return c