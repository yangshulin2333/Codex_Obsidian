local hotpot = _G.ServerHotpot
---@type Server_RankManager
local rank_manager = hotpot.load.Server_RankManager()

local characterCfg = hotpot.config.character
local chaFol = hotpot:GetPath_Loop('character',hotpot.Resource)

---@class Server_StatsComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end

function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('stats')

    self.rig = nil
    self:AddProcess(function()
        self.rig = hotpot:GetPath_Check(
            'PlayerGui.StatsGui.Frame.bg.left.ViewportFrame.WorldModel.Rig',
            self.parent.main_inst
        )

        local count = 10
        while count > 0 do
            if self.rig then
                break
            end
            count = count - 1
            self.rig = hotpot:GetPath_Check(
                'PlayerGui.RelicsGui.Frame.bg.ViewportFrame.WorldModel.Rig',
                self.parent.main_inst
            )
        end

        self.part_fol = self.rig:WaitForChild('Folder')
        self.humanoid = self.rig:WaitForChild('Humanoid')
        if self.model then
            self:ChangeCharacter(self.model)
        end
    end)
end

function c:GetStats()
    local hp = self.parent.character.max_hp
    local atk = self.parent.prop_cmp:GetAttack()
    local speed = self.parent.prop_cmp:GetSpeed()
    local playTime = 0
    local re,time_ = rank_manager:GetRankValue('time',self.parent.user_id)
    if not re then
        time_ = 0
    else
        if not time_ then
            time_ = 0
        end
    end
    playTime = time_

    local kill = 0
    local re,kill_ = rank_manager:GetRankValue('kill',self.parent.user_id)
    if not re then
        kill_ = 0
    else
        if not kill_ then
            kill_ = 0
        end
    end
    kill = kill_

    local tDmg = self.data.__real.total_dmg
    local egg = self.data.__real.eggs

    self.playTime = playTime or 0
    self.now_clock = os.clock()
    self.killMonster = kill

    spawn(function()
        local equiped = self.parent.character_cmp.data.__real.equiped
        local model = characterCfg[equiped].model
        model = chaFol:FindFirstChild(model)
        model = hotpot:CloneInst_Loop(model)
        model.Name = characterCfg[equiped].name
        self:ChangeCharacter(model)
    end)

    return {
        hp = hp,
        atk = atk,
        speed = speed,
        playTime = playTime,
        kill = kill,
        tDmg = tDmg,
        egg = egg,
    }
end

function c:SyncAttack()
    local atk = self.parent.prop_cmp:GetAttack()
    local speed = self.parent.prop_cmp:GetSpeed()
    local hp = self.parent.prop_cmp:GetHp()

    self:Fire('stats_dmg',atk,speed,hp)
end

function c:SyncKill(kill)
    self.killMonster = kill
    self:Fire('stats_kill',kill)
end

function c:AddEggs(num)
    self.parent.save_data:Execut(function()
        self.data.eggs = self.data.eggs + num
    end)

    self:Fire('stats_egg',self.data.__real.eggs)
end

function c:AddTotalDmg(num)
    self.parent.save_data:Execut(function()
        self.data.total_dmg = self.data.total_dmg + num
    end)

    self:Fire('stats_total_dmg',self.data.__real.total_dmg)
end

