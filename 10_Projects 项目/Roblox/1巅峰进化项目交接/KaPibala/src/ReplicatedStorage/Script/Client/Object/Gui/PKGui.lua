local hotpot = _G.ClientHotpot

---@class PKGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type TextLabel		
	c.insts.cd = 'Frame.cd'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.PKGui',_G.Resource)
    c.super.ctor(self,ui)
end

function c:SetCD(cd)
    self.insts.cd.Text = string.format('PK countdown: %ss',cd)
    if cd <= 0 then
        self.insts.cd.Text = ''
    end
end

return c