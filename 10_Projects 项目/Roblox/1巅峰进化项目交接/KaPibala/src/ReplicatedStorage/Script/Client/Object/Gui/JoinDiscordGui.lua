local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)

---@class JoinDiscordGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

c.insts = {}
---@type Frame		
c.insts.Frame = 'Frame'    
---@type ImageButton		
c.insts.close = 'Frame.bg.close'    
---@type TextBox		
c.insts.TextBox = 'Frame.bg.input.TextBox'    
---@type ImageButton		
c.insts.btn = 'Frame.bg.btn'    

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.JoinDiscordGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.insts.close.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    self.insts.btn.MouseButton1Click:Connect(function()
        local text = self.insts.TextBox.Text
        if text == '' then
            return
        end
        local re,msg = hotpot.function_manager:Invoke('verifyJoinDiscord',text)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage(msg,'success')
        else
            ui_manager.ui_list.tips_gui:TipsMessage(msg,'fail')
        end
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

return c