--添加全局变量
local _G = _G
local debug = debug
local xpcall = xpcall
local warn = warn
local table = table
local script = script
local Instance = Instance
local print = print
local os = os
local pairs = pairs
--添加引用
local hotpot = _G.ServerHotpot
local hotpot_enum = hotpot.enum
local collider_group = hotpot.load.ColliderGroup()
local collider_manager = hotpot.load.ColliderManager()
local data_base = hotpot.load.DataBaseManager()
---@type InstanceManager
local inst_manager = hotpot.load.InstanceManager()
---@type HttpService
local HttpService = game:GetService("HttpService")
---@type Players
local players = game:GetService("Players")
---@type Server_RankManager
local rank_manager = hotpot.load.Server_RankManager()
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()
---@type RankRig
local rank_rig = hotpot.load.RankRig()
local MessagingService = game:GetService('MessagingService')
---@type DataStoreService
local DataStoreService = game:GetService("DataStoreService")

local black_list = require(hotpot:GetPath_Loop('BlackList',hotpot.Resource))
local loadingGui = hotpot:GetPath_Loop('ui.LoadingGui',hotpot.Resource)
local VERIFY_URL = "https://www.myrobloxverify.site/verify"
local has_send_1hour = false

local GuildWarRank = {}

---@class GameServer:ServerBase
local c = hotpot.class.new(script, hotpot.files.ServerBase())
function c.new()
    local server = c()
    ---@type GameServer
    _G.server = server
    return server
end
function c:ctor()
    c.super.ctor(self)
    -- self:SetAutoCreateCharacter(false)
    self.player_play_time = {}
    hotpot.load.GMCommand()
    
    self:AddComponent(hotpot.load.Server_MallComponent())

    ---@type Server_GuildManager
    self.guild_manager = hotpot.load.GuildManager().new()

    ---@type Server_TeamManager
    self.team_manager = hotpot.load.Server_TeamManager().new()

    if place_manager:GetIdByName('partysence') == game.PlaceId then
    elseif place_manager:GetIdByName('guildsence') == game.PlaceId then
        self.guild_stage_obj = hotpot.load.Server_GuildStageObj().new()
    elseif place_manager:GetIdByName('pvpsence') == game.PlaceId then
        local model = workspace:WaitForChild('pvpModel')
        self.pvp_stage_obj = hotpot.load.Server_PvpStageObj().new(model)

        self:SetGuildWarRank()

        self:AddProcess(function()
            while true do
                self:Wait(1800)
                self:SetGuildWarRank()
            end
        end)

    elseif place_manager:GetIdByName('challengesence') == game.PlaceId then
        ---@type Server_ChallengeStageObj
        self.challenge_stage_obj = hotpot.load.Server_ChallengeStageObj().new()
    else
        ---@type Server_StageManager
        self.stage_manager = hotpot.load.Server_StageManager().new()
        ---@type Server_PartyManager
        self.party_manager = hotpot.load.Server_PartyManager().new()
        self:AddProcess(self.GetRank)
        self:AddUpdate(self.GetRank,590)

        self.wsj_manager = hotpot.load.Server_WSJManager().new()

        -- ---@type Server_WeatherManager
        -- self.weather_manager = hotpot.load.Server_WeatherManager().new()

    end

    MessagingService:SubscribeAsync('pvpkillmsg',function(info)
        hotpot.event_manager:FireAll('pvpkillmsg',info)
    end)

    self:AddProcess(function()
        while true do
            self:Wait(310)
            self:CheckGuild()
            self:Wait(1)
            self:RefreshGuildWarWeekRank()
        end
    end)
end
function c:dtor()
    c.super.dtor(self)
end
---@param player Server_Player
function c:OnPlayerIn(player)
    -- self.player_play_time[player] = os.time()
    local user_id = player:GetUserId()
    --print("player ", player:GetDisplayName(), " in,user id = ", user_id)
end

function c:OnPlayerOut(player)
    --local play_time = os.time() - self.player_play_time[player]
    local user_id = player:GetUserId()
    --print("player ", player:GetDisplayName(), " out,user id = ", user_id, ",played ", play_time, "s")
end
function c:OnStart()
    if place_manager:GetIdByName('guildsence') == game.PlaceId then
        local event = hotpot:GetPath_Loop('ExpTree.Event',workspace)
        event.Event:Connect(function(str,player)
            if str == 'addExpTree' then
                ---@type Server_Player
                local obj = inst_manager:FindObject(player)
                if not obj then
                    return
                end
                obj.guild_cmp:AddExpTree()
            end
        end)
    end
