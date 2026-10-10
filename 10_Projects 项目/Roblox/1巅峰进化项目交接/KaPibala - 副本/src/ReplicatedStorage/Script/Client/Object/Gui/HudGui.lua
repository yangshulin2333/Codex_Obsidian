local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()
local Debris = game:GetService('Debris')
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()
---@type BtnHelper
local BtnHelper = hotpot.load.BtnHelper()

local mobile = hotpot.is_mobile
local exp_str = 'EXP: %s/%s (%.2f%%)'
local tweenInfo = TweenInfo.new(0.2)
local pumpkin_str = "%s/%s (%.2f%%)"
local cdShow = '%.1f'
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class HudGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageButton		
	c.insts.teleportBtn = 'Frame.rightHide.teleportBtn'       

    ---@type Frame		
	c.insts.expPanel = 'Frame.expPanel'    
     ---@type Frame		
	c.insts.expPanel_bg = 'Frame.expPanel.bg'    
    ---@type Frame		
	c.insts.expPanel_fg = 'Frame.expPanel.bg.fg'  
    ---@type TextLabel		
	c.insts.expPanel_num = 'Frame.expPanel.bg.num'      
    ---@type TextLabel		
	c.insts.expPanel_lv = 'Frame.expPanel.lv'    
    ---@type ImageLabel		
	c.insts.exp_icon = 'Frame.expPanel.bg.show.icon'    
    ---@type ImageLabel		
	c.insts.exp_icon1 = 'Frame.expPanel.bg.show.icon1'   
    ---@type ImageButton		
	c.insts.exp_btn = 'Frame.expPanel.bg.show.btn'  
    ---@type UIGradient		
	c.insts.left_UIGradient = 'Frame.expPanel.bg.show.cricle.left.ImageLabel.UIGradient'  
    ---@type UIGradient		
	c.insts.right_UIGradient = 'Frame.expPanel.bg.show.cricle.right.ImageLabel.UIGradient'  
    ---@type ImageLabel		
	c.insts.exp_guide = 'Frame.expPanel.bg.show.guide'    

    ---@type Frame		
	c.insts.friendPanel = 'Frame.friendPanel'      

    ---@type Frame		
	c.insts.resPanel = 'Frame.resPanel'    
    ---@type TextLabel		
	c.insts.gems_num = 'Frame.resPanel.gems.num'    
    ---@type TextLabel		
	c.insts.wins_num = 'Frame.resPanel.wins.num'   
    ---@type TextLabel		
	c.insts.gems_anima = 'Frame.resPanel.gems.anima'    
    ---@type TextLabel		
	c.insts.wins_anima = 'Frame.resPanel.wins.anima'    
    ---@type Frame		
	c.insts.gemsFrame = 'Frame.resPanel.gems'   
    ---@type Frame		
	c.insts.winsFrame = 'Frame.resPanel.wins'     
    
    ---@type Frame		
	c.insts.leftFrame = 'Frame.leftFrame'    
    ---@type Frame		
	c.insts.rightHide = 'Frame.rightHide'    
    ---@type Frame		
	c.insts.rightBtns = 'Frame.rightBtns'      
    ---@type ImageButton		
	c.insts.bag_btn = 'Frame.rightBtns.bagBtn'
    ---@type ImageButton		
	c.insts.shop_btn = 'Frame.leftFrame.list.shopBtn'       
    ---@type ImageButton		
	c.insts.onlineBtn = 'Frame.rightHide.onlineBtn'    
    ---@type ImageButton		
	c.insts.relicsBtn = 'Frame.rightBtns.relicsBtn'    
    ---@type ImageButton		
	c.insts.openBtn = 'Frame.rightBtns.openBtn'   
    ---@type ImageButton		
	c.insts.dailyBtn = 'Frame.rightHide.dailyBtn'    
    ---@type ImageButton		
	c.insts.settingBtn = 'Frame.rightHide.settingBtn'    
    ---@type ImageButton		
	c.insts.afkBtn = 'Frame.rightBtns.afkBtn'    
    ---@type ImageButton		
	c.insts.startrtpack = 'Frame.startrtpack'    
    ---@type ImageButton		
	c.insts.limitpet = 'Frame.limitpet'     
    ---@type ImageButton		
	c.insts.freePetBtn = 'Frame.leftFrame.freePetBtn' 
    ---@type ImageButton		
	c.insts.taskBtn = 'Frame.leftFrame.list.taskBtn'    
    ---@type ImageButton		
	c.insts.VIPBtn = 'Frame.leftFrame.list.VIPBtn'      
    ---@type ImageLabel		
	c.insts.afk_open = 'Frame.rightBtns.afkBtn.open'     
    ---@type ImageButton		
	c.insts.bpBtn = 'Frame.leftFrame.list.bpBtn'    
    ---@type ImageButton		
	c.insts.taskBtn = 'Frame.leftFrame.list.taskBtn'  
    ---@type ImageButton		
	c.insts.partyBtn = 'Frame.rightHide.partyBtn'   
    ---@type ImageButton		
	c.insts.ExitBtn = 'Frame.rightBtns.ExitBtn'     
    ---@type ImageButton		
	c.insts.StatsBtn = 'Frame.rightHide.StatsBtn'  
    ---@type ImageButton		
	c.insts.joinDiscordBtn = 'Frame.rightHide.joinDiscordBtn'     
    ---@type ImageButton		
	c.insts.mountBtn = 'Frame.rightHide.mountBtn'      
    ---@type ImageButton		
	c.insts.guildBtn = 'Frame.rightHide.guildBtn' 
    ---@type ImageButton		
	c.insts.pvpBtn = 'Frame.rightHide.pvpBtn'       
    
    ---@type ImageLabel		
	c.insts.online_red = 'Frame.rightHide.onlineBtn.red'    
    ---@type ImageLabel		
	c.insts.free_pet_red = 'Frame.leftFrame.freePetBtn.red'   
    ---@type ImageLabel		
	c.insts.task_red = 'Frame.leftFrame.list.taskBtn.red'   
    ---@type ImageLabel		
	c.insts.bag_red = 'Frame.rightBtns.bagBtn.red'   
    ---@type ImageLabel		
	c.insts.shop_red = 'Frame.leftFrame.list.shopBtn.red'  
    ---@type ImageLabel		
	c.insts.relics_red = 'Frame.rightBtns.relicsBtn.red'    
     ---@type ImageLabel		
	c.insts.open_red = 'Frame.rightBtns.openBtn.red'   
    ---@type ImageLabel		
	c.insts.teleport_red = 'Frame.rightHide.teleportBtn.red'   
    ---@type ImageLabel		
	c.insts.party_red = 'Frame.rightHide.partyBtn.red'  
    ---@type ImageLabel		
	c.insts.mount_red = 'Frame.rightHide.mountBtn.red'   
    ---@type ImageLabel		
	c.insts.skill_red = 'Frame.rightHide.joinDiscordBtn.red'         

    ---@type Frame		
	c.insts.bossPanel = 'Frame.bossPanel'    
    ---@type TextLabel		
	c.insts.boss_name = 'Frame.bossPanel.name.info'    
    ---@type Frame		
	c.insts.boss_profb = 'Frame.bossPanel.probg.profb'    
    ---@type TextLabel		
	c.insts.boss_num = 'Frame.bossPanel.probg.num'   
    ---@type Frame		
	c.insts.boss_rewards = 'Frame.bossPanel.rewards'    
    ---@type Frame		
	c.insts.boss_rewards_item = 'Frame.bossPanel.rewards.item'    

    ---@type Frame		
	c.insts.VIPFrame = 'Frame.VIPFrame'  
    ---@type ImageButton		
	c.insts.VIPFrame_close = 'Frame.VIPFrame.close'     
    ---@type ImageButton		
	c.insts.VIPFrame_btn = 'Frame.VIPFrame.btn' 
    
    ---@type ImageButton		
	c.insts.doubleAtkBtn = 'Frame.expPanel.doubleAtkBtn'   
    ---@type ImageButton		
	c.insts.doubleAtkSpeedBtn = 'Frame.expPanel.doubleAtkSpeedBtn'     

    ---@type Frame		
	c.insts.EternalFrame = 'Frame.EternalFrame'    
    ---@type TextLabel		
	c.insts.Eternalnum = 'Frame.EternalFrame.board.num' 
    ---@type TextLabel		
	c.insts.Eternaladdnum = 'Frame.EternalFrame.board.addnum'   
    ---@type ImageLabel		
	c.insts.Eternalbtn = 'Frame.EternalFrame.btn'       
    
    ---@type Frame		
	c.insts.CDFrame = 'Frame.CDFrame'    
    ---@type TextLabel		
	c.insts.cd_tips = 'Frame.CDFrame.tips'    

    ---@type Frame		
	c.insts.HeartFrame = 'Frame.HeartFrame'   
    ---@type ImageLabel		
	c.insts.Heart1 = 'Frame.HeartFrame.list.1'     
    ---@type ImageLabel		
	c.insts.Heart2 = 'Frame.HeartFrame.list.2'     
    ---@type ImageLabel		
	c.insts.Heart3 = 'Frame.HeartFrame.list.3'     

    ---@type ImageButton		
	c.insts.Weather_btn = 'Frame.friendPanel.Weather.btn'    
    ---@type Frame		
	c.insts.WeatherPanel = 'Frame.WeatherPanel'    
    ---@type ScrollingFrame		
	c.insts.WeatherPanel_ScrollingFrame = 'Frame.WeatherPanel.bg.ScrollingFrame'   
    ---@type Frame		
	c.insts.WeatherPanel_item = 'Frame.WeatherPanel.bg.ScrollingFrame.item'     
    ---@type ImageButton		
	c.insts.WeatherPanel_close = 'Frame.WeatherPanel.bg.close'    
    ---@type TextLabel		
	c.insts.WeatherPanel_cd = 'Frame.WeatherPanel.bg.cd'    

    ---@type Frame		
	c.insts.PumpkinFrame = 'Frame.PumpkinFrame'    
    ---@type ImageLabel		
	c.insts.Pumpkin_bg = 'Frame.PumpkinFrame.bg'    
    ---@type ImageLabel		
	c.insts.Pumpkin_fg = 'Frame.PumpkinFrame.bg.fg'   
    ---@type TextLabel		
	c.insts.Pumpkin_num = 'Frame.PumpkinFrame.bg.num'    
    ---@type TextLabel		
	c.insts.PumpkinBuff_num = 'Frame.friendPanel.Pumpkin.btn.num'   
    ---@type ImageLabel		
	c.insts.PumpkinBuff_img = 'Frame.friendPanel.Pumpkin.btn.ImageLabel'  
    ---@type Frame		
	c.insts.Pumpkin_rewards = 'Frame.PumpkinFrame.rewards'   
    ---@type Frame		
	c.insts.Pumpkin_rewards_item = 'Frame.PumpkinFrame.rewards.item'       
    
    ---@type Frame		
	c.insts.PumpkinPanel = 'Frame.PumpkinPanel'   
    ---@type Frame		
	c.insts.PumpkinPanel_item1 = 'Frame.PumpkinPanel.bg.ScrollingFrame.item1'  
    ---@type Frame		
	c.insts.PumpkinPanel_item2 = 'Frame.PumpkinPanel.bg.ScrollingFrame.item2'
    ---@type Frame		
	c.insts.PumpkinPanel_item3 = 'Frame.PumpkinPanel.bg.ScrollingFrame.item3'  
    ---@type TextLabel		
	c.insts.PumpkinPanel_cd = 'Frame.PumpkinPanel.bg.cd'    

    ---@type ImageButton		
	c.insts.halloweenpack = 'Frame.halloweenpack'    

    ---@type Frame		
	c.insts.weatherHP = 'Frame.weatherHP'    
    ---@type ImageLabel		
	c.insts.weatherHP_icon = 'Frame.weatherHP.icon'    
    ---@type TextLabel		
	c.insts.weatherHP_name = 'Frame.weatherHP.name'    
    ---@type ImageLabel		
	c.insts.weatherHP_fg = 'Frame.weatherHP.bg.fg'    
    ---@type TextLabel		
	c.insts.weatherHP_num = 'Frame.weatherHP.bg.num'    
    ---@type Frame		
	c.insts.weatherHP_rewards = 'Frame.weatherHP.rewards'    
    ---@type Frame		
	c.insts.weatherHP_item = 'Frame.weatherHP.rewards.item'    

    ---@type Frame		
	c.insts.SkillFrame = 'Frame.SkillFrame'    
    ---@type Frame		
	c.insts.skill_item1 = 'Frame.SkillFrame.list.item1'    
    ---@type Frame		
	c.insts.skill_item2 = 'Frame.SkillFrame.list.item2'    
    ---@type Frame		
	c.insts.skill_item3 = 'Frame.SkillFrame.list.item3'    
    ---@type ImageButton		
	c.insts.skill_hideBtn = 'Frame.SkillFrame.hideBtn'   
    ---@type Frame		
	c.insts.skill_list = 'Frame.SkillFrame.list'     
    ---@type ImageButton		
	c.insts.skill_MountBtn = 'Frame.SkillFrame.MountBtn'    

    ---@type TextLabel		
	c.insts.treeCD = 'Frame.treeCD'    

    ---@type ImageButton		
	c.insts.hideHeadBtn = 'Frame.expPanel.bg.show.btn'  
    ---@type ImageLabel		
	c.insts.hideHeadBtn_open = 'Frame.expPanel.bg.show.btn.open'    
    ---@type TextLabel		
	c.insts.online_cd = 'Frame.rightHide.onlineBtn.cd'      
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.HudGui',_G.Resource)
    c.super.ctor(self,ui)

    self.afk = false
    self.boss_rewards = {}
    self.pumpkin_rewards = {}
    self.weather_rewards = {}

    self.pumpkin_panel_items = {
        self.insts.PumpkinPanel_item1,
        self.insts.PumpkinPanel_item2,
        self.insts.PumpkinPanel_item3,
    }

    self:Init()
    self.insts.VIPFrame_close.MouseButton1Click:Connect(function()
        self:SetVipVisible(false)
    end)

    if mobile then
        self.insts.startrtpack.Position = UDim2.new(0.032,0,0.036,36)
    end

    if place_manager:GetIdByName('partysence') == game.PlaceId then
        self:AddProcess(function()
            self:Wait(7)
            for k,v in ipairs(self.main_inst:GetDescendants()) do
                if v:GetAttribute('hide') then
                    v.Visible = false
                end
            end
            self:Wait(3)
            self.insts.SkillFrame.Visible = true
            self.insts.skill_hideBtn.Visible = true
            self.insts.skill_list.Visible = false
        end)
        self.insts.ExitBtn.Visible = true
        self.insts.SkillFrame.Visible = true
        self:SetWeatherBuffVisible(false)
    else
        self.insts.ExitBtn.Visible = false
        self:SetWeatherBuffVisible(true)
    end

    self:SetHeartFrameVisible(place_manager:GetIdByName('partysence') == game.PlaceId)

    self.skillItems = {
        self.insts.skill_item1,
        self.insts.skill_item2,
        self.insts.skill_item3,
    }
