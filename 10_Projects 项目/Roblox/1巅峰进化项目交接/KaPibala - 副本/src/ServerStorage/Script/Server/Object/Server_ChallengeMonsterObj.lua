local hotpot = _G.ServerHotpot
---@type TweenHelper
local tween_helper = hotpot.load.TweenHelper()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
local Debris = game:GetService('Debris')
---@type ParticleHelper
local ParticleHelper = hotpot.load.ParticleHelper()
---@type CurveHelper
local curve_helper = hotpot.load.CurveHelper()
---@type Players
local players = game:GetService('Players')
---@type InstanceManager
local inst_manager = hotpot.load.InstanceManager()

local monster_cfg = hotpot.config.PartyMonster
local boss1Model = hotpot:GetPath_Loop('pfb.boos1Model',hotpot.Resource)
local collider = hotpot:GetPath_Loop('pfb.collider',hotpot.Resource)
local hp_ui = hotpot:GetPath_Loop('pfb.monsterHp',hotpot.Resource)
local hit_eff = hotpot:GetPath_Loop('pfb.hitEff.ATM',hotpot.Resource)
local boss1_eff = hotpot:GetPath_Loop('pfb.boss1Eff',hotpot.Resource)
local boss2_eff = hotpot:GetPath_Loop('pfb.boss2_eff',hotpot.Resource)
local boss3_eff = hotpot:GetPath_Loop('pfb.boss3_eff',hotpot.Resource)
local boss4_eff = hotpot:GetPath_Loop('pfb.boss4Eff',hotpot.Resource)
local boss5_eff = hotpot:GetPath_Loop('pfb.boss5eff',hotpot.Resource)
local boss6_eff = hotpot:GetPath_Loop('pfb.boss6Eff',hotpot.Resource)
local ParticleEmitter = 'ParticleEmitter'

---@class Server_ChallengeMonsterObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model,stage,cfg,part,idx,cfg2)
    return c(model,stage,cfg,part,idx,cfg2)
end
function c:ctor(model,stage,cfg,part,idx,cfg2)
    c.super.ctor(self,model)

    self.area_idx = idx
    self.cfg2 = cfg2
    self.name = cfg2.name

    self.guid = hotpot.pro_cfg:GetGuid()

    self.main_inst:SetAttribute('guid',self.guid)
    self.main_inst:SetAttribute('area_idx',idx)

    for k,v in ipairs(self.main_inst:GetDescendants())do
        if v:IsA('BasePart') then
            -- v.CollisionGroup = 'monster'
        end
        if v:IsA('Shirt') then
            if not v.ShirtTemplate or v.ShirtTemplate == '' then
                local res = v:GetAttribute('res')
                if res then
                    v.ShirtTemplate = res
                end
            end
        end
        if v:IsA('Pants') then
            if not v.PantsTemplate or v.PantsTemplate == '' then
                local res = v:GetAttribute('res')
                if res then
                    v.PantsTemplate = res
                end
            end
        end
    end

    self.atk_time = 0

    local collider_ = collider:Clone()
    collider_.Parent = model
    collider_.CFrame = self:GetCFrame()
    local we = Instance.new('WeldConstraint',collider_)
    we.Part0 = self.root_part
    we.Part1 = collider_
    self.collider = collider_
    collider_:SetAttribute('guid',self.guid)

    self.cfg = cfg
    self.is_boss = (part.Name == 'boss')

    ---@type Server_ChallengeStageObj
    self.stage = stage
    ---@type Part
    self.part = part
    ---@type Humanoid
    self.humanoid = self.main_inst:WaitForChild('Humanoid')

    self.humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    self.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
    self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
    self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)

    self.dmg_list = {}
    self.recover_time = 6
    self.move_cold = math.random(40,60)/10
    self.cold_cd = 0

    self:Init()

    self:AddUpdate(self.CheckPlayer,0.5)

    if self.is_boss then
        self.root_part.Anchored = true
        local model = self.stage.area_list[self.area_idx].model
        if model then
            local bossArea = model:FindFirstChild('bossArea')
            if bossArea then
                self.bossArea = bossArea

                self.bossArea:SetAttribute('is_alive',true)
                self.bossArea:SetAttribute('hp',self.hp)
                self.bossArea:SetAttribute('max_hp',self.hp)
                self.bossArea:SetAttribute('name',self.name)
            end
        end
    end
