local _G = _G
local script = script
local pairs = pairs
local ipairs = ipairs
local table = table
local xpcall = xpcall
local debug = debug
local warn = warn
local hotpot = _G.ClientHotpot
local event_list = hotpot.event_list
event_list.sync_client_to_server = true

---@class Client_SyncComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
--申明本地函数
local Receive
local Push
local count = 0
local function DoHandle(handle,object,info)
    local r,e = xpcall(handle,debug.traceback,object,info)
    if not r then
        warn(e)
    end
end
--定义本地函数
---@param self Client_SyncComponent
local function UpdateReceive(self)
    local get_data = self.__get_data
    local handles = self.__sync_handle
    while next(get_data) do
        local data
        if self.__order_break then
            local now_count = self.__get_count + 1
            data = get_data[now_count]
            if not data then
                warn("receive data break in count = ",now_count)
                break
                -- self:Wait()
                -- data = get_data[now_count]
            end
            self.__get_count = self.__get_count + 1
            get_data[now_count] = nil
        else
            local key
            key,data = next(get_data)
            get_data[key] = nil
        end
        local name,info = table.unpack(data)
        local handle_info = handles[name]
        if handle_info then
            local obj = handle_info.object
            local handle = handle_info.handle
            -- local r,e = xpcall(handle,debug.traceback,obj,info)
            -- if not r then
            --     warn(e)
            -- end
            local co = coroutine.create(DoHandle)
            coroutine.resume(co,handle,obj,info,self.parent)
        end
            
    end
    self.__do_receive_cnnt = nil
end
---@param self Client_SyncComponent
local function Receive(self,datas)
    for idx,data in pairs(datas) do
        self.__get_data[idx] = data
    end
    if self.__do_receive_cnnt then
        return
    end
    self.__do_receive_cnnt = self:AddProcess(UpdateReceive)
end
---@type fun() @推送同步信息
---@param self Client_SyncComponent
function Push(self)
    if self.__step then
        self:Wait(self.__step)
    end
    self:Fire(event_list.sync_client_to_server,self.__sent_data)
    self.__sent_data = {}
    self.__pushing = nil
end
-----------------------------
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)
    self.__get_data = {}
    self.__sent_data = {}
    self.__get_count = 0
    self.__sent_count = 0
    self.__sync_handle = {}
    self.__order_break = true
end
function c:dtor()
    c.super.dtor(self)
end
function c:AddHandle(name,object,handle)
    self.__sync_handle[name] = {object = object,handle = handle}
end
function c:DelHandle(name)
    self.__sync_handle[name] = nil
end
function c:SetReceiveOrderBreakEnabled(enable)
    self.__order_break = enable
end
function c:SetPushStep(step)
    self.__step = step
end
function c:Add(name,info)
    self.__sent_count = self.__sent_count + 1
    local now_count = self.__sent_count
    self.__sent_data[now_count] = {name,info}
    if self.__pushing then
        return
    end
    self.__pushing = self:AddProcess(Push)
end
c:RegistEvent(event_list.sync_server_to_client,Receive)
return c