local _G = _G
local setmetatable = setmetatable
local table = table
local assert = assert
local Instance = Instance
local ipairs = ipairs
local pairs = pairs
local tostring = tostring
local string = string
local script = script
local Enum = Enum
---@class RagdollLink
local RagdollLink = {}
RagdollLink.Died = true
RagdollLink.FallingDown = true
RagdollLink.FreeFalling = true
RagdollLink.Jumping = true
RagdollLink.PlatformStanding = true
RagdollLink.Ragdoll = true
RagdollLink.Seated = true
RagdollLink.Strafing = true
local hotpot = _G.CommonHotpot
---@type HotpotConnection
local hotpot_connection = hotpot.load.HotpotConnection()
---@class RagdollR15Component:BaseComponent
local c = hotpot.class.new(script,hotpot.files.BaseComponent())
local humanoidstatetype = {
    FallingDown = Enum.HumanoidStateType.FallingDown,
    Running = Enum.HumanoidStateType.Running,
    RunningNoPhysics = Enum.HumanoidStateType.RunningNoPhysics,
    Climbing = Enum.HumanoidStateType.Climbing,
    StrafingNoPhysics = Enum.HumanoidStateType.StrafingNoPhysics,
    Ragdoll = Enum.HumanoidStateType.Ragdoll,
    GettingUp = Enum.HumanoidStateType.GettingUp,
    Jumping = Enum.HumanoidStateType.Jumping,
    Landed = Enum.HumanoidStateType.Landed,
    Flying = Enum.HumanoidStateType.Flying,
    Freefall = Enum.HumanoidStateType.Freefall,
    Seated = Enum.HumanoidStateType.Seated,
    PlatformStanding = Enum.HumanoidStateType.PlatformStanding,
    Dead = Enum.HumanoidStateType.Dead,
    Swimming = Enum.HumanoidStateType.Swimming,
    Physics = Enum.HumanoidStateType.Physics,
    None = Enum.HumanoidStateType.None,
}
local lfunc = {}
---@param self RagdollR15Component
function lfunc.Init(self)
    if self.parent.main_inst.Parent then
        lfunc.GetParts(self)
        lfunc.GetAttachments(self)
        lfunc.CreateNoCollisions(self)
        lfunc.CreateConstraints(self)
        lfunc.GetMotors(self)
    else
        ---@type HotpotConnection
        local cnnt
        ---@type CharacterObject
        local character = self.parent
        character:AddHandleOnInWorkspace(function()
            lfunc.Init(self)
        end,true)
    end
end
---@param self RagdollR15Component
function lfunc.GetMotors(self)
    local parts = self.parts
    local modelMotos = {}
    self.modelMotos = modelMotos
    ---@type Motor6D
    modelMotos.LeftAnkle = parts.LeftFoot.LeftAnkle
    ---@type Motor6D
    modelMotos.LeftWrist = parts.LeftHand.LeftWrist
    ---@type Motor6D
    modelMotos.LeftElbow = parts.LeftLowerArm.LeftElbow
    ---@type Motor6D
    modelMotos.LeftKnee = parts.LeftLowerLeg.LeftKnee
    ---@type Motor6D
    modelMotos.LeftShoulder = parts.LeftUpperArm.LeftShoulder
    ---@type Motor6D
    modelMotos.LeftHip = parts.LeftUpperLeg.LeftHip
    ---@type Motor6D
    modelMotos.Root = parts.LowerTorso.Root
    ---@type Motor6D
    modelMotos.RightAnkle = parts.RightFoot.RightAnkle
    ---@type Motor6D
    modelMotos.RightWrist = parts.RightHand.RightWrist
    ---@type Motor6D
    modelMotos.RightElbow = parts.RightLowerArm.RightElbow
    ---@type Motor6D
    modelMotos.RightKnee = parts.RightLowerLeg.RightKnee
    ---@type Motor6D
    modelMotos.RightShoulder = parts.RightUpperArm.RightShoulder
    ---@type Motor6D
    modelMotos.RightHip = parts.RightUpperLeg.RightHip
    ---@type Motor6D
    modelMotos.Waist = parts.UpperTorso.Waist
    ---@type Motor6D
    modelMotos.Neck = parts.Head.Neck
