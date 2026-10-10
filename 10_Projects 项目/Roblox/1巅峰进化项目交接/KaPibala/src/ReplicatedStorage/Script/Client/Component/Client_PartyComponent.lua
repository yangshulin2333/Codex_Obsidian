local hotpot = _G.ClientHotpot
---@type UIManager
local uiManager = hotpot.load.UIManager()
---@type Players
local Players = game:GetService('Players')

local chaTipsStr = 'Character will always be %s%% stronger as your best character!'
local partyCfg = hotpot.config.Party
local DIFFICULTY = {'Easy','Normal','Hard',}
local joinRoomTips = {
    "The room doesn't exist.",
    "The room is being teleported",
    "The level is insufficient.",
    "This is a private room",
    "You are already in the room",
    "This room is only open to friends",
    "The room is fully occupied",
}
local PropList = {DMG = true,EXP = true,MaxHp = true,Speed = true}
local showStr = '%s:%s%%'

---@class Client_PartyComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.ui = uiManager.ui_list.party_gui
    self.ui:BindJoinSelectStageBgItemClickHandle(self,self.ClickJoinSelectStageBgItem)
    self.ui:BindCreateSelectStageBgItemClickHandle(self,self.ClickCreateSelectStageBgItem)
    self.ui:BindCreateBgTypeBtnClickHandle(self,self.ClickPartyTypeBtn)
    self.ui:BindCreateBgDifficultyBtnClickHandle(self,self.ClickPartyDifficultyBtn)
    self.ui:BindCreateBgCreateBtnClickHandle(self,self.ClickCreatePartyBtn)
    self.ui:BindJoinSelectRoomBgItemClickHandle(self,self.ClickJoinRoomBtn)
    self.ui:BindLeaveBtnClickHandle(self,self.ClickLeavePartyBtn)
    self.ui:BindDelBtnClickHandle(self,self.ClickDelPartyBtn)
    self.ui:BindStartBtnClickHandle(self,self.ClickStartPartyBtn)
    self.ui:BindMouseInHandle(self,self.MouseEnter)
    self.ui:BindMainBgJoinBtnClickHandle(self,self.ClickJoinRoomBtn1)
    self.ui:BindMainBgCreateBtnClickHandle(self,self.ClickCreateRoomBtn)

    self:InitUi()
end

function c:InitUi()
    for k,v in ipairs(partyCfg)do
        self.ui:AddJoinSelectStageBgItem(
            v.id,
            v.icon,
            v.bossIcon,
            v.name,
            v.lv1
        )
        self.ui:AddCreateSelectStageBgItem(
            v.id,
            v.icon,
            v.bossIcon,
            v.name,
            v.lv1
        )
    end

    local re = self:Invoke('getRoomList')
    if re then
        local len = #re
        self.ui:SetJoinSelectRoomBgTipsVisible(len == 0)

        for k,v in ipairs(re)do
            local cfg = partyCfg[v.cfgid]
            local difficulty = v.difficulty
            local ui = self.ui:AddJoinSelectRoomBgItem(
                v.roomId,
                v.roomName,
                cfg['lv'..difficulty],
                cfg.roomIcon,
                cfg.bossIcon,
                cfg.name,
                DIFFICULTY[difficulty],
                v.player_count
            )

            ui:SetAttribute('cfgid',v.cfgid)
            ui:SetAttribute('difficulty',difficulty)
            ui:SetAttribute('pType',v.pType)
            ui:SetAttribute('uid',v.uid)
        end
    end
end

--添加房间
function c:AddRoom(info)
    local v = info
    if v.uid == self.parent.user_id then
        return
    end
    local cfg = partyCfg[v.cfgid]
    local difficulty = v.difficulty
    local ui = self.ui:AddJoinSelectRoomBgItem(
        v.id,
        v.roomName,
        cfg['lv'..difficulty],
        cfg.roomIcon,
        cfg.bossIcon,
        cfg.name,
        DIFFICULTY[difficulty],
        v.player_count
    )

    if self.nowSelectStageBgId == v.cfgid then
        if info.pType == 1 then
            ui.Visible = true
        elseif info.pType == 2 then
            if self.parent.main_inst:IsFriendsWith(info.uid) then
                ui.Visible = true
            else
                ui.Visible = false
            end
        else
            ui.Visible = false
        end
    else
        ui.Visible = false
    end

    ui:SetAttribute('cfgid',v.cfgid)
    ui:SetAttribute('difficulty',difficulty)
    ui:SetAttribute('pType',v.pType)
    ui:SetAttribute('uid',v.uid)

    self.ui:SetJoinSelectRoomBgTipsVisible(false)
