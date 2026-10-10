local script = script
local assert = assert
local table = table
local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local coroutine = coroutine
local wait = wait
local error = error
local next = next
local _G = _G
local game = game
local xpcall = xpcall
local warn = warn
local debug = debug
local os = os

---@type RunService
local RunService = game:GetService("RunService")
---@type TweenService
local TweenService = game:GetService("TweenService")
local is_client = RunService:IsClient()
local hotpot = _G.CommonHotpot
local object_manager = hotpot.load.ObjectManager()
local callback_manager = hotpot.load.CallBackManager()
local instance_manager = hotpot.load.InstanceManager()
local hotpot_connection = hotpot.load.HotpotConnection()
local hotpot_enum = hotpot.enum
local message_helper = hotpot.load.MessageHelper()
hotpot_enum.UpdateType = {}
hotpot_enum.UpdateType.logic = true
hotpot_enum.UpdateType.step = true
hotpot_enum.UpdateType.heart_beat = true
hotpot_enum.UpdateType.first = true
hotpot_enum.UpdateType.input = true
hotpot_enum.UpdateType.camera = true
hotpot_enum.UpdateType.character = true
hotpot_enum.UpdateType.last = true
hotpot_enum.UpdateType.render = true
---@class BaseObject
---@field super BaseObject @父类
---@field class string @类名称
---@field ctor function
---@field dtor function
local c = hotpot.class.new(script)
function c:ctor()
    ---@type table<HotpotConnection,boolean>
    object_manager:AddObject(self)
end
function c:dtor()
    object_manager:DelObject(self)
    callback_manager:DelObject(self)
    instance_manager:DelObject(self)
end
local function IsA(mdl,class_name)
    if mdl.class == class_name then
        return true
    else
        if mdl.super then
            return IsA(mdl.super,class_name)
        else
            return false
        end
    end
end
---@param class_name string
---@return boolean
function c:IsA(class_name)
    return IsA(self,class_name)
end
---@type fun(func:function,...):HotpotConnection
---@param func function
---@return HotpotConnection
function c:AddProcess(func,...)
    return callback_manager:AddProcess("logic",self,func,...)
end
---@type fun(func:function,step:number,...):HotpotConnection
---@param func function
---@param step number
---@return HotpotConnection
function c:AddUpdate(func,step,...)
    return callback_manager:AddUpdate("logic",self,func,step,...)
end
---@type fun(func:function,...):HotpotConnection
---@param func function
---@return HotpotConnection
function c:AddStepProcess(func,...)
    return callback_manager:AddProcess("step",self,func,...)
end
---@type fun(func:function,step:number,...):HotpotConnection
---@param func function
---@param step number
---@return HotpotConnection
function c:AddStepUpdate(func,step,...)
    return callback_manager:AddUpdate("step",self,func,step,...)
end
---@type fun(func:function,...):HotpotConnection
---@param func function
---@return HotpotConnection
function c:AddHeartBeatProcess(func,...)
    return callback_manager:AddProcess("heart_beat",self,func,...)
end
---@type fun(func:function,step:number,...):HotpotConnection
---@param func function
---@param step number
---@return HotpotConnection
function c:AddHeartBeatUpdate(func,step,...)
    return callback_manager:AddUpdate("heart_beat",self,func,step,...)
end
if is_client then
    ---@type fun(enum_update_type:string,func:function,...):HotpotConnection
    ---@param enum_update_type string | "'render'" | "'first'" | "'input'" | "'camera'" | "'character'" | "'last'" 
    ---@param func function
    ---@return HotpotConnection
    function c:AddRenderProcess(enum_update_type,func,...)
        return callback_manager:AddProcess(enum_update_type,self,func,...)
    end
    ---@type fun(enum_update_type:string,func:function,step:number,...):HotpotConnection
    ---@param enum_update_type string | "'render'" | "'first'" | "'input'" | "'camera'" | "'character'" | "'last'" 
    ---@param func function
    ---@param step number
    ---@return HotpotConnection
    function c:AddRenderUpdate(enum_update_type,func,step,...)
        return callback_manager:AddUpdate(enum_update_type,self,func,step,...)
    end
    local function TweenFunc(obj, step, run_time, func, EasingStyle, EasingDirection, time, ...)
        local alpha
        local per = math.min(run_time / time, 1)
        alpha = TweenService:GetValue(per, EasingStyle, EasingDirection)

        func(obj, alpha, step, run_time)
        if run_time > time then
            return true
        end
    end
    ---@type fun(enum_update_type:string,func:function,step:number,...):HotpotConnection
    ---@param enum_update_type string | "'render'" | "'first'" | "'input'" | "'camera'" | "'character'" | "'last'" 
    ---@param func function
    ---@param EasingStyle string 
    ---@param EasingDirection string 
    ---@param time number
    ---@return HotpotConnection
    function c:AddRenderTween(enum_update_type, func, EasingStyle, EasingDirection, time)
        return
            callback_manager:AddUpdate(enum_update_type, self, TweenFunc, 0, func, EasingStyle, EasingDirection, time)
    end
