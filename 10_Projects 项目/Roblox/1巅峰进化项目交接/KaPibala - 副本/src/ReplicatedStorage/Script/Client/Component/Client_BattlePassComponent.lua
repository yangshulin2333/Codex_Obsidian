local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()

local BPReward = hotpot.config.BPReward
local BPTask = hotpot.config.BPTask
local OVERTIME = 1778803200  
local PropList = {DMG = true,EXP = true,MaxHp = true,Speed = true}
local showStr = '%s:%s%%'

---@class Client_BattlePassComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('battle_pass')
    self.ui = ui_manager.ui_list.battle_pass_gui
    self.ui:BindBuyPremiumBtnClickHandle(self,self.ClickBuyPrimium)
    self.ui:BindPassFrameItemFreeBtnClickHandle(self,self.ClaimFree)
    self.ui:BindPassFrameItemPrimiumBtnClickHandle(self,self.ClaimPremium)
    self.ui:BindGiftBtnClickHandle(self,self.ClickGiftBtn)
    self.ui:BindSelectPlayerItemClickHandle(self,self.ClickSelectPlayerItem)
    self.ui:BindPlayerCloseBtnClickHandle(self,self.ClickCloseBtn)
    self.ui:BindMouseInPassItemHandle(self,self.MouseInPassItem)

    self:InitUi()
    self:AddUpdate(self.Update,1)
end

function c:InitUi()
    local maxLV = #BPReward
    self.ui:SetPassFramePremiumOwnedVisible(self.data.is_primium)

    for k,v in ipairs(BPReward)do
        self.ui:AddItemInPassFrame(
            v.id,
            self.parent.reward_cmp:GetIcon(v.reward1),
            v.reward1[3],
            self.parent.reward_cmp:GetIcon(v.reward2),
            v.reward2[3],
            k == maxLV
        )

        if self.data.lv >= v.id then--已解锁
            --免费
            if self.data.get.free[v.id] then--已领取
                self.ui:SetPassFrameItemFreeState(v.id,2)
            else
                self.ui:SetPassFrameItemFreeState(v.id,3)
            end

            --付费
            if self.data.get.primium[v.id] then--已领取
                self.ui:SetPassFrameItemPrimiumState(v.id,2)
            else
                self.ui:SetPassFrameItemPrimiumState(v.id,3)
            end

        else--未解锁
            self.ui:SetPassFrameItemFreeState(v.id,1)
            self.ui:SetPassFrameItemPrimiumState(v.id,1)
        end

    end

    self.ui:SetPassFrameItemLv(self.data.lv)

    --任务
    for k,v in ipairs(BPTask)do
        self.ui:AddItemInTaskFrame(
            v.id,
            v.desc,
            v.exp
        )
        if self.data.task[v.id].done then
            self.ui:SetTaskFrameItemComplete(v.id,true)
        else
            self.ui:SetTaskFrameItemComplete(v.id,false)
        end
        self.ui:SetTaskFrameItemPro(
            v.id,
            self.data.task[v.id].num,
            v.num
        )
    end

    self:Refresh()
end

function c:Update()
    local now = workspace:GetServerTimeNow()
    self.ui:SetCD(math.max(0,OVERTIME - now))
end

--设置selectPlayerBgVisible
function c:SetSelectPlayerBgVisible(visible)
    self.insts.selectPlayerBg.Visible = visible
end

--向player添加item
---@param player Player
function c:AddItemInPlayerBg(player)
    self:AddProcess(function()
        local ui  = hotpot:CloneInst_Loop(self.insts.selectPlayerBg_item)
        ui.Visible = true
        ui.Name = player.UserId
        ui.Parent = self.insts.selectPlayerBg_ScrollingFrame
        local r,e = pcall(function()
            return players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size80x80)
        end)
        if not r then
            e = ''
        end
        ui.bg.icon.Image = e
        ui.bg.name1.Text = player.DisplayName
        ui.bg.name2.Text = player.Name
        self.selectPlayerList[player] = ui

        ui.bg.btn.MouseButton1Click:Connect(function()
            if self.__selectPlayerItemClickHandle and self.__selectPlayerItemClickObj then
                self.__selectPlayerItemClickHandle(self.__selectPlayerItemClickObj,player)
            end 
        end)
    end)
end

--移除玩家item
function c:RemoveItemInPlayerBg(player)
    if self.selectPlayerList[player] then
        self.selectPlayerList[player]:Destroy()
        self.selectPlayerList[player] = nil
    end
end

function c:Refresh()
    local maxLV = #BPReward
    --左边
    if self.data.lv == maxLV then
        local val = BPReward[maxLV-1].exp
        self.ui:SetPassFrameLeftExp(maxLV,val,val)
    else
        local val = BPReward[self.data.lv + 1].exp or 10000
        self.ui:SetPassFrameLeftExp(self.data.lv,self.data.exp,val)
    end

    for k,v in ipairs(BPReward)do
        if self.data.lv >= v.id then--已解锁
            --免费
            if self.data.get.free[v.id] then--已领取
                self.ui:SetPassFrameItemFreeState(v.id,2)
            else
                self.ui:SetPassFrameItemFreeState(v.id,3)
            end

            --付费
            if self.data.get.primium[v.id] then--已领取
                self.ui:SetPassFrameItemPrimiumState(v.id,2)
            else
                self.ui:SetPassFrameItemPrimiumState(v.id,3)
            end
        else--未解锁
            self.ui:SetPassFrameItemFreeState(v.id,1)
            self.ui:SetPassFrameItemPrimiumState(v.id,1)
        end
    end

    self.ui:SetPassFrameItemLv(self.data.lv)
