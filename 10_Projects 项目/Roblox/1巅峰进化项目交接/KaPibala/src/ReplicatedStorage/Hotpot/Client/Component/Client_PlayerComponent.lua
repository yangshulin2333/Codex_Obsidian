local _G = _G
local warn = warn
local script = script
local hotpot = _G.ClientHotpot
local event_manager = hotpot.event_manager
local function_manager = hotpot.function_manager
---@class Client_PlayerComponent:BaseComponent
---@field parent Client_Player
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
            --component:AddProcess(handle,...)
            local r,e = xpcall(handle,debug.traceback,component,...)
            if not r then
                warn(e)
            end
        else
            warn(player_object.main_inst.Name.."don't have component named "..self.class)
        end
    end)
end
function c:Fire(event_name,...)
    event_manager:Fire(event_name,...)
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
    return function_manager:Invoke(function_name,...)
end
return c