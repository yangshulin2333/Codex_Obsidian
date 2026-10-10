local setmetatable = setmetatable
local xpcall = xpcall
local require = require
local game = game
local warn = warn
local _G = _G
local function GetFrame()
    local r,e = xpcall(function()
        return require(game:GetService("ReplicatedStorage"):WaitForChild("Hotpot",10):WaitForChild("HotpotFrame",10))
    end,debug.traceback)
    if not r then
        warn(e)
        return GetFrame()
    end
    return e
end
---@type HotpotFrame
local HotpotFrame = GetFrame()
---@class CommonHotpot:HotpotFrame
local c = setmetatable({},{__index=HotpotFrame})
_G.CommonHotpot = c
local file_list = require(c:GetPath_Loop("ReplicatedStorage._FileData.CommonFileList",game))
---@type CommonFileList
c.files = c:InitFiles(file_list)
---@type CommonFileList
c.load = c:InitLoads(file_list)
---@type Config
c.config = c:InitConfig()
c.class = c.load.Class()
---@type HotpotEnum
c.enum = c.load.HotpotEnum()
return c