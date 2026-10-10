local hotpot = _G.ClientHotpot
---@type TweenHelper
local tween_helper = hotpot.load.TweenHelper()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
local Debris = game:GetService('Debris')
---@type ParticleHelper
local ParticleHelper = hotpot.load.ParticleHelper()
---@type CurveHelper
local curve_helper = hotpot.load.CurveHelper()

local boss1Model = hotpot:GetPath_Loop('pfb.boos1Model',_G.Resource)
local hp_ui = hotpot:GetPath_Loop('pfb.monsterHp',_G.Resource)
local monster_cfg = hotpot.config.monster
local stageDropCfg = hotpot.config.stageDrop
local relicsCfg = hotpot.config.relics
local ChristmasMonster_Cfg = hotpot.config.ChristmasMonster
local monsterDieGui = hotpot:GetPath_Loop('pfb.monsterDieGui',_G.Resource)
local collider = hotpot:GetPath_Loop('pfb.collider',_G.Resource)
local drop = hotpot:GetPath_Loop('pfb.drop',_G.Resource)
local hit_eff = hotpot:GetPath_Loop('pfb.hitEff.ATM',_G.Resource)
local boss1_eff = hotpot:GetPath_Loop('pfb.boss1Eff',_G.Resource)
local boss2_eff = hotpot:GetPath_Loop('pfb.boss2_eff',_G.Resource)
local boss3_eff = hotpot:GetPath_Loop('pfb.boss3_eff',_G.Resource)
local boss4_eff = hotpot:GetPath_Loop('pfb.boss4Eff',_G.Resource)
local boss5_eff = hotpot:GetPath_Loop('pfb.boss5eff',_G.Resource)
local boss6_eff = hotpot:GetPath_Loop('pfb.boss6Eff',_G.Resource)
local boss10_eff = hotpot:GetPath_Loop('pfb.boss10Eff',_G.Resource)
local boss11_eff = hotpot:GetPath_Loop('pfb.boss11Eff',_G.Resource)
local christmasBossEff = hotpot:GetPath_Loop('pfb.christmasBossEff',_G.Resource)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)
local ParticleEmitter = 'ParticleEmitter'
local weatherCfg = hotpot.config.Weather
local normalRewards = {
    {icon = 'rbxassetid://77799429334242',quality = 2,},
    {icon = 'rbxassetid://74187092935619',quality = 1,},
    {icon = 'rbxassetid://134804226826116',quality = 3,},
}

---@class Client_MonsterObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model,data)
    return c(model,data)
end
function c:ctor(model,data)
    c.super.ctor(self,model)

    self.data = data
    self.guid = data.guid
    self.part = data.part
    self.move_cold = math.random(40,60)/10
    self.id = tonumber(self.part.Name)
    if self.data.stage.id == 'christmas' then
        self.cfg = ChristmasMonster_Cfg[self.id]
    else
        self.cfg = monster_cfg[self.id]
    end

    self.__showhp_red = 0

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

    ---@type Humanoid
    self.humanoid = self.main_inst:WaitForChild('Humanoid')
    local collider_ = collider:Clone()
    collider_.Parent = self.main_inst
    collider_.CFrame = self:GetCFrame()
    local we = Instance.new('WeldConstraint',collider_)
    we.Part0 = self.root_part
    we.Part1 = collider_
    self.collider = collider_

    -- self.root_part.CollisionGroup = 'check_monster'

    self:Init()
    -- self:AddUpdate(self.UpdateHpRed)
end

