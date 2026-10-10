local hotpot = _G.ClientHotpot
---@type UserInputService
local UserInputService = game:GetService('UserInputService')
local CONNECT_TIME = 17*60

---@class Client_ReconnectComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.time = 0

    UserInputService.InputChanged:Connect(function()
        self.time = 0
    end)
    UserInputService.InputBegan:Connect(function()
		self.time = 0
	end)
	UserInputService.InputEnded:Connect(function()
		self.time = 0
	end)

    self:AddUpdate(self.Update,1)
end

function c:Update()
    self.time = self.time + 1
    -- print(self.time,CONNECT_TIME)
    if self.time >= CONNECT_TIME then
        self:Fire('teleport_reconnect')
        return true
    end
end

return c