end

--删除房间
function c:RemoveRoom(info)
    self.ui:RemoveJoinSelectRoomBgItem(info.id)

    if self.join_roomId == info.id then--自己在房间中，房主删除了房间
        self.join_roomId = nil
        self.ui:SetRoomBgVisible(false)
        self.ui:SetMainBgVisible(true)
        uiManager.ui_list.tips_gui:TipsMessage('The creator of the room has deleted it!','fail')
    end
end

--加入房间
function c:JoinRoom(info)
    local roomId = info.roomId
    local uid = info.uid
    local player_count = info.player_count

    if self.roomId == roomId then--其他玩家加入自己创建的房间

        local tab = {}
        for k,v in ipairs(info.players)do
            if v.uid == uid then
                tab = v
                break
            end
        end

        self:AddProcess(function()
            local r,e = pcall(function()
                return Players:GetUserThumbnailAsync(uid,'HeadShot','Size100x100')
            end)
            if not r then
                e = ''
            end
            self.ui:AddRoomBgLeftItem(
                uid,
                e,
                tab.lv or 1,
                tab.name or 'UnkownName'
            )
        end)
    end

    self.ui:SetJoinSelectRoomBgItemPlayers(roomId,player_count)
end

--离开房间
function c:LeaveRoom(info)
    local roomId = info.roomId
    local uid = info.uid
    local player_count = info.player_count

    if self.roomId == roomId then--其他玩家离开自己创建的房间
        self.ui:RemoveRoomBgLeftItem(uid)
    end

    self.ui:SetJoinSelectRoomBgItemPlayers(roomId,player_count)
end

--点击加入房间选择关卡的子项
function c:ClickJoinSelectStageBgItem(id)
    local cfg = partyCfg[id]
    if not cfg then
        return
    end

    self.nowSelectStageBgId = id

    local list = self.ui:GetJoinSelectRoomBgAllItem()
    for k,ui in ipairs(list)do
        local cfgid = ui:GetAttribute('cfgid')
        local difficulty = ui:GetAttribute('difficulty')
        local pType = ui:GetAttribute('pType')
        local uid = ui:GetAttribute('uid')

        if cfgid == id then
            if pType == 1 then
                ui.Visible = true
            elseif pType == 2 then
                if self.parent.main_inst:IsFriendsWith(uid) then
                    ui.Visible = true
                else
                    ui.Visible = false
                end
            else
                ui.Visible = false
            end
        else
            ui.Visible = false
        end
    end
    
    self.ui:SetJoinSelectStageBgVisible(false)
    self.ui:SetJoinSelectRoomBgVisible(true)
end

--点击创建房间选择关卡的子项
function c:ClickCreateSelectStageBgItem(id)
    local cfg = partyCfg[id]
    if not cfg then
        return
    end

    self.ui:SetCreateBgRoomName(self.parent:GetDisplayName())
    self.createRoomId = id
    self.pType = 1
    self.difficulty = 1

    self:RefreshCreateRoomRightInfo()

    self.ui:SetCreateSelectStageBgVisible(false)
    self.ui:SetCreateBgVisible(true)
end

--刷新创建房间的右边信息
function c:RefreshCreateRoomRightInfo()
    local id = self.createRoomId
    local cfg = partyCfg[id]
    if not cfg then
        return
    end
    local difficulty = self.difficulty
    local info = {}
    info.cfgid = id
    info.icon = cfg.roomIcon2
    info.bossIcon = cfg.bossIcon
    info.name = cfg.name
    local list = {}
    local reward = cfg['lv'..difficulty..'Reward']
    for k,v in ipairs(reward)do
        local icon = self.parent.reward_cmp:GetIcon(v)
        list[k] = {icon = icon}
    end
    info.list = list

    self.ui:SetCreateBgInfo(info)
    self.ui:SetCreateBgDiffDes('Difficulty:Level '..cfg['lv'..self.difficulty]..'+')

    self.ui:SetRoomBgInfo(info)
end

--点击创建房间的类型按钮
function c:ClickPartyTypeBtn(id)
    self.pType = id
end

--点击创建房间的难度按钮
function c:ClickPartyDifficultyBtn(id)
    self.difficulty = id

    local cfgId = self.createRoomId
    local difficulty = self.difficulty

    local cfg = partyCfg[cfgId]
    if not cfg then
        return
    end
    local need_lv = cfg['lv'..difficulty]
    local now_lv = self.parent.prop_cmp:GetLv()
    if now_lv < need_lv then
        uiManager.ui_list.tips_gui:TipsMessage('You need to be at least level '..need_lv..' to create a room!','fail')
        
    end

    self:RefreshCreateRoomRightInfo()
