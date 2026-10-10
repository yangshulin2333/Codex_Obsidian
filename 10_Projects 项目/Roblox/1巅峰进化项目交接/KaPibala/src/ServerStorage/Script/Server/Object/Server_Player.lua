local _G = _G
local script = script
---@type ServerHotpot
local hotpot = _G.ServerHotpot
---@type Server_RankManager
local renkManager = hotpot.load.Server_RankManager()
---@type Players
local Players = game:GetService('Players')
---@type BadgeHelper
local badgeHelper = hotpot.load.BadgeHelper()
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()
---@type CodePlayer
local codePlayer = hotpot.load.CodePlayer()

local ChristmasEvent
if place_manager:GetIdByName('partysence') == game.PlaceId then
elseif place_manager:GetIdByName('guildsence') == game.PlaceId then
elseif place_manager:GetIdByName('pvpsence') == game.PlaceId then
elseif place_manager:GetIdByName('challengesence') == game.PlaceId then
else
    ChristmasEvent = hotpot:GetPath_Loop('ChristmasChest.ChristmasEvent',workspace)
end
local badgeCfg = hotpot.config.badge
local code_cfg = hotpot.config.code
local christmas = 'christmas'
local ChristmasBox = hotpot.config.ChristmasBox
local boxTotal = 0
for k,v in ipairs(ChristmasBox)do
    boxTotal = boxTotal + v.weight
end

---@class Server_Player:Server_PlayerObject
---@field main_inst Player
local c = hotpot.class.new(script, hotpot.files.Server_PlayerObject())
function c.new(player_inst)
    return c(player_inst)
end
function c:ctor(player_inst)
    c.super.ctor(self, player_inst)

    self.guid = hotpot.pro_cfg:GetGuid()
    local guidValue = Instance.new('NumberValue',self.main_inst)
    guidValue.Name = 'guid'
    guidValue.Value = self.guid

    local speedValue = Instance.new('NumberValue',self.main_inst)
    speedValue.Name = 'atkSpeed'
    speedValue.Value = 0
    self.speedValue = speedValue

    if place_manager:GetIdByName('partysence') == game.PlaceId then
        ---@type GameServer
        local server = _G.server

        local data = self.main_inst:GetJoinData()
        data = data or {}
        if data then
            server:CreatePartyStage(data)

            self:AddProcess(function()
                local obj = server.partyStageObj
                while not obj do
                    self:Wait()
                    obj = server.partyStageObj
                end
                obj:PlayerIn(self)
            end)

        end
    end

    self.kills = 0
    self.friend_num = 0

    local value = Instance.new('IntValue',self.main_inst)
    value.Name = 'friend_num'
    value.Value = 0
    self.friend_value = value

    local LVvalue = Instance.new('IntValue',self.main_inst)
    LVvalue.Name = 'LV'
    LVvalue.Value = 0
    self.LVvalue = LVvalue

    local Weaponvalue = Instance.new('IntValue',self.main_inst)
    Weaponvalue.Name = 'weapon'
    Weaponvalue.Value = 0
    self.Weaponvalue = Weaponvalue

    local character_value = Instance.new('StringValue',self.main_inst)
    character_value.Name = 'character_value'
    character_value.Value = ''
    self.character_value = character_value

    local pk_stateValue = Instance.new('BoolValue',self.main_inst)
    pk_stateValue.Name = 'pk_state'
    pk_stateValue.Value = false
    self.pk_stateValue = pk_stateValue

    local safe = Instance.new('BoolValue',self.main_inst)
    safe.Name = 'safeValue'
    safe.Value = true
    self.safeValue = safe

    self:AddUpdate(self.SaveTime,30)

    Players.PlayerAdded:Connect(function(player)
        self:RefreshFriend()
    end)
    Players.PlayerRemoving:Connect(function(player)
        self:RefreshFriend()
    end)
    if ChristmasEvent then
        ChristmasEvent.Event:Connect(function(str,plr)
            if plr == self.main_inst then
                if str == 'get_christmas_box' then
                    self:GetChristmasBox()
                end
            end
        end)
    end

    if place_manager:GetIdByName('pvpsence') == game.PlaceId then

        safe.Changed:Connect(function()
            if self.character then
                self.character:SetPKStateVisible(not safe.Value)
            end
        end)
    end
    -- print(self.class,"cotr")

    self:RefreshFriend()
