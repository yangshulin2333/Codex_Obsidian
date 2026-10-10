local _G = _G
local warn = warn
local os = os
local script = script
local table = table
local ipairs = ipairs
local pairs = pairs
local game = game
local assert = assert
---@type Players
local Players = game:GetService("Players")
---@type Player
local local_player = Players.LocalPlayer
local hotpot = _G.ClientHotpot
---@class ClientFunctionManager
local c = hotpot.class.new(script)
local instance_manager = hotpot.load.InstanceManager()
local player_dataex_helper = hotpot.player_dataex_helper
local json_helper = hotpot.load.JsonHelper()
---@type RemoteFunction
local remote_function = hotpot:GetPath_Loop("ReplicatedStorage.RemoteFunction")
-- remote_function.Parent = nil
local handles = {}
local hold_list = {}
local get_active_list = {}
local send_active_list = {}
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
local function GetFunction(player_object,function_name,...)
    local handle = handles[function_name]
    if handle then
        if not get_active_list[function_name] then
            get_active_list[function_name] = true
            local result = handle(player_object,function_name,...)
            get_active_list[function_name] = nil
            result = ConvertToGet(result)
            return table.unpack(result)
        end
    end
end
remote_function.OnClientInvoke = function(function_name,...)
    local player_object = instance_manager:FindObject()
    if player_object then
        return GetFunction(player_object,function_name,...)
    else
        hold_list[function_name] = {...}
    end
end
function c:SetHandle(function_name,handle)
    assert(function_name,"param function name is nil")
    assert(handle,"param handle is nil")
    handles[function_name] = handle
end
function c:Invoke(function_name,...)
    if not send_active_list[function_name] then
        send_active_list[function_name] = os.clock()
        -- local result,args,key = player_dataex_helper:GetKey({...})
        -- if not result then
        --     warn(args)
        --     return
        -- end
        local args = ConvertToSent({...})
        local r,e = xpcall(function()
            local result = {remote_function:InvokeServer(function_name,args)}
            result = ConvertToGet(result)
            send_active_list[function_name] = nil
            return result
        end,debug.traceback)
        if not r then
            warn(e)
        else
            return table.unpack(e)
        end
    else
        -- warn("function "..function_name.." is actived! pls wait")
    end
end
function c:DelayGet(player_object)
    for function_name,args in ipairs(hold_list) do
        return GetFunction(player_object,function_name,table.unpack(args))
    end
end
return c