end
---@param self RagdollR15Component
function lfunc.GetAttachments(self)
    local attachs = {}
    local parts = self.parts
    self.attachs = attachs
    ---@type Attachment
    attachs.Head_Neck = hotpot:GetPath("NeckRigAttachment",parts.Head)
    ---@type Attachment
    attachs.UpperTorso_Neck = hotpot:GetPath("NeckRigAttachment",parts.UpperTorso)
    ---@type Attachment
    attachs.UpperTorso_RightShoulder = hotpot:GetPath("RightShoulderRigAttachment",parts.UpperTorso)
    ---@type Attachment
    attachs.RightUpperArm_RightShoulder = hotpot:GetPath("RightShoulderRigAttachment",parts.RightUpperArm)
    ---@type Attachment
    attachs.UpperTorso_LeftShoulder = hotpot:GetPath("LeftShoulderRigAttachment",parts.UpperTorso)
    ---@type Attachment
    attachs.LeftUpperArm_LeftShoulder = hotpot:GetPath("LeftShoulderRigAttachment",parts.LeftUpperArm)
    ---@type Attachment
    attachs.UpperTorso_Waist = hotpot:GetPath("WaistRigAttachment",parts.UpperTorso)
    ---@type Attachment
    attachs.LowerTorso_Waist = hotpot:GetPath("WaistRigAttachment",parts.LowerTorso)
    ---@type Attachment
    attachs.RightUpperArm_RightElbow = hotpot:GetPath("RightElbowRigAttachment",parts.RightUpperArm)
    ---@type Attachment
    attachs.RightLowerArm_RightElbow = hotpot:GetPath("RightElbowRigAttachment",parts.RightLowerArm)
    ---@type Attachment
    attachs.LeftUpperArm_LeftElbow = hotpot:GetPath("LeftElbowRigAttachment",parts.LeftUpperArm)
    ---@type Attachment
    attachs.LeftLowerArm_LeftElbow = hotpot:GetPath("LeftElbowRigAttachment",parts.LeftLowerArm)
    ---@type Attachment
    attachs.RightLowerArm_RightWrist = hotpot:GetPath("RightWristRigAttachment",parts.RightLowerArm)
    ---@type Attachment
    attachs.RightHand_RightWrist = hotpot:GetPath("RightWristRigAttachment",parts.RightHand)
    ---@type Attachment
    attachs.LeftLowerArm_LeftWrist = hotpot:GetPath("LeftWristRigAttachment",parts.LeftLowerArm)
    ---@type Attachment
    attachs.LeftHand_LeftWrist = hotpot:GetPath("LeftWristRigAttachment",parts.LeftHand)
    ---@type Attachment
    attachs.LowerTorso_RightHip = hotpot:GetPath("RightHipRigAttachment",parts.LowerTorso)
    ---@type Attachment
    attachs.RightUpperLeg_RightHip = hotpot:GetPath("RightHipRigAttachment",parts.RightUpperLeg)
    ---@type Attachment
    attachs.LowerTorso_LeftHip = hotpot:GetPath("LeftHipRigAttachment",parts.LowerTorso)
    ---@type Attachment
    attachs.LeftUpperLeg_LeftHip = hotpot:GetPath("LeftHipRigAttachment",parts.LeftUpperLeg)
    ---@type Attachment
    attachs.RightUpperLeg_RightKnee = hotpot:GetPath("RightKneeRigAttachment",parts.RightUpperLeg)
    ---@type Attachment
    attachs.RightLowerLeg_RightKnee = hotpot:GetPath("RightKneeRigAttachment",parts.RightLowerLeg)
    ---@type Attachment
    attachs.LeftUpperLeg_LeftKnee = hotpot:GetPath("LeftKneeRigAttachment",parts.LeftUpperLeg)
    ---@type Attachment
    attachs.LeftLowerLeg_LeftKnee = hotpot:GetPath("LeftKneeRigAttachment",parts.LeftLowerLeg)
    ---@type Attachment
    attachs.RightLowerLeg_RightAnkle = hotpot:GetPath("RightAnkleRigAttachment",parts.RightLowerLeg)
    ---@type Attachment
    attachs.RightFoot_RightAnkle = hotpot:GetPath("RightAnkleRigAttachment",parts.RightFoot)
    ---@type Attachment
    attachs.LeftLowerLeg_LeftAnkle = hotpot:GetPath("LeftAnkleRigAttachment",parts.LeftLowerLeg)
    ---@type Attachment
    attachs.LeftFoot_LeftAnkle = hotpot:GetPath("LeftAnkleRigAttachment",parts.LeftFoot)
