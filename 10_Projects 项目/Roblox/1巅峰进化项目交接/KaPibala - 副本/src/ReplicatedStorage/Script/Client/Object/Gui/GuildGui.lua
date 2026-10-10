local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()
---@type Players
local players = game:GetService('Players')
---@type Player
local player = players.LocalPlayer
---@type Mouse
local mouse = player:GetMouse()

local tweenInfo = TweenInfo.new(0.2)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)
local refreshStr = 'Refresh:'

---@class GuildGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageButton		
	c.insts.CreateGuildBg_closeBtn = 'Frame.CreateGuildBg.closeBtn'    
    ---@type ImageButton		
	c.insts.GuildMainBg_closeBtn = 'Frame.GuildMainBg.closeBtn'    
    
    ---@type ImageLabel		
	c.insts.GuildMainBg = 'Frame.GuildMainBg' 
    ---@type Frame		
	c.insts.GuildMainBg_topBtns = 'Frame.GuildMainBg.topBtns'      
    ---@type Frame		
	c.insts.GuildFrame = 'Frame.GuildMainBg.GuildFrame'   
    ---@type ImageLabel		
	c.insts.GuildFrame_GuildInfo = 'Frame.GuildMainBg.GuildFrame.GuildInfo'    
    ---@type ImageLabel		
	c.insts.GuildFrame_guildIcon = 'Frame.GuildMainBg.GuildFrame.GuildInfo.flag.icon' 
    ---@type ImageLabel		
	c.insts.GuildFrame_guideFlag = 'Frame.GuildMainBg.GuildFrame.GuildInfo.flag'        
    ---@type TextLabel		
	c.insts.GuildFrame_guildName = 'Frame.GuildMainBg.GuildFrame.GuildInfo.guildName'     
    ---@type TextLabel		
	c.insts.GuildFrame_guildId = 'Frame.GuildMainBg.GuildFrame.GuildInfo.guildId'   
    ---@type TextLabel		
	c.insts.GuildFrame_guildLv = 'Frame.GuildMainBg.GuildFrame.GuildInfo.guildLv'     
    ---@type TextLabel		
	c.insts.GuildFrame_guildDes = 'Frame.GuildMainBg.GuildFrame.GuildInfo.guildDes'    
    ---@type TextLabel		
	c.insts.GuildFrame_guildPownum = 'Frame.GuildMainBg.GuildFrame.GuildInfo.rightInfo.power.num'    
    ---@type TextLabel		
	c.insts.GuildFrame_guildNeednum = 'Frame.GuildMainBg.GuildFrame.GuildInfo.rightInfo.needpower.num'    
    ---@type TextLabel		
	c.insts.GuildFrame_guildTypenum = 'Frame.GuildMainBg.GuildFrame.GuildInfo.rightInfo.type.num'   
    ---@type TextLabel		
	c.insts.GuildFrame_guildMembernum = 'Frame.GuildMainBg.GuildFrame.GuildInfo.rightInfo.menber.num'     
    ---@type ImageButton		
	c.insts.GuildFrame_leaveBtn = 'Frame.GuildMainBg.GuildFrame.GuildInfo.leaveBtn'    
    ---@type ImageButton		
	c.insts.GuildFrame_manageBtn = 'Frame.GuildMainBg.GuildFrame.GuildInfo.manageBtn'    
    ---@type ScrollingFrame		
	c.insts.GuildFrame_ScrollingFrame = 'Frame.GuildMainBg.GuildFrame.PlayerInfo.ScrollingFrame'    
    ---@type Frame		
	c.insts.GuildFrame_scroll_item = 'Frame.GuildMainBg.GuildFrame.PlayerInfo.ScrollingFrame.item'    
    ---@type ImageLabel		
	c.insts.GuildFrame_changeGuildInfo = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo'    
    ---@type ImageLabel		
	c.insts.GuildFrame_change_flag = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.flag'    
    ---@type ImageLabel		
	c.insts.GuildFrame_change_icon = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.flag.icon'    
    ---@type ImageButton		
	c.insts.GuildFrame_change_flagbtn = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.flag.btn'    
    ---@type TextBox		
	c.insts.GuildFrame_change_guildName = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.guildName'    
    ---@type TextBox		
	c.insts.GuildFrame_change_guildDes = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.guildDes'   
    ---@type TextLabel		
	c.insts.GuildFrame_change_guildId = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.guildId'     
    ---@type TextLabel		
	c.insts.GuildFrame_change_guildLv = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.guildLv'   
    ---@type ImageLabel		
	c.insts.GuildFrame_change_needpower = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.rightInfo.powerNeed'  
    ---@type TextLabel		
	c.insts.GuildFrame_change_power = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.rightInfo.power.num'      
    ---@type TextLabel		
	c.insts.GuildFrame_change_member = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.rightInfo.menber.num'     
    ---@type ImageLabel		
	c.insts.GuildFrame_change_public = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.rightInfo.public'  
    ---@type ImageLabel		
	c.insts.GuildFrame_change_type = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.rightInfo.type'   
    ---@type ImageButton		
	c.insts.GuildFrame_change_sureBtn = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.sureBtn'   
    ---@type ImageButton		
	c.insts.GuildFrame_change_cancelBtn = 'Frame.GuildMainBg.GuildFrame.changeGuildInfo.cancelBtn'  
    ---@type ImageButton		
	c.insts.GuildFrame_guildSenceBtn = 'Frame.GuildMainBg.GuildFrame.GuildInfo.guildSenceBtn'    
    ---@type ImageButton		
	c.insts.GuildFrame_guildWarBtn = 'Frame.GuildMainBg.GuildFrame.GuildInfo.guildWarBtn'    
    
    ---@type Frame		
	c.insts.warnFrame = 'Frame.GuildMainBg.warnFrame'   
    ---@type TextLabel		
	c.insts.warnFrame_info = 'Frame.GuildMainBg.warnFrame.bg.info'     
    ---@type ImageButton		
	c.insts.warnFrame_yesBtn = 'Frame.GuildMainBg.warnFrame.bg.yesBtn'   
    ---@type ImageButton		
	c.insts.warnFrame_noBtn = 'Frame.GuildMainBg.warnFrame.bg.noBtn'     

    ---@type Frame		
	c.insts.DailyFrame = 'Frame.GuildMainBg.DailyFrame'    
    ---@type TextLabel		
	c.insts.DailyFrame_guildLvnum = 'Frame.GuildMainBg.DailyFrame.left.guildLv.num'    
    ---@type TextLabel		
	c.insts.DailyFrame_guildExpnum = 'Frame.GuildMainBg.DailyFrame.left.guildExp.num'    
    ---@type TextLabel		
	c.insts.DailyFrame_contributionnum = 'Frame.GuildMainBg.DailyFrame.left.contribution.num'    
    ---@type TextLabel		
	c.insts.DailyFrame_guildCoinsnum = 'Frame.GuildMainBg.DailyFrame.left.guildCoin.num'    
    ---@type ImageButton		
	c.insts.DailyFrame_claimbtn = 'Frame.GuildMainBg.DailyFrame.left.claimbtn'  
    ---@type TextLabel		
	c.insts.DailyFrame_claimed = 'Frame.GuildMainBg.DailyFrame.left.claimed'     
    ---@type ImageLabel		
	c.insts.DailyFrame_right = 'Frame.GuildMainBg.DailyFrame.right'     
    ---@type Frame		
	c.insts.DailyFrame_rightitem = 'Frame.GuildMainBg.DailyFrame.right.item'    

    ---@type Frame		
	c.insts.ShopFrame = 'Frame.GuildMainBg.ShopFrame'  
    ---@type ScrollingFrame		
	c.insts.ShopFrame_ScrollingFrame = 'Frame.GuildMainBg.ShopFrame.ScrollingFrame'   
    ---@type Frame		
	c.insts.ShopFrame_scrollitem = 'Frame.GuildMainBg.ShopFrame.ScrollingFrame.item'   
    ---@type TextLabel		
	c.insts.ShopFrame_coin = 'Frame.GuildMainBg.ShopFrame.coin.num'   
    ---@type TextLabel		
	c.insts.ShopFrame_refreshTime = 'Frame.GuildMainBg.ShopFrame.refreshTime'         

    ---@type Frame		
	c.insts.RankFrame = 'Frame.GuildMainBg.RankFrame'   
    ---@type ScrollingFrame		
	c.insts.RankFrame_ScrollingFrame = 'Frame.GuildMainBg.RankFrame.list.ScrollingFrame'   
    ---@type Frame		
	c.insts.RankFrame_scrollitem = 'Frame.GuildMainBg.RankFrame.list.ScrollingFrame.item'    

    ---@type Frame		
	c.insts.RequestFrame = 'Frame.GuildMainBg.RequestFrame'    
    ---@type ScrollingFrame		
	c.insts.RequestFrame_ScrollingFrame = 'Frame.GuildMainBg.RequestFrame.ScrollingFrame'    
    ---@type Frame		
	c.insts.RequestFrame_scrollitem = 'Frame.GuildMainBg.RequestFrame.ScrollingFrame.item'    

    ---@type ImageLabel		
	c.insts.CreateGuildBg = 'Frame.CreateGuildBg'    
    ---@type Frame		
	c.insts.CreateGuildBg_topBtns = 'Frame.CreateGuildBg.topBtns'    
    ---@type Frame		
	c.insts.CreateGuildFrame = 'Frame.CreateGuildBg.CreateGuildFrame'   
    ---@type ImageLabel		
	c.insts.CreateGuildFrame_flag = 'Frame.CreateGuildBg.CreateGuildFrame.bg.flag'     
    ---@type ImageLabel		
	c.insts.CreateGuildFrame_flagicon = 'Frame.CreateGuildBg.CreateGuildFrame.bg.flag.icon'    
    ---@type ImageButton		
	c.insts.CreateGuildFrame_editbtn = 'Frame.CreateGuildBg.CreateGuildFrame.bg.flag.btn'   
    ---@type TextBox		
	c.insts.CreateGuildFrame_guideName = 'Frame.CreateGuildBg.CreateGuildFrame.bg.guideName.TextBox'    
    ---@type TextBox		
	c.insts.CreateGuildFrame_guideAnnouncement = 'Frame.CreateGuildBg.CreateGuildFrame.bg.guideAnnouncement.TextBox'
    ---@type ImageButton		
	c.insts.CreateGuildFrame_powerNeed_leftBtn = 'Frame.CreateGuildBg.CreateGuildFrame.bg.powerNeed.leftBtn'  
    ---@type ImageButton		
	c.insts.CreateGuildFrame_powerNeed_rightBtn = 'Frame.CreateGuildBg.CreateGuildFrame.bg.powerNeed.rightBtn'  
    ---@type TextLabel		
	c.insts.CreateGuildFrame_powerNeed_num = 'Frame.CreateGuildBg.CreateGuildFrame.bg.powerNeed.num'        
    ---@type ImageButton		
	c.insts.CreateGuildFrame_type_leftBtn = 'Frame.CreateGuildBg.CreateGuildFrame.bg.type.leftBtn'  
    ---@type ImageButton		
	c.insts.CreateGuildFrame_type_rightBtn = 'Frame.CreateGuildBg.CreateGuildFrame.bg.type.rightBtn'    
    ---@type TextLabel		
	c.insts.CreateGuildFrame_type_num = 'Frame.CreateGuildBg.CreateGuildFrame.bg.type.num'    
    ---@type ImageButton		
	c.insts.CreateGuildFrame_public_leftBtn = 'Frame.CreateGuildBg.CreateGuildFrame.bg.public.leftBtn' 
    ---@type ImageButton		
	c.insts.CreateGuildFrame_public_rightBtn = 'Frame.CreateGuildBg.CreateGuildFrame.bg.public.rightBtn'   
    ---@type TextLabel		
	c.insts.CreateGuildFrame_public_num = 'Frame.CreateGuildBg.CreateGuildFrame.bg.public.num'      
    ---@type ImageButton		
	c.insts.CreateGuildFrame_createBtn = 'Frame.CreateGuildBg.CreateGuildFrame.bg.createBtn'      

    ---@type Frame		
	c.insts.JoinFrame = 'Frame.CreateGuildBg.JoinFrame'    
    ---@type ScrollingFrame		
	c.insts.JoinFrame_ScrollingFrame = 'Frame.CreateGuildBg.JoinFrame.ScrollingFrame'    
    ---@type Frame		
	c.insts.JoinFrame_scrollitem = 'Frame.CreateGuildBg.JoinFrame.ScrollingFrame.item'    
    ---@type TextBox		
	c.insts.JoinFrame_serchTextBox = 'Frame.CreateGuildBg.JoinFrame.serch.TextBox'    
    ---@type ImageButton		
	c.insts.JoinFrame_searchBtn = 'Frame.CreateGuildBg.JoinFrame.searchBtn'    
    ---@type ImageButton		
	c.insts.JoinFrame_refreshBtn = 'Frame.CreateGuildBg.JoinFrame.refreshBtn'    

    ---@type Frame		
	c.insts.Create_RankFrame = 'Frame.CreateGuildBg.RankFrame'    
    ---@type ScrollingFrame		
	c.insts.Create_RankFrame_ScrollingFrame = 'Frame.CreateGuildBg.RankFrame.list.ScrollingFrame'    
    ---@type Frame		
	c.insts.Create_RankFrame_scrollitem = 'Frame.CreateGuildBg.RankFrame.list.ScrollingFrame.item'   
    
    ---@type ImageLabel		
	c.insts.changeFlagBg = 'Frame.changeFlagBg'    
    ---@type ImageLabel		
	c.insts.changeFlagBg_flag = 'Frame.changeFlagBg.flag'    
    ---@type ImageLabel		
	c.insts.changeFlagBg_flagicon = 'Frame.changeFlagBg.flag.icon'    
    ---@type Frame		
	c.insts.changeFlagBg_flagList = 'Frame.changeFlagBg.flagList'  
    ---@type Frame		
	c.insts.changeFlagBg_flagList_item = 'Frame.changeFlagBg.flagList.item'    
    ---@type Frame		
	c.insts.changeFlagBg_iconList = 'Frame.changeFlagBg.iconList'    
    ---@type Frame		
	c.insts.changeFlagBg_iconList_item = 'Frame.changeFlagBg.iconList.item'    
    ---@type ImageButton		
	c.insts.changeFlagBg_btn = 'Frame.changeFlagBg.btn'    

    ---@type ImageLabel		
	c.insts.tipsFrame = 'Frame.tipsFrame'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.GuildGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self:InitGuildMainBg()
    self:InitCreateGuildBg()

    self.changeFlagBg_flagList_items = {}
    self.changeFlagBg_iconList_items = {}
    self.requestItemList = {}

    self.insts.CreateGuildBg_closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    self.insts.GuildMainBg_closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    self.insts.GuildFrame_guildWarBtn.MouseButton1Click:Connect(function()
        ui_manager.ui_list.guild_war_gui:Show()
    end)

    local island = (place_manager:GetIdByName('guildsence') == game.PlaceId)
    self:SetGuildFrameGuildSenceBtnVisible(not island)
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
    self:SetTipsFrameVisible(false)
