local warn = warn
local xpcall = xpcall
local debug = debug
local require = require
local game = game
local wait = wait
local function LoadFrame(frame_type)
    local str
    if frame_type == "Server" then
        str = "ServerStorage"
    else
        str = "ReplicatedStorage"
    end
    local r,e
    while not r do
        r,e = xpcall(function()
            return require(game:GetService(str):WaitForChild("Hotpot",10):WaitForChild(frame_type,10):WaitForChild(frame_type.."Hotpot",10))
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
---@type ServerHotpot
local ServerHotpot = LoadFrame("Server")
local r,e = xpcall(function()
    local server = ServerHotpot.load.GameServer().new()
    server:Start()
end,debug.traceback)
if not r then
    warn(e)
end
_G.GameAnalyticsServiceInit = CommonHotpot.load.GameAnalyticsServerInit()