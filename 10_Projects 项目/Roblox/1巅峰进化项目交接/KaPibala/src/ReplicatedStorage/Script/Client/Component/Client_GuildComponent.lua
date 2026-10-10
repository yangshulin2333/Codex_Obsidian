local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type ProjectConfig
local proCfg = hotpot.load.ProjectConfig()
---@type Players
local Players = game:GetService('Players')
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()
---@type GameClient
local client = _G.client

local STARTTIME = 1766534400
local searchCD = -60
local refreshCD = -60
local random = Random.new()
local normalExitStr = 'Leave will trigger an 8-hour cooldown before joining another guild.'
local leaderExitStr = 'As the leader, leaving will transferleadership and trigger an 8-hour cooldown before joining another guild.'
local guildDailyCfg = hotpot.config.guildDaily
local guildShopCfg = hotpot.config.guildShop

---@class Client_GuildComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('guild')
    self.ui = ui_manager.ui_list.guild_gui
    self.ui:BindCreateGuildFrameCreateBtnClickHandle(self,self.ClickCreateGuildFrameCreateBtn)
    self.ui:BindCreateGuildFrameNeedPowerClickHandle(self,self.ClickCreateGuildFrameNeedPowerBtn)
    self.ui:BindCreateGuildFramePublicClickHandle(self,self.ClickCreateGuildFramePublicBtn)
    self.ui:BindCreateGuildFrameTypeClickHandle(self,self.ClickCreateGuildFrameTypeBtn)
    self.ui:BindCreateGuildFrameEditBtnClickHandle(self,self.ClickCreateGuildFrameEditBtn)
    self.ui:BindChangeFlagBgFlagItemClickHandle(self,self.ClickChangeFlagBgFlagItem)
    self.ui:BindChangeFlagBgIconItemClickHandle(self,self.ClickChangeFlagBgIconItem)
    self.ui:BindChangeFlagBgSureBtnClickHandle(self,self.ClickChangeFlagBgSureBtn)
    self.ui:BindJoinFrameItemClickHandle(self,self.ClickJoinFrameItem)
    self.ui:BindJoinFrameRefreshBtnClickHandle(self,self.ClickJoinFrameRefreshBtn)
    self.ui:BindJoinFrameSearchBtnClickHandle(self,self.ClickJoinFrameSearchBtn)
    self.ui:BindGuildFrameManageBtnClickHandle(self,self.ClickGuildFrameManageBtn)
    self.ui:BindGuildFrameLeaveBtnClickHandle(self,self.ClickGuildFrameLeaveBtn)
    self.ui:BindGuildFrameFlagBtnClickHandle(self,self.ClickGuildFrameFlagBtn)
    self.ui:BindGuildFrameSureBtnClickHandle(self,self.ClickGuildFrameChangeGuildInfoSureBtn)
    self.ui:BindGuildFrameCancelBtnClickHandle(self,self.ClickGuildFrameChangeGuildInfoCancelBtn)
    self.ui:BindGuildFrameNeedPowerBtnClickHandle(self,self.ClickGuildFrameNeedPowerBtn)
    self.ui:BindGuildFrameTypeBtnClickHandle(self,self.ClickGuildFrameTypeBtn)
    self.ui:BindGuildFramePublicBtnClickHandle(self,self.ClickGuildFramePublicBtn)
    self.ui:BindPlayerItemBtnClickHandle(self,self.ClickPlayerInfoOperationBtn)
    self.ui:BindAgreeRequestBtn(self,self.ClickAgreePlayerBtn)
    self.ui:BindRefuseRequestBtn(self,self.ClickRefusePlayerBtn)
    self.ui:BindWarnFrameYesBtn(self,self.ClickWarnFrameYesBtn)
    self.ui:BindWarnFrameNoBtn(self,self.ClickWarnFrameNoBtn)
    self.ui:BindDailyFrameClaimBtnClickHandle(self,self.ClickDailyFrameClaimBtn)
    self.ui:BindShopFrameBuyBtnClickHandle(self,self.ClickShopFrameItemBtn)
    self.ui:BindGuildFrameGuildSenceBtnClickHandle(self,self.ClickGuildFrameGuildSenceBtn)
    self.ui:BindItemMouseEnterHandle(self,self.MouseEnterItem)

    ui_manager.ui_list.npc_gui:BindWarRegisterBtnClickHandle(self,self.ClickRegisterBtn)
    ui_manager.ui_list.npc_gui:BindWarClaimBtnClickHandle(self,self.ClickClaimWarRewardBtn)

    self:GetGuildInfo()
    self:AddUpdate(self.GetGuildInfo,60)
    self.ui:SetGuildFrameChangeGuildInfoVisible(false)

    self.changeFlagBg_flag = 1
    self.changeFlagBg_icon = 1

    self:InitUi()
    self:AddProcess(function()
        self:RefreshRank1()
        while true do
            self:Wait(300)
            local battle = hotpot.pro_cfg.IsInGuildBattleTime()
            if battle then
                self:RefreshRank1()
            end
        end
    end)
    self:AddProcess(function()
        self:Wait(10)
        self:RefreshRank2()
        while true do
            self:Wait(600)
            self:RefreshRank1()
        end
    end)
end

