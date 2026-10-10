local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)

---@class PvpBuffGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type TextLabel		
	c.insts.title = 'Frame.bg.title'    
    ---@type TextLabel		
	c.insts.desc = 'Frame.bg.desc' 
    ---@type ImageButton		
	c.insts.free = 'Frame.bg.free'       
    ---@type ImageButton		
	c.insts.btn1 = 'Frame.bg.btn1'    
    ---@type ImageButton		
	c.insts.btn2 = 'Frame.bg.btn2'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.PvpBuffGui',_G.Resource)
    c.super.ctor(self,ui,true)
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

function c:SetTitle(title)
    self.insts.title.Text = title
end

function c:SetDesc(desc)
    self.insts.desc.Text = desc
end

function c:BindFreeBtnClickHandle(obj,handle)
    self.insts.free.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindBtn1ClickHandle(obj,handle)
    self.insts.btn1.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindBtn2ClickHandle(obj,handle)
    self.insts.btn2.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c

