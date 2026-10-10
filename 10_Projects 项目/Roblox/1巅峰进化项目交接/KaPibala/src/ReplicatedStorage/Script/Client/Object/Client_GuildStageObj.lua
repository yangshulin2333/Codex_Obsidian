local hotpot = _G.ClientHotpot
---@type RayManager
local ray_manager = hotpot.load.RayManager()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Players
local Players = game:GetService('Players')
---@type Player
local localPlayer = Players.LocalPlayer
---@type InstanceManager
local instance_manager = hotpot.load.InstanceManager()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local tween_helper = hotpot.load.TweenHelper()

local monsterCfg = hotpot.config.monster
local dmgUi = hotpot:GetPath_Loop('pfb.dmgUi',_G.Resource)
local treeStr = 'When the countdown is over.After the guild administrator activates it, standing under the tree when it is activated can earn a large amount of experience points. Upgrading your guild level will increase the experience points you gain.'
local bossStr = 'When the countdown is over.After the guild administrator activates it, there are a total of 10 bosses. Defeating them can earn you a large amount of rewards.'
local forgeStr = 'Forging relics will give your relics a significant increase in damage. Moreover, at levels 3, 7, and 10, there will be different cool effects.'
local pkStr = "PK rule: Two players stand on the platform simultaneously. HP and attacks will only use the player's relics, pets and titles."
local warStr = "Register for the guild battle and participate, and you will be awarded a unique title!"

---@class Client_GuildStageObj:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new()
    return c()
end
function c:ctor()
    c.super.ctor(self)

    ui_manager.ui_list.npc_gui:BindCloseBtnClickHandle(self,self.ClickCloseBtn)
    ui_manager.ui_list.npc_gui:BindOpenBtnClickHandle(self,self.ClickOpenBtn)
    ui_manager.ui_list.npc_gui:BindRelicBtnClickHandle(self,self.ClickForgeRelicsBtn)
    ui_manager.ui_list.npc_gui:BindMountBtnClickHandle(self,self.ClickForgeMountBtn)

    hotpot.event_manager:RegistHandle('playerBedamage',function(_,pos,dmg)
        self:PlayDmg(pos,dmg)
    end)

    self:InitAnimation()
end

function c:InitAnimation()
    local fol = hotpot:GetPath_Loop('Stage.NPC',workspace)
    for k,v in ipairs(fol:GetChildren())do
        local humanoid = v:WaitForChild('Humanoid')
        local Animator = humanoid:WaitForChild('Animator')
        local Animation = humanoid:WaitForChild('Animation')
        Animator:LoadAnimation(Animation):Play()
    end
end

