local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)

local temp = {'I','II','III','IV','V'}

---@class RebornGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'    

    ---@type Frame		
	c.insts.unlockFrame = 'Frame.bg.unlockFrame' 
    ---@type TextLabel		
	c.insts.unlockFrame_need_lv = 'Frame.bg.unlockFrame.need_lv'   

    ---@type Frame		
	c.insts.list = 'Frame.bg.rebornFrame.list'    
    ---@type Frame		
	c.insts.rebornFrame = 'Frame.bg.rebornFrame'    
    ---@type Frame		
	c.insts.new_item = 'Frame.bg.rebornFrame.list.new_item'  
    ---@type ImageButton		
	c.insts.btn = 'Frame.bg.rebornFrame.btn'     
    ---@type Frame		
	c.insts.exp_item = 'Frame.bg.rebornFrame.list.exp_item'    
    ---@type Frame		
	c.insts.atk_item = 'Frame.bg.rebornFrame.list.atk_item'    

    ---@type Frame		
	c.insts.successFrame = 'successFrame'    
    ---@type Frame		
	c.insts.success_stars = 'successFrame.stars'    
    ---@type ImageLabel		
	c.insts.success_star = 'successFrame.stars.star'    
    ---@type Frame		
	c.insts.success_list = 'successFrame.bg.list'    
    ---@type TextLabel		
	c.insts.success_title = 'successFrame.title'    
    ---@type TextLabel		
	c.insts.success_desc = 'successFrame.desc'    
    ---@type Frame		
	c.insts.success_atk_item = 'successFrame.bg.list.atk_item'    
    ---@type Frame		
	c.insts.success_exp_item = 'successFrame.bg.list.exp_item'    
    ---@type Frame		
	c.insts.success_new_item = 'successFrame.bg.list.new_item'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.RebornGui',_G.Resource)
    c.super.ctor(self,ui)

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)
end

function c:Show()
    self.insts.Frame.Position = UDim2.fromScale(0.5,0.7)
    c.super.Show(self)
    ui_manager.ui_list.hud_gui:Hide()
    TweenHelper:PlayTween(
        self.insts.Frame,
        tweenInfo,
        {Position = UDim2.fromScale(0.5,0.5)}
    )
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

--设置未解锁界面的显示
function c:SetUnlockFrameVisible(vis)
    self.insts.unlockFrame.Visible = vis
end

--设置重生界面的显示
function c:SetRebornFrameVisible(vis)
    self.insts.rebornFrame.Visible = vis
end

--添加新项
function c:SetNewItem(vis,icon,title,desc)
    local ui = self.insts.new_item
    ui.Visible = vis
    if vis then
        ui.bg.icon.Image = icon
        ui.bg.title.Text = title
        ui.bg.desc.Text = desc
    end

    local s_ui = self.insts.success_new_item
    s_ui.Visible = vis
    if vis then
        s_ui.bg.icon.Image = icon
        s_ui.bg.title.Text = title
        s_ui.bg.desc.Text = desc
    end
end

--设置未解锁界面的等级
function c:SetUnlockFrameLv(lv)
    self.insts.unlockFrame_need_lv.Text = 'Need Lv:'..lv
end

--设置重生数值
function c:SetRebornValue(atk,exp)
    self.insts.atk_item.bg.desc.Text = string.format(
        "Your character's attack is permanently increased by %s%%",
        atk
    )
    self.insts.exp_item.bg.desc.Text = string.format(
        'Defeat monsters and gain x%s experience',
        exp
    )

    self.insts.success_atk_item.bg.desc.Text = string.format(
        "Your character's attack is permanently increased by %s%%",
        atk
    )
    self.insts.success_exp_item.bg.desc.Text = string.format(
        'Defeat monsters and gain x%s experience',
        exp
    )
end

--设置Frame的显示
function c:SetFrameVisible(vis)
    self.insts.Frame.Visible = vis
end

--设置成功界面的显示
function c:SetSuccessFrameVisible(vis)
    self.insts.successFrame.Visible = vis
end

--设置成功界面信息
function c:SetSuccessFrameInfo(title,mark,star)
    self.insts.success_title.Text = title
    self.insts.success_desc.Text = mark
    local ui = self.insts.success_stars
    for k,v in ipairs(ui:GetChildren()) do
        if not v:IsA('UIListLayout') then
            v:Destroy()
        end
    end

    for i = 1,star do
        self.insts.success_star:Clone().Parent = ui
    end
end

--绑定重生按钮点击事件
function c:BindRebornBtnClickHandle(obj,handle)
    self.insts.btn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c