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
---@class ServerHotpot:HotpotFrame
local c = setmetatable({},{__index=HotpotFrame})
_G.ServerHotpot = c
local file_list = require(c:GetPath_Loop("ServerStorage._FileData.ServerFileList",game))
---@type ServerFileList
c.files = c:InitFiles(file_list)
---@type ServerFileList
c.load = c:InitLoads(file_list)
---@type Config
c.config = c:InitConfig()
c.class = c.load.Class()
c.encryption_manager = c.load.EncryptionManager()
c.event_manager = c.load.ServerEventManager()
c.function_manager = c.load.ServerFunctionManager()
c.event_list = c.load.EventList()
c.function_list = c.load.FunctionList()
---@type HotpotEnum
c.enum = c.load.HotpotEnum()
---@type Folder
c.Resource = c:GetPath("ReplicatedStorage.Resource",game)
---@type ProjectConfig
c.pro_cfg = c.load.ProjectConfig()
return c