function c:Init()
    local humanoid = self.humanoid
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    if humanoid then
        local hight = humanoid.HipHeight + self.root_part.Size.Y/2
        local cf = self.data.part.CFrame
        local pos = cf.Position + Vector3.new(0,hight,0) + Vector3.new(0,self.data.part.Size.Y/2,0)
        self.main_inst:PivotTo(
            CFrame.new(pos,pos + cf.LookVector)
        )
    else
        local cf,size = self:GetBoundingBox()
        self:PivotTo(CFrame.new(self.data.part.Position + Vector3.new(0,size.Y/2,0)))
    end

    
    self.main_inst.Parent = self.data.stage.monster_fol
    self.hp = self.data.hp
    self.max_hp = self.data.max_hp

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
        local name = ''
        if self.data.weather_id then
            local cfg = weatherCfg[self.data.weather_id]
            name = cfg.name
            local reward = cfg.reward[2]
            if reward then
                local item = hotpot:GetPath_Loop('Frame.rewards.item',self.hp_ui)
                local ui = hotpot:CloneInst_Loop(item)
                ui.Parent = self.hp_ui.Frame.rewards
                ui.bg.icon.Image = hotpot.config.relics_gacha[reward].icon
                ui.Visible = true
                local color = qualityColor:FindFirstChild(tostring(reward.quality))
                if color then
                    color:Clone().Parent = ui.bg
                    color:Clone().Parent = ui.bg.UIStroke
                end
            end
        else
            name = self.cfg.name or ''
            local item = hotpot:GetPath_Loop('Frame.rewards.item',self.hp_ui)
            for k,v in ipairs(normalRewards)do
                local ui = hotpot:CloneInst_Loop(item)
                ui.Parent = self.hp_ui.Frame.rewards
                ui.bg.icon.Image = v.icon
                ui.Visible = true
                local color = qualityColor:FindFirstChild(tostring(v.quality))
                if color then
                    color:Clone().Parent = ui.bg
                    color:Clone().Parent = ui.bg.UIStroke
                end
            end

            local stage = self.cfg.stage
            if stageDropCfg[stage] then
                local cfg = stageDropCfg[stage].relics_id
                for k,v in ipairs(cfg)do
                    local ui = hotpot:CloneInst_Loop(item)
                    ui.Parent = self.hp_ui.Frame.rewards
                    ui.bg.icon.Image = relicsCfg[v].icon
                    ui.Visible = true
                    local color = qualityColor:FindFirstChild(tostring(relicsCfg[v].quality))
                    if color then
                        color:Clone().Parent = ui.bg
                        color:Clone().Parent = ui.bg.UIStroke
                    end
                end
            end
        end
        self.hp_ui.Frame.name.Text = name
        self.hp_ui.MaxDistance = 35
        self:PlayHpUi(self.hp,self.max_hp)
    end
end

function c:GetRandomPos()
    local pos = self.data.part.Position
    local random_x = math.random(-500,500)/100
    local random_y = math.random(-500,500)/100
    return pos + Vector3.new(random_x,3,random_y)
end

function c:PlayHpUi(now,max)
    if not self.hp_ui then
        return
    end
    -- print(now,max,big_number:ToString(now),big_number:ToString(max))
    self.hp_ui.Frame.bg.num.Text = big_number:ToString(now)..'/'..big_number:ToString(max)
    tween_helper:PlayTween(
        self.hp_ui.Frame.bg.fg,
        TweenInfo.new(0.2),
        {Size = UDim2.fromScale(math.clamp(now/max,0,1),1)}
    )
end

function c:BeDamage(dmg)
    self:AddProcess(function()
        local Highlight = Instance.new('Highlight',self.main_inst)
        Highlight.DepthMode = 'Occluded'
        self:Wait(.15)
        Highlight:Destroy()
    end)
    self.__showhp_red = 0.2
    self.hp = self.hp - dmg
    if self.hp >= 0 then
        if self.hurt_track then
            self.hurt_track:Play()
        end
        self:PlayHpUi(self.hp,self.max_hp)
        if self.hit_eff then
            for k,v in ipairs(self.hit_eff:GetChildren()) do
                if v:IsA('ParticleEmitter') then
                    v:Emit(v.Rate)
                end
            end
        end
    end
end

function c:UpdateHpRed(step)
    if not self.hp_ui then
        return
    end
    if self.__showhp_red <= 0 then
        self.hp_ui.Frame.bg.fg.ImageColor3 = Color3.fromRGB(255,255,255)
        return
    end
    self.__showhp_red = self.__showhp_red - step
    self.hp_ui.Frame.bg.fg.ImageColor3 = Color3.fromRGB(255,0,0)
end

function c:Recover()
    self.hp = self.max_hp
    self:PlayHpUi(self.hp,self.max_hp)
end

