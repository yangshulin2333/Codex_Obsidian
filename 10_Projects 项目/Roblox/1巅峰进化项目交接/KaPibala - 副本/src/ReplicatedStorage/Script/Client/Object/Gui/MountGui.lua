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

---@class MountGui:HotpotScreenBase
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
	c.insts.tipsFrame = 'Frame.bg.tipsFrame'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.MountGui',_G.Resource)
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
end

function c:SetTipsFrameVisible(visible)
    self.insts.tipsFrame.Visible = visible
end

function c:SetTipsFrameInfo(name,big,small,speed)
    self.insts.tipsFrame.name.Text = name
    self.insts.tipsFrame.speed.Text = string.format('Speed +%s%%',speed)

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

function c:AddItemInScroll(id,icon,name,speed,lockNum,condition,order)
    local ui = hotpot:CloneInst_Loop(self.insts.scroll_item)
    ui.Parent = self.insts.ScrollingFrame
    ui.Name = id
    ui.LayoutOrder = order or 0
    ui.Visible = true
    ui.bg.icon.Image = icon or ''
    ui.bg.name.Text = name
    ui.bg.speed.Text = string.format('Speed  + %s%%',speed)
    ui.bg.unlockRobuxBtn.price.Text = lockNum or 0
    ui.bg.condition.Text = condition or ''
    self.item_list[id] = ui

    ui.bg.equipBtn.MouseButton1Click:Connect(function()
        if self.item_equip_handle then
            self.item_equip_handle(self.item_equip_obj,id)
        end
    end)
    ui.bg.unequipBtn.MouseButton1Click:Connect(function()
        if self.item_unequip_handle then
            self.item_unequip_handle(self.item_unequip_obj,id)
        end
    end)
    ui.bg.unlockBtn.MouseButton1Click:Connect(function()
        if self.item_unlock_handle then
            self.item_unlock_handle(self.item_unlock_obj,id)
        end
    end)
    ui.bg.unlockRobuxBtn.MouseButton1Click:Connect(function()
        if self.item_unlock_robux_handle then
            self.item_unlock_robux_handle(self.item_unlock_robux_obj,id)
        end
    end)

    ui.bg.icon.MouseEnter:Connect(function()
        if self.item_mouse_enter_handle then
            self.item_mouse_enter_handle(self.item_mouse_enter_obj,id)
        end
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    ui.bg.icon.MouseMoved:Connect(function()
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    ui.bg.icon.MouseLeave:Connect(function()
        self:SetTipsFrameVisible(false)
    end)
end

function c:SetItemSpeed(id,speed)
    local ui = self.item_list[id]
    if ui then
        ui.bg.speed.Text = string.format('Speed +%s%%',speed)
    end
end

function c:SetItemUnlockBtnVisible(id,visible)
    local ui = self.item_list[id]
    if ui then
        ui.bg.unlockBtn.Visible = visible
    end
end

function c:SetItemUnlockRobuxBtnVisible(id,visible)
    local ui = self.item_list[id]
    if ui then
        ui.bg.unlockRobuxBtn.Visible = visible
    end
end

function c:SetItemUnequipBtnVisible(id,visible)
    local ui = self.item_list[id]
    if ui then
        ui.bg.unequipBtn.Visible = visible
    end
end

function c:SetItemEquipBtnVisible(id,visible)
    local ui = self.item_list[id]
    if ui then
        ui.bg.equipBtn.Visible = visible
    end
end

function c:SetUnlockBtnRedVisible(id,visible)
    local ui = self.item_list[id]
    if ui then
        ui.bg.unlockBtn.red.Visible = visible
    end
end

function c:BindItemEquipBtnClickHandle(obj,handle)
    self.item_equip_handle = handle
    self.item_equip_obj = obj
end

function c:BindItemUnequipBtnClickHandle(obj,handle)
    self.item_unequip_handle = handle
    self.item_unequip_obj = obj
end

function c:BindItemUnlockBtnClickHandle(obj,handle)
    self.item_unlock_handle = handle
    self.item_unlock_obj = obj
end

function c:BindItemUnlockRobuxBtnClickHandle(obj,handle)
    self.item_unlock_robux_handle = handle
    self.item_unlock_robux_obj = obj
end

function c:BindMouseEnterHandle(obj,handle)
    self.item_mouse_enter_handle = handle
    self.item_mouse_enter_obj = obj
end

return c