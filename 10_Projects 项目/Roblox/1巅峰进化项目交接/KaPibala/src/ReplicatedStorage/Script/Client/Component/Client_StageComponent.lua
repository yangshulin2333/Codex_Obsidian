local hotpot = _G.ClientHotpot
---@type Client_StageObj
local stage_obj = hotpot.load.Client_StageObj()
---@type ContextActionService
local ContextActionService = game:GetService('ContextActionService')
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Client_TranstionsAnimation
local TranstionsAnimation = hotpot.load.Client_TranstionsAnimation()
---@type Players
local Players = game:GetService('Players')
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local stage_cfg = hotpot.config.stage
local relics_cfg = hotpot.config.relics
local sky_fol = hotpot:GetPath_Loop('Sky',_G.Resource)
local img1 = 'rbxassetid://96113255686788'
local img2 = 'rbxassetid://93280845336671'
local FREEPOTIONCD = 7200
local STARTFREEPOTION = 1763942400
local normalRewards = {
    {icon = 'rbxassetid://77799429334242',quality = 2,},
    {icon = 'rbxassetid://74187092935619',quality = 1,},
    {icon = 'rbxassetid://134804226826116',quality = 3,},
}

---@class Client_StageComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('stage')
    ui_manager.ui_list.teleport_gui:BindItemBtnClickHandle(self,self.ClickTeleport)

    self.free_potion_data = self.parent.save_data:GetData('free_potion')
    
    local r,e = pcall(function()
        self:LoadOtherPlayer()
    end)
    if not r then
        warn(e)
    end
    self:InitTeleportGui()
    self:Sync()
    self:AddUpdate(self.UpdateFreePotion,1)

    ---@type Folder
    local fol = workspace.Pumpkin
    fol:GetAttributeChangedSignal('stage'):Connect(function()
        local bossStage = workspace.Pumpkin:GetAttribute('stage')
        local stage = self.now_stage and self.now_stage.id or 'base'
        if stage == bossStage then
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(true)
        else
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(false)
        end
    end)
end

function c:LoadOtherPlayer()
    self.other_player_list = {}

    ---@param self Client_StageComponent
    ---@param player Player
    local function Load(self,player)
        local time_len = 10
        local character = nil
        while true do
            time_len = time_len - self:Wait(.5)
            character = player.Character
            if character then
                break
            end
        end
        if not character then
            return
        end
        local character_obj = hotpot.load.CharacterObject().new(character)
        local skill_list = {}
        local fol = player:FindFirstChild('Skill')
        if not fol then
            time_len = 10
            while true do
                time_len = time_len - self:Wait(1)
                fol = player:FindFirstChild('Skill')
                if fol then
                    break
                end
                if time_len <= 0 then
                    break
                end
            end
        end
        if not fol then
            return
        end
        for solt,intValue in pairs(fol:GetChildren())do
            if intValue:IsA('IntValue') then
                local obj = hotpot.load.Client_Skill_1().new(character_obj)
                obj.other_player = true
                skill_list[solt] = obj
            end
        end
        character_obj.skill_list = skill_list
        self.other_player_list[player] = character_obj
        -- print(player,'加载完成')

        fol.ChildRemoved:Connect(function(child)
            if child:IsA('IntValue') then
                if skill_list[child.Name] then
                    skill_list[child.Name]:dtor()
                    skill_list[child.Name] = nil
                end
            end
        end)
        fol.ChildAdded:Connect(function(child)
            if child:IsA('IntValue') then
                -- skill_list[child.Name] = hotpot.load.Client_Skill_1().new(character_obj)
                local obj = hotpot.load.Client_Skill_1().new(character_obj)
                obj.other_player = true
                skill_list[child.Name] = obj
            end
        end)
    end

    local function UnLoad(self,player)
        local character_obj = self.other_player_list[player]
        if not character_obj then
            return
        end
        local skill_list = character_obj.skill_list
        if skill_list then
            for _,skill in pairs(skill_list)do
                skill:dtor()
            end
        end
        if character_obj then
            character_obj:dtor()
        end
    end

    local player_list = Players:GetPlayers()
    for _,player in ipairs(player_list)do
        if player ~= Players.LocalPlayer then
            self:AddProcess(Load,player)
        end
    end

    Players.PlayerRemoving:Connect(function(player)
        UnLoad(self,player)
        self.other_player_list[player] = nil
    end)
    Players.PlayerAdded:Connect(function(player)
        self:AddProcess(Load,player)
    end)