function c:GetGuildInfo()
    if not self.data.id then
        self.guildInfo = nil
    end
    local re = self:Invoke('getGuildInfo')
    if re then
        self.guildInfo = re
        self:RefreshGuildUi()
    end
end

function c:RefreshGuildUi()
    if not self.guildInfo then
        return
    end
    local maxLv = #proCfg.guildLv
    local lv = self.guildInfo.lv
    local exp = self.guildInfo.exp
    local lvStr = ''
    if lv == maxLv then
        lvStr = string.format('Lv %s(MAX)',lv)
    else
        lvStr = string.format('Lv %s(%s/%s)',lv,exp,proCfg.guildLv[lv])
    end
    local typeStr = self.guildInfo.type == 1 and 'No Verification Required' or 'Verification Required'
    local memberStr = string.format('%s/%s',self.guildInfo.player_count,self.guildInfo.max_player_count)
    self.ui:SetGuildFrameGuildInfo(
        self.guildInfo.guild_name,
        self.guildInfo.showId,
        proCfg.guildFlag[self.guildInfo.flag],
        proCfg.guildIcon[self.guildInfo.icon],
        lvStr,
        self.guildInfo.announcement,
        self.guildInfo.total_power,
        proCfg.guildNeedPower[self.guildInfo.need_power],
        typeStr,
        memberStr
    )

    local myInfo = self.guildInfo.player_list[self.parent.user_id]
    local expStr = string.format('%s/%s',exp,proCfg.guildLv[lv])
    myInfo = myInfo or {}
    self.ui:SetDailyFrameLeftInfo(
        lv,
        expStr,
        myInfo.contribution or 0,
        self.data.coin
    )
    
    local myInfo = self.guildInfo.player_list[self.parent.user_id]
    if not myInfo then
        return
    end
    local isManage = myInfo.post >= 4
    self.ui:SetGuildFrameManageBtnVisible(isManage)
    if self.manageState then
        return
    end

    self.ui:RemoveAllPlayerInfoInGuildFrameScrollingFrame()
    local list = {}
    for uid,data in pairs(self.guildInfo.player_list)do
        table.insert(list,{
            uid = uid,
            post = data.post,
            data = data
        })
    end
    table.sort(list,function(a,b)
        return a.post > b.post
    end)
    for i,data in ipairs(list)do
        spawn(function()
            local r,e = pcall(function()
                return Players:GetNameFromUserIdAsync(data.uid)
            end)
            if not r then
                e = 'UnknownName'
            end
            local loginTime = workspace:GetServerTimeNow() - data.data.last_active
            local loginstr = ''
            if loginTime < 3600 then
                loginstr = string.format('%s minutes',math.floor(loginTime / 60))
            elseif loginTime < 86400 then
                loginstr = string.format('%s hours',math.floor(loginTime / 3600))
            elseif loginTime < 86400 * 30 then
                loginstr = string.format('%s days',math.floor(loginTime / 86400))
            else
                loginstr = string.format('%s months',math.floor(loginTime / 86400 * 30))
            end

            self.ui:AddPlayerInfoInGuildFrameScrollingFrame(
                data.uid,
                i,
                proCfg.guildPost[data.post],
                data.data.lv,
                e,
                loginstr,
                data.data.contribution,
                data.data.power
            )
        end)
    end

    local requestList = self.guildInfo.apply_list
    self.ui:RemoveAllRequestFrameItem()
    for uid,data in pairs(requestList)do
        local name = ''
        local r,e = pcall(function()
            return Players:GetNameFromUserIdAsync(uid)
        end)
        if not r then
            name = 'UnknownName'
        else
            name = e
        end
        local icon = ''
        r,e = pcall(function()
            return Players:GetUserThumbnailAsync(uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48)
        end)
        if not r then
            icon = ''
        else
            icon = e
        end
        self.ui:AddRequestFrameItem(
            uid,
            icon,
            name,
            data.power
        )
    end

    if place_manager:GetIdByName('guildsence') == game.PlaceId then
        self:RefreshWarNPCState()
    end
end

function c:InitUi()
    local guildId = self.data.id
    -- print(guildId)
    if guildId then--拥有公会
        self.ui:SetCreateGuildBgVisible(false)
        self.ui:SetGuildMainBgVisible(true)
        self:LoadDailyReward()
        self:LoadShop()
    else
        self.ui:SetCreateGuildBgVisible(true)
        self.ui:SetGuildMainBgVisible(false)
        self.ui:SetCreateGuildFrameFlag(proCfg.guildFlag[1],proCfg.guildIcon[1])
        self.createFrame_needPower_idx = 1
        self.createFrame_Type_idx = 1
        self.createFrame_public_idx = 1

        self:RefreshJoinGuildFrame()
    end

    --添加旗帜与icon
    for k,v in ipairs(proCfg.guildFlag)do
        local idx = k
        self.ui:AddChangeFlagBgFlagItem(idx,v)
    end
    for k,v in ipairs(proCfg.guildIcon)do
        local idx = k
        self.ui:AddChangeFlagBgIconItem(idx,v)
    end

    self:AddProcess(function()
        self:Wait(5)
        self:LoadRank()
    end)
    self:AddUpdate(self.LoadRank,610)
end

