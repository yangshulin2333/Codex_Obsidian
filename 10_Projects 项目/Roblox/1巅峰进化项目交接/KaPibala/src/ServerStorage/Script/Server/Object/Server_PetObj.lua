local hotpot = _G.ServerHotpot
---@type CurveHelper
local CurveHelper = hotpot.load.CurveHelper()

local dir = Vector3.new(0,-5,0)

---@class Server_PetObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model,att)
    return c(model,att)
end
function c:ctor(model,att)
    c.super.ctor(self,model)

    ---@type Attachment
    self.att = att
    self.part = self.att.Parent
    local cf,size = self:GetBoundingBox()
    self.y = size.Y / 2

    self:SetCFrame(self.att.WorldCFrame)

end

return c