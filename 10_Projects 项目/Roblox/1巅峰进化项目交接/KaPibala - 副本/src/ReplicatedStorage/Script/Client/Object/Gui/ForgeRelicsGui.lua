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

---@class ForgeRelicsGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'    
    ---@type ImageLabel		
	c.insts.left = 'Frame.bg.left'    
    ---@type ImageButton		
	c.insts.left_rBtn = 'Frame.bg.left.rBtn'    
    ---@type ImageButton		
	c.insts.left_sBtn = 'Frame.bg.left.sBtn'     
    ---@type ImageButton		
	c.insts.left_forge_btn = 'Frame.bg.left.btn'    
    ---@type ScrollingFrame		
	c.insts.RelicsScrollingFrame = 'Frame.bg.RelicsScrollingFrame'   
    ---@type Frame		
	c.insts.Relics_item = 'Frame.bg.RelicsScrollingFrame.item'     
    ---@type ScrollingFrame		
	c.insts.ScrollsScrollingFrame = 'Frame.bg.ScrollsScrollingFrame'  
    ---@type Frame		
	c.insts.Scrolls_item = 'Frame.bg.ScrollsScrollingFrame.item'    
    ---@type ImageButton		
	c.insts.RelicsBtn = 'Frame.bg.RelicsBtn'   
    ---@type ImageButton		
	c.insts.ScrollBtn = 'Frame.bg.ScrollBtn'       

    ---@type ImageLabel		
	c.insts.left_top = 'Frame.bg.left.top'    
    ---@type ImageButton		
	c.insts.left_top_cancelBtn = 'Frame.bg.left.top.cancelBtn'    
    ---@type ImageButton		
	c.insts.left_top_sureBtn = 'Frame.bg.left.top.sureBtn'    

    ---@type ImageLabel		
	c.insts.tipsFrame = 'Frame.bg.tipsFrame'  
    ---@type ImageLabel		
	c.insts.tips1Frame = 'Frame.bg.tips1Frame'  
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.ForgeRelicsGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.relics_item = {}
    self.scroll_item = {}

    self.insts.RelicsBtn.MouseButton1Click:Connect(function()
        self:SetRelicsScrollingFrameVisible(true)
        self:SetScrollsScrollingFrameVisible(false)
    end)
    self.insts.ScrollBtn.MouseButton1Click:Connect(function()
        self:SetRelicsScrollingFrameVisible(false)
        self:SetScrollsScrollingFrameVisible(true)
    end)

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    self.insts.left_top_cancelBtn.MouseButton1Click:Connect(function()
        self:SetLeftTopVisible(false)
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

    if self.__hide_obj and self.__hide_handle then
        self.__hide_handle(self.__hide_obj)
    end

    self:SetLeftTopVisible(false)
    self:SetTipsFrameVisible(false)
    self:SetTips1FrameVisible(false)
end

--设置tipsFrame是否可见
function c:SetTipsFrameVisible(visible)
    self.insts.tipsFrame.Visible = visible
end

--设置tipsInfo
function c:SetTipsInfo(name,list,quality)
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
end

--设置tipsFrame是否可见
function c:SetTips1FrameVisible(visible)
    self.insts.tips1Frame.Visible = visible
end

--设置tipsInfo
function c:SetTips1Info(name,desc)
    self.insts.tips1Frame.name.Text = name
    self.insts.tips1Frame.desc.Text = desc
end

function c:SetRelicsScrollingFrameVisible(visible)
    self.insts.RelicsScrollingFrame.Visible = visible
end

function c:SetScrollsScrollingFrameVisible(visible)
    self.insts.ScrollsScrollingFrame.Visible = visible
end

function c:AddItemInRelics(inst_id,icon,score,quality)
    local ui = hotpot:CloneInst_Loop(self.insts.Relics_item)
    ui.Parent = self.insts.RelicsScrollingFrame
    ui.Visible = true
    ui.Name = inst_id
    ui.LayoutOrder = -score
    ui.btn.icon.Image = icon
    ui.btn.num.Text = score
    local color = qualityColor:FindFirstChild(quality)
    if color then
        color:Clone().Parent = ui.btn
        color:Clone().Parent = ui.btn.UIStroke
    end
    self.relics_item[inst_id] = ui
    ui.btn.MouseButton1Click:Connect(function()
        if self.__relics_item_handle then
            self.__relics_item_handle(self.__relics_item_obj,inst_id)
        end
    end)
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
end

function c:DelItem(inst_id)
    local ui = self.relics_item[inst_id]
    if ui then
        ui:Destroy()
        self.relics_item[inst_id] = nil
    end
end

function c:SetRelicsItemVisible(inst_id,vis)
    local ui = self.relics_item[inst_id]
    if ui then
        ui.Visible = vis
    end
end

function c:SetItemScore(inst_id,score)
    local ui = self.relics_item[inst_id]
    if ui then
        ui.btn.num.Text = score
        ui.LayoutOrder = -score
    end
end

function c:AddItemInScrolls(scroll_id,icon,quality)
    local ui = hotpot:CloneInst_Loop(self.insts.Scrolls_item)
    ui.Parent = self.insts.ScrollsScrollingFrame
    ui.Visible = true
    ui.Name = scroll_id
    ui.btn.icon.Image = icon
    local color = qualityColor:FindFirstChild(quality)
    if color then
        color:Clone().Parent = ui.btn
        color:Clone().Parent = ui.btn.UIStroke
    end
    self.scroll_item[scroll_id] = ui
    ui.btn.MouseButton1Click:Connect(function()
        if self.__scrolls_item_handle then
            self.__scrolls_item_handle(self.__scrolls_item_obj,scroll_id)
        end
    end)
    ui.btn.MouseEnter:Connect(function()
        if self.__scrolls_mouse_enter_handle and self.__scrolls_mouse_enter_obj then
            self.__scrolls_mouse_enter_handle(self.__scrolls_mouse_enter_obj,scroll_id)
        end
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.tips1Frame.Position = UDim2.fromScale(x,y)
    end)
    ui.btn.MouseLeave:Connect(function()
        self:SetTips1FrameVisible(false)
    end)
    ui.btn.MouseMoved:Connect(function()
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.tips1Frame.Position = UDim2.fromScale(x,y)
    end)
end

function c:SetScrollsItemVisible(scroll_id,vis)
    local ui = self.scroll_item[scroll_id]
    if ui then
        ui.Visible = vis
    end
end

function c:SetScrollsItemNum(scroll_id,num)
    local ui = self.scroll_item[scroll_id]
    if ui then
        ui.btn.num.Text = 'x'..num
    end
end

function c:SetLeftRelicsInfo(icon,quality)
    local ui = self.insts.left_rBtn
    local color = ui.board:FindFirstChildOfClass('UIGradient')
    if color then
        color:Destroy()
        color = nil
    end
    color = ui.UIStroke:FindFirstChildOfClass('UIGradient')
    if color then
        color:Destroy()
        color = nil
    end

    ui.add.Visible = false
    ui.icon.Image = icon
    color = qualityColor:FindFirstChild(quality)
    if color then
        color:Clone().Parent = ui.board
        color:Clone().Parent = ui.UIStroke
    end
end

function c:SetLeftScrollsInfo(icon,quality)
    local ui = self.insts.left_sBtn
    local color = ui.board:FindFirstChildOfClass('UIGradient')
    if color then
        color:Destroy()
        color = nil
    end
    color = ui.UIStroke:FindFirstChildOfClass('UIGradient')
    if color then
        color:Destroy()
        color = nil
    end

    ui.add.Visible = false
    ui.icon.Image = icon
    color = qualityColor:FindFirstChild(quality)
    if color then
        color:Clone().Parent = ui.board
        color:Clone().Parent = ui.UIStroke
    end
end

function c:ClearLeftRelicsInfo()
    local ui = self.insts.left_rBtn
    ui.add.Visible = true
    ui.icon.Image = ''
    local color = ui.board:FindFirstChildOfClass('UIGradient')
    if color then
        color:Destroy()
        color = nil
    end
    color = ui.UIStroke:FindFirstChildOfClass('UIGradient')
    if color then
        color:Destroy()
        color = nil
    end
end

function c:ClearLeftScrollsInfo()
    local ui = self.insts.left_sBtn
    ui.add.Visible = true
    ui.icon.Image = ''
    local color = ui.board:FindFirstChildOfClass('UIGradient')
    if color then
        color:Destroy()
        color = nil
    end
    color = ui.UIStroke:FindFirstChildOfClass('UIGradient')
    if color then
        color:Destroy()
        color = nil
    end
end

function c:SetLeftTopVisible(vis)
    self.insts.left_top.Visible = vis
end

function c:BindAddRelicsBtnClickHandle(obj,handle)
    self.insts.left_rBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindAddScrollsBtnClickHandle(obj,handle)
    self.insts.left_sBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindRelicsItemClickHandle(obj,handle)
    self.__relics_item_handle = handle
    self.__relics_item_obj = obj
end

function c:BindScrollsItemClickHandle(obj,handle)
    self.__scrolls_item_handle = handle
    self.__scrolls_item_obj = obj
end

function c:BindForgeBtnClickHandle(obj,handle)
    self.insts.left_forge_btn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindSureBtnClickHandle(obj,handle)
    self.insts.left_top_sureBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindCloseUiHandle(obj,handle)
    self.__hide_obj = obj
    self.__hide_handle = handle
end

function c:BindItemMouseEnter(obj,handle)
    self.__item_mouse_enter_handle = handle
    self.__item_mouse_enter_obj = obj
end

function c:BindScrollMouseEnter(obj,handle)
    self.__scrolls_mouse_enter_handle = handle
    self.__scrolls_mouse_enter_obj = obj
end

return c
