local _G = _G
local debug = debug
local xpcall = xpcall
local math = math
local warn = warn
local os = os
local next = next
local table= table
local assert = assert
local type = type
local pairs = pairs
local tostring = tostring
local tonumber = tonumber
local script = script
local game = game
local coroutine = coroutine
local Enum = Enum
local wait = wait
local ipairs = ipairs
--定义常量--------------------------------
local CD = 8
local ORDER_LIST_MAX_NUM = 100
local REQUEST_ENUM_MAP = {
    normal = {
        get = Enum.DataStoreRequestType.GetAsync,
        set = Enum.DataStoreRequestType.SetIncrementAsync,
        update = Enum.DataStoreRequestType.UpdateAsync,
        increment = Enum.DataStoreRequestType.SetIncrementAsync
    },
    sort = {
        get = Enum.DataStoreRequestType.GetSortedAsync,
        update = Enum.DataStoreRequestType.UpdateAsync,
        set = Enum.DataStoreRequestType.SetIncrementSortedAsync,
        increment = Enum.DataStoreRequestType.SetIncrementSortedAsync,
    }

}
--添加引用--------------------------------
local hotpot = _G.ServerHotpot
local DataStoreService = game:GetService("DataStoreService")
---@class DataBaseManager
local c = hotpot.class.new(script)
--初始化本地变量---------------------------
---@type table<string,table> @用于存储数据库,key数据库名称，value是
local data_bases= {}
---@type table<name,table<string,boolean>> @用于记录在存储队列的查询表
local check_save_mark = {}
---@type table<string,function>[]
local save_array = {}
local save_process  --用于标记存储过程
local load_process  --用于标记读取过程
---@type table<string,table<string,number>> @用于存储cd的表
local save_cd_mark = {}
---@type table<string,table<string,number>> @用于存储加减的数据
local increment_list = {}
---@type table<string,table<string,function>> @用于存储获取值函数的表
local get_func_list = {}
---@type table<thread,boolean>
local saving_cos = {}
local saving_co_count = 0
---@type table<string,table<string,table>> @用于存储读取的队列
local load_array = {}
---@type table<string,table<string,number>> @用于存储读取的cd
local load_cd_mark = {}
---@type table<string,table<string,thread[]>> @用于存储读取的cd
local load_co_list = {}
--申明本地函数-----------------------------
local ConvertToSaveData --将数据转换为存储用的表
local ConvertToUseData  --将数据转变为用于使用的表
local SaveProcess --存储更新函数
local LoadProcess --读取更新函数
local SaveFuncs = {}
local LoadFuncs = {}
--定义本地函数----------------------------
function ConvertToSaveData(val)
    if type(val) == "table" then
        local new_tab = {}
        for key,value in pairs(val) do
            if type(key) == "number" then
                new_tab[tostring(key)] = ConvertToSaveData(value)
            else
                new_tab[key] = ConvertToSaveData(value)
            end
        end
        return new_tab
    else
        return val
    end
end
function ConvertToUseData(val)
    if type(val) == "table" then
        local new_tab = {}
        for key,value in pairs(val) do
            local new_key = tonumber(key) or key
            new_tab[new_key] = ConvertToUseData(value)
        end
        return new_tab
    else
        return val
    end
end
---@param data_base GlobalDataStore
---@param data any
---@param data_info table
function SaveFuncs.set(data_base,key,data,data_info)
    local r,e = xpcall(data_base.SetAsync,debug.traceback,data_base,key,data)
    saving_cos[coroutine.running()] = nil
    saving_co_count = saving_co_count - 1
    -- print(data_info.name,data_info.key,data," save success!")
    --如果存储错误，那么就提示，并重新执行
    if not r then
        warn(e.."\n---------------------\nretry!")
        local get_func = data_info.get_func
        local name = data_info.name
        local key = data_info.key
        c:Save(name,key,get_func)
    end
