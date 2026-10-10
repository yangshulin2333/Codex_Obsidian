local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)

---@class FreePetGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type Frame		
	c.insts.task1 = 'Frame.bg.task1'    
    ---@type Frame		
	c.insts.task2 = 'Frame.bg.task2'    
    ---@type ImageButton		
	c.insts.freeBtn = 'Frame.bg.freeBtn'    
    ---@type ImageButton		
	c.insts.buyBtn = 'Frame.bg.buyBtn'   
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'     
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.FreePetGui',_G.Resource)
    c.super.ctor(self,ui)

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)
end

function c:Show()
    self.insts.Frame.Position = UDim2.fromScale(0.5,0.7)
    c.super.Show(self)
    TweenHelper:PlayTween(
        self.insts.Frame,
        tweenInfo,
        {Position = UDim2.fromScale(0.5,0.5)}
    )
    ui_manager.ui_list.hud_gui:Hide()
end

function c:Hide()
    TweenHelper:PlayTween(
        self.insts.Frame,
        tweenInfo,
        {Position = UDim2.fromScale(0.5,0.7)},
        function()
            c.super.Hide(self)
        end
    )
    ui_manager.ui_list.hud_gui:Show()
end

function c:SetTask1Pro(now,need)
    self.insts.task1.proBg.proFg.Size = UDim2.fromScale(math.clamp(now/need,0,1),1)
    self.insts.task1.proBg.num.Text = now .. '/' .. need
end

function c:SetTask2Pro(now,need)
    self.insts.task2.proBg.proFg.Size = UDim2.fromScale(math.clamp(now/need,0,1),1)
    self.insts.task2.proBg.num.Text = now .. '/' .. need
end

function c:SetPrice(price,time_,icon)
    self.insts.buyBtn.TextLabel.Text = price
    self.insts.task1.TextLabel.Text = string.format('Play for %s Minutes!',time_)
    self.insts.bg.board.icon.Image = icon
    ui_manager.ui_list.hud_gui.insts.freePetBtn.ImageLabel.Image = icon
end

function c:BindFreeBtnClickHandle(obj,handle)
    self.insts.freeBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindBuyBtnClickHandle(obj,handle)
    self.insts.buyBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c