end

function c:dtor()
    self:AddProcess(function()
        if self.hp_ui then
            self.hp_ui.Enabled = false
        end
        local BasePart = 'BasePart'
        self.die_anima:GetMarkerReachedSignal('stop'):Connect(function()
            self.die_anima:AdjustSpeed(0)
        end)
        self.die_anima:Play()
        self:Wait(1.5)
        if not (self.main_inst and self.main_inst.Parent) then
            c.super.dtor(self)
            return
        end
        local cf = self:GetCFrame()
        local new_cf = cf + Vector3.new(0,-2,0)
        self.root_part.Anchored = true
        for k,v in ipairs(self.main_inst:GetDescendants())do
            if v:IsA(BasePart) then
                v.CanCollide = false
            end
        end

        local interval = 0
        local time_len = 1
        local val = 0
        while true do
            interval = interval + self:Wait()
            interval = math.min(interval,time_len)
            val = interval / time_len

            if not (self.main_inst and self.main_inst.Parent) then
                break
            end

            self:SetCFrame(cf:Lerp(new_cf,val))

            for k,v in ipairs(self.main_inst:GetDescendants())do
                if v ~= self.root_part and v ~= self.collider and v:IsA(BasePart) then
                    v.Transparency = val
                end
            end
            if interval >= time_len then
                break
            end
        end


        if self.main_inst then
            self.main_inst:Destroy()
        end
        c.super.dtor(self)
    end)
end

function c:Updata()
    self.recover_time = self.recover_time - 1
    if self.recover_time <= 0 then
        self.recover_time = 6
        self.hp = self.max_hp
        self.dmg_list = {}
        self:PlayHpUi(self.hp,self.max_hp)
        self:StopUpdate()
        self.__dmg = false
        if self.is_boss then
            self.stage:SendAllPlayer('party_boss_recover',{
                hp = self.max_hp,
                max_hp = self.max_hp,
            })
        end
    end
end

function c:GetRandomPos()
    local pos = self.part.Position
    local random_x,random_y
    if self.is_boss then
        random_x = math.random(-1000,1000)/100
        random_y = math.random(-1000,1000)/100
    else
        random_x = math.random(-500,500)/100
        random_y = math.random(-500,500)/100
    end
    return pos + Vector3.new(random_x,3,random_y)
end

function c:Move(step,pos)
    if self.is_boss then
        return
    end
    if self.is_die then
        return
    end
    self.humanoid:MoveTo(pos)
    if not self.move_anima.IsPlaying then
        self.move_anima:Play()
    end
end

function c:CheckPlayer(step)
    if self.target then
        if not self.target.Parent then
            self.target = nil
            return
        end
        if self.target:FindFirstChild('HumanoidRootPart') then
            local pos = self.target.HumanoidRootPart.Position
            local dis = (pos - self:GetPosition()).Magnitude
            local t_dis = 8
            if self.is_boss then
                t_dis = 20
            end
            if dis > t_dis then
                self:Move(step,pos)
            else
                self.humanoid:MoveTo(self:GetPosition())
                if self.move_anima.IsPlaying then
                    self.move_anima:Stop()
                end
                self:Attack()
            end
        end
    end

    for k,player in ipairs(players:GetPlayers())do
        if player.Character then
            if player.Character:FindFirstChild('HumanoidRootPart') then
                local pos = player.Character.HumanoidRootPart.Position
                local dis = (pos - self:GetPosition()).Magnitude
                if dis <= 30 then
                    self.target = player.Character
                    break
                end
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