end

--点击创建房间按钮
function c:ClickCreatePartyBtn()
    local roomName = self.ui:GetCreateBgRoomName()
    local cfgId = self.createRoomId
    local pType = self.pType
    local difficulty = self.difficulty

    local cfg = partyCfg[cfgId]
    if not cfg then
        return
    end
    local need_lv = cfg['lv'..difficulty]
    local now_lv = self.parent.prop_cmp:GetLv()
    if now_lv < need_lv then
        uiManager.ui_list.tips_gui:TipsMessage('You need to be at least level '..need_lv..' to create a room!','fail')
        return
    end

    local re = self:Invoke('clientCreateRoom',roomName,cfgId,pType,difficulty)
    if re then
        self:AddProcess(function()
            local r,e = pcall(function()
                return self.parent:GetTumbnail('HeadShot','Size100x100')
            end)
            if not r then
                e = ''
            end
            self.ui:AddRoomBgLeftItem(
                self.parent.user_id,
                e,
                self.parent.prop_cmp:GetLv(),
                self.parent:GetDisplayName(),
                true
            )
        end)

        self.ui:SetLeavePartyBtnVisible(false)
        self.ui:SetStartPartyBtnVisible(true)
        self.ui:SetDelPartyBtnVisible(true)
        self.ui:SetCreateBgVisible(false)
        self.ui:SetRoomBgVisible(true)

        self.roomId = re.id
    end
end

--点击删除房间按钮
function c:ClickDelPartyBtn()
    local re = self:Invoke('clientDelRoom')
    if re then
        self.roomId = nil
        self.ui:SetRoomBgVisible(false)
        self.ui:SetMainBgVisible(true)
    end
end

--点击开始游戏按钮
function c:ClickStartPartyBtn()
    self:AddProcess(function()
        local count = 10
        while true do
            uiManager.ui_list.tips_gui:TipsMessage('Teleporting....')
            self:Wait(.8)
            count = count - 1
            if count <= 0 then
                break
            end
        end
    end)
    local re = self:Invoke('startPartyGame')
end

--点击离开房间按钮
function c:ClickLeavePartyBtn()
    local re = self:Invoke('clientLeaveRoom')
    if re then
        self.join_roomId = nil
        self.ui:SetRoomBgVisible(false)
        self.ui:SetMainBgVisible(true)
    end
end

--点击加入房间按钮
function c:ClickJoinRoomBtn(roomid)
    local re,info = self:Invoke('clientJoinRoom',roomid)
    if re then
        self.join_roomId = roomid
        --左边
        local id = info.cfgid
        local cfg = partyCfg[id]
        if not cfg then
            return
        end
        local difficulty = info.difficulty
        local info_ = {}
        info_.cfgid = id
        info_.icon = cfg.icon
        info_.bossIcon = cfg.bossIcon
        info_.name = cfg.name
        local list = {}
        local reward = cfg['lv'..difficulty..'Reward']
        for k,v in ipairs(reward)do
            local icon = self.parent.reward_cmp:GetIcon(v)
            list[k] = {icon = icon}
        end
        info_.list = list 
        self.ui:SetRoomBgInfo(info_)

        --右边
        self:AddProcess(function()
            for k,v in ipairs(info.players)do
                local r,e = pcall(function()
                    return Players:GetUserThumbnailAsync(v.uid,'HeadShot','Size100x100')
                end)
                if not r then
                    e = ''
                end
                self.ui:AddRoomBgLeftItem(
                    v.uid,
                    e,
                    v.lv,
                    v.name,
                    k == 1
                )
            end
        end)

        self.ui:SetJoinSelectRoomBgVisible(false)
        self.ui:SetRoomBgVisible(true)
        self.ui:SetLeavePartyBtnVisible(true)
        self.ui:SetStartPartyBtnVisible(false)
        self.ui:SetDelPartyBtnVisible(false)
    else
        local msg = joinRoomTips[info] or 'Join Room Failed!'
        uiManager.ui_list.tips_gui:TipsMessage(msg,'fail')
    end
end