end

function c:SetTipsFrameInfo(name,desc)
    self.insts.tipsFrame.name.Text = name
    self.insts.tipsFrame.desc.Text = desc
end

function c:SetTipsFrameVisible(vis)
    self.insts.tipsFrame.Visible = vis
end

---------------------------------------------GuildMainBg_Start
--初始化
function c:InitGuildMainBg()
    local frames = {
        self.insts.DailyFrame,
        self.insts.GuildFrame,
        self.insts.RankFrame,
        self.insts.ShopFrame,
        self.insts.RequestFrame,
    }
    local topBtns = self.insts.GuildMainBg_topBtns
    local btns = {
        topBtns:FindFirstChild('btn1'),
        topBtns:FindFirstChild('btn2'),
        topBtns:FindFirstChild('btn3'),
        topBtns:FindFirstChild('btn4'),
        topBtns:FindFirstChild('btn5'),
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

            self:SetTipsFrameVisible(false)
        end)
    end

    self.guidePlayeritemList = {}
    self.dailyItemList = {}
    self.shopItemList = {}
    self.rankItemList = {}
end

--设置GuildMainBg的显示
function c:SetGuildMainBgVisible(visible)
    self.insts.GuildMainBg.Visible = visible
end

--设置GuildInfo
function c:SetGuildFrameGuildInfo(name,id,flag,icon,lv,des,power,needPower,type_,member)
    self.insts.GuildFrame_guildName.Text = name
    self.insts.GuildFrame_guildId.Text = 'ID:' .. id
    self.insts.GuildFrame_guildIcon.Image = icon
    self.insts.GuildFrame_guideFlag.Image = flag
    self.insts.GuildFrame_guildLv.Text = '等级:' .. lv
    self.insts.GuildFrame_guildDes.Text = des
    self.insts.GuildFrame_guildPownum.Text = big_number:ToString(power)
    self.insts.GuildFrame_guildNeednum.Text = big_number:ToString(needPower)
    self.insts.GuildFrame_guildTypenum.Text = type_
    self.insts.GuildFrame_guildMembernum.Text = member
