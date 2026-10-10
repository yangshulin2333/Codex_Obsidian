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
local skillFol = hotpot:GetPath_Loop('skill.skill4',_G.Resource)
local skillModel = skillFol:WaitForChild('model')

---@class Client_Skill_4:BaseObject
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
    local startPos = cf.Position + cf.LookVector * 5

    ---@type Model
    local model = hotpot:CloneInst_Loop(skillModel)
    model.Parent = workspace
    model:PivotTo(CFrame.new(startPos,startPos + cf.LookVector))
    -- local list = workspace:GetPartsInPart(model.PrimaryPart,ov)
    -- self:AddProcess(self.SendDamage,list)
    if not self.other_player then
        local list = nil

        if place_manager:GetIdByName('pvpsence') == game.PlaceId then
            local playerList = workspace:GetPartsInPart(model.PrimaryPart,pvpOv)
            local monsterList = workspace:GetPartsInPart(model.PrimaryPart,ov)
            -- print(playerList,monsterList)
            self:AddProcess(self.SendPvpDmg,playerList,monsterList)
        end

        if self.isPk and self.isPk.Value then
            list = workspace:GetPartsInPart(model.PrimaryPart,pvpOv)
            self:AddProcess(self.SendPKDmg,list)
        else
            list = workspace:GetPartsInPart(model.PrimaryPart,ov)
            self:AddProcess(self.SendDamage,list)
        end
    end
    Debris:AddItem(model,3)  
    self:AddProcess(function()
        audio_manager:PlayGloble('skill4')
        self:PlayEff(model)
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