function c:RefreshWarNPCState()
    local week = hotpot.pro_cfg.GetWeek()
    ---@type Client_GuildStageObj
    local guild_stage_obj = client.guild_stage_obj
    if hotpot.pro_cfg.IsInGuildJoinTime() then--在报名时间内
        local guild_info = self.guildInfo
        local warInfo = guild_info.warInfo 
        if not warInfo then
            guild_stage_obj:SetWarNPCState('Not Registration',Color3.fromRGB(255,0,0))
        else
            if week == warInfo.week and warInfo.is_join then
                guild_stage_obj:SetWarNPCState('Already registered',Color3.fromRGB(0,255,0))
                ui_manager.ui_list.npc_gui:SetWarRegisterBtnState(false)
            else
                guild_stage_obj:SetWarNPCState('Not Registration',Color3.fromRGB(255,0,0))
                ui_manager.ui_list.npc_gui:SetWarRegisterBtnState(true)
            end
        end
    elseif hotpot.pro_cfg.IsInGuildBattleTime() then
    else
        guild_stage_obj:SetWarNPCState('Finished',Color3.fromRGB(0,0,0))
    end
end

function c:RefreshJoinGuildFrame()
    local re = self:Invoke('getJoinGuildList')
    if not re then
        return
    end
    -- print(re)
    self.guildList = re
    self.ui:RemoveAllJoinFrameItem()

    local list = {}

    local sum = 0
    for guildId,data in pairs(re)do
        if data.public == 1 then
            if data.player_count < data.max_player_count then
                table.insert(list,{
                    guildId = guildId,
                    data = data
                })
            end
        end
    end

    random:Shuffle(list)

    for _,v in ipairs(list)do
        local guildId = v.guildId
        local data = v.data
        if sum < 10 then
            self.ui:AddJoinFrameItem(
                guildId,
                proCfg.guildFlag[data.flag],
                proCfg.guildIcon[data.icon],
                data.name,
                data.power,
                proCfg.guildNeedPower[data.needPower],
                data.player_count..'/'..data.max_player_count
            )
        else
            break
        end
        sum = sum + 1
    end
end

function c:UpdateGuildId(guildId)
    if self.data.id == guildId then
        return
    end
    self.data.id = guildId
    self:GetGuildInfo()
    self:InitUi()
end

function c:LoadDailyReward()
    local myInfo = self.guildInfo.player_list[self.parent.user_id]
    if myInfo then
        local contribution = myInfo.contribution
        local coin = self.data.coin
        local lv = self.guildInfo.lv
        local exp = self.guildInfo.exp
        local maxLv = #proCfg.guildLv
        local expStr = string.format('%s/%s',exp,proCfg.guildLv[lv])
        
        self.ui:SetDailyFrameLeftInfo(lv,expStr,contribution,coin)
    end
    for k,v in ipairs(guildDailyCfg)do
        self.ui:AddDailyFrameRightItem(
            v.id,
            self.parent.reward_cmp:GetIcon(v.reward),
            v.reward[3],
            self.parent.reward_cmp:GetQulity(v.reward)
        )
        self.ui:SetDailyFrameItemTopVisible(v.id,self.data.daily.get >= v.id)
    end
    self.ui:SetDailyFrameClaimBtnVisible(self.data.daily.can_get)
end

function c:LoadShop()
    self.ui:SetShopFrameCoin(self.data.coin)
    for k,v in ipairs(guildShopCfg)do
        local buy = self.data.shop.list[v.id] or 0
        self.ui:AddShopFrameItem(
            v.id,
            self.parent.reward_cmp:GetName(v.reward),
            self.parent.reward_cmp:GetIcon(v.reward),
            v.price,
            self.parent.reward_cmp:GetNum(v.reward),
            buy..'/'..v.limit,
            self.parent.reward_cmp:GetQulity(v.reward)
        )
    end
end

function c:LoadRank()
    local re = self:Invoke('getGuildRank')
    if not re then
        return
    end
    self.rankList = re

    self.ui:RemoveAllRankFrameItem()
    for k,v in ipairs(self.rankList)do
        self.ui:AddRankFrameItem(
            k,
            k,
            v.lv,
            proCfg.guildFlag[v.flag],
            proCfg.guildIcon[v.icon],
            v.name,
            v.player_count..'/'..v.max_player_count,
            v.power
        )
    end
end

function c:AddCoin(num)
    self.data.coin = self.data.coin + num
    self.ui:SetShopFrameCoin(self.data.coin)
end
------------------------CreateGuildFrame
--点击NeedPowerBtn
function c:ClickCreateGuildFrameNeedPowerBtn(dir)
    if dir == 'left' then
        self.createFrame_needPower_idx = self.createFrame_needPower_idx - 1
        if self.createFrame_needPower_idx < 1 then
            self.createFrame_needPower_idx = #proCfg.guildNeedPower
        end
    elseif dir == 'right' then
        self.createFrame_needPower_idx = self.createFrame_needPower_idx + 1
        if self.createFrame_needPower_idx > #proCfg.guildNeedPower then
            self.createFrame_needPower_idx = 1
        end
    end
    self.ui:SetCreateGuildFramePowerNeed(proCfg.guildNeedPower[self.createFrame_needPower_idx])