end

function c:OtherPlayerUseSkill(info)
    local player = info.player
    local solt = info.solt
    local character_obj = self.other_player_list[player]
    if not character_obj then
        return
    end
    local skill = character_obj.skill_list[solt]
    if not skill then
        return
    end
    skill:Start()
end

function c:InitTeleportGui()
    ui_manager.ui_list.teleport_gui:AddItemInScroll(
        'base',
        'rbxassetid://101232155883191',
        'Main Scene'
    )
    ui_manager.ui_list.teleport_gui:SetItemTopVisible(
        'base',false
    )

    for k,v in ipairs(stage_cfg)do
        ui_manager.ui_list.teleport_gui:AddItemInScroll(
            v.id,
            v.icon,
            v.name
        )
        ui_manager.ui_list.teleport_gui:SetItemTopVisible(
            v.id,not self.data.list[v.id]
        )
    end

    ui_manager.ui_list.hud_gui:SetPartyBtnVisible(self.data.list[3])
end

function c:ClickTeleport(id)
    if place_manager:GetIdByName('pvpsence') == game.PlaceId then
        --ui_manager.ui_list.tips_gui:TipsMessage('PvP scene cannot use teleport','fail')
        return
    end

    if id == 'base' then
        TranstionsAnimation:PlayTransitionsAnimation(1,function()
            self:LoadStage(id)
        end)
        ui_manager.ui_list.teleport_gui:Hide()
        return
    end

    if not self.data.list[id] then
        return
    end
    ui_manager.ui_list.teleport_gui:Hide()
    if self.now_stage.id == id then
        ui_manager.ui_list.tips_gui:TipsMessage('You are already in the scene','fail')
        return
    end

    TranstionsAnimation:PlayTransitionsAnimation(1,function()
        self:LoadStage(id)
    end)
end

function c:LoadStage(id)
    local list = self:Invoke('in_stage',id)
    if list then   
        if id == 'base' then
            self:LoadBase(list)
            return
        end
        self.parent:ChangeBGM(id)
        local old = self.now_stage
        self.parent.guid = list.player_guid
        local name = stage_cfg[id].model
        local model = hotpot:GetPath_Loop('Stage.'..name,_G.Resource)
        model = hotpot:CloneInst_Loop(model)
        model.Parent = workspace.Stage
        local obj = stage_obj.new(model,id,self)
        self.now_stage = obj
        obj:PlayerIn(self.parent)
        obj:LoadMonster(list)
        obj:LoadGacha(self.parent)
        obj:LoadTeleport(self.parent)
        obj:LoadFunction(self.parent)
        obj:LoadUpgrade(self.parent)
        obj:LoadStageGamepass(self.parent)
        obj:LoadRank()

        self:RefreshCD()

        if old then
            old:dtor()
        end

        self:LoadSkyBox(id)
        obj:ResetPet(self.parent)

        self.parent.prop_cmp:CheckReborn()

        local fol = workspace.Pumpkin
        local bossStage = fol:GetAttribute('stage')
        if bossStage == id then
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(true)
        else
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(false)
        end
    end
end

--刷新倒计时
function c:RefreshCD()
    self.parent.prop_cmp:StartUpdate()
    self.parent.relics_cmp:StartUpdate()
end

--加载天空盒
function c:LoadSkyBox(id)
    local Lighting = game:GetService('Lighting')
    local fol = sky_fol:FindFirstChild(id)
    if not fol then
        fol = sky_fol:FindFirstChild('1')
    end
    Lighting:ClearAllChildren()
    for k,v in pairs(fol.child:GetChildren())do
        local clone = v:Clone()
        clone.Parent = Lighting
    end
    local args = require(fol.args)

    for key,value in pairs(args)do
        Lighting[key] = value
    end
