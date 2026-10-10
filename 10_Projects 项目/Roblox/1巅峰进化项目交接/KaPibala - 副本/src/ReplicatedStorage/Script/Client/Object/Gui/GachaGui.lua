local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local bigNumber = hotpot.load.BigNumberHelper()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()

local tweenInfo = TweenInfo.new(0.2)

---@class GachaGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'      

    ---@type ImageButton		
	c.insts.clickBtn = 'Frame.clickBtn'    

    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'   
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'    
    ---@type ImageLabel		
	c.insts.icon = 'Frame.bg.icon'    
    ---@type ImageButton		
	c.insts.luckyBtn = 'Frame.bg.luckyBtn'     
    ---@type ImageButton		
	c.insts.superluckyBtn = 'Frame.bg.superluckyBtn'   
    ---@type ImageButton		
	c.insts.autoBtn = 'Frame.bg.autoBtn'   
    ---@type ImageButton		
	c.insts.multipleBtn = 'Frame.bg.multipleBtn'     
    ---@type ImageButton		
	c.insts.btn1 = 'Frame.bg.bottom.btn1.btn'     
    ---@type TextLabel		
	c.insts.btn1_price = 'Frame.bg.bottom.btn1.price'    
    ---@type ImageButton		
	c.insts.btn3 = 'Frame.bg.bottom.btn3.btn'    
    ---@type TextLabel		
	c.insts.btn3_price = 'Frame.bg.bottom.btn3.price'    
    ---@type ImageButton		
	c.insts.stopBtn = 'Frame.stopBtn'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.GachaGui',_G.Resource)
    c.super.ctor(self,ui)
end

function c:SetBGVisible(vis)
    if vis then
        self:Show()
        self.insts.bg.Position = UDim2.fromScale(0.5,0.7)
        self.insts.bg.Visible = true
        TweenHelper:PlayTween(
            self.insts.bg,
            tweenInfo,
            {
                Position = UDim2.fromScale(0.5,0.5)
            }
        )
    else
        TweenHelper:PlayTween(
            self.insts.bg,
            tweenInfo,
            {
                Position = UDim2.fromScale(0.5,0.7)
            },
            function()
                self.insts.bg.Visible = false
            end
        )
    end
end

function c:SetBtn3Visible(vis)
    self.insts.btn3.Parent.Visible = vis
end

function c:SetBtnPrice(p1,p3)
    self.insts.btn1_price.Text = bigNumber:ToString(p1)
    self.insts.btn3_price.Text = bigNumber:ToString(p3)
end

function c:SetIcon(icon)
    self.insts.icon.Image = icon
end

function c:SetStopBtnVisible(vis)
    self.insts.stopBtn.Visible = vis
end

function c:SetLuckyOwnedVisible(vis)
    self.insts.luckyBtn.owned.Visible = vis
end

function c:SetSuperLuckyOwnedVisible(vis)
    self.insts.superluckyBtn.owned.Visible = vis
end

function c:SetAutoOwnedVisible(vis)
    self.insts.autoBtn.owned.Visible = vis
end

function c:SetMultipleOwnedVisible(vis)
    self.insts.multipleBtn.owned.Visible = vis
end

function c:SetMultipleBtnVisible(vis)
    self.insts.multipleBtn.Visible = vis
end

--绑定按钮点击事件
function c:BindBtnClickHandle(obj,handle)
    self.insts.clickBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindBgCloseBtnClickHandle(obj,handle)
    self.insts.closeBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindBtn1ClickHandle(obj,handle)
    self.insts.btn1.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindBtn3ClickHandle(obj,handle)
    self.insts.btn3.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindGamepassClickHandle(obj,handle)
    self.insts.luckyBtn.MouseButton1Click:Connect(function()
        handle(obj,56)
    end)
    self.insts.superluckyBtn.MouseButton1Click:Connect(function()
        handle(obj,57)
    end)
    self.insts.autoBtn.MouseButton1Click:Connect(function()
        handle(obj,54)
    end)
    self.insts.multipleBtn.MouseButton1Click:Connect(function()
        handle(obj,55)
    end)
end

function c:BindStopBtnClickHandle(obj,handle)
    self.insts.stopBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c