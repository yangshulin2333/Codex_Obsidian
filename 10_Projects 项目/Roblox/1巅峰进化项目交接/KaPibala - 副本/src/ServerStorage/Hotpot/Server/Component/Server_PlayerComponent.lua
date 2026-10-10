local _G = _G
local warn = warn
local script = script 
local hotpot = _G.ServerHotpot
local event_manager = hotpot.event_manager
local function_manager = hotpot.function_manager
---@class Server_PlayerComponent:BaseComponent
---@field parent Server_Player
local c = hotpot.class.new(script,hotpot.files.BaseComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)
end
function c:dtor()
    c.super.dtor(self)
end
function c:RegistEvent(event_name,handle)
    event_manager:RegistHandle(event_name,function(player_object,...)
        local component = player_object:GetComponent(self)
        if component then
            component:AddProcess(handle,...)
        else
            warn(player_object.main_inst.Name.."don't have component named "..self.class)
        end
    end)
end
function c:Fire(event_name,...)
    local player = self.parent
    if player and player.main_inst then
        event_manager:Fire(player,event_name,...)
    end
end
function c:FireEventToAll(event_name,...)
    event_manager:FireAll(event_name,...)
end
function c:RegistFunction(function_name,handle)
    function_manager:SetHandle(function_name,function(player_object,...)
        local component = player_object:GetComponent(self)
        if component then
            return handle(component,...)
        else
            warn(player_object.main_inst.Name.."don't have component named "..self.class)
        end
    end)
end
function c:Invoke(function_name,...)
    local player = self.parent
    if player then
        return function_manager:Invoke(player,function_name,...)
    end
end
return c