end

function c:AddPoint(id,num)
    self.data.task[id].num = math.min(BPTask[id].num,self.data.task[id].num + num)
    self.ui:SetTaskFrameItemPro(id,self.data.task[id].num,BPTask[id].num)
    if self.data.task[id].num >= BPTask[id].num then
		self.ui:SetTaskFrameItemComplete(id,true)
	end
end

function c:AddExp(exp,lv)
    self.data.exp = exp
    self.data.lv = lv

    self:Refresh()

    ui_manager.ui_list.tips_gui:TipsMessage('Get Battlepass Exp:'..exp,'success')
end

function c:ClaimFree(lv)
    if lv > self.data.lv then
        return
    end
    if self.data.get.free[lv] then
        return
    end
    local re = self:Invoke('getFreeBP',lv)
    if re then
        self.data.get.free[lv] = true
        ui_manager.ui_list.tips_gui:TipsMessage('Claimed Successful!','success')
        self:Refresh()
    end
end

function c:ClaimPremium(lv)
    if not self.data.is_primium then
        self:ClickBuyPrimium()
        return
    end

    if lv > self.data.lv then
        return
    end
    if self.data.get.primium[lv] then
        return
    end
    local re = self:Invoke('getPrimiumBP',lv)
    if re then
        self.data.get.primium[lv] = true
        ui_manager.ui_list.tips_gui:TipsMessage('Claimed Successful!','success')
        self:Refresh()
    end
end

function c:ClickBuyPrimium()
    local data = self.parent.save_data:GetData('pay')
    if data.pay_list[132] then
        return
    end
    local re = self:Invoke('buy_goods',132)
    if re then
        spawn(function()
            pcall(function()
                audioManager:PlayGloble('purchase1')
                audioManager:PlayGloble('purchase2')
                wait(0.6)
                audioManager:PlayGloble('purchase3')
            end)
        end)
        self.data.is_primium = true
        data.pay_list[132] = true
        self.ui:SetPassFramePremiumOwnedVisible(true)
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

function c:ClickGiftBtn()
    self.ui:SetSelectPlayerBgVisible(true)
end

function c:ClickSelectPlayerItem(player)
    self.gift_player = player
    self:Fire('battlepassGiftPlayer',player)
    local re = self:Invoke('buy_goods',132)
    if re then
        spawn(function()
            pcall(function()
                audioManager:PlayGloble('purchase1')
                audioManager:PlayGloble('purchase2')
                wait(0.6)
                audioManager:PlayGloble('purchase3')
            end)
        end)
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

function c:ClickCloseBtn()
    self.ui:SetSelectPlayerBgVisible(false)
    self:Fire('battlepassGiftPlayer',nil)
end

function c:OtherSendPrimium(name)
    ui_manager.ui_list.tips_gui:TipsMessage(name..' tom has given you BattlePass Premium!','success')
    local data = self.parent.save_data:GetData('pay')
    self.data.is_primium = true
    data.pay_list[132] = true
    self.ui:SetPassFramePremiumOwnedVisible(true)
end

function c:MouseInPassItem(lv,isfree)
    local cfg = BPReward[lv]
    local reward = cfg.reward2
    if isfree then
        reward = cfg.reward1
    end
    local r1 = reward[1]
    local r2 = reward[2]
    local info = {}

    if r1 == 1 then
    elseif r1 == 2 then
        info.name = hotpot.config.pet[r2].name
        info.quality = hotpot.config.pet[r2].quality
        info.atk = hotpot.config.pet[r2].value

        self.ui:SetPetTipsFrameInfo(info)
        self.ui:SetPetTipsFrameVisible(true)
        self.ui:SetRelicstipsFrameVisible(false)
        self.ui:SetBoxtipsFrameVisible(false)
    elseif r1 == 3 then
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

        self.ui:SetRelicstipsFrameInfo(info)
        self.ui:SetPetTipsFrameVisible(false)
        self.ui:SetRelicstipsFrameVisible(true)
        self.ui:SetBoxtipsFrameVisible(false)
    elseif r1 == 6 then
        local cfg = hotpot.config.relics_gacha[r2]
        local total = 0
        for k,v in ipairs(cfg.weight)do
            total = total + v
        end
        for k,v in ipairs(cfg.relics_id)do
            if cfg.character and k == 5 then
				local cCfg = hotpot.config.character[cfg.character]
				table.insert(info,{
					icon = cCfg.icon,
					name = cCfg.name,
					quality = cCfg.quality,
					per = cfg.weight[k] / total * 100,
				})
			else
	            table.insert(info,{
	                icon = hotpot.config.relics[v].icon,
	                name = hotpot.config.relics[v].name,
	                quality = hotpot.config.relics[v].quality,
	                per = cfg.weight[k] / total * 100,
	            })
			end
        end

        info.name = cfg.name

        self.ui:SetBoxtipsFrameInfo(info)
        self.ui:SetPetTipsFrameVisible(false)
        self.ui:SetRelicstipsFrameVisible(false)
        self.ui:SetBoxtipsFrameVisible(true)
    end
end

c:RegistEvent('bpAddPoint',c.AddPoint)
c:RegistEvent('bpAddExp',c.AddExp)
c:RegistEvent('sendBattlePassPrimium',c.OtherSendPrimium)

return c