local _G = _G
local script = script
local assert = assert
local hotpot = _G.CommonHotpot
--添加服务引用
local collider_group = hotpot.load.ColliderGroup()
local collider_manager = hotpot.load.ColliderManager()
---@class AreaManager
local c = hotpot.class.new(script)
---@type table<Part,BaseObject>
local area_list = {}
---@type table<Part,function>
local in_area_func_list = {}
---@type table<Part,function>
local out_area_func_list = {}
---@type fun(part:Part,object:BaseObject) @注册区域，注册的类可以实现InArea和OutArea来出发进入区域和退出区域的逻辑
---@param part Part
---@param object BaseObject
---@param collider_group string
---@param in_area_func function
---@param out_area_func function
function c:AddArea(part,object,collider_group,in_area_func,out_area_func)
    assert(part,"param part is nil")
    assert(object,"param object is nil")
    assert(collider_group,"param collider group is nil")
    if collider_group then
        collider_manager:SetPartGroup(part,collider_group)
    end
    part.CanTouch = true
    area_list[part] = object
    in_area_func_list[part] = in_area_func
    out_area_func_list[part] = out_area_func
end
---@type fun(part:Part) @注销区域
---@param part Part
function c:DelArea(part)
    area_list[part] = nil
end
---@type fun(object:BaseObject,part:Part,...) @当触发进入已经注册的part区域时调用
---@param object BaseObject
---@param part Part
function c:InArea(object,part,...)
    local area_obj = area_list[part]
    if not area_obj then
        return
    end
    local in_area_func = in_area_func_list[part] or area_obj.InArea
    if not in_area_func then
        return
    end
    local su,res = xpcall(in_area_func,debug.traceback,area_obj,object,...)
    if not su and res then
        warn(res)
    end
end
---@type fun(object:BaseObject,part:Part,...) @当触发退出已经注册的part区域调用
---@param object BaseObject
---@param part Part
function c:OutArea(object,part,...)
    local area_obj = area_list[part]
    if not area_obj then
        return
    end
    local out_area_func = out_area_func_list[part] or area_obj.OutArea
    if not out_area_func then
        return
    end
    local su,res = xpcall(out_area_func,debug.traceback,area_obj,object,...)
    if not su and res then
        warn(res)
    end
end
return c