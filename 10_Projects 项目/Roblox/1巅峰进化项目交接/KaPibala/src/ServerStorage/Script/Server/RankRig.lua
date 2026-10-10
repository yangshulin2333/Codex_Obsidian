local hotpot = _G.ServerHotpot
---@type DataStoreService
local DataStoreService = game:GetService('DataStoreService')
---@type Players
local players = game:GetService("Players")

local DataStore = DataStoreService:getDataStore('player_data')
local characterFol = hotpot:GetPath_Loop('character',hotpot.Resource)
local relicsFol = hotpot:GetPath_Loop('Relics',hotpot.Resource)
local characterCfg = hotpot.config.character
local relicsCfg = hotpot.config.relics

---@class RankRig:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new()
    return c()
end
function c:ctor()
    c.super.ctor(self)
end

function c:SetRigModel(fol,is_guildWar)
    local r1 = fol:GetAttribute('r1')
    local r2 = fol:GetAttribute('r2')
    local r3 = fol:GetAttribute('r3')

    local rig1 = fol:WaitForChild('Rig1')
    local rig2 = fol:WaitForChild('Rig2')
    local rig3 = fol:WaitForChild('Rig3')

    Instance.new('Folder',rig1)
    Instance.new('Folder',rig2)
    Instance.new('Folder',rig3)

    if is_guildWar then
        self:SetGuildWarRig(r1,rig1)
        self:SetGuildWarRig(r2,rig2)
        self:SetGuildWarRig(r3,rig3)
    else
        self:SetRig(r1,rig1)
        self:SetRig(r2,rig2)
        self:SetRig(r3,rig3)
    
        fol:GetAttributeChangedSignal('r1'):Connect(function()
            local r1 = fol:GetAttribute('r1')
            self:SetRig(r1,rig1)
            if r1 ~= 0 then
            end
        end)
        fol:GetAttributeChangedSignal('r2'):Connect(function()
            local r2 = fol:GetAttribute('r2')
            self:SetRig(r2,rig2)
            if r2 ~= 0 then
            end
        end)
        fol:GetAttributeChangedSignal('r3'):Connect(function()
            local r3 = fol:GetAttribute('r3')
            self:SetRig(r3,rig3)
            if r3 ~= 0 then
            end
        end)
    end

end

