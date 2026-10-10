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
local ParticleEmitter = 'ParticleEmitter'
local path = hotpot:GetPath_Loop('Pumpkin.path',workspace)
local root = hotpot:GetPath_Loop('Pumpkin.root',workspace)
local boxList = {19,19,20,20,21,21,22,22,23,23}

---@class Server_PumpkinMonsterObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model,mgr,boss_num)
    return c(model,mgr,boss_num)
end
function c:ctor(model,mgr,boss_num)
    c.super.ctor(self,model)

    ---@type Server_WSJManager
    self.wsj_mgr = mgr

    self.move_stage = 1
    self.now_pos = 0
    self.next_pos = 1
    self.now_pos_part = root
    self.next_pos_part = path:FindFirstChild(tostring(self.next_pos))

    self.bossNum = boss_num
    
    self.guid = hotpot.pro_cfg:GetGuid()

    for k,v in ipairs(self.main_inst:GetDescendants())do
        if v:IsA('BasePart') then
            v.CollisionGroup = 'monster'
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

    self.reward_list = {
        [80] = false,[50] = false
    }

    self.atk_time = 0
    self.be_damage_time = 0

    spawn(function()
        wait(3)
        if self.bossNum == 1 then
            local effbase = hotpot:GetPath_Loop('Pumpkin.eff',workspace)
            local eff = hotpot:CloneInst_Loop(effbase)
            local weld = Instance.new('WeldConstraint',eff)
            eff.Parent = self.main_inst
            eff.Position = effbase.Position
            weld.Part0 = eff
            weld.Part1 = self.root_part
            eff.Anchored = false
            self.atk_eff = eff
        else
            local effbase = hotpot:GetPath_Loop('Pumpkin.Leoeff',workspace)
            local eff = hotpot:CloneInst_Loop(effbase)
            ParticleHelper:ReSizeParticle(eff,3)
            local weld = Instance.new('WeldConstraint',eff)
            eff.Parent = self.main_inst
            eff.Position = effbase.Position
            weld.Part0 = eff
            weld.Part1 = self.root_part
            eff.Anchored = false
            self.atk_eff = eff
        end
    end)

    local collider_ = collider:Clone()
    collider_.Parent = model
    collider_.CFrame = self:GetCFrame()
    local we = Instance.new('WeldConstraint',collider_)
    we.Part0 = self.root_part
    we.Part1 = collider_
    self.collider = collider_
    collider_:SetAttribute('Pumpkin',true)
    collider_:SetAttribute('hide',true)

    ---@type Humanoid
    self.humanoid = self.main_inst:WaitForChild('Humanoid')

    self.humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    -- self.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
    self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
    self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)

    ---@type table<Server_Player,number>
    self.dmg_list = {}
    self.new_dmg_list = {}
    self.recover_time = 10
    self.cold_cd = 0

    self.root_part.Anchored = true

    self:SetModelTransparency(1)
    self:Init()
    self.__can_dmg = false
    self:AddProcess(function()
        self:Wait(8)
        self.__can_dmg = true
    end)
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
        self.recover_time = 5
        self.hp = self.max_hp
        self.dmg_list = {}
        self:PlayHpUi(self.hp,self.max_hp)
        self:StopUpdate()
        self.__dmg = false
        if self.cfg.is_boss then
            self.stage:SendAllPlayer('party_boss_recover',{
                hp = self.max_hp,
                max_hp = self.max_hp,
            })
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

function c:SetModelTransparency(num)
    local BasePart = 'BasePart'
    local hide = 'hide'
    for k,v in ipairs(self.main_inst:GetDescendants())do
        if v:IsA(BasePart) then
            if v:GetAttribute(hide) then
                v.Transparency = 1
            else
                v.Transparency = num
            end
        end
    end
end

