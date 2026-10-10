local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class OnlineGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'   
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type Frame		
	c.insts.list1 = 'Frame.bg.list1'     
    ---@type Frame		
	c.insts.list2 = 'Frame.bg.list2'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'    
    ---@type ImageButton		
	c.insts.jump = 'Frame.bg.jump'    
end
GetInsts()

function c.new()
    return c()
end

function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.OnlineGui',_G.Resource)
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

function c:SetOnlineInfo(info)
    for k,v in ipairs(info)do
        local ui 
        if k <= 8 then
            ui = self.insts.list1:FindFirstChild(tostring(k))
        else
            ui = self.insts.list2:FindFirstChild(tostring(k))
        end
        local idx = k
        -- ui.bg.board.Image = hotpot.pro_cfg.quality[v.quality].board
        local color = qualityColor:FindFirstChild(tostring(v.quality))
        color:Clone().Parent = ui.bg.board
        color:Clone().Parent = ui.bg.board.UIStroke
        ui.bg.icon.Image = v.icon
        ui.bg.num.Text = 'x'.. big_number:ToString(v.num)

        ui.bg.btn.MouseButton1Click:Connect(function()
            if self.__item_handle and self.__item_obj then
                self.__item_handle(self.__item_obj,k)
            end
        end)
    end
end

---@param state number @1已领取 2可领取 3未领取
function c:SetItemState(id,state,time_)
    local ui
    if id <= 8 then
        ui = self.insts.list1:FindFirstChild(tostring(id))
    else
        ui = self.insts.list2:FindFirstChild(tostring(id))
    end

    if state == 1 then
        ui.bg.claimed.Visible = true
        ui.bg.time_.Visible = false
        ui.bg.btn.Visible = false
    elseif state == 2 then
        ui.bg.claimed.Visible = false
        ui.bg.time_.Visible = false
        ui.bg.btn.Visible = true
    else
        ui.bg.time_.Text = big_number:TransformDateToString(time_)
        ui.bg.claimed.Visible = false
        ui.bg.time_.Visible = true
        ui.bg.btn.Visible = false
    end
end

function c:BindItemClickHandle(obj,handle)
    self.__item_handle = handle
    self.__item_obj = obj
end

function c:BindJumpBtnClickHandle(obj,handle)
    self.insts.jump.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c