function c:CharacterIn(character)
    ---@type Client_Player
    local player = character.player
    local part = workspace:WaitForChild('BossArea')
    self.bossArea = part
    ray_manager:AddRayCast(
        part,
        self,
        self.InBossArea,
        self.OutBossArea
    )

    local mount = workspace:WaitForChild('mount')
    ray_manager:AddRayCast(
        mount,
        ui_manager.ui_list.mount_gui,
        ui_manager.ui_list.mount_gui.Show,
        ui_manager.ui_list.mount_gui.Hide
    )

    ---@type ProximityPrompt
    local treePrompt = hotpot:GetPath_Loop('Stage.NPC.tree.HumanoidRootPart.ProximityPrompt',workspace)
    treePrompt.Triggered:Connect(function(player)
        ui_manager.ui_list.npc_gui:SetNormalBtnVisible(true)
        ui_manager.ui_list.npc_gui:SetForgeBtnVisible(false)
        ui_manager.ui_list.npc_gui:SetTitle('Guild Tree')
        ui_manager.ui_list.npc_gui:SetInfo(treeStr)
        ui_manager.ui_list.npc_gui:Show()
        ui_manager.ui_list.hud_gui:Hide()
        self.prompt_state = 'tree'
    end)

    ---@type ProximityPrompt
    local bossPrompt = hotpot:GetPath_Loop('Stage.NPC.boss.HumanoidRootPart.ProximityPrompt',workspace)
    bossPrompt.Triggered:Connect(function(player)
        ui_manager.ui_list.npc_gui:SetNormalBtnVisible(true)
        ui_manager.ui_list.npc_gui:SetForgeBtnVisible(false)
        ui_manager.ui_list.npc_gui:SetTitle('Guild Bosses')
        ui_manager.ui_list.npc_gui:SetInfo(bossStr)
        ui_manager.ui_list.npc_gui:Show()
        ui_manager.ui_list.hud_gui:Hide()
        self.prompt_state = 'boss'
    end)

    ---@type ProximityPrompt
    local forgePrompt = hotpot:GetPath_Loop('Stage.NPC.forge.HumanoidRootPart.ProximityPrompt',workspace)
    forgePrompt.Triggered:Connect(function(player)
        ui_manager.ui_list.npc_gui:SetNormalBtnVisible(false)
        ui_manager.ui_list.npc_gui:SetForgeBtnVisible(true)
        ui_manager.ui_list.npc_gui:SetTitle('Guild Forge')
        ui_manager.ui_list.npc_gui:SetInfo(forgeStr)
        ui_manager.ui_list.npc_gui:Show()
        ui_manager.ui_list.hud_gui:Hide()
        self.prompt_state = 'forge'
    end)

    ---@type ProximityPrompt
    local pkPrompt = hotpot:GetPath_Loop('Stage.NPC.pk.HumanoidRootPart.ProximityPrompt',workspace)
    pkPrompt.Triggered:Connect(function(player)
        ui_manager.ui_list.npc_gui:SetNormalBtnVisible(true)
        ui_manager.ui_list.npc_gui:SetForgeBtnVisible(false)
        ui_manager.ui_list.npc_gui:SetTitle('Guild PK')
        ui_manager.ui_list.npc_gui:SetInfo(pkStr)
        ui_manager.ui_list.npc_gui:Show()
        ui_manager.ui_list.hud_gui:Hide()
        self.prompt_state = 'pk'
    end)

    ---@type ProximityPrompt
    local warPrompt = hotpot:GetPath_Loop('Stage.NPC.war.HumanoidRootPart.ProximityPrompt',workspace)
    warPrompt.Triggered:Connect(function(player)
        ui_manager.ui_list.npc_gui:SetNormalBtnVisible(false)
        ui_manager.ui_list.npc_gui:SetForgeBtnVisible(false)
        ui_manager.ui_list.npc_gui:SetWarBtnVisible(true)
        ui_manager.ui_list.npc_gui:SetTitle('Guild War')
        ui_manager.ui_list.npc_gui:SetInfo(warStr)
        ui_manager.ui_list.npc_gui:Show()
        ui_manager.ui_list.hud_gui:Hide()
        self.prompt_state = 'war'
    end)
    self.war_state_ui = hotpot:GetPath_Loop('Stage.NPC.war.HumanoidRootPart.state.info',workspace)

    local pk = hotpot:GetPath_Loop('Stage.pk',workspace)
    local pk1 = pk:FindFirstChild('pk1')
    local pk2 = pk:FindFirstChild('pk2')
    ray_manager:AddRayCast(
        pk1,
        self,
        self.InPkArea,
        self.OutPkArea
    )
    ray_manager:AddRayCast(
        pk2,
        self,
        self.InPkArea,
        self.OutPkArea
    )

    local main = hotpot:GetPath_Loop('Stage.teleport.main',workspace)
    ray_manager:AddRayCast(
        main,
        self,
        function()
            hotpot.event_manager:Fire('partybackToLobby',true)
            spawn(function()
                local time = 15
                while time > 0 do
                    time = time - 0.5
                    wait(.5)
                    ui_manager.ui_list.tips_gui:TipsMessage('Teleport...','success')
                end
            end)
        end
    )

    local pvp = hotpot:GetPath_Loop('Stage.teleport.pvp',workspace)
    ray_manager:AddRayCast(
        pvp,
        self,
        function()
            local lv = self.player.prop_cmp:GetLv()
            if lv < 22 then
                ui_manager.ui_list.tips_gui:TipsMessage('You need lv22 to PVP','error')
                return
            end

            hotpot.event_manager:Fire('teleportToPvp',true)
            spawn(function()
                local time = 15
                while time > 0 do
                    time = time - 0.5
                    wait(.5)
                    ui_manager.ui_list.tips_gui:TipsMessage('Teleport...','success')
                end
            end)
        end
    )