end

function c:Sync()
    self.parent.sync_cmp:AddHandle('monster_be_dmg',self,self.MonsterBeDamage)
    self.parent.sync_cmp:AddHandle('monster_die',self,self.MonsterDie)
    self.parent.sync_cmp:AddHandle('monster_reborn',self,self.MonsterReborn)
    self.parent.sync_cmp:AddHandle('monster_atk_player',self,self.MonsterAttackPlayer)
    self.parent.sync_cmp:AddHandle('monster_move',self,self.MonsterMove)
    self.parent.sync_cmp:AddHandle('monster_recover',self,self.MonsterRecover)
    self.parent.sync_cmp:AddHandle('createWeatherMonster',self,self.CreateRandomMonster)
    self.parent.sync_cmp:AddHandle('monster_destroy',self,self.DestroyMonster)
    self.parent.sync_cmp:AddHandle('playerUseSkill',self,self.OtherPlayerUseSkill)
end

--怪物死亡
function c:MonsterDie(info)
    local stage_id = info.stage_id
    if self.now_stage.id ~= stage_id then
        return
    end
    self.now_stage:MonsterDie(info)

    if info.dmg_list and info.dmg_list[self.parent.guid] then
        self.parent.now_kill_monster_guid = info.monster_guid
    end
end

--怪物移动
function c:MonsterMove(info)
    local stage_id = info.stage_id
    if not self.now_stage then
        return
    end
    if self.now_stage.id ~= stage_id then
        return
    end
    self.now_stage:MonsterMove(info)
end

--怪物受伤
function c:MonsterBeDamage(info)
    local stage_id = info.stage_id
    if self.now_stage.id ~= stage_id then
        return
    end
    if info.player_guid == self.parent.guid then
        info.owner = true
    end
    self.now_stage:MonsterBeDamage(info)
end

--怪物复活
function c:MonsterReborn(info)
    local stage_id = info.stage_id
    if self.now_stage.id ~= stage_id then
        return
    end
    self.now_stage:MonsterReborn(info)
end

--怪物攻击玩家
function c:MonsterAttackPlayer(info)
    local stage_id = info.stage_id
    if self.now_stage.id ~= stage_id then
        return
    end
    self.now_stage:MonsterAttackPlayer(info)
end

--怪物恢复
function c:MonsterRecover(info)
    local stage_id = info.stage_id
    if self.now_stage.id ~= stage_id then
        return
    end
    self.now_stage:MonsterRecover(info)
end

--销毁怪物
function c:DestroyMonster(info)
    local stage_id = info.stage_id
    if self.now_stage.id ~= stage_id then
        return
    end
    self.now_stage:DestroyMonster(info)
end

--创建随机怪物
function c:CreateRandomMonster(info)
    local stage_id = info.stage_id
    if self.now_stage.id ~= stage_id then
        return
    end
    self.now_stage:CreateRandomMonster(info)
end

--进入boss区域
function c:InBossArea()
    self.parent.in_boss_area = true
    if self.now_stage.boss_obj then
        ui_manager.ui_list.hud_gui:SetBossPanelVisible(true)
        ui_manager.ui_list.hud_gui:RemoveAllBossItem()
        for k,v in ipairs(normalRewards)do
            ui_manager.ui_list.hud_gui:AddItemInBossRewards(v.icon,v.quality)
        end
        ui_manager.ui_list.hud_gui:AddItemInBossRewards('rbxassetid://101543528273589',4)

        local stage_id = self.now_stage.id
        local cfg = hotpot.config.stageDrop[stage_id]
        if cfg then
            for k,v in ipairs(cfg.boss_id)do
                ui_manager.ui_list.hud_gui:AddItemInBossRewards(relics_cfg[v].icon,relics_cfg[v].quality)
            end
        end
    end
