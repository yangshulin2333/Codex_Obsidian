local _G = _G
local wait = wait
local Enum = Enum
local Vector3 = Vector3
local script = script
local assert = assert
local hotpot = _G.CommonHotpot
local callback_manager = hotpot.load.CallBackManager()
---@class CharacterObject:ModelObject
---@field main_inst Model
local c = hotpot.class.new(script,hotpot.files.ModelObject())
local HumanoidCollisionType = {
    OuterBox = 0,
    InnerBox = 1,
    [0] = "OuterBox",
    [1] = "InnerBox",
}
local HumanoidDisplayDistanceType = {
    Viewer = 0,
    Subject = 1,
    None = 2,
    [0] = "Viewer",
    [1] = "Subject",
    [2] = "None",
}
local HumanoidHealthDisplayType = {
    DisplayWhenDamaged = 0,
    AlwaysOn = 1,
    AlwaysOff = 2,
    [0] = "DisplayWhenDamaged",
    [1] = "AlwaysOn",
    [2] = "AlwaysOff"
}
local NameOcclusion = {
    OccludeAll = 2,
    EnemyOcclusion = 1,
    NoOcclusion = 0,
    [0] = "NoOcclusion",
    [1] = "EnemyOcclusion",
    [2] = "OccludeAll",
}
local HumanoidRigType = {
    R6 = 0,
    R15 = 1,
    [0] = "R6",
    [1] = "R15",
}
function c.new(model,...)
    assert(model,"param model is nil")
    return c(model,...)
end
function c:ctor(model,...)
    c.super.ctor(self,model,...)
    assert(self:GetHumanoid(),"model don't have humanoid")
    if self.OnDead then
        local humanoid = self:GetHumanoid_Check()
        callback_manager:AddRbxConnect(self,humanoid.Died,self.OnDead)
    end
    self:GetHumanoid_Check()
end
function c:dtor()
    c.super.dtor(self)
end
---@return Humanoid
function c:GetHumanoid()
    if self.humanoid then
        return self.humanoid
    end
    ---@type Humanoid
    self.humanoid = self:WaitForChild("Humanoid")
    return self.humanoid
end
---@return Humanoid
function c:GetHumanoid_Check()
    if self.humanoid then
        return self.humanoid
    end
    self.humanoid = self:WaitForChild_Check("Humanoid")
    return self.humanoid
end
---@return Humanoid
function c:GetHumanoid_Loop()
    if self.humanoid then
        return self.humanoid
    end
    self.humanoid = self:WaitForChild_Loop("Humanoid")
    return self.humanoid
end
---@return number
function c:GetHeight()
    local humanoid = self:GetHumanoid_Check()
    local root_part = self:GetRootPart_Check()
    return humanoid.HipHeight + root_part.Size.Y/2
end
function c:SetAutoJumpEnabled(switch)
    if switch == nil then
        switch = false
    end
    local humanoid = self:GetHumanoid_Check()
    humanoid.AutoJumpEnabled = switch
end
---@return boolean
function c:IsAutoJumpEnabled()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.AutoJumpEnabled
end
function c:SetAutoRotate(switch)
    if switch == nil then
        switch = false
    end
    local humanoid = self:GetHumanoid_Check()
    humanoid.AutoRotate = switch
