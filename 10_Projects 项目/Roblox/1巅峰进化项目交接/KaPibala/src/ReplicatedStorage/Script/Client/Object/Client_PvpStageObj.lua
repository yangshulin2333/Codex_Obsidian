local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local tween_helper = hotpot.load.TweenHelper()
---@type RayManager
local RayManager = hotpot.load.RayManager()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local monsterCfg = hotpot.config.pvpMonster

local dmgUi = hotpot:GetPath_Loop('pfb.dmgUi',_G.Resource)
local bossAreaFol = hotpot:GetPath_Loop('Stage.bossArea',workspace)
local kill_str = '[SYSTEM] <font color = "rgb(0,255,0)">%s</font> has killed <font color = "rgb(255,0,0)">%s</font>'
local forge_str = '[SYSTEM] <font color = "rgb(0,255,0)">%s</font> has forged <font color = "rgb(255,0,0)">+%s</font>'
local revenge_str = '[SYSTEM] <font color = "rgb(0,255,0)">%s</font> <font color = "rgb(0, 170, 255)">has revenged</font> <font color = "rgb(255,0,0)">%s</font>'

---@class Client_PvpStageObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model)
    return c(model)
end
function c:ctor(model)
    c.super.ctor(self,model)

    ui_manager.ui_list.die_gui:BindRebornBtnClickHandle(self,self.ClickRebornBtn)
    ui_manager.ui_list.die_gui:BindRevengeBtnClickHandle(self,self.ClickRevengeBtn)
end

