--添加全局变量
local _G = _G
local script = script
--添加引用
local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Client_AudioManager
local audio_Manager = hotpot.load.Client_AudioManager()
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()
---@type TeleportService
local TeleportService = game:GetService('TeleportService')
---@type CodePlayer
local codePlayer = hotpot.load.CodePlayer()

local event = hotpot:GetPath_Check('ReplicatedStorage.Event')
local bgm_list = {
    'world1','world2','world3','world4','world5','world6','world7','world8','world9',
    'world10','world11','world12','world13',base = 'base',
}
local code_cfg = hotpot.config.code

---@class Client_Player:Client_PlayerObject
local c = hotpot.class.new(script, hotpot.files.Client_PlayerObject())
function c.new(player_inst)
    return c(player_inst)
end
function c:ctor(player_inst)
    c.super.ctor(self, player_inst)
    -- print(self.class, "ctor")

    ui_manager.ui_list.hud_gui:BindShowBtnClickHandle(self,self.ClickChangeBuff)

    self.prop_data = self.save_data:GetData('prop')
    self.code_data = self.save_data:GetData('code')

    self:AddProcess(function()
        if hotpot.is_mobile then
            local btn = hotpot:GetPath_Check('PlayerGui.TouchGui.TouchControlFrame.JumpButton',self.main_inst)

            local count = 10
            while count > 0 do
                count = count - 1
                if btn then
                    break
                end
                btn = hotpot:GetPath_Check('PlayerGui.TouchGui.TouchControlFrame.JumpButton',self.main_inst)
            end

            btn.Size = UDim2.fromOffset(50,50)
            btn.Position = UDim2.new(1,-65,1,-60)
        end
    end)

    --断线重连
    self:AddProcess(function()
        if game.PlaceId == 112733956767862 or game.PlaceId == 140209136165491 then
            local data = TeleportService:GetLocalPlayerTeleportData()
            if not data then
                return
            end
            local types = data.types
            if types == 'reconnect' then
                local stage = data.stage
                local cf = data.cf 
                if not stage or not cf then
                    return
                end
                self:Wait(3)
                if stage ~= 'base' then
                    self.stage_cmp:LoadStage(stage)
                end
                self:Wait(3)
                self.character:SetCFrame(cf + Vector3.new(0,1,0))
                self:Wait()
                self.character.auto = true
                self.character:StartAFK()
                ui_manager.ui_list.hud_gui:SetAfkOpen(true)
            end
        end
    end)

    self:AddProcess(function()
        self:Wait(3)
        if place_manager:GetIdByName('partysence') == game.PlaceId then
            local guid = hotpot.function_manager:Invoke('getPlayerGuid')
            self.guid = guid

            local data = TeleportService:GetLocalPlayerTeleportData()
            -- data = {
            --     cfgid = 1,
            --     difficulty = 1,
            -- }

            local model = workspace:WaitForChild('Stage'):WaitForChild('map'..data.cfgid)
            local stageObj = hotpot.load.Client_PartyStageObj().new(model)
            local monsterInfo = hotpot.function_manager:Invoke('getPartyMonsterInfo')
            stageObj:LoadMonster(monsterInfo)
            -- _G.client.partyStageObj = stageObj
            self.partyStageObj = stageObj
        end
        if place_manager:GetIdByName('pvpsence') == game.PlaceId then
            local guid = hotpot.function_manager:Invoke('getPlayerGuid')
            self.guid = guid
        end
    end)

    event.Event:Connect(function(str)
	if str == 'clientSprint' then
		self.character:Dash()
	end
end)
end
function c:dtor()
    -- print(self.class, "dtor")
    c.super.dtor(self)
end
function c:OnLogin()
    self:LoadComponent()
    self:BindSetting()
    if place_manager:GetIdByName('partysence') == game.PlaceId then
        audio_Manager:PlayGloble('party',1,100)
    else
        self:ChangeBGM(1)
    end

    ui_manager.ui_list.stats_gui:SetPlayerName(self:GetDisplayName())

    self.Weaponvalue = self.main_inst:WaitForChild('weapon')
    self.Weaponvalue.Changed:Connect(function()
        if self.character then
            self.character:LoadAnimation()
        end 
    end)
end
function c:OnLoginOver()
    self.sync_cmp:AddHandle('sync_hp',self,self.SyncHp)

    ui_manager.ui_list.hud_gui:BindInviteBtnClickHandle(self,function()
        self.invite_cmp:OpenInviteList()
    end)