function c:SetRig(uid,rig)
    self:AddProcess(function()
        if not uid then
            return
        end

        if uid == 0 then
            self:SetRig0(rig)
            return
        end

        local data = DataStore:GetAsync(uid)
        if not data then
            data = {
                character = {equiped = 1},
                relics = {
                    equiped = {
                        {unlock = true,relics_id = nil,},
                        {unlock = true,relics_id = nil,},
                        {unlock = true,relics_id = nil,},
                        {unlock = false,relics_id = nil,buy = false},
                        {unlock = false,relics_id = nil,buy = false},
                        {unlock = false,relics_id = nil,buy = false},
                        {unlock = false,relics_id = nil},
                        {unlock = false,relics_id = nil},
                        {unlock = false,relics_id = nil},
                    },--当前装备
                },
                prop = {
                    lv = 1,
                },
            }
        end

        self:AddProcess(function()
            local r,e = pcall(function()
                return players:GetNameFromUserIdAsync(uid)
            end)
            if not r then
                e = 'UnkownName'
            end

            local humanoid = rig:FindFirstChild('Humanoid')
            humanoid.DisplayName = ''

            local name = hotpot:GetPath_Loop('PlayerName.info',rig.PrimaryPart)
            local lv = hotpot:GetPath_Loop('PlayerName.lv',rig.PrimaryPart)

            name.Text = e
            lv.Text = 'Lv '..(data.prop.lv or 1)
        end)

        local characterId = data.character.equiped
        local modelName = characterCfg[characterId].model
        local model = characterFol:FindFirstChild(modelName)
        model = hotpot:CloneInst_Loop(model)

        --先删除
        local fol = rig:FindFirstChild('Folder')
        fol:ClearAllChildren()
        for k,v in ipairs(rig:GetChildren()) do
            if v:IsA('Accessory') then
                if not v.Name:find('relicsAcc') then
                    v:Destroy()
                end
            end
            if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Hat') then
                v:Destroy()
            end
        end

        local head__ = rig:FindFirstChild('Head')
        if head__ then
            for k,v in ipairs(head__:GetChildren()) do
                if v.Name == 'effAtt' then
                    v:Destroy()
                end
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
            fol:ClearAllChildren()
            for k,v in ipairs(rig:GetChildren()) do
                if v:IsA('MeshPart') then
                    v.Transparency = 0
                end
            end

            local humanoid = model:FindFirstChild('Humanoid')
            local desc = humanoid:GetAppliedDescription()

            if self.finish_co then
                self.finish_co:Disconnect()
                self.finish_co = nil
            end

            local rigHumanoid = rig:FindFirstChild('Humanoid')

            local function Finish()
                for k,v in ipairs(rig:GetDescendants()) do
                    if v:IsA('SurfaceAppearance') then
                        v:Destroy()
                    end
                end

                for k,v in pairs(model:GetChildren()) do
                    if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Accessory') or v:IsA('Hat') then
                        v:Clone().Parent = rig
                    end
                    if v:IsA('BasePart') then
                        local part = rig:FindFirstChild(v.Name)
                        if part then
                            part.Color = v.Color
                        end
                    end
                    if v:IsA('Attachment') and v.Name == 'effAtt' then
                        local clone = v:Clone()
                        local part = rig:FindFirstChild(v.Name)
                        if part then
                            clone.Parent = part
                        end
                    end
                end
                local head = rig:FindFirstChild('Head')
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
                        face:Clone().Parent = rig.Head
                    end
                end

                for k,v in pairs(model:GetDescendants()) do
                    if v:IsA('Attachment') and v.Name == 'effAtt' then
                        local clone = v:Clone()
                        local part = rig:FindFirstChild(v.Parent.Name)
                        if part then
                            clone.Parent = part
                        end
                    end
                end

                local color = model:FindFirstChildOfClass('BodyColors')
                if color then
                    local color1 = rig:FindFirstChildOfClass('BodyColors')
                    if color1 then
                        color1:Destroy()
                    end
                    color.Parent = rig
                end
                self:Wait(1)
                if rig and rig.Parent then
                    for k,v in pairs(rig:GetChildren()) do
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
            end

            self.finish_co = rigHumanoid.ApplyDescriptionFinished:Connect(Finish)

            for k,v in pairs(rig:GetDescendants()) do
                if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Accessory') or v:IsA('Hat') then
                    v:Destroy()
                end
                if v:IsA('Attachment') and v.Name == 'effAtt' then
                    v:Destroy()
                end
            end

            rigHumanoid:ApplyDescription(desc)
            self:Wait(3)
            Finish()
        else
            --应用
            local head = rig:FindFirstChild('Head')
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
        
                    local chaPart = rig:FindFirstChild(v.Name)
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
                    
                    v.Parent = fol
                end
                if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Hat') or v:IsA('Accessory') then
                    v.Parent = rig
                end
            end
            for k,v in ipairs(fol:GetChildren()) do
                if v:IsA('MeshPart') then
                    if v:GetAttribute('transparency') then
                        v.Transparency = 1
                    else
                        v.Transparency = 0
                    end
                end
            end
            for k,v in ipairs(rig:GetChildren()) do
                if v:IsA('MeshPart') then
                    v.Transparency = 1
                end
            end
        end

        model:Destroy()

        self:Wait(1)
        --遗物
        local equiped = data.relics.equiped
        local types = {}
        for k,v in pairs(equiped)do
            if v.inst_id then
                pcall(function()
                    local tab = data.relics.newlist[tostring(v.inst_id)]
                    local relics_id = tab.relics_id
                    local type_ = relicsCfg[relics_id].type_
                    local rModel = relicsCfg[relics_id].model
                    if not types[type_] then
                        types[type_] = rModel
                    end
                end)
            end
        end
        if types[7] then
            for k,v in rig:GetChildren()do
                if v:IsA('Accessory') and v.Name == 'weapon' then
                    v:Destroy()
                end
            end
        end
        for _,str in pairs(types)do
            local model = relicsFol:FindFirstChild(str)
            if model then
                model = model:Clone()
                model.Parent = rig
            end
        end
    end)
end