end

--退出boss区域
function c:OutBossArea()
    self.parent.in_boss_area = false
    ui_manager.ui_list.hud_gui:SetBossPanelVisible(false)
end

--传送关卡
function c:Teleport(id)
    if self.data.list[id] then
        TranstionsAnimation:PlayTransitionsAnimation(1,function()
            self:LoadStage(id)
        end)
    else
        local lv = self.parent.prop_cmp:GetLv()
        local need = stage_cfg[id].need
    
        
        if lv < need then
            ui_manager.ui_list.tips_gui:TipsMessage('Not Enough Lv','fail')
            return false
        end

        local re = self:Invoke('unlockStage',id)
        if re then
            self.data.list[id] = true
            self.parent.shop_cmp:RefreshGold()
            self.parent.task_cmp:RefreshReward()
            ui_manager.ui_list.teleport_gui:SetItemTopVisible(id,false)
            ui_manager.ui_list.hud_gui:SetPartyBtnVisible(self.data.list[3])
            ui_manager.ui_list.hud_gui:SetPartyRedVisible(true)
            ui_manager.ui_list.hud_gui:SetOpenRedVisible(true)
            TranstionsAnimation:PlayTransitionsAnimation(1,function()
                self:LoadStage(id)
            end)
        end
    end
end

--传送圣诞
function c:TeleportChristmas()
    TranstionsAnimation:PlayTransitionsAnimation(1,function()
        local list = self:Invoke('in_stage','christmas')
        if list then   
            self.parent:ChangeBGM('christmas')
            local old = self.now_stage
            self.parent.guid = list.player_guid
            local model = hotpot:GetPath_Loop('Stage.ChristmasStage',_G.Resource)
            model = hotpot:CloneInst_Loop(model)
            model.Parent = workspace.Stage
            local obj = stage_obj.new(model,'christmas',self)
            self.now_stage = obj
            obj:PlayerIn(self.parent)
            obj:LoadMonster(list)
            obj:LoadChristmasArea(self.parent)
            obj:LoadChristmasRank()
            -- obj:LoadGacha(self.parent)
            -- obj:LoadTeleport(self.parent)
            -- obj:LoadFunction(self.parent)
            -- obj:LoadUpgrade(self.parent)
            -- obj:LoadStageGamepass(self.parent)
            -- obj:LoadRank()

            -- self:RefreshCD()

            if old then
                old:dtor()
            end

            self:LoadSkyBox('christmas')

            self.parent.prop_cmp:CheckReborn()
        end
    end)
end

function c:LoadBase(list)
    self.parent:ChangeBGM('base')
    local old = self.now_stage
    self.parent.guid = list.player_guid
    local model = hotpot:GetPath_Loop('Stage.baseStage',_G.Resource)
    model = hotpot:CloneInst_Loop(model)
    model.Parent = workspace.Stage
    local obj = stage_obj.new(model,'base',self)
    self.now_stage = obj
    obj:PlayerIn(self.parent)
    obj:LoadFunction(self.parent)
    obj:LoadTeleport(self.parent)
    obj:LoadRank()
    obj:HideAllPet()

    self:AddProcess(function()
        self:Wait(2)
        self.parent.guide_cmp:GuideSkill()
    end)

    self:LoadSkyBox(1)

    if old then
        old:dtor()
    end
end

--获取已解锁的最大关卡
function c:GetMaxStage()
    return #self.data.list
end

function c:DropGems(guid)
    local stage = self.now_stage
    if not self.now_stage then
        return
    end
    local obj = stage.guid_to_monster[guid]
    if not obj then
        return
    end
    local pos = obj:GetPosition()
    self.parent.drop_cmp:PlayDrop('Gems',pos)
end

function c:DropGold(guid)
    local stage = self.now_stage
    if not self.now_stage then
        return
    end
    local obj = stage.guid_to_monster[guid]
    if not obj then
        return
    end
    local pos = obj:GetPosition()
    self.parent.drop_cmp:PlayDrop('Coins',pos)
    self.parent.drop_cmp:PlayDrop('Exp',pos)
