local _shared = shared
local script = script
local xpcall  = xpcall
local require = require
local game    = game
local debug   = debug
local wait    = wait
local warn    = warn 
local plugin  = plugin
local DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo
local Enum = Enum
local utf8 = utf8

local config = _shared.PluginConfig
---@class BaseGui
local c = _shared.Class.new(script)
function c.new()
    return c()
end
function c:ctor()
end

return c