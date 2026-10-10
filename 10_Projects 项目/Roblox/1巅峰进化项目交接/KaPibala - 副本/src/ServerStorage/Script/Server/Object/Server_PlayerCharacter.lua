local _G = _G
local script = script
---@type ServerHotpot
local hotpot = _G.ServerHotpot
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()
---@type TweenHelper
local tween_helper = hotpot.load.TweenHelper()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()

local charcter_cfg = hotpot.config.character
local eff_fol = hotpot:GetPath_Loop('eff',hotpot.Resource)
local PlayerName = hotpot:GetPath_Loop('pfb.PlayerName',hotpot.Resource)
local BodyColors = hotpot:GetPath_Loop('pfb.BodyColors',hotpot.Resource)
local lv_cfg = hotpot.config.playerLv
local collider = hotpot:GetPath_Loop('pfb.collider',hotpot.Resource)
local hp_ui = hotpot:GetPath_Loop('pfb.monsterHp',hotpot.Resource)

---@class Server_PlayerCharacter:CharacterObject
local c = hotpot.class.new(script, hotpot.files.CharacterObject())
function c.new(character_inst, player_object)
    return c(character_inst, player_object)
end
---@param player_object Server_Player
function c:ctor(character_inst, player_object)
    c.super.ctor(self, character_inst)
    self.player = player_object

    self.humanoid.AutoJumpEnabled = false

    self.atk_time = 0
    self.recover_time = 6

    local partFol = Instance.new('Folder',self.main_inst)
    partFol.Name = 'PartFolder'
    self.part_fol = partFol

    local forgeEffFol = Instance.new('Folder',self.main_inst)
    forgeEffFol.Name = 'ForgeEffFolder'
    self.forgeEff_fol = forgeEffFol

    self:CreatePetPart()
    self:InitProp()
    self.humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    -- self.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
    self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
    self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
    self.humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    local part = hotpot:GetPath_Loop('pfb.attackCheck',hotpot.Resource)
    local p = part:Clone()
    if place_manager:GetIdByName('pvpsence') == game.PlaceId then
        p.Parent = workspace.AttackCheck
        p.Name = self.player.guid
    else
        p.Parent = self.main_inst
    end
    local cf = self:GetCFrame()
    p.Position = cf.Position + cf.LookVector * 3
    local we = Instance.new('WeldConstraint',p)
    we.Part0 = p
    we.Part1 = self.root_part
    self.attackCheck = p

    self:AddProcess(function()
        self:Wait(5)
        local collider_ = collider:Clone()
        collider_.CanTouch = true
        collider_.Parent = self.main_inst
        collider_.CFrame = self:GetCFrame()
        local we = Instance.new('WeldConstraint',collider_)
        we.Part0 = self.root_part
        we.Part1 = collider_
        self.collider = collider_
        collider_.CollisionGroup = 'pvp_character'
        if place_manager:GetIdByName('pvpsence') == game.PlaceId then
            collider_:SetAttribute('guid',self.player.guid)
        end
    end)

    local ui = hotpot:CloneInst_Loop(hp_ui)
    ui.Parent = self.root_part
    ui.Enabled = false

    local pk_state = self.player.main_inst:WaitForChild('pk_state')
    self.pk_stateValue = pk_state

    self.hp_ui = ui

    self.hp_ui_cd = 2

    self:AddUpdate(self.UpdateHpUi,0.5)

    self.__head_vis = false
    self:AddProcess(function()
        self:Wait(5)
        self:SetOwnerHeadVisible(false)
    end)
end

function c:dtor()
    if self.main_inst then
        self.main_inst:Destroy()
    end
    c.super.dtor(self)
end

function c:OnDead()
end

function c:PlayHpUi(now,max)
    if not now or not max then
        return
    end
    if not self.hp_ui then
        return
    end
    self.hp_ui.Frame.bg.num.Text = big_number:ToString(now)..'/'..big_number:ToString(max)
    tween_helper:PlayTween(
        self.hp_ui.Frame.bg.fg,
        TweenInfo.new(0.2),
        {Size = UDim2.fromScale(math.clamp(now/max,0,1),1)}
    )
