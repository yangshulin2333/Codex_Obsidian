local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local weather_cfg = hotpot.config.Weather
local total = 0
for k,v in ipairs(weather_cfg)do
    total = total + v.weight
end

---@class Client_WeatherComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self:InitUi()
end

function c:InitUi()
    for k,v in ipairs(weather_cfg)do
        ui_manager.ui_list.hud_gui:AddItemInWeather(
            v.icon,
            v.weight / total * 100,
            v.name
        )
    end
end

function c:Update(cd,is_weather,id)
    if not self.start then
        if is_weather then
            self:StartWeather(id)
        end
    end
    ui_manager.ui_list.hud_gui:SetWeatherCD(cd)
end

function c:StartWeather(id)
    self.start = true
    ui_manager.ui_list.hud_gui:SetWeatherBtnIcon(weather_cfg[id].icon,1)
    if weather_cfg[id].is_big then
        ui_manager.ui_list.hud_gui:SetWeatherHPIcon(weather_cfg[id].icon)
        ui_manager.ui_list.hud_gui:SetWeatherHPName(weather_cfg[id].name)
        local hp = weather_cfg[id].hp
        ui_manager.ui_list.hud_gui:SetWeatherHPProgress(hp,hp)
        ui_manager.ui_list.hud_gui:SetWeatherHPVisible(true)

        ui_manager.ui_list.hud_gui:RemoveAllWeatherItem()
        local reward = weather_cfg[id].reward
        local rId = reward[2]
        local cfg = hotpot.config.relics_gacha[rId]
        ui_manager.ui_list.hud_gui:AddItemInWeatherRewards(cfg.icon,cfg.quality)
    end
end

function c:StopWeather()
    self.start = false
    ui_manager.ui_list.hud_gui:SetWeatherHPVisible(false)
    ui_manager.ui_list.hud_gui:SetWeatherBtnIcon('rbxassetid://132388050267081',1.5)
end

c:RegistEvent('weatherUpdate',c.Update)
c:RegistEvent('weatherStart',c.StartWeather)
c:RegistEvent('weatherEnd',c.StopWeather)

return c

