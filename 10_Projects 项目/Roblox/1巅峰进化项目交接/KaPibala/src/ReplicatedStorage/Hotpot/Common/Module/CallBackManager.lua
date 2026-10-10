local _G = _G
local table = table
local xpcall = xpcall
local assert = assert
local debug = debug
local wait = wait
local game = game
local next = next
local script = script
local coroutine = coroutine
local os = os
local pairs = pairs
local ipairs = ipairs
local warn = warn
---@type RunService
local RunService = game:GetService("RunService")
local is_client = RunService:IsClient()
local hotpot = _G.CommonHotpot
local Timer = hotpot.load.Timer()
local object_manager = hotpot.load.ObjectManager()
local hotpot_connection = hotpot.load.HotpotConnection()
---@class CallBackManager
local c = hotpot.class.new(script)
---@type table<BaseObject,table<thread,string>>
local object_co = {}
---@type table<thread,BaseObject>
local co_object = {}

local function CoCheck(co)
    local object = co_object[co]
    if object then
        if not object:IsExist() then
            return
        end
        local list = object_co[object]
        if list then
            return list[co]
        end
    end
end
local function DelCo(co)
    local object = co_object[co]
    if object then
        co_object[co] = nil
        local list = object_co[object]
        if list then
            list[co] = nil
            if not next(list) then
                object_co[object] = nil
            end
        end
    end
end
local function TryResume(co, time_count)
    local object = co_object[co]
    if object then
        local co_type = object_co[object][co]
        if co_type then
            coroutine.resume(co, time_count)
        end
    end
end
local function ConnectCoDel(object, co)
    DelCo(co)
end
local function ConnectCoExist(object, co)
    return CoCheck(co)
end
local timer_list = {}
timer_list.logic = Timer.new(TryResume)
timer_list.step = Timer.new(TryResume)
timer_list.heart_beat = Timer.new(TryResume)
local update_marks = {}
local update_funcs = {}
function update_funcs.logic()
    local timer = timer_list.logic
    local co =
        coroutine.create(
        function()
            while true do
                local step = wait()
                if not timer:Update(step) then
                    break
                end
            end
            update_marks.logic = nil
        end
    )
    update_marks.logic = true
    local r, e = coroutine.resume(co)
    if not r then
        warn(e)
    end
end
function update_funcs.step()
    local timer = timer_list.step
    ---@type RBXScriptConnection
    local cnnt
    cnnt =
        RunService.Stepped:Connect(
        function(time,step)
            if not timer:Update(step) then
                cnnt:Disconnect()
                update_marks.step = nil
            end
        end
    )
    update_marks.step = true
end
function update_funcs.heart_beat()
    local timer = timer_list.heart_beat
    local cnnt
    cnnt =
        RunService.Heartbeat:Connect(
        function(step)
            if not timer:Update(step) then
                cnnt:Disconnect()
                update_marks.heart_beat = nil
            end
        end
    )
    update_marks.heart_beat = true
end
if is_client then
    timer_list.render = Timer.new(TryResume)
    timer_list.first = Timer.new(TryResume)
    timer_list.input = Timer.new(TryResume)
    timer_list.camera = Timer.new(TryResume)
    timer_list.character = Timer.new(TryResume)
    timer_list.last = Timer.new(TryResume)
    function update_funcs.render()
        local timer = timer_list.render
        local cnnt
        cnnt =
            RunService.RenderStepped:Connect(
            function(step)
                if not timer:Update(step) then
                    cnnt:Disconnect()
                    update_marks.render = nil
                end
            end
        )
        update_marks.render = true
    end
    function update_funcs.first()
        local timer = timer_list.first
        RunService:BindToRenderStep(
            "hotpot_first",
            Enum.RenderPriority.First.Value,
            function(step)
                if not timer:Update(step) then
                    RunService:UnbindFromRenderStep("hotpot_first")
                    update_marks.first = nil
                end
            end
        )
        update_marks.first = true
    end
    function update_funcs.input()
        local timer = timer_list.input
        RunService:BindToRenderStep(
            "hotpot_input",
            Enum.RenderPriority.Input.Value,
            function(step)
                if not timer:Update(step) then
                    RunService:UnbindFromRenderStep("hotpot_input")
                    update_marks.input = nil
                end
            end
        )
        update_marks.input = true
    end
    function update_funcs.camera()
        local timer = timer_list.camera
        RunService:BindToRenderStep(
            "hotpot_camera",
            Enum.RenderPriority.Camera.Value,
            function(step)
                if not timer:Update(step) then
                    RunService:UnbindFromRenderStep("hotpot_camera")
                    update_marks.camera = nil
                end
            end
        )
        update_marks.camera = true
    end
    function update_funcs.character()
        local timer = timer_list.character
        RunService:BindToRenderStep(
            "hotpot_character",
            Enum.RenderPriority.Character.Value,
            function(step)
                if not timer:Update(step) then
                    RunService:UnbindFromRenderStep("hotpot_character")
                    update_marks.character = nil
                end
            end
        )
        update_marks.character = true
    end
    function update_funcs.last()
        local timer = timer_list.last
        RunService:BindToRenderStep(
            "hotpot_last",
            Enum.RenderPriority.Last.Value,
            function(step)
                if not timer:Update(step) then
                    RunService:UnbindFromRenderStep("hotpot_last")
                    update_marks.last = nil
                end
            end
        )
        update_marks.last = true
    end