end

function c:UpdateHpUi(step)
    if self.pk_stateValue.Value then
        self.hp_ui.Enabled = true
    else
        self.hp_ui_cd = self.hp_ui_cd - step
        if self.hp_ui_cd <= 0 then
            self.hp_ui.Enabled = false
        end
    end
end

--创建宠物part
function c:CreatePetPart()
    ---@type Part
    local part = Instance.new('Part',self.main_inst)
    part.Size = Vector3.new(4,8,4)
    part.CFrame = self:GetCFrame()
    part.CanQuery = false
    part.CanCollide = false
    part.CanTouch = false
    part.Transparency = 1
    local we = Instance.new('WeldConstraint',part)
    we.Part0 = part
    we.Part1 = self.root_part
    part.Name = 'PetPart'
    self.pet_part = part
    part.CustomPhysicalProperties = PhysicalProperties.new(0.0001,0.5,1,0.2,1)

    local ui = hotpot:CloneInst_Loop(PlayerName)
    self.name_ui = ui
    ui.info.Text = self.player:GetDisplayName()
    ui.Parent = self.root_part
end

function c:SetLv()
    local lv = self.player.prop_cmp:GetLv()
    if not self.name_ui then
        return
    end
    local lvText = self.name_ui:FindFirstChild('lv')
    if not lvText then
        return
    end
    lvText.Text = 'LV'..lv
    local icon = lv_cfg[lv].icon
    self.name_ui.info.icon.Image = icon
end

function c:SetGuildName(name)
    if self.name_ui then
        self.name_ui.guild.Text = name
    end
end

