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

local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)
local tweenInfo = TweenInfo.new(0.2)
local tipsInfo = TweenInfo.new(0.1,2,1)

---@class GuildForgeGui:HotpotScreenBase
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
    ---@type ScrollingFrame		
	c.insts.left_ScrollingFrame = 'Frame.bg.left.ScrollingFrame'    
    ---@type Frame		
	c.insts.left_scrollitem = 'Frame.bg.left.ScrollingFrame.item'    
    ---@type TextLabel		
	c.insts.left_title = 'Frame.bg.left.title'    
    ---@type ImageLabel		
	c.insts.right = 'Frame.bg.right'    
    ---@type ScrollingFrame		
	c.insts.right_ScrollingFrame = 'Frame.bg.right.ScrollingFrame'    
    ---@type Frame		
	c.insts.right_scrollitem = 'Frame.bg.right.ScrollingFrame.item'    

    ---@type ImageLabel		
	c.insts.center = 'Frame.bg.center'    
    ---@type ImageButton		
	c.insts.center_solt1 = 'Frame.bg.center.solt1'    
    ---@type ImageButton		
	c.insts.center_solt2 = 'Frame.bg.center.solt2'    
    ---@type ImageButton		
	c.insts.center_solt3 = 'Frame.bg.center.solt3'    
    ---@type ImageButton		
	c.insts.center_solt4 = 'Frame.bg.center.solt4'    
    ---@type ImageButton		
	c.insts.center_relicssolt = 'Frame.bg.center.relicssolt'    
    ---@type Frame		
	c.insts.center_Lvbig = 'Frame.bg.center.lv.big.info'    
    ---@type Frame		
	c.insts.center_Lvsmall = 'Frame.bg.center.lv.small.info'    
    ---@type TextLabel		
	c.insts.center_forgeStoneNum = 'Frame.bg.center.board.forgeStoneNum.num'   
    ---@type ImageLabel		
	c.insts.forgeStone = 'Frame.bg.center.board.forgeStone'    
    ---@type TextLabel		
	c.insts.center_gemsNum = 'Frame.bg.center.board.gemsNum.num'     
    ---@type TextLabel		
	c.insts.center_successRate = 'Frame.bg.center.board.successRate'    
    ---@type TextLabel		
	c.insts.center_otherRate = 'Frame.bg.center.board.otherRate'    
    ---@type ImageButton		
	c.insts.center_btn = 'Frame.bg.center.board.btn'
    ---@type TextLabel		
	c.insts.center_tips = 'Frame.bg.center.tips'    
    ---@type Model		
	c.insts.center_rig = 'Frame.bg.center.ViewportFrame.WorldModel.Test03a'   
    ---@type TextLabel		
	c.insts.valuetips = 'Frame.bg.center.valuetips'    
    
    ---@type ImageLabel		
	c.insts.relicstipsFrame = 'Frame.bg.relicstipsFrame'    
    ---@type ImageLabel		
	c.insts.mounttipsFrame = 'Frame.bg.mounttipsFrame'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.GuildForgeGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.center_solt = {
        self.insts.center_solt1,
        self.insts.center_solt2,
        self.insts.center_solt3,
        self.insts.center_solt4,
    }
    self.left_item = {}
    self.right_item = {}

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    local animator = hotpot:GetPath_Loop('Humanoid.Animator',self.insts.center_rig)
    local animation = self.insts.center_rig:WaitForChild('Animation')
    self.track = animator:LoadAnimation(animation)

    self.insts.center_relicssolt.MouseEnter:Connect(function()
        if self.center_mouse_enter_handle then
            self.center_mouse_enter_handle(self.center_mouse_enter_obj)
        end
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.relicstipsFrame.Position = UDim2.fromScale(x,y)
        self.insts.mounttipsFrame.Position = UDim2.fromScale(x,y)
    end)
    self.insts.center_relicssolt.MouseMoved:Connect(function()
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.relicstipsFrame.Position = UDim2.fromScale(x,y)
        self.insts.mounttipsFrame.Position = UDim2.fromScale(x,y)
    end)
    self.insts.center_relicssolt.MouseLeave:Connect(function()
        self:SetRelicsTipsFrameVisible(false)
        self:SetMountTipsFrameVisible(false)
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

    self:SetRelicsTipsFrameVisible(false)
    self:SetMountTipsFrameVisible(false)
end

function c:SetRelicsTipsFrameVisible(vis)
    self.insts.relicstipsFrame.Visible = vis
end

function c:SetMountTipsFrameVisible(vis)
    self.insts.mounttipsFrame.Visible = vis
end

function c:SetRelicsTipsFrameInfo(name,list,quality,big,small)
    local len = #list
    self.insts.relicstipsFrame.name.Text = name

    for i = 1,7 do
        local color = self.insts.relicstipsFrame.name:FindFirstChild(tostring(i))
        color.Enabled = i == quality
    end

    local ui
    for i = 1,4 do
        ui = self.insts.relicstipsFrame:FindFirstChild(tostring(i))
        ui.Visible = i == len
    end

    ui = self.insts.relicstipsFrame:FindFirstChild(tostring(len))

    for k,v in ipairs(list)do
        local TextLabel = ui:FindFirstChild('info'..k)
        if TextLabel then
            TextLabel.Text = v
        end
    end

    local bigUi = self.insts.relicstipsFrame.big
    local smallUi = self.insts.relicstipsFrame.small
    for i = 1,10 do
        local icon = bigUi:FindFirstChild(tostring(i))
        icon.ImageColor3 = (big >= i) and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
    end
    for i = 1,10 do
        local icon = smallUi:FindFirstChild(tostring(i))
        icon.ImageColor3 = (small >= i) and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
    end
end

function c:SetMountTipsFrameInfo(name,big,small,speed)
    self.insts.mounttipsFrame.name.Text = name
    self.insts.mounttipsFrame.speed.Text = string.format('Speed +%s%%',speed)

    local bigUi = self.insts.mounttipsFrame.big
    local smallUi = self.insts.mounttipsFrame.small
    for i = 1,10 do
        local icon = bigUi:FindFirstChild(tostring(i))
        icon.ImageColor3 = (big >= i) and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
    end
    for i = 1,10 do
        local icon = smallUi:FindFirstChild(tostring(i))
        icon.ImageColor3 = (small >= i) and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
    end
end

function c:SetTitle(title)
    self.insts.left_title.Text = title
end

function c:AddItemInLeft(inst_id,icon,name,big,small,quality,score)
    local ui = hotpot:CloneInst_Loop(self.insts.left_scrollitem)
    ui.Parent = self.insts.left_ScrollingFrame
    ui.Visible = true
    ui.Name = inst_id
    ui.LayoutOrder = -score
    ui.btn.board.icon.Image = icon
    ui.btn.title.Text = name
    ui.btn.big.Text = '+' .. big
    ui.btn.small.Text = '+' .. small
    
    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        color:Clone().Parent = ui.btn.board
        color:Clone().Parent = ui.btn.board.UIStroke
    end

    ui.btn.MouseButton1Click:Connect(function()
        if self.__left_handle then
            self.__left_handle(self.__left_obj,inst_id)
        end
    end)

    self.left_item[inst_id] = ui

    ui.btn.board.MouseEnter:Connect(function()
        if self.item_mouse_enter_handle then
            self.item_mouse_enter_handle(self.item_mouse_enter_obj,inst_id)
        end
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.relicstipsFrame.Position = UDim2.fromScale(x,y)
        self.insts.mounttipsFrame.Position = UDim2.fromScale(x,y)
    end)
    ui.btn.board.MouseMoved:Connect(function()
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.relicstipsFrame.Position = UDim2.fromScale(x,y)
        self.insts.mounttipsFrame.Position = UDim2.fromScale(x,y)
    end)
    ui.btn.board.MouseLeave:Connect(function()
        self:SetRelicsTipsFrameVisible(false)
        self:SetMountTipsFrameVisible(false)
    end)
end

function c:RemoveItemInLeft(inst_id)
    local ui = self.left_item[inst_id]
    if ui then
        ui:Destroy()
        self.left_item[inst_id] = nil
    end
end

function c:RemoveAllItemInLeft()
    for inst_id,ui in pairs(self.left_item) do
        ui:Destroy()
    end
    self.left_item = {}
end

function c:RemoveAllItemInRight()
    for id in pairs(self.right_item) do
        self:RemoveItemInRight(id)
    end
end

function c:SetLeftItemLv(inst_id,big,small)
    local ui = self.left_item[inst_id]
    if ui then
        ui.btn.big.Text = '+' .. big
        ui.btn.small.Text = '+' .. small
    end
end

function c:AddItemInRight(id,icon,quality,name,desc,num)
    local ui = hotpot:CloneInst_Loop(self.insts.right_scrollitem)
    ui.Parent = self.insts.right_ScrollingFrame
    ui.Visible = true
    ui.Name = id
    ui.btn.board.icon.Image = icon
    ui.btn.name.Text = name
    ui.btn.rate.Text = desc
    ui.btn.num.Text = 'x' .. num
    
    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        color:Clone().Parent = ui.btn.board
        color:Clone().Parent = ui.btn.board.UIStroke
    end

    ui.btn.MouseButton1Click:Connect(function()
        if self.__right_handle then
            self.__right_handle(self.__right_obj,id)
        end
    end)

    self.right_item[id] = ui
end

function c:RemoveItemInRight(id)
    local ui = self.right_item[id]
    if ui then
        ui:Destroy()
        self.right_item[id] = nil
    end
end

function c:SetRightItemNum(id,num)
    local ui = self.right_item[id]
    if ui then
        ui.btn.num.Text = 'x' .. num
    end
end

function c:SetCenterRelics(icon,quality)
    local ui = self.insts.center_relicssolt
    ui.icon.Image = icon
    
    local uig = ui:FindFirstChildOfClass('UIGradient')
    if uig then
        uig:Destroy()
        uig = nil
    end
    uig = ui.UIStroke:FindFirstChildOfClass('UIGradient')
    if uig then
        uig:Destroy()
        uig = nil
    end

    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        color:Clone().Parent = ui
        color:Clone().Parent = ui.UIStroke
    end
end

function c:SetCenterLv(big,small)
    self.insts.center_Lvbig.Text = big
    self.insts.center_Lvsmall.Text = small
end

function c:SetCenterForgeStoneNum(num)
    self.insts.center_forgeStoneNum.Text = num
end

function c:SetCenterForgeStoneInfo(icon,quality)
    self.insts.forgeStone.icon.Image = icon
    local uig = self.insts.forgeStone:FindFirstChildOfClass('UIGradient')
    if uig then
        uig:Destroy()
        uig = nil
    end
    uig = self.insts.forgeStone.UIStroke:FindFirstChildOfClass('UIGradient')
    if uig then
        uig:Destroy()
        uig = nil
    end

    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        color:Clone().Parent = self.insts.forgeStone
        color:Clone().Parent = self.insts.forgeStone.UIStroke
    end
end

function c:SetCenterGemsNum(num)
    self.insts.center_gemsNum.Text = num
end

function c:SetCenterSuccessRate(rate)
    self.insts.center_successRate.Text = rate
end

function c:SetCenterOtherRate(rate)
    self.insts.center_otherRate.Text = rate
end

function c:SetCenterSoltInfo(solt,icon,quality)
    local ui = self.center_solt[solt]
    ui.icon.Image = icon
    
    local uig = ui:FindFirstChildOfClass('UIGradient')
    if uig then
        uig:Destroy()
        uig = nil
    end
    uig = ui.UIStroke:FindFirstChildOfClass('UIGradient')
    if uig then
        uig:Destroy()
        uig = nil
    end

    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        color:Clone().Parent = ui
        color:Clone().Parent = ui.UIStroke
    end
end

function c:PlayTips(success)
    if success then
        self.insts.center_tips.Text = 'Success'
        self.insts.center_tips.TextColor3 = Color3.new(0,1,0)
    else
        self.insts.center_tips.Text = 'Fail'
        self.insts.center_tips.TextColor3 = Color3.new(1,0,0)
    end
    TweenHelper:PlayTween(
        self.insts.center_tips,
        tipsInfo,
        {Size = UDim2.fromScale(0.384,0.085)},
        function()
            wait(1)
            self.insts.center_tips.Size = UDim2.fromScale(0,0)
        end
    )
end

function c:PlayValueTips(str)
    local ui = self.insts.valuetips:Clone()
    ui.Parent = self.insts.valuetips.Parent
    ui.Text = str
    ui.Visible = true
    TweenHelper:PlayTween(
        self.insts.center_tips,
        tipsInfo,
        {Size = UDim2.fromScale(0.384,0.085)},
        function()
            wait(1)
            ui:Destroy()
        end
    )
end

function c:PlayForgeAnimation()
    self.track:Play()
end

function c:BindLeftItemClickHandle(obj,handle)
    self.__left_obj = obj
    self.__left_handle = handle
end

function c:BindRightItemClickHandle(obj,handle)
    self.__right_obj = obj
    self.__right_handle = handle
end

function c:BindCenterSoltClickHandle(obj,handle)
    for k,v in ipairs(self.center_solt)do
        local pos = k
        v.MouseButton1Click:Connect(function()
            handle(obj,pos)
        end)
    end
end

function c:BindForgeBtnClickHandle(obj,handle)
    self.insts.center_btn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindCloseBtnClickHandle(obj,handle)
    self.__hide_obj = obj
    self.__hide_handle = handle
end

function c:BindMouseEnterItemHandle(obj,handle)
    self.item_mouse_enter_obj = obj
    self.item_mouse_enter_handle = handle
end

function c:BindCenterMouseEnterHandle(obj,handle)
    self.center_mouse_enter_obj = obj
    self.center_mouse_enter_handle = handle
end

return c