function c:Init()
    if self.bossNum == 1 then
        self.max_hp = hotpot.pro_cfg.PumpkinBossHp / 2
        self.hp = hotpot.pro_cfg.PumpkinBossHp / 2
    else
        self.max_hp = hotpot.pro_cfg.PumpkinBossHp
        self.hp = hotpot.pro_cfg.PumpkinBossHp
    end
    self.atk = 0

    self.main_inst.Parent = workspace.Pumpkin

    local humanoid = self.humanoid
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    local part = hotpot:GetPath_Loop('Pumpkin.root',workspace)

    self:SetCFrame(CFrame.new(Vector3.new(0,10,0)))

    self.hit_eff = hotpot:CloneInst_Loop(hit_eff)
    self.hit_eff.Parent = self.root_part

    local scale = self.main_inst:GetScale()
    ParticleHelper:ReSizeParticle(self.hit_eff,scale)

    self.eff_att = hotpot:GetPath_Loop('eff.Main',self.main_inst)

    self:LoadAnimation()
    self:AddProcess(function()
        if humanoid then
            -- local _,size = self.main_inst:GetBoundingBox()
            local hight = humanoid.HipHeight + self.root_part.Size.Y/2
            local cf = part.CFrame
            local pos = cf.Position + Vector3.new(0,hight,0) + Vector3.new(0,part.Size.Y/2,0)
            self.main_inst:PivotTo(
                CFrame.new(pos,pos + cf.LookVector)
            )
        else
            local cf,size = self:GetBoundingBox()
            self:PivotTo(CFrame.new(self.part.Position + Vector3.new(0,size.Y/2,0)))
        end
    end)

    if self.bossNum == 3 then
        spawn(function()
            wait(15)
            self:AddHeartBeatUpdate(self.Move)
        end)
    end
end

function c:PlayEff()
    for k,v in ipairs(self.eff_att:GetDescendants())do
        if v:IsA('ParticleEmitter') then
            v.Enabled = true
            delay(0.2,function()
                v.Enabled = false
            end)
        end
    end
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

--加载动画
function c:LoadAnimation()
    local humanoid = self.main_inst:FindFirstChild('Humanoid')
    
    ---@type Animation
    local animation = Instance.new('Animation')
    if self.bossNum == 1 then
        animation.AnimationId = 'rbxassetid://76816351337028'
    else
        animation.AnimationId = 'rbxassetid://87854456364288'
    end

    if not humanoid then
        return
    end

    local walkAnima = Instance.new('Animation')
    walkAnima.AnimationId = 'rbxassetid://94411743913488'
    self.walk_anima = humanoid:LoadAnimation(walkAnima)
    self.walk_anima:AdjustSpeed(0.1)

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
    animation.AnimationId = 'rbxassetid://109873597168666'
    self.move_anima = self.humanoid:LoadAnimation(animation)

    --114342440365631
    ---@type Animation
    local animation = Instance.new('Animation')
    animation.AnimationId = 'rbxassetid://114342440365631'
    self.die_anima = self.humanoid:LoadAnimation(animation)

    self.move_anima:GetMarkerReachedSignal('eff'):Connect(function()
        self:PlayEff()
    end)
    self.move_anima:Play()
    self.move_anima:AdjustSpeed(0.7)
    delay(0.2,function()
        self:SetModelTransparency(0)
    end)
end

function c:BeDamage(source,dmg)
    if not self.__can_dmg then
        return
    end
    dmg = 1
    if self.is_die then
        return
    end
    self.__dmg = true
    local old_hp = self.hp
    self.hp = math.max(0,self.hp - dmg)
    dmg = math.min(old_hp,dmg)

    self.be_damage_time = os.clock()

    self:PlayHitEff()

    hotpot.event_manager:FireAll('SyncPumpkinHP',self.hp,self.max_hp,self:GetPosition())
    if not self.hurt_track.IsPlaying then
        self.hurt_track:Play()
    end

    self.dmg_list[source] = self.dmg_list[source] or 0
    self.dmg_list[source] = self.dmg_list[source] + dmg

    self.new_dmg_list[source] = self.new_dmg_list[source] or 0
    self.new_dmg_list[source] = self.new_dmg_list[source] + dmg

    pcall(function()
        self:CheckDmg(source)
    end)

    self:StartAttackUpdate()

    if self.hp <= 0 then
        self:StopUpdate()
        self:StopAttackUpdate()
        self:Die()
        return true
    end

    return false
