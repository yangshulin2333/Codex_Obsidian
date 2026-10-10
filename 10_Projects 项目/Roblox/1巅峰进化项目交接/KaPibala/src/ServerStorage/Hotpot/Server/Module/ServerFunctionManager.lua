local _G = _G
local next = next
local pairs = pairs
local ipairs = ipairs
local table = table
local script = script
local coroutine = coroutine
local wait = wait
local os = os
local hotpot = _G.ServerHotpot
---@class ServerFunctionManager
local c = hotpot.class.new(script)
local instance_manager = hotpot.load.InstanceManager()
local encryption_manager = hotpot.encryption_manager
local json_helper = hotpot.load.JsonHelper()
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
---@type RemoteFunction
local remote_function = hotpot:GetPath_Loop("ReplicatedStorage.RemoteFunction")
local function GetFunction(player_object,function_name,...)
    local handle = handles[function_name]
    if handle then
        if not get_active_list[player_object] or not get_active_list[player_object][function_name] then
            get_active_list[player_object] = get_active_list[player_object] or {}
            get_active_list[player_object][function_name] = os.clock()
            local result = {handle(player_object,...)}
            get_active_list[player_object][function_name] = nil
            if not next(get_active_list[player_object]) then
                get_active_list[player_object] = nil
            end
            for k,v in ipairs(result) do
                result[k] = ConvertToSent(v)
            end
            return table.unpack(result)
        else
            return false,"function is active"
        end
    end
end
remote_function.OnServerInvoke = function(player_inst,function_name,args)
    -- if not key then
    --     local str = "error function from player "..player_inst.UserId..",lost key"
    --     encryption_manager:KickPlayerDelay(player_inst,str)
    --     return
    -- end
    -- local result,new_args = encryption_manager:Decode(player_inst,key,args)
    -- if not result then
    --     encryption_manager:KickPlayerDelay(player_inst,function_name,new_args)
    --     return
    -- end
    local new_args = ConvertToGet(args)

    local player_obejct = instance_manager:FindObject(player_inst)

    if player_obejct then
        if not new_args then
            local error_str = "arg is nil name = "..function_name
            error_str = error_str.."\n"..debug.traceback()
            error_str = error_str.."\n error args = "
            if not args then
                error_str = error_str.."nil"
            else
                if type(args) ~= "table" then
                    error_str = error_str..tostring(args)
                else
                    error_str = error_str..hotpot:Dump(args)
                end
            end
            error(error_str)
        end
        return GetFunction(player_obejct,function_name,table.unpack(new_args))
    else
        hold_list[player_inst] = hold_list[player_inst] or {}
        table.insert(hold_list[player_inst],{
            name = function_name,
            args = new_args,
            co = coroutine.running()
        })
        local r = {coroutine.yield()}
        wait()
        return table.unpack(r)
    end
end
function c:SetHandle(function_name,handle)
    handles[function_name] = handle
end
function c:Invoke(player_object,function_name,...)
    if not send_active_list[player_object] or not send_active_list[player_object][function_name] then
        get_active_list[player_object] = get_active_list[player_object] or {}
        send_active_list[player_object][function_name] = os.time()
        local arg = {}
        for k,v in ipairs({...}) do
            arg[k] = ConvertToSent(v)
        end
        local result remote_function:InvokeClient(player_object.main_inst,function_name,table.unpack(arg))
        send_active_list[player_object][function_name] = nil
        if not next(send_active_list[player_object]) then
            send_active_list[player_object] = nil
        end
        result = ConvertToGet(result)
        return table.unpack(result)
    end
end
function c:DelayGet(player_object)
    local list = hold_list[player_object.main_inst]
    if list then
        for idx,info in ipairs(list) do
            local name = info.name
            local args = info.args
            local co = info.co
            coroutine.resume(co,GetFunction(player_object,name,table.unpack(args)))
        end
    end
end
return c