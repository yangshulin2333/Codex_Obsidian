local _G = _G
local script = script
---@type ClientHotpot
local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type TweenHelper
local tween_helper = hotpot.load.TweenHelper()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local ov = OverlapParams.new()
ov.CollisionGroup = 'check_monster'
local pvpOv = OverlapParams.new()
pvpOv.CollisionGroup = 'pvp_character'

local atk_cold = 0
local character_cfg = hotpot.config.character
local beam = hotpot:GetPath_Loop('pfb.GuideBeam',_G.Resource)
local ISRUN = false
local fol = workspace.Stage
local speed = 100
local ParticleEmitter = 'ParticleEmitter'
local EmitCount = 'EmitCount'
local EmitDelay = 'EmitDelay'
local dashCold = 0

---@class Client_PlayerCharacter:CharacterObject
local c = hotpot.class.new(script, hotpot.files.CharacterObject())
function c.new(character_inst, player_object)
    return c(character_inst, player_object)
end
---@param player_object Client_Player
function c:ctor(character_inst, player_object)
    c.super.ctor(self, character_inst)
    -- print(self.class,"ctor")

    ---@type Client_Player
    self.player = player_object

    self.humanoid.AutoJumpEnabled = false

    self.atk_count = 0
    self.atk_time = 0
    self.heart_num = 3

    self:AddProcess(function()
        repeat self:Wait() until self.player.main_inst:FindFirstChild('pk_state')
        repeat self:Wait() until self.player.main_inst:FindFirstChild('atkSpeed')

        self.pk_stateValue = self.player.main_inst:WaitForChild('pk_state')
        self.speed_value = self.player.main_inst:WaitForChild('atkSpeed')
    end)

    self.ray_cmp = self:AddComponent(hotpot.load.Client_RayComponent())

    self:ListenMouse()

    ui_manager.ui_list.hud_gui:BindAFKBtnClickHandle(self,self.ClickAutoAttackBtn)

    local humanoid = self.humanoid

    -- self:SetJumpPower(0)
    -- self:SetJumpHeight(0)

    -- humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    -- humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
    self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)

    self.pet_part = self.main_inst:WaitForChild('PetPart')

    if place_manager:GetIdByName('pvpsence') == game.PlaceId then
        local guidValue = self.player.main_inst:WaitForChild('guid')
        self.attackCheck = workspace:WaitForChild('AttackCheck'):WaitForChild(guidValue.Value)
    else
        self.attackCheck = self.main_inst:WaitForChild('attackCheck')
    end

    local eff = game.ReplicatedStorage:WaitForChild('Resource'):WaitForChild('pfb'):WaitForChild('SprintEff')
    eff = eff:Clone()
    eff.Parent = self.main_inst
    eff.CFrame = self:GetCFrame()
    local we = Instance.new('WeldConstraint',eff)
    we.Part0 = eff
    we.Part1 = self.root_part
    self.raycastParams = RaycastParams.new()
    self.raycastParams.FilterDescendantsInstances = {
        {self.main_inst},
        workspace.Terrain,
    }
    self.raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    self.dash_eff = eff
end
function c:dtor()
    -- print(self.class,"dtor")
    if self.mouse_co then
        self.mouse_co:Disconnect()
        self.mouse_co = nil
    end
    c.super.dtor(self)
end
function c:OnDead()
    -- print(self.class,"on dead")
end

function c:CreateBeam()
    ---@type Beam
    local be = beam:Clone()
    be.Parent = self.root_part
    be.Enabled = true
    be.Attachment1 = self.root_part:FindFirstChildOfClass('Attachment')

    self.beam = be
end

function c:LinkBeam(att)
    if att and self.beam then
        self.beam.Attachment0 = att
        self.beam.Attachment1 = self.root_part:FindFirstChildOfClass('Attachment')
    end
end

function c:UnLinkBeam()
    if self.beam then
        self.beam.Attachment0 = nil
    end
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

