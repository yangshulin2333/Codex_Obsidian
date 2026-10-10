local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type UIGradientHelper
local UIGradientHelper = hotpot.load.UIGradientHelper()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()

local tweenInfo = TweenInfo.new(0.2)

---@class TitleGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ScrollingFrame		
	c.insts.ScrollingFrame = 'Frame.bg.ScrollingFrame'    
    ---@type Frame		
	c.insts.scroll_item = 'Frame.bg.ScrollingFrame.item'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'    
    ---@type ImageLabel		
	c.insts.left = 'Frame.bg.left'    
    ---@type Frame		
	c.insts.left_list = 'Frame.bg.left.list'    
    ---@type Frame		
	c.insts.left_list_item = 'Frame.bg.left.list.item'    
    ---@type TextLabel		
	c.insts.activatedTxt = 'Frame.bg.left.activatedTxt'    
    ---@type ImageButton		
	c.insts.DeactivateBtn = 'Frame.bg.left.DeactivateBtn'    
    ---@type ImageButton		
	c.insts.ActivateBtn = 'Frame.bg.left.ActivateBtn'    
    ---@type ImageLabel		
	c.insts.right = 'Frame.bg.right'    
    ---@type ImageLabel		
	c.insts.right_icon = 'Frame.bg.right.icon'    
    ---@type TextLabel		
	c.insts.right_info = 'Frame.bg.right.info'    
    ---@type ImageButton		
	c.insts.equipBtn = 'Frame.bg.right.equipBtn'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.TitleGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.item_list = {}
    self.left_list = {}

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    UIGradientHelper:Add(self.insts.right_info.UIGradient)
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

function c:AddItemInScroll(id,icon,titleName,props,isRare,order)
    local ui = hotpot:CloneInst_Loop(self.insts.scroll_item)
    ui.Parent = self.insts.ScrollingFrame
    ui.Visible = true
    ui.Name = id
    ui.bg.icon.Image = icon
    ui.bg.titleName.Text = titleName
    ui.LayoutOrder = order

    for k,v in ipairs(props) do
        local p = ui.bg.prop.propItem:Clone()
        p.Parent = ui.bg.prop
        p.Visible = true
        p.txt.Text = v
    end

    ui.bg.MouseButton1Click:Connect(function()
        if self.__scroll_item_click_handle then
            self.__scroll_item_click_handle(self.__scroll_item_click_obj,id)
        end
    end)

    ui.bg.unlockBtn.MouseButton1Click:Connect(function()
        if self.__scroll_item_unlock_btn_click_handle then
            self.__scroll_item_unlock_btn_click_handle(self.__scroll_item_unlock_btn_click_obj,id)
        end
    end)

    if isRare then
        UIGradientHelper:Add(ui.bg.titleName.UIGradient)
        ui.bg.titleName.UIGradient.Enabled = true
    end

    self.item_list[id] = ui
end

function c:SetScrollItemSelectVisible(id,vis)
    local ui = self.item_list[id]
    if not ui then
        return
    end
    ui.bg.UIStroke.Enabled = vis
end

function c:SetScrollItemActiveVisible(id,vis)
    local ui = self.item_list[id]
    if not ui then
        return
    end
    ui.bg.ActiveFrame.Visible = vis
end

function c:SetScrollItemUnlockVisible(id,vis)
    local ui = self.item_list[id]
    if not ui then
        return
    end
    ui.bg.unlockBtn.Visible = vis
end

function c:SetScrollItemNeed(id,str,now,max)
    local ui = self.item_list[id]
    if not ui then
        return
    end
    ui.bg.need.Text = str .. string.format(' (%d/%d)',now,max)
end

function c:SetScrollItemTime(id,time_)
    local ui = self.item_list[id]
    if not ui then
        return
    end
    if time_ <= 0 then
        ui.bg.Time.Text = ''
    else
        ui.bg.Time.Text = big_number:GetTime(time_)
    end
end

function c:AddItemInLeft(str)
    local ui = hotpot:CloneInst_Loop(self.insts.left_list_item)
    ui.Parent = self.insts.left_list
    ui.Visible = true
    ui.info.Text = str

    self.left_list[ui] = true
end

function c:RemoveAllItemInLeft()
    for ui,_ in pairs(self.left_list) do
        ui:Destroy()
    end
    self.left_list = {}
end

function c:SetActivateBtnVisible(vis)
    self.insts.ActivateBtn.Visible = vis
end

function c:SetDeactivateBtnVisible(vis)
    self.insts.DeactivateBtn.Visible = vis
end

function c:SetActivatedTxt(str)
    self.insts.activatedTxt.Text = str
end

function c:SetRightInfo(icon,info,isRare)
    self.insts.right_icon.Image = icon
    self.insts.right_info.Text = info
    if isRare then
        self.insts.right_info.UIGradient.Enabled = true
    end
end

function c:BindScrollItemClickHandle(obj,handle)
    self.__scroll_item_click_handle = handle
    self.__scroll_item_click_obj = obj
end

function c:BindScrollItemUnlockBtnClickHandle(obj,handle)
    self.__scroll_item_unlock_btn_click_handle = handle
    self.__scroll_item_unlock_btn_click_obj = obj
end

function c:BindEquipBtnClickHandle(obj,handle)
    self.insts.equipBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindActivateBtnClickHandle(obj,handle)
    self.insts.ActivateBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindDeactivateBtnClickHandle(obj,handle)
    self.insts.DeactivateBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c