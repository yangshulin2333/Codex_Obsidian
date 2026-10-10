local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type BigNumberHelper
local BigNumberHelper = hotpot.load.BigNumberHelper()

local tweenInfo = TweenInfo.new(0.2)

---@class BuyPosionGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.close = 'Frame.bg.close'    
    ---@type ImageButton		
	c.insts.btn1 = 'Frame.bg.btn1'    
    ---@type ImageButton		
	c.insts.btn2 = 'Frame.bg.btn2'    
    ---@type ImageButton		
	c.insts.btn3 = 'Frame.bg.btn3'    

    ---@type TextLabel		
	c.insts.limit = 'Frame.bg.limit'   
    ---@type TextLabel		
	c.insts.cd = 'Frame.bg.cd'     
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.BuyPosionGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.insts.close.MouseButton1Click:Connect(function()
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

function c:SetLimited(num)
    self.insts.limit.Text = string.format('Limit: %d/4',num)
end

function c:SetCd(cd)
    self.insts.cd.Text = BigNumberHelper:TransformDateToString(cd)
end

function c:BindBtnClickHandle(obj,handle)
    self.insts.btn1.MouseButton1Click:Connect(function()
        handle(obj,1)
    end)
    -- self.insts.btn2.MouseButton1Click:Connect(function()
    --     handle(obj,2)
    -- end)
    -- self.insts.btn3.MouseButton1Click:Connect(function()
    --     handle(obj,3)
    -- end)
end

return c