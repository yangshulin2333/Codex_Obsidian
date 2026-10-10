local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)

---@class MapScrollShopGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.close = 'Frame.bg.close'   
    ---@type ImageLabel		
	c.insts.item1 = 'Frame.bg.list.item1' 
    ---@type ImageLabel		
	c.insts.item2 = 'Frame.bg.list.item2'    
    ---@type ImageLabel		
	c.insts.item3 = 'Frame.bg.list.item3'    
    ---@type ImageLabel		
	c.insts.item4 = 'Frame.bg.list.item4'        
    ---@type TextLabel		
	c.insts.cd = 'Frame.bg.cd'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.MapScrollShopGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.item_list = {
        self.insts.item1,
        self.insts.item2,
        self.insts.item3,
        self.insts.item4,
    }
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

function c:SetItemBtnVisible(id,vis)
    local ui = self.item_list[id]
    if ui then
        ui.bg.btn.Visible = vis
        ui.bg.sellOut.Visible = not vis
    end
end

function c:SetCD(cd)
    self.insts.cd.Text = big_number:TransformDateToString(cd)

end

function c:BindItemBtnClickHandle(obj,handle)
    for k,v in ipairs(self.item_list)do
        local btn = v.bg.btn
        local id = k
        btn.MouseButton1Click:Connect(function()
            handle(obj,id)
        end)
    end
end

return c