end

--向GuildFrame_ScrollingFrame添加玩家信息
function c:AddPlayerInfoInGuildFrameScrollingFrame(uid,rank,post,lv,name,login,contribution,power)
    local ui = hotpot:CloneInst_Loop(self.insts.GuildFrame_scroll_item)
    ui.Parent = self.insts.GuildFrame_ScrollingFrame
    ui.Visible = true
    ui.Name = uid
    ui.rank.Text = rank
    ui.post.Text = post
    ui.lv.Text = lv
    ui.name.Text = name
    ui.login.Text = login
    ui.contribution.Text = contribution
    ui.power.Text = big_number:ToString(power)
    self.guidePlayeritemList[uid] = ui

    ui.promotionbtn.MouseButton1Click:Connect(function()
        self.player_opBtn_handle(self.player_opBtn_obj,'promotion',uid)
    end)
    ui.demotionbtn.MouseButton1Click:Connect(function()
        self.player_opBtn_handle(self.player_opBtn_obj,'demotion',uid)
    end)
    ui.kickbtn.MouseButton1Click:Connect(function()
        self.player_opBtn_handle(self.player_opBtn_obj,'kick',uid)
    end)
end

--设置GuildFrame玩家的职位
function c:SetPlayerInfoPost(uid,post)
    local ui = self.guidePlayeritemList[uid]
    if not ui then
        return
    end
    ui.post.Text = post
