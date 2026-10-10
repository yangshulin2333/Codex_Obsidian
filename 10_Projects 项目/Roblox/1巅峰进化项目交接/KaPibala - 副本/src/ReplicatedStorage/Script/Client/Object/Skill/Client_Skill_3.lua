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
local skillFol = hotpot:GetPath_Loop('skill.skill3',_G.Resource)
local checkPart = skillFol:WaitForChild('check')
local ball = skillFol:WaitForChild('ball')

---@class Client_Skill_3:BaseObject
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
    local cf = self.parent:GetCFrame()
    local startPos = cf.Position + cf.LookVector * 5

    local ballInst = ball:Clone()
    local RightHand = self.parent.main_inst:FindFirstChild('RightHand')
    ballInst.Parent = workspace
    ballInst.Position = RightHand.Position
    self.ball_co = self:AddRenderUpdate('render',function()
        ballInst.Position = RightHand.Position
    end)
    self.ball_inst = ballInst
    self.overPos = startPos

    delay(4,function()
        self.is_running = false
    end)
end

function c:Run()
    self:AddRenderProcess('render',function()
        local time_len = 0.3
        local interval = 0
        local startPos = self.ball_inst.Position
        while true do
            interval = interval + self:Wait()
            interval = math.min(interval,time_len)
            local pos = startPos:Lerp(self.overPos,interval/time_len)
            self.ball_inst.Position = pos
            if interval >= time_len then
                break
            end
        end
        Debris:AddItem(self.ball_inst,0)

        local part = checkPart:Clone()
        part.Parent = workspace
        part.Position = self.overPos
        Debris:AddItem(part,3)
        audio_manager:PlayGloble('skill3')
        self:PlayEff(part)
        if not self.other_player then
            local list = nil

            if place_manager:GetIdByName('pvpsence') == game.PlaceId then
                local playerList = workspace:GetPartsInPart(part,pvpOv)
                local monsterList = workspace:GetPartsInPart(part,ov)
                -- print(playerList,monsterList)
                self:AddProcess(self.SendPvpDmg,playerList,monsterList)
            end

            if self.isPk and self.isPk.Value then
                list = workspace:GetPartsInPart(part,pvpOv)
                self:AddProcess(self.SendPKDmg,list)
            else
                list = workspace:GetPartsInPart(part,ov)
                self:AddProcess(self.SendDamage,list)
            end
        end
        self.is_running = false
    end)
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
    animation.AnimationId = 'rbxassetid://130083974261515'
    self.track = animator:LoadAnimation(animation)
    -- self.track:AdjustSpeed(2)

    self.track:GetMarkerReachedSignal('send'):Connect(function()
        self.ball_co:Disconnect()
        self:Run()
    end)
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