end

function c:InBossArea()
    local part = self.bossArea
    local alive = part:GetAttribute('bossAlive')
    local bossId = part:GetAttribute('nowBossId')
    local bossHp = part:GetAttribute('bossHp')
    local bossMaxHp = part:GetAttribute('bossMaxHp')
    -- print(alive,bossId,bossHp)
    if not alive or not bossId or bossId == 0 then
        return
    end
    if not bossHp or bossHp == 0 then
        return
    end
    local cfg = monsterCfg[bossId]
    ui_manager.ui_list.hud_gui:SetBossName(cfg.name)
    ui_manager.ui_list.hud_gui:SetBossProgress(bossHp,bossMaxHp)
    ui_manager.ui_list.hud_gui:SetBossPanelVisible(true)

    self.inBossArea = true
end

function c:OutBossArea()
    ui_manager.ui_list.hud_gui:SetBossPanelVisible(false)
    self.inBossArea = false
end

function c:UpdateBossHp(info)
    local hp = info.hp
    local max_hp = info.max_hp
    local id = info.id
    ui_manager.ui_list.hud_gui:SetBossProgress(hp,max_hp)
    ui_manager.ui_list.hud_gui:SetBossName(monsterCfg[id].name)
    if hp <= 0 then
        ui_manager.ui_list.hud_gui:SetBossPanelVisible(false)
    else
        if self.inBossArea then
            ui_manager.ui_list.hud_gui:SetBossPanelVisible(true)
        end
    end
end

function c:ClickOpenBtn()
    local state = self.prompt_state

    if state == 'forge' then
        ui_manager.ui_list.npc_gui:Hide()
        self.prompt_state = nil
        ui_manager.ui_list.guild_forge_gui:Show()
        return
    end

    if state == 'pk' then
        ui_manager.ui_list.npc_gui:Hide()
        ui_manager.ui_list.hud_gui:Show()
        self.prompt_state = nil
        return
    end

    ---@type Client_Player
    local obj = instance_manager:FindObject(localPlayer)
    if not obj then
        return
    end
    local data = obj.guild_cmp.data
    if not data then
        return
    end
    local guild_id = data.id
    if not guild_id or guild_id == 0 then
        return
    end
    local myInfo = obj.guild_cmp.guildInfo
    if not myInfo then
        return
    end
    myInfo = myInfo.player_list[localPlayer.UserId]
    if not myInfo then
        return
    end

    if myInfo.post < 4 then
        ui_manager.ui_list.npc_gui:SetInfo('Only guild manager can open it.','fail')
        return
    end

    if state == 'tree' then
        local re,arg = hotpot.function_manager:Invoke('OpenGuildTree')
        -- print(re,arg)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage('Guild Tree is opened.','success')
            ui_manager.ui_list.npc_gui:Hide()
            ui_manager.ui_list.hud_gui:Show()
        else
            local str = ''
            if arg == 1 then
                str = 'Insufficient permission'
            elseif arg == 2 then
                str = "It's not yet the opening time."
            elseif arg == 3 then
                str = 'It has already been opened.'
            else
                str = 'Opened failed.'
            end
            ui_manager.ui_list.tips_gui:TipsMessage(str,'fail')
        end
    elseif state == 'boss' then
        local re,arg = hotpot.function_manager:Invoke('OpenGuildBoss')
        -- print(re,arg)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage('Guild Boss is opened.','success')
            ui_manager.ui_list.npc_gui:Hide()
            ui_manager.ui_list.hud_gui:Show()
            -- ui_manager.
        else
            local str = ''
            if arg == 1 then
                str = 'Insufficient permission'
            elseif arg == 2 then
                str = "It's not yet the opening time."
            elseif arg == 3 then
                str = 'It has already been opened.'
            else
                str = 'Opened failed.'
            end
            ui_manager.ui_list.tips_gui:TipsMessage(str,'fail')
        end
    end
