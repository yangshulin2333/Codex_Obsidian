local hotpot = _G.ClientHotpot
---@type Players
local Players = game:GetService('Players')
---@type Player
local Player = Players.LocalPlayer
---@type Mouse
local Mouse = Player:GetMouse()
---@type UIManager
local uimanager = hotpot.load.UIManager()
---@type PlaceManager
local placemanager = hotpot.load.PlaceManager()

local clickMark = 0
local stage_cfg = hotpot.config.stage
local lvCfg = hotpot.config.playerLv

---@class Client_TeamComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.ui = uimanager.ui_list.new_party_gui
    uimanager.ui_list.stats_gui:BindInvitePartyBtnClickHandle(self,self.ClickInviteBtn)
    uimanager.ui_list.stats_gui:BindJoinPartyBtnClickHandle(self,self.ClickJoinBtn)
    self.ui:BindAgreeBtnClickHandle(self,self.ClickAgree)
    self.ui:BindRefuseBtnClickHandle(self,self.ClickRefuse)
    self.ui:BindOutBgClickHandle(self,self.ClickOutBtn)
    self.ui:BindExitBtnClickHandle(self,self.ClickExitTeam)
    self.ui:BindScrollItemClickHandle(self,self.ClickScrollItem)
    self.ui:BindOpenBtnClickHandle(self,self.ClickOpenBtn)
    self.ui:BindCloseBtnClickHandle(self,self.ClickCloseBtn)
    self.ui:BindSetOwnerBtnClickHandle(self,self.ClickSetOwnerBtn)
    self.ui:BindKickBtnClickHandle(self,self.ClickKickBtn)

    if placemanager:GetIdByName('pvpsence') == game.PlaceId then
        self:AddProcess(function()
            repeat self:Wait() until self.parent.main_inst:FindFirstChild('safeValue')
            local safeValue = self.parent.main_inst:WaitForChild('safeValue')
            self.safeValue = safeValue
        end)
        local AttackCheck = workspace:WaitForChild('AttackCheck')
        Mouse.TargetFilter = AttackCheck

        self.pvp_sence = true
    else
        uimanager.ui_list.stats_gui:SetJoinPartyBtnVisible(false)
        uimanager.ui_list.stats_gui:SetInvitePartyBtnVisible(false)
    end
    self:AddUpdate(self.UpdateMouse,0.1)
    self:CheckClickMouse()
end

function c:FindPlayer()
    local target = Mouse.Target
    if not target then
        return
    end
    local model = target:FindFirstAncestorOfClass('Model')
    if not model then
        return
    end
    local player = Players:GetPlayerFromCharacter(model)
    if not player then
        return
    end
    return player
end

function c:UpdateMouse()
    if self.pvp_sence then
        if not (self.safeValue and self.safeValue.Value) then
            return
        end
    end

    if self.parent.prop_cmp:GetLv() < 36 then
        return
    end

    ---@type Player
    self.select_player = self:FindPlayer()
    if self.select_player then
        local x,y = Mouse.X,Mouse.Y
        local view = workspace.CurrentCamera.ViewportSize
        self.ui:SetTipsPos(UDim2.fromScale(x/view.X,y/view.Y))
        self.ui:SetTipsVisible(true)
    else
        self.ui:SetTipsVisible(false)
    end
end

function c:CheckClickMouse()
    Mouse.Button1Down:Connect(function()
        local now = os.clock()
        if now - clickMark < 0.7 then
            if not self.select_player then
                return
            end
            local player = self.select_player
            local re = self:Invoke('viewPlayerInfo',self.select_player)
            if re then
                local ui = uimanager.ui_list.stats_gui
                ui:SetRightHp(re.hp)
                ui:SetRightDmg(re.atk)
                ui:SetRightSpeed(re.speed)
                ui:SetRightPlayTime(re.playTime)
                ui:SetRightMonsterKill(re.kill)
                ui:SetRightTotalDmg(re.tDmg)
                ui:SetRightOpenEgg(re.egg)
                ui:SetLv(re.lv,lvCfg[re.lv].icon)
                ui:SetExp(re.exp,lvCfg[re.lv].exp)
                ui:SetPlayerName(player.DisplayName)
                if self.parent.team_id then
                    if re.team_id then
                        ui:SetInvitePartyBtnVisible(false)
                        ui:SetJoinPartyBtnVisible(false)
                    else
                        ui:SetInvitePartyBtnVisible(true)
                        ui:SetJoinPartyBtnVisible(false)
                    end
                else
                    if re.team_id then
                        ui:SetInvitePartyBtnVisible(false)
                        ui:SetJoinPartyBtnVisible(true)
                    else
                        ui:SetInvitePartyBtnVisible(true)
                        ui:SetJoinPartyBtnVisible(false)
                    end
                end
                ui:Show()
                self.parent.stats_cmp.show_self = false
                self.view_player = player
            end
        end
        clickMark = now
    end)