end

function c:LockStage(id)
    self.data.list[id] = nil
    ui_manager.ui_list.teleport_gui:SetItemTopVisible(id,true)
end

function c:CreatePumpkinBoss(bossNum)
    if bossNum == 1 then
        ui_manager.ui_list.hud_gui:SetPumpkinNum(hotpot.pro_cfg.PumpkinBossHp,hotpot.pro_cfg.PumpkinBossHp)
        ui_manager.ui_list.hud_gui:SetPumpkinBuffImg('rbxassetid://93940333371909')

        local stage = self.now_stage.id
        if stage == 1 then
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(true)
        else
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(false)
        end

        ui_manager.ui_list.hud_gui:SetPumpkinFrameName('Pumpkin Boss','rbxassetid://93940333371909')

        ui_manager.ui_list.hud_gui:RemoveAllPumpkinItem()
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://109552623746167',4)
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://97950625618717',4)
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://105112106242077',4)

    elseif bossNum == 2 then
        -- local cfg = hotpot.config.Weather[6]
        ui_manager.ui_list.hud_gui:SetPumpkinNum(hotpot.pro_cfg.PumpkinBossHp,hotpot.pro_cfg.PumpkinBossHp)
        ui_manager.ui_list.hud_gui:SetPumpkinBuffImg('rbxassetid://113427139231510')
        local stage = self.now_stage.id
        if stage == 1 then
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(true)
        else
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(false)
        end
        ui_manager.ui_list.hud_gui:SetPumpkinFrameName('Leo','rbxassetid://113427139231510')
        ui_manager.ui_list.hud_gui:RemoveAllPumpkinItem()
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://131369362945190',4)
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://115046552923805',4)
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://77040878668236',4)
    elseif bossNum == 3 then
        ui_manager.ui_list.hud_gui:SetPumpkinNum(hotpot.pro_cfg.PumpkinBossHp,hotpot.pro_cfg.PumpkinBossHp)
        ui_manager.ui_list.hud_gui:SetPumpkinBuffImg('rbxassetid://97750089436678')
        local stage = self.now_stage.id
        if stage == 1 then
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(true)
        else
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(false)
        end
        ui_manager.ui_list.hud_gui:SetPumpkinFrameName('Elephant','rbxassetid://97750089436678')
        ui_manager.ui_list.hud_gui:RemoveAllPumpkinItem()
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://106234670761768',1)
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://130894823201172',2)
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://105794436522355',3)
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://135704525829108',4)
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://126293728215195',5)
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://77352085838107',7)
        ui_manager.ui_list.hud_gui:AddItemInPumpkinRewards('rbxassetid://135210716417270',7)
    end
    
end

function c:SyncPumpkinHP(now,max,pos)
    ui_manager.ui_list.hud_gui:SetPumpkinNum(now,max)
    pos = Vector3.new(
        pos.x + math.random(-10,10) / 3,
        pos.y,
        pos.z + math.random(-10,10) / 3
    )
    if self.now_stage then
        self.now_stage:PlayDmg(pos,1)
    end
end

function c:PumpkinBossDie()
    ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(false)
    ui_manager.ui_list.hud_gui:SetPumpkinBuffImg(img2)
end