end
--点击TypeBtn
function c:ClickCreateGuildFrameTypeBtn(dir)
    if dir == 'left' then
        self.createFrame_Type_idx = self.createFrame_Type_idx - 1
        if self.createFrame_Type_idx < 1 then
            self.createFrame_Type_idx = #proCfg.guildType
        end
    elseif dir == 'right' then
        self.createFrame_Type_idx = self.createFrame_Type_idx + 1
        if self.createFrame_Type_idx > #proCfg.guildType then
            self.createFrame_Type_idx = 1
        end
    end
    self.ui:SetCreateGuildFrameType(proCfg.guildType[self.createFrame_Type_idx])
end
--点击PublicBtn
function c:ClickCreateGuildFramePublicBtn(dir)
    if dir == 'left' then
        self.createFrame_public_idx = self.createFrame_public_idx - 1
        if self.createFrame_public_idx < 1 then
            self.createFrame_public_idx = #proCfg.guildPublic
        end
    elseif dir == 'right' then
        self.createFrame_public_idx = self.createFrame_public_idx + 1
        if self.createFrame_public_idx > #proCfg.guildPublic then
            self.createFrame_public_idx = 1
        end
    end
    self.ui:SetCreateGuildFramePublic(proCfg.guildPublic[self.createFrame_public_idx])
end
--点击EditBtn
function c:ClickCreateGuildFrameEditBtn()
    self.ui:SetChangeFlagBgFlag(proCfg.guildFlag[self.changeFlagBg_flag],proCfg.guildIcon[self.changeFlagBg_icon])
    self.ui:SetChangeFlagBgVisible(true)
    self.createGuildFrame_editState = true
end
--点击创建按钮
function c:ClickCreateGuildFrameCreateBtn()
    local flag = self.changeFlagBg_flag
    local icon = self.changeFlagBg_icon
    local name = self.ui:GetCreateGuildFrameName()
    local announcement = self.ui:GetCreateGuildFrameAnnouncement()
    local needPower = self.createFrame_needPower_idx
    local type_ = self.createFrame_Type_idx
    local public = self.createFrame_public_idx
    
    name = name:gsub("%s+", "")
    local name_len = name:len()
    if name_len == 0 then
        ui_manager.ui_list.tips_gui:TipsMessage('Please input name','fail')
        return
    end
    if name_len > 15 then
        ui_manager.ui_list.tips_gui:TipsMessage('Name is too long','fail')
        return
    end
    if announcement:len() > 100 then
        ui_manager.ui_list.tips_gui:TipsMessage('Announcement is too long','fail')
        return
    end

    local gems = self.parent.prop_cmp:GetGems()
    if gems < 2000 then
        ui_manager.ui_list.tips_gui:TipsMessage('Not enough gems','fail')
        return
    end

    local info = {
        flag = flag,
        icon = icon,
        name = name,
        announcement = announcement,
        needPower = needPower,
        type_ = type_,
        public = public,
    }

    local re,guildId = self:Invoke('CreateGuild',info)
    if re then
        self.data.id = guildId
        self:GetGuildInfo()
        self.ui:SetCreateGuildBgVisible(false)
        self.ui:SetGuildMainBgVisible(true)
        ui_manager.ui_list.tips_gui:TipsMessage('Create success','success')
    else
        if guildId == 1 then
            ui_manager.ui_list.tips_gui:TipsMessage('GuildName is exist','fail')
        elseif guildId == 'cold' then
            ui_manager.ui_list.tips_gui:TipsMessage('You can only create one guild within a single day.','fail')
        end
    end
end

--点击JoinFrame的Item
function c:ClickJoinFrameItem(guildId)
    local tab = self.guildList[guildId]
    if not tab then
        return
    end
    local re,gid = self:Invoke('RequestJoinGuild',guildId)
    if re then
        if gid then
            self.data.id = gid
            self:GetGuildInfo()
            self.ui:SetCreateGuildBgVisible(false)
            self.ui:SetGuildMainBgVisible(true)
            ui_manager.ui_list.tips_gui:TipsMessage('Join success','success')
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Request success,wait for approval','success')
        end
    else
        if gid == 1 then
            ui_manager.ui_list.tips_gui:TipsMessage('Guild is full','fail')
        elseif gid == 2 then
            ui_manager.ui_list.tips_gui:TipsMessage('Already applyed','fail')
        elseif gid == 3 then
            ui_manager.ui_list.tips_gui:TipsMessage('Guild is private','fail')
        elseif gid == 4 then
            ui_manager.ui_list.tips_gui:TipsMessage('Power is not enough','fail')
        elseif gid == 5 then
            ui_manager.ui_list.tips_gui:TipsMessage('The cooling time has not yet elapsed.','fail')
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Request fail','fail')
        end
    end
end

--点击JoinFrame的Refresh按钮
function c:ClickJoinFrameRefreshBtn()
    if os.clock() - refreshCD < 60 then
        ui_manager.ui_list.tips_gui:TipsMessage('You clicked too quickly','fail')
        return
    end
    refreshCD = os.clock()
    spawn(function()
        local cd = 60
        while cd > 0 do
            cd = cd - 1
            self.ui:SetJoinFrameRefreshBtnCD(cd)
            wait(1)
        end
    end)
    self:RefreshJoinGuildFrame()
end