end

---@param player Player
function c:InviteTips(player)
    self.beInvitePlayer = player
    self.ui:SetInvitePanelInfo(player.DisplayName ..' invited you to the party. Do you agree?')
    self.ui:SetInvitePanelVisible(true)
    self:StartBeInviteUpdate()
end

function c:StartBeInviteUpdate()
    if self.beInvite_co then
        return
    end
    self.beInvite_time = 6
    self.beInvite_co = self:AddUpdate(self.BeInviteUpdate,1)
end

function c:StopBeInviteUpdate()
    if self.beInvite_co then
        self.beInvite_co:Disconnect()
        self.beInvite_co = nil
    end

    self:AddProcess(function()
        self:Wait()
        self.beInvitePlayer = nil
        self.apply_join_player = nil
    end)
end

function c:BeInviteUpdate()
    self.beInvite_time = self.beInvite_time - 1
    if self.beInvite_time <= 0 then
        self:StopBeInviteUpdate()
        self.ui:SetInvitePanelVisible(false)
    end
end

function c:ClickInviteBtn()
    local view_player = self.view_player
    if not view_player then
        uimanager.ui_list.tips_gui:TipsMessage('Player is not found','fail')
        return
    end
    if self.invite_player then
        uimanager.ui_list.tips_gui:TipsMessage('Please do not click too quickly','fail')
        return
    end
    self.invite_player = view_player
    local re = self:Invoke('invitePlayerToTeam',view_player)
    self.invite_player = nil
    if re then
        uimanager.ui_list.tips_gui:TipsMessage('Invite success','success')
        uimanager.ui_list.stats_gui:SetInvitePartyBtnVisible(false)
    else
        uimanager.ui_list.tips_gui:TipsMessage(view_player.DisplayName ..' refuse invite','fail')
    end
end

function c:ClickJoinBtn()
    if self.parent.team_id then
        uimanager.ui_list.tips_gui:TipsMessage('You have already joined a team','fail')
        return
    end
    local re,err = self:Invoke('p_joinTeam',self.view_player)
    if not re then
        if err == 0 or err == 1 then
            uimanager.ui_list.tips_gui:TipsMessage('Team is not found','fail')
        elseif err == 2 then
            uimanager.ui_list.tips_gui:TipsMessage('This team is not open','fail')
        elseif err == 3 then
            uimanager.ui_list.tips_gui:TipsMessage('This team is full','fail')
        end
    else
        uimanager.ui_list.stats_gui:SetJoinPartyBtnVisible(false)
        uimanager.ui_list.tips_gui:TipsMessage('Join success','success')
    end
end

function c:ClickAgree()
    self:StopBeInviteUpdate()
    self.ui:SetInvitePanelVisible(false)
    if self.beInvitePlayer then
        self:Fire('ReplyInvitePlayer',self.beInvitePlayer,true)
        self.beInvitePlayer = nil
    end
    if self.apply_join_player then
        self:Fire('ReplyJoinPlayer',self.apply_join_player,true)
        self.apply_join_player = nil
    end
end

function c:ClickRefuse()
    self:StopBeInviteUpdate()
    self.ui:SetInvitePanelVisible(false)
    if self.beInvitePlayer then
        self:Fire('ReplyInvitePlayer',self.beInvitePlayer,false)
        self.beInvitePlayer = nil
    end
    if self.apply_join_player then
        self:Fire('ReplyJoinPlayer',self.apply_join_player,false)
        self.apply_join_player = nil
    end
end

function c:ClickOpenBtn()
    self.ui:SetOpenBtnVisible(false)
    self.ui:SetCloseBtnVisible(true)
    self:Fire('setTeamCanJoin',true)
end

function c:ClickCloseBtn()
    self.ui:SetOpenBtnVisible(true)
    self.ui:SetCloseBtnVisible(false)
    self:Fire('setTeamCanJoin',false)
end

