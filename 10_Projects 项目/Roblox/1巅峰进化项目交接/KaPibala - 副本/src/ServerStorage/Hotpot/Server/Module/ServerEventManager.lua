local _G = _G
local script = script
local table = table
local ipairs = ipairs
local pairs = pairs
local game = game
local hotpot = _G.ServerHotpot
local instance_manager = hotpot.load.InstanceManager()
local encryption_manager = hotpot.encryption_manager
local json_helper = hotpot.load.JsonHelper()
---@class ServerEventManager
local c = hotpot.class.new(script)
---@type RemoteEvent
local remote_event = hotpot:GetPath_Loop("ReplicatedStorage.RemoteEvent",game)
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
---@param player Player
remote_event.OnServerEvent:Connect(function(player,event_name,args)
    -- assert(args,"param args is nil,event name = "..event_name)
    -- if not key then
    --     local str = "error event from player "..player.UserId.."lost key"
    --     encryption_manager:KickPlayerDelay(player,str)
    --     return
    -- end
    -- local result,new_args = encryption_manager:Decode(player,key,args)
    -- if not result then
    --     encryption_manager:KickPlayerDelay(player,event_name,new_args)
    --     return
    -- end
    local new_args = ConvertToGet(args)
    ---@type Server_Player
    local player_object = instance_manager:FindObject(player)
    --玩家实例进入以后，先检查是否存在对象，如果没有那么就放到等待列表
    if not player_object then
        hold_list[player] = hold_list[player] or {}
        table.insert(hold_list[player],{
            event = event_name,
            args = new_args
        })
    else
        GetEvent(player_object,event_name,table.unpack(new_args))
    end
end)
function c:RegistHandle(event,handle)
    handles[event] = handles[event] or {}
    handles[event][handle] = true
end
function c:CancelHandle(event,handle)
    if handles[event] then
        handles[event][handle] = nil
    end
end
---@param player_object Server_Player
function c:Fire(player_object,event,...)
    local arg = {}
    for k,v in ipairs({...}) do
        arg[k] = ConvertToSent(v)
    end
    remote_event:FireClient(player_object.main_inst,event,table.unpack(arg))
end
function c:FireAll(event,...)
    local arg = {}
    for k,v in ipairs({...}) do
        arg[k] = ConvertToSent(v)
    end
    remote_event:FireAllClients(event,table.unpack(arg))
end
function c:DelayGet(player_object)
    local delay_list = hold_list[player_object.main_inst]
    if delay_list then
        for idx,info in ipairs(delay_list) do
            local event = info.event
            local args = info.args
            GetEvent(player_object,event,table.unpack(args))
        end
        hold_list[player_object.main_inst] = nil
    end
end
return c