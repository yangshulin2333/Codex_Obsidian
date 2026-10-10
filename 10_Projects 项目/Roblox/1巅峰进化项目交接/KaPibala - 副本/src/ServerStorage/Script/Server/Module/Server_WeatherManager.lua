local hotpot = _G.ServerHotpot

local START = 1761957000
local INTERVAL = 7200
local RUNTIME = 300
local BOSSRUNTIME = 900
local weatherUpdate = 'weatherUpdate'

local weather_cfg = hotpot.config.Weather
local total = 0
for k,v in ipairs(weather_cfg)do
    total = total + v.weight
end

---@class Server_WeatherManager:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new()
    return c()
end
function c:ctor()
    c.super.ctor(self)

    self.state = 1
    self.time = 0
    self.weather = false

    self:AddUpdate(self.Update,1)
end

function c:StartWeather()
    if self.weather then
        return
    end
    self.weather = true
    local num = math.random(1,total)    
    local id = 0
    for k,v in ipairs(weather_cfg)do
        num = num - v.weight
        if num <= 0 then
            id = v.id
            break
        end
    end
    if not id then
        id = weather_cfg[1].id
    end
    self.id = id

    ---@type GameServer
    local server = _G.server
    ---@type Server_StageManager
    local stage_mgr = server.stage_manager
    for k,v in pairs(stage_mgr.stage_list)do
        if k ~= 'christmas' or k ~= 'base' then
            local r,e = pcall(function()
                if v.StartRefreshRandomMonster then
                    v:StartRefreshRandomMonster(id)
                end
            end)
            if not r then
                warn(e)
            end
        end
    end

    if weather_cfg[id].is_big then
        self.time = BOSSRUNTIME
    else
        self.time = RUNTIME
    end
    self:StartRun()
end

function c:StopWeather()
    self:StopRun()
    self.id = nil
    ---@type GameServer
    local server = _G.server
    ---@type Server_StageManager
    local stage_mgr = server.stage_manager
    for k,v in pairs(stage_mgr.stage_list)do
        local r,e = pcall(function()
            if v.StopRefreshRandomMonster then
                v:StopRefreshRandomMonster()
            end
        end)
        if not r then
            warn(e)
        end
    end
    hotpot.event_manager:FireAll('weatherEnd')

    self.weather = false
end

function c:IsWeatherMonster()
    if not self.weather then
        return
    end
    if not self.id then
        return
    end
    local cfg = weather_cfg[self.id]
    if not cfg then
        return
    end
    local num = math.random(1,100)
    if num <= cfg.per then
        return true,cfg.id
    end
    return false
end

function c:Update()
    local now = os.time()
    local time_ = now - START
    time_ = time_ % INTERVAL
    local cd = INTERVAL - time_
    if cd == INTERVAL then
        self:StartWeather()
    end
    if not self.run_co then
        hotpot.event_manager:FireAll(weatherUpdate,cd,false,self.id)
    end
end

function c:BossDie()
    self.state = 1
    self:StopWeather()
end

function c:StartRun()
    if self.run_co then
        return
    end
    self.run_co = self:AddUpdate(self.Run,1)
end

function c:StopRun()
    if self.run_co then
        self.run_co:Disconnect()
        self.run_co = nil
    end
end

function c:Run()
    self.time = self.time - 1
    hotpot.event_manager:FireAll(weatherUpdate,self.time,true,self.id)
    if self.time <= 0 then
        self:StopWeather()
    end
end

return c