end

function c:PlayHitEff()
    if self.hit_eff then
        for k,v in ipairs(self.hit_eff:GetChildren()) do
            if v:IsA('ParticleEmitter') then
                v:Emit(v.Rate)
            end
        end
    end
end

function c:CheckDmg()
    local per = self.hp / self.max_hp * 100
    for k,v in pairs(self.reward_list) do
        if per <= k and not v then
            self.reward_list[k] = true
            for playerObj,_ in pairs(self.dmg_list)do
                pcall(function()
                    if playerObj.IsExist and playerObj:IsExist() then
                        if playerObj.main_inst and playerObj.main_inst.Parent then
                            ---@type Server_RewardComponent
                            local reward_cmp = playerObj.reward_cmp
                            if reward_cmp then
                                if self.bossNum == 1 then
                                    reward_cmp:AddReward({{6,13,1}})
                                elseif self.bossNum == 2 then
                                    reward_cmp:AddReward({{6,12,1}})
                                else
                                    reward_cmp:AddReward({{6,13,1}})
                                end
                            end
                        end
                    end 
                end)
            end
        end
    end
end

--开始攻击更新
function c:StartAttackUpdate()
    if self.atk_co then
        return
    end
    self.atk_co = self:AddUpdate(self.Attack)
end

--停止攻击更新
function c:StopAttackUpdate()
    if self.atk_co then
        self.atk_co:Disconnect()
        self.atk_co = nil
    end
end

function c:Attack()
    if os.clock() - self.atk_time < 3 then
        return
    end

    if os.clock() - self.be_damage_time > 6 then
        self:StopAttackUpdate()
        return
    end

    self.atk_time = os.clock()

    if self.is_die then
        return
    end

    self:AttackAnima()
end

function c:AttackAnima()
    self.atk_anima:Play()
    local delay_time = 0
    if self.bossNum == 1 then
        delay_time = 0.85
    else
        delay_time = 0.35
    end
    delay(delay_time,function()
        for k,v in ipairs(self.atk_eff:GetDescendants())do
            if v:IsA('ParticleEmitter') then
                local EmitCount = v:GetAttribute('EmitCount')
                local EmitDelay = v:GetAttribute('EmitDelay')
                EmitCount = EmitCount or v.Rate
                if EmitDelay and EmitDelay > 0 then
                    delay(EmitDelay,function()
                        v:Emit(EmitCount)
                    end)
                else
                    v:Emit(EmitCount)
                end
            end
        end

        for k,player in ipairs(players:GetPlayers())do
            local r,e = pcall(function()
                ---@type Server_Player
                local obj = inst_manager:FindObject(player)
                if obj then
                    ---@type Server_PlayerCharacter
                    local character = obj.character
                    if character then
                        local root = character.root_part
                        local dis = (root.Position - self:GetPosition()).Magnitude
                        if dis <= 20 then
                            character:BeDamage(self.guid,1)
                            hotpot.event_manager:Fire(
                                obj,
                                'SyncPumpkinDamage',
                                root.Position
                            )
                        end
                    end
                end
            end)
            if not r then
                warn(e)
            end
        end
    end)
end

