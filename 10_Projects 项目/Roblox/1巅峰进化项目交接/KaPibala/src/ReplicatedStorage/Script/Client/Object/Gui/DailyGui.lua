local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class DailyGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'  
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'      
    ---@type Frame		
	c.insts.list = 'Frame.bg.list'    
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
    local ui = hotpot:GetPath_Loop('ui.DailyGui',_G.Resource)
    c.super.ctor(self,ui)

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

function c:SetDailyGuiInfo(info)
    for k,v in ipairs(info)do
        local idx = k
        local ui = self.insts.list:FindFirstChild(tostring(k))
        -- ui.btn.board.Image = hotpot.pro_cfg.quality[v.quality].board
        local color = qualityColor:FindFirstChild(tostring(v.quality))
        color:Clone().Parent = ui.btn.board
        color:Clone().Parent = ui.btn.board.UIStroke
        ui.btn.icon.Image = v.icon
        ui.btn.num.Text = 'x'..big_number:ToString(v.num)
        ui.btn.btn.MouseButton1Click:Connect(function()
            if self.__item_handle then
                self.__item_handle(self.__item_obj,idx)
            end
        end)
    end
end

---@param state number @1:未领取 2:已领取 3:可领取
function c:SetItemState(id,state)
    local ui = self.insts.list:FindFirstChild(tostring(id))
    if not ui then
        return
    end
    if state == 1 then
        ui.btn.Image = 'rbxassetid://137467217454471'
        ui.btn.top.Visible = false
        ui.btn.btn.Visible = false
        ui.btn.cd.Visible = false
    elseif state == 2 then
        ui.btn.Image = 'rbxassetid://137467217454471'
        ui.btn.btn.Visible = false
        ui.btn.top.Visible = true
        ui.btn.cd.Visible = false
    elseif state == 3 then
        ui.btn.Image = 'rbxassetid://111424340077825'
        ui.btn.top.Visible = false
        ui.btn.btn.Visible = true
        ui.btn.cd.Visible = false
    end 
end

function c:SetItemCD(id,cd)
    -- local ui = self.insts.list:FindFirstChild(tostring(id))
    -- if not ui then
    --     return
    -- end
    -- if cd <= 0 then
    --     self:SetItemState(id,3)
    --     ui.btn.cd.Visible = false
    -- else
    --     ui.btn.cd.Visible = true
    --     ui.btn.cd.info.Text = big_number:GetTime(cd)
    -- end
    self.insts.cd.Text = big_number:GetTime(cd)
    if cd <= 0 then
        self.insts.cd.Text = ''
    end
end

function c:BindItemClickHandle(obj,handle)
    self.__item_handle = handle
    self.__item_obj = obj
end

return c