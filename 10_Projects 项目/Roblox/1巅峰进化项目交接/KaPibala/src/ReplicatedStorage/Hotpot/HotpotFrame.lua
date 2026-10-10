--设置随机种子
local next = next
local setmetatable = setmetatable
local getmetatable = getmetatable
local game = game
local math = math
local string = string
local warn = warn
local pairs = pairs
local ipairs = ipairs
local xpcall = xpcall
local error = error
local wait = wait
local assert = assert
local require = require
local type = type
local typeof = typeof
local print = print
local table = table
local tostring = tostring
local os = os
local pcall = pcall
local coroutine = coroutine
------------------基础配置
local DEFAULT_TIME_LIMIT = 10
--引用通用服务
---@type InsertService
local InsertService = game:GetService("InsertService")
---@type RunService
local RunService = game:GetService("RunService")
--设置随机种子
local random_seed = os.time()
---@class HotpotFrame
local c = {}
--------定义随机数相关函数
---@type fun(min:number,max:number):number @根据输入获得一个随机数
---@param min number
---@param max number
---@return number
function c:Random(min,max)
    random_seed = random_seed + 1
    math.randomseed(random_seed)
    if min and max then
        return math.random(min,max)
    else
        return math.random()
    end
end
--------随机小数(传整数也返回小数)
---@type fun(min:number,max:number):number @返回随机小数,min和max必填
---@param min number @整数或小数（不论正负)
---@param max number@整数或小数（不论正负)
---@return number 
function c:RandomFloat(min,max)
    random_seed = random_seed + 1
    return Random.new():NextNumber(min,max)
end
--------定义获得路径相关碎片
local function get_child(path,base,time_out)
    time_out = time_out or DEFAULT_TIME_LIMIT
    local child = base:WaitForChild(path,time_out)
    return child
end
---@type fun(path_str:string,base:Instance,time_out:number) @根据基础instance获取指定路径上的instance,如果获得超时则返回空值
---@param path_str string
---@param base Instance
---@param time_out number
---@return Instance
function c:GetPath(path_str,base,time_out)
    --检查参数合法性
    assert(path_str,"param path string is nil")
    local type_of_path_str = typeof(path_str)
    assert(type_of_path_str=="string","param path string must be a string,not "..type_of_path_str)
    base = base or game
    local type_of_base = typeof(base)
    assert(base and type_of_base=="Instance","param base must be a instance,not "..type_of_base)
    local base_init = base
    local now_path = base.Name
    for path in string.gmatch(path_str,"[%a%d_]+") do
        base = get_child(path,base,time_out)
        if not base then
            warn("get inst with path = "..path_str.." form "..base_init.Name.." time out!\nStopped at "..now_path.."\n"..debug.traceback(coroutine.running()))
            return
        end
        now_path = now_path.."."..path
    end
    return base
end
---@type fun(path_str:string,base:Instance,time_out:number) @根据基础instance获取指定路径上的instance,如果获得超时则会报错
---@param path_str string
---@param base Instance
---@param time_out number
---@return Instance
function c:GetPath_Check(path_str,base,time_out)
    local inst = self:GetPath(path_str,base,time_out)
    assert(inst,"get inst with path "..path_str.." time out!")
    return inst
end
function c:GetPath_Loop(path_str,base,time_out)
    -- local inst = self:GetPath(path_str,base,time_out)
    -- if not inst then
    --     warn("retry get "..path_str)
    --     return self:GetPath_Loop(path_str,base,time_out)
    -- end
    -- return inst
    local inst = self:GetPath(path_str,base,time_out)
    while not inst do
        inst = self:GetPath(path_str,base,time_out)
    end
    return inst
end
---------定义输出表格相关的函数
local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    if type(v) == 'number' and v > 0xFFFFFFFF then
        return string.format('0x%x', v)
    end
    return tostring(v)
end
local function dump(value, desciption, nesting)
    assert(value,"param value is nil")
    if type(nesting) ~= "number" then nesting = 5 end

    local lookupTable = {}
    local result = {}

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, desciption, "", 1)
    print(table.concat(result, '\n'))
end
---@type fun(tab:table,desciption:string,nesting:number) @输出指定的表
---@param tab table
---@param desciption string
---@param nesting number
function c:PrintTable(tab,desciption,nesting)
    dump(tab,desciption,nesting)