end
---@return boolean
function c:IsAutoRotate()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.AutoRotate
end
---@return number
function c:GetWalkSpeed()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.WalkSpeed
end
---@param speed number
function c:SetWalkSpeed(speed)
    assert(speed,"param speed is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid.WalkSpeed = speed
end
function c:SetBreakJointsOnDeath(switch)
    if switch == nil then
        switch = false
    end
    local humanoid = self:GetHumanoid_Check()
    humanoid.BreakJointsOnDeath = switch
end
function c:IsBreakJointsOnDeath()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.BreakJointsOnDeath
end
function c:SetAutomaticScalingEnabled(switch)
    if switch == nil then
        switch = false
    end
    local humanoid = self:GetHumanoid_Check()
    humanoid.AutomaticScalingEnabled = switch
end
function c:IsAutomaticScalingEnabled()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.AutomaticScalingEnabled
end
---@param offset Vector3
function c:SetCameraOffset(offset)
    assert(offset,"param offset is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid.CameraOffset = offset
end
---@return Vector3
function c:GetCameraOffset()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.CameraOffset
end
---@type fun(collision_type:string)
---@param collision_type string | "'OuterBox'" | "'InnerBox'"
function c:SetCollisionType(collision_type)
    assert(collision_type,"param collision type is nil")
    local ctype = HumanoidCollisionType[collision_type]
    assert(ctype,"no such collision type")
    local humanoid = self:GetHumanoid_Check()
    humanoid.CollisionType = ctype
end
function c:GetCollisionType()
    local humanoid = self:GetHumanoid_Check()
    return HumanoidCollisionType[humanoid.CollisionType]
end
---@type fun(distance_type :string)
---@param distance_type string | "'Viewer'" | "'Subject'" | "'None'"
function c:SetDisplayDistanceType(distance_type)
    assert(distance_type,"param distance type is nil")
    local dtype = HumanoidDisplayDistanceType[distance_type]
    assert(dtype,"no such display distance type")
    local humanoid = self:GetHumanoid_Check()
    humanoid.DisplayDistanceType = dtype
end
function c:GetDisplayDistanceType()
    local humanoid = self:GetHumanoid_Check()
    return HumanoidDisplayDistanceType[humanoid.DisplayDistanceType]
end
function c:SetDisplayName(name)
    assert(name,"param name is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid.DisplayName = name
end
function c:GetDisplayName()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.DisplayName
end
function c:SetMaxHp(max_hp)
    assert(max_hp,"param max hp is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid.MaxHealth = max_hp
end
function c:GetMaxHp()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.MaxHealth
end
function c:SetHp(hp)
    assert(hp,"param hp is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid.Health = hp
end
function c:GetHp()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.Health
end
function c:SetHealthDisplayDistance(distance)
    local humanoid = self:GetHumanoid_Check()
    humanoid.HealthDisplayDistance = distance
end
function c:GetHealthDisplayDistance()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.HealthDisplayDistance
end
function c:SetHealthDisplayType(display_type)
    assert(display_type,"param displayer type is nil")
    local dtype = HumanoidHealthDisplayType[display_type]
    assert(dtype,"no such health display type")
    local humanoid = self:GetHumanoid_Check()
    humanoid.HealthDisplayType = dtype
end
function c:GetHealthDisplayType()
    local humanoid = self:GetHumanoid_Check()
    return HumanoidHealthDisplayType[humanoid.HealthDisplayType]
end
function c:Jump()
    local humanoid = self:GetHumanoid_Check()
    humanoid.Jump = true
end
function c:IsJumping()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.Jump
end
function c:SetJumpHeight(height)
    assert(height,"param height is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid.JumpHeight = height
end
function c:GetJumpHeight()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.JumpHeight
end
function c:SetJumpPower(power)
    assert(power,"param power is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid.JumpPower = power
end
function c:GetJumpPower()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.JumpPower
end
function c:SetMaxSlopAngle(angle)
    assert(angle,"param angle is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid.MaxSlopeAngle = angle
end
function c:GetMaxSlopAngle()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.MaxSlopeAngle
end
function c:SetNameDisplayDistance(distance)
    assert(distance,"param distance is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid.NameDisplayDistance = distance
end
function c:GetNameDisplayDistance()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.NameDisplayDistance
end
---@type fun(occlusion_type:string)
---@param occlusion_type string | "'NoOcclusion'" | "'EnemyOcclusion'" | "'OccludeAll'"
function c:SetNameOcclusion(occlusion_type)
    assert(occlusion_type,"param occlusion type is nil")
    local otype = NameOcclusion[occlusion_type]
    assert(otype,"no such occlude type")
    local humanoid = self:GetHumanoid_Check()
    humanoid.NameOcclusion = otype
end
function c:GetnameOcclusion()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.NameOcclusion
end
function c:SetPlatformStand(switch)
    if switch == nil then
        switch = false
    end
    local humanoid = self:GetHumanoid_Check()
    humanoid.PlatformStand = switch
end
function c:IsPlatformStand()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.PlatformStand
end
function c:SetRequiresNeck(switch)
    if switch == nil then
        switch = false
    end
    local humanoid = self:GetHumanoid_Check()
    humanoid.RequiresNeck = switch
end
function c:IsRequiresNeck()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.RequiresNeck
end
---@type fun(rig_type:string)
---@param rig_type string | "'R6'" | "'R15'"
function c:SetRigType(rig_type)
    assert(rig_type,"param rig type is nil")
    local rtype  = HumanoidRigType[rig_type]
    assert(rtype,"no such rig type")
    local humanoid = self:GetHumanoid_Check()
    humanoid.RigType = rtype
end
function c:GetRigType()
    local humanoid = self:GetHumanoid_Check()
    return HumanoidRigType[humanoid.RigType]
end
---@return Part
function c:GetSeatPart()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.SeatPart
end
function c:IsSit()
    local humanoid = self:GetHumanoid_Check()
    return humanoid.Sit
end
---@return Vector3
function c:GetBottomPosition()
    local height = self:GetHeight()
    local position = self:GetPosition()
    return position - Vector3.new(0,height,0)
end
function c:SetBottomPosition(position)
    assert(position,"param position is nil")
    local height = self:GetHeight()
    self:SetPosition(position + Vector3.new(0,height,0))
end
function c:SetPosition(position)
    assert(position,"param position is nil")
    local humanoid = self:GetHumanoid_Check()
    local fallingdown = humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown)
    local freefall = humanoid:GetStateEnabled(Enum.HumanoidStateType.Freefall)
    local flying = humanoid:GetStateEnabled(Enum.HumanoidStateType.Flying)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
    c.super.SetPosition(self,position)
    self:AddProcess(function()
        self:Wait()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,fallingdown)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,freefall)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,flying)
    end)
end
---@param position Vector3
function c:WalkTo(position)
    assert(position,"param position is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid:MoveTo(position)
end
function c:MoveDirection(dir)
    assert(dir,"param position is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid:Move(dir)
end
function c:TakeDamage(damage)
    assert(damage,"param damage is nil")
    local humanoid = self:GetHumanoid_Check()
    humanoid:TakeDamage(damage)
end
function c:UseJumpPower(switch)
    if switch == nil then
        switch = false
    end
    local humanoid = self:GetHumanoid_Check()
    humanoid.UseJumpPower = switch
end
return c