end

--移除玩家信息
function c:RemovePlayerInfoInGuildFrameScrollingFrame(uid)
    local ui = self.guidePlayeritemList[uid]
    if not ui then
        return
    end
    ui:Destroy()
    self.guidePlayeritemList[uid] = nil
end

--移除所有玩家信息
function c:RemoveAllPlayerInfoInGuildFrameScrollingFrame()
    for _,v in pairs(self.guidePlayeritemList)do
        v:Destroy()
    end
    self.guidePlayeritemList = {}
end

--设置玩家信息的操作按钮显示
function c:SetPlayerInfoOperationBtnVisible(uid,proBtn,deBtn,kickBtn)
    local ui = self.guidePlayeritemList[uid]
    if not ui then
        return
    end
    ui.promotionbtn.Visible = proBtn
    ui.demotionbtn.Visible = deBtn
    ui.kickbtn.Visible = kickBtn
end

--设置GuildFrame的manageBtn是否显示
function c:SetGuildFrameManageBtnVisible(visible)
    self.insts.GuildFrame_manageBtn.Visible = visible
end

--设置changeGuildInfo的显示
function c:SetGuildFrameChangeGuildInfoVisible(visible)
    self.insts.GuildFrame_changeGuildInfo.Visible = visible
    self.insts.GuildFrame_GuildInfo.Visible = not visible
end

--设置changeGuildInfo的信息
function c:SetGuildFrameChangeGuildInfo(info)
    self.insts.GuildFrame_change_power.Text = big_number:ToString(info.power)
    self.insts.GuildFrame_change_guildName.Text = info.name
    self.insts.GuildFrame_change_guildDes.Text = info.des
    self.insts.GuildFrame_change_flag.Image = info.flag
    self.insts.GuildFrame_change_icon.Image = info.icon
    self.insts.GuildFrame_change_guildId.Text = 'ID:' .. info.showId
    self.insts.GuildFrame_change_guildLv.Text = info.lv
    self.insts.GuildFrame_change_member.Text = info.member
    self.insts.GuildFrame_change_type.num.Text = info.type_
    self.insts.GuildFrame_change_needpower.num.Text = big_number:ToString(info.need_power)
    self.insts.GuildFrame_change_public.num.Text = info.public
end