end
function c:Dump(tb,dump_metatable, max_level)
    local lookup_table = {}
    local level = 0
    local rep = string.rep
    local dump_metatable = dump_metatable
	local max_level = max_level or 5
	
	if not next(tb) then
		return "{ }"
	end

    local function _dump(tb, level)
        local str = "\n" .. rep("\t", level) .. "{\n"
        for k,v in pairs(tb) do
            local k_is_str = type(k) == "string" and 1 or 0
            local v_is_str = type(v) == "string" and 1 or 0
            str = str..rep("\t", level + 1).."["..rep("\"", k_is_str)..(tostring(k) or type(k))..rep("\"", k_is_str).."]".." = "
            if type(v) == "table" then
                if not lookup_table[v] and ((not max_level) or level < max_level) then
					lookup_table[v] = true
					if next(v) then
						str = str.._dump(v, level + 1, dump_metatable).."\n"
					else
						str = str.."{ }".."\n"
					end
				else
					if next(v) then
						str = str..(tostring(v) or type(v))..",\n"
					else
						str = str.."{ }"..",\n"
					end
                end
            else
                str = str..rep("\"", v_is_str)..(tostring(v) or type(v))..rep("\"", v_is_str)..",\n"
            end
        end
        if dump_metatable then
            local mt = getmetatable(tb)
            if mt ~= nil and type(mt) == "table" then
                str = str..rep("\t", level + 1).."[\"__metatable\"]".." = "
                if not lookup_table[mt] and ((not max_level) or level < max_level) then
                    lookup_table[mt] = true
                    str = str.._dump(mt, level + 1, dump_metatable).."\n"
                else
                    str = str..(tostring(v) or type(v))..",\n"
                end
            end
        end
        str = str..rep("\t", level) .. "},"
        return str
    end

    return _dump(tb, level)
end
---@type fun(tab:table):table @克隆表
---@param tab table
---@return table
function c:CloneTable(tab)
    assert(tab,"param tab is nil")
    assert(typeof(tab)=="table","param tab must be a table")
    local ctab = {}
    for key,value in pairs(tab) do
        if type(value) ~= "table" then
            ctab[key] = value
        else
            ctab[key] = self:CloneTable(value)
        end
    end
    return ctab
end
---@type fun(tab:table):number @输出表中的元素数量
---@param tab table
---@return number
function c:CountTable(tab)
    assert(tab,"param tab is nil")
    assert(typeof(tab)=="table","param tab must be a table")
    local n = 0
    for k in pairs(tab) do
        n = n + 1
    end
    return n