end
---@type fun(func:function,...):any
---@param func function
---@return any
function c:WaitForFunc(func,...)
    local result = {func(...)}
    -- self:CoCheck()
    if not self:IsExist() then
        coroutine.yield()
    end
    return table.unpack(result)
end
---@type fun(wait_time:number):number,number
---@param wait_time number
---@return number,number
function c:Wait(wait_time)
    return callback_manager:Wait(self,wait_time)
end
---@type fun(path:string):Instance
---@param path string
---@return Instance
function c:WaitForChild(path)
    assert(path,"param path is nil")
    assert(self.main_inst,self.class.." don't have main inst")
    -- return self:WaitForFunc(hotpot.GetPath,hotpot,path,self.main_inst)
    return hotpot:GetPath(path,self.main_inst)
end
---@type fun(path:string):Instance
---@param path string
---@return Instance
function c:WaitForChild_Check(path)
    assert(path,"param path is nil")
    assert(self.main_inst,self.class.." don't have main inst")
    -- return self:WaitForFunc(hotpot.GetPath_Check,hotpot,path,self.main_inst)
    return hotpot:GetPath_Check(path,self.main_inst)
end
---@type fun(path:string):Instance
---@param path string
---@return Instance
function c:WaitForChild_Loop(path)
    assert(path,"param path is nil")
    assert(self.main_inst,self.class.." don't have main inst")
    -- return self:WaitForFunc(hotpot.GetPath_Loop,hotpot,path,self.main_inst)
    return hotpot:GetPath_Loop(path,self.main_inst)
end
local attributes_meta = {}
function attributes_meta:__index(key)
    return self.__inst:GetAttribute(key)
end
function attributes_meta:__newindex(key,val)
    self.__inst:SetAttribute(key,val)
end
function c:SetMainInst(inst)
    assert(inst,"Instance can't be nil")
    if self.main_inst then
        instance_manager:DelInst(self.main_inst)
    end
    self.main_inst = inst
    instance_manager:AddInst(self,inst)
    --添加属性io
    self.attribute = setmetatable({__inst = inst,__rbx = {}},attributes_meta)
    --为对象添加类标记属性
    if is_client then
        self.attribute.client_class = self.class
    else
        self.attribute.server_class = self.class
    end
end
function c:DelMainInst()
    if self.main_inst then
        instance_manager:DelInst(self.main_inst)
    end
    if self.attribute then
        for rbx,__ in pairs(self.attribute.__rbx) do
            rbx:Disconnect()
        end
    end
    self.main_inst = nil
    self.attribute = nil
end
---@type fun(key:string,handle:function,...):HotpotConnection
---@param key string
---@param handle function
---@return HotpotConnection
function c:AttributeValueChanged(key,handle,...)
    assert(key,"param key is nil")
    assert(handle,"param handle is nil")
    local args = {...}
    local cnt = callback_manager:AddRbxConnect(self,self.attribute.__inst:GetAttributeChangedSignal(key),function()
        handle(self,table.unpack(args))
    end)
    return cnt
end
function c:AttributeChanged(handle,...)
    assert(handle,"param handle is nil")
    local args = {...}
    local cnt = callback_manager:AddRbxConnect(self,self.attribute.__inst.AttributeChanged,function(att_name)
        handle(self,att_name,table.unpack(args))
    end)
    return cnt
end
function c:IsExist()
    return object_manager:IsObjectExsit(self)
end
function c:ExistCheck()
    if not self:IsExist() then
        coroutine.yield()
    end
end
function c:AddCo(co)
    return callback_manager:AddCo(self,"logic",co)
end
---@type fun(update_type:string):HotpotConnection
---@param updater_type string | "'logic'" | "'step'" | "'heart_beat'" | "'render'" | "'first'" | "'input'" | "'camera'" | "'character'" | "'last'"
---@param co thread
---@return HotpotConnection
function c:AddCoTo(updater_type,co)
    return callback_manager:AddCo(self,updater_type,co)
