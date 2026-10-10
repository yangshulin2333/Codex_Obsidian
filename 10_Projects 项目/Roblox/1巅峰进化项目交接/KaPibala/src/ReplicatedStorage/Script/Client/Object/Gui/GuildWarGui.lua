local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local tweenInfo = TweenInfo.new(0.2)

---@class GuildWarGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'    

    ---@type Frame		
	c.insts.topBtns = 'Frame.bg.topBtns'    

    ---@type Frame		
	c.insts.InfoFrame = 'Frame.bg.InfoFrame'    

    ---@type Frame		
	c.insts.Rank1Frame = 'Frame.bg.Rank1Frame'    
    ---@type ScrollingFrame		
	c.insts.Rank1FrameScrollingFrame = 'Frame.bg.Rank1Frame.PlayerInfo.ScrollingFrame'   
    ---@type Frame		
	c.insts.Rank1Frameitem = 'Frame.bg.Rank1Frame.PlayerInfo.ScrollingFrame.item'    
    
    ---@type Frame		
	c.insts.Rank2Frame = 'Frame.bg.Rank2Frame'    
    ---@type ScrollingFrame		
	c.insts.Rank2FrameScrollingFrame = 'Frame.bg.Rank2Frame.list.ScrollingFrame'  
    ---@type Frame		
	c.insts.Rank2Frameitem = 'Frame.bg.Rank2Frame.list.ScrollingFrame.item'      
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.GuildWarGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.rank1_items = {}
    self.rank2_items = {}

    self:Init()
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

function c:Init()
    local frames = {self.insts.InfoFrame,self.insts.Rank1Frame,self.insts.Rank2Frame}
    local topBtns = self.insts.topBtns
    local btns = {
        topBtns:FindFirstChild('btn1'),
        topBtns:FindFirstChild('btn2'),
        topBtns:FindFirstChild('btn3'),
    }
    for k,v in ipairs(btns)do
        ---@type ImageButton
        local btn = v:FindFirstChild('btn')
        local str = btn:GetAttribute('Frame')
        local uiFrame = self.insts[str]
        btn.MouseButton1Click:Connect(function()
            for _,frame in ipairs(frames)do
                frame.Visible = frame == uiFrame
            end
            for _,b in ipairs(btns)do
                b.btn.select.Visible = btn == b.btn
                b.btn.TextLabel.TextColor3 = ((btn == b.btn) and Color3.new(1,1,1) or Color3.new(0.7,0.7,0.7))
            end
        end)
    end

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)
end

function c:ClearAllRank1Item()
    for ui,_ in pairs(self.rank1_items)do
        ui:Destroy()
    end
    self.rank1_items = {}
end

function c:ClearAllRank2Item()
    for ui,_ in pairs(self.rank2_items)do
        ui:Destroy()
    end
    self.rank2_items = {}
end

function c:AddItemInRank1(rank,name,kill)
    local ui = hotpot:CloneInst_Loop(self.insts.Rank1Frameitem)
    ui.Visible = true
    ui.Parent = self.insts.Rank1FrameScrollingFrame
    ui.rank.Text = rank
    ui.name.Text = name
    ui.kill.Text = kill
    ui.LayoutOrder = -kill

    self.rank1_items[ui] = true
end

function c:AddItemInRank2(id,rank,lv,flag,icon,name,member,kill)
    local inst = hotpot:CloneInst_Loop(self.insts.Rank2Frameitem)
    inst.Parent = self.insts.Rank2FrameScrollingFrame
    inst.Visible = true
    inst.LayoutOrder = rank
    inst.bg.rank.Text = rank
    inst.bg.lv.Text = lv
    inst.bg.flag.Image = flag
    inst.bg.flag.icon.Image = icon
    inst.bg.name.Text = name
    inst.bg.member.Text = member
    inst.bg.kill.Text = kill
    inst.LayoutOrder = -kill

    self.rank2_items[inst] = true
end

return c