function c:Init()
    local partName = self.part.Name
    if self.is_boss then
        self.max_hp = self.cfg.boss_hp
        self.hp = self.max_hp
        self.atk = self.cfg.boss_atk
    else
        local hpName = string.format('m%d_hp',tonumber(partName))
        local atkName = string.format('m%d_atk',tonumber(partName))
        self.max_hp = self.cfg[hpName]
        self.atk = self.cfg[atkName]
        self.hp = self.max_hp
    end

    local humanoid = self.humanoid
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    if humanoid then
        local hight = humanoid.HipHeight + self.root_part.Size.Y/2
        local cf = self.part.CFrame
        local pos = cf.Position + Vector3.new(0,hight,0) - Vector3.new(0,self.part.Size.Y/2,0)
        if not self.is_boss then
            pos = pos + Vector3.new(0,3,0)
        end
        self.main_inst:PivotTo(
            CFrame.new(pos,pos + cf.LookVector)
        )
    else
        local cf,size = self:GetBoundingBox()
        local pos = self.part.Position
        if not self.is_boss then
            pos = pos + Vector3.new(0,3,0)
        end
        self:PivotTo(CFrame.new(pos + Vector3.new(0,size.Y/2,0)))
    end

    if not self.is_boss then
        self.root_part.Anchored = true
        delay(0.5,function()
            self.root_part.Anchored = false
            wait(5)
            self.humanoid:MoveTo(self:GetPosition() + Vector3.new(0,0,10))
        end)
    end

    self.hit_eff = hotpot:CloneInst_Loop(hit_eff)
    self.hit_eff.Parent = self.root_part

    if self.is_boss then
        self:BossAnimation()

        local scale = self.main_inst:GetScale()
        ParticleHelper:ReSizeParticle(self.hit_eff,scale)
    else
        local size = self.main_inst:GetScale()
        ---@type BillboardGui
        self.hp_ui = hotpot:CloneInst_Loop(hp_ui)
        self.hp_ui.StudsOffsetWorldSpace = self.hp_ui.StudsOffsetWorldSpace * size
        self.hp_ui.Parent = self.root_part
        self.hp_ui.Frame.name.Text = self.name or ''
        self.hp_ui.MaxDistance = 35
        self:PlayHpUi(self.hp,self.max_hp)
    end

    self:LoadAnimation()
end

function c:PlayHpUi(now,max)
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

--boss动作
function c:BossAnimation()
    local w_type = self.cfg2.is_boss
    local animation = Instance.new('Animation')
    animation.AnimationId = hotpot.pro_cfg.animas[w_type][1]
    self.atk_anima1 = self.humanoid:LoadAnimation(animation)
end

--加载动画
function c:LoadAnimation()
    ---@type Animation
    local animation = Instance.new('Animation')
    animation.AnimationId = 'rbxassetid://567479941'

    local humanoid = self.main_inst:FindFirstChild('Humanoid')
    if not humanoid then
        return
    end
    self.atk_anima = humanoid:LoadAnimation(animation)

    ---@type Animation
    local animation = Instance.new('Animation')
    animation.AnimationId = 'rbxassetid://507766388'

    local humanoid = self.main_inst:FindFirstChild('Humanoid')
    if not humanoid then
        return
    end
    self.idle_anima = humanoid:LoadAnimation(animation)
    self.idle_anima:Play()

    local Animation = Instance.new('Animation')
    Animation.AnimationId = 'rbxassetid://96402589923870'
    self.hurt_track = humanoid:LoadAnimation(Animation)

    ---@type Animation
    local animation = Instance.new('Animation')
    animation.AnimationId = 'rbxassetid://94411743913488'
    self.move_anima = self.humanoid:LoadAnimation(animation)

    --114342440365631
    ---@type Animation
    local animation = Instance.new('Animation')
    animation.AnimationId = 'rbxassetid://114342440365631'
    self.die_anima = self.humanoid:LoadAnimation(animation)

    humanoid.MoveToFinished:Connect(function()
        self.move_anima:Stop()
    end)
end

