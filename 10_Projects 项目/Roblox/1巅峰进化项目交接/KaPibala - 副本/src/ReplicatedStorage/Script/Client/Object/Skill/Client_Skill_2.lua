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
local skillFol = hotpot:GetPath_Loop('skill.skill2',_G.Resource)
local eff1 = skillFol:WaitForChild('eff1')
local eff2 = skillFol:WaitForChild('eff2')
local skillModel = skillFol:WaitForChild('model')

---@class Client_Skill_2:BaseObject
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
    local bottomPos
    if self.parent.GetNewBottomPosition then
        bottomPos = self.parent:GetNewBottomPosition()
    else
        bottomPos = self.parent:GetBottomPosition()
    end
    local startPos = bottomPos + cf.LookVector * 5

    ---@type Model
    local eff1Model = hotpot:CloneInst_Loop(eff1)
    eff1Model.Parent = workspace
    eff1Model:PivotTo(CFrame.new(startPos))
    self:AddProcess(self.Create,startPos,cf)

    local chPart = eff1Model:FindFirstChild('check')
    if chPart then
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
    end

    audio_manager:PlayGloble('skill2')

    ---@type Part
    local eff2Model = hotpot:CloneInst_Loop(eff2)
    eff2Model.Parent = workspace
    eff2Model.Position = startPos
    eff2Model.CFrame = (
        CFrame.new(eff2Model.Position) * CFrame.Angles(
            math.rad(22)
            ,0,0
        )
    )

    Debris:AddItem(eff2Model,3)
    Debris:AddItem(eff1Model,3)

    spawn(function()
        self:PlayEff(eff1Model) 
        self:PlayEff(eff2Model) 
    end)
end

function c:Create(pos,cf)
    for i = 1,7 do
        ---@type Model
        local model = hotpot:CloneInst_Loop(skillModel)
        model:ScaleTo(math.random(20,80)/100)
        model.Parent = workspace
        local p = pos + Vector3.new(
            math.random(-50,50)/10,
            0,
            math.random(-50,50)/10
        )
        model:PivotTo(
            CFrame.new(p,p + cf.LookVector) * CFrame.Angles(
                -math.rad(math.random(30,50))
                ,0,0
            )
        )
        Debris:AddItem(model,1)
        self:Wait(math.random(0,10/1000))
    end

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