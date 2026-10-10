local hotpot = _G.ClientHotpot
---@type Players
local players = game:GetService('Players')
---@type Player
local player = players.LocalPlayer
---@type Mouse
local mouse = player:GetMouse()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type UIGradientHelper
local ui_gradient = hotpot.load.UIGradientHelper()
local GuiService = game:GetService("GuiService")

local TIP_SIZE_Y = 0
local tweenInfo = TweenInfo.new(0.2)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class RelicsGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type Frame		
	c.insts.left = 'Frame.bg.left'   
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'     
    ---@type ScrollingFrame		
	c.insts.ScrollingFrame = 'Frame.bg.right.ScrollingFrame'    
    ---@type Frame		
	c.insts.scroll_item = 'Frame.bg.right.ScrollingFrame.item'  
    ---@type ImageButton		
	c.insts.cancelBtn = 'Frame.bg.right.cancelBtn'      
    ---@type ImageButton		
	c.insts.delBtn = 'Frame.bg.right.delBtn'    

    ---@type ImageLabel		
	c.insts.tipsFrame = 'Frame.bg.tipsFrame'    
    ---@type ImageLabel		
	c.insts.capacityPanel = 'Frame.bg.right.capacityPanel'  
    ---@type TextLabel		
	c.insts.capacity_num = 'Frame.bg.right.capacityPanel.num'   
    
    ---@type Model		
	c.insts.Rig = 'Frame.bg.ViewportFrame.WorldModel.Rig' 
    
    ---@type ImageButton		
	c.insts.unlockAllBtn = 'Frame.bg.unlockAllBtn'    

    ---@type ImageButton		
	c.insts.TitleBtn = 'Frame.bg.left.TitleBtn'    
    ---@type Frame		
	c.insts.title_red = 'Frame.bg.left.TitleBtn.red'    

    ---@type ImageButton		
	c.insts.TransferBtn = 'Frame.bg.left.TransferBtn'    

    ---@type ImageLabel		
	c.insts.suitFrame = 'Frame.bg.tipsFrame.suitFrame'    
    ---@type TextLabel		
	c.insts.suitFrame_title = 'Frame.bg.tipsFrame.suitFrame.title'    
    ---@type Frame		
	c.insts.suitNameList = 'Frame.bg.tipsFrame.suitFrame.suitNameList'   
    ---@type TextLabel		
	c.insts.suitNameList_item = 'Frame.bg.tipsFrame.suitFrame.suitNameList.item'     
    ---@type ScrollingFrame		
	c.insts.suitFrame_ScrollingFrame = 'Frame.bg.tipsFrame.suitFrame.suitList.ScrollingFrame'    
    ---@type TextLabel		
	c.insts.Titleitem = 'Frame.bg.tipsFrame.suitFrame.suitList.ScrollingFrame.Titleitem'  
    ---@type TextLabel		
	c.insts.effectitem = 'Frame.bg.tipsFrame.suitFrame.suitList.ScrollingFrame.effectitem'     
    
    ---@type TextLabel		
	c.insts.power = 'Frame.bg.left.power'    
    ---@type TextLabel		
	c.insts.add = 'Frame.bg.left.add'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('PlayerGui.RelicsGui',player)
    c.super.ctor(self,ui,true)

    self:Init()

    self.suit_name_items = {}
    self.suit_scroll_item = {}
end

function c:Show()
    self.insts.Frame.Position = UDim2.fromScale(0.5,0.7)
    c.super.Show(self)
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

function c:Init()
    self.item_list = {}
    self.equip_solt_list = {}
    for i = 1,9 do
        local idx = i
        local ui = self.insts.left:WaitForChild('solt'..i)
        self.equip_solt_list[i] = ui
        ui.MouseEnter:Connect(function()
            if self.__solt_mouse_enter_handle and self.__solt_mouse_enter_obj then
                self.__solt_mouse_enter_handle(self.__solt_mouse_enter_obj,idx)
            end
            local x = mouse.X
            local y = mouse.Y
            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize
            if self.suit_vis then
                local topbarInset = GuiService:GetGuiInset()
                local view = workspace.CurrentCamera.ViewportSize
                local suitSize = self.insts.suitFrame.AbsoluteSize
                local tipsSize = self.insts.tipsFrame.AbsoluteSize

                if x + tipsSize.X + suitSize.X > view.X then
                    x = view.X - tipsSize.X - suitSize.X - 5
                end
                if y + suitSize.Y > view.Y then
                    y = view.Y - suitSize.Y - 5 - topbarInset.Y
                end
                x = (x - a_pos.X) / a_size.X
                y = (y - a_pos.Y) / a_size.Y
                self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
            else
                x = (x - a_pos.X) / a_size.X
                y = (y - a_pos.Y) / a_size.Y
                self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
            end
        end)
        ui.MouseLeave:Connect(function()
            self:SetTipsFrameVisible(false)
        end)
        ui.MouseMoved:Connect(function()
            local x = mouse.X
            local y = mouse.Y
            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize
            if self.suit_vis then
                local topbarInset = GuiService:GetGuiInset()
                local view = workspace.CurrentCamera.ViewportSize
                local suitSize = self.insts.suitFrame.AbsoluteSize
                local tipsSize = self.insts.tipsFrame.AbsoluteSize

                if x + tipsSize.X + suitSize.X > view.X then
                    x = view.X - tipsSize.X - suitSize.X - 5
                end
                if y + suitSize.Y > view.Y then
                    y = view.Y - suitSize.Y - 5 - topbarInset.Y
                end
                x = (x - a_pos.X) / a_size.X
                y = (y - a_pos.Y) / a_size.Y
                self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
            else
                x = (x - a_pos.X) / a_size.X
                y = (y - a_pos.Y) / a_size.Y
                self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
            end
        end)
        ui.MouseButton1Click:Connect(function()
            if self.__solt_click_handle and self.__solt_click_obj then
                self.__solt_click_handle(self.__solt_click_obj,idx)
            end
        end)
        if idx >= 4 and idx <= 6 then
            ui.purchasetop.btn.MouseButton1Click:Connect(function()
                if self.__solt_handle and self.__solt_obj then
                    self.__solt_handle(self.__solt_obj,idx)
                end
            end)
        end
    end

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    self.insts.TitleBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.title_gui:Show()
    end)

    self.insts.TransferBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.transfer_gui:Show()
    end)
