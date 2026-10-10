local setmetatable = setmetatable
local xpcall = xpcall
local require = require
local game = game
local warn = warn
local _G = _G
local function GetFrame()
    local r, e =
        xpcall(
        function()
            return require(
                game:GetService("ReplicatedStorage"):WaitForChild("Hotpot", 10):WaitForChild("HotpotFrame", 10)
            )
        end,
        debug.traceback
    )
    if not r then
        warn(e)
        return GetFrame()
    end
    return e
end
---@type HotpotFrame
local HotpotFrame = GetFrame()
---@class ClientHotpot:HotpotFrame
local c = setmetatable({}, {__index = HotpotFrame})
_G.ClientHotpot = c
local file_list = require(c:GetPath_Loop("ReplicatedStorage._FileData.ClientFileList", game))
---@type ClientFileList
c.files = c:InitFiles(file_list)
---@type ClientFileList
c.load = c:InitLoads(file_list)
c.class = c.load.Class()

---@type Client_PlayerDataExHelper
c.player_dataex_helper = c.load.Client_PlayerDataExHelper()
---@type Config
c.config = c:InitConfig()
local config = HotpotFrame:GetPath_Loop("ReplicatedStorage.Config",game)
config.Parent = nil
c.event_manager = c.load.ClientEventManager()
c.function_manager = c.load.ClientFunctionManager()
c.event_trigger = c.load.ClientEventTriggerManager()
c.is_mobile = game:GetService("UserInputService").TouchEnabled
c.event_list = c.load.EventList()
c.function_list = c.load.FunctionList()
---@type HotpotEnum
c.enum = c.load.HotpotEnum()
---@type Folder
c.resource = c:GetPath("ReplicatedStorage.Resource", game)
---@type Folder
_G.Resource = c:GetPath_Loop("ReplicatedStorage.Resource")
---@type ProjectConfig
c.pro_cfg = c.load.ProjectConfig()
return c