end
---@param character Client_PlayerCharacter
function c:OnCharacterIn(character)
    if place_manager:GetIdByName('partysence') == game.PlaceId then
        self:AddProcess(function()
            repeat self:Wait(.2) until self.partyStageObj
            self:Wait(1)
            self.partyStageObj:PlayerIn(self)
        end)
    elseif place_manager:GetIdByName('guildsence') == game.PlaceId then
        character.root_part.CollisionGroup = 'check_character'
        ---@type GameClient
        local client = _G.client
        ---@type Client_GuildStageObj
        local guild_stage_obj = client.guild_stage_obj
        if guild_stage_obj then
            guild_stage_obj:CharacterIn(character)
        end
    elseif place_manager:GetIdByName('pvpsence') == game.PlaceId then
        ---@type GameClient
        local client = _G.client
        ---@type Client_PvpStageObj
        local pvp_stage_obj = client.pvp_stage_obj
        if pvp_stage_obj then
            pvp_stage_obj:PlayerIn(self)
        end
    elseif place_manager:GetIdByName('challengesence') == game.PlaceId then
        ---@type GameClient
        local client = _G.client
        ---@type Client_ChallengeStageObj
        local challenge_stage_obj = client.challenge_stage_obj
        if challenge_stage_obj then
            challenge_stage_obj:CharacterIn(character)
        end
    else
        self.stage_cmp:LoadStage('base')
    end
    self:AddProcess(function()
        local re = hotpot.function_manager:Invoke('get_hp')
        self:SyncHp({hp = re,max_hp = re})
    end)
    character:LoadAnimation()
    character:CreateBeam()

    delay(0.1,function()
        workspace.CurrentCamera.CameraSubject = character.humanoid
    end)
    if self.afk then
        character:ClickAutoAttackBtn()
    end
    delay(3,function()
        self.stats_cmp:Init()
    end)

    self.skill_cmp:LoadSkill()

    self:AddProcess(function()
        while true do
            self:Wait(.2)
            self.collider = character.main_inst:FindFirstChild('collider')
            if self.collider then
                break
            end
        end
    end)
end
---@param character Client_PlayerCharacter
function c:OnCharacterOut(character)
    -- print("on character out")
end

