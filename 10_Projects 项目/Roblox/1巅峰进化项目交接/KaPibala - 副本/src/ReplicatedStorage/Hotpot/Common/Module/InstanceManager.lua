local pairs = pairs
local ipairs = pairs
local script = script
local hotpot = _G.CommonHotpot
---@class InstanceManager
local c = hotpot.class.new(script)
---@type table<BaseObject,table<Instance,boolean>>
local object_inst = {}
---@type table<Instance,BaseObject>
local insts_object = {}
function c:AddInst(obj,inst)
    assert(obj,"param obj is nil")
    assert(inst,"param inst is nil")
    insts_object[inst] = obj
    object_inst[obj] = object_inst[obj] or {}
    object_inst[obj][inst] = true
end
function c:DelInst(inst)
    assert(inst,"param inst is nil")
    local obj = insts_object[inst]
    if obj then
        insts_object[inst] = nil
        object_inst[obj][inst] = nil
        if not object_inst[obj] then
            object_inst[obj] = nil
        end
    end
end
function c:DelObject(obj)
    assert(obj,"param obj is nil")
    local inst_list = object_inst[obj]
    if inst_list then
        for inst,__ in pairs(inst_list) do
            insts_object[inst] = nil
        end
        object_inst[obj] = nil
    end
end
---@type fun(inst:Instance):BaseObject
---@param inst Instance
---@return BaseObject
function c:FindObject(inst)
    assert(inst,"param is nil")
    return insts_object[inst]
end
---@type fun(obj:BaseObject):table<Instance,boolean>
---@param obj BaseObject
---@return table<Instance,boolean>
function c:GetInsts(obj)
    assert(obj,"param obj is nil")
    return object_inst[obj]
end
return c