function c:Die(source)
    self.is_die = true
    self:StopUpdate()

    --结算
    for playerObj,_ in pairs(self.dmg_list)do
        pcall(function()
            if playerObj.IsExist and playerObj:IsExist() then
                if playerObj.main_inst and playerObj.main_inst.Parent then
                    ---@type Server_RewardComponent
                    local reward_cmp = playerObj.reward_cmp
                    if reward_cmp then
                        if self.bossNum == 1 then
                            reward_cmp:AddReward({{6,13,3}})

                            local ran = math.random(1,10000)
                            if ran <= 100 then
                                reward_cmp:AddReward({{4,151,1}})
                            else
                                ran = math.random(1,10000)
                                if ran <= 100 then
                                    reward_cmp:AddReward({{4,152,1}})
                                end
                            end

                        elseif self.bossNum == 2 then
                            reward_cmp:AddReward({{6,12,3}})
                            playerObj.title_cmp:AddPoint(5,1)

                            local ran = math.random(1,10000)
                            if ran <= 50 then
                                reward_cmp:AddReward({{4,153,1}})
                            else
                                ran = math.random(1,10000)
                                if ran <= 50 then
                                    reward_cmp:AddReward({{4,154,1}})
                                end
                            end
                        elseif self.bossNum == 3 then
                            reward_cmp:AddReward({{6,23,2}})
                        end
                    end
                end
            end
        end)
    end

    if self.bossNum == 3 then
        for playerObj,_ in pairs(self.dmg_list)do
            pcall(function()
                if playerObj.IsExist and playerObj:IsExist() then
                    if playerObj.main_inst and playerObj.main_inst.Parent then
                        ---@type Server_RewardComponent
                        local reward_cmp = playerObj.reward_cmp
                        if reward_cmp then
                            local ran = math.random(1,10000)
                            if ran <= 1 then
                                reward_cmp:AddReward({{4,155,1}})
                            else
                                ran = math.random(1,10000)
                                if ran <= 1 then
                                    reward_cmp:AddReward({{4,156,1}})
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    self.wsj_mgr:BossDie()
end

function c:Move(step)
    local part1 = self.now_pos_part
    local part2 = self.next_pos_part
    if not part1 or not part2 then
        return
    end

    local dir = (part2.Position - part1.Position).Unit

    local pos = self:GetPosition()
    pos = pos + dir * step * 3

    self:SetCFrame(CFrame.new(pos,pos+dir))

    local p1 = Vector3.new(pos.X,0,pos.Z)
    local p2 = Vector3.new(part2.Position.X,0,part2.Position.Z)
    if (p1 - p2).Magnitude <= 5 then
        if self.walk_anima.IsPlaying then
            self.walk_anima:Stop()
        end

        self.now_pos = self.now_pos + 1
        self.next_pos = self.next_pos + 1
        self.next_pos_part = path:FindFirstChild(tostring(self.next_pos))
        self.now_pos_part = path:FindFirstChild(tostring(self.now_pos))

        if self.now_pos_part:GetAttribute('jump') then
            self:JumpStage()
        end
        return
    end

    if not self.walk_anima.IsPlaying then
        self.walk_anima:Play()
        self.walk_anima:AdjustSpeed(0.3)
    end
end

function c:JumpStage()
    local part = self.next_pos_part
    if not part then
        return false
    end
    local humanoid = self.humanoid
    local hight = humanoid.HipHeight + self.root_part.Size.Y/2
    local cf = part.CFrame
    local pos = cf.Position + Vector3.new(0,hight,0) - Vector3.new(0,part.Size.Y/2,0)
    self.main_inst:PivotTo(
        CFrame.new(pos,pos + cf.LookVector)
    )

    self.now_pos = self.now_pos + 1
    self.next_pos = self.next_pos + 1
    self.next_pos_part = path:FindFirstChild(tostring(self.next_pos))
    self.now_pos_part = path:FindFirstChild(tostring(self.now_pos))

    local now_stage = self.move_stage
    self.move_stage = self.move_stage + 1
    workspace.Pumpkin:SetAttribute('stage',self.move_stage)

    local list = self.new_dmg_list
    self.new_dmg_list = {}
    hotpot.event_manager:FireAll('bossJump',self.move_stage)
    for playerObj,_ in pairs(list)do
        pcall(function()
            if playerObj.IsExist and playerObj:IsExist() then
                if playerObj.main_inst and playerObj.main_inst.Parent then
                    ---@type Server_RewardComponent
                    local reward_cmp = playerObj.reward_cmp
                    if reward_cmp then
                        local num = (now_stage >= 6) and 2 or 1
                        reward_cmp:AddReward({{6,boxList[now_stage],num}})
                    end
                end
            end
        end)
    end
end

return c