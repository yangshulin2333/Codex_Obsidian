local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()

local tween_info = TweenInfo.new(0.1)

---@class RewardGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame
	c.insts.Frame = 'Frame'
    ---@type Frame		
	c.insts.list = 'Frame.list'    
    ---@type Frame		
	c.insts.item = 'Frame.list.item'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.RewardGui',_G.Resource)
    c.super.ctor(self,ui)

    self.reward_list = {}
    self.len = 0
end

function c:PlayReward(icon,num,name,quality)
    local list = {icon = icon,num = num,name = name,quality = quality}
    table.insert(self.reward_list,list)
    self:Play()
end

function c:Play()
    if self.__playing then
        return
    end
    self.__playing = true

    self:AddRenderProcess('render',function()
        while true do
            self:Wait(.1)
            if #self.reward_list == 0 then
                break
            end
            if self.len < 4 then
                local tab = self.reward_list[1]
                table.remove(self.reward_list,1)
                local inst = hotpot:CloneInst_Loop(self.insts.item)
                inst.Visible = true
                inst.bg.Position = UDim2.fromScale(2,0.5)
                inst.Parent = self.insts.list
                self.len = self.len + 1
                inst.bg.UIGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0,hotpot.pro_cfg.quality[tab.quality].color),
                    ColorSequenceKeypoint.new(1,hotpot.pro_cfg.quality[tab.quality].color)
                }
                inst.bg.icon.Image = tab.icon
                inst.bg.num.Text = 'x'..(tab.num)
                inst.bg.name.Text = tab.name
                TweenHelper:PlayTween(
                    inst.bg,
                    tween_info,
                    {Position = UDim2.fromScale(1,0.5)}
                )
                self:AddProcess(function()
                    self:Wait(3)
                    inst:Destroy()
                    self.len = self.len - 1
                end)
            end
        end
        self.__playing = false
    end)

end

return c