end
function c:Wait(object, step)
    if not object_manager:IsObjectExsit(object) then
        coroutine.yield()
    end
    local co = coroutine.running()
    if not CoCheck(co) then
        coroutine.yield()
    end
    local co_list = object_co[object]
    local co_type
    if co_list then
        co_type = co_list[co]
    end
    local timer
    if co_type then
        timer = timer_list[co_type]
    end
    if timer then
        timer:Add(co, step)
        --尝试唤醒更新
        if not update_marks[co_type] then
            update_funcs[co_type]()
        end
        -- local mark = os.clock()
        return coroutine.yield()
    else
        local run_time = wait(step)
        if not object_manager:IsObjectExsit(object) then
            coroutine.yield()
        end
        return run_time
    end
end
local function Process(co, object, func, ...)
    c:Wait(object)
    if not CoCheck(co) then
        --warn("co is delected from " .. object.class, "\n" .. debug.traceback(coroutine.running()))
        return
    end
    local r, e = xpcall(func, debug.traceback, object, ...)
    if not r then
        warn(e .. debug.traceback(co))
    end
    DelCo(co)
    wait()
end
---@type fun(co_type:string,object:BaseObject,func:function,...):HotpotConnection
---@param co_type string
---@param object BaseObject
---@param func function
---@return HotpotConnection
function c:AddProcess(co_type, object, func, ...)
    if not object_manager:IsObjectExsit(object) then
        return
    end
    assert(co_type, "param co type is nil" .. debug.traceback(coroutine.running()))
    assert(object, "param object is nil" .. debug.traceback(coroutine.running()))
    assert(func, "param func is nil" .. debug.traceback(coroutine.running()))
    assert(object_manager:IsObjectExsit(object), "object is dtor!", debug.traceback(coroutine.running()))
    local co = coroutine.create(Process)
    object_co[object] = object_co[object] or {}
    object_co[object][co] = co_type
    co_object[co] = object
    local connect = hotpot_connection.new(object, ConnectCoDel, ConnectCoExist, co)
    local r, e = coroutine.resume(co, co, object, func, ...)
    if not r then
        warn(e .. debug.traceback(coroutine.running()))
        DelCo(co)
    end
    if not update_marks[co_type] then
        update_funcs[co_type]()
    end
    return connect
end
local function Update(co, object, func, step, ...)
    local total_time = 0
    while true do
        local step = c:Wait(object, step)
        total_time = total_time + step
        local r, e = xpcall(func, debug.traceback, object, step, total_time, ...)
        if not r then
            warn(e)
            break
        end
        if e == true then
            break
        end
        if not CoCheck(co) then
            --warn("co is delected from " .. object.class, "\n" .. debug.traceback(coroutine.running()))
            break
        end
    end
    DelCo(co)
    wait()
end
---@type fun(co_type:string,object:BaseObject,func:function,step:number,...):HotpotConnection
---@param co_type string
---@param object BaseObject
---@param func function
---@param step number
---@return HotpotConnection
function c:AddUpdate(co_type, object, func, step, ...)
    assert(co_type, "param co type is nil" .. debug.traceback(coroutine.running()))
    assert(object, "param object is nil" .. debug.traceback(coroutine.running()))
    assert(func, "param func is nil" .. debug.traceback(coroutine.running()))
    assert(
        object_manager:IsObjectExsit(object),
        "object " .. object.class .. " is dtor!" .. debug.traceback(coroutine.running())
    )
    local co = coroutine.create(Update)
    object_co[object] = object_co[object] or {}
    object_co[object][co] = co_type
    co_object[co] = object
    local connect = hotpot_connection.new(object, ConnectCoDel, ConnectCoExist, co)
    local r, e = coroutine.resume(co, co, object, func, step, ...)
    if not r then
        warn(e .. debug.traceback(coroutine.running()))
        DelCo(co)
    end
    if not update_marks[co_type] then
        update_funcs[co_type]()
    end
    return connect
