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

---@class HalloweenPackGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.pet_btn = 'Frame.bg.petitem.btn'  
    ---@type ImageButton		
	c.insts.relics_btn = 'Frame.bg.relicsitem.btn'     
    ---@type ImageButton		
	c.insts.mount_btn = 'Frame.bg.mountitem.btn'     
    ---@type ImageButton		
	c.insts.close = 'Frame.bg.close'    
    ---@type ImageButton		
	c.insts.btn = 'Frame.bg.btn'    
    ---@type ImageLabel		
	c.insts.tipsFrame = 'Frame.bg.tipsFrame'    
    ---@type ImageLabel		
	c.insts.tipsFrame1 = 'Frame.bg.tipsFrame1'    
    ---@type ImageLabel		
	c.insts.relicstipsFrame = 'Frame.bg.relicstipsFrame'    
    ---@type TextLabel		
	c.insts.cd = 'Frame.bg.cd'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.HalloweenPackGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.insts.close.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    self.insts.pet_btn.MouseEnter:Connect(function()
        local viewSize = workspace.CurrentCamera.ViewportSize
        if self.__pet_item_mouse_enter_handle and self.__pet_item_mouse_enter_obj then
            self.__pet_item_mouse_enter_handle(self.__pet_item_mouse_enter_obj)
        end
        local x = mouse.X
        local y = mouse.Y
        if hotpot.is_mobile then
            x = x + ui.AbsoluteSize.X / 2
        end

        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        local tipSize = self.insts.tipsFrame.AbsoluteSize

        x = math.min(viewSize.X - tipSize.X - 5,x)

        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    self.insts.pet_btn.MouseLeave:Connect(function()
        self:SetPetFrameTipsFrameVisible(false)
    end)
    self.insts.pet_btn.MouseMoved:Connect(function()
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y
        if hotpot.is_mobile then
            x = x + ui.AbsoluteSize.X / 2
        end

        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        local tipSize = self.insts.tipsFrame.AbsoluteSize

        x = math.min(viewSize.X - tipSize.X - 5,x)
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
    end)

    self.insts.relics_btn.MouseEnter:Connect(function()
        if self.__relics_item_mouse_enter_handle and self.__relics_item_mouse_enter_obj then
            self.__relics_item_mouse_enter_handle(self.__relics_item_mouse_enter_obj)
        end
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.relicstipsFrame.Position = UDim2.fromScale(x,y)
    end)
    self.insts.relics_btn.MouseLeave:Connect(function()
        self:SetRelicsFrameTipsFrameVisible(false)
    end)
    self.insts.relics_btn.MouseMoved:Connect(function()
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.relicstipsFrame.Position = UDim2.fromScale(x,y)
    end)

    self.insts.mount_btn.MouseEnter:Connect(function()
        local viewSize = workspace.CurrentCamera.ViewportSize
        if self.__mount_item_mouse_enter_handle and self.__mount_item_mouse_enter_obj then
            self.__mount_item_mouse_enter_handle(self.__mount_item_mouse_enter_obj)
        end
        local x = mouse.X
        local y = mouse.Y
        if hotpot.is_mobile then
            x = x + ui.AbsoluteSize.X / 2
        end

        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        local tipSize = self.insts.tipsFrame1.AbsoluteSize

        x = math.min(viewSize.X - tipSize.X - 5,x)

        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.tipsFrame1.Position = UDim2.fromScale(x,y)
    end)
    self.insts.mount_btn.MouseLeave:Connect(function()
        self:SetTipsFrame1Visible(false)
    end)
    self.insts.mount_btn.MouseMoved:Connect(function()
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y
        if hotpot.is_mobile then
            x = x + ui.AbsoluteSize.X / 2
        end

        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        local tipSize = self.insts.tipsFrame1.AbsoluteSize

        x = math.min(viewSize.X - tipSize.X - 5,x)
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.tipsFrame1.Position = UDim2.fromScale(x,y)
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

function c:SetCD(cd)
    self.insts.cd.Text = big_number:GetTime(cd)
end

--设置petFrame的TipsFrame的显示
function c:SetPetFrameTipsFrameVisible(vis)
    self.insts.tipsFrame.Visible = vis
end

--设置petFrame的TipsFrame的信息
function c:SetPetFrameTipsFrameInfo(name,atk,quality)
    self.insts.tipsFrame.name.Text = name
    self.insts.tipsFrame.atk.num.Text = '+' .. big_number:ToString(atk)
    self.insts.tipsFrame.quality.Text = hotpot.pro_cfg.quality[quality].name
    self.insts.tipsFrame.quality.TextColor3 = hotpot.pro_cfg.quality[quality].color
end

--设置relicsFrame的TipsFrame的显示
function c:SetRelicsFrameTipsFrameVisible(vis)
    self.insts.relicstipsFrame.Visible = vis
end

--设置tipsInfo
function c:SetTipsInfo(name,list,quality)
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
end

function c:SetTipsFrame1Visible(vis)
    self.insts.tipsFrame1.Visible = vis
end

function c:SetTipsFrame1Info(name,speed)
    self.insts.tipsFrame1.name.Text = name
    self.insts.tipsFrame1.speed.Text = string.format('Speed  + %s%%',speed)
end

function c:BindPetBtnMouseEnterHandle(obj,handle)
    self.__pet_item_mouse_enter_handle = handle
    self.__pet_item_mouse_enter_obj = obj
end

function c:BindRelicsBtnMouseEnterHandle(obj,handle)
    self.__relics_item_mouse_enter_handle = handle
    self.__relics_item_mouse_enter_obj = obj
end

function c:BindMountBtnMouseEnterHandle(obj,handle)
    self.__mount_item_mouse_enter_handle = handle
    self.__mount_item_mouse_enter_obj = obj
end

function c:BindBtnClickHandle(obj,handle)
    self.insts.btn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c