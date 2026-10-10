local hotpot = _G.ClientHotpot
local Debris = game:GetService('Debris') 
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
local skillFol = hotpot:GetPath_Loop('skill.skill1',_G.Resource)
local createEff = skillFol:WaitForChild('createEff')
local HitEff = skillFol:WaitForChild('Hit')
local skillModel = skillFol:WaitForChild('model')
local checkPart = skillFol:WaitForChild('check')

---@class Client_Skill_1:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self)

    ---@type Client_PlayerCharacter
    self.parent = parent

    if not self.other_player then
        if self.parent.player then
            self.isPk = self.parent.player.main_inst:WaitForChild('pk_state')
        end
    end

    self:LoadAnimation()
end

function c:Start()
    if self.is_running then
        return
    end
    self.is_running = true
    self:PlayAnimation()
    wait(1.5)
    local cf = self.parent:GetCFrame()
    local bottomPos
    if self.parent.GetNewBottomPosition then
        bottomPos = self.parent:GetNewBottomPosition()
    else
        bottomPos = self.parent:GetBottomPosition()
    end
    local startPos = cf.Position + Vector3.new(0,40,0)
    local overPos = bottomPos + cf.LookVector * 5

    local chPart = hotpot:CloneInst_Loop(checkPart)
    chPart.Transparency = 1
    chPart.Parent = workspace
    chPart.Position = overPos
    Debris:AddItem(chPart,1)

    if not self.other_player then
        local list = nil

        if place_manager:GetIdByName('pvpsence') == game.PlaceId then
            local playerList = workspace:GetPartsInPart(chPart,pvpOv)
            local monsterList = workspace:GetPartsInPart(chPart,ov)
            -- print(playerList,monsterList)
            self:AddProcess(self.SendPvpDmg,playerList,monsterList)
        end

        if self.isPk and self.isPk.Value then
            list = workspace:GetPartsInPart(chPart,pvpOv)
            self:AddProcess(self.SendPKDmg,list)
        else
            list = workspace:GetPartsInPart(chPart,ov)
            self:AddProcess(self.SendDamage,list)
        end
    end
    -- print(list)

    self:AddProcess(function()
        for i = 1,5 do
            self:AddRenderProcess('render',self.Create,startPos,overPos)
            self:Wait(.2)
        end
        self:Wait(3)
        self.is_running = false
    end)
end

function c:Create(startPos,overPos)
    local s_pos = startPos + Vector3.new(
        math.random(-150,150)/10,
        0,
        math.random(-150,150)/10
    )
    local o_pos = overPos + Vector3.new(
        math.random(-100,100)/10,
        0,
        math.random(-100,100)/10
    )
    local dir = (o_pos - s_pos).Unit

    local eff = hotpot:CloneInst_Loop(createEff)
    eff.Parent = workspace
    eff.Position = s_pos
    Debris:AddItem(eff,3)
    spawn(function()
        self:PlayEff(eff) 
    end)

    ---@type Model
    local model = hotpot:CloneInst_Loop(skillModel)
    model:SetPrimaryPartCFrame(CFrame.new(s_pos,o_pos))
    model.Parent = workspace
    
    self:Wait(.3)

    local interval = 0
    local timeLen = 0.5
    while true do
        interval = interval + self:Wait()
        interval = math.min(interval,timeLen)
        if interval >= timeLen then
            break
        end
        model:PivotTo(
            CFrame.new(
                s_pos:Lerp(o_pos,interval/timeLen),
                o_pos + dir
            )
        )
    end

    audio_manager:PlayGloble('skill1')
    local hitEff = hotpot:CloneInst_Loop(HitEff)
    hitEff.Parent = workspace
    hitEff.Position = o_pos
    Debris:AddItem(hitEff,3)
    spawn(function()
        self:PlayEff(hitEff) 
    end)

    Debris:AddItem(model,.5)
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