end

function c:ClickCloseBtn()
    self.prompt_state = nil
end

function c:ClickForgeRelicsBtn()
    ---@type Client_Player
    local player = instance_manager:FindObject(localPlayer)
    if not player then
        return
    end
    player.guild_forge_cmp:InForgeRelics()
end

function c:ClickForgeMountBtn()
    ---@type Client_Player
    local player = instance_manager:FindObject(localPlayer)
    if not player then
        return
    end
    player.mount_cmp:InForgeMount()
end

function c:InPkArea(part)
    -- print(part)
    local re = hotpot.function_manager:Invoke('InPkArea',part)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Enter Pk Area.','success')
    else
        ui_manager.ui_list.tips_gui:TipsMessage('Enter Pk Area Failed.','fail')
    end
end

function c:OutPkArea(part)
    -- print(part)
    local re = hotpot.function_manager:Invoke('OutPkArea',part)
end

function c:SetWarNPCState(str,color)
    self.war_state_ui.Text = str
    self.war_state_ui.TextColor3 = color
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

---@param player Client_Player
hotpot.event_manager:RegistHandle('updateGuildBossHp',function(player,info)
    ---@type GameClient
    local client = _G.client
    ---@type Client_GuildStageObj
    local stageObj = client.guild_stage_obj
    stageObj:UpdateBossHp(info)
    if player.hud_boss_idx ~= info.idx then
        player.hud_boss_idx = info.idx
        ui_manager.ui_list.hud_gui:RemoveAllBossItem()
        local cfg = hotpot.pro_cfg.guildBossReward[info.idx]
        for k,v in ipairs(cfg) do
            local icon = player.reward_cmp:GetIcon(v.reward)
            local quality = player.reward_cmp:GetQulity(v.reward)
            ui_manager.ui_list.hud_gui:AddItemInBossRewards(icon,quality)
        end
    end
end)

hotpot.event_manager:RegistHandle('pkcd',function(player,cd)
    ui_manager.ui_list.pk_gui:SetCD(cd)
end)

hotpot.event_manager:RegistHandle('pk_startTip',function(player)
    ui_manager.ui_list.tips_gui:TipsMessage('PK start.','success')
end)

hotpot.event_manager:RegistHandle('pk_win',function(player,p)
    ui_manager.ui_list.tips_gui:TipsMessage('You defeated '..p.Name,'success')
end)

hotpot.event_manager:RegistHandle('pk_lose',function(player,p)
    ui_manager.ui_list.tips_gui:TipsMessage('You were defeated by '..p.Name,'fail')
end)

hotpot.event_manager:RegistHandle('outPkState',function(player)
    wait(3)
    ui_manager.ui_list.tips_gui:TipsMessage('Exit PK state.','success')
end)

hotpot.event_manager:RegistHandle('openPKui',function(player1,player2)
    --先打开自己的
    local cha1 = player1.character.main_inst
    local root = cha1.PrimaryPart
    local pkUi = hotpot:GetPath_Loop('PlayerName.info.pk',root)
    pkUi.Visible = true

    --打开对面的
    local cha2 = player2.Character
    local root2 = cha2.PrimaryPart
    local pkUi2 = hotpot:GetPath_Loop('PlayerName.info.pk',root2)
    pkUi2.Visible = true
end)

---@param player Client_Player
hotpot.event_manager:RegistHandle('playerUsePKSkill',function(player,info)
    player.stage_cmp:OtherPlayerUseSkill(info)
end)

hotpot.event_manager:RegistHandle('sendTreeTime',function(player,t)
    ui_manager.ui_list.hud_gui:SetTreeCD(t)
end)

return c