local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class ChallengeGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ScrollingFrame		
	c.insts.ScrollingFrame = 'Frame.bg.list.ScrollingFrame'    
    ---@type Frame		
	c.insts.item = 'Frame.bg.list.ScrollingFrame.item'    
    ---@type TextLabel		
	c.insts.stage = 'Frame.bg.stage'    
    ---@type ImageButton		
	c.insts.btn = 'Frame.btn'    
    ---@type TextLabel		
	c.insts.info = 'Frame.info'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.ChallengeGui',_G.Resource)
    c.super.ctor(self,ui)

    self.insts.btn.MouseButton1Click:Connect(function()
        hotpot.event_manager:Fire('partybackToLobby')
        while true do
            wait(.5)
            ui_manager.ui_list.tips_gui:TipsMessage('Teleport...','success')
        end
    end)
end

function c:SetBgVisible(vis)
    self.insts.bg.Visible = false
    -- self.insts.Frame.Transparency = vis and 0.7 or 1
end

function c:SetStageText(text)
    self.insts.info.Text = 'Pass Level: ' .. text
end

function c:AddItemInScroll(icon,num,quality)
    local ui = hotpot:CloneInst_Loop(self.insts.item)
    ui.Parent = self.insts.ScrollingFrame
    ui.Visible = true
    ui.bg.icon.Image = icon
    ui.bg.num.Text = 'x'..big_number:ToString(num)
    
    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        color:Clone().Parent = ui.bg
        color:Clone().Parent = ui.bg.UIStroke
    end
end

return c