--点击JoinFrame的Search按钮
function c:ClickJoinFrameSearchBtn()
    if os.clock() - searchCD < 60 then
        ui_manager.ui_list.tips_gui:TipsMessage('You clicked too quickly','fail')
        return
    end
    searchCD = os.clock()
    spawn(function()
        local cd = 60
        while cd > 0 do
            cd = cd - 1
            self.ui:SetJoinFrameSearchBtnCD(cd)
            wait(1)
        end
    end)
    local txt = self.ui:GetJoinFrameSearchText()
    txt = txt:gsub("%s+", "")
    if txt:len() == 0 then
        ui_manager.ui_list.tips_gui:TipsMessage('Please input name or id','fail')
        return
    end
    local re,info = self:Invoke('SearchGuild',txt)
    -- print(re,info)
    if re then
        self.ui:RemoveAllJoinFrameItem()
        self.ui:AddJoinFrameItem(
            info.guild_id,
            proCfg.guildFlag[info.flag],
            proCfg.guildIcon[info.icon],
            info.guild_name,
            info.total_power,
            proCfg.guildNeedPower[info.need_power],
            info.player_count..'/'..info.max_player_count
        )
    end
end
------------------------CreateGuildFrame


------------------------changeFlagBg
---点击ChangeFlagBg的flag子项
function c:ClickChangeFlagBgFlagItem(id)
    if self.changeFlagBg_flag then
        self.ui:SetChangeFlagBgFlagItemSelectVisible(self.changeFlagBg_flag,false)
    end
    self.ui:SetChangeFlagBgFlagItemSelectVisible(id,true)
    self.changeFlagBg_flag = id
end
---点击ChangeFlagBg的icon子项
function c:ClickChangeFlagBgIconItem(id)
    if self.changeFlagBg_icon then
        self.ui:SetChangeFlagBgIconItemSelectVisible(self.changeFlagBg_icon,false)
    end
    self.ui:SetChangeFlagBgIconItemSelectVisible(id,true)
    self.changeFlagBg_icon = id
end
--点击ChangeFlagBg的确认按钮
function c:ClickChangeFlagBgSureBtn()
    self.ui:SetChangeFlagBgVisible(false)

    if self.createGuildFrame_editState then
        self.ui:SetCreateGuildFrameFlag(proCfg.guildFlag[self.changeFlagBg_flag],proCfg.guildIcon[self.changeFlagBg_icon])
    end

    if self.modifyFlagState then
        self.modify_flag = self.changeFlagBg_flag
        self.modify_icon = self.changeFlagBg_icon

        self.ui:SetGuildFrameChangeGuildInfoFlagIcon(
            proCfg.guildFlag[self.modify_flag],
            proCfg.guildIcon[self.modify_icon]
        )
    end

    self.modifyFlagState = false
    self.createGuildFrame_editState = false
end
------------------------changeFlagBg

------------------------GuildMainBg_Start
--点击管理按钮
function c:ClickGuildFrameManageBtn()
    if not self.guildInfo then
        return
    end
    local guildInfo = self.guildInfo
    local uid = self.parent.user_id
    local data = guildInfo.player_list[uid]
    if not data then
        return
    end
    if data.post < 4 then
        return
    end
    local info = {}
    info.flag = proCfg.guildFlag[guildInfo.flag]
    info.icon = proCfg.guildIcon[guildInfo.icon]
    info.name = guildInfo.guild_name
    info.des = guildInfo.announcement
    info.showId = guildInfo.showId
    local maxLv = #proCfg.guildLv
    local lv = self.guildInfo.lv
    local exp = self.guildInfo.exp
    local lvStr = ''
    if lv == maxLv then
        lvStr = string.format('Lv %s(MAX)',lv)
    else
        lvStr = string.format('Lv %s(%s/%s)',lv,exp,proCfg.guildLv[lv])
    end
    local typeStr = self.guildInfo.type == 1 and 'No Verification Required' or 'Verification Required'
    local memberStr = string.format('%s/%s',self.guildInfo.player_count,self.guildInfo.max_player_count)
    info.lv = lvStr
    info.type_ = typeStr
    info.member = memberStr
    info.public = self.guildInfo.public == 1 and 'Public' or 'Private'
    info.power = guildInfo.total_power
    info.need_power = proCfg.guildNeedPower[guildInfo.need_power]

    self.ui:SetGuildFrameChangeGuildInfo(info)
    self.ui:SetGuildFrameChangeGuildInfoVisible(true)

    self.modify_flag = self.guildInfo.flag
    self.modify_icon = self.guildInfo.icon
    self.modify_need_power = self.guildInfo.need_power
    self.modify_type = self.guildInfo.type
    self.modify_public = self.guildInfo.public

    self.manageState = true
    local myPost = data.post
    for k,v in pairs(guildInfo.player_list)do
        if myPost > v.post then
            if v.post == 1 then
                self.ui:SetPlayerInfoOperationBtnVisible(k,true,false,true)
            else
                self.ui:SetPlayerInfoOperationBtnVisible(k,true,true,false)
            end
        end
    end
end

--点击退出按钮
function c:ClickGuildFrameLeaveBtn()
    local myInfo = self.guildInfo.player_list[self.parent.user_id]
    if myInfo.post == 5 then
        self.ui:SetWarnFrameInfo(leaderExitStr)
    else
        self.ui:SetWarnFrameInfo(normalExitStr)
    end
    self.ui:SetWarnFrameVisible(true)
end