end
function c:dtor()
    ---@type GameServer
    local server = _G.server

    ---@type Server_TeamManager
    local team_manager = server.team_manager
    if team_manager then
        team_manager:LeaveTeam(self)
    end


    if self.roomId then
        ---@type GameServer
        local server = _G.server

        ---@type Server_PartyManager
        local party_manager = server.party_manager

        party_manager:RemoveRoom(self,self.roomId)
    end

    if self.join_roomId then
        ---@type GameServer
        local server = _G.server

        ---@type Server_PartyManager
        local party_manager = server.party_manager

        party_manager:PlayerLeaveRoom(self,self.join_roomId)
    end

    if self.now_stage then
        self.now_stage:PlayerOut(self)
    end

    if self.pvp_stage_obj then
        self.pvp_stage_obj:PlayerOut(self)
    end

    c.super.dtor(self)
end
function c:OnLogin()
    local fol = Instance.new('Folder',self.main_inst)
    fol.Name = 'leaderstats'

    local lv = Instance.new('IntValue',fol)
    lv.Name = 'Level'

    local rebirths = Instance.new('IntValue',fol)
    rebirths.Name = 'Rebirths'

    local kills = Instance.new('IntValue',fol)
    kills.Name = 'Kills'

    self.learder_lv = lv
    self.learder_rebirths = rebirths
    self.learder_kills = kills

    self:AddProcess(function()
        local re,num = renkManager:GetRankValue('kill',self.user_id)
        if re then
            self.kills = num or 0
        else
            self.kills = 0
        end

        self.learder_kills.Value = self.kills
    end)
    self:AddProcess(function()
        local data = self.save_data:GetData('prop')
        local newPlayer = data.__real.newPlayer
        if newPlayer then
            badgeHelper:AwardBadge(self.main_inst,badgeCfg[1].badgeId)
        end

        self:CheckContinuousLogin()
    end)

    self:LoadComponent()

    self.shop_cmp:CheckGamePass()
end
function c:OnLoginOver()
    -- print(self.class,"on login over")
    self.prop_data = self.save_data:GetData('prop')
    self.code_data = self.save_data:GetData('code')
    
    self:CheckFriend()
end
---@type fun(character:Server_PlayerCharacter) @创建角色完成后执行的函数
---@param character Server_PlayerCharacter
function c:OnCharacterIn(character)
    self.character_cmp:Init()
    self.pet_cmp:Init()
    character:SetWalkSpeed(self.prop_cmp:GetSpeed())
    character:SetLv()

    if place_manager:GetIdByName('guildsence') == game.PlaceId then
        character.root_part.CollisionGroup = 'check_character'
        ---@type GameServer
        local server = _G.server
        ---@type Server_GuildStageObj
        local guildStageObj = server.guild_stage_obj
        if not guildStageObj then
            return
        end
        guildStageObj:PlayerIn(self)
    end

    if place_manager:GetIdByName('pvpsence') == game.PlaceId then
        ---@type GameServer
        local server = _G.server
        ---@type Server_PvpStageObj
        local pvpStageObj = server.pvp_stage_obj
        if not pvpStageObj then
            return
        end
        pvpStageObj:PlayerIn(self)

        self.pvp_buff_cmp:InitEff()
    end

    if place_manager:GetIdByName('challengesence') == game.PlaceId then
        ---@type GameServer
        local server = _G.server
        ---@type Server_ChallengeStageObj
        local challengeStageObj = server.challenge_stage_obj
        if not challengeStageObj then
            return
        end
        challengeStageObj:PlayerIn(self)
    end

    self.relics_cmp:RefreshEff()
end
function c:OnCharacterOut(character)
    -- print(self.class,"on character out")
end

function c:CheckFriend()
    if place_manager:GetIdByName('partysence') == game.PlaceId then
        return
    end
    local players = Players:GetPlayers()

    local function Check(player)
        if self.main_inst then
            local is_friend = self.main_inst:IsFriendsWith(player.UserId)
            if is_friend then
                local data = self.save_data:GetData('christmas').__real
                local friend_list = data.friend_list
                if not friend_list[player.UserId] then
                    local r,e = pcall(function()
                        renkManager:IncrementRankValue('christmas_friend',self.user_id,1)
                    end)
                    if r then
                        self.save_data:Execut(function()
                            data.friend_list[player.UserId] = true
                        end) 
                    end
                end
            end
        end
    end

    for _,player in ipairs(players) do
        if player.UserId ~= self.user_id then
            Check(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        Check(player)
    end)
end