--改变角色
---@param model Model
function c:ChangeCharacter(model,id)
    self.__id = id

    --先删除
    self.part_fol:ClearAllChildren()
    for k,v in ipairs(self.main_inst:GetChildren()) do
        if v:IsA('Accessory') then
            if not v.Name:find('relicsAcc') then
                v:Destroy()
            end
        end
        if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Hat') then
            v:Destroy()
        end
    end

    local head__ = self.main_inst:FindFirstChild('Head')
    if head__ then
        for k,v in ipairs(head__:GetChildren()) do
            if v.Name == 'effAtt' then
                v:Destroy()
            end
        end
    end

    for k,v in pairs(model:GetDescendants()) do
        if v:IsA('BasePart') then
            v.CanCollide = false
            v.CanTouch = false
            v.CanQuery = false
            v.Anchored = false
            v.Massless = true
        end
    end

    if model:GetAttribute('old') then
        self.__old = true
        self.part_fol:ClearAllChildren()
        for k,v in ipairs(self.main_inst:GetChildren()) do
            if v:IsA('MeshPart') then
                v.Transparency = 0
            end
        end

        local humanoid = model:FindFirstChild('Humanoid')
        local desc = humanoid:GetAppliedDescription()

        if self.finish_co then
            self.finish_co:Disconnect()
            self.finish_co = nil
        end
        self.finish_co = self.humanoid.ApplyDescriptionFinished:Connect(function()
            for k,v in ipairs(self.main_inst:GetDescendants()) do
                if v:IsA('SurfaceAppearance') then
                    v:Destroy()
                end
            end

            for k,v in pairs(model:GetChildren()) do
                if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Accessory') or v:IsA('Hat') then
                    v:Clone().Parent = self.main_inst
                end
                if v:IsA('BasePart') then
                    if v.Name ~= 'collider' then
                        v.CollisionGroup = 'character'
                    end
                    local part = self.main_inst:FindFirstChild(v.Name)
                    if part then
                        part.Color = v.Color
                    end
                end
                if v:IsA('Attachment') and v.Name == 'effAtt' then
                    local clone = v:Clone()
                    local part = self.main_inst:FindFirstChild(v.Name)
                    if part then
                        clone.Parent = part
                    end
                end
            end
            local head = self.main_inst:FindFirstChild('Head')
            if head then
                local face = head:FindFirstChildOfClass('Decal')
                if face then
                    face:Destroy()
                end
            end
            head = model:FindFirstChild('Head')
            local face = head:FindFirstChildOfClass('Decal')
            if face then
                face:Clone().Parent = self.main_inst.Head
            end

            for k,v in pairs(model:GetDescendants()) do
                if v:IsA('Attachment') and v.Name == 'effAtt' then
                    local clone = v:Clone()
                    local part = self.main_inst:FindFirstChild(v.Parent.Name)
                    if part then
                        clone.Parent = part
                    end
                end
            end

            local color = model:FindFirstChildOfClass('BodyColors')
            if color then
                local color1 = self.main_inst:FindFirstChildOfClass('BodyColors')
                if color1 then
                    color1:Destroy()
                end
                color.Parent = self.main_inst
            end
            wait(1)
            if self.main_inst and self.main_inst.Parent then
                for k,v in pairs(self.main_inst:GetChildren()) do
                    if v:IsA('BasePart') then
                        if v.Name ~= 'collider' then
                            v.CollisionGroup = 'character'
                        end
                    end
                    if v:IsA('Shirt') then
                        if not v.ShirtTemplate or v.ShirtTemplate == '' then
                            v.ShirtTemplate = v:GetAttribute('res')
                        end
                    end
                    if v:IsA('Pants') then
                        if not v.PantsTemplate or v.PantsTemplate == '' then
                            v.PantsTemplate = v:GetAttribute('res')
                        end
                    end
                end
            end
        end)

        for k,v in pairs(self.main_inst:GetDescendants()) do
            if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Accessory') or v:IsA('Hat') then
                v:Destroy()
            end
            if v:IsA('Attachment') and v.Name == 'effAtt' then
                v:Destroy()
            end
        end

        self.humanoid:ApplyDescription(desc)

    else
        self.__old = false
        --应用
        local head = self.main_inst:FindFirstChild('Head')
        if head then
            local face = head:FindFirstChildOfClass('Decal')
            if face then
                face:Destroy()
            end
        end

        for k,v in ipairs(model:GetChildren())do
            if v:IsA('Humanoid') then
                v:Destroy()
            end
            if v:IsA('MeshPart') then
                local value = v:FindFirstChild('OriginalSize')
                if value then
                    value:Destroy()
                end
                local motor = v:FindFirstChildOfClass('Motor6D')
                if motor then
                    motor:Destroy()
                end
                local trage = v:FindFirstChildOfClass('WrapTarget')
                if trage then
                    trage:Destroy()
                end
    
                local chaPart = self.main_inst:FindFirstChild(v.Name)
                if not chaPart then
                    continue
                end
                local RigidConstraint = Instance.new("RigidConstraint",v)
                local att = v:FindFirstChildOfClass("Attachment")
                RigidConstraint.Attachment0 = att
    
                local chaAtt = chaPart:FindFirstChild(att.Name)
                if not chaAtt then
                    continue
                end
                RigidConstraint.Attachment1 = chaAtt
                
                v.Parent = self.part_fol
            end
            if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Hat') or v:IsA('Accessory') then
                v.Parent = self.main_inst
            end
        end
        for k,v in ipairs(self.part_fol:GetChildren()) do
            if v:IsA('MeshPart') then
                if v:GetAttribute('transparency') then
                    v.Transparency = 1
                else
                    v.Transparency = 0
                end
            end
        end
        for k,v in ipairs(self.main_inst:GetChildren()) do
            if v:IsA('MeshPart') then
                v.Transparency = 1
            end
        end
    end

    if self.eff then
        self.eff:Destroy()
        self.eff = nil
    end
    if self.eff2 then
        self.eff2:Destroy()
        self.eff2 = nil
    end
    if self.eff3 then
        self.eff3:Destroy()
        self.eff3 = nil
    end

    self:AddEff()

    self:AddProcess(function()
        self:Wait(.1)
        self:SetOwnerHeadVisible(self.__head_vis)
    end)

    wait(1)
    if self.player.relics_cmp then
        self.player.relics_cmp:Init()
    end

    wait(2)
    model:Destroy()