--加载component
function c:LoadComponent()
    ---@type Client_SyncComponent
    self.sync_cmp = self:AddComponent(hotpot.load.Client_SyncComponent())
    ---@type Client_PropComponent
    self.prop_cmp = self:AddComponent(hotpot.load.Client_PropComponent())
    ---@type Client_StageComponent
    self.stage_cmp = self:AddComponent(hotpot.load.Client_StageComponent())
    ---@type Client_RewardComponent
    self.reward_cmp = self:AddComponent(hotpot.load.Client_RewardComponent())
    ---@type Client_CharacterComponent
    self.character_cmp = self:AddComponent(hotpot.load.Client_CharacterComponent())
    ---@type Client_PetComponent
    self.pet_cmp = self:AddComponent(hotpot.load.Client_PetComponent())
    ---@type Client_RelicsComponent
    self.relics_cmp = self:AddComponent(hotpot.load.Client_RelicsComponent())
    ---@type Client_ShopComponent
    self.shop_cmp = self:AddComponent(hotpot.load.Client_ShopComponent())
    ---@type Client_DropComponent
    self.drop_cmp = self:AddComponent(hotpot.load.Client_DropComponent())
    ---@type Client_PartyComponent
    self.party_cmp = self:AddComponent(hotpot.load.Client_PartyComponent())
    ---@type Client_StatsComponent
    self.stats_cmp = self:AddComponent(hotpot.load.Client_StatsComponent())
    ---@type Client_HalloweenPackComponent
    self.halloween_pack_cmp = self:AddComponent(hotpot.load.Client_HalloweenPackComponent())
    ---@type Client_TitleComponent
    self.title_cmp = self:AddComponent(hotpot.load.Client_TitleComponent())
    ---@type Client_SkillComponent
    self.skill_cmp = self:AddComponent(hotpot.load.Client_SkillComponent())
    ---@type Client_OpenSkillComponent
    self.open_skill_cmp = self:AddComponent(hotpot.load.Client_OpenSkillComponent())
    ---@type Client_MountComponent
    self.mount_cmp = self:AddComponent(hotpot.load.Client_MountComponent())
    ---@type Client_GuildForgeComponent
    self.guild_forge_cmp = self:AddComponent(hotpot.load.Client_GuildForgeComponent())

    ---@type Client_BagComponent
    self.bag_cmp = self:AddComponent(hotpot.load.Client_BagComponent())
    ---@type Client_DailyComponent
    self.daily_cmp = self:AddComponent(hotpot.load.Client_DailyComponent())
    ---@type Client_OnlineComponent
    self.online_cmp = self:AddComponent(hotpot.load.Client_OnlineComponent())
    ---@type Client_FreePetComponent
    self.free_pet_cmp = self:AddComponent(hotpot.load.Client_FreePetComponent())
    ---@type Client_BattlePassComponent
    self.battle_pass_cmp = self:AddComponent(hotpot.load.Client_BattlePassComponent())
    ---@type Client_EternalComponent
    self.eternal_cmp = self:AddComponent(hotpot.load.Client_EternalComponent())
    ---@type Client_TaskComponent
    self.task_cmp = self:AddComponent(hotpot.load.Client_TaskComponent())
    ---@type Client_NewDailyComponent
    self.new_daily_cmp = self:AddComponent(hotpot.load.Client_NewDailyComponent())
    ---@type Client_ReconnectComponent
    self.reconnect_cmp = self:AddComponent(hotpot.load.Client_ReconnectComponent())
    -- ---@type Client_TeamComponent
    -- self.team_cmp = self:AddComponent(hotpot.load.Client_TeamComponent())

    if place_manager:GetIdByName('partysence') == game.PlaceId then
    elseif place_manager:GetIdByName('pvpsence') == game.PlaceId then
        ---@type Client_PvpShopComponent
        self.pvp_shop_cmp = self:AddComponent(hotpot.load.Client_PvpShopComponent())
        ---@type Client_TeamComponent
        self.team_cmp = self:AddComponent(hotpot.load.Client_TeamComponent())
        ---@type Client_PvpBuffComponent
        self.pvp_buff_cmp = self:AddComponent(hotpot.load.Client_PvpBuffComponent())
        
    elseif place_manager:GetIdByName('challengesence') == game.PlaceId then
        
    else
        ---@type Client_BagComponent
        self.bag_cmp = self:AddComponent(hotpot.load.Client_BagComponent())
        ---@type Client_GachaComponent
        self.gacha_cmp = self:AddComponent(hotpot.load.Client_GachaComponent())
        ---@type Client_TaskComponent
        self.task_cmp = self:AddComponent(hotpot.load.Client_TaskComponent())
        ---@type Client_OnlineComponent
        self.online_cmp = self:AddComponent(hotpot.load.Client_OnlineComponent())
        ---@type Client_PlayerInviteComponent
        self.invite_cmp = self:AddComponent(hotpot.load.Client_PlayerInviteComponent())
        ---@type Client_FreePetComponent
        self.free_pet_cmp = self:AddComponent(hotpot.load.Client_FreePetComponent())
        ---@type Client_BattlePassComponent
        self.battle_pass_cmp = self:AddComponent(hotpot.load.Client_BattlePassComponent())
        ---@type Client_UpgradeComponent
        self.upgrade_cmp = self:AddComponent(hotpot.load.Client_UpgradeComponent())
        ---@type Client_GuideComponent
        self.guide_cmp = self:AddComponent(hotpot.load.Client_GuideComponent())
        ---@type Client_MapShopComponent
        self.map_shop_cmp = self:AddComponent(hotpot.load.Client_MapShopComponent())
        ---@type Client_WeatherComponent
        self.weather_cmp = self:AddComponent(hotpot.load.Client_WeatherComponent())

    end

    self:AddProcess(function()
        local data = hotpot.function_manager:Invoke('waitGuildCpt')
        local gdata = self.save_data:GetData('guild')
        if data then
            gdata = data
        end
        ---@type Client_GuildComponent
        self.guild_cmp = self:AddComponent(hotpot.load.Client_GuildComponent())
    end)
end

--同步血量
function c:SyncHp(info)
    if place_manager:GetIdByName('challengesence') == game.PlaceId then
        if self.die then
            return
        end
    end
    if not info then
        return
    end
    -- self.character:PlayHpUi(info.hp,info.max_hp)

    ui_manager.ui_list.stats_gui:SetRightHp(info.max_hp)

    -- if info.source then
    --     self.character.hp_ui_cd = 3
    --     self.character.hp_ui.Enabled = true
    -- end

    if info.hp <= 0 then
        self.die = true
    else
        self.die = false
    end
end

