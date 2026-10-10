local hotpot = _G.ServerHotpot
---@type ParticleHelper
local ParticleHelper = hotpot.load.ParticleHelper()
local Debris = game:GetService('Debris')
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local tween_helper = hotpot.load.TweenHelper()

local collider = hotpot:GetPath_Loop('pfb.collider',hotpot.Resource)
local hit_eff = hotpot:GetPath_Loop('pfb.hitEff.ATM',hotpot.Resource)
local hp_ui = hotpot:GetPath_Loop('pfb.monsterHp',hotpot.Resource)
local ParticleEmitter = 'ParticleEmitter'
local bossAreaFol = workspace:WaitForChild('Stage'):WaitForChild('bossArea')
local boss1_eff = hotpot:GetPath_Loop('pfb.boss1Eff',hotpot.Resource)
local boss2_eff = hotpot:GetPath_Loop('pfb.boss2_eff',hotpot.Resource)
local boss3_eff = hotpot:GetPath_Loop('pfb.boss3_eff',hotpot.Resource)
local boss4_eff = hotpot:GetPath_Loop('pfb.boss4Eff',hotpot.Resource)
local boss5_eff = hotpot:GetPath_Loop('pfb.boss5eff',hotpot.Resource)
local boss6_eff = hotpot:GetPath_Loop('pfb.boss6Eff',hotpot.Resource)
local ParticleEmitter = 'ParticleEmitter'
local dropRelics1 = {29,50,51,38,30,23,15,34}
local dropRelics2 = {71,36}

---@class Server_PvpMonsterObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model,stage,cfg,part)
    return c(model,stage,cfg,part)
end
function c:ctor(model,stage,cfg,part)
    c.super.ctor(self,model)
    ---@type Server_PvpStageObj
    self.stage = stage
    self.cfg = cfg
    self.part = part

    if cfg.is_boss then
        self.bossAreaPart = bossAreaFol:FindFirstChild(part.Name)
        self:SetModelTransparency(1)
        self.eff_att = hotpot:GetPath_Loop('eff.Main',self.main_inst)
        self.root_part:SetAttribute('hide',true)
    end
    self.root_part.Anchored = true

    self.dmg_list = {}
    self.guid = hotpot.pro_cfg:GetGuid()

    self.main_inst:SetAttribute('guid',self.guid)

    for k,v in ipairs(self.main_inst:GetDescendants())do
        if v:IsA('BasePart') then
            v.CollisionGroup = 'monster'
        end
    end

    self.atk_time = 0
    self.recover_time = 0

    local collider_ = collider:Clone()
    collider_.Parent = model
    collider_.CFrame = self:GetCFrame()
    local we = Instance.new('WeldConstraint',collider_)
    we.Part0 = self.root_part
    we.Part1 = collider_
    self.collider = collider_
    collider_:SetAttribute('guid',self.guid)
    collider_:SetAttribute('hide',true)

    self.humanoid = self.main_inst:WaitForChild('Humanoid')

    self:AddUpdate(self.UpdateRecover,1)
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

function c:UpdateRecover()
    self.recover_time = self.recover_time - 1
    if self.recover_time <= 0 then
        self:StopAttackUpdate()
    end
end

