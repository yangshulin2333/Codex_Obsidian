local hotpot = _G.ClientHotpot
---@type TweenHelper
local tweenHelper = hotpot.load.TweenHelper()

---@class NewGuideGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

c.insts = {}
---@type Frame		
c.insts.Frame = 'Frame'    
---@type ImageLabel		
c.insts.bg = 'Frame.bg'    
---@type Frame		
c.insts.item = 'Frame.bg.item'    

local list = {
    skill = {icon = 'rbxassetid://114121656307669',name = 'Skill'},
    guild = {icon = 'rbxassetid://133649457600896',name = 'Guild'},
    pvp = {icon = 'rbxassetid://82855199500825',name = 'PVP'},
    stats = {icon = 'rbxassetid://76473250594275',name = 'Stats'},
}
local tempstr = '<font color="rgb(0,255,0)">%s</font>'

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.NewGuideGui',_G.Resource)
    c.super.ctor(self,ui)
end

function c:Play(strList)
    local t = {}
    for str,_ in pairs(strList) do
        local item = hotpot:CloneInst_Loop(self.insts.item)
        item.Parent = self.insts.bg
        item.Visible = true
        item.bg.icon.Image = list[str].icon
        item.bg.info.Text = string.format(tempstr,list[str].name)
        t[item] = true
        wait(1)
    end
    wait(3)
    local overPos = UDim2.fromScale(0.951,0.737)
    tweenHelper:PlayTween(
        self.insts.bg,
        TweenInfo.new(0.5),
        {Position = overPos,Size = UDim2.fromScale(0,0)},
        function()
            self.insts.bg.Visible = false
            for item,_ in pairs(t) do
                item:Destroy()
            end
            self.insts.bg.Visible = true
            self.insts.bg.Position = UDim2.fromScale(0.5,0.5)
            self.insts.bg.Size = UDim2.fromScale(1,1)
        end
    )
end

return c