end
---@param self RagdollR15Component
function lfunc.CreateConstraints(self)
    local parts = self.parts
    local attachs = self.attachs
    local constraints = {}
    self.constraints = constraints
    ---@type Folder
    local constraintsFolder = Instance.new("Folder",self.parent.main_inst)
    constraintsFolder.Name = "Constraints"
    self.constraints_folder = constraintsFolder
    --//:创建脖子
    ---@type BallSocketConstraint
    local NeckConstraint = Instance.new("BallSocketConstraint",constraintsFolder)
    constraints.NeckConstraint = NeckConstraint
    NeckConstraint.Name = "NeckConstraint"
    NeckConstraint.LimitsEnabled = true
    NeckConstraint.TwistLimitsEnabled = true
    NeckConstraint.UpperAngle = 60
    NeckConstraint.TwistLowerAngle = -75
    NeckConstraint.TwistUpperAngle = 65
    NeckConstraint.Attachment1 = attachs.Head_Neck
    NeckConstraint.Attachment0 = attachs.UpperTorso_Neck
    --//:创建腰部
    ---@type BallSocketConstraint
    local WaistConstraint = Instance.new("BallSocketConstraint",constraintsFolder)
    constraints.WaistConstraint = WaistConstraint
    WaistConstraint.Name = "WaistConstraint"
    WaistConstraint.LimitsEnabled = true
    WaistConstraint.TwistLimitsEnabled = true
    WaistConstraint.UpperAngle = 30
    WaistConstraint.TwistLowerAngle = -55
    WaistConstraint.TwistUpperAngle = 25
    WaistConstraint.Attachment0 = attachs.LowerTorso_Waist
    WaistConstraint.Attachment1 = attachs.UpperTorso_Waist
    --//:创建右肩关节
    ---@type BallSocketConstraint
    local RightShoulderConstraint = Instance.new("BallSocketConstraint",constraintsFolder)
    constraints.RightShoulderConstraint = RightShoulderConstraint
    RightShoulderConstraint.Name = "RightShoulderConstraint"
    RightShoulderConstraint.LimitsEnabled = true
    RightShoulderConstraint.TwistLimitsEnabled = true
    RightShoulderConstraint.UpperAngle = 45
    RightShoulderConstraint.TwistLowerAngle = -90
    RightShoulderConstraint.TwistUpperAngle = 150
    RightShoulderConstraint.Attachment0 = attachs.UpperTorso_RightShoulder
    RightShoulderConstraint.Attachment1 = attachs.RightUpperArm_RightShoulder
    --//:创建左肩关节
    ---@type BallSocketConstraint
    local LeftShoulderConstraint = Instance.new("BallSocketConstraint",constraintsFolder)
    constraints.LeftShoulderConstraint = LeftShoulderConstraint
    LeftShoulderConstraint.Name = "LeftShouldderConstraint"
    LeftShoulderConstraint.LimitsEnabled = true
    LeftShoulderConstraint.TwistLimitsEnabled = true
    LeftShoulderConstraint.UpperAngle = 45
    LeftShoulderConstraint.TwistLowerAngle = -90
    LeftShoulderConstraint.TwistUpperAngle = 150
    LeftShoulderConstraint.Attachment0 = attachs.UpperTorso_LeftShoulder
    LeftShoulderConstraint.Attachment1 = attachs.LeftUpperArm_LeftShoulder
    --//:创建右肘关节
    ---@type HingeConstraint
    local RightElbowConstraint = Instance.new("HingeConstraint",constraintsFolder)
    constraints.RightElbowConstraint = RightElbowConstraint
    RightElbowConstraint.Name = "RightElbowConstraint"
    RightElbowConstraint.LimitsEnabled = true
    RightElbowConstraint.UpperAngle = 135
    RightElbowConstraint.LowerAngle = 0
    RightElbowConstraint.Restitution = 0
    RightElbowConstraint.Attachment0 = attachs.RightUpperArm_RightElbow
    RightElbowConstraint.Attachment1 = attachs.RightLowerArm_RightElbow
    --//:创建左肘关节
    ---@type HingeConstraint
    local LeftElbowConstraint = Instance.new("HingeConstraint",constraintsFolder)
    constraints.LeftElbowConstraint = LeftElbowConstraint
    LeftElbowConstraint.Name = "LeftElbowConstraint"
    LeftElbowConstraint.LimitsEnabled = true
    LeftElbowConstraint.UpperAngle = 135
    LeftElbowConstraint.LowerAngle = 0
    LeftElbowConstraint.Restitution = 0
    LeftElbowConstraint.Attachment0 = attachs.LeftUpperArm_LeftElbow
    LeftElbowConstraint.Attachment1 = attachs.LeftLowerArm_LeftElbow
    --//:创建右腕关节
    ---@type BallSocketConstraint
    local RightWristConstraint = Instance.new("BallSocketConstraint",constraintsFolder)
    constraints.RightWristConstraint = RightWristConstraint
    RightWristConstraint.Name = "RightWristConstraint"
    RightWristConstraint.LimitsEnabled = true
    RightWristConstraint.TwistLimitsEnabled = true
    RightWristConstraint.UpperAngle = 30
    RightWristConstraint.TwistLowerAngle = -45
    RightWristConstraint.TwistUpperAngle = 45
    RightWristConstraint.Attachment0 = attachs.RightLowerArm_RightWrist
    RightWristConstraint.Attachment1 = attachs.RightHand_RightWrist
    --//:创建左腕关节
    ---@type BallSocketConstraint
    local LeftWristConstraint = Instance.new("BallSocketConstraint",constraintsFolder)
    constraints.LeftWristConstraint = LeftWristConstraint
    LeftWristConstraint.Name = "LeftWristConstraint"
    LeftWristConstraint.LimitsEnabled = true
    LeftWristConstraint.TwistLimitsEnabled = true
    LeftWristConstraint.UpperAngle = 30
    LeftWristConstraint.TwistLowerAngle = -45
    LeftWristConstraint.TwistUpperAngle = 45
    LeftWristConstraint.Attachment0 = attachs.LeftLowerArm_LeftWrist
    LeftWristConstraint.Attachment1 = attachs.LeftHand_LeftWrist
    --//:创建右髋关节
    ---@type BallSocketConstraint
    local RightHipConstraint = Instance.new("BallSocketConstraint",constraintsFolder)
    constraints.RightHipConstraint = RightHipConstraint
    RightHipConstraint.Name = "RightHipConstraint"
    RightHipConstraint.LimitsEnabled = true
    RightHipConstraint.TwistLimitsEnabled = true
    RightHipConstraint.UpperAngle = 50
    RightHipConstraint.TwistLowerAngle = 100
    RightHipConstraint.TwistUpperAngle = -45
    RightHipConstraint.Attachment0 = attachs.LowerTorso_RightHip
    RightHipConstraint.Attachment1 = attachs.RightUpperLeg_RightHip
    --//:创建左髋关节
    ---@type BallSocketConstraint
    local LeftHipConstraint = Instance.new("BallSocketConstraint",constraintsFolder)
    constraints.LeftHipConstraint = LeftHipConstraint
    LeftHipConstraint.Name = "LeftHipConstraint"
    LeftHipConstraint.LimitsEnabled = true
    LeftHipConstraint.TwistLimitsEnabled = true
    LeftHipConstraint.UpperAngle = 50
    LeftHipConstraint.TwistLowerAngle = 100
    LeftHipConstraint.TwistUpperAngle = -45
    LeftHipConstraint.Attachment0 = attachs.LowerTorso_LeftHip
    LeftHipConstraint.Attachment1 = attachs.LeftUpperLeg_LeftHip
    --//:创建右膝盖关节
    ---@type HingeConstraint
    local RightKneeConstraint = Instance.new("HingeConstraint",constraintsFolder)
    constraints.RightKneeConstraint = RightKneeConstraint
    RightKneeConstraint.Name = "RightKneeConstraint"
    RightKneeConstraint.LimitsEnabled = true
    RightKneeConstraint.UpperAngle = -140
    RightKneeConstraint.LowerAngle = 0
    RightKneeConstraint.UpperAngle = 0
    RightKneeConstraint.Attachment0 = attachs.RightUpperLeg_RightKnee
    RightKneeConstraint.Attachment1 = attachs.RightLowerLeg_RightKnee
    --//:创建左膝盖关节
    ---@type HingeConstraint
    local LeftKneeConstraint = Instance.new("HingeConstraint",constraintsFolder)
    constraints.LeftKneeConstraint = LeftKneeConstraint
    LeftKneeConstraint.Name = "LeftKneeConstraint"
    LeftKneeConstraint.LimitsEnabled = true
    LeftKneeConstraint.UpperAngle = -140
    LeftKneeConstraint.LowerAngle = 0
    LeftKneeConstraint.UpperAngle = 0
    LeftKneeConstraint.Attachment0 = attachs.LeftUpperLeg_LeftKnee
    LeftKneeConstraint.Attachment1 = attachs.LeftLowerLeg_LeftKnee
    --//:创建右脚关节
    ---@type BallSocketConstraint
    local RightAnkleConstraint = Instance.new("BallSocketConstraint",constraintsFolder)
    constraints.RightAnkleConstraint = RightAnkleConstraint
    RightAnkleConstraint.Name = "RightAnkleConstraint"
    RightAnkleConstraint.LimitsEnabled = true
    RightAnkleConstraint.TwistLimitsEnabled = true
    RightAnkleConstraint.UpperAngle = 30
    RightAnkleConstraint.TwistLowerAngle = -45
    RightAnkleConstraint.TwistUpperAngle = 30
    RightAnkleConstraint.Attachment0 = attachs.RightLowerLeg_RightAnkle
    RightAnkleConstraint.Attachment1 = attachs.RightFoot_RightAnkle
    --//:创建左脚关节
    ---@type BallSocketConstraint
    local leftAnkleConstraint = Instance.new("BallSocketConstraint",constraintsFolder)
    constraints.leftAnkleConstraint = leftAnkleConstraint
    leftAnkleConstraint.Name = "leftAnkleConstraint"
    leftAnkleConstraint.LimitsEnabled = true
    leftAnkleConstraint.TwistLimitsEnabled = true
    leftAnkleConstraint.UpperAngle = 30
    leftAnkleConstraint.TwistLowerAngle = -45
    leftAnkleConstraint.TwistUpperAngle = 30
    leftAnkleConstraint.Attachment0 = attachs.LeftLowerLeg_LeftAnkle
    leftAnkleConstraint.Attachment1 = attachs.LeftFoot_LeftAnkle
    --默认关闭
    for name,constraint in pairs(constraints) do
        constraint.Enabled = false
    end
