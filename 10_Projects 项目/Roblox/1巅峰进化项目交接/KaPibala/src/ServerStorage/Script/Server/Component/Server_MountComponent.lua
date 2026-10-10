local hotpot = _G.ServerHotpot

local mountFol = hotpot:GetPath_Loop('mount',hotpot.Resource)
local mountCfg = hotpot.config.mount
local forgeCostCfg = hotpot.config.forgeCost
local luckyStoneCfg = hotpot.config.luckyStone

---@class Server_MountComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.__add = 0

    self.data = self.parent.save_data:GetData('mount')

    for id,v in pairs(self.data.__real.list)do
        if v == true then
            self.parent.save_data:Execut(function()
                self.data.list[id] = {
                    big = 0,
                    small = 0,
                }
            end)
        end
    end

    self:AddProcess(function()
        while true do
            self:Wait(0.15)
            if self.__ride then
                if self.parent and self.parent.character and self.parent.character.humanoid then
                    if self.data.__real.equiped == 4 and self.parent.character.humanoid.MoveDirection.Magnitude > 0 then
                        self.__add = 4
                    else
                        self.__add = 0
                    end
                    self.parent.character.humanoid.HipHeight = self.now_hipHight + self.__add
                end
            end
        end
    end)
end

function c:dtor()
    if self.mount then
        self.mount:Destroy()
        self.mount = nil
    end
    c.super.dtor(self)
end

function c:ClientUnlockMount(id)
    local cfg = mountCfg[id]
    if not cfg then
        return
    end
    if cfg.lockCondition == 2 then
        local lv = self.parent.prop_cmp:GetLv()
        if lv < 22 then
            return false
        end 
        self:UnlockMount(id)
    end
    return true
end

function c:UnlockMount(id)
    if self.data.__real.list[id] then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.list[id] = {
            big = 0,
            small = 0,
        }
    end)

    self:Fire('unlock_mount',id)

    return true
end

function c:EquipMount(id)
    if self.data.__real.equiped == id then
        return
    end

    if not self.data.__real.list[id] then
        return false
    end

    self.parent.save_data:Execut(function()
        self.data.equiped = id
    end)

    if self.mount then
        self.mount:Destroy()
        self.mount = nil
    end

    local cfg = mountCfg[id]
    if not cfg then
        return
    end
    local mountModel = hotpot:GetPath_Loop(cfg.model,mountFol)
    ---@type Model
    local mount = hotpot:CloneInst_Loop(mountModel)
    mount.Parent = workspace
    for k,v in ipairs(mount:GetDescendants()) do
        if v:IsA('BasePart') then
            v.Anchored = false
            v.CanCollide = false
            v.Massless = true
        end
    end

    if not self.parent.character then
        return
    end
    self.parent.character:SetEffY(cfg.offset)
    
    local bottom_pos = self.parent.character:GetBottomPosition()
    local cf = self.parent.character:GetCFrame()

    local mcf,size = mount:GetBoundingBox()

    local mount_pos = bottom_pos + Vector3.new(0,size.Y/2,0)

    mount:PivotTo(CFrame.new(mount_pos,mount_pos + cf.LookVector))

    -- local seat = hotpot:GetPath_Loop('Mount.Seat',mount)
    local playerValue = hotpot:GetPath_Loop('player',mount)
    local bottom_att = hotpot:GetPath_Loop('bottom',mount.PrimaryPart)

    local weld = Instance.new('Weld')
    local root = mount.PrimaryPart
    weld.Parent = root
    weld.Part0 = root
    weld.Part1 = self.parent.character.root_part
    weld.C1 = CFrame.new(Vector3.new(0,cfg.Yoffset))
    self.old_height = self.parent.character.humanoid.HipHeight
    self.now_hipHight = cfg.hipHight
    self.parent.character.humanoid.HipHeight = self.now_hipHight
    self.__ride = true

    playerValue.Value = self.parent.main_inst
    -- seat:Sit(self.parent.character.humanoid)

    self.mount = mount
    self.bottom_att = bottom_att

    self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetSpeed())

    return true,mount
end

function c:UnEquipMount()
    local now = self.data.__real.equiped
    if now == 0 then
        return
    end
    self.parent.save_data:Execut(function()
        self.data.equiped = 0
    end)

    if self.mount then
        self.mount:Destroy()
        self.mount = nil
    end
    self.bottom_att = nil

    self.parent.character.humanoid.HipHeight = self.old_height or 2
    self.__ride = false

    self.parent.character:SetEffY()
    self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetSpeed())

    return true
end