function c:TeamJoin(data)
    self.team_data = data
    self.parent.team_id = data.team_id

    for uid,v in pairs(data.info)do
        if uid ~= self.parent.user_id then
            local r,e = pcall(function()
                return Players:GetUserThumbnailAsync(uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size60x60)
            end)
            if not r then
                e = ''
            end
            local hp = v.hp
            local max_hp = v.max_hp
            self.ui:AddItemInScroll(
                uid,
                e,
                hp,
                max_hp
            )
            self.ui:AddItemInOut(
                uid,
                e,
                hp,
                max_hp
            )
            self.ui:SetOutBgVisible(true)
        end

        self.ui:SetItemCrownVisible(uid,uid == data.owner.UserId)
        self.ui:SetOutItemCrownVisible(uid,uid == data.owner.UserId)
    end
end

function c:TeamLeave(data)
    if data.leave_player == self.parent.main_inst then
        self.ui:DelAllItemInOut()
        self.ui:DelAllItemInScroll()
        self.ui:SetOutBgVisible(false)
        self.ui:SetBgVisible(false)
        self.parent.team_id = nil
    else
        self.ui:DelItemInOut(data.leave_player.UserId)
        self.ui:DelItemInScroll(data.leave_player.UserId)
    end
end

function c:ClickOutBtn()
    if not self.team_data then
        return
    end
    self.ui:SetOutBgVisible(false)
    self.ui:SetBgVisible(true)
    if self.team_data and self.team_data.owner == self.parent.main_inst then
        self.ui:SetRecivaRequestPanelVisible(true)
    end
end

function c:ClickExitTeam()
    local re = self:Invoke('exitTeam')
end

function c:TeamOwnerChange(player)
    self.team_data.owner = player
    if player ~= self.parent.main_inst then
        self.ui:SetOwnerPanelVisible(false)
        self.ui:SetRecivaRequestPanelVisible(false)
    else
        self.ui:SetRecivaRequestPanelVisible(true)
    end
    uimanager.ui_list.tips_gui:TipsMessage('Team owner change to ' .. player.DisplayName,'success')

    for uid,_ in pairs(self.team_data.info)do
        self.ui:SetItemCrownVisible(uid,uid == player.UserId)
        self.ui:SetOutItemCrownVisible(uid,uid == player.UserId)
    end
end

function c:ClickScrollItem(uid)
    if self.team_data.owner ~= self.parent.main_inst then
        return
    end
    self.click_uid = uid
    self.ui:SetOwnerPanelVisible(true)
end

function c:OtherPlayerApplyJoinTeam(player)
    if self.team_data.owner ~= self.parent.main_inst then
        return
    end
    self.apply_join_player = player
    self.ui:SetInvitePanelInfo(player.DisplayName ..' apply join team. Do you agree?')
    self.ui:SetInvitePanelVisible(true)
    self:StartBeInviteUpdate()
end

function c:ClickSetOwnerBtn()
    if not self.click_uid then
        return
    end
    if self.team_data.owner ~= self.parent.main_inst then
        return
    end
    self:Fire('setTeamOwner',self.click_uid)
end

function c:ClickKickBtn()
    if not self.click_uid then
        return
    end
    if self.team_data.owner ~= self.parent.main_inst then
        return
    end
    local re = self:Invoke('kickTeamPlayer',self.click_uid)
    if re then
        self.ui:SetOwnerPanelVisible(false)
    end
end

function c:KickPlayer(owner)
    uimanager.ui_list.tips_gui:TipsMessage(owner.DisplayName ..' kicked you out team.','success')
end

function c:SyncPlayerData(data)
    if not data then
        return
    end
    self.ui:SetItemPro(data.uid,data.hp,data.max_hp)
    self.ui:SetOutItemPro(data.uid,data.hp,data.max_hp)
end

function c:PlayerChangeStage(info)
    local nowStage = self.parent.now_stage.id
    for uid,stageId in pairs(info)do
        self.ui:SetItemTopVisible(uid,stageId ~= nowStage,stage_cfg[stageId].name)
        self.ui:SetOutItemTopVisible(uid,stageId ~= nowStage,stage_cfg[stageId].name)
    end
end

c:RegistEvent('p_invite_team',c.InviteTips)
c:RegistEvent('TeamJoin',c.TeamJoin)
c:RegistEvent('TeamLeave',c.TeamLeave)
c:RegistEvent('TeamOwnerChange',c.TeamOwnerChange)
c:RegistEvent('p_apply_join_team',c.OtherPlayerApplyJoinTeam)
c:RegistEvent('kickPlayer',c.KickPlayer)
c:RegistEvent('TeamSyncPlayerData',c.SyncPlayerData)
c:RegistEvent('TeamPlayerChangeStage',c.PlayerChangeStage)

return c
