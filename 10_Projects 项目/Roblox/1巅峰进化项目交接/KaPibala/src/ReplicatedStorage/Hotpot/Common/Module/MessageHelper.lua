local _G = _G
local next = next
local ipairs = ipairs
local pairs = pairs
local table = table
local assert = assert
local script = script
--添加引用
local hotpot = _G.CommonHotpot
local callback_manager = hotpot.load.CallBackManager()
local hotpot_connection = hotpot.load.HotpotConnection()
---@class MessageHelper
local c = hotpot.class.new(script)
--初始化本地变量
local watch_list = {}
local watch_array = {}
local id_priority_map = {}
local id_key_map = {}
local id_obj_map = {}
local id_counter = 0
--申明本地函数
local IsWatch
local DisWatch
--定义本地函数
---@param self MessageHelper
---@param id number
function IsWatch(self,id)
    return id_priority_map[id] ~= nil
end
---@param self MessageHelper
---@param id number
function DisWatch(self,id)
    local obj = id_obj_map[id]
    if not obj then
        return
    end
    local priority = id_priority_map[id]
    local key = id_key_map[id]
    id_priority_map[id] = nil
    id_obj_map[id] = nil
    id_key_map[id] = nil

    watch_list[key][obj][priority][id_counter] = nil
    if not next(watch_list[key][obj][priority]) then
        watch_list[key][obj][priority] = nil
        for idx,p in ipairs(watch_array[key][obj]) do
            if p == priority then
                table.remove(watch_array[key][obj],idx)
                if not watch_array[key][obj][1] then
                    watch_array[key][obj] = nil
                    if not next(watch_array[key]) then
                        watch_array[key] = nil
                    end
                end
                break
            end
        end
        if not next(watch_list[key][obj]) then
            watch_list[key][obj] = nil
            if not next(watch_list[key]) then
                watch_list[key] = nil
            end
        end
    end
    --self:Print()
end
---@param obj BaseObject
---@param key string
---@param handle function
---@param priority number
---@return HotpotConnection
function c:Watch(obj,key,handle,priority)
    assert(obj,"param object is nil")
    assert(key,"param key is nil")
    assert(handle,"param handle is nil")
    priority = priority or 0
    id_counter = id_counter + 1
    --进行标记
    id_priority_map[id_counter] = priority
    id_key_map[id_counter] = key
    id_obj_map[id_counter] = obj

    watch_list[key] = watch_list[key] or {}
    watch_list[key][obj] = watch_list[key][obj] or {}
    watch_list[key][obj][priority] = watch_list[key][obj][priority] or {}
    watch_list[key][obj][priority][id_counter] = handle

    watch_array[key] = watch_array[key] or {}
    watch_array[key][obj] = watch_array[key][obj] or {}
    local idx = 0
    local array = watch_array[key][obj]
    while true do
        idx = idx + 1
        local now_priority = array[idx]
        if not now_priority or now_priority <= priority then
            if now_priority ~= priority then
                table.insert(array,idx,priority)
            end
            break
        end
    end
    --self:Print()
    -- return callback_manager:CreateHotpotConnect(obj,DisWatch,IsWatch,id_counter)
    local cnnt = hotpot_connection.new(self,DisWatch,IsWatch,id_counter)
    callback_manager:AddConnectToObject(cnnt,obj)
    return cnnt
end
function c:Sent(key,...)
    local list = watch_list[key]
    if not list then
        return
    end
    local array = watch_array[key]
    for obj,a in pairs(array) do
        for idx,priority in ipairs(a) do
            local l = list[obj][priority]
            for id,handle in pairs(l) do
                local co = coroutine.create(handle)
                local r,e = coroutine.resume(co,obj,...)
                if not r then
                    warn(e)
                end
            end
        end
    end
end
function c:Print()
    print("message helper print")
    print("watch_list",watch_list)
    print("watch_array",watch_array)
    print("id_priority_map",id_priority_map)
    print("id_key_map",id_key_map)
    print("id_obj_map",id_obj_map)
end
return c