end
---@type fun(tab:table):any[] @获得表中所有的key，并以数组的方式返回，注意这个顺序是不定的
---@param tab table
---@return any[]
function c:GetTableKeys(tab)
    assert(tab,"param tab is nil")
    assert(typeof(tab)=="table","param tab must be a table")
    local keys = {}
    for k in pairs(tab) do
        keys[#keys+1] = k
    end
    return keys
end
---@type fun(tab:table):any[] @获得表中所有的value，并以数组的方式返回，，注意这个顺序是不定的
---@param tab table
---@return any[]
function c:GetTableValues(tab)
    assert(tab,"param tab is nil")
    assert(typeof(tab)=="table","param tab must be a table")
    local vals = {}
    for _, v in pairs(tab) do
        vals[#vals+1] = v
    end
    return vals
end
---@type fun(inst:Instance,time_out:number):Instance @克隆实例,如果克隆失败返回空值
---@param inst Instance
---@param time_out number
---@return Instance
function c:CloneInst(inst,time_out)
    assert(inst,"param inst is nil")
    local inst_type = typeof(inst)
    assert(inst_type=="Instance","param inst must be instance,now is "..inst_type)
    time_out = time_out or DEFAULT_TIME_LIMIT
    --如果要克隆的对象是model，那么需要检查是否存在primary part
    if inst:IsA('Model') then
        assert(inst.PrimaryPart,'model '..inst.Name.." don't have primary part,plese check")
        assert(inst.PrimaryPart.Archivable,'model '..inst.Name.."'s primary part archivable is false, can't clone")
    end
    --获取目标实例的对象数量
    local childs = inst:GetDescendants()
    local child_num = #childs
    --先检查克隆目标，去掉克隆锁，并删除碰撞检测组件
    for __,child in ipairs(inst:GetDescendants()) do
        if child:IsA("TouchTransmitter") then
            child:Destroy()
            child_num = child_num - 1
        elseif not child.Archivable then
            child_num = child_num - 1
        end
    end
    --开始克隆
    local time_count = 0
    local cinst = inst:Clone()
    while #cinst:GetDescendants() < child_num do
        time_count = time_count + wait()
        if time_count >= time_out then
            warn("clone "..inst.Name.." faild,time out")
            return
        end
    end
    if cinst:IsA("Model") then
        while not cinst.PrimaryPart do
            time_count = time_count + wait()
            if time_count > time_out then
                warn("clone "..inst.Name.." faild,time out")
                return
            end
        end
    end
    return cinst
end
---@type fun(inst:Instance,time_out:number):Instance @克隆实例,如果克隆失败会报错
---@param inst Instance
---@param time_out number
---@return Instance
function c:CloneInst_Check(inst,time_out)
    local cinst = self:CloneInst(inst,time_out)
    assert(cinst,"clone inst "..inst.Name.." time out")
    return cinst
end
function c:CloneInst_Loop(inst,time_out)
    local cinst = self:CloneInst(inst,time_out)
    -- if not cinst then
    --     warn("retry clone "..inst.Name)
    --     return self:CloneInst_Loop(inst,time_out)
    -- end
    -- return cinst
    while not cinst do
        cinst = self:CloneInst(inst,time_out)
    end
    return cinst
end
---@type fun(time_limit:number) @设置默认最长等待时间
function c:SetDefaultTimeLimit(time_limit)
    assert(time_limit,"param time limit is nil")
    assert(typeof(time_limit)=="number","param time limit must be number")
    DEFAULT_TIME_LIMIT = time_limit
end
---@type fun():number @返回当前默认最长等待时间
function c:GetDefaultTimeLimit()
    return DEFAULT_TIME_LIMIT
end
function c:InitFiles(file_list)
    self.__file_list = file_list
    local files = {}
    for name,path in pairs(file_list) do
        files[name] = function(time_out)
            local file = self:GetPath_Loop(path,game,time_out)
            files[name] = function()
                return file
            end
            return file
        end
    end
    return files
end
function c:InitLoads(file_list)
    local loads = {}
    for name,path in pairs(file_list) do
        loads[name] = function(time_out)
            local r,e = xpcall(require,debug.traceback,self.files[name](time_out))
            if not r then
                warn(e)
                return
            end
            loads[name] = function()
                return e
            end
            return e
        end
    end
    return loads
end
function c:InitResource(file_list)
    local rescs = {}
    for name,val in pairs(file_list) do
        if type(val) == "table" then
            rescs[name] = self:InitResource(val)
        else
            rescs[name] = function(time_out)
                local resc = self:GetPath_Loop(val,game,time_out)
                rescs[name] = function(time_out)
                    return self:CloneInst_Loop(resc,time_out)
                end
                return self:CloneInst_Loop(resc,time_out)
            end
        end
    end
    return rescs
end
function c:InitConfig()
    local config = self:GetPath_Check("ReplicatedStorage.Config",game)
    local r,e = xpcall(require,debug.traceback,config)
    if not r then
        warn(e)
        return
    end
    return e
end
---@type fun(handle:function,err_handle:function,time_out:number)
---@param handle function
---@param err_handle function
---@param time_out number
function c:Preload(handle,err_handle,time_out)
    local preloading_co = coroutine.running()
    local max_num = 0
    local left_num = 0
    local load_funcs = {}
    for file_name,file_path in pairs(self.__file_list) do
        max_num = max_num + 1
        left_num = left_num + 1
        load_funcs[file_name] = coroutine.wrap(function()
            local r,e = pcall(function()
                self.files[file_name](time_out,not err_handle)
                left_num = left_num - 1
                if handle then
                    handle(max_num,max_num-left_num,file_name,file_path)
                end
                if left_num <= 0 then
                    wait()
                    coroutine.resume(preloading_co)
                end
            end)
            if not r then
                if err_handle then
                    err_handle(e,file_name,file_path)
                else
                    error(e)
                end
            end
        end)
    end
    for file_name,file_func in pairs(load_funcs) do
        file_func()
    end
    coroutine.yield()
end
return c