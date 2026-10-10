local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local bigNumber = hotpot.load.BigNumberHelper()
---@type Players
local players = game:GetService('Players')
---@type Player
local player = players.LocalPlayer
---@type Mouse
local mouse = player:GetMouse()

local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)
local tipsStr = "Pet will always be %.0f%% stronger as your best pet!."

---@class NewDailyGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type TextLabel		
	c.insts.tip = 'Frame.bg.tip'    
    ---@type ScrollingFrame		
	c.insts.ScrollingFrame = 'Frame.bg.ScrollingFrame'    
    ---@type Frame		
	c.insts.item = 'Frame.bg.ScrollingFrame.item'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'    
    ---@type ImageLabel		
	c.insts.top = 'Frame.bg.top'    
    ---@type ImageButton		
	c.insts.lostBtn = 'Frame.bg.top.lostBtn'   
    ---@type ImageButton		
	c.insts.recoverBtn = 'Frame.bg.top.recover'    
    ---@type TextLabel		
	c.insts.price = 'Frame.bg.top.recover.price'  
    ---@type TextLabel		
	c.insts.top_info = 'Frame.bg.top.info'   
    
    ---@type ImageLabel		
	c.insts.topDone = 'Frame.bg.topDone'    

    ---@type ImageLabel		
	c.insts.petTips = 'Frame.bg.petTips'    
    ---@type ImageLabel		
	c.insts.petTips2 = 'Frame.bg.petTips2'   
    ---@type ImageLabel		
	c.insts.relicsTips = 'Frame.bg.relicsTips'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.NewDailyGui',_G.Resource)
    c.super.ctor(self,ui)

    self.item_list = {}

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)
end

function c:AddItemInScroll(id,icon,num,quality,title)
    local ui = hotpot:CloneInst_Loop(self.insts.item)
    ui.Parent = self.insts.ScrollingFrame
    ui.Visible = true
    ui.Name = id
    ui.LayoutOrder = id
    ui.btn.icon.Image = icon
    if title then
        ui.btn.icon.titleName.Text = title
        ui.btn.icon.titleName.Visible = true
        if id == 30 then
            ui.btn.icon.titleName.Size = UDim2.fromScale(0.7,0.2)
        end
    else
        ui.btn.icon.titleName.Visible = false
    end
    ui.btn.num.Text = 'x'..bigNumber:ToString(num)
    ui.day.Text = 'Day '..id
    local color = qualityColor:FindFirstChild(quality)
    if color then
        color:Clone().Parent = ui.btn
        color:Clone().Parent = ui.btn.UIStroke
    end
    self.item_list[id] = ui

    ui.claim.MouseButton1Click:Connect(function()
        self.__item_handle(self.__item_obj,id)
    end)

    ui.btn.MouseEnter:Connect(function()
        if self.mouse_enter_handle and self.mouse_enter_obj then
            self.mouse_enter_handle(self.mouse_enter_obj,id)
        end
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.petTips.Position = UDim2.fromScale(x,y)
        self.insts.petTips2.Position = UDim2.fromScale(x,y)
        self.insts.relicsTips.Position = UDim2.fromScale(x,y)
    end)
    ui.btn.MouseLeave:Connect(function()
        self:SetPetTipsVisible(false)
        self:SetPetTips2Visible(false)
        self:SetRelicsTipsVisible(false)
    end)
    ui.btn.MouseMoved:Connect(function()
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.petTips.Position = UDim2.fromScale(x,y)
        self.insts.petTips2.Position = UDim2.fromScale(x,y)
        self.insts.relicsTips.Position = UDim2.fromScale(x,y)
    end)
end

---@param state number @1已领取 2可以领取 3未完成
function c:SetItemState(id,state)
    local ui = self.item_list[id]
    if not ui then
        return
    end
    if state == 1 then
        ui.claim.Visible = false
        ui.notReady.Visible = false
        ui.claimed.Visible = true
    elseif state == 2 then
        ui.claim.Visible = true
        ui.notReady.Visible = false
        ui.claimed.Visible = false
    elseif state == 3 then
        ui.claim.Visible = false
        ui.notReady.Visible = true
        ui.claimed.Visible = false
    end