--绑定设置按钮点击事件
function c:BindSetting()
    local data = self.save_data:GetData('setting')
    -- print(data)
    ui_manager.ui_list.setting_gui:SetMusic(not data.close_music)
    ui_manager.ui_list.setting_gui:SetSound(not data.close_sound)
    audio_Manager:SetGroupVolume('bgm',not data.close_music and 0.5 or 0)
    audio_Manager:SetGroupVolume('ui',not data.close_sound and 1 or 0)

    ui_manager.ui_list.setting_gui:BindMusicBtnClickHandle(1,function(_,open)
        -- print('music')
        audio_Manager:SetGroupVolume('bgm',open and 0.5 or 0)
        hotpot.event_manager:Fire('SettingMusic',open)
    end)
    ui_manager.ui_list.setting_gui:BindSFXBtnClickHandle(1,function(_,open)
        audio_Manager:SetGroupVolume('ui',open and 1 or 0)
        hotpot.event_manager:Fire('SettingSound',open)
    end)
    ui_manager.ui_list.setting_gui:BindPetsBtnClickHandle(self,function(player,open)
        local tempfol = game.ReplicatedStorage:FindFirstChild('OtherPlayerFol')
        local petFol = workspace:WaitForChild('PlayerPet')

        player.setting_pets = open

        if open then
            for k,v in ipairs(petFol:GetChildren())do
                if v.Name ~= self:GetName() then
                    v.Parent = tempfol
                end
            end
            self.__fol_co = petFol.ChildAdded:Connect(function(child)
                if child:IsA('Folder') then
                    child.Parent = tempfol
                end
            end)
        else
            if self.__fol_co then
                self.__fol_co:Disconnect()
                self.__fol_co = nil
            end
            if tempfol then
                for k,v in ipairs(tempfol:GetChildren())do
                    v.Parent = petFol
                end
            end
        end
    end)
    ui_manager.ui_list.setting_gui:BindCodeBtnClickHandle(self,function(_,code)
        -- print(code)
        code = string.lower(code)
        if self.code_data.list[code] then
            ui_manager.ui_list.tips_gui:TipsMessage('The code has been used','fail')
            return
        end

        local uid = self.user_id
        local tab = codePlayer.list[uid]
        if tab then
            if tab.code == code then
                local re = hotpot.function_manager:Invoke('useCode',code)
                if re then
                    ui_manager.ui_list.tips_gui:TipsMessage('Use success','success')
                    self.code_data.list[code] = true
                    local goods = tab.goods
                    for _,cfg_id in pairs(goods)do
                        self.shop_cmp:CodeBuyGoods(cfg_id)
                    end
                end
                return
            end
        end

        if not code_cfg[code] then
            ui_manager.ui_list.tips_gui:TipsMessage('The code is not exist','fail')
            return
        end

        if code == 'newgame' then
            local tim = workspace:GetServerTimeNow()
            if tim > 1759248000 then
                ui_manager.ui_list.tips_gui:TipsMessage('The code has expired','fail')
                return
            end
        end

        local re = hotpot.function_manager:Invoke('useCode',code)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage('Use success','success')
            self.code_data.list[code] = true
        end

    end)
    ui_manager.ui_list.setting_gui:BindShadowBtnClickHandle(self,function(_,open)
        local Lighting = game:GetService('Lighting')
        Lighting.GlobalShadows = open
    end)

end

function c:ChangeBGM(id)
    if self.playing_bgm then
        self.playing_bgm:Stop()
        self.playing_bgm = nil
    end

    local str = bgm_list[id]
    if str then
        local r,e = pcall(function()
            self.playing_bgm = audio_Manager:PlayGloble(str,1,-1)
        end)
        if not r then
            warn(e)
        end
    end
end

function c:SyncKillMonster(kills)
    self.kills = kills
    ui_manager.ui_list.hud_gui:SetShowProgress(math.clamp(kills / 10,0,1))
    if kills >= 10 then
        if not self.prop_data.guide_buff then
            ui_manager.ui_list.hud_gui:SetShowGuideVisible(true)
        end
    end
end

function c:ClickChangeBuff()
    if self.kills < 10 then
        return
    end
    local re = hotpot.function_manager:Invoke('useChangeBuff')
    if re then
        self.prop_data.guide_buff = true
        ui_manager.ui_list.hud_gui:SetShowGuideVisible(false)
    end
end

hotpot.event_manager:RegistHandle('KillMonster',function(player,kills)
    player:SyncKillMonster(kills)
end)

return c
