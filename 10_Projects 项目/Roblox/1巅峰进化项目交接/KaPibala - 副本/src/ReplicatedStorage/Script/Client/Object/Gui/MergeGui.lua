local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type Players
local players = game:GetService('Players')
---@type Player
local player = players.LocalPlayer
---@type Mouse
local mouse = player:GetMouse()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class MergeGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'   
    
    ---@type ScrollingFrame		
	c.insts.ScrollingFrame = 'Frame.bg.left.ScrollingFrame'     
    ---@type Frame		
	c.insts.scroll_item = 'Frame.bg.left.ScrollingFrame.item'    
    
    ---@type Frame		
	c.insts.right = 'Frame.bg.right'   
    ---@type TextLabel		
	c.insts.right_name = 'Frame.bg.right.name'     
    ---@type ImageButton		
	c.insts.mergeBtn = 'Frame.bg.right.mergeBtn'    
    ---@type ImageButton		
	c.insts.resetBtn = 'Frame.bg.right.resetBtn'    
    ---@type ImageLabel		
	c.insts.right_s1 = 'Frame.bg.right.s1'    
    ---@type ImageLabel		
	c.insts.right_s2 = 'Frame.bg.right.s2'    
    ---@type ImageLabel		
	c.insts.right_s3 = 'Frame.bg.right.s3'    

    ---@type ImageLabel		
	c.insts.tipsFrame = 'Frame.bg.tipsFrame'    
    ---@type TextLabel		
	c.insts.tipsFrame_name = 'Frame.bg.tipsFrame.name'    
    ---@type TextLabel		
	c.insts.tipsFrame_atk = 'Frame.bg.tipsFrame.atk'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.MergeGui',_G.Resource)
    c.super.ctor(self,ui)

    self.item_list = {}
    self.right_item_list = {
        self.insts.right_s1,self.insts.right_s2,self.insts.right_s3
    }

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
            if self.__hide_handle and self.__hide_obj then
                self.__hide_handle(self.__hide_obj)
            end
        end
    )
    ui_manager.ui_list.hud_gui:Show()
end

--向scroll添加item
function c:AddItemInScroll(inst_id,icon,quality,value,star)
    local ui = hotpot:CloneInst_Loop(self.insts.scroll_item)
    ui.Visible = true
    ui.Parent = self.insts.ScrollingFrame
    ui.Name = inst_id
    local color = qualityColor:FindFirstChild(tostring(quality))
    color:Clone().Parent = ui.btn
    color:Clone().Parent = ui.btn.UIStroke

    ui.btn.icon.Image = icon
    ui.btn.value.Text = big_number:ToString(value)
    ui.LayoutOrder = -value
    self.item_list[inst_id] = ui
    local stars = ui.btn.stars
    for i = 1,2 do
        local star_ui = stars:FindFirstChild(tostring(i))
        star_ui.Visible = star>=i
    end

    ui.btn.MouseEnter:Connect(function()
        if self.__mouse_enter_handle and self.__mouse_enter_obj then
            self.__mouse_enter_handle(self.__mouse_enter_obj,inst_id)
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

--设置scroll的layout
function c:SetItemLayout(inst_id,layout)
    local ui = self.item_list[inst_id]
    if ui then
        ui.LayoutOrder = layout
    end
end

--删除item
function c:DelItemInScroll(inst_id)
    local ui = self.item_list[inst_id]
    if ui then
        ui:Destroy()
        self.item_list[inst_id] = nil
    end
end

--设置item的显示
function c:SetItemVisible(inst_id,visible)
    local ui = self.item_list[inst_id]
    if ui then
        ui.Visible = visible
    end
end

--设置item的select显示
function c:SetItemSelectVisible(inst_id,vis)
    local ui = self.item_list[inst_id]
    if ui then
        ui.btn.select.Visible = vis
    end
end

--设置右侧名字
function c:SetRightName(name)
    self.insts.right_name.Text = name
end

--设置右侧宠物信息
function c:SetRightPetInfo(list)
    local icon = 'rbxassetid://114263356305733'
    for k,v in ipairs(self.right_item_list) do
        if list[k] then
            icon = list[k].icon
            v.icon.Image = list[k].icon
            v.icon.ImageColor3 = Color3.fromRGB(255,255,255)
            v.ImageColor3 = Color3.fromRGB(255,255,255)
            
            local g = v:FindFirstChildOfClass('UIGradient')
            if g then
                g:Destroy()
            end
            v.UIStroke:ClearAllChildren()

            local color = qualityColor:FindFirstChild(tostring(list[k].quality))
            color:Clone().Parent = v
            color:Clone().Parent = v.UIStroke

            local stars = v.stars
            for i = 1,2 do
                local star_ui = stars:FindFirstChild(tostring(i))
                star_ui.Visible = list[k].star>=i
            end
        else
            v.icon.Image = icon
            v.icon.ImageColor3 = Color3.fromRGB(0,0,0)
            v.ImageColor3 = Color3.fromRGB(147,147,147)

            local g = v:FindFirstChildOfClass('UIGradient')
            if g then
                g:Destroy()
            end
            v.UIStroke:ClearAllChildren()

            local stars = v.stars
            for i = 1,2 do
                local star_ui = stars:FindFirstChild(tostring(i))
                star_ui.Visible = false
            end
        end
    end
end

--设置重置按钮显示
function c:SetResetBtnVisible(visible)
    self.insts.resetBtn.Visible = visible
end

--设置tipsFrame信息
function c:SetTipsFrameInfo(name,atk)
    self.insts.tipsFrame_name.Text = name
    self.insts.tipsFrame_atk.num.Text = '+'..big_number:ToString(atk)
end

--设置tipsFrame显示
function c:SetTipsFrameVisible(visible)
    self.insts.tipsFrame.Visible = visible
end

--绑定item鼠标进入事件
function c:BindItemMouseEnterEvent(obj,handle)
    self.__mouse_enter_obj = obj
    self.__mouse_enter_handle = handle
end

--绑定item点击事件
function c:BindItemClickEvent(obj,handle)
    self.__item_click_obj = obj
    self.__item_click_handle = handle
end

--绑定重置按钮点击事件
function c:BindResetBtnClickEvent(obj,handle)
    self.insts.resetBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
    self.__hide_handle = handle
    self.__hide_obj = obj
end

--绑定合成点击事件
function c:BindMergeBtnClickEvent(obj,handle)
    self.insts.mergeBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c