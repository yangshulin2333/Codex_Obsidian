local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type Players
local players = game:GetService('Players')
---@type Player
local player = players.LocalPlayer
---@type Mouse
local mouse = player:GetMouse()

local tweenInfo = TweenInfo.new(0.2)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class RelicsSmelterGui:HotpotScreenBase
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
	c.insts.scrollitem = 'Frame.bg.ScrollingFrame.item'  
    ---@type ImageButton		
	c.insts.SmeltBtn = 'Frame.bg.SmeltBtn'    
    ---@type ImageButton		
	c.insts.ShopBtn = 'Frame.bg.ShopBtn'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'    
    ---@type ImageLabel		
	c.insts.left = 'Frame.bg.left'    
    ---@type ScrollingFrame		
	c.insts.left_ScrollingFrame = 'Frame.bg.left.ScrollingFrame'    
    ---@type Frame		
	c.insts.left_Scrollitem = 'Frame.bg.left.ScrollingFrame.item'    
    ---@type ImageButton		
	c.insts.smeltBtn = 'Frame.bg.left.smeltBtn'    
    ---@type TextLabel		
	c.insts.coin_num = 'Frame.bg.left.icon.num'    
    ---@type TextLabel		
	c.insts.left_tip = 'Frame.bg.left.tip'    

    ---@type Frame		
	c.insts.shopFrame = 'Frame.bg.shopFrame'    
    ---@type ImageLabel		
	c.insts.item1 = 'Frame.bg.shopFrame.list.item1'    
    ---@type ImageLabel		
	c.insts.item2 = 'Frame.bg.shopFrame.list.item2'   
    ---@type ImageLabel		
	c.insts.item3 = 'Frame.bg.shopFrame.list.item3'     
    ---@type ImageLabel		
	c.insts.item4 = 'Frame.bg.shopFrame.list.item4'    

    ---@type TextLabel		
	c.insts.totalCoinsnum = 'Frame.bg.coins.num'    
    ---@type TextLabel		
	c.insts.cd = 'Frame.bg.shopFrame.cd'    
    ---@type ImageLabel		
	c.insts.tipsFrame = 'Frame.bg.tipsFrame'  
    ---@type ImageButton		
	c.insts.DarkScrollbtn = 'Frame.bg.DarkScroll.btn'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.RelicsSmelterGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.right_item_list = {}
    self.left_item_list = {}
    self.shop_item_list = {
        self.insts.item1,
        self.insts.item2,
        self.insts.item3,
        self.insts.item4,
    }
    for k,ui in ipairs(self.shop_item_list) do
        local idx = k
        ui.bg.btn.MouseButton1Click:Connect(function()
            if self.__shop_handle then
                self.__shop_handle(self.__shop_obj,idx)
            end
        end)
    end

    self.insts.SmeltBtn.MouseButton1Click:Connect(function()
        self:SetShopFrameVisible(false)
        self:SetRightScrollVisible(true)
        self:SetLeftVisible(true)
    end)
    self.insts.ShopBtn.MouseButton1Click:Connect(function()
        self:SetShopFrameVisible(true)
        self:SetRightScrollVisible(false)
        self:SetLeftVisible(false)
        self:SetTipsFrameVisible(false)
    end)
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

    if self.__hide_handle then
        self.__hide_handle(self.__hide_obj)
    end

    self:SetTipsFrameVisible(false)
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

function c:AddItemInRightScroll(inst_id,icon,quality,score)
    local ui = hotpot:CloneInst_Loop(self.insts.scrollitem)
    ui.Visible = true
    ui.Parent = self.insts.ScrollingFrame
    ui.Name = inst_id
    ui.LayoutOrder = -score
    ui.btn.icon.Image = icon
    ui.btn.num.Text = score
    local color = qualityColor:FindFirstChild(quality)
    if color then
        color:Clone().Parent = ui.btn
        color:Clone().Parent = ui.btn.UIStroke
    end

    self.right_item_list[inst_id] = ui

    ui.btn.MouseButton1Click:Connect(function()
        if self.__right_handle then
            self.__right_handle(self.__right_obj,inst_id)
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

function c:SetRightItemVisible(inst_id,vis)
    local ui = self.right_item_list[inst_id]
    if ui then
        ui.Visible = vis
    end
end

function c:SetRightItemScore(inst_id,score)
    local ui = self.right_item_list[inst_id]
    if ui then
        ui.btn.num.Text = score
        ui.LayoutOrder = -score
    end
end

function c:DelRightItem(inst_id)
    local ui = self.right_item_list[inst_id]
    if ui then
        ui:Destroy()
        self.right_item_list[inst_id] = nil
    end
end

function c:AddItemInLeftScroll(inst_id,icon,quality,score)
    local ui = hotpot:CloneInst_Loop(self.insts.left_Scrollitem)
    ui.Visible = true
    ui.Parent = self.insts.left_ScrollingFrame
    ui.Name = inst_id
    ui.LayoutOrder = -score
    ui.btn.icon.Image = icon
    ui.btn.num.Text = score
    local color = qualityColor:FindFirstChild(quality)
    if color then
        color:Clone().Parent = ui.btn
        color:Clone().Parent = ui.btn.UIStroke
    end
    self.left_item_list[inst_id] = ui

    ui.btn.MouseButton1Click:Connect(function()
        if self.__left_handle then
            self.__left_handle(self.__left_obj,inst_id)
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

function c:DelLeftItem(inst_id)
    local ui = self.left_item_list[inst_id]
    if ui then
        ui:Destroy()
        self.left_item_list[inst_id] = nil
    end
end

function c:SetSmeltCoinNum(num)
    self.insts.coin_num.Text = num
end

function c:SetLeftVisible(vis)
    self.insts.left.Visible = vis
end

function c:SetRightScrollVisible(vis)
    self.insts.ScrollingFrame.Visible = vis
end

function c:SetShopFrameVisible(vis)
    self.insts.shopFrame.Visible = vis
end

function c:SetTotalCoinsNum(num)
    self.insts.totalCoinsnum.Text = big_number:ToString(num)
end

function c:SetShopItemBtnVisible(idx,vis)
    local ui = self.shop_item_list[idx]
    if ui then
        ui.bg.btn.Visible = vis
        ui.bg.sellOut.Visible = not vis
    end
end

function c:SetCd(cd)
    self.insts.cd.Text = big_number:TransformDateToString(cd)
end

function c:BindRightItemClickHandle(obj,handle)
    self.__right_handle = handle
    self.__right_obj = obj
end

function c:BindLeftItemClickHandle(obj,handle)
    self.__left_handle = handle
    self.__left_obj = obj
end

function c:BindSmeltBtnClickHandle(obj,handle)
    self.insts.smeltBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindHideHandle(obj,handle)
    self.__hide_handle = handle
    self.__hide_obj = obj
end

function c:BindShopItemClickHandle(obj,handle)
    self.__shop_handle = handle
    self.__shop_obj = obj
end

function c:BindItemMouseEnter(obj,handle)
    self.__item_mouse_enter_handle = handle
    self.__item_mouse_enter_obj = obj
end

function c:BindDarkScrollBtnClickHandle(obj,handle)
    self.insts.DarkScrollbtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c