--点击确定退出按钮
function c:ClickWarnFrameYesBtn()
    local re,cd = self:Invoke('LeaveGuild')
    if re then
        self.data.exit_cd = cd
        self.data.id = nil
        self:InitUi()
        self.ui:SetWarnFrameVisible(false)
    end
end

--点击取消退出按钮
function c:ClickWarnFrameNoBtn()
    self.ui:SetWarnFrameVisible(false)
end

--点击修改旗帜按钮
function c:ClickGuildFrameFlagBtn()
    self.ui:SetChangeFlagBgFlag(proCfg.guildFlag[self.modify_flag],proCfg.guildIcon[self.modify_icon])
    self.ui:SetChangeFlagBgIconItemSelectVisible(self.modify_icon,true)
    self.ui:SetChangeFlagBgFlagItemSelectVisible(self.modify_flag,true)
    self.ui:SetChangeFlagBgVisible(true)
    self.modifyFlagState = true
end
--点击修改界面的needPower按钮
function c:ClickGuildFrameNeedPowerBtn(dir)
    local max = #proCfg.guildNeedPower
    if dir == 'left' then
        self.modify_need_power = self.modify_need_power - 1
        if self.modify_need_power == 0 then
            self.modify_need_power = max
        end
    else
        self.modify_need_power = self.modify_need_power + 1
        if self.modify_need_power == max + 1 then
            self.modify_need_power = 1
        end
    end
    self.ui:SetGuildFrameChangeGuildInfoNeedPower(proCfg.guildNeedPower[self.modify_need_power])
end
--点击修改界面的type按钮
function c:ClickGuildFrameTypeBtn(dir)
    if dir == 'left' then
        self.modify_type = self.modify_type - 1
        if self.modify_type < 1 then
            self.modify_type = #proCfg.guildType
        end
    elseif dir == 'right' then
        self.modify_type = self.modify_type + 1
        if self.modify_type > #proCfg.guildType then
            self.modify_type = 1
        end
    end
    self.ui:SetGuildFrameChangeGuildInfoType(proCfg.guildType[self.modify_type])
end
--点击修改界面的public按钮
function c:ClickGuildFramePublicBtn(dir)
    if dir == 'left' then
        self.modify_public = self.modify_public - 1
        if self.modify_public < 1 then
            self.modify_public = #proCfg.guildPublic
        end
    elseif dir == 'right' then
        self.modify_public = self.modify_public + 1
        if self.modify_public > #proCfg.guildPublic then
            self.modify_public = 1
        end
    end
    self.ui:SetGuildFrameChangeGuildInfoPublic(proCfg.guildPublic[self.modify_public])
end
--点击修改界面的确认按钮
function c:ClickGuildFrameChangeGuildInfoSureBtn()
    local name,des = self.ui:GetGuildFrameChangeGuildInfoNameDes()
    name = name:gsub('%s','')
    local nameLen = name:len()
    local desLen = des:len()
    if nameLen == 0 then
        ui_manager.ui_list.tips_gui:TipsMessage('Please input name','fail')
        return
    end
    if desLen > 100 then
        ui_manager.ui_list.tips_gui:TipsMessage('Announcement is too long','fail')
        return
    end
    if nameLen > 15 then
        ui_manager.ui_list.tips_gui:TipsMessage('Name is too long','fail')
        return
    end

    local flag = self.modify_flag
    local icon = self.modify_icon
    local need_power = self.modify_need_power
    local type_ = self.modify_type
    local public = self.modify_public

    local modifyInfo = {
        name = name,
        des = des,
        flag = flag,
        icon = icon,
        need_power = need_power,
        type_ = type_,
        public = public,
    }
    local re = self:Invoke('ModifyGuildInfo',modifyInfo)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Modify success','success')
        self.guildInfo.guild_name = name
        self.guildInfo.announcement = des
        self.guildInfo.flag = flag
        self.guildInfo.icon = icon
        self.guildInfo.need_power = need_power
        self.guildInfo.type = type_
        self.guildInfo.public = public

        self:RefreshGuildUi()
    else
        ui_manager.ui_list.tips_gui:TipsMessage('Modify failed','fail')
    end
    self.ui:SetGuildFrameChangeGuildInfoVisible(false)

    for k,v in pairs(self.guildInfo.player_list)do
        self.ui:SetPlayerInfoOperationBtnVisible(k,false,false,false)
    end

    self.manageState = false
end
--点击修改界面的取消按钮
function c:ClickGuildFrameChangeGuildInfoCancelBtn()
    self.ui:SetGuildFrameChangeGuildInfoVisible(false)
    for k,v in pairs(self.guildInfo.player_list)do
        self.ui:SetPlayerInfoOperationBtnVisible(k,false,false,false)
    end

    self.manageState = false
