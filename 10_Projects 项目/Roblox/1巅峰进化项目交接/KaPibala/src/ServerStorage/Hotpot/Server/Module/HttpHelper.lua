local game = game
local tonumber = tonumber
local type = type
local pairs = pairs
local Enum = Enum
local coroutine = coroutine
local tostring = tostring
local table = table
local assert = assert
local xpcall = xpcall
local debug = debug
local warn = warn
local os = os
local wait = wait
local MINUTE_LIMIT = 250
local LIMIT_CYCLE = 60
local OUT_TIME = 60
local QUOTA_STEP = LIMIT_CYCLE/MINUTE_LIMIT
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local url_list = {}
local game_id_list = {}
local now_env
local release_game_id
---@class HttpHelper
local c = {}
local time_mark = os.clock()
local action_list = {}
local server_info = {}
--定义本地函数
--@type fun() @更新函数
local Update
local IsLimit
local UseQuota
local GetSum
local InitServerInfo
local ConvertToSent
local ConvertToGet
function IsLimit()
    local now = os.clock()
    if now - time_mark < QUOTA_STEP then
        return
    end
    return true
end
function UseQuota()
    time_mark = time_mark + QUOTA_STEP
end
function GetSum(str)
    assert(str,"param str is nil")
    local sum = 0
    for i = 1,string.len(str),1 do
        sum = sum + string.byte(str,i)
    end
    return sum
end
function InitServerInfo()
    local job_id = tostring(game.JobId)
    local game_id = tostring(game.GameId)
    local place_id = tostring(game.PlaceId)
    server_info.key = tostring(GetSum(job_id) + GetSum(game_id) + GetSum(place_id))
    server_info.job_id = job_id
    server_info.game_id = game_id
    server_info.place_id = place_id
end
function ConvertToSent(val)
    if type(val) == "table" then
        local new_tab = {}
        for key,value in pairs(val) do
            if type(key) == "number" then
                new_tab[tostring(key)] = ConvertToSent(value)
            else
                new_tab[key] = ConvertToSent(value)
            end
        end
        return new_tab
    else
        return val
    end
end
function ConvertToGet(val)
    if type(val) == "table" then
        local new_tab = {}
        for key,value in pairs(val) do
            local new_key = tonumber(key) or key
            new_tab[new_key] = ConvertToGet(value)
        end
        return new_tab
    else
        return val
    end
end
--初始化server的基础key
InitServerInfo()
local action_handles = {}
action_handles.get = function(info)
    local url = info.url
    local nocache = info.nocache
    local headers = info.headers
    local co = info.co
    local response = HttpService:GetAsync(url,nocache,headers)
    -- coroutine.resume(co,response)
    return response
end
action_handles.pos = function(info)
    local url = info.url
    local data = info.data
    local content_type = info.content_type
    local compress = info.compress
    local headers = info.headers
    local co = info.co
    local response = HttpService:PostAsync(url,data,content_type,compress,headers)
    -- coroutine.resume(co,response)
    return response
end
action_handles.request = function(info)
    local request_options = info.request_options
    local co = info.co
    local respone = HttpService:RequestAsync(request_options)
    -- coroutine.resume(co,respone)
    return respone
end
local function DoHttp(handle,info)
    local r,e = xpcall(handle,debug.traceback,info)
    if not r then
        warn(e)
        coroutine.resume(info.co)
    else
        coroutine.resume(info.co,e)
    end
end
function Update()
    wait()
    while #action_list > 0 do
        if IsLimit() then
            --拿到执行信息
            local info = action_list[1]
            --拿到所有的信息
            local action_type = info.action_type
            local handle = action_handles[action_type]
            --执行
            local co = coroutine.create(DoHttp)
            coroutine.resume(co,handle,info)
            --更新队列
            table.remove(action_list,1)
            UseQuota()
            -- coroutine.resume(info.co,e)
        else
            warn("http queue is full! wait "..tostring(QUOTA_STEP).."s")
            wait(QUOTA_STEP)
        end
    end
    c.__update_co = nil
end
function c:BaseGet(url,nocache,header)
    assert(url,"param url is nil")
    nocache = nocache or false
    local info = {
        url = url,
        nocache = nocache,
        header = header,
        action_type = "get",
        co = coroutine.running()
    }
    table.insert(action_list,info)
    --尝试启动更新
    if not self.__update_co then
        self.__update_co = coroutine.create(Update)
        coroutine.resume(self.__update_co)
    end
    local response = coroutine.yield()
    wait()
    return response
end
function c:BasePost(url,data,content_type,compress,headers)
    assert(url,"param url is nil")
    assert(data,"param data is nil")
    content_type = content_type or Enum.HttpContentType.ApplicationJson
    compress = compress or false
    local info = {
        url = url,
        data = data,
        content_type = content_type,
        compress = compress,
        action_type = "post",
        co = coroutine.running()
    }
    table.insert(action_list,info)
    --尝试启动更新
    if not self.__update_co then
        self.__update_co = coroutine.create(Update)
        coroutine.resume(self.__update_co)
    end
    local response = coroutine.yield()
    wait()
    return response
end
function c:Request(request_options)
    assert(request_options,"param request option is nil")
    local info = {
        request_options = request_options,
        action_type = "request",
        co = coroutine.running()
    }
    table.insert(action_list,info)
    --尝试启动更新
    if not self.__update_co then
        self.__update_co = coroutine.create(Update)
        coroutine.resume(self.__update_co)
    end
    local response = coroutine.yield()
    wait()
    return response
end
function c:Sync(server_name,action,info)
    assert(server_name,"param server name is nil")
    assert(action,"param action is nil")
    local url = c:GetServerUrl(server_name)
    local body = info and HttpService:JSONEncode(ConvertToSent(info))
    local request_options = {
        Url = url.."/"..action,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            job = server_info.job_id,
            game = server_info.game_id,
            place= server_info.place_id,
            key = server_info.key,
        },
        Body = body,
    }
    --进行通讯
    local response = c:Request(request_options)
    if not response then
        return
    end
    if not response.Success then
        local error_str = "http "..response.StatusCode.."\n"
        error_str = error_str..response.StatusMessage.."\n"
        error_str = error_str..tostring(response.Body).."\n"
        warn(error_str)
        return
    end
    --检查结果
    response = response and ConvertToGet(HttpService:JSONDecode(response.Body))
    return response
end
function c:AddServer(server_name,normal_url,dev_url)
    assert(server_name,"param server name is nil")
    url_list[server_name] = {
        release = normal_url.."/"..server_name,
        dev = dev_url.."/"..server_name
    }
end
function c:GetServerUrl(server_name)
    assert(server_name,"param server name is nil")
    if not now_env then
        if RunService:IsStudio() then
            now_env = "dev"
        else
            local now_game_id = game.GameId
            if now_game_id == release_game_id then
                now_env = "release"
            else
                now_env = "dev"
            end
        end
    end
    local list = url_list[server_name]
    assert(list,"can't find server url named "..server_name)
    return list[now_env]
end
function c:SetReleaseGameId(game_id)
    release_game_id = game_id
end
return c