function c:SetRig0(rig)
    local humanoid = rig:FindFirstChild('Humanoid')
    humanoid.DisplayName = ''

    local name = hotpot:GetPath_Loop('PlayerName.info',rig.PrimaryPart)
    local lv = hotpot:GetPath_Loop('PlayerName.lv',rig.PrimaryPart)

    name.Text = 'UnkownName'
    lv.Text = 'Lv 1'


    local characterId = 1
    local modelName = characterCfg[characterId].model
    local model = characterFol:FindFirstChild(modelName)
    model = hotpot:CloneInst_Loop(model)

    --先删除
    local fol = rig:FindFirstChild('Folder')
    fol:ClearAllChildren()
    for k,v in ipairs(rig:GetChildren()) do
        if v:IsA('Accessory') then
            if not v.Name:find('relicsAcc') then
                v:Destroy()
            end
        end
        if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Hat') then
            v:Destroy()
        end
    end

    local head__ = rig:FindFirstChild('Head')
    if head__ then
        for k,v in ipairs(head__:GetChildren()) do
            if v.Name == 'effAtt' then
                v:Destroy()
            end
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
        fol:ClearAllChildren()
        for k,v in ipairs(rig:GetChildren()) do
            if v:IsA('MeshPart') then
                v.Transparency = 0
            end
        end

        local humanoid = model:FindFirstChild('Humanoid')
        local desc = humanoid:GetAppliedDescription()

        if self.finish_co then
            self.finish_co:Disconnect()
            self.finish_co = nil
        end

        local rigHumanoid = rig:FindFirstChild('Humanoid')

        local function Finish()
            for k,v in ipairs(rig:GetDescendants()) do
                if v:IsA('SurfaceAppearance') then
                    v:Destroy()
                end
            end

            for k,v in pairs(model:GetChildren()) do
                if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Accessory') or v:IsA('Hat') then
                    v:Clone().Parent = rig
                end
                if v:IsA('BasePart') then
                    local part = rig:FindFirstChild(v.Name)
                    if part then
                        part.Color = v.Color
                    end
                end
                if v:IsA('Attachment') and v.Name == 'effAtt' then
                    local clone = v:Clone()
                    local part = rig:FindFirstChild(v.Name)
                    if part then
                        clone.Parent = part
                    end
                end
            end
            local head = rig:FindFirstChild('Head')
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
                    face:Clone().Parent = rig.Head
                end
            end

            for k,v in pairs(model:GetDescendants()) do
                if v:IsA('Attachment') and v.Name == 'effAtt' then
                    local clone = v:Clone()
                    local part = rig:FindFirstChild(v.Parent.Name)
                    if part then
                        clone.Parent = part
                    end
                end
            end

            local color = model:FindFirstChildOfClass('BodyColors')
            if color then
                local color1 = rig:FindFirstChildOfClass('BodyColors')
                if color1 then
                    color1:Destroy()
                end
                color.Parent = rig
            end
            self:Wait(1)
            if rig and rig.Parent then
                for k,v in pairs(rig:GetChildren()) do
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
        end

        self.finish_co = rigHumanoid.ApplyDescriptionFinished:Connect(Finish)

        for k,v in pairs(rig:GetDescendants()) do
            if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Accessory') or v:IsA('Hat') then
                v:Destroy()
            end
            if v:IsA('Attachment') and v.Name == 'effAtt' then
                v:Destroy()
            end
        end

        rigHumanoid:ApplyDescription(desc)
        self:Wait(3)
        Finish()
    else
        --应用
        local head = rig:FindFirstChild('Head')
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
    
                local chaPart = rig:FindFirstChild(v.Name)
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
                
                v.Parent = fol
            end
            if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Hat') or v:IsA('Accessory') then
                v.Parent = rig
            end
        end
        for k,v in ipairs(fol:GetChildren()) do
            if v:IsA('MeshPart') then
                if v:GetAttribute('transparency') then
                    v.Transparency = 1
                else
                    v.Transparency = 0
                end
            end
        end
        for k,v in ipairs(rig:GetChildren()) do
            if v:IsA('MeshPart') then
                v.Transparency = 1
            end
        end
    end

    model:Destroy()

end

