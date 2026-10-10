local hotpot = _G.ClientHotpot
---@type Client_PartyMonsterObj
local monster_obj = hotpot.load.Client_PartyMonsterObj()
---@type InstanceManager
local inst_manager = hotpot.load.InstanceManager()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local tween_helper = hotpot.load.TweenHelper()
---@type RayManager
local RayManager = hotpot.load.RayManager()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()
---@type Players
local players = game:GetService('Players')

local monster_fol = hotpot:GetPath_Loop('monster',_G.Resource)
local dmgUi = hotpot:GetPath_Loop('pfb.dmgUi',_G.Resource)
local monster_cfg = hotpot.config.PartyMonster
local gacha_cfg = hotpot.config.gacha
local pet_cfg = hotpot.config.pet
local gacha_ui = hotpot:GetPath_Loop('pfb.gachaUi',_G.Resource)
local upgrade_cfg = hotpot.config.upgrade
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)
local vote_list = {}

---@class Client_PartyStageObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model)
    return c(model)
end
function c:ctor(model)
    c.super.ctor(self,model)

    self:Init()

    ui_manager.ui_list.party_over_gui:BindBtnClickHandle(self,self.ClickBackToLobby)
    ui_manager.ui_list.party_over_gui:BindAgainBtnClickHandle(self,self.ClickReset)
end

function c:dtor()
    if self.main_inst then
        self.main_inst:Destroy()
    end
    c.super.dtor(self)
end

function c:Init()
    ---@type table<Client_Player,boolean>
    self.player_list = {}
    ---@type table<part,Client_MonsterObj>
    self.monster_list = {}
    ---@type table<number,Client_MonsterObj>
    self.guid_to_monster = {}

    self.monster_fol = self.main_inst:WaitForChild('monster')
    self.spawn_part = self.main_inst:WaitForChild('spawn')

    self.spawnFol = self.main_inst:WaitForChild('spawns')
    self.spawn_list = {}
    for k,v in ipairs(self.spawnFol:GetChildren())do
        v.Transparency = 1
        self.spawn_list[tonumber(v.Name)] = v
    end
end

--加载怪物信息
function c:LoadMonster(data)
    ui_manager.ui_list.hud_gui:SetBossName(data.boss_name)
    ui_manager.ui_list.hud_gui:SetBossProgress(data.boss_hp,data.boss_hp)
end

--玩家进入
---@param player Client_Player
function c:PlayerIn(player)
    self.player_list[player] = true

    self.player = player

    player.now_stage = self

    self:Sync(player)

    ---@type Server_PlayerCharacter
    local character = player.character

    local cf = self.spawn_part.CFrame

    character:SetCFrame(cf + Vector3.new(0,4,0))
end

--玩家退出
---@param player Client_Player
function c:PlayerOut(player)
    self.player_list[player] = nil

    player.now_stage = nil
end

--同步
---@param player Client_Player
function c:Sync(player)
    player:AddProcess(function()
        while true do
            player:Wait(1)
            if player.sync_cmp then
                break
            end
        end

        player.sync_cmp:AddHandle('party_monster_be_dmg',self,self.MonsterBeDamage)
        player.sync_cmp:AddHandle('party_monster_die',self,self.MonsterDie)
        player.sync_cmp:AddHandle('party_monster_atk_player',self,self.MonsterAttackPlayer)
        player.sync_cmp:AddHandle('party_monster_move',self,self.MonsterMove)
        player.sync_cmp:AddHandle('party_boss_recover',self,self.MonsterRecover)
    end)
end

--玩家攻击
---@param player Client_Player
function c:PlayerAttack(root,player)
    player.sync_cmp:Add('party_player_attack_monster',{
        player_guid = player.guid,
    })
end

--玩家技能
function c:PlayerSkill(player,skill_id,slot,root)
    local model = root.Parent

    if not model then
        return
    end

    local guid = model:GetAttribute('guid')

    player.sync_cmp:Add('party_player_skill_monster',{
        player_guid = player.guid,
        stage_id = self.id,
        monster_guid = guid,
        skill_id = skill_id,
        slot = slot,
        root = root,
    })
end