end

--设置原生头
function c:SetOwnerHeadVisible(vis)
    if vis then
        for k,v in ipairs(self.main_inst:GetDescendants())do
            if v:GetAttribute('isHead') then
                if v:IsA('BasePart') and v.Name ~= 'NewPlayerHead' then
                    v.Transparency = 1
                end
                if v.Name == 'effAtt' and v:IsA('Attachment') then
                    for _,eff in ipairs(v:GetDescendants())do
                        if eff:IsA('ParticleEmitter') then
                            eff.Enabled = false
                        end
                    end
                end
                if v:IsA('Decal') and v.Parent.Name ~= 'NewPlayerHead' then
                    v.Transparency = 1
                end
            end
        end
        local NewPlayerHead = self.main_inst:FindFirstChild('NewPlayerHead')
        if NewPlayerHead then
            NewPlayerHead.Transparency = 0
            local Decal = NewPlayerHead:FindFirstChildOfClass('Decal')
            if Decal then
                Decal.Transparency = 0
            end
        end

        local name = self.player.main_inst.Name
        local model = hotpot:GetPath_Loop('PlayerRigs.'..name,workspace)
        for k,v in ipairs(model:GetDescendants())do
            if v:IsA('BasePart') then
                v.Transparency = 0
            end
        end
    else
        for k,v in ipairs(self.main_inst:GetDescendants())do
            if v:GetAttribute('isHead') then
                if v:IsA('BasePart') and v.Name ~= 'NewPlayerHead' then
                    v.Transparency = 0
                end
                if v.Name == 'effAtt' and v:IsA('Attachment') then
                    for _,eff in ipairs(v:GetDescendants())do
                        if eff:IsA('ParticleEmitter') then
                            eff.Enabled = true
                        end
                    end
                end
                if v:IsA('Decal') and v.Parent.Name ~= 'NewPlayerHead' then
                    v.Transparency = 0
                end
            end
        end
        local NewPlayerHead = self.main_inst:FindFirstChild('NewPlayerHead')
        if NewPlayerHead then
            NewPlayerHead.Transparency = 1
            local Decal = NewPlayerHead:FindFirstChildOfClass('Decal')
            if Decal then
                Decal.Transparency = 1
            end
        end

        local name = self.player.main_inst.Name
        local model = hotpot:GetPath_Loop('PlayerRigs.'..name,workspace)
        for k,v in ipairs(model:GetDescendants())do
            if v:IsA('BasePart') then
                v.Transparency = 1
            end
        end

    end

    local head = self.main_inst:FindFirstChild('Head')
    if head then
        head.Transparency = self.__old and 0 or 1
    end
end