end

--设置equipFrame的solt信息
---@param state number @1未装备 2已装备 3未解锁 4使用robux解锁 
function c:SetSoltInfo(id,state,infos)
    local ui = self.insts.left:FindFirstChild('solt'..id)
    if not ui then
        return 
    end

    local color = ui:FindFirstChildOfClass('UIGradient')
    if color then
        color:Destroy()
        color = nil
    end
    color = ui.UIStroke:FindFirstChildOfClass('UIGradient')
    if color then
        color:Destroy()
        color = nil
    end

    if state == 1 then
        ui.top.Visible = false
        ui.icon.Image = ''
        ui.value.Text = ''
        ui.purchasetop.Visible = false
        ui.big.Text = '+0'
        ui.big.Visible = false

        local col = qualityColor:FindFirstChild('1')
        if col then
            col:Clone().Parent = ui
            col:Clone().Parent = ui.UIStroke
        end
    elseif state == 2 then
        ui.top.Visible = false
        ui.icon.Image = infos.icon
        ui.value.Text = big_number:ToString(infos.score)
        ui.purchasetop.Visible = false
        ui.big.Text = '+'..infos.big
        ui.big.Visible = infos.big > 0

        local col = qualityColor:FindFirstChild(tostring(infos.quality))
        if col then
            col:Clone().Parent = ui
            col:Clone().Parent = ui.UIStroke
        end
    elseif state == 3 then
        ui.top.Visible = true
        ui.icon.Image = ''
        ui.purchasetop.Visible = false
        ui.value.Text = ''
        ui.big.Text = '+0'
        ui.big.Visible = false
    elseif state == 4 then
        ui.top.Visible = true
        ui.icon.Image = ''
        ui.value.Text = ''
        ui.purchasetop.Visible = true
        ui.big.Text = '+0'
        ui.big.Visible = false
    end
end

function c:SetSoltBig(id,big)
    local ui = self.insts.left:FindFirstChild('solt'..id)
    if not ui then
        return 
    end
    ui.big.Text = '+'..big
    ui.big.Visible = big > 0
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

--向EquipFrame添加子项
function c:AddItemInFrame(inst_id,icon,score,quality,big)
    local ui = hotpot:CloneInst_Loop(self.insts.scroll_item)
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
        if self.suit_vis then
            local topbarInset = GuiService:GetGuiInset()
            local view = workspace.CurrentCamera.ViewportSize
            local suitSize = self.insts.suitFrame.AbsoluteSize
            local tipsSize = self.insts.tipsFrame.AbsoluteSize

            if x + tipsSize.X + suitSize.X > view.X then
                x = view.X - tipsSize.X - suitSize.X - 5
            end
            if y + suitSize.Y > view.Y then
                y = view.Y - suitSize.Y - 5 - topbarInset.Y
            end
            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y
            self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
        else
            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y
            self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
        end
    end)
    ui.btn.MouseLeave:Connect(function()
        self:SetTipsFrameVisible(false)
    end)
    ui.btn.MouseMoved:Connect(function()
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        if self.suit_vis then
            local topbarInset = GuiService:GetGuiInset()
            local view = workspace.CurrentCamera.ViewportSize
            local suitSize = self.insts.suitFrame.AbsoluteSize
            local tipsSize = self.insts.tipsFrame.AbsoluteSize

            if x + tipsSize.X + suitSize.X > view.X then
                x = view.X - tipsSize.X - suitSize.X - 5
            end

            if y + suitSize.Y > view.Y then
                y = view.Y - suitSize.Y - 5 - topbarInset.Y
            end
            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y
            self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
        else
            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y
            self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
        end
    end)
    ui.btn.MouseButton1Click:Connect(function()
        if self.__item_click_handle and self.__item_click_obj then
            self.__item_click_handle(self.__item_click_obj,inst_id)
        end
    end)
