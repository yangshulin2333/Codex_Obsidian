local warn = warn
local xpcall = xpcall
local debug = debug
local require = require
local game = game
local wait = wait
local _G = _G
local function LoadFrame(frame_type)
    local r,e
    while not r do
        r,e = xpcall(function()
            return require(game:GetService("ReplicatedStorage"):WaitForChild("Hotpot",10):WaitForChild(frame_type,10):WaitForChild(frame_type.."Hotpot",10))
        end,debug.traceback)
        if not r then
            warn(e)
            wait()
        end
    end
    return e
end
---@type CommonHotpot
local CommonHotpot = LoadFrame("Common")
---@type ClientHotpot
local ClientHotpot = LoadFrame("Client")
-------------
---@type GameClient
local client = ClientHotpot.load.GameClient().new()
client:Start()