---@param model Model
function c:ChangeCharacter(model)
    self.model = model
    self:Fire('stats_chaName',model.Name)
    if not self.rig then
        return
    end
    --先删除
    self.part_fol:ClearAllChildren()
    for k,v in ipairs(self.rig:GetChildren()) do
        if v:IsA('Accessory') then
            if not v.Name:find('relicsAcc') then
                v:Destroy()
            end
        end
        if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Hat') then
            v:Destroy()
        end
    end

    for k,v in pairs(model:GetDescendants()) do
        if v:IsA('BasePart') then
            v.CanCollide = false
            v.CanTouch = false
            v.CanQuery = false
            v.Anchored = false
            v.Massless = true
        end
    end

    if model:GetAttribute('old') then
        self.part_fol:ClearAllChildren()
        for k,v in ipairs(self.rig:GetChildren()) do
            if v:IsA('MeshPart') then
                v.Transparency = 0
            end
        end

        local humanoid = model:FindFirstChild('Humanoid')
        if not humanoid then
            return
        end

        local desc = humanoid:GetAppliedDescription()

        if self.finish_co then
            self.finish_co:Disconnect()
            self.finish_co = nil
        end
        self.finish_co = self.humanoid.ApplyDescriptionFinished:Connect(function()
            for k,v in ipairs(self.rig:GetDescendants()) do
                if v:IsA('SurfaceAppearance') then
                    v:Destroy()
                end
            end

            for k,v in pairs(model:GetChildren()) do
                if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Accessory') or v:IsA('Hat') then
                    v:Clone().Parent = self.rig
                end
                if v:IsA('BasePart') then
                    v.CollisionGroup = 'character'
                    local part = self.rig:FindFirstChild(v.Name)
                    if part then
                        part.Color = v.Color
                    end
                end
                if v:IsA('Attachment') and v.Name == 'effAtt' then
                    local clone = v:Clone()
                    local part = self.rig:FindFirstChild(v.Name)
                    if part then
                        clone.Parent = part
                    end
                end
            end
            local head = self.rig:FindFirstChild('Head')
            if head then
                local face = head:FindFirstChildOfClass('Decal')
                if face then
                    face:Destroy()
                end
            end
            head = model:FindFirstChild('Head')
            if head then
                local face = head:FindFirstChildOfClass('Decal')
                if face then
                    face:Clone().Parent = self.rig.Head
                end
            end

            for k,v in pairs(model:GetDescendants()) do
                if v:IsA('Attachment') and v.Name == 'effAtt' then
                    local clone = v:Clone()
                    local part = self.rig:FindFirstChild(v.Parent.Name)
                    if part then
                        clone.Parent = part
                    end
                end
            end

            local color = model:FindFirstChildOfClass('BodyColors')
            if color then
                local color1 = self.rig:FindFirstChildOfClass('BodyColors')
                if color1 then
                    color1:Destroy()
                end
                color.Parent = self.rig
            end
            wait(1)
            if self.rig and self.rig.Parent then
                for k,v in pairs(self.rig:GetChildren()) do
                    if v:IsA('BasePart') then
                        v.CollisionGroup = 'character'
                    end
                    if v:IsA('Shirt') then
                        if not v.ShirtTemplate or v.ShirtTemplate == '' then
                            v.ShirtTemplate = v:GetAttribute('res')
                        end
                    end
                    if v:IsA('Pants') then
                        if not v.PantsTemplate or v.PantsTemplate == '' then
                            v.PantsTemplate = v:GetAttribute('res')
                        end
                    end
                end
            end
        end)

        for k,v in pairs(self.rig:GetDescendants()) do
            if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Accessory') or v:IsA('Hat') then
                v:Destroy()
            end
            if v:IsA('Attachment') and v.Name == 'effAtt' then
                v:Destroy()
            end
        end

        pcall(function()
            if self.humanoid then
                self.humanoid:ApplyDescription(desc)
            end
        end)

    else
        --应用
        local head = self.rig:FindFirstChild('Head')
        if head then
            local face = head:FindFirstChildOfClass('Decal')
            if face then
                face:Destroy()
            end
        end

        for k,v in ipairs(model:GetChildren())do
            if v:IsA('Humanoid') then
                v:Destroy()
            end
            if v:IsA('MeshPart') then
                local value = v:FindFirstChild('OriginalSize')
                if value then
                    value:Destroy()
                end
                local motor = v:FindFirstChildOfClass('Motor6D')
                if motor then
                    motor:Destroy()
                end
                local trage = v:FindFirstChildOfClass('WrapTarget')
                if trage then
                    trage:Destroy()
                end
    
                local chaPart = self.rig:FindFirstChild(v.Name)
                if not chaPart then
                    continue
                end
                local RigidConstraint = Instance.new("RigidConstraint",v)
                local att = v:FindFirstChildOfClass("Attachment")
                RigidConstraint.Attachment0 = att
    
                local chaAtt = chaPart:FindFirstChild(att.Name)
                if not chaAtt then
                    continue
                end
                RigidConstraint.Attachment1 = chaAtt
                
                v.Parent = self.part_fol
            end
            if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Hat') or v:IsA('Accessory') then
                v.Parent = self.rig
            end
        end
        for k,v in ipairs(self.part_fol:GetChildren()) do
            if v:IsA('MeshPart') then
                if v:GetAttribute('transparency') then
                    v.Transparency = 1
                else
                    v.Transparency = 0
                end
            end
        end
        for k,v in ipairs(self.rig:GetChildren()) do
            if v:IsA('MeshPart') then
                v.Transparency = 1
            end
        end
    end

    self.model = nil
    wait(2)
    model:Destroy()
end

function c:GetEgg()
    return self.data.__real.eggs
end

function c:GetTotalDmg()
    return self.data.__real.totalDmg
end

c:RegistFunction('get_stats',c.GetStats)

return c