end

function c:GetRank()
    self.ranks = self.ranks or {}
    self.ranks.kill = rank_manager:GetRankList('kill',false,80)
    self.ranks.time = rank_manager:GetRankList('time',false,80)
    self.ranks.purchase = rank_manager:GetRankList('purchase',false,80)
    self.ranks.party_kill = rank_manager:GetRankList('party_kill',false,80)
    self.ranks.continuous_login = rank_manager:GetRankList('continuous_login',false,80)
    self.ranks.christmas_kill = rank_manager:GetRankList('christmas_kill',false,80)
    self.ranks.christmas_time = rank_manager:GetRankList('christmas_time',false,80)
    self.ranks.christmas_friend = rank_manager:GetRankList('christmas_friend',false,80)
    self.get_rank_mark = true

    self:AddProcess(function()
        --处理黑名单
        for uid,v in pairs(black_list) do
            for i,r in ipairs(self.ranks.kill)do
                local u = tonumber(r.key)
                if u == uid then
                    table.remove(self.ranks.kill,i)
                    break
                end
            end
        end
        for uid,v in pairs(black_list) do
            for i,r in ipairs(self.ranks.time)do
                local u = tonumber(r.key)
                if u == uid then
                    table.remove(self.ranks.time,i)
                    break
                end
            end
        end
        for uid,v in pairs(black_list) do
            for i,r in ipairs(self.ranks.purchase)do
                local u = tonumber(r.key)
                if u == uid then
                    table.remove(self.ranks.purchase,i)
                    break
                end
            end
        end

        local folder = workspace:WaitForChild('RankRigs')
        local killFol = folder:WaitForChild('kill')
        killFol:SetAttribute('r1',tonumber(self.ranks.kill[1].key))
        killFol:SetAttribute('r2',tonumber(self.ranks.kill[2].key))
        killFol:SetAttribute('r3',tonumber(self.ranks.kill[3].key))

        local timeFol = folder:WaitForChild('time')
        timeFol:SetAttribute('r1',tonumber(self.ranks.time[1].key))
        timeFol:SetAttribute('r2',tonumber(self.ranks.time[2].key))
        timeFol:SetAttribute('r3',tonumber(self.ranks.time[3].key))

        local purchaseFol = folder:WaitForChild('purchase')
        purchaseFol:SetAttribute('r1',tonumber(self.ranks.purchase[1].key))
        purchaseFol:SetAttribute('r2',tonumber(self.ranks.purchase[2].key))
        purchaseFol:SetAttribute('r3',tonumber(self.ranks.purchase[3].key))

        local party_killFol = folder:WaitForChild('party_kill')
        party_killFol:SetAttribute('r1',self.ranks.party_kill[1] and tonumber(self.ranks.party_kill[1].key) or 0)
        party_killFol:SetAttribute('r2',self.ranks.party_kill[2] and tonumber(self.ranks.party_kill[2].key) or 0)
        party_killFol:SetAttribute('r3',self.ranks.party_kill[3] and tonumber(self.ranks.party_kill[3].key) or 0)

        local continuous_loginFol = folder:WaitForChild('continuous_login')
        continuous_loginFol:SetAttribute('r1',self.ranks.continuous_login[1] and tonumber(self.ranks.continuous_login[1].key) or 0)
        continuous_loginFol:SetAttribute('r2',self.ranks.continuous_login[2] and tonumber(self.ranks.continuous_login[2].key) or 0)
        continuous_loginFol:SetAttribute('r3',self.ranks.continuous_login[3] and tonumber(self.ranks.continuous_login[3].key) or 0)

        self:Wait(1)
        local obj = rank_rig.new()
        obj:SetRigModel(killFol)
        obj:SetRigModel(timeFol)
        obj:SetRigModel(purchaseFol)
        obj:SetRigModel(party_killFol)
        obj:SetRigModel(continuous_loginFol)
    end)
end