---@param rig Model
function c:SetGuildWarRig(uid,rig)
    self:AddProcess(function()
        if not uid or uid == 0 then
            rig:PivotTo(rig:GetPivot() - Vector3.new(0,20,0))
            return
        end

        local data = DataStore:GetAsync(uid)
        if not data then
            data = {
                character = {equiped = 1},
                relics = {
                    equiped = {
                        {unlock = true,relics_id = nil,},
                        {unlock = true,relics_id = nil,},
                        {unlock = true,relics_id = nil,},
                        {unlock = false,relics_id = nil,buy = false},
                        {unlock = false,relics_id = nil,buy = false},
                        {unlock = false,relics_id = nil,buy = false},
                        {unlock = false,relics_id = nil},
                        {unlock = false,relics_id = nil},
                        {unlock = false,relics_id = nil},
                    },--当前装备
                },
                prop = {
                    lv = 1,
                },
            }
        end

        self:AddProcess(function()
            local r,e = pcall(function()
                return players:GetNameFromUserIdAsync(uid)
            end)
            if not r then
                e = 'UnkownName'
            end

            local humanoid = rig:FindFirstChild('Humanoid')
            humanoid.DisplayName = ''

            local name = hotpot:GetPath_Loop('PlayerName.info',rig.PrimaryPart)
            local lv = hotpot:GetPath_Loop('PlayerName.lv',rig.PrimaryPart)

            name.Text = e
            lv.Text = rig:GetAttribute('guild_name')
        end)

        local characterId = data.character.equiped
        local modelName = characterCfg[characterId].model
        local model = characterFol:FindFirstChild(modelName)
        model = hotpot:CloneInst_Loop(model)

        --先删除
        local fol = rig:FindFirstChild('Folder')
        fol:ClearAllChildren()
        for k,v in ipairs(rig:GetChildren()) do
            if v:IsA('Accessory') then
                if not v.Name:find('relicsAcc') then
                    v:Destroy()
                end
            end
            if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Hat') then
                v:Destroy()
            end
        end

        local head__ = rig:FindFirstChild('Head')
        if head__ then
            for k,v in ipairs(head__:GetChildren()) do
                if v.Name == 'effAtt' then
                    v:Destroy()
                end
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
            fol:ClearAllChildren()
            for k,v in ipairs(rig:GetChildren()) do
                if v:IsA('MeshPart') then
                    v.Transparency = 0
                end
            end

            local humanoid = model:FindFirstChild('Humanoid')
            local desc = humanoid:GetAppliedDescription()

            if self.finish_co then
                self.finish_co:Disconnect()
                self.finish_co = nil
            end

            local rigHumanoid = rig:FindFirstChild('Humanoid')

            local function Finish()
                for k,v in ipairs(rig:GetDescendants()) do
                    if v:IsA('SurfaceAppearance') then
                        v:Destroy()
                    end
                end

                for k,v in pairs(model:GetChildren()) do
                    if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Accessory') or v:IsA('Hat') then
                        v:Clone().Parent = rig
                    end
                    if v:IsA('BasePart') then
                        local part = rig:FindFirstChild(v.Name)
                        if part then
                            part.Color = v.Color
                        end
                    end
                    if v:IsA('Attachment') and v.Name == 'effAtt' then
                        local clone = v:Clone()
                        local part = rig:FindFirstChild(v.Name)
                        if part then
                            clone.Parent = part
                        end
                    end
                end
                local head = rig:FindFirstChild('Head')
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
                        face:Clone().Parent = rig.Head
                    end
                end

                for k,v in pairs(model:GetDescendants()) do
                    if v:IsA('Attachment') and v.Name == 'effAtt' then
                        local clone = v:Clone()
                        local part = rig:FindFirstChild(v.Parent.Name)
                        if part then
                            clone.Parent = part
                        end
                    end
                end

                local color = model:FindFirstChildOfClass('BodyColors')
                if color then
                    local color1 = rig:FindFirstChildOfClass('BodyColors')
                    if color1 then
                        color1:Destroy()
                    end
                    color.Parent = rig
                end
                self:Wait(1)
                if rig and rig.Parent then
                    for k,v in pairs(rig:GetChildren()) do
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
            end

            self.finish_co = rigHumanoid.ApplyDescriptionFinished:Connect(Finish)

            for k,v in pairs(rig:GetDescendants()) do
                if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Accessory') or v:IsA('Hat') then
                    v:Destroy()
                end
                if v:IsA('Attachment') and v.Name == 'effAtt' then
                    v:Destroy()
                end
            end

            rigHumanoid:ApplyDescription(desc)
            self:Wait(3)
            Finish()
        else
            --应用
            local head = rig:FindFirstChild('Head')
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
        
                    local chaPart = rig:FindFirstChild(v.Name)
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
                    
                    v.Parent = fol
                end
                if v:IsA('Shirt') or v:IsA('Pants') or v:IsA('Hat') or v:IsA('Accessory') then
                    v.Parent = rig
                end
            end
            for k,v in ipairs(fol:GetChildren()) do
                if v:IsA('MeshPart') then
                    if v:GetAttribute('transparency') then
                        v.Transparency = 1
                    else
                        v.Transparency = 0
                    end
                end
            end
            for k,v in ipairs(rig:GetChildren()) do
                if v:IsA('MeshPart') then
                    v.Transparency = 1
                end
            end
        end

        model:Destroy()

        self:Wait(1)
        --遗物
        local equiped = data.relics.equiped
        local types = {}
        for k,v in pairs(equiped)do
            if v.inst_id then
                pcall(function()
                    local tab = data.relics.newlist[tostring(v.inst_id)]
                    local relics_id = tab.relics_id
                    local type_ = relicsCfg[relics_id].type_
                    local rModel = relicsCfg[relics_id].model
                    if not types[type_] then
                        types[type_] = rModel
                    end
                end)
            end
        end
        if types[7] then
            for k,v in rig:GetChildren()do
                if v:IsA('Accessory') and v.Name == 'weapon' then
                    v:Destroy()
                end
            end
        end
        for _,str in pairs(types)do
            local model = relicsFol:FindFirstChild(str)
            if model then
                model = model:Clone()
                model.Parent = rig
            end
        end

        self:Wait(3)
        for k,v in ipairs(rig:GetDescendants())do
            if v:IsA('BasePart') then
                v.CanCollide = false
            end
        end
    end)
end

return c