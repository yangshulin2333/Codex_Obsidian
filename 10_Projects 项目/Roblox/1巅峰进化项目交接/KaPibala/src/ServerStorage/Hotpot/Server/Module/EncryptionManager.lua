local _G = _G
local script = script
local workspace = workspace
local string = string
local table = table
local tonumber = tonumber
local assert = assert
local os = os
local ipairs = ipairs
local pairs = pairs
local coroutine = coroutine
local xpcall = xpcall
local debug = debug
local warn = warn
local tostring = tostring
local wait = wait
local type = type
local hotpot = _G.ServerHotpot
---@class EncryptionManager
local c = hotpot.class.new(script)
---@type RemoteFunction
local login_function = hotpot:GetPath_Check("ReplicatedStorage.LoginFunction")
local player_marks = {}
local player_codes = {}
local kick_list = {}
function c:PlayerLogin(player_inst)
    local code = hotpot:Random(0, 999999)
    player_codes[player_inst] = code
    player_marks[player_inst] = {}
    return code
end
function c:PlayerLogout(player_inst)
    player_codes[player_inst] = nil
    player_marks[player_inst] = nil
end
login_function.OnServerInvoke = function(player, ...)
    return c:PlayerLogin(player)
end
--新的函数，用于取代以前的GetSum
local function GetReceiveTabAndSum(tab)
    local new_tab = {}
    local sum = 0
    for k, v in pairs(tab) do
        k = tonumber(k) or k
        local v_type = type(v)
        if v_type == "table" then
            local t, s = GetReceiveTabAndSum(v)
            new_tab[k] = t
            sum = sum + s
        else
            if v_type == "number" then
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
local function Decode(key, args)
    -- 解码
    local random_key = string.byte(key, 1) - 32
    local len = string.byte(key, 2) - 31 - random_key
    local key_offset = string.sub(key, 3, string.len(key))
    local key_str = ""
    for i = 1, string.len(key_offset), 1 do
        key_str = key_str .. string.char(string.byte(key_offset, i) - random_key - i)
    end
    local clock = string.sub(key_str, 1, len)
    local sum_check = tonumber(string.sub(key_str, len + 1, string.len(key_str)))
    local new_tab, sum = GetReceiveTabAndSum(args)
    -- 转换表
    return new_tab, clock, sum, sum_check
end
---@param player_inst Player
---@param args any
---@param key any
function c:Decode(player_inst, key, args)
    assert(key, "param key is nil")
    assert(args, "param arge is nil")
    local code = player_codes[player_inst]
    if not code then
        return false, "no player code id = " .. player_inst.UserId
    end
    local result, new_tab, clock, sum, sum_check = xpcall(Decode, debug.traceback, key, args)
    -- 进行比对
    if not result then
        return false, "error on decode" .. "\n" .. new_tab
    end
    -- 包体检查
    if sum + code ~= sum_check then
        return false, "sum check faild"
    end
    if player_marks[player_inst][clock] then
        return false, "the key is marked"
    end
    self:MarkClock(player_inst,clock)
    return true, new_tab
end
function c:MarkClock(player_inst, clock)
    player_marks[player_inst][clock] = os.clock()
end
---@param player Player
---@param str string
function c:KickPlayerDelay(player, event_name,str)
    if kick_list[player] then
        return
    end
    kick_list[player] = true
    local delay = 10 + hotpot:Random() * 50
    local co = coroutine.create(function()
        wait(delay)
        kick_list[player] = nil
        if player.Parent then
            player:Kick("unkown error!please login again or contact us in the group")
        end
    end)
    coroutine.resume(co)
    -- local eo = coroutine.create(function()
    error("event name = "..tostring(event_name)..","..tostring(str) .. ",kick in " .. delay)
    -- end)
    -- coroutine.resume(eo)
end
local function Update()
    while true do
        local count = 0
        for player_inst, marks in pairs(player_marks) do
            for mark, clock in pairs(marks) do
                if os.clock() - clock > 36000 then
                    marks[mark] = nil
                end
                count = count + 1
                if count > 100 then
                    wait()
                end
            end
        end
        wait(1)
    end
end
local f = coroutine.wrap(Update)
f()
return c