--获取changeGuildInfo的名字和公告
function c:GetGuildFrameChangeGuildInfoNameDes()
    local name = self.insts.GuildFrame_change_guildName.Text
    local des = self.insts.GuildFrame_change_guildDes.Text
    return name,des
end

--设置changeGuildInfo的旗帜和图标
function c:SetGuildFrameChangeGuildInfoFlagIcon(flag,icon)
    self.insts.GuildFrame_change_flag.Image = flag
    self.insts.GuildFrame_change_icon.Image = icon
end

--设置changeGuildInfo的needpower
function c:SetGuildFrameChangeGuildInfoNeedPower(needPower)
    self.insts.GuildFrame_change_needpower.num.Text = big_number:ToString(needPower)
end

--设置changeGuildInfo的type
function c:SetGuildFrameChangeGuildInfoType(type_)
    self.insts.GuildFrame_change_type.num.Text = type_
end

--设置changeGuildInfo的public
function c:SetGuildFrameChangeGuildInfoPublic(public)
    self.insts.GuildFrame_change_public.num.Text = public
end

--绑定changeGuildInfo的needPower按钮点击事件
function c:BindGuildFrameNeedPowerBtnClickHandle(obj,handle)
    self.insts.GuildFrame_change_needpower.leftBtn.MouseButton1Click:Connect(function()
        handle(obj,'left')
    end)
    self.insts.GuildFrame_change_needpower.rightBtn.MouseButton1Click:Connect(function()
        handle(obj,'right')
    end)
end

--绑定changeGuildInfo的type按钮点击事件
function c:BindGuildFrameTypeBtnClickHandle(obj,handle)
    self.insts.GuildFrame_change_type.leftBtn.MouseButton1Click:Connect(function()
        handle(obj,'left')
    end)
    self.insts.GuildFrame_change_type.rightBtn.MouseButton1Click:Connect(function()
        handle(obj,'right')
    end)
end

--绑定changeGuildInfo的public按钮点击事件
function c:BindGuildFramePublicBtnClickHandle(obj,handle)
    self.insts.GuildFrame_change_public.leftBtn.MouseButton1Click:Connect(function()
        handle(obj,'left')
    end)
    self.insts.GuildFrame_change_public.rightBtn.MouseButton1Click:Connect(function()
        handle(obj,'right')
    end)
end

--绑定PlayerItem的按钮点击事件
function c:BindPlayerItemBtnClickHandle(obj,handle)
    self.player_opBtn_obj = obj
    self.player_opBtn_handle = handle
end

--绑定LeaveBtn点击事件
function c:BindGuildFrameLeaveBtnClickHandle(obj,handle)
    self.insts.GuildFrame_leaveBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定GuildFrame的manageBtn点击事件
function c:BindGuildFrameManageBtnClickHandle(obj,handle)
    self.insts.GuildFrame_manageBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定GuildFrame的修改旗帜按钮点击事件
function c:BindGuildFrameFlagBtnClickHandle(obj,handle)
    self.insts.GuildFrame_change_flagbtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定GuildFrame的cancel按钮点击事件
function c:BindGuildFrameCancelBtnClickHandle(obj,handle)
    self.insts.GuildFrame_change_cancelBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定GuildFrame的sure按钮点击事件
function c:BindGuildFrameSureBtnClickHandle(obj,handle)
    self.insts.GuildFrame_change_sureBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--设置guildSenceBtn的显示
function c:SetGuildFrameGuildSenceBtnVisible(visible)
    self.insts.GuildFrame_guildSenceBtn.Visible = visible
end

--绑定GuildFrame的guildSenceBtn点击事件
function c:BindGuildFrameGuildSenceBtnClickHandle(obj,handle)
    self.insts.GuildFrame_guildSenceBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--设置DailyFrameLeft信息
function c:SetDailyFrameLeftInfo(lv,exp,contribution,coins)
    self.insts.DailyFrame_guildLvnum.Text = lv
    self.insts.DailyFrame_guildExpnum.Text = exp
    self.insts.DailyFrame_contributionnum.Text = contribution
    self.insts.DailyFrame_guildCoinsnum.Text = coins
end

--设置DailyFrameClaim按钮的显示
function c:SetDailyFrameClaimBtnVisible(visible)
    self.insts.DailyFrame_claimbtn.Visible = visible
    self.insts.DailyFrame_claimed.Visible = not visible
end