end
---@param self RagdollR15Component
function lfunc.GetParts(self)
    local parts = {}
    self.parts = parts
    local model = self.parent.main_inst
    ---@type Part
    parts.Head = hotpot:GetPath("Head",model)
    ---@type Part
    parts.UpperTorso = hotpot:GetPath("UpperTorso",model)
    ---@type Part
    parts.LowerTorso = hotpot:GetPath("LowerTorso",model)
    ---@type Part
    parts.RightUpperArm = hotpot:GetPath("RightUpperArm",model)
    ---@type Part
    parts.RightLowerArm = hotpot:GetPath("RightLowerArm",model)
    ---@type Part
    parts.LeftUpperArm = hotpot:GetPath("LeftUpperArm",model)
    ---@type Part
    parts.LeftLowerArm = hotpot:GetPath("LeftLowerArm",model)
    ---@type Part
    parts.RightHand = hotpot:GetPath("RightHand",model)
    ---@type Part
    parts.LeftHand = hotpot:GetPath("LeftHand",model)
    ---@type Part
    parts.RightUpperLeg = hotpot:GetPath("RightUpperLeg",model)
    ---@type Part
    parts.LeftUpperLeg = hotpot:GetPath("LeftUpperLeg",model)
    ---@type Part
    parts.RightLowerLeg = hotpot:GetPath("RightLowerLeg",model)
    ---@type Part
    parts.LeftLowerLeg = hotpot:GetPath("LeftLowerLeg",model)
    ---@type Part
    parts.RightFoot = hotpot:GetPath("RightFoot",model)
    ---@type Part
    parts.LeftFoot = hotpot:GetPath("LeftFoot",model)
    ---@type Part
    parts.HumanoidRootPart = hotpot:GetPath("HumanoidRootPart",model)
