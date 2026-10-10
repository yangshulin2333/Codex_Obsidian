local _G = _G
local script = script
local os = os
local game = game
local string = string
local tostring = tostring
local assert = assert
local table = table
local tonumber = tonumber
local workspace = workspace
local pairs = pairs
local type = type
local math = math
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local hotpot = _G.ClientHotpot

---@type Players
local Players = game:GetService("Players")
---@type Player
local local_player = Players.LocalPlayer
---@class Client_PlayerDataExHelper
local c = hotpot.class.new(script)
local code
function c:Login()
    ---@type RemoteFunction
    local login_function = hotpot:GetPath_Check("ReplicatedStorage.LoginFunction")
    code = login_function:InvokeServer()
    if code then
        login_function:Destroy()
    else
        local f = coroutine.wrap(function() 
            error("error in login,retry! id = "..player.UserId)
        end)
        f()
        self:Login()
    end
end
local function GetFireTabAndSum(tab)
    local new_tab = {}
    local sum = 0
    for k, v in pairs(tab) do
        if type(k) == "number" then
            k = tostring(k)
        end
        local v_type = type(v)
        if v_type == "table" then
            local t, s = GetFireTabAndSum(v)
            new_tab[k] = t
            sum = sum + s
        else
            if v_type == "number" and v ~= math.huge then
                local val = math.abs(math.ceil(v))
                local temp = 0
                while val ~= 0 do
                    temp = temp + (val % 256)
                    val = math.floor(val / 256)
                end
                sum = sum + temp
            end
            new_tab[k] = v
        end
    end
    return new_tab, sum
end
local function GetKey(args)
    -- 随机一个0～9的数值作为随机key
    -- local random_key = hotpot:Random(1,9)
    local random_key = math.random(1, 9)
    -- id乘以随机值
    -- clock添加随机值并做一个加法
    local clock = tostring(os.clock())
    -- 转换包体，并记录数值数值和
    local new_args, sum = GetFireTabAndSum(args)
    local str = clock .. tostring(sum + code)
    local key = string.char(32 + random_key) .. string.char(string.len(clock) + 31 + random_key)
    for i = 1, string.len(str), 1 do
        key = key .. string.char(string.byte(str, i) + random_key + i)
    end
    return new_args, key
end
function c:GetKey(args)
    assert(args, "param args is nil")
    return xpcall(GetKey, debug.traceback, args)
end
--[[
local function GetStringSum(str)
    local sum = 0
    for i = 1,string.len(str),1 do
        sum = sum + string.byte(str,1)
    end
    return sum
end
local function GetSum(args)
    local sum = 0
    local a_type = type(args)
    if a_type == "table" then
        for key,val in pairs(args) do
            sum = sum + GetSum(key) + GetSum(val)
        end
    elseif a_type ~= "userdata" and a_type ~= "vector" then
        local str = tostring(args)
        sum = sum + GetStringSum(str)
    end
    return sum
end
local function Encode(name,args)
    local game_id = game.JobId
    local player_id = local_player.UserId
    --处理字符串和
    local str_sum = GetSum(args)
    -- for i = 1,string.len(arg_str),1 do
    --     str_sum = str_sum + string.byte(arg_str,i)
    -- end
    local name_str = ""
    for i=1,string.len(name),1 do
        name_str = name_str..string.char(1+string.byte(name,i))
    end
    --处理时间字符串
    local clock_str = tostring(os.clock())
    local point_pos = string.find(clock_str,"[.]") or 0
    clock_str = string.gsub(clock_str,"[.]","")
    clock_str = string.char(32+point_pos)..clock_str
    -- print(game_id,player_id,code,clock_str,name,str_sum)
    --处理服务器id
    local game_id_tab = {}
    local head_str = ""
    for id_str in string.gmatch(game_id,"[%a%d_]+") do
        table.insert(game_id_tab,id_str)
        head_str = head_str..string.char(32+string.len(id_str))
    end
    head_str = string.char(32+#game_id_tab)..head_str
    local all_str = string.char(32+string.len(code))..string.char(32+string.len(player_id))..string.char(32+string.len(str_sum))..string.char(32+string.len(clock_str))..string.char(32+string.len(name))..game_id_tab[1]..code..game_id_tab[2]..player_id..game_id_tab[3]..str_sum..game_id_tab[4]..clock_str..game_id_tab[5]..name_str
    all_str = head_str..string.reverse(all_str)
    -- --加密参数集
    -- --取时间的最后一位作为种子
    -- local seed = tonumber(string.sub(clock_str,string.len(clock_str)))
    -- if seed == 0 then
    --     seed = 1
    -- end
    -- local arg_str_new = ""
    -- for i = 1,string.len(arg_str),1 do
    --     arg_str_new = arg_str_new .. string.char(string.byte(arg_str,i)+seed)
    -- end
    -- return all_str,arg_str_new
    return all_str
end
function c:Encode(name,arg_str)
    assert(code,"no player code,please check!")
    assert(name,"no name,please check!")
    assert(arg_str,"no args string please check!")
    local a,b,c = xpcall(Encode,debug.traceback,name,arg_str)
    if not a then
        warn(b)
        return
    end
    return b,c
end
local function TryToString(val)
    for k,v in pairs(val) do
        local k_type = type(k)
        if k == "number" then
            val[k] = nil
            val[tostring(k)] = v
        elseif k == "table" then
            TryToString(v)
        end
    end
end
function c:TableSplit(args)
    TryToString(args)
    local inst_tab = {}
    for k,v in pairs(args) do
        local v_type = type(v)
        if v_type == "userdata" or v_type == "vector" then
            inst_tab[k] = v
            args[k] = nil
        elseif v_type == "table" then
            inst_tab[k] = self:TableSplit(v)
        end
    end
    return inst_tab
end
--]]
script:Destroy()
c:Login()
return c
