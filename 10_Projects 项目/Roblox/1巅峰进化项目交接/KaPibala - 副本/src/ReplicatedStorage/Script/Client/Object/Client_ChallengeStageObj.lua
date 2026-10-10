local hotpot = _G.ClientHotpot
---@type RayManager
local ray_manager = hotpot.load.RayManager()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local tween_helper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type InstanceManager
local inst_manager = hotpot.load.InstanceManager()

local dmgUi = hotpot:GetPath_Loop('pfb.dmgUi',_G.Resource)

---@class Client_ChallengeStageObj:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new()
    return c()
end
function c:ctor()
    c.super.ctor(self)
end

---@param character Client_PlayerCharacter
function c:CharacterIn(character)
    local list = workspace:WaitForChild('stagelist')

    for k,v in ipairs(list:GetChildren())do
        local root = v:WaitForChild('root')
        ray_manager:AddRayCast(
            root,
            self,
            function()
                character.player.sync_cmp:Add('challenge_in_area',{name = v.Name})
            end
        )

        local bossArea = v:WaitForChild('bossArea')
        ray_manager:AddRayCast(
            bossArea,
            self,
            self.InBossArea,
            self.LeaveBossArea
        )
    end

    list.ChildAdded:Connect(function(child)
        local root = child:WaitForChild('root')
        ray_manager:AddRayCast(
            root,
            self,
            function()
                character.player.sync_cmp:Add('challenge_in_area',{name = child.Name})
            end
        )

        local bossArea = child:WaitForChild('bossArea')
        ray_manager:AddRayCast(
            bossArea,
            self,
            self.InBossArea,
            self.LeaveBossArea
        )
    end)
    list.ChildRemoved:Connect(function(child)
        local root = child:FindFirstChild('root')
        if root then
            ray_manager:RemoveRayCast(root)
        end
        local bossArea = child:FindFirstChild('bossArea')
        if bossArea then
            ray_manager:RemoveRayCast(bossArea)
        end
    end)

    character.player.now_stage = self

    self.player = character.player

    self:AddProcess(function()
        self:Wait(5)
        ui_manager.ui_list.challenge_gui:Show()
    end)
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

function c:InBossArea(part)
    local is_alive = part:GetAttribute('is_alive')
    if is_alive then
        local hp = part:GetAttribute('hp')
        local max_hp = part:GetAttribute('max_hp')
        local name = part:GetAttribute('name')
        ui_manager.ui_list.hud_gui:SetBossName(name)
        ui_manager.ui_list.hud_gui:SetBossProgress(hp,max_hp)
        ui_manager.ui_list.hud_gui:SetBossPanelVisible(true)

        self.player.__in_boss_area = true
    end
end

function c:LeaveBossArea(part)
    ui_manager.ui_list.hud_gui:SetBossPanelVisible(false)
    self.player.__in_boss_area = false
end

--玩家技能
function c:PlayerSkill(player,skill_id,slot,collider)
    local monster_guid = collider:GetAttribute('guid')
    player.sync_cmp:Add('challenge_player_skill_monster',{
        monster_guid = monster_guid,
        skill_id = skill_id,
        slot = slot,
    })
end

hotpot.event_manager:RegistHandle('play_dmg',function(_,info)
    ---@type GameClient
    local client = _G.client
    ---@type Server_ChallengeStageObj
    local obj = client.challenge_stage_obj
    if obj then
        obj:PlayDmg(info.pos,info.dmg)
    end
end)

hotpot.event_manager:RegistHandle('challenge_boss_hp_change',function(player,info)
    if player.__in_boss_area then
        local hp = info.hp
        local maxHp = info.max_hp
        ui_manager.ui_list.hud_gui:SetBossProgress(hp,maxHp)
        if hp <= 0 then
            ui_manager.ui_list.hud_gui:SetBossPanelVisible(false)
        end
    end
end)

hotpot.event_manager:RegistHandle('challenge_pass',function(player,pass_num)
    ui_manager.ui_list.challenge_gui:SetStageText(pass_num)
end)

return c