end

function c:Show(isSkill)
    if not self.skill_hide then
        TweenHelper:PlayTween(
            self.insts.EternalFrame,
            tweenInfo,
            {Position = UDim2.fromScale(0.982,0.322)}
        )
        TweenHelper:PlayTween(
            self.insts.resPanel,
            tweenInfo,
            {Position = UDim2.fromScale(0.007,0.735)}
        )
        TweenHelper:PlayTween(
            self.insts.rightBtns,
            tweenInfo,
            {Position = UDim2.fromScale(0.99,0.55)}
        )
        TweenHelper:PlayTween(
            self.insts.startrtpack,
            tweenInfo,
            {Position = UDim2.new(0.032,0,0.036,mobile and 36 or 0)}
        )
        TweenHelper:PlayTween(
            self.insts.limitpet,
            tweenInfo,
            {Position = UDim2.new(0.982,0,0.036,0)}
        )
        TweenHelper:PlayTween(
            self.insts.leftFrame,
            tweenInfo,
            {Position = UDim2.fromScale(0.015,0.4)}
        )
    end
    if not isSkill then
        TweenHelper:PlayTween(
            self.insts.expPanel,
            tweenInfo,
            {Position = UDim2.fromScale(0.5,0.9)}
        )
        self.insts.SkillFrame.Visible = true
    end
    