end
---@param self RagdollR15Component
local no_collidsion_map = {
    {"Head","LeftUpperArm"},
    {"Head","LeftUpperLeg"},
    {"Head","LowerTorso"},
    {"Head","RightUpperArm"},
    {"Head","RightUpperLeg"},
    {"Head","UpperTorso"},
    {"LeftFoot","Lowertorso"},
    {"LeftFoot","UpperTorso"},
    {"LeftFoot","LeftLowerLeg"},
    {"LeftFoot","LeftUpderLeg"},
    {"LeftHand","LowerTorso"},
    {"LeftLowerArm","LowerTorso"},
    {"LeftLowerArm","UpperTorso"},
    {"LeftLowerLeg","LowerTorso"},
    {"LeftLowerLeg","UpperTorso"},
    {"LeftUpperArm","LeftUpperLeg"},
    {"LeftUpperArm","LowerTorso"},
    {"LeftUpperArm","RightUpperArm"},
    {"LeftUpperArm","RightUpperLeg"},
    {"LeftUpperArm","UpperTorso"},
    {"LeftUpperLeg","LowerTorso"},
    {"LeftUpperLeg","RightUpperLeg"},
    {"LeftUpperLeg","UpperTorso"},
    {"RightFoot","LowerTorso"},
    {"RightFoot","UpperTorso"},
    {"RightFoot","RightLowerLeg"},
    {"RightFoot","RightUpperLeg"},
    {"RightHand","UpperTorso"},
    {"RightLowerArm","UpperTorso"},
    {"RightLowerArm","LowerTorso"},
    {"RightLowerLeg","UpperTorso"},
    {"RightLowerLeg","LeftUpperArm"},
    {"RightUpperArm","LeftUpperLeg"},
    {"RightUpperArm","LowerTorso"},
    {"RightUpperArm","RightUpperLeg"},
    {"RightUpperArm","UpperTorso"},
    {"RightUpperArm","LeftUpperLeg"},
    {"RightUpperLeg","LowerTorso"},
    {"RightUpperLeg","UpperTorso"},
    {"RightUpperLeg","LeftUpperLeg"},
    {"HumanoidRootPart","Head"},
    {"HumanoidRootPart","LeftFoot"},
    {"HumanoidRootPart","LeftLowerArm"},
    {"HumanoidRootPart","LeftLowerLeg"},
    {"HumanoidRootPart","LeftUpperArm"},
    {"HumanoidRootPart","LeftUpperLeg"},
    {"HumanoidRootPart","RightFoot"},
    {"HumanoidRootPart","RightHand"},
    {"HumanoidRootPart","RightLowerArm"},
    {"HumanoidRootPart","RightLowerLeg"},
    {"HumanoidRootPart","RightUpperArm"},
    {"HumanoidRootPart","RightUpperLeg"},
    {"HumanoidRootPart","LowerTorso"},
    {"HumanoidRootPart","UpperTorso"},
    {"HumanoidRootPart","LeftHand"},
}
function lfunc.CreateNoCollisions(self)
    local parts = self.parts
    ---@type Folder
    local NoCollisionFolder = Instance.new("Folder",self.parent.main_inst)
    NoCollisionFolder.Name = "NoCollisions"
    self.no_collision_folder = NoCollisionFolder
    local NoCollisions = {} 
    self.no_collisions = NoCollisions
    for idx,info in ipairs(no_collidsion_map) do
        ---@type NoCollisionConstraint
        local no_collision_constraint = Instance.new('NoCollisionConstraint',NoCollisionFolder)
        no_collision_constraint.Name = string.format("%s<->%s",table.unpack(info))
        no_collision_constraint.Part0 = parts[info[1]]
        no_collision_constraint.Part1 = parts[info[2]]
        no_collision_constraint.Enabled = false
        NoCollisions[no_collision_constraint.Name] = no_collision_constraint
    end
