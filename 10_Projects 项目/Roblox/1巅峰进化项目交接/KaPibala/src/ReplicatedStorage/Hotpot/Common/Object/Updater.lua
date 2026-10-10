local _G = _G
local warn = warn
local next = next
local assert = assert
local os = os
local script = script
local xpcall = xpcall
local debug = debug
local table = table
local coroutine = coroutine
local print = print
local pairs = pairs
local hotpot = _G.CommonHotpot
local ObjectManager = hotpot.load.ObjectManager()
local HotpotConnection = hotpot.load.HotpotConnection()
---@class Updater
local c = hotpot.class.new(script)
function c:ctor()
    ---@type table<BaseObject,table<thread,any[]>>
    self.co_list = {}
    self.wait_list = {}
end
function c:dtor()
    self.co_list = {}
    self.context_marks = {}
end
function c.new()
    return c()
end
---@type fun(object:BaseObject,handle:function,tag_step:number,...):HotpotConnection
---@param object BaseObject
---@param handle function
---@param tag_step number
---@return HotpotConnection
function c:AddUpdate(object,handle,tag_step,...)
    assert(object,"param object is nil")
    assert(handle,"param handle is nil")
    if not ObjectManager:IsObjectExsit(object) then
        warn("object is not exist!"..debug.traceback())
        return
    end
    tag_step = tag_step or 0
    local co
    local arg = {...}
    co = coroutine.create(function()
        coroutine.yield("update_begin")
        local time_mark = os.clock()
        local step = 0
        local run_time = 0
        while true do
            local now_time = os.clock()
            local def_time = now_time - time_mark
            time_mark = now_time
            step = step + def_time
            run_time = run_time + def_time
            if step >= tag_step then
                local r,e = xpcall(handle,debug.traceback,object,step,run_time,table.unpack(arg))
                step = 0
                if not r then
                    warn(e)
                    break
                end
                if e == true then
                    break
                end
            end
            coroutine.yield("update_step")
        end
        self:DelCo(object,co)
    end)
    self:AddCo(object,co)
    -- return HotpotConnection.new(object,self.DelCo,self.CoExsit,self,co)
    return co
end
---@type fun(object:BaseObject,handle:function,...):HotpotConnection
---@param object BaseObject
---@param handle function
---@return HotpotConnection
function c:AddProcess(object,handle,...)
    assert(object,"param object is nil")
    assert(handle,"param handle is nil")
    if not ObjectManager:IsObjectExsit(object) then
        warn("object is not exist!")
        return
    end
    local co
    local arg = {...}
    co = coroutine.create(function()
        coroutine.yield("process_begin")
        local r,e = xpcall(handle,debug.traceback,object,table.unpack(arg))
        self:DelCo(object,co)
        if not r then
            warn(e)
        end
    end)
    self:AddCo(object,co)
    -- return HotpotConnection.new(object,self.DelCo,self.CoExsit,self,co)
    return co
end
function c:AddCo(object,co)
    if not ObjectManager:IsObjectExsit(object) then
        return
    end
    self.co_list[object] = self.co_list[object] or {}
    self.co_list[object][co] = true
    return co
end
function c:DelCo(object,co)
    if self.co_list[object] then
        self.co_list[object][co] = nil
        if not next(self.co_list[object]) then
            self.co_list[object] = nil
        end
    end
end
function c:CoExsit(object,co)
    if not ObjectManager:IsObjectExsit(object) then
        self.co_list[object] = nil
    else
        if self.co_list[object] then
            return self.co_list[object][co]
        end
    end
end
function c:DelObject(obj)
    if not ObjectManager:IsObjectExsit(obj) then
        self.co_list[obj] = nil
    end
end
function c:AddWaitCo(obj,co,log)
    self.wait_list[obj] = self.wait_list[obj] or {}
    self.wait_list[obj][co] = log
end
function c:DelWaitCo(obj,co)
    if self.wait_list[obj] then
        self.wait_list[obj][co] = nil
        if not next(self.wait_list[obj]) then
            self.wait_list[obj] = nil
        end
    end
end
function c:WaitCoExist(obj,co)
    if self.wait_list[obj] then
        return self.wait_list[obj][co]
    end
end
function c:Update()
    for obj,cos in pairs(self.co_list) do
        for co,__ in pairs(cos) do
            local r,e = coroutine.resume(co)
            if not r then
                warn(e)
                self:DelCo(obj,co)
            else
                if not self:CoExsit(obj,co) then
                    self:DelCo(obj,co)
                else
                    if not e then
                        if coroutine.status(co) ~= "dead" then
                            warn("there is roblox yield,update is stop!pls check!\n"..debug.traceback(co))
                        end
                        self:DelCo(obj,co)
                    elseif e == "hotpot_update_wait_start" then
                        self:DelCo(obj,co)
                        coroutine.resume(co)
                    end
                end
            end
        end
    end
end
function c:UpdateCheck()
    return next(self.co_list) or next(self.wait_list)
end
return c