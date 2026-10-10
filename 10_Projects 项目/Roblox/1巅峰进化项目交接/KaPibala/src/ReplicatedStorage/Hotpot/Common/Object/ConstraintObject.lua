local hotpot = _G.CommonHotpot
---@class ConstraintObject:GameObject
---@field main_inst Constraint
local c = hotpot.class.new(script, hotpot.files.GameObject())

-- function c.new(constraint)
--     assert(constraint, "param Constraint is nil")
--     return c(constraint)
-- end

---@type fun(constraint_str:string | Instance,parent:Instance,attachment0:Attachment,attachment1:Attachment)
---@param constraint_str string | '"AlignOrientation"' | '"AlignPosition"' | '"AngularVelocity"' | '"BallSocketConstraint"' | '"CylindricalConstraint"' | '"HingeConstraint"' | '"LineForce"' | '"LinearVelocity"' | '"NoCollisionConstraint"' | '"PlaneConstraint"' | '"PrismaticConstraint"' | '"RigidConstraint"' | '"RodConstraint"' | '"RopeConstraint"' | '"SpringConstraint"' | '"TorsionSpringConstraint"' | '"Torque"' | '"UniversalConstraint"' | '"VectorForce"'
function c.new(constraint, parent, attachment0, attachment1)
    assert(constraint, "param constraint_string | instance is nil")
    local new_constraint
    if type(constraint) == "string" then
        xpcall(
            function()
                new_constraint = Instance.new(constraint, parent)
            end,
            function(error)
                warn(error)
            end
        )
    else
        new_constraint = constraint
    end

    if attachment0 and not attachment0:IsA("Attachment") then
        warn("param attachment0 is not an Attachment")
    end
    if attachment1 and not attachment1:IsA("Attachment") then
        warn("param attachment1 is not an Attachment")
    end

    new_constraint.Attachment0 = attachment0
    new_constraint.Attachment1 = attachment1

    return c(new_constraint)
end

local function CreateWeldConstraint(parent, part0, part1)
    if part0 and not part0:IsA("BasePart") then
        warn("param part0 is not a BasePart")
    end
    if part1 and not part1:IsA("BasePart") then
        warn("param part1 is not a BasePart")
    end
    local constraint
    xpcall(
        function()
            constraint = Instance.new("WeldConstraint", parent)
        end,
        function(error)
            warn(error)
        end
    )
    constraint.Part0 = part0
    constraint.Part1 = part1

    return constraint
end

-- ---@type fun(parent:Instance,part0:BasePart,part1:BasePart)
-- function c.createWeld(parent, part0, part1)
--     local constraint = CreateWeldConstraint(parent, part0, part1)
--     return c(constraint)
-- end

---@type fun(parent:Instance,part0:BasePart,part1:BasePart)
function c:WeldParts(parent, part0, part1)
    local constraint = CreateWeldConstraint(parent, part0, part1)
    return constraint
end

function c:ctor(constraint)
    c.super.ctor(self, constraint)
    --self:SetMainInst(constraint)
end

function c:dtor()
    c.super.dtor(self)
end

return c