end
--点击操作玩家按钮
function c:ClickPlayerInfoOperationBtn(op,uid)
    local guildInfo = self.guildInfo
    if not guildInfo then
        return 
    end
    local myInfo = guildInfo.player_list[self.parent.user_id]
    if not myInfo then
        return
    end
    if myInfo.post < 4 then
        return
    end

    local targetInfo = guildInfo.player_list[uid]
    if not targetInfo then
        return
    end

    local nowPost = targetInfo.post

    if op == 'promotion' then
        if nowPost >= 4 then
            ui_manager.ui_list.tips_gui:TipsMessage('The highest authority cannot be promoted','fail')
            return
        end
        local re = self:Invoke('PromotionPlayer',self.parent.user_id,uid)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage('Promotion success','success')
            targetInfo.post = nowPost + 1
            self.ui:SetPlayerInfoPost(uid,proCfg.guildPost[nowPost + 1])
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Promotion failed','fail')
        end
    elseif op == 'demotion' then
        if nowPost <= 1 then
            ui_manager.ui_list.tips_gui:TipsMessage('The lowest authority cannot be demoted','fail')
            return
        end
        local re = self:Invoke('DemotionPlayer',self.parent.user_id,uid)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage('Demotion success','success')
            targetInfo.post = nowPost - 1
            self.ui:SetPlayerInfoPost(uid,proCfg.guildPost[nowPost - 1])
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Demotion failed','fail')
        end
    elseif op == 'kick' then
        if targetInfo.post ~= 1 then
            return
        end
        local re,kickTime = self:Invoke('KickPlayer',self.parent.user_id,uid)
        if re then
            if kickTime then
                ui_manager.ui_list.tips_gui:TipsMessage('Kick fail,Only 5 people are allowed to be kicked each day.','fail')
            else
                ui_manager.ui_list.tips_gui:TipsMessage('Kick success','success')
                self.ui:RemovePlayerInfoInGuildFrameScrollingFrame(uid)
            end
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Kick failed','fail')
        end
    end

    nowPost = targetInfo.post
    self.ui:SetPlayerInfoOperationBtnVisible(uid,true,nowPost > 1,nowPost == 1)
end
--点击同意玩家
function c:ClickAgreePlayerBtn(uid)
    if self.guildInfo then
        if self.guildInfo.player_list[uid] then
            ui_manager.ui_list.tips_gui:TipsMessage('The player has already been processed','fail')
            return
        end
        if self.guildInfo.player_count >= self.guildInfo.max_player_count then
            ui_manager.ui_list.tips_gui:TipsMessage('The guild is full','fail')
            return
        end

        local myInfo = self.guildInfo.player_list[self.parent.user_id]
        if not myInfo then
            return
        end
        if myInfo.post < 4 then
            ui_manager.ui_list.tips_gui:TipsMessage('You do not have the authority to agree','fail')
            return
        end

        local re = self:Invoke('AgreePlayer',self.parent.user_id,uid)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage('Agree success','success')
            self.ui:RemoveRequestFrameItem(uid)
            self:GetGuildInfo()
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Agree failed','fail')
        end
    end
end
--点击拒绝玩家
function c:ClickRefusePlayerBtn(uid)
    if self.guildInfo then
        if not self.guildInfo.apply_list[uid] then
            ui_manager.ui_list.tips_gui:TipsMessage('The player has not applied','fail')
            return
        end
        local myInfo = self.guildInfo.player_list[self.parent.user_id]
        if not myInfo then
            return
        end
        if myInfo.post < 4 then
            ui_manager.ui_list.tips_gui:TipsMessage('You do not have the authority to agree','fail')
            return
        end
        local re = self:Invoke('RefusePlayer',self.parent.user_id,uid)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage('Refuse success','success')
            self.ui:RemoveRequestFrameItem(uid)
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Refuse failed','fail')
        end
    end
end
--点击传送至公会场景
function c:ClickGuildFrameGuildSenceBtn()
    if place_manager:GetIdByName('guildsence') == game.PlaceId then
        return
    end
    self:Fire('TeleportToGuildSence')
    self:AddProcess(function()
        for i = 1,20 do
            self:Wait(.5)
            ui_manager.ui_list.tips_gui:TipsMessage('Teleporting ...','success')
        end
    end)
end

--点击领取奖励
function c:ClickDailyFrameClaimBtn()
    if not self.data.daily.can_get then
        return
    end
    local r = self:Invoke('GetGuildDailyReward')
    if r then
        ui_manager.ui_list.tips_gui:TipsMessage('Claim success','success')
        self.data.daily.can_get = false
        self.data.daily.get = self.data.daily.get + 1
        self.ui:SetDailyFrameClaimBtnVisible(false)
        self.data.coin = self.data.coin + guildDailyCfg[self.data.daily.get].guildCoin
        local myInfo = self.guildInfo.player_list[self.parent.user_id]
        if myInfo then
            myInfo.contribution = myInfo.contribution + guildDailyCfg[self.data.daily.get].contribute
        end
        local expStr = string.format('%s/%s',self.guildInfo.exp,proCfg.guildLv[self.guildInfo.lv])
        self.ui:SetDailyFrameLeftInfo(
            self.guildInfo.lv,
            expStr,
            myInfo.contribution,
            self.data.coin
        )
        self.ui:SetDailyFrameItemTopVisible(self.data.daily.get,true)
    else
        ui_manager.ui_list.tips_gui:TipsMessage('Claim failed','fail')
    end
end

--点击购买商品
function c:ClickShopFrameItemBtn(id)
    local cfg = guildShopCfg[id]
    local price = cfg.price
    local limit = cfg.limit
    if self.data.coin < price then
        ui_manager.ui_list.tips_gui:TipsMessage('Not enough coins','fail')
        return
    end
    local myLimit = self.data.shop.list[id] or 0
    if myLimit >= limit then
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase limit reached','fail')
        return
    end
    local re = self:Invoke('BuyGuildShopItem',id)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Buy success','success')
        self.data.coin = self.data.coin - price
        self.data.shop.list[id] = myLimit + 1
        self.ui:SetShopFrameItemLimit(id,(myLimit + 1)..'/'..limit)
        self.ui:SetShopFrameCoin(self.data.coin)
    else
        ui_manager.ui_list.tips_gui:TipsMessage('Buy failed','fail')
    end