function c:Ride()
    if self.data.__real.equiped == 0 then
        return
    end
    if self.mount then
        return
    end
    local id = self.data.__real.equiped
    local cfg = mountCfg[id]
    if not cfg then
        return
    end
    local mountModel = hotpot:GetPath_Loop(cfg.model,mountFol)
    ---@type Model
    local mount = hotpot:CloneInst_Loop(mountModel)
    mount.Parent = workspace
    for k,v in ipairs(mount:GetDescendants()) do
        if v:IsA('BasePart') then
            v.Anchored = false
            v.CanCollide = false
            v.Massless = true
        end
    end

    if self.parent and self.parent.character then
        self.parent.character:SetEffY(cfg.offset)
    end
    
    local bottom_pos = self.parent.character:GetBottomPosition()
    local cf = self.parent.character:GetCFrame()

    local mcf,size = mount:GetBoundingBox()

    local mount_pos = bottom_pos + Vector3.new(0,size.Y/2,0)

    mount:PivotTo(CFrame.new(mount_pos,mount_pos + cf.LookVector))

    -- local seat = hotpot:GetPath_Loop('Mount.Seat',mount)

    local weld = Instance.new('Weld')
    local root = mount.PrimaryPart
    weld.Parent = root
    weld.Part0 = root
    weld.Part1 = self.parent.character.root_part
    weld.C1 = CFrame.new(Vector3.new(0,cfg.Yoffset))
    self.old_height = self.parent.character.humanoid.HipHeight
    self.now_hipHight = cfg.hipHight
    self.parent.character.humanoid.HipHeight = self.now_hipHight

    local playerValue = hotpot:GetPath_Loop('player',mount)
    local bottom_att = hotpot:GetPath_Loop('bottom',mount.PrimaryPart)

    playerValue.Value = self.parent.main_inst
    -- seat:Sit(self.parent.character.humanoid)

    self.mount = mount
    self.bottom_att = bottom_att

    self.__ride = true
    self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetSpeed())


    return true,mount
end

function c:UnRide()
    if not self.mount then
        return
    end
    self.mount:Destroy()
    self.mount = nil
    self.bottom_att = nil
    self.parent.character:SetEffY()
    self.__ride = false
    self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetSpeed())
    self.parent.character.humanoid.HipHeight = self.old_height or 2
    return true
end

function c:GetSpeed()
    if not self.__ride then
        return 0
    end
    local id = self.data.__real.equiped
    if id == 0 then
        return 0
    end
    local cfg = mountCfg[id]
    if not cfg then
        return 0
    end

    local tab = self.data.__real.list[id]
    local big = tab.big or 0

    local speed = cfg.speed
    local per = forgeCostCfg[big] and forgeCostCfg[big].big or 0
    if big > 0 then
        speed = speed * (1 + per/100)
    end
    return speed * 0.01
end

function c:ForgeMount(id,list)
    local tab = self.data.__real.list[id]
    if not tab then
        return false
    end
    local big = tab.big or 0
    local small = tab.small or 0
    if small >= 10 then
        return false
    end
    local cost = forgeCostCfg[small + 1].forgeStone 
    local stoneIdx = 0
    if small <= 3 then
        stoneIdx = 1
    elseif small <= 6 then
        stoneIdx = 2
    else
        stoneIdx = 3
    end
    local stoneNum = self.parent.relics_cmp.data.__real.forgeStone.list[stoneIdx] or 0
    if stoneNum < cost then
        return false
    end
    local gold = forgeCostCfg[small + 1].gold
    if self.parent.prop_cmp:GetWins() < gold then
        return false
    end
    local addPer = 0
    for id,num in pairs(list)do
        local now = self.parent.relics_cmp.data.__real.luckyStone.list[id] or 0
        if now < num then
            return false
        end
        addPer = addPer + num * luckyStoneCfg[id].per
    end

    local per = forgeCostCfg[small + 1].per + addPer

    local success = false
    if per < 100 then
        local num = math.random(1,100*10000)
        if num > per*10000 then
            success = false
        else
            success = true
        end
    else
        success = true
    end
    self.parent.relics_cmp:UseForgeStone(stoneIdx,cost)
    self.parent.prop_cmp:CostWins(gold)
    self.parent.save_data:Execut(function()
        if success then
            if small == big then
                self.data.list[id].small = small + 1
                self.data.list[id].big = big + 1
            else
                self.data.list[id].small = small + 1
            end
        else
            self.data.list[id].small = 0
        end
    end)
    for id,num in pairs(list)do
        self.parent.relics_cmp:UseLuckyStone(id,num)
    end

    return true,success
end

c:RegistFunction('equipMount',c.EquipMount)
c:RegistFunction('unEquipMount',c.UnEquipMount)
c:RegistFunction('unlockMount',c.ClientUnlockMount)
c:RegistFunction('rideMount',c.Ride)
c:RegistFunction('unrideMount',c.UnRide)
c:RegistFunction('forgeGuildMount',c.ForgeMount)

return c