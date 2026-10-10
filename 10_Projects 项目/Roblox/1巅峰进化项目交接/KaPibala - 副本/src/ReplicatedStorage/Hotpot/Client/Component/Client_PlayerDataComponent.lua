local _G = _G
local script = script
local assert = assert
local hotpot = _G.ClientHotpot
---@class Client_PlayerDataComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c:ctor(parent)
    c.super.ctor(self,parent)
end
function c:dtor()
    c.super.dtor(self)
end
function c.new(parent)
    return c(parent)
end
function c:SetData(save_data)
    self.__save_data = save_data
end
function c:SetActivityData(data_name,save_data)
    self.__save_data[data_name] = save_data
end
function c:GetData(data_name)
    assert(data_name,"param data name is nil")
    local data = self.__save_data[data_name]
    assert(data,"no save data named .."..data_name)
    return self.__save_data[data_name]
end
return c