function c:PlayerIn(player)
    ---@type Client_Player
    self.player = player
    ---@type Client_PlayerCharacter
    self.character = player.character

    player.pvp_stage = self

    for _,part in ipairs(bossAreaFol:GetChildren())do
        RayManager:AddRayCast(
            part,
            self,
            self.InBossArea,
            self.OutBossArea
        )
    end

    local shop = workspace:WaitForChild('shop')
    RayManager:AddRayCast(
        shop,
        ui_manager.ui_list.pvp_shop_gui,
        ui_manager.ui_list.pvp_shop_gui.Show,
        ui_manager.ui_list.pvp_shop_gui.Hide
    )

    local teleport = hotpot:GetPath_Loop('teleport',workspace)
    RayManager:AddRayCast(
        teleport,
        self,
        function()
            spawn(function()
                local time = 15
                while time > 0 do
                    time = time - 0.5
                    wait(.5)
                    ui_manager.ui_list.tips_gui:TipsMessage('Teleport...','success')
                end
            end)
            wait(4)
            hotpot.event_manager:Fire('partybackToLobby')
        end
    )

    local skillPart = hotpot:GetPath_Loop('skillPart',workspace)
    RayManager:AddRayCast(
        skillPart,
        ui_manager.ui_list.open_skill_gui,
        function()
                ui_manager.ui_list.open_skill_gui:SetSureBgVisible(true)
                ui_manager.ui_list.open_skill_gui:Show()
                self.__in_skill_box = true
            end,
        function()
                ui_manager.ui_list.open_skill_gui:SetSureBgVisible(false)
                self.__in_skill_box = false
            end
    )

    local forgePart = hotpot:GetPath_Loop('forgePart',workspace)
    RayManager:AddRayCast(
        forgePart,
        ui_manager.ui_list.guild_forge_gui,
        ui_manager.ui_list.guild_forge_gui.Show,
        ui_manager.ui_list.guild_forge_gui.Hide
    )

    local challenge = hotpot:GetPath_Loop('challenge',workspace)
    RayManager:AddRayCast(
        challenge,
        self,
        function()
            local lv = player.prop_cmp:GetLv()
            if lv < 29 then
                ui_manager.ui_list.tips_gui:TipsMessage('You need lv29 to challenge','fail')
                return
            end

            hotpot.event_manager:Fire('teleportChallenge')
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

    local ProximityPrompt = hotpot:GetPath_Loop('y8.Part.ProximityPrompt',workspace)
    ProximityPrompt.Triggered:Connect(function(player)
        ui_manager.ui_list.npc_gui:SetTitle('Challenge')
        ui_manager.ui_list.npc_gui:Show()
        ui_manager.ui_list.npc_gui:SetInfo('The "Blood Castle" is refreshed every Thursday. The top 10 players in the ranking will be awarded rare relics.')
        ui_manager.ui_list.npc_gui:SetNormalBtnVisible(false)
        ui_manager.ui_list.npc_gui:SetForgeBtnVisible(false)
        ui_manager.ui_list.npc_gui:SetChallengeBtnVisible(true)
    end)

    ui_manager.ui_list.npc_gui:BindChallengeClaimBtnClickHandle(self,self.ClickChallengeClaimBtn)
end

function c:InBossArea(part)
    local id = tonumber(part.Name)
    self.in_boss_area = id

    local is_alive = part:GetAttribute('is_alive')
    if is_alive then
        local hp = part:GetAttribute('hp')
        local maxHp = part:GetAttribute('max_hp')
        ui_manager.ui_list.hud_gui:SetBossName(monsterCfg[id].name)
        ui_manager.ui_list.hud_gui:SetBossProgress(hp,maxHp)
        ui_manager.ui_list.hud_gui:SetBossPanelVisible(hp > 0)

        ui_manager.ui_list.hud_gui:RemoveAllBossItem()
        if id == 8 then
            ui_manager.ui_list.hud_gui:AddItemInBossRewards('rbxassetid://97950625618717',4)
            ui_manager.ui_list.hud_gui:AddItemInBossRewards('rbxassetid://105112106242077',4)
            ui_manager.ui_list.hud_gui:AddItemInBossRewards('rbxassetid://115046552923805',5)
        elseif id == 9 then
            ui_manager.ui_list.hud_gui:AddItemInBossRewards('rbxassetid://77040878668236',5)
            ui_manager.ui_list.hud_gui:AddItemInBossRewards('rbxassetid://77352085838107',7)
            ui_manager.ui_list.hud_gui:AddItemInBossRewards('rbxassetid://135210716417270',7)
        end
    end
end

function c:OutBossArea(part)
    self.in_boss_area = nil
    ui_manager.ui_list.hud_gui:SetBossPanelVisible(false)
end

function c:ClickChallengeClaimBtn()
    local re,arg = hotpot.function_manager:Invoke('challengeClaim')
    if re then
    else
        if arg == 1 then
            ui_manager.ui_list.tips_gui:TipsMessage('You failed to make it into the top 10 of the ranking last week.','fail')
        elseif arg == 2 then
            ui_manager.ui_list.tips_gui:TipsMessage('You have already claimed the reward.','fail')
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Unknown error.Please try again later.','fail')
        end
    end
end

function c:ClickRevengeBtn()
    local re = hotpot.function_manager:Invoke('buy_goods',115)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Revenge attack success.','success')
    end
end

function c:ClickRebornBtn()
    hotpot.event_manager:Fire('pvpReborn')
    ui_manager.ui_list.die_gui:Hide()
end

hotpot.event_manager:RegistHandle('show_dmg',function(_,info)
    local pos = info.pos
    local dmg = info.dmg
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
end)

---@param player Client_Player
hotpot.event_manager:RegistHandle('playerUsePvpSkill',function(player,info)
    player.stage_cmp:OtherPlayerUseSkill(info)
end)

hotpot.event_manager:RegistHandle('pvp_boss_hp_change',function(player,info)
    local id = info.id
    local hp = info.hp
    local maxHp = info.max_hp
    
    local stage = player.pvp_stage
    if not stage then
        return
    end
    if stage.in_boss_area == id then
        ui_manager.ui_list.hud_gui:SetBossName(monsterCfg[id].name)
        ui_manager.ui_list.hud_gui:SetBossProgress(hp,maxHp)
        ui_manager.ui_list.hud_gui:SetBossPanelVisible(true)
        if hp <= 0 then
            ui_manager.ui_list.hud_gui:SetBossPanelVisible(false)
        end
    end
end)

hotpot.event_manager:RegistHandle('pvp_boss_spawn',function(_,name)
    local TextChatService = game:GetService("TextChatService")

    local channel = TextChatService.TextChannels:WaitForChild("RBXGeneral")

    if channel then
        channel:DisplaySystemMessage("<font color='#ff0026'>[SYSTEM] "..name.." has already appeared. Please defeat it as soon as possible.</font>")
    end
end)

hotpot.event_manager:RegistHandle('pvp_kill',function(_,info)

    local killer_guid = info.killer
    local target_guid = info.target

    local TextChatService = game:GetService("TextChatService")

    local channel = TextChatService.TextChannels:WaitForChild("RBXGeneral")

    if channel then
        channel:DisplaySystemMessage(kill_str:format(killer_guid.Name,target_guid.Name))
    end
end)

hotpot.event_manager:RegistHandle('pvpforgeSuccess',function(_,info)

    local name = info.name
    local upgrade = info.upgrade

    local TextChatService = game:GetService("TextChatService")

    local channel = TextChatService.TextChannels:WaitForChild("RBXGeneral")

    if channel then
        channel:DisplaySystemMessage(forge_str:format(name,upgrade))
    end
end)

hotpot.event_manager:RegistHandle('pvp_die',function(player,info)
    local killed = info.kill
    local revenge = info.revenge
    if killed and killed.UserId then
        ui_manager.ui_list.die_gui:SetRevengeBtnVisible(true)
        ui_manager.ui_list.die_gui:SetName(killed.Name)
    else
        if revenge and revenge.UserId then
            ui_manager.ui_list.die_gui:SetRevengeName(revenge.Name)
        else
            ui_manager.ui_list.die_gui:SetNormal()
        end
        ui_manager.ui_list.die_gui:SetRevengeBtnVisible(false)
    end

    ui_manager.ui_list.die_gui:Show()
end)

hotpot.event_manager:RegistHandle('pvprevengetip',function(_,info)

    local player1 = info.player1
    local player2 = info.player2

    local TextChatService = game:GetService("TextChatService")

    local channel = TextChatService.TextChannels:WaitForChild("RBXGeneral")

    if channel then
        channel:DisplaySystemMessage(revenge_str:format(player1.Name,player2.Name))
    end
end)

return c