--怪物受伤
function c:MonsterBeDamage(info)
    self:PlayDmg(info.pos,info.dmg)
    if info.is_boss then
        ui_manager.ui_list.hud_gui:SetBossProgress(info.now_hp,info.max_hp)
    end
    pcall(function()
        audioManager:PlayGloble('hit')
    end)
end

--怪物恢复
function c:MonsterRecover(info)
    ui_manager.ui_list.hud_gui:SetBossProgress(info.hp,info.max_hp)
end

--怪物死亡
function c:MonsterDie(info)
    local list = info.dmg_list
    self:AddProcess(function()
        self:Wait(.1)
        local monster_guid = info.monster_guid
        local obj = self.guid_to_monster[monster_guid]
        if obj then
            obj.die = true
            if obj.cfg.is_boss then
                ui_manager.ui_list.hud_gui:SetBossPanelVisible(false)
                self.boss_obj = nil
            end
            obj:PlayHpUi(0,obj.max_hp)
            self.guid_to_monster[monster_guid] = nil
            self.monster_list[obj.part] = nil
            obj:dtor()
        end
    end)
end

--怪物移动
function c:MonsterMove(info)
    local monster_guid = info.guid
    local obj = self.guid_to_monster[monster_guid]
    if not obj then
        return
    end
    local pos = info.pos
    obj:Move(pos)
end

--播放伤害动画
function c:PlayDmg(pos,dmg)
    local part = hotpot:CloneInst_Loop(dmgUi)
    part.Position = pos
    part.Parent = workspace
    
    part.BillboardGui.info.Text = '-'.. big_number:ToString(dmg)
    part.BillboardGui.Size = UDim2.fromScale(0,0)

    tween_helper:PlayTween(
        part,
        TweenInfo.new(0.2),
        {Position = pos + Vector3.new(0,5,0)},
        function()
            wait(1)
            part:Destroy()
        end
    )
    tween_helper:PlayTween(
        part.BillboardGui,
        TweenInfo.new(0.2),
        {Size = UDim2.fromScale(4,1.3)}
    )
end

--怪物攻击玩家
function c:MonsterAttackPlayer(info)
    self:PlayDmg(info.pos,info.dmg)
end

--销毁怪物
function c:DestroyMonster(info)
    local monster_guid = info.monster_guid
    local obj = self.guid_to_monster[monster_guid]
    if obj then
        self.guid_to_monster[monster_guid] = nil
        self.monster_list[obj.part] = nil
        obj:dtor()
    end
end

--boss出现
function c:BossAppear()
    ui_manager.ui_list.hud_gui:SetBossPanelVisible(true)
    ui_manager.ui_list.hud_gui:SetCDFramePos(UDim2.fromScale(0.5,0.11))
end

--同步时间
function c:SyncTime(state,time_)
    ui_manager.ui_list.hud_gui:SetCDFrameVisible(true)
    if state == 1 then
        ui_manager.ui_list.hud_gui:SetCDTips('Starting:'..time_)
    elseif state == 2 then
        ui_manager.ui_list.hud_gui:SetCDTips('Countdown:'..time_..'s')
    end
end

--死亡失败
---@param player Client_Player
function c:DieFail(player,dmg,num)
    ui_manager.ui_list.hud_gui:SetHeartFrameCount(0)
    local r,e = pcall(function()
        return player:GetTumbnail('HeadShot','Size100x100')
    end)
    if not r then
        e = ''
    end
    ui_manager.ui_list.party_over_gui:SetInfo({
        success = false,
        dmg = dmg,
        kill = num,
        lv = player.prop_cmp:GetLv(),
        name = player:GetDisplayName(),
        icon = e,
    })
    ui_manager.ui_list.party_over_gui:SetAgainBtnVisible(false)
    ui_manager.ui_list.party_over_gui:Show()
    ui_manager.ui_list.hud_gui:Hide()
    self.__uiShow = true
end