--加载动画
function c:LoadAnimation()
    local equiped = self.player.character_cmp.data.equiped
    local weapon = self.player.Weaponvalue and self.player.Weaponvalue.Value

    ---@type Animation
    local animation = Instance.new('Animation')
    local t 
    if weapon and weapon ~= 0 then
        t = hotpot.config.relics[weapon].w_type
    else
        t = character_cfg[equiped].w_type
    end
    animation.AnimationId = hotpot.pro_cfg.animas[t][1] or 'rbxassetid://567479941'
    self.atk_anima1 = self.humanoid:LoadAnimation(animation)

    ---@type Animation
    local animation = Instance.new('Animation')
    animation.AnimationId = hotpot.pro_cfg.animas[t][2] or 'rbxassetid://567479941'
    self.atk_anima2 = self.humanoid:LoadAnimation(animation)

    ---@type Animation
    local animation = Instance.new('Animation')
    animation.AnimationId = hotpot.pro_cfg.animas[t][3] or 'rbxassetid://913376220'
    self.move_anima = self.humanoid:LoadAnimation(animation)
    local RunAnim = hotpot:GetPath_Loop('Animate.run.RunAnim',self.main_inst)
    RunAnim.AnimationId = animation.AnimationId

    if self.__load then
        return
    end
    self.__load = true

    ---@type Animation
    local animation = Instance.new('Animation')
    animation.AnimationId = 'rbxassetid://127141016792856'
    self.die_anima = self.humanoid:LoadAnimation(animation)
    self.die_anima:GetMarkerReachedSignal('stop'):Connect(function()
        self.die_anima:AdjustSpeed(0)
    end)

    ---@type Animation
    local DashAnian = Instance.new('Animation')
    DashAnian.AnimationId = 'rbxassetid://100719127042012'
    self.dash_anima = self.humanoid:LoadAnimation(DashAnian)

    --2506281703
    local sitAnian = Instance.new('Animation')
    sitAnian.AnimationId = 'rbxassetid://116268760614289'
    self.sit_anima = self.humanoid:LoadAnimation(sitAnian)
end

--攻击一次
function c:Attack()
    if self.player.die then
        return
    end
    self.atk_count = 0
    hotpot.event_manager:Fire('play_atk_eff',self.atk_count)
    if self.atk_count == 0 then
        if self.atk_anima1 then
            self.atk_anima1:Play()
            self.atk_anima1:AdjustSpeed(1.8)
        end
        -- self.atk_count = self.atk_count + 1
    elseif self.atk_count == 1 then
        if os.clock() - self.atk_time < 2 then
            self.atk_anima2:Play()
            self.atk_anima2:AdjustSpeed(1.8)
            self.atk_count = 0
        else
            self.atk_anima1:Play()
            self.atk_anima1:AdjustSpeed(1.8)
            self.atk_count = 1
        end
    end
    self.atk_time = os.clock()

    if place_manager:GetIdByName('pvpsence') == game.PlaceId then
        local monsterResult = workspace:GetPartsInPart(self.attackCheck,ov)
        local playerResult = workspace:GetPartsInPart(self.attackCheck,pvpOv)

        -- print(playerResult)
        self.player.sync_cmp:Add('pvp_player_atk',{
            player_guid = self.player.guid,
            monster = monsterResult,
            player = playerResult,
        })
        return
    end

    if self.pk_stateValue and self.pk_stateValue.Value then
        local result = workspace:GetPartsInPart(self.attackCheck,pvpOv)
        -- print(result)
        local equiped_id = self.player.character_cmp.data.equiped
        local w_type = character_cfg[equiped_id].w_type
        if w_type == 2 then
            wait(.2)
        elseif w_type == 3 then
            wait(.3)
        end
        pcall(function()
            if w_type == 3 then
                audioManager:PlayGloble('Hammer')
            else
                audioManager:PlayGloble('atk',math.random(80,120)/100)
            end
        end)
        hotpot.event_manager:Fire('player_atk_pk',result)
    else
        local result = workspace:GetPartsInPart(self.attackCheck,ov)
        --local result = workspace:GetPartBoundsInRadius(self:GetPosition() + dir * 2,6,ov)
        if result then
            if place_manager:GetIdByName('guildsence') == game.PlaceId then
                self.player.sync_cmp:Add('attackGuildMonster',{
                    root = result[1]
                })
                return
            end
    
            ---@type Client_StageObj
            local stage = self.player.now_stage
            if not stage then
                return
            end
    
            local equiped_id = self.player.character_cmp.data.equiped
            local w_type = character_cfg[equiped_id].w_type
            if w_type == 2 then
                wait(.2)
            elseif w_type == 3 then
                wait(.3)
            end
            pcall(function()
                if w_type == 3 then
                    audioManager:PlayGloble('Hammer')
                else
                    audioManager:PlayGloble('atk',math.random(80,120)/100)
                end
            end)
            if place_manager:GetIdByName('partysence') == game.PlaceId then
                stage:PlayerAttack(nil,self.player)
            elseif place_manager:GetIdByName('challengesence') == game.PlaceId then
                self.player.sync_cmp:Add('attackChallengeMonster',{
                    list = result
                })
            else
                for k,v in ipairs(result)do
                    stage:PlayerAttack(v,self.player)
                end
            end
    
        end
    end

end

--监听鼠标
function c:ListenMouse()
    ---@type Mouse
    local Mouse = self.player.main_inst:GetMouse()

    local ATTACKING = false

    local function ATK()
        local speed = 1 
        if self.speed_value then
            speed = self.speed_value.Value + speed
        end
    
        if self.player.pvp_buff_cmp then
            speed = self.player.pvp_buff_cmp:GetAtkSpeedPer()
        end
    
        local cold = 1/speed
        if os.clock() - atk_cold <= cold then
            return
        end
        atk_cold = os.clock()
    
        if self.player and self.player.gacha_cmp then
            if self.player.gacha_cmp.isRunning then
                return
            end
        end
    
        self:Attack()
    end

    Mouse.Button1Down:Connect(function()
        ATTACKING = true
    end)
    Mouse.Button1Up:Connect(function()
        ATTACKING = false
    end)

    self:AddRenderUpdate('render',function()
        if ATTACKING then
            ATK()
        end
    end)
