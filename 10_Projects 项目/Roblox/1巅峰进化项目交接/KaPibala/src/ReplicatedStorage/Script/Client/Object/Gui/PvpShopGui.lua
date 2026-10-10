local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type BigNumberHelper
local BigNumberHelper = hotpot.load.BigNumberHelper()

local tweenInfo = TweenInfo.new(0.2)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class PvpShopGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GeInsts()
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
    ---@type TextLabel		
	c.insts.coinnum = 'Frame.bg.coin.num'    
    ---@type TextLabel		
	c.insts.cd = 'Frame.bg.cd'    
end
GeInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.PvpShopGui',_G.Resource)
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

function c:SetCoin(num)
    self.insts.coinnum.Text = BigNumberHelper:ToString(num)
end

function c:SetCd(cd)
    self.insts.cd.Text = 'Refresh:'..BigNumberHelper:TransformDateToString(cd)
end

function c:AddItemInScroll(id,name,icon,quality,price,num)
    local ui = hotpot:CloneInst_Loop(self.insts.scroll_item)
    ui.Parent = self.insts.ScrollingFrame
    ui.Visible = true
    ui.bg.name.Text = name
    ui.bg.board.icon.Image = icon
    ui.bg.btn.price.Text = BigNumberHelper:ToString(price)
    ui.Name = id
    ui.bg.board.num.Text = 'x'..BigNumberHelper:ToString(num)

    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        color:Clone().Parent = ui.bg.board
        color:Clone().Parent = ui.bg.board.UIStroke
    end

    self.item_list[id] = ui

    ui.bg.btn.MouseButton1Click:Connect(function()
        if self.item_handle and self.item_obj then
            self.item_handle(self.item_obj,id)
        end
    end)
end

function c:SetItemLimit(id,now,max)
    local ui = self.item_list[id]
    if ui then
        ui.bg.board.limit.Text = string.format('%d/%d',now,max)
    end
end

function c:BindItemBtnClickHandle(obj,handle)
    self.item_handle = handle
    self.item_obj = obj
end

return c