local hotpot = _G.ClientHotpot
local Debris = game:GetService('Debris') 
---@type CurveHelper
local curve_helper = hotpot.load.CurveHelper()
---@type Client_AudioManager
local audio_manager = hotpot.load.Client_AudioManager()
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local ov = OverlapParams.new()
ov.CollisionGroup = 'skill_check'
local pvpOv = OverlapParams.new()
pvpOv.CollisionGroup = 'pvp_character'
local ParticleEmitter = 'ParticleEmitter'
local EmitCount = 'EmitCount'
local EmitDelay = 'EmitDelay'
local skillFol = hotpot:GetPath_Loop('skill.skill5',_G.Resource)

---@class Client_Skill_5:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self)

    ---@type Client_PlayerCharacter
    self.parent = parent

    self:LoadAnimation()

    if not self.other_player then
        if self.parent.player then
            self.isPk = self.parent.player.main_inst:WaitForChild('pk_state')
        end
    end
end

function c:Start()
    if self.is_running then
        return
    end
    self.is_running = true
    self:PlayAnimation()
    wait(1.5)

    local cf = self.parent:GetCFrame()

    local checkPart = skillFol:FindFirstChild('check')
    checkPart = hotpot:CloneInst_Check(checkPart)
    checkPart.Parent = workspace
    local bottomPos
    if self.parent.GetNewBottomPosition then
        bottomPos = self.parent:GetNewBottomPosition()
    else
        bottomPos = self.parent:GetBottomPosition()
    end
    checkPart.Position = bottomPos + cf.LookVector * 5
    -- local list = workspace:GetPartsInPart(checkPart,ov)
    -- self:AddProcess(self.SendDamage,list)
    if not self.other_player then
        local list = nil

        if place_manager:GetIdByName('pvpsence') == game.PlaceId then
            local playerList = workspace:GetPartsInPart(checkPart,pvpOv)
            local monsterList = workspace:GetPartsInPart(chPart,ov)
            -- print(playerList,monsterList)
            self:AddProcess(self.SendPvpDmg,playerList,monsterList)
        end

        if self.isPk and self.isPk.Value then
            list = workspace:GetPartsInPart(checkPart,pvpOv)
            self:AddProcess(self.SendPKDmg,list)
        else
            list = workspace:GetPartsInPart(checkPart,ov)
            self:AddProcess(self.SendDamage,list)
        end
    end
    Debris:AddItem(checkPart,1)

    self:AddProcess(function()
        -- local cf = self.parent:GetCFrame()
        local cha_pos = self.cha_pos
        if not cha_pos then
            cha_pos = bottomPos + cf.LookVector * 5
        end
        for i = 1,4 do
            local pos = self.parent:GetPosition() + Vector3.new(0,20,0) + cf.LookVector * 5
            pos = pos + cf.RightVector * math.random(-200,200)/10
            local ball = skillFol:FindFirstChild('火球')
            ball = hotpot:CloneInst_Check(ball)
            local eff1 = skillFol:FindFirstChild('火球出现')
            eff1 = hotpot:CloneInst_Check(eff1)
            eff1.Position = pos
            eff1.Parent = workspace
            self:PlayEff(eff1)
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
                local eff2 = skillFol:FindFirstChild('火球爆炸')
                eff2 = hotpot:CloneInst_Check(eff2)
                local bottomPos
                if self.parent.GetNewBottomPosition then
                    bottomPos = self.parent:GetNewBottomPosition()
                else
                    bottomPos = self.parent:GetBottomPosition()
                end
                eff2.Position = Vector3.new(cha_pos.X,bottomPos.Y + 0.5,cha_pos.Z)
                eff2.Parent = workspace
                audio_manager:PlayGloble('skill5')
                self:PlayEff(eff2)
                Debris:AddItem(eff2,2)
            end)
            self:Wait(.2)
        end
    end)


    self.is_running = false
end

function c:PlayEff(inst)
    for k,v in ipairs(inst:GetDescendants())do
        if v:IsA(ParticleEmitter) then
            local count = v:GetAttribute(EmitCount) or v.Rate
            local delay_ = v:GetAttribute(EmitDelay) or 0
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

function c:LoadAnimation()
    local animator = self.parent.humanoid:WaitForChild('Animator')
    local animation = Instance.new('Animation')
    animation.AnimationId = 'rbxassetid://114789931459759'
    self.track = animator:LoadAnimation(animation)
    self.track:AdjustSpeed(2)
end

function c:PlayAnimation()
    self.track:Play()
end

function c:SendDamage(list)
    if self.other_player then
        return
    end
    ---@type Client_StageObj
    local stage = self.parent.player.now_stage
    if not stage then
        return
    end
    for i,v in ipairs(list)do
        stage:PlayerSkill(self.parent.player,self.id,self.solt,v)
    end
end

function c:SendPKDmg(list)
    if not self.isPk.Value then
        return
    end
    hotpot.event_manager:Fire('pk_skill_dmg',{
        player = self.parent.main_inst,
        skill_id = self.id,
        solt = self.solt,
        list = list,
    })
end

function c:SendPvpDmg(playerList,monsterList)
    if self.other_player then
        return
    end
    ---@type Client_Player
    local player = self.parent.player
    if not player then
        return
    end
    player.sync_cmp:Add('pvp_skill',{
        player_guid = player.guid,
        skill_id = self.id,
        solt = self.solt,
        playerList = playerList,
        monsterList = monsterList,
    })
end

return c