--添加特效
function c:AddEff()
    if self.eff then
        self.eff:Destroy()
        self.eff = nil
    end
    if self.eff2 then
        self.eff2:Destroy()
        self.eff2 = nil
    end
    if self.eff3 then
        self.eff3:Destroy()
        self.eff3 = nil
    end

    local id = self.__id
    if not id then
        return
    end
    local model = self.main_inst

    local weaponId = self.player.relics_cmp:GetEquipWeaponId()

    local name,part,part1

    if weaponId then
        local cfg = hotpot.config.relics[weaponId]
        name = cfg.eff
        part = eff_fol:FindFirstChild(name)
        part = hotpot:CloneInst_Loop(part)
        if cfg.w_type == 4 or cfg.w_type == 1 then
            part1 = part:Clone()
        end
    else
        name = charcter_cfg[id].eff
        part = eff_fol:FindFirstChild(name)
        part = hotpot:CloneInst_Loop(part)

        if charcter_cfg[id].w_type == 4 or charcter_cfg[id].w_type == 1 then
            part1 = part:Clone()
        end
    end
    
    part.Parent = model
    part.CFrame = model:GetPivot()
    ---@type WeldConstraint
    local we = Instance.new('WeldConstraint',part)
    we.Part0 = part
    we.Part1 = model.PrimaryPart
    
    if part1 then
        part1.Parent = model
        part1.CFrame = model:GetPivot() * CFrame.Angles(math.rad(180),math.rad(90),0)
        ---@type WeldConstraint
        local we = Instance.new('WeldConstraint',part1)
        we.Part0 = part1
        we.Part1 = model.PrimaryPart
        self.eff3 = part1
        part1.Name = part1.Name .. '_New'
        for k,v in ipairs(part1:GetDescendants())do
            if v:IsA('ParticleEmitter') then
                v.Enabled = false
            end
        end
    end
    
    self.eff = part
    for k,v in ipairs(part:GetDescendants())do
        if v:IsA('ParticleEmitter') then
            v.Enabled = false
        end
    end
    if part:FindFirstChild('裂地') then
        self.eff2 = part:FindFirstChild('裂地')
    else
        self.eff2 = nil
    end
end

--初始化属性
function c:InitProp()
    local hp = self.player.prop_cmp:GetHp()
    self.hp = hp
    self.max_hp = hp
end

function c:BeDamage(source,dmg)
    if self.is_die then
		return
	end
    self.__dmg = true
    self:StartUpdate()
    self.recover_time = 6
    self.hp = self.hp - dmg
    if self.hp <= 0 then
        self.player.kill_player = source
        self.hp = 0
        self:Die()
    end
    self.player.sync_cmp:Add('sync_hp',{source = source, hp = self.hp,max_hp = self.max_hp})
    self.hp_ui.Enabled = true
    self:PlayHpUi(self.hp,self.max_hp)
    self.hp_ui_cd = 3

    if place_manager:GetIdByName('guildsence') == game.PlaceId then
        hotpot.event_manager:FireAll('playerBedamage',self:GetPosition(),dmg)
        if self.hp <= 0 then
            if self.player.pk_state then
                ---@type GameServer
                local server = _G.server
                ---@type Server_GuildStageObj
                local stage = server.guild_stage_obj
                stage:PKWin(self.player.pk_player,self.player)
            end
        end
    elseif place_manager:GetIdByName('pvpsence') == game.PlaceId then
        pcall(function()
            if self.player.team_id then
                ---@type GameServer
                local server = _G.server
                ---@type Server_TeamManager
                local team_manager = server.team_manager
                team_manager:SyncPlayerData(self.player)
            end
        end)
        hotpot.event_manager:FireAll('playerBedamage',self:GetPosition(),dmg)
        if self.hp <= 0 then
            local stage = self.player.pvp_stage_obj
            if stage then
                stage:PlayerKillPlayer(source,self.player)
            end
        end
    end
end

