local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)

---@class SkillGui:HotpotScreenBase
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
	c.insts.left = 'Frame.bg.left'    
    ---@type ScrollingFrame		
	c.insts.ScrollingFrame = 'Frame.bg.left.ScrollingFrame'    
    ---@type Frame		
	c.insts.scroll_item = 'Frame.bg.left.ScrollingFrame.item'   
    
    ---@type ImageLabel		
	c.insts.right = 'Frame.bg.right'  
    ---@type ImageLabel		
	c.insts.rightSkillicon = 'Frame.bg.right.iconBoard.icon'    
    ---@type TextLabel		
	c.insts.unlockDesc_info = 'Frame.bg.right.unlockDesc.info'     
    ---@type TextLabel		
	c.insts.skillDesc_info = 'Frame.bg.right.skillDesc.info'     
    ---@type TextLabel		
	c.insts.skillLv = 'Frame.bg.right.skillLv'   
    ---@type ImageLabel		
	c.insts.cost_icon = 'Frame.bg.right.costDesc.icon'      
    ---@type TextLabel		
	c.insts.cost_num = 'Frame.bg.right.costDesc.num'    
    ---@type ImageButton		
	c.insts.upgradeBtn = 'Frame.bg.right.upgradeBtn'   
    ---@type ImageButton		
	c.insts.unequipBtn = 'Frame.bg.right.unequipBtn'     
    ---@type ImageButton		
	c.insts.equipBtn = 'Frame.bg.right.equipBtn'    
    ---@type ImageButton		
	c.insts.unlockBtn = 'Frame.bg.right.unlockBtn'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.SkillGui',_G.Resource)
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

function c:AddItemInScoll(id,icon,name)
    local ui = hotpot:CloneInst_Loop(self.insts.scroll_item)
    ui.Parent = self.insts.ScrollingFrame
    ui.Visible = true
    ui.Name = id
    ui.bg.icon.Image = icon
    ui.name.Text = name
    self.item_list[id] = ui

    ui.bg.MouseButton1Click:Connect(function()
        if self.__item_handle then
            self.__item_handle(self.__item_obj,id)
        end
    end)
end

function c:SetItemSelectVisible(id,vis)
    local ui = self.item_list[id]
    if ui then
        ui.bg.UIStroke.Enabled = vis
    end
end

function c:SetItemEquipVisible(id,vis)
    local ui = self.item_list[id]
    if ui then
        ui.bg.equip.Visible = vis
    end
end

function c:SetRightSkillIcon(icon)
    self.insts.rightSkillicon.Image = icon
end

function c:SetUnlockDesc(unlockDesc)
    self.insts.unlockDesc_info.Text = unlockDesc
end

function c:SetRedVisible(id,vis)
    local ui = self.item_list[id]
    if ui then
        ui.bg.red.Visible = vis
    end
end

function c:SetSkillDesc(desc)
    self.insts.skillDesc_info.Text = desc
end

function c:SetSkillLv(lv)
    self.insts.skillLv.Text = 'LV: '..lv
end

function c:SetCostIcon(icon)
    self.insts.cost_icon.Image = icon
end

function c:SetCostNum(now,need)
    self.insts.cost_num.Text = now..'/'..need
end

function c:SetUnlockBtnVisible(vis)
    self.insts.unlockBtn.Visible = vis
end

function c:SetUpgradeBtnVisible(vis)
    self.insts.upgradeBtn.Visible = vis
end

function c:SetEquipBtnVisible(vis)
    self.insts.equipBtn.Visible = vis
end

function c:SetUnequipBtnVisible(vis)
    self.insts.unequipBtn.Visible = vis
end

function c:BindLeftItemClickHandle(obj,handle)
    self.__item_handle = handle
    self.__item_obj = obj
end

function c:BindUnlockBtnClickHandle(obj,handle)
    self.insts.unlockBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindEquipBtnClickHandle(obj,handle)
    self.insts.equipBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindUnequipBtnClickHandle(obj,handle)
    self.insts.unequipBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindUpgradeBtnClickHandle(obj,handle)
    self.insts.upgradeBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c