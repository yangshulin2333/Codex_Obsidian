local _G = _G
local game = game
local script = script
local assert = assert
local table = table
local ipairs = ipairs
local function DefaultFilter()
    return true
end
---@type PhysicsService
local PhysicsService = game:GetService('PhysicsService')
local hotpot = _G.CommonHotpot
---@type CollideGroups
local CollideGroup = hotpot.load.ColliderGroup()
---@class ColliderManager
local c = hotpot.class.new(script)
---@param part Part
---@param name string
function c:SetPartGroup(part,name)
    name = name or CollideGroup.Default
    --PhysicsService:SetPartCollisionGroup(part,name)
    part.CollisionGroup = name
end
---@param inst Instance
---@param name string
---@param filter function
function c:SetAllGroup(inst,name,filter)
    assert(inst,"param inst is nil!")
    name = name or CollideGroup.Default
    filter = filter or DefaultFilter
    local insts = inst:GetDescendants()
    table.insert(insts,inst)
    for __,cinst in ipairs(insts) do
        if cinst:IsA("BasePart") and filter(cinst) then
            self:SetPartGroup(cinst,name)
        end
    end
end
---@param game_obj GameObject
function c:SetObjectGroup(game_obj,name,filter)
    if game_obj.main_inst then
        self:SetAllGroup(game_obj.main_inst,name,filter)
    end
end
---@param part Part
---@return string
function c:GetPartGroup(part)
    assert(part:IsA("BasePart"))
    return CollideGroup:GetNameWithId(part.CollisionGroupId)
end
---@param group1 stirng
---@param group2 string
---@param collidable boolean
function c:SetGroupCollidable(group1,group2,collidable)
    PhysicsService:CollisionGroupSetCollidable(group1,group2,collidable)
end
---@param group1 stirng
---@param group2 string
---@return boolean
function c:GetGroupCollidable(group1,group2)
    return PhysicsService:CollisionGroupsAreCollidable(group1,group2)
end
-- function c:GetGroupIdWithName(name)
--     return PhysicsService:GetCollisionGroupId(name)
-- end
-- function c:GetGroupNameWithId(id)
--     return PhysicsService:GetCollisionGroupName(id)
-- end
function c:GetGroupNum()
    return PhysicsService:GetMaxCollisionGroups()
end
return c