function c:BeDamage(source,dmg)
    if self.is_die then
        return
    end
    self.__dmg = true
    local old_hp = self.hp
    self.hp = math.max(0,self.hp - dmg)
    self.recover_time = 6
    self:StartUpdate()

    if self.bossArea then
        self.bossArea:SetAttribute('hp',self.hp)
        hotpot.event_manager:FireAll(
            'challenge_boss_hp_change',
            {hp = self.hp,max_hp = self.max_hp}
        )
    end

    self:PlayHpUi(self.hp,self.max_hp)
    if self.hit_eff then
        for k,v in ipairs(self.hit_eff:GetChildren()) do
            if v:IsA('ParticleEmitter') then
                v:Emit(v.Rate)
            end
        end
    end

    -- self.dmg_list[source] = self.dmg_list[source] or 0
    -- self.dmg_list[source] = self.dmg_list[source] + dmg
    if self.hp <= 0 then
        self:StopUpdate()
        -- self:StopAttackUpdate()
        self:Die(source)
        return true
    end
    return false
end

function c:Attack()
    if os.clock() - self.atk_time < 2.5 then
        return
    end

    if self.is_die then
        return
    end

    ---@type Model
    local target = self.target
    if not target then
        return
    end
    local pos = target:GetPivot().Position
    if self.is_boss then
        if (self:GetPosition() - pos).Magnitude > 30 then
            return
        end
    else
    end

    self.atk_time = os.clock()
    local list = {}
    if self.is_boss then
        local player = self.stage.player
        local cha = player.character
        if cha and cha.root_part then
            local pos = cha:GetPosition()
            if (self:GetPosition() - pos).Magnitude <= 45 then
                list[player.guid] = true
            end
        end
    else
        local target = self.target
        if not target then
            return
        end
        local player = players:GetPlayerFromCharacter(target)
        if not player then
            return
        end
        ---@type Server_Player
        local obj = inst_manager:FindObject(player)
        if not obj then
            return
        end
        if obj.character and obj.character.is_die then
            return
        end
        local guid = obj.guid
        list[guid] = true
    end

    self.recover_time = 6
    if self.is_boss then
        delay(1,function()
            self.stage:MonsterAttackPlayer(self.guid,list,self.atk)
        end)
    else
        self.stage:MonsterAttackPlayer(self.guid,list,self.atk)
    end

    pcall(function()
        spawn(function()
            self:AttackAnima()
        end)
        local pos = self:GetPosition()
        local tPos = self.target.PrimaryPart.Position
        self:SetCFrame(
            CFrame.new(pos,Vector3.new(tPos.X,pos.Y,tPos.Z))
        )
    end)
end