function c:Attack()
    if self.cfg.is_boss then
        self.atk_anima1:Play()
        local boss_eff = self.cfg.boss_eff
        if boss_eff == 'boss1_eff' then
            local part = hotpot:CloneInst_Loop(boss1_eff)
            wait(.8)
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
            self:AddRenderProcess('render',function()
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
            self:AddRenderProcess('render',function()
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
                    self:AddRenderProcess('render',function()
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
        elseif boss_eff == 'christmas' then
            self:AddRenderProcess('render',function()
                self:Wait(.1)
                local cf = self:GetCFrame()
                local pos = self:GetBottomPosition()
                local overPos = pos + cf.LookVector * 10 + Vector3.new(0,3,0)

                local effPart = christmasBossEff:FindFirstChild('eff')
                effPart = hotpot:CloneInst_Check(effPart)
                effPart.Parent = workspace
                effPart.Position = overPos

                local interval = 0
                local time_len = 0.3
                local startPos = overPos + Vector3.new(0,30,0)

                local part = christmasBossEff:FindFirstChild('part')
                part = hotpot:CloneInst_Check(part)
                part.Parent = workspace
                part.Position = startPos
                while true do
                    interval = math.min(interval + self:Wait(),time_len)
                    local pos = startPos:Lerp(overPos,interval / time_len)
                    part.Position = pos
                    if interval >= time_len then
                        break
                    end
                end
                Debris:AddItem(part,0)
                Debris:AddItem(effPart,2)
                for k,v in ipairs(effPart:GetDescendants())do
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
            end)
        elseif boss_eff == 'boss10_eff' then
            self:AddProcess(function()
                local cf = self:GetCFrame()
                local cha_pos = self.cha_pos
                local bottom = self:GetBottomPosition() + Vector3.new(0,2,0)
                if not cha_pos then
                    cha_pos = bottom + cf.LookVector * 10
                end

                local eff1 = boss10_eff:FindFirstChild('eff')
                eff1 = hotpot:CloneInst_Check(eff1)
                eff1.Position = bottom
                eff1.Parent = workspace

                Debris:AddItem(eff1,2.5)

                for i = 1,4 do
                    local pos = self:GetPosition() + Vector3.new(0,20,0) + cf.LookVector * 5
                    pos = pos + cf.RightVector * math.random(-200,200)/10
                    local ball = boss10_eff:FindFirstChild('ball')
                    ball = hotpot:CloneInst_Check(ball)
                    ball.Position = pos
                    ball.Parent = workspace
                    self:AddRenderProcess('render',function()
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
                        local eff2 = boss10_eff:FindFirstChild('boom')
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
        elseif boss_eff == 'boss11_eff' then
            local part = hotpot:CloneInst_Loop(boss11_eff)
            wait(.8)
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
            local pos = self:GetBottomPosition() + cf.LookVector * 12 + Vector3.new(0,6,0)
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
            self:AddRenderProcess('render',function()
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
        end
    else
        self.atk_anima:Play()
    end
end

function c:dtor(bool)
    if bool then
        if self.main_inst then
            self.main_inst:Destroy()
        end
        c.super.dtor(self)
        return
    end
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
    animation.AnimationId = 'rbxassetid://913376220'
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

--面向目标
function c:LookAtTarget(pos)
    self.cha_pos = pos
    local dir = (pos - self:GetPosition()).Unit
    self:AddRenderProcess('render',function()
        local time_len = 0.2
        local interval = 0
        local now_cf = self:GetCFrame()
        local tar_cf = CFrame.new(now_cf.Position,now_cf.Position + Vector3.new(dir.X,0,dir.Z))
        if now_cf == tar_cf then
            return true
        end
        while true do
            interval = math.min(interval + self:Wait(),time_len)
            if not self.root_part then
                break
            end
            self:SetCFrame(now_cf:Lerp(tar_cf,interval / time_len))
            if interval >= time_len then
                break
            end
        end
    end)
end

--展示死亡ui
function c:ShowDieUi()
    self.ui = hotpot:CloneInst_Loop(monsterDieGui)
    self.ui.Parent = self.root_part
end

--掉落
function c:Drop(info)
    local gold = info.gold
    if gold <= 0 then
        return
    end
    local pos = self:GetPosition()
    local count = 0
    if gold < 10 then
        count = 1
    else
        count = 4
    end
    for i = 1,count do
        local dropPart = hotpot:CloneInst_Loop(drop)
        dropPart.Parent = workspace
        dropPart.Position = pos
        self:AddProcess(function()
            local VectorForce = dropPart:FindFirstChild('VectorForce')
            local v3 = Vector3.new(math.random(-1000,1000)/1000,math.random(-1000,1000)/1000)
            VectorForce.Force = v3 * 20
            self:Wait(.5)
            VectorForce.Enabled = false
            self:Wait(1)
            dropPart.Anchored = true
            dropPart.CanCollide = false
            local dir
        end)
    end
end

--移动
function c:Move(pos)
    self.humanoid:MoveTo(pos)
    if not self.move_anima.IsPlaying then
        self.move_anima:Play()
    end
end

--boss动作
function c:BossAnimation()
    local w_type = self.cfg.is_boss
    local animation = Instance.new('Animation')
    animation.AnimationId = hotpot.pro_cfg.animas[w_type][1]
    self.atk_anima1 = self.humanoid:LoadAnimation(animation)

    local animation = Instance.new('Animation')
    animation.AnimationId = hotpot.pro_cfg.animas[w_type][2]
    self.atk_anima2 = self.humanoid:LoadAnimation(animation)
end

function c:PlayEff(inst)
    for k,v in ipairs(inst:GetDescendants())do
        if v:IsA('ParticleEmitter') then
            v:Emit(v.Rate)
        end
    end
end

return c