function c:Die()
    self:StopUpdate()
    self.is_die = true
    self:SetWalkSpeed(0)
    hotpot.event_manager:Fire(self.player,'player_die')
    self:AddProcess(function()
        if place_manager:GetIdByName('guildsence') == game.PlaceId then
            if self.player.pk_state then
                local p = self.player.pk_player

                ---@type GameServer
                local server = _G.server
                ---@type Server_GuildStageObj
                local stage = server.guild_stage_obj
                stage:PlayerOutPkState(self.player)
                stage:PlayerOutPkState(p)

            end
            self:Wait(3)
            self.hp = self.max_hp
            self.player.sync_cmp:Add('sync_hp',{hp = self.hp,max_hp = self.max_hp})
            self:SetWalkSpeed(self.player.prop_cmp:GetSpeed())
            hotpot.event_manager:Fire(self.player,'pk_revive')
            self.is_die = false

            return
        end

        if place_manager:GetIdByName('pvpsence') == game.PlaceId then
            hotpot.event_manager:Fire(self.player,'pvp_die',{
                kill = self.player.kill_player,
                revenge = self.revenge_player
            })
            self:SetWalkSpeed(0)
            return
        end

        if place_manager:GetIdByName('partysence') == game.PlaceId then
            if self.player.rebornCount <= 0 then
                hotpot.event_manager:Fire(self.player,'party_fail_die',self.player.partyKillNum,self.player.partyDmg)
                self.player.now_stage:PlayerDie(self.player)
                return false
            end
            self.player.rebornCount = self.player.rebornCount - 1
            -- hotpot.event_manager:FireAll('party_reborn',self.player:GetDisplayName())
        end

        if place_manager:GetIdByName('challengesence') == game.PlaceId then
            self:Wait(1)
            ---@type Server_ChallengeStageObj
            local stage = self.player.challenge_stage_obj
            local reward_list = stage.reward_list
            local pass_num = stage.pass_num
            hotpot.event_manager:FireAll('challenge_player_die',reward_list,pass_num)

            self:SetWalkSpeed(0)

            return
        end 

        self:Wait(3)
        self.hp = self.max_hp
        self.player.sync_cmp:Add('sync_hp',{hp = self.hp,max_hp = self.max_hp})
        self:SetWalkSpeed(self.player.prop_cmp:GetSpeed())
        hotpot.event_manager:Fire(self.player,'player_revive',self.player.now_stage.spawn_idx)
        self.is_die = false
    end)
end

function c:RevengeDie(player)
    self.revenge_player = player
    self:Die()
end

function c:PvpReborn()
    self.revenge_player = nil
    self.player.kill_player = nil
    delay(.1,function()
        ---@type Model
        local cha = self.main_inst
        if cha.PrimaryPart then
            cha:PivotTo(workspace.SpawnLocation.CFrame + Vector3.new(0,4,0))
        end
    end)
    hotpot.event_manager:Fire(self.player,'pk_revive')
    self.hp = self.max_hp
    self.player.sync_cmp:Add('sync_hp',{hp = self.hp,max_hp = self.max_hp})
    self:SetWalkSpeed(self.player.prop_cmp:GetSpeed())
    self:SetBottomPosition(workspace.SpawnLocation.Position)
    self:PlayHpUi(self.hp,self.max_hp)

    delay(1,function()
        self.is_die = false
    end)

    pcall(function()
        if self.player.team_id then
            ---@type GameServer
            local server = _G.server
            ---@type Server_TeamManager
            local team_manager = server.team_manager
            team_manager:SyncPlayerData(self.player)
        end
    end)
end

function c:SetEffY(y)
    y = y or -2.8
    y = y + 1
    if self.eff then
        local eff = self.eff:FindFirstChild('裂地')
        if eff then
            local pos = eff.Position
            eff.Position = Vector3.new(pos.X,y,pos.Z)
        end
    end
end

function c:PlayEff(count)
    if not self.eff then
        return
    end
    local id  = self.__id
    if not id then
        return
    end

    local t = charcter_cfg[id].w_type
    local weapon = self.player.relics_cmp:GetEquipWeaponId()
    if weapon then
        t = hotpot.config.relics[weapon].w_type
    end
    
    if charcter_cfg[id].delay > 0 then
        wait(charcter_cfg[id].delay)
    end

    local eff = self.eff

    if t == 4 then
        if count == 0 then
            eff = self.eff3
        elseif count == 1 then
            if os.clock() - self.atk_time < 2 then
            else
                eff = self.eff3
            end
        end
    end
    if t == 3 then
        if count == 1 then
            if os.clock() - self.atk_time < 2 then
                wait(.1)
            end 
        end
    end
    if t == 1 then
        if count == 0 then
        elseif count == 1 then
            if os.clock() - self.atk_time < 2 then
                eff = self.eff3
            else
            end
        end
    end
    self.atk_time = os.clock()
    if eff then
        for k,v in ipairs(eff:GetDescendants())do
            if v:IsA('ParticleEmitter') then
                if v.Parent ~= self.eff2 then
                    v:Emit(v.Rate)
                end
            end
        end
    end
    wait(0.2)
    if self.eff2 and self.eff2.Parent then
        for k,v in ipairs(self.eff2:GetDescendants())do
            if v:IsA('ParticleEmitter') then
                v:Emit(v.Rate)
            end
        end
    end