end
function c:CoCheck(co)
    callback_manager:CoCheck(self,co)
end
---@return HotpotConnection
function c:AddRbxCallBack(sign,handle,...)
    return callback_manager:AddRbxConnect(self,sign,handle,...)
end
---@param self BaseObject
local function DoExecuteQueue(self)
    local __execute_queue = self.__execute_queue
    while __execute_queue[1] do
        if not self:IsExist() then
            return
        end
        local info = __execute_queue[1]
        table.remove(__execute_queue,1)
        local func = info.func
        local args = info.args
        local r,e = xpcall(func,debug.traceback,self,table.unpack(args))
        if not r then
            warn(e)
        end
    end
    self.__queue_execute_cnnt = nil
end
function c:AddExecuteQueue(func,...)
    self.__execute_queue = self.__execute_queue or {}
    table.insert(self.__execute_queue,{func = func,args = {...}})
    if self.__queue_execute_cnnt then
        return
    end
    self.__queue_execute_cnnt = self:AddProcess(DoExecuteQueue)
end
---@param self BaseObject
---@param id number
local function IsWatch(self,id)
    assert(id,"param id is nil")
    return self.__watch_id_priority_map[id] ~= nil
end
---@param self BaseObject
---@param id number
local function DisWatch(self,id)
    assert(id,"param id is nil")
    local watch_id_key_map = self.__watch_id_key_map
    local key = self.__watch_id_key_map[id]
    if not key then
        return
    end
    watch_id_key_map[id] = nil
    local watch_id_priority_map = self.__watch_id_priority_map
    local watch_list = self.__watch_list
    local watch_array = self.__watch_array
    local priority = watch_id_priority_map[id]
    watch_id_priority_map[id] = nil
    watch_list[key][priority][id] = nil
    if not next(watch_list[key][priority]) then
        watch_list[key][priority] = nil
        for idx,p in ipairs(watch_array[key]) do
            if p == priority then
                table.remove(watch_array[key],idx)
                if not watch_array[key][1] then
                    watch_array[key] = nil
                end
                break
            end
        end
        if not next(watch_list[key]) then
            watch_list[key] = nil
        end
    end
end
--事件相关
---@param handle function
---@param priority number
---@return HotpotConnection
function c:Watch(key,handle,priority)
    assert(key,"param key is nil")
    assert(handle,"param handle is nil")
    --默认优先级为0
    priority = priority or 0
    --尝试初始化内容
    local id_counter = self.__watch_id_counter or  0
    local watch_list = self.__watch_list or {}
    local watch_id_priority_map = self.__watch_id_priority_map or {}
    local watch_array = self.__watch_array or {}
    local watch_id_key_map = self.__watch_id_key_map or {}
    --进行变量存储
    id_counter = id_counter + 1
    if id_counter == self.__watch_id_counter then
        id_counter = 1
    end
    watch_list[key] = watch_list[key] or {}
    watch_list[key][priority] = watch_list[key][priority] or {}
    watch_list[key][priority][id_counter] = handle
    watch_id_priority_map[id_counter] = priority
    watch_id_key_map[id_counter] = key
    watch_array[key] = watch_array[key] or {}
    local array = watch_array[key]
    local idx = 0
    while true do
        idx = idx + 1
        local now_priority = array[idx]
        if not now_priority or now_priority <= priority then
            if now_priority ~= priority then
                table.insert(array,idx,priority)
            end
            break
        end
    end
    --将数据回存
    self.__watch_id_counter = id_counter
    self.__watch_list = watch_list
    self.__watch_array = watch_array
    self.__watch_id_priority_map = watch_id_priority_map
    self.__watch_id_key_map = watch_id_key_map
    return callback_manager:CreateHotpotConnect(self,DisWatch,IsWatch,id_counter)
end
---@param key string
---@param handle function
---@param priority number
---@return HotpotConnection
function c:WatchGlobal(key,handle,priority)
    return message_helper:Watch(self,key,handle,priority)
end
---@param key string
function c:Sent(key,...)
    local watch_array = self.__watch_array and self.__watch_array[key]
    if not watch_array then
        return
    end
    local watch_list = self.__watch_list[key]
    for idx,priority in ipairs(watch_array) do
        local list = watch_list[priority]
        for id,handle in pairs(list) do
            local co = coroutine.create(handle)
            local r,e = coroutine.resume(co,self,...)
            if not r then
                warn(e)
            end
        end
    end
end
---@param key string
function c:SentGlobal(key,...)
    message_helper:Sent(key,self,...)
end
return c