end

function c:Hide(isSkill)
    TweenHelper:PlayTween(
        self.insts.EternalFrame,
        tweenInfo,
        {Position = UDim2.fromScale(1.3,0.322)}
    )
    TweenHelper:PlayTween(
        self.insts.resPanel,
        tweenInfo,
        {Position = UDim2.fromScale(-0.2,0.735)}
    )
    TweenHelper:PlayTween(
        self.insts.rightBtns,
        tweenInfo,
        {Position = UDim2.fromScale(1.15,0.55)}
    )
    if not isSkill then
        TweenHelper:PlayTween(
            self.insts.expPanel,
            tweenInfo,
            {Position = UDim2.fromScale(0.5,1.1)}
        )
        self.insts.SkillFrame.Visible = false
    end
    TweenHelper:PlayTween(
        self.insts.startrtpack,
        tweenInfo,
        {Position = UDim2.new(-0.11,0,0.036,mobile and 36 or 0)}
    )
    TweenHelper:PlayTween(
        self.insts.limitpet,
        tweenInfo,
        {Position = UDim2.new(1.11,0,0.036,mobile and 36 or 0)}
    )
    TweenHelper:PlayTween(
        self.insts.leftFrame,
        tweenInfo,
        {Position = UDim2.fromScale(-0.15,0.4)}
    )
    local event = game.ReplicatedStorage:WaitForChild('Event')
    event:Fire('hudHide')
    self:SetVipVisible(false)