function c:Init()
    self.max_hp = self.cfg.hp
    self.hp = self.max_hp
    self.atk = 1--self.cfg.attack

    self.gold = math.random(self.cfg.gold[1],self.cfg.gold[2])
    self.gems = math.random(self.cfg.gems[1],self.cfg.gems[2])
    self.pvpCoinPer = self.cfg.pvpCoin[1]
    self.pvpCoin = self.cfg.pvpCoin[2]

    if self.bossAreaPart then
        self.bossAreaPart:SetAttribute('is_alive',true)
        self.bossAreaPart:SetAttribute('hp',self.hp)
        self.bossAreaPart:SetAttribute('max_hp',self.max_hp)
    end

    local humanoid = self.humanoid
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    if humanoid then
        local hight = humanoid.HipHeight + self.root_part.Size.Y/2
        local cf = self.part.CFrame
        local pos = cf.Position + Vector3.new(0,hight,0) - Vector3.new(0,self.part.Size.Y/2,0)
        self.main_inst:PivotTo(
            CFrame.new(pos,pos + cf.LookVector) 
        )
    else
        local cf,size = self:GetBoundingBox()
        local pos = self.part.Position
        self:PivotTo(CFrame.new(pos + Vector3.new(0,size.Y/2,0)))
    end

    self.main_inst.Parent = self.stage.monster_fol

    self.hit_eff = hotpot:CloneInst_Loop(hit_eff)
    self.hit_eff.Parent = self.root_part

    if self.cfg.is_boss then
        self:BossAnimation()

        local scale = self.main_inst:GetScale()
        ParticleHelper:ReSizeParticle(self.hit_eff,scale)
    else
        local size = self.main_inst:GetScale()
        ---@type BillboardGui
        self.hp_ui = hotpot:CloneInst_Loop(hp_ui)
        self.hp_ui.StudsOffsetWorldSpace = self.hp_ui.StudsOffsetWorldSpace * size
        self.hp_ui.Parent = self.root_part
        self.hp_ui.Frame.name.Text = self.cfg.name or ''
        self.hp_ui.MaxDistance = 35
        self:PlayHpUi(self.hp,self.max_hp)
    end

    self:LoadAnimation()
end

function c:InitPool(big_boss)
    self.pool = {}
    --金币
    local gold = self.gold
    local ramdom = math.random(8,10)
    local temp = math.floor(gold / ramdom)
    for i=1,ramdom do
        local g = math.ceil(temp * math.random(800,1200)/1000)
        table.insert(self.pool,{1,3,g})
    end

    --钻石
    local gems = self.gems
    local ramdom = math.random(8,10)
    local temp = math.floor(gems / ramdom)
    for i=1,ramdom do
        local g = math.ceil(temp * math.random(800,1200)/1000)
        table.insert(self.pool,{1,2,g})
    end
    
    --遗物
    local list = hotpot:CloneTable(dropRelics1)
    local ra = Random.new()
    ra:Shuffle(list)
    table.insert(self.pool,{4,list[1],1})
    table.insert(self.pool,{4,list[2],1})

    if math.random() <= 0.2 then
        table.insert(self.pool,{4,dropRelics2[1],1})
    else
        if math.random() <= 0.2 then
            table.insert(self.pool,{4,dropRelics2[2],1})
        end
    end

    if big_boss then
        local ran = math.random(1,10000)
        if ran <= 100 then
            table.insert(self.pool,{4,154,1})
        else
            ran = math.random(1,10000)
            if ran <= 100 then
                table.insert(self.pool,{4,155,1})
            else
                ran = math.random(1,10000)
                if ran <= 100 then
                    table.insert(self.pool,{4,156,1})
                end 
            end 
        end
    else
        local ran = math.random(1,10000)
        if ran <= 100 then
            table.insert(self.pool,{4,151,1})
        else
            ran = math.random(1,10000)
            if ran <= 100 then
                table.insert(self.pool,{4,152,1})
            else
                ran = math.random(1,10000)
                if ran <= 100 then
                    table.insert(self.pool,{4,153,1})
                end 
            end 
        end
    end

    --pvpCoin
    local pvpCoin = self.pvpCoin
    local ramdom = 10
    local temp = math.floor(pvpCoin / ramdom)
    for i=1,ramdom do
        local g = temp
        if math.random() <= 0.5 then
            g = g - math.random(1,2)
        else
            g = g + math.random(1,2)
        end
        g = math.clamp(g,1,10)
        table.insert(self.pool,{1,12,g})
    end

    --锻造石
    table.insert(self.pool,{11,1,1})
    if self.cfg.id == 8 then
    else
        table.insert(self.pool,{11,2,1})
        if math.random() <= 0.02 then
            table.insert(self.pool,{11,3,1})
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

