local hotpot = _G.ClientHotpot
---@type TweenHelper
local tweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local info = TweenInfo.new(0.2)
local loopTweenInfo = TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local stopTweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

---@class OpenBoxGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'      

    ---@type ImageLabel		
	c.insts.OpenBg = 'Frame.OpenBg'    
    ---@type ScrollingFrame		
	c.insts.ScrollingFrame = 'Frame.OpenBg.list.ScrollingFrame'    

    ---@type ImageLabel		
	c.insts.SureOpenBG = 'Frame.SureOpenBG'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.SureOpenBG.closeBtn'  
    ---@type ImageButton		
	c.insts.btn = 'Frame.SureOpenBG.btn'   
    ---@type ImageButton		
	c.insts.btnAll = 'Frame.SureOpenBG.btnAll'       
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.OpenBoxGui',_G.Resource)
    c.super.ctor(self,ui)

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:SetSureBgVisible(false)
        ui_manager.ui_list.hud_gui:Show()

        wait(.2)
        self:Hide()
    end)
end

function c:SetSureBgIcon(icon)
    self.insts.SureOpenBG.icon.Image = icon
end

function c:SetOpenBGVisible(vis)
    if vis then
        self.insts.OpenBg.Visible = true
        self.insts.OpenBg.Position = UDim2.fromScale(0.5,-0.2)
        tweenHelper:PlayTween(
            self.insts.OpenBg,
            info,
            {Position = UDim2.fromScale(0.5,0.233)}
        )
    else
        tweenHelper:PlayTween(
            self.insts.OpenBg,
            info,
            {Position = UDim2.fromScale(0.5,-0.2)},
            function()
                self.insts.OpenBg.Visible = false
            end
        )
    end
end

function c:SetSureBgVisible(vis)
    if vis then
        self.insts.SureOpenBG.Visible = true
        tweenHelper:PlayTween(
            self.insts.SureOpenBG,
            info,
            {Position = UDim2.fromScale(0.5,0.5)}
        )
    else
        tweenHelper:PlayTween(
            self.insts.SureOpenBG,
            info,
            {Position = UDim2.fromScale(0.5,0.7)},
            function()
                self.insts.SureOpenBG.Visible = false
            end
        )
    end
end

function c:SetRewardList(list)
    for k,v in ipairs(list)do
        local ui = self.insts.ScrollingFrame:FindFirstChild('item'..k)
        ui.icon.Image = v.icon
        ui.board.UIStroke.Color = hotpot.pro_cfg.quality[v.quality].color
        ui.bg.ImageColor3 = hotpot.pro_cfg.quality[v.quality].color
    end
end

function c:Play(handle)
    local ui = self.insts.ScrollingFrame:FindFirstChild('item1')
    local itemWidth = ui.AbsoluteSize.X

    self.insts.ScrollingFrame.CanvasPosition = Vector2.zero
    local tween = tweenHelper:PlayTween(
        self.insts.ScrollingFrame,
        loopTweenInfo,
        {CanvasPosition = Vector2.new(itemWidth * 95, 0)}
    )
    -- wait(2.5)
    -- tween:Cancel()
    
    -- tweenHelper:PlayTween(
    --     self.insts.ScrollingFrame,
    --     stopTweenInfo,
    --     {CanvasPosition = Vector2.new(itemWidth * 5, 0)}
    -- )
    
    wait(5)
    if handle then
        handle()
    end
    wait(1)

    self:SetOpenBGVisible(false)
    wait(.2)
    ui_manager.ui_list.open_box_gui:Hide()
end

function c:BindBtnClickHandle(obj,handle)
    self.insts.btn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindBtnAllClickHandle(obj,handle)
    self.insts.btnAll.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c