end

function c:Init()
    self.skill_hide = false
    self.insts.bag_btn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.bag_gui:Show()
        local event = game.ReplicatedStorage:WaitForChild('Event')
        event:Fire('EnterBagView')
        self:Hide()
        audioManager:PlayGloble('pick')
    end)
    self.insts.taskBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.task_gui:Show()
        self:Hide()
    end)
    self.insts.shop_btn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.shop_gui:Show()
        self:Hide()
        audioManager:PlayGloble('openStore1')
        audioManager:PlayGloble('openStore2')
    end)
    self.insts.dailyBtn.MouseButton1Click:Connect(function()
        if self.daily_handle then
            self.daily_handle(self.daily_obj)
        end
        -- self:Hide()
    end)
    self.insts.onlineBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.online_gui:Show()
        self:Hide()
    end)
    self.insts.relicsBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.relics_gui:Show()
        self:Hide()
    end)
    self.insts.bpBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.battle_pass_gui:Show()
        self:Hide()
    end)
    self.insts.settingBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.setting_gui:Show()
        self:Hide()
    end)
    self.insts.freePetBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.free_pet_gui:Show()
    end)
    self.insts.VIPBtn.MouseButton1Click:Connect(function()
        self:SetVipVisible(true)
    end)
    self.insts.teleportBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.teleport_gui:Show()
        self:Hide()

        self:SetOpenRedVisible(false)
        self:SetTeleportRedVisible(false)
    end)
    self.insts.Eternalbtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.eternal_gui:Show()
    end)
    self.insts.partyBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.party_gui:Show()
        self:SetPartyRedVisible(false)
        self:SetOpenRedVisible(false)
    end)
    self.insts.ExitBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.sure_exit_party_gui:Show()
    end)
    self.insts.Weather_btn.MouseButton1Click:Connect(function()
        self:SetWeatherPanelVisible(true)
    end)
    self.insts.WeatherPanel_close.MouseButton1Click:Connect(function()
        self:SetWeatherPanelVisible(false)
    end)
    self.insts.joinDiscordBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.skill_gui:Show()
    end)
    self.insts.skill_hideBtn.MouseButton1Click:Connect(function()
        self.skill_hide = not self.skill_hide
        if self.skill_hide then
            self:Hide(true)
            self.insts.skill_hideBtn.icon.Image = 'rbxassetid://96571302645352'
            self.insts.skill_hideBtn.TextLabel.Text = 'Show'
            self.insts.skill_list.Visible = true
        else
            self:Show(true)
            self.insts.skill_hideBtn.icon.Image = 'rbxassetid://135576978988592'
            self.insts.skill_hideBtn.TextLabel.Text = 'Hide'
            self.insts.skill_list.Visible = false
        end
    end)
    self.insts.mountBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.mount_gui:Show()
    end)
    self.insts.guildBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.guild_gui:Show()
    end)
    self.insts.pvpBtn.MouseButton1Click:Connect(function()
        spawn(function()
            local time = 15
            while time > 0 do
                time = time - 0.5
                wait(.5)
                ui_manager.ui_list.tips_gui:TipsMessage('Teleport...','success')
            end
        end)
        wait(4)
        hotpot.event_manager:Fire('teleportToPvp')
    end)
    self.insts.hideHeadBtn.MouseButton1Click:Connect(function()
        self.head_open = not self.head_open
        self:SethideHeadBtnState(self.head_open)
        hotpot.event_manager:Fire('changeHideHead')
    end)