--boss动作
function c:BossAnimation()
    local w_type = self.cfg.is_boss
    local animation = Instance.new('Animation')
    animation.AnimationId = hotpot.pro_cfg.animas[w_type][1]
    self.atk_anima1 = self.humanoid:LoadAnimation(animation)
end

function c:SetModelTransparency(num)
    local BasePart = 'BasePart'
    local hide = 'hide'
    local transparency = 'transparency'
    for k,v in ipairs(self.main_inst:GetDescendants())do
        if v:IsA(BasePart) then
            if v:GetAttribute(hide) or v:GetAttribute(transparency) then
                v.Transparency = 1
            else
                v.Transparency = num
            end
        end
    end
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
    Animation.AnimationId = 'rbxassetid://79394965634595'
    self.hurt_track = humanoid:LoadAnimation(Animation)

    ---@type Animation
    local animation = Instance.new('Animation')
    animation.AnimationId = 'rbxassetid://109873597168666'
    self.move_anima = self.humanoid:LoadAnimation(animation)

    if self.cfg.is_boss then
        self.move_anima:GetMarkerReachedSignal('eff'):Connect(function()
            self:PlayEff()
        end)
        self.move_anima:Play()
        self.move_anima:AdjustSpeed(0.7)
        delay(0.2,function()
            self:SetModelTransparency(0)
        end)
    end

    --114342440365631
    ---@type Animation
    local animation = Instance.new('Animation')
    animation.AnimationId = 'rbxassetid://114342440365631'
    self.die_anima = self.humanoid:LoadAnimation(animation)
end

function c:BeDamage(source,dmg)
    dmg = 1
    if self.is_die then
        return
    end
    self.__dmg = true
    local old_hp = self.hp
    self.hp = math.max(0,self.hp - dmg)

    if self.bossAreaPart then
        self.bossAreaPart:SetAttribute('hp',self.hp)
    end

    dmg = math.min(old_hp,dmg)
    self.recover_time = 3
    -- self:StartUpdate()
    self:StartAttackUpdate()
    if self.cfg.is_boss then
        pcall(function()
            hotpot.event_manager:FireAll('pvp_boss_hp_change',{
                id = self.cfg.id,
                hp = self.hp,
                max_hp = self.max_hp,
            })
        end)
    end

    self:PlayHpUi(self.hp,self.max_hp)
    if self.hit_eff then
        for k,v in ipairs(self.hit_eff:GetChildren()) do
            if v:IsA('ParticleEmitter') then
                v:Emit(v.Rate)
            end
        end
    end
    if self.hurt_track then
        self.hurt_track:Play()
    end

    self.dmg_list[source] = self.dmg_list[source] or 0
    self.dmg_list[source] = self.dmg_list[source] + dmg
    if self.hp <= 0 then
        -- self:StopUpdate()
        self:StopAttackUpdate()

        if self.bossAreaPart then
            self.bossAreaPart:SetAttribute('is_alive',false)
        end

        self:Die(source)
        return true
    end
    return false
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
    if os.clock() - self.atk_time < 2.5 then
        return
    end

    if self.is_die then
        return
    end

    self.atk_time = os.clock()

    local dis = 45
    if not self.cfg.is_boss then
        dis = 20
    end
    for player,_ in pairs(self.stage.player_list)do
        if player and player.character and not player.character.is_die then
            local pos = player.character:GetPosition()
            local dis = (self.part.Position - pos).Magnitude
            if dis <= 45 then
                pcall(function()
                    spawn(function()
                        delay(1,function()
                            if player and player.character then
                                player.character:BeDamage(nil,1)
                            end
                        end)
                    end)
                end)
            end
        end
    end

    -- self.recover_time = 6

    pcall(function()
        spawn(function()
            self:AttackAnima()
        end)
    end)
end

function c:AttackAnima()
    if self.cfg.is_boss then
        self.atk_anima1:Play()
        local boss_eff = self.cfg.boss_eff
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
    self.is_die = true
    self.source = source
    self.stage:MonsterDie(self,source)
    -- self:StopUpdate()

    -- self.stage:DestroyMonster(self.guid)
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

return c