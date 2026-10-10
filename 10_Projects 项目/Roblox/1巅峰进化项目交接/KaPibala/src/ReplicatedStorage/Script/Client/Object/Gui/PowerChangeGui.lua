local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()

local info = TweenInfo.new(0.5)

---@class PowerChangeGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

c.insts = {}
---@type Frame		
c.insts.Frame = 'Frame'  
---@type Frame		
c.insts.bg = 'Frame.bg'     
---@type TextLabel		
c.insts.power = 'Frame.bg.power'     
---@type TextLabel		
c.insts.add = 'Frame.bg.add'    

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.PowerChangeGui',_G.Resource)
    c.super.ctor(self,ui)
end

function c:PlayPower(old,new)
    spawn(function()
        if new == old then
            return
        end
    
        self.insts.bg.Size = UDim2.fromScale(0,0)
        self.insts.bg.Visible = true
        
        TweenHelper:PlayTween(
            self.insts.bg,
            info,
            {Size = UDim2.fromScale(0.442,0.081)},
            function()
                wait(3)
                self.insts.bg.Size = UDim2.fromScale(0,0)
                self.insts.bg.Visible = false
            end
        )
    
        wait(0.5)
    
        if new > old then
            local sub = new - old
            self.insts.add.Text = '+'..big_number:ToString(sub)
            self.insts.add.TextColor3 = Color3.fromRGB(0,255,0)
        else
            local sub = old - new
            self.insts.add.Text = '-'..big_number:ToString(sub)
            self.insts.add.TextColor3 = Color3.fromRGB(255,0,0)
        end

        local sub = new - old
        sub = math.floor(sub / 4)
        for i = 1,4 do
            if i == 4 then
                self.insts.power.Text = big_number:ToString(new)
            else
                self.insts.power.Text = big_number:ToString(old + sub * i)
            end
            wait(.1)
        end
    end)
end

return c