--胜利
function c:Success(player,info)
    local r,e = pcall(function()
        return player:GetTumbnail('HeadShot','Size100x100')
    end)
    if not r then
        e = ''
    end

    local reward = info.reward
    local list = {}
    for k,v in ipairs(reward)do
        table.insert(list,{
            icon = player.reward_cmp:GetIcon(v),
            num = v[3],
        })
    end
    ui_manager.ui_list.party_over_gui:ClearInfo()
    ui_manager.ui_list.party_over_gui:SetInfo({
        success = true,
        dmg = info.dmg,
        kill = info.kill,
        time = info.time,
        lv = player.prop_cmp:GetLv(),
        name = player:GetDisplayName(),
        icon = e,
        reward = list,
    })
    ui_manager.ui_list.party_over_gui:SetAgainBtnVisible(true)
    ui_manager.ui_list.party_over_gui:Show()
    ui_manager.ui_list.hud_gui:SetBossPanelVisible(false)
end

--失败
function c:Fail(player,info)
    if self.__uiShow then
        return
    end
    local r,e = pcall(function()
        return player:GetTumbnail('HeadShot','Size100x100')
    end)
    if not r then
        e = ''
    end

    ui_manager.ui_list.party_over_gui:SetInfo({
        success = false,
        dmg = info.dmg,
        kill = info.kill,
        time = info.time,
        lv = player.prop_cmp:GetLv(),
        name = player:GetDisplayName(),
        icon = e,
    })
    ui_manager.ui_list.party_over_gui:SetAgainBtnVisible(false)
    ui_manager.ui_list.party_over_gui:Show()
    ui_manager.ui_list.hud_gui:Hide()
end

--点击返回大厅
function c:ClickBackToLobby()
    hotpot.event_manager:Fire('partybackToLobby')
    self:AddProcess(function()
        local count = 10
        while true do
            ui_manager.ui_list.tips_gui:TipsMessage('Teleporting....')
            self:Wait(.8)
            count = count - 1
            if count <= 0 then
                break
            end
        end
    end)
end

--点击重置
function c:ClickReset()
    local re,info = hotpot.function_manager:Invoke('partyStageReset')
    if re then
        -- ui_manager.ui_list.hud_gui:SetHeartFrameCount(3)
        -- ui_manager.ui_list.party_over_gui:Hide()
        -- ui_manager.ui_list.party_over_gui:ClearInfo()
        -- self:LoadMonster(info)
        -- ui_manager.ui_list.hud_gui:SetBossPanelVisible(false)
        -- ---@type Server_PlayerCharacter
        -- local character = self.player.character
        -- local cf = self.spawn_part.CFrame
        -- character:SetCFrame(cf + Vector3.new(0,4,0)) 
    end
end

---@param player Client_Player
hotpot.event_manager:RegistHandle('partyStageUpdate',function(player,state,time_)
    ---@type Client_PartyStageObj
    local obj = player.partyStageObj

    if not obj then
        return
    end

    obj:SyncTime(state,time_)
end)

---@param player Client_Player
hotpot.event_manager:RegistHandle('partyStageBossAppear',function(player)
    ---@type Client_PartyStageObj
    local obj = player.partyStageObj

    if not obj then
        return
    end

    obj:BossAppear()
end)

---@param player Client_Player
hotpot.event_manager:RegistHandle('party_fail_die',function(player,num,dmg)
    ---@type Client_PartyStageObj
    local obj = player.partyStageObj

    obj:DieFail(player,dmg,num)
end)

---@param player Client_Player
hotpot.event_manager:RegistHandle('party_stage_win',function(player,info)
    ---@type Client_PartyStageObj
    local obj = player.partyStageObj

    obj:Success(player,info)
end)

---@param player Client_Player
hotpot.event_manager:RegistHandle('party_stage_lose',function(player,info)
    ---@type Client_PartyStageObj
    local obj = player.partyStageObj

    obj:Fail(player,info)
end)

---@param player Client_Player
hotpot.event_manager:RegistHandle('partyStageOverUpdate',function(player,cd,list)
    for _,uid in ipairs(list)do
        if not vote_list[uid] then
            local r,e = pcall(function()
                return players:GetUserThumbnailAsync(uid,'HeadShot','Size100x100')
            end)
            if not r then
                e = ''
            end
            ui_manager.ui_list.party_over_gui:AddItemInAgainFrame(uid,e)
        end
        vote_list[uid] = true
    end
    ui_manager.ui_list.party_over_gui:SetCD(cd)
    ui_manager.ui_list.party_over_gui:SetVoteTipsVisible(true)
end)

return c