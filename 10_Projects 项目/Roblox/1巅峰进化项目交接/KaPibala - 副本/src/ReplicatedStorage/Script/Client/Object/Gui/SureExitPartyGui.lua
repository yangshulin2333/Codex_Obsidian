local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)

---@class SureExitPartyGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageButton		
	c.insts.SureBtn = 'Frame.bg.SureBtn'    
    ---@type ImageButton		
	c.insts.cancelBtn = 'Frame.bg.cancelBtn'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.SureExitPartyGui',_G.Resource)
    c.super.ctor(self,ui)

    self.insts.cancelBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    self.insts.SureBtn.MouseButton1Click:Connect(function()
        hotpot.event_manager:Fire('partybackToLobby')
        self:AddProcess(function()
            local count = 10
            while true do
                ui_manager.ui_list.tips_gui:TipsMessage('Teleporting....')
                self:Wait(.8)
                count = count - 1
                if count <= 0 then
                    break
                end
            end
        end)
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

function c:BindSureBtnClickHandle(obj,handle)
end

return c