end

function c:SetPartyBtnVisible(vis)
    self.insts.partyBtn.Visible = false
end

function c:SetTeleportBtnVisible(vis)
    self.insts.teleportBtn.Visible = vis
end

function c:SetVipVisible(vis)
    if vis then
        self.insts.VIPFrame.Position = UDim2.fromScale(0.5,0.7)
        self.insts.VIPFrame.Visible = true
        TweenHelper:PlayTween(
            self.insts.VIPFrame,
            tweenInfo,
            {Position = UDim2.fromScale(0.5,0.5)}
        )
    else
       TweenHelper:PlayTween(
            self.insts.VIPFrame,
            tweenInfo,
            {Position = UDim2.fromScale(0.5,0.7)},
            function()
                self.insts.VIPFrame.Visible = false
            end
        ) 
    end
end

function c:SetVipBtnVisible(vis)
    self.insts.VIPBtn.Visible = vis
end

function c:SetStarterpackVisible(vis)
    self.insts.startrtpack.Visible = vis
end

function c:SetLimitpetVisible(vis)
    self.insts.limitpet.Visible = vis
end

function c:SetFreePetVisible(vis)
    self.insts.leftFrame.freePetBtn.Visible = vis
end

function c:SetBagRedVisible(vis)
    self.insts.bag_red.Visible = vis
end

function c:SetSkillRedVisible(vis)
    self.insts.skill_red.Visible = vis
end

function c:SetTeleportRedVisible(vis)
    self.insts.teleport_red.Visible = vis
end

function c:SetOpenRedVisible(vis)
    self.insts.open_red.Visible = vis
end

function c:SetMountRedVisible(vis)
    self.insts.mount_red.Visible = vis
end

function c:SetAfkOpen(is_open)
    self.insts.afk_open.ImageColor3 = is_open and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end

function c:SetDamagex2BtnVisible(vis)
    self.insts.doubleAtkBtn.Visible = vis
end

function c:SetSpeedx2BtnVisible(vis)
    self.insts.doubleAtkSpeedBtn.Visible = vis
end

--设置经验值
function c:SetExp(now,need)
    self.insts.expPanel_fg.Size = UDim2.fromScale(math.clamp(now/need,0,1),1)
    self.insts.expPanel_num.Text = string.format(
        exp_str,
        big_number:ToString(now),
        big_number:ToString(need),
        now/need*100
    )

    ui_manager.ui_list.stats_gui:SetExp(now,need)
end

--设置等级
function c:SetLv(lv,icon)
    self.insts.expPanel_lv.Text = 'Level ' .. lv
    self.insts.expPanel_lv.ImageLabel.Image = icon or ''
    ui_manager.ui_list.stats_gui:SetLv(lv,icon)
end

--设置模型
function c:SetExpModel(icon)
    if not icon then
        self.insts.exp_icon.Visible = true
        self.insts.exp_icon1.Visible = false
        return
    end
    self.insts.exp_icon.Visible = false
    self.insts.exp_icon1.Visible = true
    
    self.insts.exp_icon1.Image = icon
end

--设置show进度
function c:SetShowProgress(per)
    if per <= 0.5 then
        self.insts.left_UIGradient.Rotation = 180
        self.insts.right_UIGradient.Rotation = per * 360
    else
        self.insts.left_UIGradient.Rotation = (per - 0.5) * 360 + 180
        self.insts.right_UIGradient.Rotation = 180
    end
