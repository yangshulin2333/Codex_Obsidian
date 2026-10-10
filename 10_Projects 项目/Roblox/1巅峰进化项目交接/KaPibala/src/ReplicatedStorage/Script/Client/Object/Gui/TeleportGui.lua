local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)

---@class TeleportGui:HotpotScreenBase
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
	c.insts.item = 'Frame.bg.ScrollingFrame.item'    
    ---@type ImageButton		
	c.insts.close = 'Frame.bg.close'      
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.TeleportGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.item_list = {}

    self.insts.close.MouseButton1Click:Connect(function()
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

function c:AddItemInScroll(id,icon,name)
    local ui = hotpot:CloneInst_Loop(self.insts.item)
    ui.Parent = self.insts.ScrollingFrame
    ui.Visible = true
    ui.btn.Image = icon or ''
    ui.btn.name.Text = name
    ui.btn.MouseButton1Click:Connect(function()
        if self.__item_handle then
            self.__item_handle(self.__item_obj,id)
        end
    end)
    self.item_list[id] = ui
end

function c:SetItemTopVisible(id,vis)
    local ui = self.item_list[id]
    if not ui then
        return
    end
    ui.btn.top.Visible = vis
    ui.btn.name.Visible = not vis
end

function c:BindItemBtnClickHandle(obj,handle)
    self.__item_obj = obj
    self.__item_handle = handle
end

return c