function c:SyncPumpkinBuffCd(cd,isboss,bossNum)
    ui_manager.ui_list.hud_gui:SetPumpkinBuffText(cd)
    if not isboss then
        ui_manager.ui_list.hud_gui:SetPumpkinPanelItemCD(1,0)
        ui_manager.ui_list.hud_gui:SetPumpkinPanelItemCD(2,0)
        ui_manager.ui_list.hud_gui:SetPumpkinPanelItemCD(3,0)
        if cd <= 10 and cd >= 0 then
            ui_manager.ui_list.tips_gui:TipsMessage('Pumpkin Boss Start In '..cd..'s','success')
        end
    else
        if bossNum == 1 then
            ui_manager.ui_list.hud_gui:SetPumpkinFrameName('Pumpkin Boss','rbxassetid://93940333371909')
            ui_manager.ui_list.hud_gui:SetPumpkinPanelItemCD(1,cd)
            ui_manager.ui_list.hud_gui:SetPumpkinBuffImg('rbxassetid://93940333371909')
        elseif bossNum == 2 then
            ui_manager.ui_list.hud_gui:SetPumpkinFrameName('Leo','rbxassetid://113427139231510')
            ui_manager.ui_list.hud_gui:SetPumpkinPanelItemCD(2,cd)
            ui_manager.ui_list.hud_gui:SetPumpkinBuffImg('rbxassetid://113427139231510')
        elseif bossNum == 3 then
            ui_manager.ui_list.hud_gui:SetPumpkinFrameName('Elephant','rbxassetid://97750089436678')
            ui_manager.ui_list.hud_gui:SetPumpkinPanelItemCD(3,cd)
            ui_manager.ui_list.hud_gui:SetPumpkinBuffImg('rbxassetid://97750089436678')
        end

        local stage = self.now_stage and self.now_stage.id or 'base'
        local fol = workspace.Pumpkin
        local bossStage = fol:GetAttribute('stage')
        if bossStage == stage then
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(true)
        else
            ui_manager.ui_list.hud_gui:SetPumpkinFrameVisible(false)
        end
    end
    ui_manager.ui_list.hud_gui:SetPumpkinPanelCD(cd)
end

function c:SyncPumpkinDamage(pos)
    self.now_stage:PlayDmg(pos,1)
end

function c:SyncWeatherHP(now,max,pos)
    ui_manager.ui_list.hud_gui:SetWeatherHPProgress(now,max)
    pos = Vector3.new(
        pos.x + math.random(-10,10) / 3,
        pos.y,
        pos.z + math.random(-10,10) / 3
    )
    if self.now_stage then
        self.now_stage:PlayDmg(pos,1)
    end
end

function c:SyncWeatherDamage(pos)
    self.now_stage:PlayDmg(pos,1)
end

--领取免费药水
function c:GetFreePotion()
    local mark = self.free_potion_data.mark
    local now = workspace:GetServerTimeNow()
    local sub = now - mark
    if sub < FREEPOTIONCD then
        return
    end
    local re,new_time = self:Invoke('getFreePotion')
    if re then
        self.free_potion_data.mark = new_time
        ui_manager.ui_list.tips_gui:TipsMessage('Claimed Success!','success')
    end
end

function c:UpdateFreePotion()
    if not self.now_stage then
        return
    end
    if not self.now_stage.FreePotion then
        return
    end
    local mark = self.free_potion_data.mark
    local now = workspace:GetServerTimeNow()
    local sub = now - mark
    if sub < FREEPOTIONCD then
        self.now_stage:SetFreePotionCD(FREEPOTIONCD - sub)
    else
        self.now_stage:SetFreePotionCD(-1)
    end
end

hotpot.event_manager:RegistHandle('bossJump',function(player,stage)
    local cfg = hotpot.config.stage[stage]

    ui_manager.ui_list.tips_gui:TipsMessage('The elephant boss has fled to '..  cfg.name,'success')
end)

c:RegistEvent('dropGems',c.DropGems)
c:RegistEvent('drop_gold',c.DropGold)
c:RegistEvent('lockStage',c.LockStage)
c:RegistEvent('PumpkinBossCreate',c.CreatePumpkinBoss)
c:RegistEvent('SyncPumpkinHP',c.SyncPumpkinHP)
c:RegistEvent('PumpkinBossDie',c.PumpkinBossDie)
c:RegistEvent('SyncPumpkinBuffCd',c.SyncPumpkinBuffCd)
c:RegistEvent('SyncPumpkinDamage',c.SyncPumpkinDamage)
c:RegistEvent('SyncWeatherHP',c.SyncWeatherHP)
c:RegistEvent('SyncWeatherDamage',c.SyncWeatherDamage)


return c