end
local rbx_cnnts = {}
---@param cnnt RBXScriptConnection
local function DelRBXConnect(object, cnnt)
    local list = rbx_cnnts[object]
    if list then
        list[cnnt] = nil
        if not list then
            rbx_cnnts[object] = nil
        end
    end
    cnnt:Disconnect()
end
---@param cnnt RBXScriptConnection
local function RBXConnectExist(object, cnnt)
    return cnnt.Connected
end
---@param object BaseObject
---@param rbx_signal RBXScriptSignal
---@param func function
---@return HotpotConnection
function c:AddRbxConnect(object, rbx_signal, func,...)
    assert(object, "param object is nil")
    assert(rbx_signal, "param rbx signal is nil")
    assert(func, "param call back is nil")
    local arg = {...}
    local rbx_cnnt
    if #arg > 0 then
        rbx_cnnt = rbx_signal:Connect( function(...)
            if not object_manager:IsObjectExsit(object) then
                return
            end
            func(object, ...,table.unpack(arg))
        end)
    else
        rbx_cnnt = rbx_signal:Connect( function(...)
            if not object_manager:IsObjectExsit(object) then
                return
            end
            func(object, ...)
        end)
    end
    rbx_cnnts[object] = rbx_cnnts[object] or {}
    rbx_cnnts[object][rbx_cnnt] = true
    local cnnt = hotpot_connection.new(object, DelRBXConnect, RBXConnectExist, rbx_cnnt)
    return cnnt
end
function c:CreateHotpotConnect(object,del_func,check_func,...)
    assert(object,"param object is nil")
    assert(del_func,"param del function is nil")
    assert(check_func,"param check function is nil")
    local cnnt = hotpot_connection.new(object,del_func,check_func,...)
    rbx_cnnts[object] = rbx_cnnts[object] or {}
    rbx_cnnts[object][cnnt] = true
    return cnnt
end
function c:AddConnectToObject(cnnt,obj)
    rbx_cnnts[obj] = rbx_cnnts[obj] or {}
    rbx_cnnts[obj][cnnt] = true
end
---@type fun() @清空传入的rbxsignal,自带检测
---@param connect HotpotConnection
function c:CancelRbxConnect(connect)
    if not connect then
        return
    end
    connect:Disconnect()
end
---@type fun(object:BaseObject)
---@param object BaseObject
function c:DelObject(object)
    local co_list = object_co[object]
    if co_list then
        for co, co_type in pairs(co_list) do
            if co_object[co] == object then
                co_object[co] = nil
            end
        end
        object_co[object] = nil
    end
    local cnnt_list = rbx_cnnts[object]
    if cnnt_list then
        for cnnt, __ in pairs(cnnt_list) do
            cnnt:Disconnect()
        end
        rbx_cnnts[object] = nil
    end
end
---@type fun(object:BaseObject,co_type:string,co:thread):HotpotConnection
---@param object BaseObject
---@param co_type string
---@param co thread
---@return HotpotConnection
function c:AddCo(object, co_type, co)
    assert(object, "param object is nil")
    assert(object_manager:IsObjectExsit(object), "object is dtor!" .. debug.traceback(coroutine.running()))
    co = co or coroutine.running()
    object_co[object] = object_co[object] or {}
    object_co[object][co] = co_type
    co_object[co] = object
    if not update_marks[co_type] then
        update_funcs[co_type]()
    end
    local cnnt = hotpot_connection.new(object, ConnectCoDel, ConnectCoExist, co)
    return cnnt
end
function c:CoCheck(object, co)
    co = co or coroutine.running()
    if not object_manager:IsObjectExsit(object) then
        coroutine.yield()
    end
    if not CoCheck(co) then
        coroutine.yield()
    end
end
function c:GetObjectCo()
    return object_co
end
function c:GetCoObject()
    return co_object
end
return c