end
---@param parent CharacterObject
function c:ctor(parent)
    c.super.ctor(self,parent)
    self.num = 1
    self.humanoid = parent:GetHumanoid_Loop()
    assert(self.humanoid.RigType==Enum.HumanoidRigType.R15,"this model is not r15")
    self.humanoid.RequiresNeck = false
    self.humanoid.BreakJointsOnDeath = false
    lfunc.Init(self)
    local state_connects = {}
    local meta = {}
    function meta.__index(tab,key)
        return state_connects[key]
    end
    function meta.__newindex(tab,key,val)
        assert(RagdollLink[key],"do not support state "..tostring(key))
        if val then
            state_connects[key] = self.humanoid[key]:Connect(function(active)
                if active == nil then
                    active = true
                end
                self:SetSwitch(active)
            end)
        else
            if state_connects[key] then
                state_connects[key]:Destroy()
                state_connects[key] = nil
            end
        end
    end
    ---@type RagdollLink
    self.links = setmetatable({},meta)
end
function c:SetSwitch(sw)
    self.ragdollState = sw
    for motor_name,motor in pairs(self.modelMotos) do
        if motor.Name ~= "Root" then
            motor.Enabled = not sw
        end
    end
    for constraints_name,constraint in pairs(self.constraints) do
        constraint.Enabled = sw
    end
    for part_name,part in pairs(self.parts) do
        ---@type Part
        local p = part
        p.CanCollide = sw
    end
    for name,no_collide in pairs(self.no_collisions) do
        no_collide.Enabled = sw
    end
end
function c:SetRagdoll(index)
    self.num = index 
    if self.num == 1 then
        self:SetSwitch(true)
    elseif self.num == 2 then
        self.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
        self.humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
        self:SetSwitch(true)
    elseif self.num == 3 then
        self:SetSwitch(false)
    end
end
function c:dtor()
    if self.no_collision_folder and self.no_collision_folder.Parent then
        self.no_collision_folder:Destroy()
    end
    if self.constraints_folder and self.constraints_folder.Parent then
        self.constraints_folder:Destroy()
    end
    c.super.dtor(self)
end
function c.new(parent)
    return c(parent)
end
return c