--鼠标进入
function c:MouseEnter(idx,cfgId)
    local difficulty = self.difficulty
    local cfg = partyCfg[cfgId]
    if not cfg then
        return
    end
    local str = 'lv'..difficulty..'Reward'
    local reward = cfg[str]
    reward = reward[idx]
    local r1,r2,r3 = reward[1],reward[2],reward[3]
    local info = {}
    if r1 == 1 then
        self.ui:SetChaTipsFrameVisible(false)
        self.ui:SetRelicstipsFrameVisible(false)
        self.ui:SetBoxtipsFrameVisible(false)
    elseif r1 == 2 then
        self.ui:SetChaTipsFrameVisible(false)
        self.ui:SetRelicstipsFrameVisible(false)
        self.ui:SetBoxtipsFrameVisible(false)
    elseif r1 == 3 then
        self.ui:SetChaTipsFrameVisible(false)
        self.ui:SetRelicstipsFrameVisible(false)
        self.ui:SetBoxtipsFrameVisible(false)
    elseif r1 == 4 then
        local rcfg = hotpot.config.relics[r2]
        local list = {}
        for key,_ in pairs(PropList)do
            if rcfg[key] then
                table.insert(list,string.format(showStr,key,rcfg[key]))
            end
        end
        info.list = list
        info.quality = rcfg.quality
        info.name = rcfg.name

        local suit_id = rcfg.suit
        local suit 
        if suit_id then
            suit = {}
            local sCfg = hotpot.config.suit[suit_id]
            suit.nameList = {}
            for k,rId in ipairs(sCfg.relics_id)do
                local name = hotpot.config.relics[rId].name
                suit.nameList[name] = true
            end
            suit.title = sCfg.name
            suit.suitScroll = {}
            local set2 = sCfg.set2
            if set2 then
                table.insert(suit.suitScroll,{
                    is_title = true,
                    text = '(2) Set',
                })
                table.insert(suit.suitScroll,{
                    text = string.format('%s+%s%%',set2.prop,set2.value),
                })
            end
    
            local set4 = sCfg.set4
            if set4 then
                table.insert(suit.suitScroll,{
                    is_title = true,
                    text = '(4) Set',
                })
                table.insert(suit.suitScroll,{
                    text = string.format('%s+%s%%',set4.prop,set4.value),
                })
            end
    
            local set6 = sCfg.set6
            if set6 then
                table.insert(suit.suitScroll,{
                    is_title = true,
                    text = '(6) Set',
                })
                table.insert(suit.suitScroll,{
                    text = string.format('%s+%s%%',set6.prop,set6.value),
                })
            end
        end

        self.ui:SetRelicstipsFrameInfo(info,suit)
        self.ui:SetChaTipsFrameVisible(false)
        self.ui:SetRelicstipsFrameVisible(true)
        self.ui:SetBoxtipsFrameVisible(false)
    elseif r1 == 6 then
        local cfg = hotpot.config.relics_gacha[r2]
        local total = 0
        info.list = {}
        info.name = cfg.name
        for k,v in ipairs(cfg.weight)do
            total = total + v
        end
        for k,v in ipairs(cfg.relics_id)do
            table.insert(info.list,{
                icon = hotpot.config.relics[v].icon,
                name = hotpot.config.relics[v].name,
                quality = hotpot.config.relics[v].quality,
                per = cfg.weight[k] / total * 100,
            })
        end
        self.ui:SetBoxtipsFrameInfo(info)
        self.ui:SetChaTipsFrameVisible(false)
        self.ui:SetRelicstipsFrameVisible(false)
        self.ui:SetBoxtipsFrameVisible(true)
    elseif r1 == 7 then
        local cfg = hotpot.config.character[r2]
        local per = cfg.per + 1
        local info = {
            name = cfg.name,
            desc = string.format(chaTipsStr,per*100),
        }
        self.ui:SetChaTipsFrameInfo(info)
        self.ui:SetChaTipsFrameVisible(true)
        self.ui:SetRelicstipsFrameVisible(false)
        self.ui:SetBoxtipsFrameVisible(false)
    end
end

function c:ClickCreateRoomBtn()
    self.ui:SetMainBgVisible(false)
    local id = self.parent.in_party_idx
    if not id then
        return
    end
    self:ClickCreateSelectStageBgItem(id)
end

function c:ClickJoinRoomBtn1()
    self.ui:SetMainBgVisible(false)
    local id = self.parent.in_party_idx
    if not id then
        return
    end
    self:ClickJoinSelectStageBgItem(id)
end

c:RegistEvent('CreateRoom',c.AddRoom)
c:RegistEvent('RemoveRoom',c.RemoveRoom)
c:RegistEvent('joinRoom',c.JoinRoom)
c:RegistEvent('leaveRoom',c.LeaveRoom)

return c