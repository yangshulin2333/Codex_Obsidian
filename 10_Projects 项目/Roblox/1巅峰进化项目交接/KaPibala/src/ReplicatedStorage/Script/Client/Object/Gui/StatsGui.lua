local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type Players
local players = game:GetService('Players')
---@type Player
local player = players.LocalPlayer
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local exp_str = 'EXP: %s/%s (%.2f%%)'
local tweenInfo = TweenInfo.new(0.2)

---@class StatsGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'    

    ---@type ImageLabel		
	c.insts.left = 'Frame.bg.left'    
    ---@type Model		
	c.insts.left_Rig = 'Frame.bg.left.ViewportFrame.WorldModel.Rig'    
    ---@type Frame		
	c.insts.left_fg = 'Frame.bg.left.bg.fg'    
    ---@type TextLabel		
	c.insts.left_num = 'Frame.bg.left.bg.num'    
    ---@type TextLabel		
	c.insts.left_lv = 'Frame.bg.left.bg.lv'    
    ---@type TextLabel		
	c.insts.left_name = 'Frame.bg.left.name'    

    ---@type Frame		
	c.insts.right = 'Frame.bg.right'    
    ---@type TextLabel		
	c.insts.right_chaName = 'Frame.bg.right.chaName'    
    ---@type TextLabel		
	c.insts.right_hp = 'Frame.bg.right.hp'    
    ---@type TextLabel		
	c.insts.right_dmg = 'Frame.bg.right.dmg'    
    ---@type TextLabel		
	c.insts.right_speed = 'Frame.bg.right.speed'    
    ---@type TextLabel		
	c.insts.right_playTime = 'Frame.bg.right.playTime'    
    ---@type TextLabel		
	c.insts.right_openEgg = 'Frame.bg.right.openEgg'    
    ---@type TextLabel		
	c.insts.right_totalDmg = 'Frame.bg.right.totalDmg'    
    ---@type TextLabel		
	c.insts.right_monsterKill = 'Frame.bg.right.monsterKill'   
    ---@type TextLabel		
	c.insts.power = 'Frame.bg.right.power'    

    ---@type ImageButton		
	c.insts.joinPartyBtn = 'Frame.bg.joinPartyBtn'    
    ---@type ImageButton		
	c.insts.invitePartyBtn = 'Frame.bg.invitePartyBtn'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('PlayerGui.StatsGui',player)
    c.super.ctor(self,ui,true)

    -- self.part_fol = self.insts.left_Rig:WaitForChild('Folder')
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

function c:SetPlayerName(name)
    self.insts.left_name.Text = name
end

function c:SetLv(lv,icon)
    self.insts.left_lv.Text = 'Level '..lv
    self.insts.left_lv.ImageLabel.Image = icon or ''
end

function c:SetExp(now,max)
    self.insts.left_fg.Size = UDim2.fromScale(math.clamp(now/max,0,1),1)
    self.insts.left_num.Text = string.format(
        exp_str,
        big_number:ToString(now),
        big_number:ToString(max),
        now/max*100
    )
end

function c:SetRightCharName(name)
    self.insts.right_chaName.Text = name
end

function c:SetRightHp(hp)
    self.insts.right_hp.num.Text = 'HP: '..big_number:ToString(hp)
end

function c:SetRightDmg(dmg)
    self.insts.right_dmg.num.Text = 'Damage: '.. big_number:ToString(dmg)
end

function c:SetRightSpeed(speed)
    self.insts.right_speed.num.Text = 'Speed: '..string.format('%.1f',speed)
end

function c:SetRightPlayTime(time)
    self.insts.right_playTime.Text = 'Play Time: '.. big_number:GetTime(time)
end

function c:SetRightPower(power)
    self.insts.power.num.Text = 'Power: '..big_number:ToString(power)
end

function c:SetRightOpenEgg(openEgg)
    self.insts.right_openEgg.Text = 'Opened Eggs: '..openEgg
end

function c:SetRightTotalDmg(totalDmg)
    self.insts.right_totalDmg.Text = 'Total Damage: '.. big_number:ToString(totalDmg)
end

function c:SetRightMonsterKill(monsterKill)
    self.insts.right_monsterKill.Text = 'Monster Killed: '..monsterKill
end

function c:SetJoinPartyBtnVisible(visible)
    self.insts.joinPartyBtn.Visible = visible
end

function c:SetInvitePartyBtnVisible(visible)
    self.insts.invitePartyBtn.Visible = visible
end

function c:BindJoinPartyBtnClickHandle(obj,handle)
    self.insts.joinPartyBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindInvitePartyBtnClickHandle(obj,handle)
    self.insts.invitePartyBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end


return c