end
function SaveFuncs.increment(data_base,key,data,data_info)
    --先剔除增减的值
    local name = data_info.name
    increment_list[name][key] = increment_list[name][key] - data
    --存储
    local r,e = xpcall(data_base.IncrementAsync,debug.traceback,data_base,key,data)
    saving_cos[coroutine.running()] = nil
    saving_co_count = saving_co_count - 1
    if not r then
        warn(e)
        c:Increment(name,key,data)
    end
end
function SaveFuncs.remove(data_base,key,data,data_info)
    local r,e = xpcall(data_base.RemoveAsync,debug.traceback,data_base,key)
    saving_cos[coroutine.running()] = nil
    saving_co_count = saving_co_count - 1
    if not r then
        warn(e)
        local name = data_info.name
        local key = data_info.key
        local get_func = data.get_func
        c:Save(name,key,get_func)
    end
end
---@param data_base GlobalDataStore
---@param info any
function LoadFuncs.value(data_base,info)
    local key = info.key
    local r,e = xpcall(data_base.GetAsync,debug.traceback,data_base,key)
    return r,e
end
function LoadFuncs.list(data_bases,info)
end
function SaveProcess()
    wait()
    local save_time_mark = os.clock()
    while true do
        local go_no = false
        --计算cd
        local now = os.clock()
        for name,mark_list in pairs(save_cd_mark) do
            local del_list = {}
            for key,mark in pairs(mark_list) do
                if now - mark > CD then
                    del_list[key] = true
                else
                    go_no = true
                end
            end
            for key,__ in pairs(del_list) do
                mark_list[key] = nil
            end
        end
        --进行队列更新
        local no = 1
        for i = 1,#save_array,1 do
            local data_info = save_array[no]
            local name = data_info.name
            local key = data_info.key
            local get_func = get_func_list[name][key]
            local action_type = data_info.type
            local data_base_info = data_bases[name]
            local data_base = data_base_info.inst
            local data_type = data_base_info.type
            --是否处于cd，如果是就跳过序号
            if save_cd_mark[name] and save_cd_mark[name][key] then
                no = no + 1
            else
                --是否进入了限额，如果是就跳过序号
                local request_enum = REQUEST_ENUM_MAP[data_type][action_type]
                -- print(DataStoreService:GetRequestBudgetForRequestType(request_enum),"-----",#save_array)
                local limit = DataStoreService:GetRequestBudgetForRequestType(request_enum)
                -- out = out or limit
                -- out = math.min(out,limit)
                if  limit < 50 then
                    no = no + 1
                else
                    if saving_co_count < 10 then
                    --     count = count + 1
                        --从队列中移除
                        table.remove(save_array,no)
                        --清空标记
                        check_save_mark[name][key] = nil
                        get_func_list[name][key] = nil
                        --记录cd
                        save_cd_mark[name] = save_cd_mark[name] or {}
                        save_cd_mark[name][key] = now
                        --拿值
                        local r,e = xpcall(get_func,debug.traceback)
                        if not r then
                            warn("get value error on database = "..tostring(name)..",key = "..tostring(key).."\n"..e)
                            return
                        end
                        local data = ConvertToSaveData(e)
                        local save_func
                        if not data then
                            save_func = SaveFuncs.remove
                        else
                            save_func = SaveFuncs[action_type]
                        end
                        local co = coroutine.create(save_func)
                        saving_cos[co] = true
                        saving_co_count = saving_co_count + 1
                        --如果都过了，那么就进入存储流程
                        coroutine.resume(co,data_base,key,data,data_info)
                        wait()
                        -- save_func(data_base,key,data,data_info)
                    else
                        break
                    end
                    -- save_func(data_base,key,data,data_info)
                end
            end
        end
        -- if go_no and #save_array < 1 then
        if #save_array < 1 then
            break
        end
        -- print("save array = ",#save_array)
        wait()
    end
    save_process = nil
    -- print("save over,cost:",os.clock() - save_time_mark)
end
function LoadProcess()
    wait()
    local load_time_mark = os.clock()
    while true do
        local go_no = false
        --处理cd
        local now = os.clock()
        for name,cd_list in pairs(load_cd_mark) do
            local del_list = {}
            for key,mark in pairs(cd_list) do
                if now - mark > CD then
                    del_list[key] = true
                else
                    go_no = true
                end
            end
            for key,__ in pairs(del_list) do
                cd_list[key] = nil
            end
        end
        local no = 1
        for i = 1,#load_array,1 do
            local info = load_array[no]
            local name = info.name
            local key = info.key
            local action_type = info.type
            if load_cd_mark[name] and load_cd_mark[name][key] then
                no = no + 1
            else
                local data_base_info = data_bases[name]
                local data_base = data_base_info.inst
                local data_base_type = data_base_info.type
                if DataStoreService:GetRequestBudgetForRequestType(REQUEST_ENUM_MAP[data_base_type].get) < 1 then
                    no = no + 1
                else
                    table.remove(load_array,no)
                    --记录cd
                    load_cd_mark[name] = load_cd_mark[name] or {}
                    load_cd_mark[name][key] = now
                    --开始读取数据
                    local co_list = load_co_list[name][key]
                    if co_list then
                        load_co_list[name][key] = nil
                        local f = coroutine.wrap(function()
                            local handle = LoadFuncs[action_type]
                            local r,e = handle(data_base,info)
                            for __,co in ipairs(co_list) do
                                coroutine.resume(co,r,e)
                            end
                        end)
                        f()
                    end
                end
            end
        end
        -- print("load array num = ",#load_array)
        if not go_no and #load_array < 1 then
        -- if #load_array < 1 then
            break
        end
        wait()
    end
    load_process = nil
    -- print("load over,used "..(os.clock() - load_time_mark).."s")
end
--定义成员函数
---@type fun(name:string) @用于创建一个数据库
---@param name string @创建数据库的名字
function c:CreateDataBase(name)
    assert(name,"param name is nil")
    -- assert(not data_bases[name],"data base have already existed named "..tostring(name))
    if not data_bases[name] then
        local data_store = DataStoreService:GetDataStore(name)
        data_bases[name] = {
            inst = data_store,
            type = "normal",
        }
    -- else
    --     warn("data base have already existed named "..tostring(name))
    end
end
---@type fun(name:string) @创建一个带有顺序的数据库
---@param name string @创建数据库的名字
function c:CreateSortDataBase(name)
    assert(name,"param name is nil")
    assert(not data_bases[name],"data base have already existed named "..tostring(name))
    local data_store = DataStoreService:GetOrderedDataStore(name)
    data_bases[name] = {
        inst = data_store,
        type = "sort"
    }
end
---@type fun(name:string,key:string,get_func:function) @记录数据
---@param name string   @数据库名字
---@param key any    @key值
---@param get_func function @用户获取最新值的闭包函数,需要返回最新值
function c:Save(name,key,get_func)
    --参数检查
    assert(name,"param name is nil")
    assert(key,"param key is nil")
    assert(get_func,"get function is nil")
    assert(data_bases[name],"no such data base named "..tostring(name))
    --检查是否已经在存储队伍里,如果在就退出
    check_save_mark[name] = check_save_mark[name] or {}
    get_func_list[name] = get_func_list[name] or {}
    get_func_list[name][key] = get_func
    if check_save_mark[name][key] then
        return
    end
    check_save_mark[name][key] = true
    table.insert(save_array,{
        name = name,
        key = key,
        get_func = get_func,
        type = "set",
    })
    --尝试打开存储过程
    if save_process then
        return
    end
    save_process = coroutine.create(SaveProcess)
    coroutine.resume(save_process)
end
---@type fun(name:string,key:string,num:number) @增减数据值，该值必须是数值类型,一般用于记录顺序数据
---@param name string
---@param key any
---@param num number
function c:Increment(name,key,num)
    assert(name,"param name is nil")
    assert(key,"param key is nil")
    assert(num,"get num is nil")
    assert(data_bases[name],"no such data base named "..tostring(name))
    check_save_mark[name] = check_save_mark[name] or {}
    increment_list[name] = increment_list[name] or {}
    increment_list[name][key] = increment_list[name][key] or 0
    increment_list[name][key] = increment_list[name][key] + num
    get_func_list[name] = get_func_list[name] or {}
    get_func_list[name][key] = function()
        return increment_list[name][key]
    end
    if check_save_mark[name][key] then
        return
    end
    check_save_mark[name][key] = true
    table.insert(save_array,{
        name = name,
        key = key,
        type = "increment",
    })
    if save_process then
        return
    end
    save_process = coroutine.create(SaveProcess)
    coroutine.resume(save_process)
end
---@type fun():boolean @查看是否还有数据正在存储
function c:IsSaving()
    return #save_array > 0 or next(saving_cos)
end
---@type fun(name:string,key:string) @查看某个数据库的某个key值是否正在存储
---@param name string @数据库名称
---@param key any  @key值
function c:IsDataSaving(name,key)
    return check_save_mark[name] and check_save_mark[name][key]
end
---@type fun(name:string,key:string):any @读取数据
---@param name string @数据库名称
---@param key any   @key值
---@return any
function c:Load(name,key)
    --参数检查
    assert(name,"param name is nil")
    assert(key,"param key is nil")
    assert(data_bases[name],"no data base named "..tostring(name))
    --查看是否有正在存储的内容,如果有就返回值
    -- if check_save_mark[name] and check_save_mark[name][key] then
    --     local get_func = get_func_list[name][key]
    --     local r,e = xpcall(get_func,debug.traceback)
    --     if not r then
    --         warn(e)
    --         return false,e
    --     end
    -- end
    --记录携程
    local co = coroutine.running()
    load_co_list[name] = load_co_list[name] or {}
    load_co_list[name][key] = load_co_list[name][key] or {}
    table.insert(load_co_list[name][key],co)
    --查看是否处于cd
    -- if load_cd_mark[name] and load_cd_mark[name][key] then
    --     local r,e = coroutine.yield()
    --     wait()
    --     if not r then
    --         warn(e)
    --     else
    --         e = ConvertToUseData(e)
    --     end
    --     return r,e
    -- end
    --如果没有在cd，那么就将请求加入队列
    table.insert(load_array,{
        name = name,
        key = key,
        type = "value"
    })
    --尝试唤醒读取流程
    if not load_process then
       load_process = coroutine.create(LoadProcess) 
       coroutine.resume(load_process)
    end
    local r,e = coroutine.yield()
    wait()
    if not r then
        warn(e)
    else
        e = ConvertToUseData(e)
    end
    return r,e
end
---@type fun(name:string,ascending:boolean,num:number,min_value:number,max_value:number):number[] @获取排序的数据表
---@param name string  @数据库名称
---@param ascending boolean @升序
---@param num number @获取数量
---@param min_value number @最小值
---@param max_value number @最大值
---@return number
function c:GetSortedList(name,ascending,num,min_value,max_value)
    assert(name,"param name is nil")
    if ascending == nil then
        ascending = false
    end
    num = num or ORDER_LIST_MAX_NUM
    local total_num = num
    local page_num = math.min(num,ORDER_LIST_MAX_NUM)
    if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetSortedAsync) < 1 then
        return false,"out of queue"
    end
    local data_base_info = data_bases[name]
    ---@type OrderedDataStore
    local data_base = data_base_info.inst
    local r,e = xpcall(data_base.GetSortedAsync,debug.traceback,data_base,ascending,page_num,min_value,max_value)
    if not r then
        warn(e)
        return false,e
    end
    ---@type DataStorePages
    local data_page = e
    local time_mark = 0
    if data_page then
        local result = {}
        while true do
            for __,val in ipairs(data_page:GetCurrentPage()) do
                table.insert(result,val)
                if #result >= total_num then
                    return result
                end
            end
            if not data_page.IsFinished then
                local now_clock = os.clock()
                if now_clock - time_mark < 10 then
                    wait(10 - (now_clock - time_mark))
                end
                time_mark = now_clock
                data_page:AdvanceToNextPageAsync()
            else
                break
            end
        end
        return result
    end
    return false,"get data faild"
end
return c