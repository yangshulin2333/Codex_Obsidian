local _G = _G
local script = script
local hotpot = _G.ClientHotpot
local Enum = Enum
local table = table
---@type ContextActionService
local ContextActionService = game:GetService("ContextActionService")
---@class UserActionComponent:BaseComponent
local c = hotpot.class.new(script,hotpot.files.BaseComponent())
local input_state_map = {}
input_state_map[Enum.UserInputState.Begin] = "start"
input_state_map[Enum.UserInputState.End] = "over"
local function ProcessHandle(cpnt,handle,obj,args)
    handle(obj,table.unpack(args))
end
local function UpdateHandle(cpnt,step,run_time,handle,obj,args)
    handle(obj,step,run_time,table.unpack(args))
end
local input_state_handle = {}
---@param cpnt UserActionComponent
---@param param ActionParam
input_state_handle.start = function(cpnt,param)
    if param.start then
        cpnt:AddProcess(ProcessHandle,param.start,param.object,param.args)
    end
    if param.hold then
        local old_cnnt = cpnt.__update_cnnts[param.name]
        if old_cnnt then
            old_cnnt:Disconnect()
        end
        cpnt.__update_cnnts[param.name] = cpnt:AddUpdate(UpdateHandle,nil,param.hold,param.object,param.args)
    end
end
---@param cpnt UserActionComponent
---@param param ActionParam
input_state_handle.over = function(cpnt,param)
    if param.over then
        cpnt:AddProcess(ProcessHandle,param.over,param.object,param.args)
    end
    ---@type HotpotConnection
    local cnnt = cpnt.__update_cnnts[param.name]
    if cnnt then
        cnnt:Disconnect()
        cpnt.__update_cnnts[param.name] = nil
    end
end
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)
    self.__update_cnnts = {}
    self.__params = {}
    self.__public_handle = function(name,input_type,input_object)
        --print(name,input_type,input_object)
        local param = self.__params[name]
        if param then
            local action_type = input_state_map[input_type]
            local handle = input_state_handle[action_type]
            if handle then
                handle(self,param)
            end
        end
    end
end
function c:dtor()
    c.super.dtor(self)
end
function c:BindAction(name,input_enum,start_handle,hold_handle,over_handle,create_btn,object,...)
    if self.__params[name] then
        self:UnBindAction(name)
    end
    self.__params[name] = {
        name = name,
        start = start_handle,
        hold = hold_handle,
        over = over_handle,
        object = object,
        args = {...}
    }
    ContextActionService:BindActionAtPriority(name,self.__public_handle,create_btn,100,input_enum)
end
function c:UnBindAction(name)
    ContextActionService:UnbindAction(name)
    local param = self.__params[name]
    ---@type HotpotConnection
    local update_cnnt = self.__update_cnnts[name]
    if update_cnnt and not update_cnnt:IsConnected() then
        update_cnnt:Disconnect()
        self.__update_cnnts[name] = nil
    end
end
return c