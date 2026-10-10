local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Players
local players = game:GetService('Players')
---@type Player
local player = players.LocalPlayer
---@type Mouse
local mouse = player:GetMouse()

local tweenInfo = TweenInfo.new(0.2)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class TransferGui:HotpotScreenBase
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
	c.insts.mainFrame = 'Frame.bg.mainFrame'    
    ---@type ImageButton		
	c.insts.btn = 'Frame.bg.mainFrame.btn'   
    ---@type ImageButton		
	c.insts.solt1 = 'Frame.bg.mainFrame.solt1'   
    ---@type ImageButton		
	c.insts.solt2 = 'Frame.bg.mainFrame.solt2'    
    ---@type TextLabel		
	c.insts.price = 'Frame.bg.mainFrame.btn.price'    
    
    ---@type Frame		
	c.insts.listFrame = 'Frame.bg.listFrame'      
    ---@type ScrollingFrame		
	c.insts.ScrollingFrame = 'Frame.bg.listFrame.ScrollingFrame'    
    ---@type Frame		
	c.insts.scrollitem = 'Frame.bg.listFrame.ScrollingFrame.item'  
    
    ---@type ImageLabel		
	c.insts.tipsFrame = 'Frame.bg.tipsFrame'  
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.TransferGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.item_list = {}

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

    self:SetMainFrameVisible(true)
    self:SetListFrameVisible(false)
    self:SetTipsFrameVisible(false)
    self:SetSolt1Info()
    self:SetSolt2Info()
end

--设置mainFrame是否可见
function c:SetMainFrameVisible(visible)
    self.insts.mainFrame.Visible = visible
end

function c:SetListFrameVisible(visible)
    self.insts.listFrame.Visible = visible
end

function c:SetPrice(price)
    self.insts.price.Text = price
    self.insts.price.Visible = price > 0
end

function c:AddItemInScroll(inst_id,icon,score,quality,big)
    local ui = hotpot:CloneInst_Loop(self.insts.scrollitem)
    ui.Name = inst_id
    ui.Visible = true
    ui.LayoutOrder = 100000 - score
    ui.Parent = self.insts.ScrollingFrame
    ui.btn.icon.Image = icon
    ui.btn.num.Text = score
    ui.btn.big.Text = '+'..big
    ui.btn.big.Visible = big > 0
    local color = qualityColor:FindFirstChild(tostring(quality))
    color:Clone().Parent = ui.btn
    color:Clone().Parent = ui.btn.UIStroke

    self.item_list[inst_id] = ui

    ui.btn.MouseEnter:Connect(function()
        if self.__item_mouse_enter_handle and self.__item_mouse_enter_obj then
            self.__item_mouse_enter_handle(self.__item_mouse_enter_obj,inst_id)
        end
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    ui.btn.MouseLeave:Connect(function()
        self:SetTipsFrameVisible(false)
    end)
    ui.btn.MouseMoved:Connect(function()
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    ui.btn.MouseButton1Click:Connect(function()
        if self.__item_click_handle and self.__item_click_obj then
            self.__item_click_handle(self.__item_click_obj,inst_id)
        end
    end)
end

function c:SetItemVisible(inst_id,visible)
    local ui = self.item_list[inst_id]
    if ui then
        ui.Visible = visible
    end
end

function c:SetItemBig(inst_id,big)
    local ui = self.item_list[inst_id]
    if ui then
        ui.btn.big.Text = '+'..big
        ui.btn.big.Visible = big > 0
    end
end

function c:DelItemInScroll(inst_id)
    local ui = self.item_list[inst_id]
    if ui then
        ui:Destroy()
        self.item_list[inst_id] = nil
    end
end

--设置tipsFrame是否可见
function c:SetTipsFrameVisible(visible)
    self.insts.tipsFrame.Visible = visible
end

--设置tipsInfo
function c:SetTipsInfo(name,list,quality,big,small)
    local len = #list
    self.insts.tipsFrame.name.Text = name

    for i = 1,7 do
        local color = self.insts.tipsFrame.name:FindFirstChild(tostring(i))
        color.Enabled = i == quality
    end

    local ui
    for i = 1,4 do
        ui = self.insts.tipsFrame:FindFirstChild(tostring(i))
        ui.Visible = i == len
    end

    ui = self.insts.tipsFrame:FindFirstChild(tostring(len))

    for k,v in ipairs(list)do
        local TextLabel = ui:FindFirstChild('info'..k)
        if TextLabel then
            TextLabel.Text = v
        end
    end

    local bigUi = self.insts.tipsFrame.big
    local smallUi = self.insts.tipsFrame.small
    for i = 1,10 do
        local icon = bigUi:FindFirstChild(tostring(i))
        icon.ImageColor3 = (big >= i) and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
    end
    for i = 1,10 do
        local icon = smallUi:FindFirstChild(tostring(i))
        icon.ImageColor3 = (small >= i) and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
    end
end

function c:SetSolt1Info(icon,quality,big)
    local c1 = self.insts.solt1:FindFirstChildOfClass('UIGradient')
        if c1 then
            c1:Destroy()
        end
    local c2 = self.insts.solt1.UIStroke:FindFirstChildOfClass('UIGradient')
    if c2 then
        c2:Destroy()
    end
    if icon then
        self.insts.solt1.icon.Image = icon
        self.insts.solt1.big.Text = '+'..big
        self.insts.solt1.big.Visible = big > 0
        local color = qualityColor:FindFirstChild(tostring(quality))
        color:Clone().Parent = self.insts.solt1
        color:Clone().Parent = self.insts.solt1.UIStroke
        self.insts.solt1.add.Visible = false
    else
        local color = qualityColor:FindFirstChild('1')
        color:Clone().Parent = self.insts.solt1
        color:Clone().Parent = self.insts.solt1.UIStroke
        self.insts.solt1.icon.Image = ''
        self.insts.solt1.big.Visible = false
        self.insts.solt1.add.Visible = true
    end
end

function c:SetSolt2Info(icon,quality)
    local c1 = self.insts.solt2:FindFirstChildOfClass('UIGradient')
        if c1 then
            c1:Destroy()
        end
    local c2 = self.insts.solt2.UIStroke:FindFirstChildOfClass('UIGradient')
    if c2 then
        c2:Destroy()
    end
    if icon then
        self.insts.solt2.icon.Image = icon
        local color = qualityColor:FindFirstChild(tostring(quality))
        color:Clone().Parent = self.insts.solt2
        color:Clone().Parent = self.insts.solt2.UIStroke
        self.insts.solt2.add.Visible = false
    else
        local color = qualityColor:FindFirstChild('1')
        color:Clone().Parent = self.insts.solt2
        color:Clone().Parent = self.insts.solt2.UIStroke
        self.insts.solt2.icon.Image = ''
        self.insts.solt2.add.Visible = true
    end
end

function c:BindSolt1ClickHandle(obj,handle)
    self.insts.solt1.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindSolt2ClickHandle(obj,handle)
    self.insts.solt2.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindTransferClickHandle(obj,handle)
    self.insts.btn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindItemClickHandle(obj,handle)
    self.__item_click_handle = handle
    self.__item_click_obj = obj
end

function c:MouseEnterItem(obj,handle)
    self.__item_mouse_enter_handle = handle
    self.__item_mouse_enter_obj = obj
end

return c