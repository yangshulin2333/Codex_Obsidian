local hotpot = _G.ServerHotpot
---@type PlaceManager
local PlaceManager = hotpot.load.PlaceManager()
---@type TeleportService
local TeleportService = game:GetService("TeleportService")

---@class Server_ReconnectComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)
end

function c:Teleport()
    -- print('teleport')

    local data = {}
    local place_id = game.PlaceId
    if place_id == 112733956767862 or place_id == 140209136165491 then
        local stage = self.parent.now_stage.id
        local cf = self.parent.character:GetCFrame()
        data.stage = stage
        data.cf = cf
        data.types = 'reconnect'
    end

    local teleport_option = Instance.new('TeleportOptions')
    teleport_option.ShouldReserveServer = true
    teleport_option:SetTeleportData(data)

    TeleportService:TeleportAsync(140209136165491,{self.parent.main_inst},teleport_option)
    -- print('teleport')
end

c:RegistEvent('teleport_reconnect',c.Teleport)

return c