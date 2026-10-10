local script = script
local _G = _G
local coroutine = coroutine
local wait = wait
local assert = assert
local print = print
local error = error
local table = table
local hotpot = _G.CommonHotpot
local InstanceManager = hotpot.load.InstanceManager()
---@class ObjectManager
local c = hotpot.class.new(script)
local all_object = {}
local class_list = {}
---@param obj BaseObject
function c:AddObject(obj)
    assert(obj,"param obj is nil")
    assert(obj.class,"param obj is not a base object")
    if not all_object[obj] then
        all_object[obj] = true
        local class = obj.class
        class_list[class] = class_list[class] or {}
        class_list[class][obj] = true
    end
end
function c:DelObject(obj)
    assert(obj,"param obj is nil")
    assert(obj.class,"param obj is not a base object")
    all_object[obj] = nil
    local class = obj.class
    if class_list[class] then
        class_list[class][obj] = nil
    end
end
function c:IsObjectExsit(obj)
    assert(obj,"param obj is nil")
    return all_object[obj]
end
function c:GetListWithClass(class)
    assert(class,"param class is nil")
    return class_list[class] or {}
end
return c