end

--设置show引导显示
function c:SetShowGuideVisible(vis)
    self.insts.exp_guide.Visible = vis
end

--设置premium加成
function c:SetPremiumNum(num)
    self.insts.premium_info.Text = num .. '%'
end

--设置好友加成
function c:SetFriendNum(num)
    self.insts.friend_info.Text = num .. '%'
end

--设置任务按钮显示
function c:SetTaskBtnVisible(vis)
    self.insts.taskBtn.Visible = vis
end

--设置钻石数量
function c:SetGemsNum(num)
    self.insts.gems_num.Text = big_number:ToString(num)
end

--设置奖杯数量
function c:SetWinsNum(num)
    self.insts.wins_num.Text = big_number:ToString(num)
end

--播放钻石动画
function c:PlayGemsAnima(num)
    local ui = self.insts.gems_anima:Clone()
    ui.Text = '+' .. big_number:ToString(num)
    ui.Parent = self.insts.gems_anima.Parent
    ui.Size = UDim2.fromScale(0,0)
    ui.Rotation = math.random(-30,30)
    ui.Visible = true
    TweenHelper:PlayTween(
        ui,
        tweenInfo,
        {Size = UDim2.fromScale(0.339,0.8)},
        function()
            wait(0.5)
            ui:Destroy()
        end
    )
    TweenHelper:PlayTween(
        self.insts.gemsFrame,
        TweenInfo.new(0.2,1,1,0,true),
        {Size = UDim2.fromScale(1.2,0.6)}
    )
end

--播放wins动画
function c:PlayWinsAnima(num)
    local ui = self.insts.wins_anima:Clone()
    ui.Text = '+' .. big_number:ToString(num)
    ui.Parent = self.insts.wins_anima.Parent
    ui.Size = UDim2.fromScale(0,0)
    ui.Rotation = math.random(-30,30)
    ui.Visible = true
    TweenHelper:PlayTween(
        ui,
        tweenInfo,
        {Size = UDim2.fromScale(0.339,0.8)},
        function()
            wait(0.5)
            ui:Destroy()
        end
    )
    TweenHelper:PlayTween(
        self.insts.winsFrame,
        TweenInfo.new(0.2,1,1,0,true),
        {Size = UDim2.fromScale(1.2,0.6)}
    )
end

--设置永恒数量
function c:SetEternalNum(num)
    self.insts.Eternalnum.Text = big_number:ToString(num)
end

--播放永恒数量增加动画
function c:PlayEternalNumAddAnim(num)
    local ui = self.insts.Eternaladdnum:Clone()
    ui.Text = '+' .. big_number:ToString(num)
    ui.Parent = self.insts.Eternaladdnum.Parent
    ui.Position = UDim2.fromScale(0.288,0.6)
    ui.Visible = true
    TweenHelper:PlayTween(
        ui,
        tweenInfo,
        {Position = UDim2.fromScale(0.288,-0.3),Size = UDim2.fromScale(0.25*1.2,0.3*1.2)}
    )
    Debris:AddItem(ui,1)
end

--设置bossPanel的显示
function c:SetBossPanelVisible(visible)
    self.insts.bossPanel.Visible = visible
end

--设置bossPanel的名字
function c:SetBossName(name)
    self.insts.boss_name.Text = name
end

--设置bossPanel的进度
function c:SetBossProgress(now,max)
    now = math.max(now,0)
    self.insts.boss_num.Text = string.format(
        '%s / %s',
        big_number:ToString(now),
        big_number:ToString(max)
    )
    self.insts.boss_profb.Size = UDim2.fromScale(math.clamp(now/max,0,1),1)
end

--设置任务红点显示
function c:SetTaskRedVisible(vis)
    self.insts.task_red.Visible = vis
end

--设置免费宠物红点显示
function c:SetFreePetRedVisible(vis)
    self.insts.free_pet_red.Visible = vis
end

--设置在线红点显示
function c:SetOnlineRedVisible(vis)
    self.insts.online_red.Visible = vis
end

--设置商店红点显示
function c:SetShopRedVisible(vis)
    self.insts.shop_red.Visible = vis
end

--设置遗物红点显示
function c:SetRelicsRedVisible(vis)
    self.insts.relics_red.Visible = vis
end

--设置partyRed的显示
function c:SetPartyRedVisible(visible)
    self.insts.party_red.Visible = visible
end

--设置cdFrame的显示
function c:SetCDFrameVisible(visible)
    self.insts.CDFrame.Visible = visible
end

--设置cdFrame的显示
function c:SetCDFrameVisible(visible)
    self.insts.CDFrame.Visible = visible
end

--设置cdTips
function c:SetCDTips(tips)
    self.insts.cd_tips.Text = tips
end

--设置cdFrame的位置
function c:SetCDFramePos(pos)
    self.insts.CDFrame.Position = pos
end

--设置HeartFrame的显示
function c:SetHeartFrameVisible(visible)
    self.insts.HeartFrame.Visible = visible
end

