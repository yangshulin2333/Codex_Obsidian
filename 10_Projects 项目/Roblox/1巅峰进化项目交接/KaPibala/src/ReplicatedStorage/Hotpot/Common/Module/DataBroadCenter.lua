-------作为一个以string为关键字的消息转发中心
-- Fire:触发信号
-- AddListener:注册监听
-- RemoveListener:取消监听
local hotpot = _G.CommonHotpot
---@type table<string,table> @保护类型的,存放特殊关键字和对应的注册方法
local KeyList = {}
---@class DataBroadCenter
local c = {}
---@type fun() @发出信号,告诉监听者们
---@param key_type string @关键字
function c:Fire(key_type,...)
    local nowKeyTable = KeyList[key_type]
    if not nowKeyTable then
        nowKeyTable = {handles = {}}
        KeyList[key_type] = nowKeyTable
    end
    local handleTable = nowKeyTable.handles
    --将参数保留,以便后注册的使用
    local arg = {...}
    nowKeyTable.arg = arg
    local del_list
    -- -@param obj @BaseObject
    for obj,handle in pairs(handleTable) do
        if not obj.IsExit or obj:IsExit() then
            local co = coroutine.create(function()
                handle(obj,table.unpack(arg))
            end)
            coroutine.resume(co)
        else
            del_list = del_list or {}
            del_list[obj] = true
        end
    end
    if del_list then
        for obj,__ in pairs(handleTable) do
            nowKeyTable[obj] = nil
        end
    end
end
---@type fun() @注册关键字
---@param key_type string @关键字
---@param handle fun() @方法
function c:AddListener(key_type,obj,handle)
    KeyList[key_type] = KeyList[key_type] or {handles = {}}
    KeyList[key_type].handles[obj] = handle
    local arg = KeyList[key_type].arg
    if arg then
        local co = coroutine.create(function()
            handle(obj,table.unpack(arg))
        end)
        coroutine.resume(co)
    end
end
---@type fun() @注销监听
function c:RemoveListener(key_type,obj)
    local nowKeyTable = KeyList[key_type]
    if not nowKeyTable then
        return
    end
    nowKeyTable.handles[obj] = nil
end
return c