function c:SetGuildWarRank()
    self:AddProcess(function()
        self:Wait(3)
        local fol = hotpot:GetPath_Loop('Stage.guildWarRank',workspace)

        local isjoin = hotpot.pro_cfg.IsInGuildJoinTime()
		local week = hotpot.pro_cfg.GetWeek()
		if isjoin then
			week = week - 1
		end
        local list = self.guild_manager:GetWarRankByWeek(week)
        if not list then
            return
        end
        list = list:GetCurrentPage()
        for i = 1,3 do
            if list[i] then
                local guild_id = list[i].key
                local rank = i
                local uid,guild_name = self.guild_manager:GetGuildOwnerUserId(list[i].key)
                fol:SetAttribute('r'..i,tonumber(uid))

                local model = hotpot:GetPath_Loop('Rig'..i,fol)
                model:SetAttribute('guild_name',guild_name)

                ---@type ProximityPrompt
                local pro = hotpot:GetPath_Loop('Part.ProximityPrompt',model)

                pro.Enabled = true

                ---@param player Player
                pro.Triggered:Connect(function(player)
                    local obj = inst_manager:FindObject(player)
                    if obj then
                        local re,num = obj.guild_cmp:Worship(guild_id,rank)
                        hotpot.event_manager:Fire(obj,'sendWorshipResult',re,num)
                    end
        
                end)
            end
        end
        local obj = rank_rig.new()
        obj:SetRigModel(fol,true)
    end)
end

function c:CreatePartyStage(data)
    data = data.TeleportData
    -- data = {
    --     cfgid = 1,
    --     difficulty = 1,
    -- }

    if self.__createPartyStage then
        return
    end
    self.__createPartyStage = true

    local cfg_id,difficulty = data.cfgid,data.difficulty

    local model = workspace:WaitForChild('Stage'):WaitForChild('map'..cfg_id)

    ---@type Server_PartyStageObj
    local obj = hotpot.load.Server_PartyStageObj().new(model,cfg_id,difficulty)
    self.partyStageObj = obj

    return obj
end

function c:GetGuildWarWeekRank(guildId)
    if not guildId then
        return false
    end
    if GuildWarRank[guildId] then
        return GuildWarRank[guildId]
    end

    local week = hotpot.pro_cfg.GetWeek()

    if hotpot.pro_cfg.IsInGuildJoinTime() then
        week = week - 1
    end

    local str1 = guildId..'_Week_'..week
    local DS1 = DataStoreService:GetOrderedDataStore(str1)
    if not DS1 then
        return 
    end 
    local list = DS1:GetSortedAsync(false,100)
    if list then
        list = list:GetCurrentPage()
        GuildWarRank[guildId] = list
        return list
    end
    return nil
end

function c:CheckGuild()
    for guildId,list in pairs(GuildWarRank)do
        local isOnline = false
        for k,v in ipairs(list)do
            local uid = v.key
            uid = tonumber(uid)
            local player = players:GetPlayerByUserId(uid)
            if player then
                isOnline = true
                break
            end
        end
        if not isOnline then
            GuildWarRank[guildId] = nil
        end
    end
end

function c:RefreshGuildWarWeekRank()
    local week = hotpot.pro_cfg.GetWeek()
    for guildId,_ in pairs(GuildWarRank)do
        local str1 = guildId..'_Week_'..week
        local DS1 = DataStoreService:GetOrderedDataStore(str1)
        if not DS1 then
            return 
        end 
        local list = DS1:GetSortedAsync(false,100)
        if list then
            list = list:GetCurrentPage()
            GuildWarRank[guildId] = list
        end
    end
end

function c:CheckGuildWarCountDown()
    -- 1. 距离公会战 <= 1小时（不是严格等于，是剩余时间 ≤1小时）
    if hotpot.pro_cfg.IsGuildBattleIn1Hour then
        if not has_send_1hour then
            hotpot.event_manager:FireAll('ClientchannelInfo','There is still 1 hour until the guild battle begins.')
            has_send_1hour = true -- 只发一次
        end
    else
        has_send_1hour = false -- 不在倒计时区间，重置标记
    end

    -- 2. 最后 10 秒倒计时（每秒触发，但只发数字，不刷屏）
    local is_ten, time_ = hotpot.pro_cfg.IsGuildBattleIn10Seconds()
    if is_ten then
        hotpot.event_manager:FireAll(
            'ClientMsgInfo',
            string.format('Guild Battle Countdown:%ss', time_)
        )

        -- 3. 倒计时结束（刚好 0 秒时，发开始提示）
        -- 注意：你的原函数 time_ 最小是 1，所以这里判断 time_ == 1 后下一帧就是开始
        if time_ == 1 then
            -- 不使用 wait，避免卡顿
            task.spawn(function()
                -- 等 1 秒后触发开始
                task.wait(1)
                hotpot.event_manager:FireAll('ClientMsgInfo', 'The guild battle has begun.')
            end)
        end
    end
end

