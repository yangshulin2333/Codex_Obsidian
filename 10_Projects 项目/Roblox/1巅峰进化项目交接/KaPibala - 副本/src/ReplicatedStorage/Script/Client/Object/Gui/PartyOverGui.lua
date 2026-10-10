local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type big_number
local big_number = hotpot.load.BigNumberHelper()

local tweenInfo = TweenInfo.new(0.2)

---@class PartyOverGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type TextLabel		
	c.insts.title = 'Frame.bg.title'    
    ---@type ImageLabel		
	c.insts.icon = 'Frame.bg.icon'    
    ---@type TextLabel		
	c.insts.name = 'Frame.bg.name'    
    ---@type TextLabel		
	c.insts.lv = 'Frame.bg.lv'    
    ---@type TextLabel		
	c.insts.kill = 'Frame.bg.kill'    
    ---@type TextLabel		
	c.insts.dmg = 'Frame.bg.dmg'    
    ---@type TextLabel		
	c.insts.time = 'Frame.bg.time'    
    ---@type ImageLabel		
	c.insts.list = 'Frame.bg.list'    
    ---@type Frame		
	c.insts.list_item = 'Frame.bg.list.item' 
    ---@type ImageButton		
	c.insts.btn = 'Frame.bg.btn'   
    ---@type ImageButton		
	c.insts.againbtn = 'Frame.bg.againbtn'     
    
    ---@type TextLabel		
	c.insts.voteTips = 'Frame.bg.voteTips'    
    ---@type Frame		
	c.insts.againFrame = 'Frame.bg.againFrame'   
    ---@type ImageLabel		
	c.insts.againitem = 'Frame.bg.againFrame.item'     
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.PartyOverGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.item_list = {}
    self.vote_list = {}
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

function c:SetInfo(info)
    if info.success then
        self.insts.title.Text = 'Success!'
        self.insts.title.TextColor3 = Color3.new(0,1,0)
    else
        self.insts.title.Text = 'Fail!'
        self.insts.title.TextColor3 = Color3.new(1,0,0)
    end

    self.insts.icon.Image = info.icon
    self.insts.name.Text = info.name
    self.insts.lv.Text = 'Level '..info.lv
    self.insts.kill.Text = 'Killed Monster:'..info.kill
    self.insts.dmg.Text = 'Damage Dealt:'..big_number:ToString(info.dmg)
    if info.time then
        self.insts.time.Text = 'Clear Time:'..info.time..'s'
    else
        self.insts.time.Text = ''
    end

    local reward = info.reward
    if not reward then
        return
    end

    self:AddProcess(function()
        self:Wait(1)
        for k,v in ipairs(reward)do
            local ui = hotpot:CloneInst_Loop(self.insts.list_item)
            ui.Parent = self.insts.list
            ui.Visible = true
            ui.icon.Image = v.icon
            ui.num.Text = v.num
            TweenHelper:PlayTween(
                ui,
                TweenInfo.new(0.35),
                {Size = UDim2.fromScale(0.5,0.5)}
            )
            self.item_list[ui] = true
            self:Wait(.5)
        end
    end)

end

function c:ClearInfo()
    for ui,_ in pairs(self.item_list)do
        ui:Destroy()
    end
    self.item_list = {}
end

function c:SetCD(cd)
    self.insts.againbtn.TextLabel.Text = 'Play Again ('..cd..')'
end

function c:SetVoteTipsVisible(visible)
    self.insts.voteTips.Visible = visible
end

function c:AddItemInAgainFrame(uid,icon)
    if self.vote_list[uid] then
        return
    end
    local ui = hotpot:CloneInst_Loop(self.insts.againitem)
    ui.Parent = self.insts.againFrame
    ui.Visible = true
    ui.Image = icon
    self.vote_list[uid] = ui
end

function c:SetAgainBtnVisible(visible)
    self.insts.againbtn.Visible = visible
end

function c:BindBtnClickHandle(obj,handle)
    self.insts.btn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindAgainBtnClickHandle(obj,handle)
    self.insts.againbtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c