--加载component
function c:LoadComponent()
    ---@type Server_SyncComponent
    self.sync_cmp = self:AddComponent(hotpot.load.Server_SyncComponent())
    ---@type Server_BagComponent
    self.bag_cmp = self:AddComponent(hotpot.load.Server_BagComponent())
    ---@type Server_PropComponent
    self.prop_cmp = self:AddComponent(hotpot.load.Server_PropComponent())
    ---@type Server_RewardComponent
    self.reward_cmp = self:AddComponent(hotpot.load.Server_RewardComponent())
    ---@type Server_StageComponent
    self.stage_cmp = self:AddComponent(hotpot.load.Server_StageComponent())
    ---@type Server_PetComponent
    self.pet_cmp = self:AddComponent(hotpot.load.Server_PetComponent())
    ---@type Server_CharacterComponent
    self.character_cmp = self:AddComponent(hotpot.load.Server_CharacterComponent())
    ---@type Server_RelicsComponent
    self.relics_cmp = self:AddComponent(hotpot.load.Server_RelicsComponent())
    ---@type Server_GachaComponent
    self.gacha_cmp = self:AddComponent(hotpot.load.Server_GachaComponent())
    ---@type Server_TaskComponent
    self.task_cmp = self:AddComponent(hotpot.load.Server_TaskComponent())
    ---@type Server_ShopComponent
    self.shop_cmp = self:AddComponent(hotpot.load.Server_ShopComponent())
    ---@type Server_DailyComponent
    self.daily_cmp = self:AddComponent(hotpot.load.Server_DailyComponent())
    ---@type Server_OnlineComponent
    self.online_cmp = self:AddComponent(hotpot.load.Server_OnlineComponent())
    ---@type Server_FreePetComponent
    self.free_pet_cmp = self:AddComponent(hotpot.load.Server_FreePetComponent())
    ---@type Server_BattlePassComponent
    self.battle_pass_cmp = self:AddComponent(hotpot.load.Server_BattlePassComponent())
    ---@type Server_UpgradeComponent
    self.upgrade_cmp = self:AddComponent(hotpot.load.Server_UpgradeComponent())
    ---@type Server_GuideComponent
    self.guide_cmp = self:AddComponent(hotpot.load.Server_GuideComponent())
    ---@type Server_ReconnectComponent
    self.reconnect_cmp = self:AddComponent(hotpot.load.Server_ReconnectComponent())
    ---@type Server_MapShopComponent
    self.map_shop_cmp = self:AddComponent(hotpot.load.Server_MapShopComponent())
    ---@type Server_EternalComponent
    self.eternal_cmp = self:AddComponent(hotpot.load.Server_EternalComponent())
    ---@type Server_TeamComponent
    self.team_cmp = self:AddComponent(hotpot.load.Server_TeamComponent())
    ---@type Server_TitleComponent
    self.title_cmp = self:AddComponent(hotpot.load.Server_TitleComponent())
    ---@type Server_StatsComponent
    self.stats_cmp = self:AddComponent(hotpot.load.Server_StatsComponent())
    ---@type Server_SkillComponent
    self.skill_cmp = self:AddComponent(hotpot.load.Server_SkillComponent())
    ---@type Server_OpenSkillComponent
    self.open_skill_cmp = self:AddComponent(hotpot.load.Server_OpenSkillComponent())
    ---@type Server_MountComponent
    self.mount_cmp = self:AddComponent(hotpot.load.Server_MountComponent())
    ---@type Server_PvpShopComponent
    self.pvp_shop_cmp = self:AddComponent(hotpot.load.Server_PvpShopComponent())
    ---@type Server_ChallengeComponent
    self.challenge_cmp = self:AddComponent(hotpot.load.Server_ChallengeComponent())
    ---@type Server_PvpBuffComponent
    self.pvp_buff_cmp = self:AddComponent(hotpot.load.Server_PvpBuffComponent())
    ---@type Server_NewDailyComponent
    self.new_daily_cmp = self:AddComponent(hotpot.load.Server_NewDailyComponent())


    self:AddProcess(function()
        ---@type Server_GuildComponent
        self.guild_cmp = self:AddComponent(hotpot.load.Server_GuildComponent())
    end)

end

function c:SaveTime(step)
    step = math.floor(step)
    renkManager:IncrementRankValue('time',self.user_id,step)
    if self.stage_cmp and self.stage_cmp.now_stage and self.stage_cmp.now_stage.id == christmas then
        renkManager:IncrementRankValue('christmas_time',self.user_id,step)
    end
end

function c:KillMonster()
    self.kills = self.kills + 1
    self.learder_kills.Value = self.kills

    self.stats_cmp:SyncKill(self.kills)
end

function c:ChangeBuff()
    if self.character and self.character.main_inst and self.character.main_inst.Parent then
        self.kills = 0
        hotpot.event_manager:Fire(self,'KillMonster',self.kills)
        self.character.main_inst:ScaleTo(2)
        self.buff_mark = true
        delay(10,function()
            if self.character and self.character.main_inst and self.character.main_inst.Parent then
                self.character.main_inst:ScaleTo(1.01)
                self.buff_mark = false
                wait(0.1)
                self.character.main_inst:ScaleTo(1) 
            end
        end)
    end