--设置HeartFrame的心跳
function c:SetHeartFrameCount(count)
    for i = 1,3 do
        self.insts['Heart'..i].Image = (i <= count) and 'rbxassetid://70564602998018' or ''
    end
end

--设置Weather的显示
function c:SetWeatherPanelVisible(vis)
    self.insts.WeatherPanel.Visible = vis
end

--向weather添加子项
function c:AddItemInWeather(icon,per,name)
    local ui = hotpot:CloneInst_Loop(self.insts.WeatherPanel_item)
    ui.Visible = true
    ui.icon.Image = icon
    ui.name.Text = name
    ui.per.Text = string.format('%.2f%%',per)
    ui.Parent = self.insts.WeatherPanel_ScrollingFrame
end

--设置weatherBtn的图标
function c:SetWeatherBtnIcon(icon,scale)
    self.insts.Weather_btn.ImageLabel.Image = icon
    self.insts.Weather_btn.ImageLabel.Size = UDim2.fromScale(scale,scale)
end

--设置weather的倒计时
function c:SetWeatherCD(cd)
    self.insts.Weather_btn.num.Text = big_number:TransformDateToString(cd)
    self.insts.WeatherPanel_cd.Text = 'Next Monster In:'..big_number:TransformDateToString(cd)
end

--设置weatherBuff的显示
function c:SetWeatherBuffVisible(vis)
    vis = false
    self.insts.Weather_btn.Parent.Visible = vis
end

--设置PumpkinFrame的显示
function c:SetPumpkinFrameVisible(visible)
    -- self.insts.PumpkinFrame.Visible = visible
    self.insts.PumpkinFrame:SetAttribute('visible',visible)
end

--设置Pumpkin的数量
function c:SetPumpkinNum(now,max)
    self.insts.Pumpkin_num.Text = string.format(pumpkin_str,now,max,now/max*100)
    self.insts.Pumpkin_fg.Size = UDim2.fromScale(now/max,1)
end

--设置PumpkinBuff的倒计时
function c:SetPumpkinBuffText(cd)
    self.insts.PumpkinBuff_num.Text = big_number:TransformDateToString(cd)
end

--设置PumpkinBuff的img
function c:SetPumpkinBuffImg(img)
    self.insts.PumpkinBuff_img.Image = img
end

--设置PumpkinPanel的显示
function c:SetPumpkinPanelVis(vis)
    self.insts.PumpkinPanel.Visible = vis
end

--设置PumpkinPanel的倒计时
function c:SetPumpkinPanelCD(cd)
    self.insts.PumpkinPanel_cd.Text = big_number:TransformDateToString(cd)
end

--设置PumpkinFrame的名字和图标
function c:SetPumpkinFrameName(name,icon)
    self.insts.PumpkinFrame.bossName.Text = name
    self.insts.PumpkinFrame.bossIcon.Image = icon
end

--设置PumpkinPanel的cd
function c:SetPumpkinPanelItemCD(id,cd)
    local item = self.pumpkin_panel_items[id]
    if cd == 0 then
        item.cd.Text = ''
    else
        item.cd.Text = big_number:TransformDateToString(cd)
    end
end

--设置weatherHP的显示
function c:SetWeatherHPVisible(vis)
    self.insts.weatherHP.Visible = vis
end

--设置weatherHP的icon
function c:SetWeatherHPIcon(icon)
    self.insts.weatherHP_icon.Image = icon
end

--设置weatherHP的名字
function c:SetWeatherHPName(name)
    self.insts.weatherHP_name.Text = name
end

--设置weatherHP的进度
function c:SetWeatherHPProgress(now,max)
    now = math.max(now,0)
    self.insts.weatherHP_num.Text = string.format(
        '%s / %s',
        big_number:ToString(now),
        big_number:ToString(max)
    )
    self.insts.weatherHP_fg.Size = UDim2.fromScale(math.clamp(now/max,0,1),1)
end

--绑定邀请按钮点击事件
function c:BindInviteBtnClickHandle(obj,handle)
    -- self.insts.friend_btn.MouseButton1Click:Connect(function()
    --     handle(obj)
    -- end)
end

--绑定afk按钮点击事件
function c:BindAFKBtnClickHandle(obj,handle)
    if self.atk_co then 
        self.atk_co:Disconnect()
        self.atk_co = nil
    end
    self.atk_co = self.insts.afkBtn.MouseButton1Click:Connect(function()
        handle(obj)
        self.afk = not self.afk
        self:SetAfkOpen(self.afk)
    end)
end

function c:BindStarterpackClickHandle(obj,handle)
    self.insts.startrtpack.MouseButton1Click:Connect(function()
        handle(obj,37)
    end)
end

function c:BindLimitpetClickHandle(obj,handle)
    self.insts.limitpet.MouseButton1Click:Connect(function()
        handle(obj,20)
    end)
end

function c:BindVipFrameBtnClickHandle(obj,handle)
    self.insts.VIPFrame_btn.MouseButton1Click:Connect(function()
        handle(obj,28)
    end)
end

