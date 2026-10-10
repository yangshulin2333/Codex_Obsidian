local game = game
local pairs = pairs
local ipairs = ipairs
local script = script
local table = table
local _G = _G
local hotpot = _G.ClientHotpot
---@type Players
local Players = game:GetService("Players")
---@type Player
local local_player = Players.LocalPlayer
---@class ClientEventTriggerManager
local c = hotpot.class.new(script)
local instance_manager = hotpot.load.InstanceManager()
local player_dataex_helper = hotpot.player_dataex_helper
local json_helper = hotpot.load.JsonHelper() 
---@type BindableEvent
local event_trigger = Instance.new("BindableEvent")
local handles = {}
local hold_list = {}
local function ConvertToSent(val)
    if type(val) == "table" then
        local new_tab = {}
        for key,value in pairs(val) do
            if type(key) == "number" then
                key = tostring(key)
            end
            new_tab[key] = ConvertToSent(value)
        end
        return new_tab
    else
        return val
    end
end
local function ConvertToGet(val)
    if type(val) == "table" then
        local new_tab = {}
        for key,value in pairs(val) do
            key = tonumber(key) or key
            new_tab[key] = ConvertToGet(value)
        end
        return new_tab
    else
        return val
    end
end
local function GetEvent(player_object,event,...)
    if handles[event] then
        local arg = {}
        for k,v in ipairs({...}) do
            arg[k] = ConvertToGet(v)
        end
        for handle,__ in pairs(handles[event]) do
            handle(player_object,table.unpack(arg))
        end
    end
end
event_trigger.Event:Connect(function(event,...)
    local player_object = instance_manager:FindObject(local_player)
    if player_object then
        GetEvent(player_object,event,...)
    else
        hotpot[event] = hotpot[event] or {}
        table.insert(hotpot[event],{...})
    end
end)
function c:RegistHandle(event,handle)
    handles[event] = handles[event] or {}
    handles[event][handle] = true
end
function c:CancelHandle(event,handle)
    if handles[event] then
        handles[event] = nil
    end
end
function c:Fire(event,...)
    -- local r,args,key = player_dataex_helper:GetKey({...})
    -- if not r then
    --     error("error on get key event name = "..event.."\n"..args)
    --     return
    -- end
    -- if not args then
    --     local co = coroutine.create(function()
    --         error("get key error,args is nil,"..tostring(event).."\n"..debug.traceback(coroutine.running()))
    --     end)
    --     coroutine.resume(co)
    -- end
    local args = ConvertToSent({...})
    event_trigger:Fire(event,args)
end
function c:DelayGet(player_object)
    for idx,args in ipairs(hold_list) do
        GetEvent(player_object,table.unpack(args))
    end
end
return c