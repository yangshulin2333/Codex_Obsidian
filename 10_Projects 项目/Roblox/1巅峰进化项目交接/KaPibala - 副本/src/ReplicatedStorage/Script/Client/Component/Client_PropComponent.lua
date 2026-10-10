local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
local Debris = game:GetService("Debris")
---@type TweenService
local tween_service = game:GetService("TweenService")
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()
---@type PlaceManager
local placeManager = hotpot.load.PlaceManager()


local free_gems_cd = hotpot.pro_cfg.free_gems_cd
local player_lv_cfg = hotpot.config.playerLv
local reborn_cfg = hotpot.config.reborn
local cha_cfg = hotpot.config.character
local chaFol = hotpot:GetPath_Loop('character',_G.Resource)
local chaAnimaUi = hotpot:GetPath_Loop('pfb.chaAnimaUi',_G.Resource)

---@class Client_PropComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('prop')

    ui_manager.ui_list.hud_gui:SetGemsNum(self.data.gems)
    ui_manager.ui_list.hud_gui:SetWinsNum(self.data.wins)
    local lv = self:GetLv()
    if cha_cfg[lv + 1] then
        local icon = cha_cfg[lv+1].icon
        ui_manager.ui_list.hud_gui:SetExpModel(icon)
    else
        ui_manager.ui_list.hud_gui:SetExpModel()
    end

    local exp = self.data.exp
    local need = player_lv_cfg[lv].exp
    ui_manager.ui_list.hud_gui:SetExp(exp,need)
    ui_manager.ui_list.hud_gui:SetLv(lv,player_lv_cfg[lv].icon)
    ui_manager.ui_list.reborn_gui:BindRebornBtnClickHandle(self,self.PlayerClickRebornBtn)

    ui_manager.ui_list.hud_gui:SetTaskBtnVisible(self.data.reborn > 0)
    ui_manager.ui_list.hud_gui:SetTeleportBtnVisible(self.data.reborn >= 2)

    ui_manager.ui_list.buy_posion_gui:BindBtnClickHandle(self,self.BuyRandomPotion)
    ui_manager.ui_list.buy_posion_gui:SetLimited(self.data.potion.num)

    self:StartUpdate()
end

function c:GetGems()
    return self.data.gems
end

function c:AddGems(gems)
    self.data.gems = self.data.gems + gems
    ui_manager.ui_list.hud_gui:SetGemsNum(self.data.gems)
    ui_manager.ui_list.hud_gui:PlayGemsAnima(gems)

    audioManager:PlayGloble('gems')
end

function c:CostGems(gems)
    self.data.gems = self.data.gems - gems

    ui_manager.ui_list.hud_gui:SetGemsNum(self.data.gems)
end

function c:GetWins()
    return self.data.wins
end

function c:AddWins(wins)
    self.data.wins = self.data.wins + wins

    ui_manager.ui_list.hud_gui:SetWinsNum(self.data.wins)
    ui_manager.ui_list.hud_gui:PlayWinsAnima(wins)
end

function c:CostWins(wins)
    self.data.wins = self.data.wins - wins

    ui_manager.ui_list.hud_gui:SetWinsNum(self.data.wins)
end

function c:GetPvpCoin()
    return self.data.pvp_coin
end

function c:AddPvpCoin(coin)
    self.data.pvp_coin = self.data.pvp_coin + coin
    if ui_manager.ui_list.pvp_shop_gui then
        ui_manager.ui_list.pvp_shop_gui:SetCoin(self.data.pvp_coin)
    end
end

function c:CostPvpCoin(coin)
    self.data.pvp_coin = self.data.pvp_coin - coin
    if ui_manager.ui_list.pvp_shop_gui then
        ui_manager.ui_list.pvp_shop_gui:SetCoin(self.data.pvp_coin)
    end
end