end

--开始更新
function c:StartUpdate()
    if self.__update_co then
        return
    end
    self.__update_co = self:AddUpdate(self.Updata,1)
end

--停止更新
function c:StopUpdate()
    if self.__update_co then
        self.__update_co:Disconnect()
        self.__update_co = nil
    end
end

function c:Updata()
    self.recover_time = self.recover_time - 1
    if self.recover_time <= 0 then
        self.recover_time = 6
        self:Recover()
        self:StopUpdate()
    end
end

function c:Recover()
    if place_manager:GetIdByName('challengesence') == game.PlaceId then
        if self.is_die then
            return
        end
    end
    self.__dmg = false
    self:AddProcess(function()
        local add_hp = math.ceil((self.max_hp - self.hp)/5)
        for i = 1,5 do
            if self.__dmg then
                return true
            end
            self.hp = math.min(self.max_hp,self.hp + add_hp)
            if self.player.now_stage then
                self.player.now_stage:SendAllPlayer('sync_hp',{
                    hp = self.hp,max_hp = self.max_hp
                })
            end
            self.hp_ui.Enabled = true
            self.hp_ui_cd = 3
            self:PlayHpUi(self.hp,self.max_hp)

            pcall(function()
                if self.player.team_id then
                    ---@type GameServer
                    local server = _G.server
                    ---@type Server_TeamManager
                    local team_manager = server.team_manager
                    team_manager:SyncPlayerData(self.player)
                end
            end)

            if self.hp >= self.max_hp then
                self.hp = self.max_hp
                return true
            end

            self:Wait(.5)
        end
    end)
end

function c:RefreshHp()
    local hp = self.hp
    local max_hp = self.max_hp

    local prop = self.player.prop_cmp:GetHp()

    if prop == max_hp then
        return
    end

    if prop > max_hp then
        local sub = prop - max_hp
        self.max_hp = prop
        max_hp = prop
        self.hp = hp + sub
        hp = self.hp
    else
        local sub = max_hp - prop
        hp = math.clamp(hp - sub,1,prop)
        max_hp = prop
        self.hp = hp
        self.max_hp = max_hp
    end
    self.recover_time = 6
    self:StartUpdate()
    self.player.sync_cmp:Add('sync_hp',{hp = self.hp,max_hp = self.max_hp})
    self:PlayHpUi(self.hp,self.max_hp)
end

function c:RefreshPKHP()
    self.hp = self.player.prop_cmp:GetHp()
    self.max_hp = self.hp
    self:PlayHpUi(self.hp,self.max_hp)
end

function c:GetNewBottomPos()
    if self.player.mount_cmp then
        if self.player.mount_cmp.bottom_att then
            return self.player.mount_cmp.bottom_att.WorldPosition
        else
            return c.super.GetBottomPosition(self)
        end
    end
    return c.super.GetBottomPosition(self)
end

function c:SetPKStateVisible(vis)
    self.name_ui.info.pk.Visible = vis
end

---@param player Client_Player
hotpot.event_manager:RegistHandle('play_atk_eff',function(player,count)
    player.character:PlayEff(count)
end)

---@param player Client_Player
hotpot.function_manager:SetHandle('get_hp',function(player)
    return player.character.max_hp
end)

hotpot.event_manager:RegistHandle('pvpReborn',function(player)
    if place_manager:GetIdByName('pvpsence') == game.PlaceId then
        player.character:PvpReborn()
    end
end)

hotpot.event_manager:RegistHandle('changeHideHead',function(player)
    player.character.__head_vis = not player.character.__head_vis
    player.character:SetOwnerHeadVisible(player.character.__head_vis)
end)

return c
