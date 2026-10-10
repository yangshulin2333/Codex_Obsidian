local hotpot = _G.ClientHotpot

local str = 'You were killed by <font color="rgb(255,0,0)">%s</font>.'
local revengeStr = 'You were killed by <font color="rgb(255,0,0)">%s</font> in a revenge attack.'
local normal = 'You are already dead. Click "Reborn" to be resurrected at the birth point.'

---@class DieGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type TextLabel		
	c.insts.info = 'Frame.bg.info'    
    ---@type ImageButton		
	c.insts.revenge = 'Frame.bg.revenge'    
    ---@type ImageButton		
	c.insts.reborn = 'Frame.bg.reborn'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.DieGui',_G.Resource)
    c.super.ctor(self,ui)
end

function c:SetName(name)
    self.insts.info.Text = string.format(str,name)
end

function c:SetRevengeName(name)
    self.insts.info.Text = string.format(revengeStr,name)
end

function c:SetNormal()
    self.insts.info.Text = normal
end

function c:SetRevengeBtnVisible(vis)
    vis = false
    self.insts.revenge.Visible = vis
    if vis then
        self.insts.reborn.Position = UDim2.fromScale(0.7,0.89)
    else
        self.insts.reborn.Position = UDim2.fromScale(0.5,0.89)
    end
end

function c:BindRevengeBtnClickHandle(obj,func)
    self.insts.revenge.MouseButton1Click:Connect(function()
        func(obj)
    end)
end

function c:BindRebornBtnClickHandle(obj,func)
    self.insts.reborn.MouseButton1Click:Connect(function()
        func(obj)
    end)
end

return c