function c:GetLv()
    local lv = self.data.lv
    return math.min(lv,#player_lv_cfg)

end

function c:AddLv(lv,exp)
    local old_lv = self:GetLv()
    self.data.lv = lv
    self.data.exp = exp

    local lv = self:GetLv()
    local exp = self.data.exp
    local need = player_lv_cfg[lv].exp
    ui_manager.ui_list.hud_gui:SetExp(exp,need)
    ui_manager.ui_list.hud_gui:SetLv(lv,player_lv_cfg[lv].icon)

    if lv > old_lv then
        self:CheckReborn()

        local reward = cha_cfg[lv].reward
        self:PlayUpgrade(lv)
        if cha_cfg[lv + 1] then
            local icon = cha_cfg[lv+1].icon
            ui_manager.ui_list.hud_gui:SetExpModel(icon)

            if not self.parent.character_cmp:IsEquipSecret() then
                self.parent.character_cmp:ClickEquipBest()
            end
        else
            ui_manager.ui_list.hud_gui:SetExpModel()
        end
    end
end

function c:SetExp(exp)
    self.data.exp = exp
    local lv = self:GetLv()
    local exp = self.data.exp
    local need = player_lv_cfg[lv].exp
    ui_manager.ui_list.hud_gui:SetExp(exp,need)
    ui_manager.ui_list.hud_gui:SetLv(lv,player_lv_cfg[lv].icon)
end

function c:GetReborn()
    return self.data.reborn
end

--玩家进入重生
function c:PlayerInReborn(part)
    local num = part:GetAttribute('num')
    if not num then
        return
    end
    local now = self.data.reborn
    if now >= num then
        return
    end
    local cfg = reborn_cfg[num]
    local need = cfg.need_lv
    if need > self:GetLv() then
        ui_manager.ui_list.reborn_gui:SetUnlockFrameVisible(true)
        ui_manager.ui_list.reborn_gui:SetRebornFrameVisible(false)
        ui_manager.ui_list.reborn_gui:SetUnlockFrameLv(need)
    else
        if cfg.unlock then
            ui_manager.ui_list.reborn_gui:SetNewItem(
                true,
                cfg.unlock_icon,
                cfg.unlock_title,
                cfg.unlock_desc
            )
        else
            ui_manager.ui_list.reborn_gui:SetNewItem(false)
        end

        ui_manager.ui_list.reborn_gui:SetSuccessFrameInfo(cfg.name,cfg.mark,num)
        ui_manager.ui_list.reborn_gui:SetRebornValue(cfg.atk,cfg.exp / 100)
        ui_manager.ui_list.reborn_gui:SetUnlockFrameVisible(false)
        ui_manager.ui_list.reborn_gui:SetRebornFrameVisible(true)

    end
    self.__in_reborn = num
    ui_manager.ui_list.reborn_gui:SetFrameVisible(true)
    ui_manager.ui_list.reborn_gui:Show()
end

--玩家退出重生
function c:PlayerOutReborn(part)
    ui_manager.ui_list.reborn_gui:Hide()
    self.__in_reborn = nil
end

--玩家点击重生按钮
function c:PlayerClickRebornBtn()
    if not self.__in_reborn then
        return
    end
    local now = self.data.reborn
    if now >= self.__in_reborn then
        return
    end
    if now + 1 ~= self.__in_reborn then
        ui_manager.ui_list.tips_gui:TipsMessage('Please Reborn '..(now + 1).." first!",'fail')
        return
    end
    local cfg = reborn_cfg[self.__in_reborn]
    local need = cfg.need_lv
    if need > self:GetLv() then
        return
    end
    local re,save_lv = self:Invoke('reborn')
    if re then
        self.parent.guide_cmp:Reborn()
        self.data.lv = save_lv
        self.data.exp = 0
        ui_manager.ui_list.hud_gui:SetPartyBtnVisible(false)
        ui_manager.ui_list.hud_gui:SetExp(0,player_lv_cfg[save_lv].exp)
        ui_manager.ui_list.hud_gui:SetLv(save_lv,player_lv_cfg[save_lv].icon)
        self:AddProcess(function()
            self:Wait(.1)
            self.parent.character_cmp:ClickItem(save_lv)
        end)

        self:AddProcess(function()
            self.parent.stage_cmp:LoadStage(1)
            self.parent.task_cmp:RefreshReward()
            self.parent.shop_cmp:RefreshGold()
        end)

        self.data.reborn = self.data.reborn + 1

        if self.data.reborn == 1 then
            ui_manager.ui_list.hud_gui:SetTaskBtnVisible(true)
        elseif self.data.reborn == 2 then
            ui_manager.ui_list.hud_gui:SetTeleportBtnVisible(true)

            ui_manager.ui_list.hud_gui:SetOpenRedVisible(true)
            ui_manager.ui_list.hud_gui:SetTeleportRedVisible(true)
        end

        self.__in_reborn = nil
        ui_manager.ui_list.reborn_gui:SetFrameVisible(false)
        -- ui_manager.ui_list.reborn_gui:SetSuccessFrameVisible(true)
        ui_manager.ui_list.tips_gui:TipsMessage('Reborn success!','success')
        ui_manager.ui_list.reborn_gui:Hide()
        pcall(function()
            audioManager:PlayGloble('reborn')
        end)

        self.parent.now_stage:SetRebornVisible(self.parent)
    end
end

--玩家进入免费钻石
function c:PlayerInFreeGems()
    local data = self.data.free_gems.mark
    local now = workspace:GetServerTimeNow()
    if now < data + free_gems_cd then
        ui_manager.ui_list.tips_gui:TipsMessage('It can be claimed only after the countdown ends!','fail')
        return
    end
    local re = self:Invoke('get_free_gems')
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Claimed success!','success')
        self.data.free_gems.mark = now
        self:StartUpdate()
        local stage = self.parent.stage_cmp.now_stage
        if stage then
            stage:SetFreeGemsGetVisible(false)
        end
    end
end

--开始倒计时
function c:StartUpdate()
    if placeManager:GetIdByName('partysence') == game.PlaceId then
        return
    end
    if self.__update_co then
        return
    end
    self.__update_co = self:AddUpdate(self.Update,1)
end

--结束倒计时
function c:StopUpdate()
    if self.__update_co then
        self.__update_co:Disconnect()
        self.__update_co = nil
    end
end

--更新倒计时
function c:Update()
    local now = workspace:GetServerTimeNow()
    local next_time = self.data.free_gems.mark + free_gems_cd
    local sub = next_time - now
    local stage = self.parent.stage_cmp.now_stage
    if sub >= 0 then
        if stage then
            stage:SetFreeGemsCD(sub)
            stage:SetFreeGemsGetVisible(false)
        end
    else
        self:StopUpdate()
        if stage then
            stage:SetFreeGemsGetVisible(true)
        end
    end
end

function c:PlayUpgrade(lv,bool)
    ---@type Camera
    local camera = workspace.CurrentCamera
    self:AddRenderProcess('render',function()
        camera.CameraType = 'Scriptable'
        local id
        if bool then
            id = lv
        else
            id = player_lv_cfg[lv].reward
        end
        ---@type Model
        local model = cha_cfg[id].model
        model = chaFol:FindFirstChild(model)
        model = hotpot:CloneInst_Loop(model)

        local ui = hotpot:CloneInst_Loop(chaAnimaUi)
        ui.BillboardGui.name.Text = cha_cfg[lv].name

        ui.Parent = model
        local m_cf = model:GetPivot()
        ui.CFrame = m_cf + m_cf.UpVector * (-8) + m_cf.LookVector * 0.5
    
        local BasePart = 'BasePart'
        local Accessory = 'Accessory'
        local co = self:AddUpdate(function()
            for k,v in ipairs(model:GetDescendants())do
                if v:IsA(BasePart) and v.Parent.ClassName ~= Accessory then
                    v.CanCollide = false
                    v.Anchored = true
                    v.CastShadow = false
                    v.CanTouch = false
                    v.CanQuery = false
                end
            end
        end)
    
        -- model:ScaleTo(0.01)
        model.Parent = workspace
        self:Wait(.5)
    
        local cf = CFrame.new(
            camera.CFrame.Position + camera.CFrame.LookVector * 20 ,
            camera.CFrame.Position + camera.CFrame.LookVector * 41
        )
        model:PivotTo(cf)

        -- local DepthOfField = game:GetService('Lighting').DepthOfField
        -- DepthOfField.Enabled = true

        local interval = 0
        local time_len = 0.5
        local over_cf = CFrame.new(
            camera.CFrame.Position + camera.CFrame.LookVector * 7,
            camera.CFrame.Position
        )
        local val = 0
        while true do
            interval = interval + self:Wait()
            interval = math.min(interval,time_len)
            val = interval / time_len
            model:PivotTo(cf:Lerp(over_cf,val))
            -- model:ScaleTo(math.max(0.01,tween_service:GetValue(val,2,1) * 1.3))
            if interval >= time_len then
                break
            end
        end
        self:Wait(2)
        -- DepthOfField.Enabled = false

        time_len = 0.5
        interval = 0
        cf = over_cf
        over_cf = cf + camera.CFrame.UpVector * -10
        val = 0
        while true do
            interval = interval + self:Wait()
            interval = math.min(interval,time_len)
            val = interval / time_len
            val = tween_service:GetValue(val,2,0)
            model:PivotTo(cf:Lerp(over_cf,val))
            if interval >= time_len then
                break
            end
        end
        if co then
            co:Disconnect()
            co = nil
        end
        model:Destroy()
        camera.CameraType = 'Custom'
    end)

    self:AddProcess(function()
        self:Wait(3.1)
        camera.CameraType = 'Custom'
    end)
end

--点击购买随机药水
function c:BuyRandomPotion()
    local count = 1
    local price = 500000 * count
    if self:GetWins() < price then
        ui_manager.ui_list.tips_gui:TipsMessage('Not enough coins!','fail')
        return
    end

    local num = self.data.potion.num
    if num >= 4 then
        ui_manager.ui_list.tips_gui:TipsMessage('You have bought 4 potions!','fail')
        return
    end

    local re = self:Invoke('BuyRandomPotion',count)
    if re then
        self.data.potion.num = num + 1
        ui_manager.ui_list.buy_posion_gui:SetLimited(self.data.potion.num)
        ui_manager.ui_list.tips_gui:TipsMessage('Success!','success')
    else
        ui_manager.ui_list.tips_gui:TipsMessage('Fail!','fail')
    end
end

--检查重生
function c:CheckReborn()
    local reborn = self.data.reborn
    ---@type Client_StageObj
    local stage = self.parent.stage_cmp.now_stage
    if not stage then
        return
    end
    local rebornPart = stage.rebornPart
    if not rebornPart then
        return
    end
    local att = rebornPart:FindFirstChild('Attachment')
    if not att then
        return
    end
    local num = rebornPart:GetAttribute('num')
    if not num then
        return
    end
    if reborn >= num then
        return
    end
    if reborn + 1 ~= num then
        return
    end
    local needLv = reborn_cfg[num].need_lv
    if self:GetLv() >= needLv then
        self.parent.character:LinkBeam(att)
    end
end

c:RegistEvent('cost_gems',c.CostGems)
c:RegistEvent('add_gems',c.AddGems)
c:RegistEvent('cost_wins',c.CostWins)
c:RegistEvent('add_wins',c.AddWins)
c:RegistEvent('add_lv',c.AddLv)
c:RegistEvent('set_exp',c.SetExp)
c:RegistEvent('add_pvp_coin',c.AddPvpCoin)
c:RegistEvent('cost_pvp_coin',c.CostPvpCoin)

return c