function c:BindDoubleAtkBtnClickHandle(obj,handle)
    self.insts.doubleAtkBtn.MouseButton1Click:Connect(function()
        handle(obj,64)
    end)
    self.insts.doubleAtkSpeedBtn.MouseButton1Click:Connect(function()
        handle(obj,68)
    end)
end

function c:BindShowBtnClickHandle(obj,handle)
    -- self.insts.exp_btn.MouseButton1Click:Connect(function()
    --     handle(obj)
    -- end)
end

function c:SetHalloweenPackVisible(vis)
    self.insts.halloweenpack.Visible = vis
end

function c:BindHalloweenPackClickHandle(obj,handle)
    self.insts.halloweenpack.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindStatsBtnClickHandle(obj,handle)
    self.insts.StatsBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.stats_gui:Show()
        ui_manager.ui_list.stats_gui:SetInvitePartyBtnVisible(false)
        ui_manager.ui_list.stats_gui:SetJoinPartyBtnVisible(false)
        handle(obj)
    end)
end

function c:SetSkillItemLockVisible(index,vis)
    self.skillItems[index].bg.lock.Visible = vis
    if vis then
        self.skillItems[index].bg.icon.Image = ''
    end
end

function c:SetSkillItemIcon(index,icon)
    self.skillItems[index].bg.icon.Image = icon
end

function c:SetSkillItemCD(index,cd,per)
    self.skillItems[index].bg.top.cd.Text = cdShow:format(cd)
    self.skillItems[index].bg.top.mask.Size = UDim2.fromScale(1,per)
    self.skillItems[index].bg.top.Visible = cd > 0
end

function c:BindSkillItemClickHandle(obj,handle)
    for k,v in ipairs(self.skillItems)do
        local index = k
        v.bg.MouseButton1Click:Connect(function()
            handle(obj,index)
        end)
    end
end

function c:SetSkillMountBtnVisible(vis)
    self.insts.skill_MountBtn.Visible = vis
end

function c:SetSkillMountBtnIcon(icon)
    self.insts.skill_MountBtn.icon.Image = icon
end

function c:BindSkillMountBtnClickHandle(obj,handle)
    self.insts.skill_MountBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:AddItemInBossRewards(icon,quality)
    local ui = hotpot:CloneInst_Loop(self.insts.boss_rewards_item)
    ui.Visible = true
    ui.Parent = self.insts.boss_rewards
    ui.bg.Image = icon
    
    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        -- color:Clone().Parent = ui.bg
        color:Clone().Parent = ui.bg.UIStroke
    end

    self.boss_rewards[ui] = true
end

function c:RemoveAllBossItem()
    for k,v in pairs(self.boss_rewards) do
        k:Destroy()
    end
    self.boss_rewards = {}
end

function c:AddItemInPumpkinRewards(icon,quality)
    local ui = hotpot:CloneInst_Loop(self.insts.Pumpkin_rewards_item)
    ui.Visible = true
    ui.Parent = self.insts.Pumpkin_rewards
    ui.bg.Image = icon
    
    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        color:Clone().Parent = ui.bg.UIStroke
        -- color:Clone().Parent = ui.bg
    end
    
    self.pumpkin_rewards[ui] = true
end

function c:RemoveAllPumpkinItem()
    for k,v in pairs(self.pumpkin_rewards) do
        k:Destroy()
    end
    self.pumpkin_rewards = {}
end

function c:AddItemInWeatherRewards(icon,quality)
    local ui = hotpot:CloneInst_Loop(self.insts.weatherHP_item)
    ui.Visible = true
    ui.Parent = self.insts.weatherHP_rewards
    ui.bg.Image = icon
    
    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        color:Clone().Parent = ui.bg.UIStroke
        -- color:Clone().Parent = ui.bg
    end
    
    self.weather_rewards[ui] = true
end

function c:RemoveAllWeatherItem()
    for k,v in pairs(self.weather_rewards) do
        k:Destroy()
    end
    self.weather_rewards = {}
end

function c:SetSKillBtnVisible(vis)
    self.insts.joinDiscordBtn.Visible = false
end

function c:SetGuildBtnVisible(vis)
    self.insts.guildBtn.Visible = vis
end

function c:SetPVPBtnVisible(vis)
    self.insts.pvpBtn.Visible = vis
end

function c:SetStatsBtnVisible(vis)
    self.insts.StatsBtn.Visible = vis
end

function c:BindDailyHandle(obj,handle)
    self.daily_handle = handle
    self.daily_obj = obj
end

function c:SetTreeCD(t)
    if t <= 0 then
        self.insts.treeCD.Text = ''
    else
        self.insts.treeCD.Text = 'Tree countdown:'..t..'s'
    end
end

function c:SethideHeadBtnState(open)
    self.insts.hideHeadBtn_open.ImageColor3 = open and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
end

function c:SetOnlineCD(cd)
    if cd == 0 then
        self.insts.online_cd.Text = ''
    else
        self.insts.online_cd.Text = big_number:TransformDateToString(cd)
    end
end

return c