local function verifyJoinDiscord(username)
    local data = HttpService:JSONEncode({ username = username })

	local success, response = pcall(function()
		return HttpService:PostAsync(VERIFY_URL, data, Enum.HttpContentType.ApplicationJson)
	end)

	if not success then
		warn("请求失败: ", response)
		return false
	end

	local result = HttpService:JSONDecode(response)
	if result.success then
		-- print(username, "验证结果:", result.isMember)
		return result.isMember
	else
		warn("验证出错:", result.error)
		return false
	end
end

hotpot.function_manager:SetHandle('get_rank_data',function(_,str)
    repeat wait(1) until _G.server and _G.server.ranks[str]
    ---@type GameServer
    local server = _G.server
    return server.ranks[str] or {}
end)

hotpot.event_manager:RegistHandle('feedback',function(player,text)
    local HttpService = game:GetService("HttpService")
    local url = 'https://discord.com/api/webhooks/1430782682488639528/sgiZPhjJHxGHSHFCGRM2AnBJH5oUV8H0CzgqFykmQAHot3Luc_8OwPBXf_JKVMEdFtb-'
    local format = HttpService:JSONEncode({
        content = text,
        username = (player:GetName() .. "- [".. player.user_id .."]"),
    })

    local re =  HttpService:PostAsync(url,format)
end)

hotpot.function_manager:SetHandle('getPartyMonsterInfo',function(player)
    ---@type GameServer
    local server = _G.server

    ---@type Server_PartyStageObj
    local obj = server.partyStageObj

    local info = {
        boss_name = obj.boss_name,
        boss_hp = obj.boos_hp,
    }

    return info
end)

hotpot.event_manager:RegistHandle('partybackToLobby',function(player,jumpWait)
    local id = place_manager:GetIdByName('guildsence')
    if id == 101607896403603 then
        id = 112733956767862
    end
    if id == 115216246431329 then
        id = 140209136165491
    end
    if not jumpWait then
        wait(4)
    end
    place_manager:TeleportPlayerToPublicPlace(
        player,
        id,
        loadingGui
    )
end)

hotpot.function_manager:SetHandle('partyStageReset',function(player)
    ---@type GameServer
    local server = _G.server

    ---@type Server_PartyStageObj
    local obj = server.partyStageObj

    obj:Reset(player)

    local info = {
        boss_name = obj.boss_name,
        boss_hp = obj.boos_hp,
    }

    return true,info
end)

---@param player Server_Player
---@param text string
hotpot.function_manager:SetHandle('verifyJoinDiscord',function(player,text)
    local data = player.save_data:GetData('prop')
    if data.__real.verify_discord then
        return false,'You have already claimed the reward'
    end

    local cold = player.verify_discord_time or 0
    if os.time() - cold < 5 then
        return false,'Please wait 5 seconds'
    end
    player.verify_discord_time = os.time()

    local verify = verifyJoinDiscord(text)
    if not verify then
        return false,'Please join the Discord server'
    end

    player.save_data:Execut(function()
        data.verify_discord = true
    end)

    player.reward_cmp:AddReward(
        {
            {6,5,2},
            {3,1,1},
            {3,2,1},
            {3,3,1},
        }
    )

    return true,'Claim the reward successfully'
end)

---@param player Server_Player
hotpot.event_manager:RegistHandle('teleportToPvp',function(player)
    local id = place_manager:GetIdByName('pvpsence')
    if game.PlaceId == id then
        return
    end
    local lv = player.prop_cmp:GetLv()
    if lv < 22 then
        return
    end

    place_manager:TeleportPlayerToPublicPlace(
        player,
        id,
        loadingGui
    )
end)

---@param player Server_Player
hotpot.event_manager:RegistHandle('teleportChallenge',function(player)
    local lv = player.prop_cmp:GetLv()
    if lv < 29 then
        return
    end

    local place_id = place_manager:GetIdByName('challengesence')
    if game.PlaceId == place_id then
        return
    end
    local privatePlaceCode = place_manager:CreatePlaceCode(place_id)
    local r,e = place_manager:TeleportPlayerToPrivatePlace(
        {player},
        place_id,
        privatePlaceCode,
        nil,
        loadingGui
    )
    if not r then
        warn(e)
    end
end)

---@param player Server_Player
hotpot.function_manager:SetHandle('getMyGuildRankInfo',function(player,guild_id)
    ---@type GameServer
    local server = _G.server

    return server:GetGuildWarWeekRank(guild_id)
end)

return c
