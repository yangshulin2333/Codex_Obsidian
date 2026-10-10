local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)

---@class TaskGui:HotpotScreenBase
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
    ---@type TextLabel		
	c.insts.cd = 'Frame.bg.cd'    

end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.TaskGui',_G.Resource)
    c.super.ctor(self,ui)

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

--设置倒计时
function c:SetCD(time_)
    self.insts.cd.Text = big_number:TransformDateToString(time_)
end

--向scorll添加子项
function c:AddItemInScroll(id,name,list)
    local ui = hotpot:CloneInst_Loop(self.insts.scroll_item)
    ui.Visible = true
    ui.Parent = self.insts.ScrollingFrame
    ui.Name = id
    ui.bg.title.Text = name
    for k,v in ipairs(list)do
        local c_ui = hotpot:CloneInst_Loop(ui.bg.list.item)
        c_ui.Visible = true
        c_ui.Parent = ui.bg.list
        c_ui.icon.Image = v.icon
        c_ui.num.Text = 'x' .. v.num
        c_ui.Name = 'cItem'
        c_ui.Image = hotpot.pro_cfg.quality[v.quality].board
    end
    self.item_list[id] = ui

    ui.bg.btn.MouseButton1Click:Connect(function()
        if self.__item_click_handle and self.__item_click_obj then
            self.__item_click_handle(self.__item_click_obj,id)
        end
    end)
end

---设置奖励数量
function c:SetItemRewardNum(id,num)
    local ui = self.item_list[id]
    if not ui then
        return
    end
    ui.bg.list.cItem.num.Text = 'x' .. num
end

--设置item进度
function c:SetItemPro(id,now,max)
    local ui = self.item_list[id]
    if not ui then
        return
    end
    ui.bg.pro.Text = now .. '/' .. max
end

--设置item状态
---@param state number @1 可领取 2 已领取 3 未完成
function c:SetItemState(id,state)
    local ui = self.item_list[id]
    if not ui then
        return
    end
    if state == 1 then
        ui.bg.notDone.Visible = false
        ui.bg.claimed.Visible = false
        ui.bg.btn.Visible = true
        ui.bg.Image = 'rbxassetid://129680592692145'
        ui.bg.show.Image = 'rbxassetid://85409214104221'
    elseif state == 2 then
        ui.bg.notDone.Visible = false
        ui.bg.claimed.Visible = true
        ui.bg.btn.Visible = false
        ui.bg.Image = 'rbxassetid://73747794494190'
        ui.bg.show.Image = 'rbxassetid://82592653162483'
    elseif state == 3 then
        ui.bg.notDone.Visible = true
        ui.bg.claimed.Visible = false
        ui.bg.btn.Visible = false
        ui.bg.Image = 'rbxassetid://73747794494190'
        ui.bg.show.Image = 'rbxassetid://82592653162483'
    end
end

--移除所有子项
function c:RemoveAllItem()
    for k,v in pairs(self.item_list)do
        v:Destroy()
    end
    self.item_list = {}
end

--绑定按钮点击事件
function c:BindBtnClickHandle(obj,handle)
    self.__item_click_handle = handle
    self.__item_click_obj = obj
end

return c