function c:AttackAnima()
    if self.is_boss then
        self.atk_anima1:Play()
        local boss_eff = self.cfg2.boss_eff
        if boss_eff == 'boss1_eff' then
            wait(0.8)
            local part = hotpot:CloneInst_Loop(boss1_eff)
            ---@type Model
            local model = boss1Model:Clone()
            model.Parent = workspace
            part.Parent = workspace
            if not (self.root_part and self.root_part.Parent) then
                model:Destroy()
                part:Destroy()
                return
            end
            local cf = self:GetCFrame()
            local pos = self:GetBottomPosition() + cf.LookVector * 12 + Vector3.new(0,3.1,0)
            pos = pos + cf.RightVector * 2
            part.Position = pos
            model:PivotTo(CFrame.new(pos - Vector3.new(0,3,0)))
            for k,v in ipairs(part:GetDescendants())do
                if v:IsA('ParticleEmitter') then
                    v:Emit(v.Rate)
                end
            end
            Debris:AddItem(part,5)
            -- Debris:AddItem(model,1.5)
            self:AddHeartBeatProcess(function()
                self:Wait(1.5)
                local time_len = 0.8
                local interval = 0
                local cf = model:GetPivot()
                while true do
                    interval = math.min(interval+self:Wait(),time_len)
                    cf = cf - Vector3.new(0,0.12,0)
                    model:PivotTo(cf)
                    if interval >= time_len then
                        break
                    end
                end
                Debris:AddItem(model,0)
            end)
        elseif boss_eff == 'boss2_eff' then
            local model = hotpot:CloneInst_Loop(boss2_eff)
            model.Parent = workspace
            local pos = self:GetBottomPosition()
            -- local cf = self:GetCFrame()
            model:PivotTo(CFrame.new(pos))
            model.WindBall.Transparency = 0
            for k,v in ipairs(model:GetDescendants())do
                if v:IsA('ParticleEmitter') then
                    v:Emit(v.Rate)
                end
            end
            wait(1)
            model.WindBall.Transparency = 1
            Debris:AddItem(model,0.5)
        elseif boss_eff == 'boss3_eff' then
            local pos = self:GetBottomPosition()
            local cf = CFrame.new(pos)
            for i = 1,8 do
                local model = hotpot:CloneInst_Loop(boss3_eff)
                model.Parent = workspace
                model:PivotTo(cf)
                local over_dir = cf * CFrame.fromEulerAnglesXYZ(0,math.rad(45 * i),0)
                local over_pos = pos + over_dir.LookVector * 100

                for k,v in ipairs(model:GetDescendants())do
                    if v:IsA('ParticleEmitter') then
                        v.Enabled = true
                    end
                end

                self:AddProcess(function()
                    local time_len = 2
                    local interval = 0
                    local over_cf = CFrame.new(over_pos)
                    while true do
                        interval = math.min(interval+self:Wait(),time_len)
                        local now_cf = cf:Lerp(over_cf,interval / time_len)
                        model:PivotTo(now_cf)
                        if interval >= time_len then
                            break
                        end
                    end
                    model:Destroy()
                end)
            end
        elseif boss_eff == 'boss4_eff' then
            ---@type Model
            local ball = boss4_eff:FindFirstChild('ball')
            ball = hotpot:CloneInst_Loop(ball)
            ball.Parent = workspace
            ---@type Model
            local eff = boss4_eff:FindFirstChild('boom')
            eff = hotpot:CloneInst_Loop(eff)
            local ParticleEmitter = 'ParticleEmitter'
            for k,v in ipairs(eff:GetDescendants())do
                if v:IsA(ParticleEmitter) then
                    v.Enabled = false
                end
            end
            local cf = self:GetCFrame()
            ball:PivotTo(cf + cf.LookVector * 20 + Vector3.new(0,30,0))
            local cha_pos = self.cha_pos
            if not cha_pos then
                cha_pos = self:GetBottomPosition() + cf.LookVector * 10
            end
            local bottomPos = self:GetBottomPosition()
            cha_pos = Vector3.new(cha_pos.X,bottomPos.Y + 0.25,cha_pos.Z)
            self:AddHeartBeatProcess(function()
                local interval = 0
                local time_len = 0.8
                while true do
                    interval = math.min(interval + self:Wait(),time_len)
                    ball:ScaleTo(0.5 + (interval / time_len)*0.5)
                    if interval >= time_len then
                        break
                    end
                end
                interval = 0
                time_len = 0.3
                local startPos = ball:GetPivot().Position
                while true do
                    interval = math.min(interval + self:Wait(),time_len)
                    ball:PivotTo(CFrame.new(startPos:Lerp(cha_pos,interval / time_len)))
                    if interval >= time_len then
                        break
                    end
                end
                ball:Destroy()
                eff:PivotTo(CFrame.new(cha_pos))
                eff.Parent = workspace
                for k,v in ipairs(eff:GetDescendants())do
                    if v:IsA(ParticleEmitter) then
                        local EmitDelay = v:GetAttribute('EmitDelay')
                        local EmitCount = v:GetAttribute('EmitCount')
                        if EmitDelay and EmitDelay > 0 then
                            delay(EmitDelay,function()
                                v:Emit(EmitCount)
                            end)
                        else
                            v:Emit(EmitCount)
                        end
                    end
                end
                Debris:AddItem(eff,1)
            end)
        elseif boss_eff == 'boss5_eff' then
            local cf = self:GetCFrame()
            local cha_pos = self.cha_pos
            if not cha_pos then
                cha_pos = self:GetBottomPosition() + cf.LookVector * 10
            end
            local eff = hotpot:CloneInst_Loop(boss5_eff)
            eff.Position = cha_pos
            eff.Parent = workspace
            for k,v in ipairs(eff:GetDescendants())do
                if v:IsA(ParticleEmitter) then
                    local EmitDelay = v:GetAttribute('EmitDelay')
                    local EmitCount = v:GetAttribute('EmitCount')
                    EmitDelay = EmitDelay or 0
                    EmitDelay = EmitDelay + 0.2
                    if EmitDelay and EmitDelay > 0 then
                        delay(EmitDelay,function()
                            v:Emit(EmitCount)
                        end)
                    else
                        v:Emit(EmitCount)
                    end
                end
            end
            Debris:AddItem(eff,3)
        elseif boss_eff == 'boss6_eff' then
            self:AddProcess(function()
                local cf = self:GetCFrame()
                local cha_pos = self.cha_pos
                if not cha_pos then
                    cha_pos = self:GetBottomPosition() + cf.LookVector * 10
                end
                for i = 1,4 do
                    local pos = self:GetPosition() + Vector3.new(0,20,0) + cf.LookVector * 5
                    pos = pos + cf.RightVector * math.random(-200,200)/10
                    local ball = boss6_eff:FindFirstChild('火球')
                    ball = hotpot:CloneInst_Check(ball)
                    local eff1 = boss6_eff:FindFirstChild('火球出现')
                    eff1 = hotpot:CloneInst_Check(eff1)
                    eff1.Position = pos
                    eff1.Parent = workspace
                    for k,v in ipairs(eff1:GetDescendants())do
                        if v:IsA(ParticleEmitter) then
                            local EmitDelay = v:GetAttribute('EmitDelay')
                            local EmitCount = v:GetAttribute('EmitCount')
                            EmitDelay = EmitDelay or 0
                            EmitDelay = EmitDelay + 0.2
                            if EmitDelay and EmitDelay > 0 then
                                delay(EmitDelay,function()
                                    v:Emit(EmitCount)
                                end)
                            else
                                v:Emit(EmitCount)
                            end
                        end
                    end
                    Debris:AddItem(eff1,2)
                    ball.Position = pos
                    ball.Parent = workspace
                    self:AddHeartBeatProcess(function()
                        local time_len = 0.75
                        local interval = 0
                        local startPos = pos
                        local overPos = cha_pos
                        local centerPos = (startPos + overPos) / 2 + cf.LookVector * 10
                        while true do
                            interval = math.min(interval + self:Wait(),time_len)
                            local pos = curve_helper:BezierCurve(startPos,centerPos,overPos,interval / time_len)
                            ball.Position = pos
                            if interval >= time_len then
                                break
                            end
                        end
                        Debris:AddItem(ball,0)
                        local eff2 = boss6_eff:FindFirstChild('火球爆炸')
                        eff2 = hotpot:CloneInst_Check(eff2)
                        local bottom = self:GetBottomPosition()
                        eff2.Position = Vector3.new(cha_pos.X,bottom.Y + 0.5,cha_pos.Z)
                        eff2.Parent = workspace
                        for k,v in ipairs(eff2:GetDescendants())do
                            if v:IsA(ParticleEmitter) then
                                local EmitDelay = v:GetAttribute('EmitDelay')
                                local EmitCount = v:GetAttribute('EmitCount')
                                EmitDelay = EmitDelay or 0
                                EmitDelay = EmitDelay + 0.2
                                if EmitDelay and EmitDelay > 0 then
                                    delay(EmitDelay,function()
                                        v:Emit(EmitCount)
                                    end)
                                else
                                    v:Emit(EmitCount)
                                end
                            end
                        end
                        Debris:AddItem(eff2,2)
                    end)
                    self:Wait(.2)
                end
            end)
        end
    else
        self.atk_anima:Play()
    end
end

function c:Die(source)
    pcall(function()
        if self.bossArea then
            self.bossArea:SetAttribute('is_alive',false)
        end
    end)
    self.is_die = true
    self.source = source
    self:StopUpdate()
    self.stage:MonsterDie(self)
    self:dtor()
end

return c