end

function c:SetTips(day)
    self.insts.tip.Text = 'Your Day Streak Level: '..day
end

function c:SetTopVisible(visible)
    self.insts.top.Visible = visible
end

function c:SetTopDay(day)
    self.insts.top_info.Text = 'Your Day Streak Level: '..day
end  

function c:SetTopPrice(price)
    self.insts.price.Text = price
    self.insts.price.Visible = price > 0
end

function c:SetScrollCenter(id)
    local _,ui = next(self.item_list)
    local size = ui.AbsoluteSize
    local x = size.X

    local dir = x * (id - 3)

    self.insts.ScrollingFrame.CanvasPosition = Vector2.new(dir,0)
end

function c:SetTopDoneVisible(visible)
    self.insts.topDone.Visible = visible
end

function c:SetPetTipsVisible(visible)
    self.insts.petTips.Visible = visible
end

function c:SetPetTips2Visible(visible)
    self.insts.petTips2.Visible = visible
end

function c:SetRelicsTipsVisible(visible)
    self.insts.relicsTips.Visible = visible
end

--设置petFrame的TipsFrame的信息
function c:SetPetFrameTipsFrameInfo(name,atk,quality)
    self.insts.petTips.name.Text = name
    self.insts.petTips.atk.num.Text = '+' .. bigNumber:ToString(atk)
    self.insts.petTips.quality.Text = hotpot.pro_cfg.quality[quality].name
    self.insts.petTips.quality.TextColor3 = hotpot.pro_cfg.quality[quality].color
end

--设置petFrame的TipsFrame2的信息
function c:SetPetFrameTipsFrame2Info(name,atk,quality,per)
    self.insts.petTips2.name.Text = name
    self.insts.petTips2.atk.num.Text = '+' .. bigNumber:ToString(atk)
    self.insts.petTips2.tip.Text = string.format(tipsStr,per)
    self.insts.petTips2.quality.Text = hotpot.pro_cfg.quality[quality].name
    self.insts.petTips2.quality.TextColor3 = hotpot.pro_cfg.quality[quality].color
end

--设置tipsInfo
function c:SetRelicsTipsInfo(name,list,quality,big,small)
    local len = #list
    self.insts.relicsTips.name.Text = name

    for i = 1,7 do
        local color = self.insts.relicsTips.name:FindFirstChild(tostring(i))
        color.Enabled = i == quality
    end

    local ui
    for i = 1,4 do
        ui = self.insts.relicsTips:FindFirstChild(tostring(i))
        ui.Visible = i == len
    end

    ui = self.insts.relicsTips:FindFirstChild(tostring(len))

    for k,v in ipairs(list)do
        local TextLabel = ui:FindFirstChild('info'..k)
        if TextLabel then
            TextLabel.Text = v
        end
    end

    -- local bigUi = self.insts.relicsTips.big
    -- local smallUi = self.insts.relicsTips.small
    -- for i = 1,10 do
    --     local icon = bigUi:FindFirstChild(tostring(i))
    --     icon.ImageColor3 = (big >= i) and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
    -- end
    -- for i = 1,10 do
    --     local icon = smallUi:FindFirstChild(tostring(i))
    --     icon.ImageColor3 = (small >= i) and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
    -- end
end

function c:BindLostBtnClickHandle(obj,handle)
    self.insts.lostBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindRecoverBtnClickHandle(obj,handle)
    self.insts.recoverBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindItemClickHandle(obj,handle)
    self.__item_handle = handle
    self.__item_obj = obj
end

function c:BindMouseEnterHandle(obj,handle)
    self.mouse_enter_handle = handle
    self.mouse_enter_obj = obj
end

return c