end

--删除item
function c:DelItem(inst_id)
    local ui = self.item_list[inst_id]
    if not ui then
        return
    end
    ui:Destroy()
    self.item_list[inst_id] = nil
end

function c:SetItemBig(inst_id,big)
    local ui = self.item_list[inst_id]
    if not ui then
        return
    end
    ui.btn.big.Text = '+'..big
    ui.btn.big.Visible = big > 0
end

function c:SetItemScore(inst_id,score)
    local ui = self.item_list[inst_id]
    if ui then
        ui.btn.num.Text = score
        ui.LayoutOrder = 100000 - score
    end
end

--设置equipitem的del显示
function c:SetItemDelVisible(inst_id,vis)
    local ui = self.item_list[inst_id]
    if not ui then
        return
    end
    ui.btn.del.Visible = vis
end

--设置equipitem的显示
function c:SetItemVisible(inst_id,vis)
    local ui = self.item_list[inst_id]
    if not ui then
        return
    end
    ui.Visible = vis
end

--设置equipframe的cancelbtn显示
function c:SetCancelBtnVisible(vis)
    self.insts.cancelBtn.Visible = vis
end

--设置装备数量
function c:SetBagCapacity(num,max)
    self.insts.capacity_num.Text = num..'/'..max
end

--设置解锁按钮的显示
function c:SetUnlockAllBtnVisible(vis)
    self.insts.unlockAllBtn.Visible = vis
end

--绑定EquipFrame的item鼠标进入事件
function c:BindItemMouseEnter(obj,handle)
    self.__item_mouse_enter_handle = handle
    self.__item_mouse_enter_obj = obj
end

--绑定EquipFrame的solt鼠标进入事件
function c:BindSoltMouseEnter(obj,handle)
    self.__solt_mouse_enter_handle = handle
    self.__solt_mouse_enter_obj = obj
end

--绑定EquipFrame的item点击事件
function c:BindItemClickHandle(obj,handle)
    self.__item_click_handle = handle
    self.__item_click_obj = obj
end

--绑定EquipFrame的solt点击事件
function c:BindSoltClickHandle(obj,handle)
    self.__solt_click_handle = handle
    self.__solt_click_obj = obj
end

--绑定EquipFrame的DelBtn
function c:BindDelBtnClickHandle(obj,handle)
    self.insts.delBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定EquipFrame的CancelBtn
function c:BindCancelBtnClickHandle(obj,handle)
    self.insts.cancelBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定solt解锁按钮点击事件
function c:BindSoltUnlockBtnClickHandle(obj,handle)
    self.__solt_handle = handle
    self.__solt_obj = obj
end

--绑定解锁按钮点击事件
function c:BindUnlockAllBtnClickHandle(obj,handle)
    self.insts.unlockAllBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:SetTitleRedVisible(vis)
    self.insts.title_red.Visible = vis
end

---------------------------------------------suit
--设置suitFrame的显示
function c:SetSuitFrameVisible(vis)
    self.suit_vis = vis
    self.insts.suitFrame.Visible = vis
end

--设置SuitFrameInfo
function c:SetSuitFrameInfo(info)
    self.insts.suitFrame_title.Text = info.title

    for _,ui in pairs(self.suit_name_items)do
        ui:Destroy()
    end
    self.suit_name_items = {}
    for name,active in pairs(info.suitNameList)do
        local ui = self.insts.suitNameList_item:Clone()
        ui.Name = name
        ui.Text = name
        ui.Visible = true
        ui.Parent = self.insts.suitNameList
        ui.TextColor3 = active and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(190, 190, 190)
        self.suit_name_items[name] = ui
    end

    for _,ui in pairs(self.suit_scroll_item)do
        ui:Destroy()
    end
    self.suit_scroll_item = {}
    for k,v in ipairs(info.suitScroll)do
        local ui = nil
        if v.is_title then
            ui = self.insts.Titleitem:Clone()
        else
            ui = self.insts.effectitem:Clone()
        end
        ui.Visible = true
        ui.Parent = self.insts.suitFrame_ScrollingFrame
        ui.LayoutOrder = k
        ui.Text = v.text
        ui.TextColor3 = v.active and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(190, 190, 190)
        self.suit_scroll_item[v.text] = ui
    end
end

function c:SetPower(power)
    self.insts.power.Text = big_number:ToString(power)
end

function c:PlayPower(power,is_add)
    local ui = self.insts.add:Clone()
    ui.Parent = self.insts.add.Parent
    ui.Text = big_number:ToString(power)
    if is_add then
        ui.Text = '+' .. ui.Text
        ui.TextColor3 = Color3.fromRGB(0,255,0)
    else
        ui.Text = '-' .. ui.Text
        ui.TextColor3 = Color3.fromRGB(255,0,0)
    end

    ui.Visible = true

    wait(.3)

    TweenHelper:PlayTween(
        ui,
        TweenInfo.new(0.5),
        {Position = UDim2.fromScale(0.5,-0.05)},
        function()
            ui:Destroy()
        end
    )
end

return c