end

function c:UseChangeBuff()
    if self.kills >= 10 then
        if not self.prop_data.__real.guide_buff then
            self.save_data:Execut(function()
                self.prop_data.guide_buff = true
            end)
        end

        self:ChangeBuff()
        return true
    end
end

function c:RefreshFriend()
    local sum = 0
    pcall(function()
        for k,v in ipairs(Players:GetPlayers())do
            if v ~= self.main_inst then
                if self.main_inst and self.main_inst.Parent then
                    if self.main_inst:IsFriendsWith(v.UserId) then
                        sum = sum + 1
                    end
                end
            end
        end
    end)
    self.friend_num = sum
    self.friend_value.Value = sum
    if self.stats_cmp then
        self.stats_cmp:SyncAttack()
    end
end

function c:UseCode(code)
    code = string.lower(code)
    if self.code_data.__real.list[code] then
        return false
    end

    if code == 'newgame' then
        local tim = os.time()
        if tim > 1759248000 then
            return false
        end
    end

    self.save_data:Execut(function()
        self.code_data.list[code] = true
    end)

    local uid = self.user_id
    local tab = codePlayer.list[uid]
    if tab then
        if tab.code == code then
            local reward = tab.reward
            self.reward_cmp:AddReward(reward)
            local shop = tab.goods
            for _,cfg_id in pairs(shop)do
                self.shop_cmp:CodeBuyGoods(cfg_id)
            end
            return true
        end
    end

    local reward = code_cfg[code].reward
    self.reward_cmp:AddReward(reward)

    return true
end

function c:GetChristmasBox()
    local cfg = hotpot.pro_cfg.christmas_box

    local reward = {}
    for k,v in ipairs(cfg)do
        local random = math.random(1,10000)
        if random <= v.per then
            if v.only then
                table.insert(reward,v.list[1].reward)
            else
                local random2 = math.random(1,v.total_weight)
                for _,item in ipairs(v.list)do
                    random2 = random2 - item.weight
                    if random2 <= 0 then
                        table.insert(reward,item.reward)
                        break
                    end
                end
            end
        end
    end
    
    if self.character_cmp.data.__real.list[79] then
        for k,v in ipairs(reward)do
            if v[1] == 7 then
                table.remove(reward,k)
                break
            end
        end
    end

    self.reward_cmp:AddReward(reward)
end

--判断连续登录
function c:CheckContinuousLogin()
    local STARTTIME = 1770508800
    local INTERVAL = 86400
    local now = os.time()
    local mark = math.floor((now - STARTTIME) / INTERVAL)
    local data = self.save_data:GetData('continuous_login')
    if data.__real.mark == 0 then
        self.save_data:Execut(function()
            data.mark = mark
            data.day = 1
        end)
        renkManager:SetRankValue('continuous_login',self.user_id,function()
            return 1
        end)
    else
        if mark == data.__real.mark + 1 then
            self.save_data:Execut(function()
                data.mark = mark
                data.day = data.day + 1
            end)
            
        else
            self.save_data:Execut(function()
                data.mark = mark
                data.day = 1
            end)
        end
    end

    local day = data.__real.day or 0
    local bool,value = renkManager:GetRankValue('continuous_login',self.user_id)
    if bool then
        value = value or 0
        if day > value then
            renkManager:SetRankValue('continuous_login',self.user_id,function()
                return day
            end)
        end
    end
end

hotpot.function_manager:SetHandle('useChangeBuff',function(player)
    return player:UseChangeBuff()
end)

hotpot.function_manager:SetHandle('useCode',function(player,code)
    return player:UseCode(code)
end)

hotpot.function_manager:SetHandle('getPlayerGuid',function(player)
    return player.guid
end)

---@param player Server_Player
hotpot.function_manager:SetHandle('waitGuildCpt',function(player)
    repeat wait(.1) until player.guild_cmp

    return player.guild_cmp.data.__real
end)

---@param player Server_Player
hotpot.event_manager:RegistHandle('SettingMusic',function(player,open)
    local data = player.save_data:GetData('setting')
    player.save_data:Execut(function()
        data.close_music = not open
    end)
end)

---@param player Server_Player
hotpot.event_manager:RegistHandle('SettingSound',function(player,open)
    local data = player.save_data:GetData('setting')
    player.save_data:Execut(function()
        data.close_sound = not open
    end)
end)

return c