--向DailyFrame右侧添加子项
function c:AddDailyFrameRightItem(id,icon,num,quality)
    local inst = hotpot:CloneInst_Loop(self.insts.DailyFrame_rightitem)
    inst.Parent = self.insts.DailyFrame_right
    inst.Visible = true
    inst.btn.icon.Image = icon
    inst.btn.num.Text = 'x'.. num
    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        color:Clone().Parent = inst.btn
        color:Clone().Parent = inst.btn.UIStroke
    end
    self.dailyItemList[id] = inst

    inst.btn.MouseEnter:Connect(function()
        if self.__item_mouse_enter_handle then
            self.__item_mouse_enter_handle(self.__item_mouse_enter_obj,'daily',id)
        end
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y

        x = x / viewSize.X
        y = y / viewSize.Y

        self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    inst.btn.MouseMoved:Connect(function()
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y

        x = x / viewSize.X
        y = y / viewSize.Y

        self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    inst.btn.MouseLeave:Connect(function()
        self:SetTipsFrameVisible(false)
    end)
end

--设置DailyFrame右侧子项的Top显示
function c:SetDailyFrameItemTopVisible(id,visible)
    local inst = self.dailyItemList[id]
    if inst then
        inst.btn.top.Visible = visible
    end
end

--绑定DailyFrame领取按钮点击事件
function c:BindDailyFrameClaimBtnClickHandle(obj,handle)
    self.insts.DailyFrame_claimbtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定鼠标进入事件
function c:BindItemMouseEnterHandle(obj,handle)
    self.__item_mouse_enter_handle = handle
    self.__item_mouse_enter_obj = obj
end

--设置ShopFrameCoin
function c:SetShopFrameCoin(coin)
    self.insts.ShopFrame_coin.Text = coin
end

--设置ShopFrameRefreshTime
function c:SetShopFrameRefreshTime(cd)
    self.insts.ShopFrame_refreshTime.Text = refreshStr .. big_number:TransformDateToString(cd)
end

--向ShopFrame添加子项
function c:AddShopFrameItem(id,name,icon,price,num,limit,quality)
    local inst = hotpot:CloneInst_Loop(self.insts.ShopFrame_scrollitem)
    inst.Parent = self.insts.ShopFrame_ScrollingFrame
    inst.Visible = true
    inst.bg.board.icon.Image = icon
    inst.bg.btn.price.Text = price
    inst.bg.name.Text = name
    inst.bg.board.num.Text = 'x'.. num
    inst.bg.board.limit.Text = limit
    
    local color = qualityColor:FindFirstChild(tostring(quality))
    if color then
        color:Clone().Parent = inst.bg.board
        color:Clone().Parent = inst.bg.board.UIStroke
    end
    self.shopItemList[id] = inst

    inst.bg.btn.MouseButton1Click:Connect(function()
        if self.shopItemBuyBtn_handle then
            self.shopItemBuyBtn_handle(self.shopItemBuyBtn_obj,id)
        end
    end)

    inst.bg.board.MouseEnter:Connect(function()
        if self.__item_mouse_enter_handle then
            self.__item_mouse_enter_handle(self.__item_mouse_enter_obj,'shop',id)
        end
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y

        x = x / viewSize.X
        y = y / viewSize.Y

        self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    inst.bg.board.MouseMoved:Connect(function()
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y

        x = x / viewSize.X
        y = y / viewSize.Y

        self.insts.tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    inst.bg.board.MouseLeave:Connect(function()
        self:SetTipsFrameVisible(false)
    end)
end

--设置shopFramItem的Limit
function c:SetShopFrameItemLimit(id,limit)
    local inst = self.shopItemList[id]
    if inst then
        inst.bg.board.limit.Text = limit
    end
end

--绑定ShopFrame购买按钮点击事件
function c:BindShopFrameBuyBtnClickHandle(obj,handle)
    self.shopItemBuyBtn_obj = obj
    self.shopItemBuyBtn_handle = handle
end

--向RankFrame添加子项
function c:AddRankFrameItem(id,rank,lv,flag,icon,name,member,power)
    local inst = hotpot:CloneInst_Loop(self.insts.RankFrame_scrollitem)
    inst.Parent = self.insts.RankFrame_ScrollingFrame
    inst.Visible = true
    inst.LayoutOrder = rank
    inst.bg.rank.Text = rank
    inst.bg.lv.Text = lv
    inst.bg.flag.Image = flag
    inst.bg.flag.icon.Image = icon
    inst.bg.name.Text = name
    inst.bg.member.Text = member
    inst.bg.power.Text = big_number:ToString(power)

    local ui = hotpot:CloneInst_Loop(inst)
    ui.Parent = self.insts.Create_RankFrame_ScrollingFrame
    self.createRankList[id] = ui

    self.rankItemList[id] = inst
end

--移除所有RankFrameItem
function c:RemoveAllRankFrameItem()
    for _,v in pairs(self.rankItemList)do
        v:Destroy()
    end
    self.rankItemList = {}

    for _,v in pairs(self.createRankList)do
        v:Destroy()
    end
    self.createRankList = {}
end

--向请求界面添加子项
function c:AddRequestFrameItem(uid,icon,name,power)
    local inst = hotpot:CloneInst_Loop(self.insts.RequestFrame_scrollitem)
    inst.Parent = self.insts.RequestFrame_ScrollingFrame
    inst.Visible = true
    inst.bg.icon.Image = icon
    inst.bg.name.Text = name
    inst.bg.power.Text = string.format('Power:%s',big_number:ToString(power))
    inst.Name = uid

    inst.bg.sureBtn.MouseButton1Click:Connect(function()
        if self.RequestFrame_agree_handle then
            self.RequestFrame_agree_handle(self.RequestFrame_agree_obj,uid)
        end
    end)
    inst.bg.refuseBtn.MouseButton1Click:Connect(function()
        if self.RequestFrame_refuse_handle then
            self.RequestFrame_refuse_handle(self.RequestFrame_refuse_obj,uid)
        end
    end)
    self.requestItemList[uid] = inst
end

--移除RequestFrameItem
function c:RemoveRequestFrameItem(uid)
    local inst = self.requestItemList[uid]
    if inst then
        inst:Destroy()
    end
end

--移除所有RequestFrameItem
function c:RemoveAllRequestFrameItem()
    for _,v in pairs(self.requestItemList)do
        v:Destroy()
    end
    self.requestItemList = {}
end

--绑定同意申请按钮
function c:BindAgreeRequestBtn(obj,handle)
    self.RequestFrame_agree_handle = handle
    self.RequestFrame_agree_obj = obj
end

--绑定拒绝申请按钮
function c:BindRefuseRequestBtn(obj,handle)
    self.RequestFrame_refuse_handle = handle
    self.RequestFrame_refuse_obj = obj
end

--设置warnFrame的信息
function c:SetWarnFrameInfo(info)
    self.insts.warnFrame_info.Text = info
end

--设置warnFrame的显示
function c:SetWarnFrameVisible(visible)
    self.insts.warnFrame.Visible = visible
end

--绑定warnFrame的确认按钮
function c:BindWarnFrameYesBtn(obj,handle)
    self.insts.warnFrame_yesBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定warnFrame的取消按钮
function c:BindWarnFrameNoBtn(obj,handle)
    self.insts.warnFrame_noBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

---------------------------------------------GuildMainBg_Over

---------------------------------------------CreateGuildBg_Start
--初始化CreateGuildBg
function c:InitCreateGuildBg()
    local frames = {
        self.insts.CreateGuildFrame,
        self.insts.JoinFrame,
        self.insts.Create_RankFrame,
    }
    local topBtns = self.insts.CreateGuildBg_topBtns
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
    self.createRankList = {}
    self.joinItemList = {}
end

--设置CreateGuildBG的显示
function c:SetCreateGuildBgVisible(visible)
    self.insts.CreateGuildBg.Visible = visible
end

--设置CreateGuildFrame的visible
function c:SetCreateGuildFrameVisible(visible)
    self.insts.CreateGuildFrame.Visible = visible
end

--获取CreateGuildFrame的name
function c:GetCreateGuildFrameName()
    return self.insts.CreateGuildFrame_guideName.Text
end

--获取CreateGuildFrame的Announcement
function c:GetCreateGuildFrameAnnouncement()
    return self.insts.CreateGuildFrame_guideAnnouncement.Text
end

--设置JoinFrame的visible
function c:SetJoinFrameVisible(visible)
    self.insts.JoinGuildFrame.Visible = visible
end

--设置CreateRankFrame的visible
function c:SetCreateRankFrameVisible(visible)
    self.insts.Create_RankFrame.Visible = visible
end

--设置CreateGuildFrame的flag
function c:SetCreateGuildFrameFlag(flag,icon)
    self.insts.CreateGuildFrame_flag.Image = flag
    self.insts.CreateGuildFrame_flagicon.Image = icon
end

--设置CreateGuildFrame的PowerNeed
function c:SetCreateGuildFramePowerNeed(power)
    self.insts.CreateGuildFrame_powerNeed_num.Text = big_number:ToString(power)
end

--设置CreateGuildFrame的type
function c:SetCreateGuildFrameType(type_)
    self.insts.CreateGuildFrame_type_num.Text = type_
end

--设置CreateGuildFrame的public
function c:SetCreateGuildFramePublic(public)
    self.insts.CreateGuildFrame_public_num.Text = public
end

--绑定CreateGuildFrame的CreateBtn点击事件
function c:BindCreateGuildFrameCreateBtnClickHandle(obj,handle)
    self.insts.CreateGuildFrame_createBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定CreateGuildFrame的NeedPower点击事件
function c:BindCreateGuildFrameNeedPowerClickHandle(obj,handle)
    self.insts.CreateGuildFrame_powerNeed_leftBtn.MouseButton1Click:Connect(function()
        handle(obj,'left')
    end)
    self.insts.CreateGuildFrame_powerNeed_rightBtn.MouseButton1Click:Connect(function()
        handle(obj,'right')
    end)
end

--绑定CreateGuildFrame的Type点击事件
function c:BindCreateGuildFrameTypeClickHandle(obj,handle)
    self.insts.CreateGuildFrame_type_leftBtn.MouseButton1Click:Connect(function()
        handle(obj,'left')
    end)
    self.insts.CreateGuildFrame_type_rightBtn.MouseButton1Click:Connect(function()
        handle(obj,'right')
    end)
end

--绑定CreateGuildFrame的Public点击事件
function c:BindCreateGuildFramePublicClickHandle(obj,handle)
    self.insts.CreateGuildFrame_public_leftBtn.MouseButton1Click:Connect(function()
        handle(obj,'left')
    end)
    self.insts.CreateGuildFrame_public_rightBtn.MouseButton1Click:Connect(function()
        handle(obj,'right')
    end)
end

--绑定CreateFrame的EditBtn点击事件
function c:BindCreateGuildFrameEditBtnClickHandle(obj,handle)
    self.insts.CreateGuildFrame_editbtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--向JoinFrame添加子项
function c:AddJoinFrameItem(guildId,flag,icon,name,power,needPower,member)
    local ui = hotpot:CloneInst_Loop(self.insts.JoinFrame_scrollitem)
    ui.Parent = self.insts.JoinFrame_ScrollingFrame
    ui.Visible = true
    ui.bg.flag.Image = flag
    ui.bg.flag.icon.Image = icon
    ui.bg.guildName.Text = name
    ui.bg.power.num.Text = big_number:ToString(power)
    ui.bg.needpower.num.Text = big_number:ToString(needPower)
    ui.bg.menber.num.Text = member
    ui.Name = guildId
    self.joinItemList[guildId] = ui

    ui.bg.MouseButton1Click:Connect(function()
        if self.join_handle then
            self.join_handle(self.join_obj,guildId)
        end
    end)
end

--移除所有JoinFrame子项
function c:RemoveAllJoinFrameItem()
    for _,v in pairs(self.joinItemList)do
        v:Destroy()
    end
    self.joinItemList = {}
end

--设置Search按钮的cd
function c:SetJoinFrameSearchBtnCD(cd)
    if cd > 0 then
        self.insts.JoinFrame_searchBtn.TextLabel.Text = 'Search('..cd..'s)'
        self.insts.JoinFrame_searchBtn.Image = 'rbxassetid://106699665783834'
    else
        self.insts.JoinFrame_searchBtn.TextLabel.Text = 'Search'
        self.insts.JoinFrame_searchBtn.Image = 'rbxassetid://111460696655002'
    end
    
end

--设置Refresh按钮的cd
function c:SetJoinFrameRefreshBtnCD(cd)
    if cd > 0 then
        self.insts.JoinFrame_refreshBtn.TextLabel.Text = 'Refresh('..cd..'s)'
        self.insts.JoinFrame_refreshBtn.Image = 'rbxassetid://106699665783834'
    else
        self.insts.JoinFrame_refreshBtn.TextLabel.Text = 'Refresh'
        self.insts.JoinFrame_refreshBtn.Image = 'rbxassetid://139165666595094'
    end
end

--获取搜索框的信息
function c:GetJoinFrameSearchText()
    return self.insts.JoinFrame_serchTextBox.Text
end

--绑定JoinFrame的Item点击事件
function c:BindJoinFrameItemClickHandle(obj,handle)
    self.join_handle = handle
    self.join_obj = obj
end

--绑定JoinFrame的search点击事件
function c:BindJoinFrameSearchClickHandle(obj,handle)
    self.insts.JoinFrame_searchBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定JoinFrame的refresh点击事件
function c:BindJoinFrameRefreshClickHandle(obj,handle)
    self.insts.JoinFrame_refreshBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定JoinFrame的Search按钮点击事件
function c:BindJoinFrameSearchBtnClickHandle(obj,handle)
    self.insts.JoinFrame_searchBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定JoinFrame的Refresh按钮点击事件
function c:BindJoinFrameRefreshBtnClickHandle(obj,handle)
    self.insts.JoinFrame_refreshBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end
---------------------------------------------CreateGuildBg_Over


---------------------------------------------changeFlagBg_Start
--设置ChangeFlagBg的visible
function c:SetChangeFlagBgVisible(visible)
    self.insts.changeFlagBg.Visible = visible
end

--设置ChangeFlagBg的flag
function c:SetChangeFlagBgFlag(flag,icon)
    self.insts.changeFlagBg_flag.Image = flag
    self.insts.changeFlagBg_flagicon.Image = icon
end

--向ChangeFlagBg添加flag子项
function c:AddChangeFlagBgFlagItem(id,icon)
    local ui = hotpot:CloneInst_Loop(self.insts.changeFlagBg_flagList_item)
    ui.Parent = self.insts.changeFlagBg_flagList
    ui.Visible = true
    ui.icon.Image = icon
    self.changeFlagBg_flagList_items[id] = ui
    ui.btn.MouseButton1Click:Connect(function()
        self.changeFlagBg_flagItem_handle(self.changeFlagBg_flagItem_obj,id)
    end)
end

--向ChangeFlagBg添加icon子项
function c:AddChangeFlagBgIconItem(id,icon)
    local ui = hotpot:CloneInst_Loop(self.insts.changeFlagBg_iconList_item)
    ui.Parent = self.insts.changeFlagBg_iconList
    ui.Visible = true
    ui.icon.Image = icon
    self.changeFlagBg_iconList_items[id] = ui
    ui.btn.MouseButton1Click:Connect(function()
        self.changeFlagBg_iconItem_handle(self.changeFlagBg_iconItem_obj,id)
    end)
end

--设置ChangeFlagBg的flag子项select的visible
function c:SetChangeFlagBgFlagItemSelectVisible(id,visible)
    local ui = self.changeFlagBg_flagList_items[id]
    if ui then
        ui.select.Visible = visible
    end
end

--设置ChangeFlagBg的icon子项select的visible
function c:SetChangeFlagBgIconItemSelectVisible(id,visible)
    local ui = self.changeFlagBg_iconList_items[id]
    if ui then
        ui.select.Visible = visible
    end
end

--点击确认按钮
function c:BindChangeFlagBgSureBtnClickHandle(obj,handle)
    self.insts.changeFlagBg_btn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定ChangeFlagBg的flag子项点击事件
function c:BindChangeFlagBgFlagItemClickHandle(obj,handle)
    self.changeFlagBg_flagItem_handle = handle
    self.changeFlagBg_flagItem_obj = obj
end

--绑定ChangeFlagBg的icon子项点击事件
function c:BindChangeFlagBgIconItemClickHandle(obj,handle)
    self.changeFlagBg_iconItem_handle = handle
    self.changeFlagBg_iconItem_obj = obj
end
---------------------------------------------changeFlagBg_Over

return c