end

function c:Die()
    self.die_anima:Play()
    -- delay(1,function()
    --     self.hp_ui.Enabled = false
    -- end)
end

function c:Revive(idx)
    self.die_anima:Stop()
    local stage = self.player.now_stage
    
    if place_manager:GetIdByName('partysence') == game.PlaceId then
        self.heart_num = self.heart_num - 1
        ui_manager.ui_list.hud_gui:SetHeartFrameCount(self.heart_num)
        if stage then
            local part = stage.spawn_list[idx]
            if part then
                self:SetBottomPosition(part.Position)
            else
                self:SetBottomPosition(stage.spawn_part.Position)
            end
        end
    elseif place_manager:GetIdByName('guildsence') == game.PlaceId then
        self:SetBottomPosition(workspace.SpawnLocation.Position)
        return
    elseif place_manager:GetIdByName('pvpsence') == game.PlaceId then
        --self:SetBottomPosition(workspace.SpawnLocation.Position)
        return
    else
        if stage then
            self:SetBottomPosition(stage.spawn_part.Position)
        end
    end
end

function c:StartAFK()
    if self.__auto_co then
        return
    end
    if self.IsExist and self:IsExist() then
        self.__auto_co = self:AddUpdate(self.AFK,0.1)
    end
    self.player.afk = true
end

function c:StopAFK()
    if self.__auto_co then
        self.__auto_co:Disconnect()
        self.__auto_co = nil
        self.player.afk = false
    end
end

function c:AFK()
    local speed = 1 
    if self.speed_value then
        speed = self.speed_value.Value + speed
    end

    if self.player.pvp_buff_cmp then
        speed = self.player.pvp_buff_cmp:GetAtkSpeedPer()
    end
    if self.player.shop_cmp:GetDoubleSpeed() then
        speed = speed + 0.2
    end

    local cold = 1/speed
    -- print(cold,speed)
    if os.clock() - atk_cold <= cold then
        return
    end
    atk_cold = os.clock()
    self:Attack()
end

--点击自动攻击按钮
function c:ClickAutoAttackBtn()
    if self.auto then
        self.auto = false
        self:StopAFK()
    else
        self.auto = true
        self:StartAFK()
    end
end

--冲刺
function c:Dash()
    if self.player.die then
        return
    end
    local character = self.main_inst
	local root = self.root_part
	
	if ISRUN then
		return
	end
	ISRUN = true
	
	local interval = 0
	local time_len = 0.3
	local cf = root.CFrame
	local rayDirection = cf.LookVector
	local dis = 0
		
	self:PlayDashEff()
	if self.dash_anima then
		self.dash_anima:Play()
		delay(0.8,function()
			self.dash_anima:Stop()
		end)
	end
	
	while true do
		interval = task.wait()
		time_len = time_len - interval
		if time_len <= 0 then
			break
		end
		dis = interval * speed
		rayDirection = rayDirection * dis
		
		cf = root.CFrame
		
		local raycastResult = workspace:Raycast(cf.Position, rayDirection, self.raycastParams)
		if raycastResult then
			local touchdis = (raycastResult.Position - cf.Position).Magnitude - 1
			if touchdis <= 0 then
				ISRUN = false
				return
			end
			dis = math.min(touchdis,dis)
		end 
		local lookVector = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit
		character:PivotTo( cf + lookVector*dis )
	end
	ISRUN = false
end

--播放冲刺特效
function c:PlayDashEff()
    for k,v in ipairs(self.dash_eff:GetDescendants())do
		if v:IsA(ParticleEmitter)then
			local count = v:GetAttribute(EmitCount)
			local delay_ = v:GetAttribute(EmitDelay)
			count = count or v.Rate
			delay_ = delay_ or 0
			if delay_ > 0 then
				delay(delay_,function()
					v:Emit(count)
				end)
			else
				v:Emit(count)
			end
		end
	end
end

function c:GetNewBottomPosition()
    if self.player.mount_cmp then
        if self.player.mount_cmp.bottom_att then
            return self.player.mount_cmp.bottom_att.WorldPosition
        end
    end
    return c.super.GetBottomPosition(self)
end

hotpot.event_manager:RegistHandle('player_die',function(player)
    player.character:Die()
end)

hotpot.event_manager:RegistHandle('player_revive',function(player,idx)
    player.character:Revive(idx)
end)

hotpot.event_manager:RegistHandle('pk_revive',function(player)
    player.character:Revive()
end)

return c