end

--鼠标进入item
function c:MouseEnterItem(type_,id)
    local cfg
    if type_ == 'shop' then
        cfg = guildShopCfg[id]
    else
        cfg = guildDailyCfg[id]
    end
    local rType = cfg.reward[1]
    if rType == 3 then
        local buffCfg = hotpot.config.boosts[cfg.reward[2]]
        self.ui:SetTipsFrameInfo(buffCfg.name,buffCfg.desc)
        self.ui:SetTipsFrameVisible(true)
    elseif rType == 11 then
        local stoneCfg = hotpot.config.forgeStone[cfg.reward[2]]
        self.ui:SetTipsFrameInfo(stoneCfg.name,stoneCfg.desc)
        self.ui:SetTipsFrameVisible(true)
    end
end
------------------------GuildMainBg_Over

------------------------War
--点击报名公会战
function c:ClickRegisterBtn()
    local info = self.guildInfo
    if not info then
        return false
    end
    local myInfo = self.guildInfo.player_list[self.parent.user_id]
    if not myInfo then
        return
    end
    if myInfo.post < 4 then
        ui_manager.ui_list.tips_gui:TipsMessage('Registration is only available for users with administrator or higher-level positions.','fail')
        return
    end
    local week = hotpot.pro_cfg.GetWeek()
    if myInfo.warInfo and myInfo.warInfo.week == week and myInfo.warInfo.is_join then
        ui_manager.ui_list.tips_gui:TipsMessage('Has already registered.','fail')
        return
    end
    if not hotpot.pro_cfg.IsInGuildJoinTime() then
        ui_manager.ui_list.tips_gui:TipsMessage('Not within the registration period.','fail')
        return
    end

    local re,temp = self:Invoke('clientRegisterGuildWar')
    if re then
        myInfo.warInfo = myInfo.warInfo or {}
        ui_manager.ui_list.tips_gui:TipsMessage('Registration successful!','success')
        myInfo.warInfo.week = week
        myInfo.warInfo.is_join = true
        ui_manager.ui_list.npc_gui:SetWarRegisterBtnState(false)
    else
        if temp == 0 then
            ui_manager.ui_list.tips_gui:TipsMessage('Registration for the guild battle will start next week.','fail')
        elseif temp == 1 then
            ui_manager.ui_list.tips_gui:TipsMessage('Not within the registration period.','fail')
        elseif temp == 2 then
            ui_manager.ui_list.tips_gui:TipsMessage('Registration is only available for users with administrator or higher-level positions.','fail')
        elseif temp == 3 then
            ui_manager.ui_list.tips_gui:TipsMessage('Has already registered.','fail')
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Registration failed. Please try again later.','fail')
        end
    end
end

--点击领取公会战奖励
function c:ClickClaimWarRewardBtn()
    local re,arg = self:Invoke('getguildwarreward')
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Claim success!','success')
    else
        if arg == 1 then
            ui_manager.ui_list.tips_gui:TipsMessage('You have already received it.','fail')
        elseif arg == 2 then
            ui_manager.ui_list.tips_gui:TipsMessage('Your guild did not achieve a top-three ranking last week.','fail')
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Failure. Please try again later.','fail')
        end
    end
end

function c:RefreshRank1()
    local id = self.data.id
    if not id then
        return
    end
    local list = self:Invoke('getMyGuildRankInfo',id)
    if not list then
        return
    end

    ui_manager.ui_list.guild_war_gui:ClearAllRank1Item()

    for k,v in pairs(list)do
        local r,e = pcall(function()
            return Players:GetNameFromUserIdAsync(v.key)
        end)
        if not r then
            e = 'UnkownName'
        end
        ui_manager.ui_list.guild_war_gui:AddItemInRank1(1,e,v.value)
    end
end

function c:RefreshRank2()
    local re = self:Invoke('getwarrank')
    if not re then
        return
    end

    local ui = ui_manager.ui_list.guild_war_gui
    ui:ClearAllRank2Item()

    for k = 1,50 do
        local v = re[k]
        if v then
            ui:AddItemInRank2(
                k,
                k,
                v.lv,
                proCfg.guildFlag[v.flag],
                proCfg.guildIcon[v.icon],
                v.name,
                v.player_count..'/'..v.max_player_count,
                v.kill
            )
        end
    end
end

function c:WorshipResult(re,num)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Success!','success')
    else
        if num == 1 then
            ui_manager.ui_list.tips_gui:TipsMessage('You have already paid your respects today. Please come again tomorrow.','fail')
        elseif num == 0 then
            ui_manager.ui_list.tips_gui:TipsMessage("Can only worship one's own guild leader",'fail')
        end
    end
end
------------------------War

c:RegistEvent('updateGuildID',c.UpdateGuildId)
c:RegistEvent('addGuildCoin',c.AddCoin)
c:RegistEvent('sendWorshipResult',c.WorshipResult)

return c