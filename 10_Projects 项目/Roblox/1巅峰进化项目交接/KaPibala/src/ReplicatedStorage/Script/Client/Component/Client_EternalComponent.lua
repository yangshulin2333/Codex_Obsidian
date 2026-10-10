local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()
---@type BigNumber
local bigNumber = hotpot.load.BigNumberHelper()

local SEASON = 2
local BASETIME = 1756080000
local OVERTIME = 1778803200 
local H_INTERVAL = 3600
local D_INTERVAL = 86400
local eternalRewardCfg = hotpot.config.EternalReward
local eternalTaskCfg = hotpot.config.EternalTask
local eternalSpinCfg = hotpot.config.EternalSpin
local eternalShopCfg = hotpot.config.EternalShop
local gachaCfg = hotpot.config.gacha
local pet_cfg = hotpot.config.pet
local PropList = {DMG = true,EXP = true,MaxHp = true,Speed = true}
local showStr = '%s:%s%%'

---@class Client_EternalComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('eternal')
    self.ui = ui_manager.ui_list.eternal_gui
    self.ui:BindBuyPremiumBtnClickHandle(self,self.ClickBuyPrimium)
    self.ui:BindPassFrameItemFreeBtnClickHandle(self,self.ClaimFree)
    self.ui:BindPassFrameItemPrimiumBtnClickHandle(self,self.ClaimPremium)
    self.ui:BindBuyDoubleCoinsBtnClickHandle(self,self.ClickBuyDoubleCoins)
    self.ui:BindRefreshTaskBtnClickHandle(self,self.ClickRefreshTask)
    self.ui:BindSpinFrameUse1BtnClickHandle(self,self.ClickSpinUse1Btn)
    self.ui:BindSpinFrameUseAllBtnClickHandle(self,self.ClickSpinUseAllBtn)
    self.ui:BindEggBtnClickHandle(self,self.ClickBuyEgg)
    self.ui:BindShopFrameItemClickHandle(self,self.ClickBuyItem)
    self.ui:BindMouseInPassItemHandle(self,self.MouseInPassItem)
    self.ui:BindMouseInEggItemHandle(self,self.MouseInEggItem)
    self.ui:BindMouseInShopItemHandle(self,self.MouseInShopItem)
    self.ui:BindGiftBtnClickHandle(self,self.ClickGiftBtn)
    self.ui:BindSelectPlayerItemClickHandle(self,self.ClickSelectPlayerItem)
    self.ui:BindPlayerCloseBtnClickHandle(self,self.ClickCloseBtn)
    self.ui:BindCancelBtnClickHandle(self,self.ClickGiftCancelBtn)

    self:InitUi()
    self:RefreshState()
    self:AddUpdate(self.Update,1)
end

function c:InitUi()
    self.ui:SetCoinNum(self.data.coin)
    ui_manager.ui_list.hud_gui:SetEternalNum(self:GetCoins())

    local pay_list = self.parent.save_data:GetData('pay').pay_list
    --Battlepass
    local len = #eternalRewardCfg
    for i = 1,len - 1 do
        local cfg = eternalRewardCfg[i]
        self.ui:AddItemInPassFrame(
            i,
            self.parent.reward_cmp:GetIcon(cfg.reward1),
            cfg.reward1[3],
            self.parent.reward_cmp:GetIcon(cfg.reward2),
            cfg.reward2[3],
            false
        )
    end

    local lastCfg = eternalRewardCfg[len]
    self.ui:SetLastInfoInPassFrame(
        self.parent.reward_cmp:GetIcon(lastCfg.reward1),
        len,
        self.parent.reward_cmp:GetName(lastCfg.reward1)
    )

    if self.data.lv >= len then
        local exp = eternalRewardCfg[len].exp
        self.ui:SetPassFrameLeftExp(len,exp,exp)
    else
        self.ui:SetPassFrameLeftExp(
            self.data.lv,
            self.data.exp,
            eternalRewardCfg[self.data.lv+1].exp
        )
    end

    self.ui:SetPassFrameItemLv(self.data.lv)
    self.ui:SetDoubleCoinsOwnedVisible(pay_list[134])
    self.ui:SetPassFramePremiumOwnedVisible(pay_list[133])

    --task
    for k,v in ipairs(eternalTaskCfg)do
        if v.type_ == 1 then
            self.ui:AddItemInDailyTask(v.id,v.desc,v.exp)
        else
            self.ui:AddItemInHourTask(v.id,v.desc,v.exp)
        end
        self.ui:SetTaskFrameItemComplete(v.id,self.data.task[k].done)
        self.ui:SetTaskFrameItemPro(v.id,self.data.task[v.id].num,v.num)
    end

    --spin
    local list = {}
    local total = 0
    -- for k,v in ipairs(eternalSpinCfg)do
    --     total = total + v.weight
    -- end
    for k,v in ipairs(eternalSpinCfg)do
        table.insert(list,{
            icon = v.icon or self.parent.reward_cmp:GetIcon(v.reward),
            per = v.show,
            rewardType = v.reward[1],
        })
    end
    self.ui:SetSpinReward(list)
    self.ui:SetSpinTicketNum(self.data.ticket)

    --shop
    local cfg = gachaCfg[40]
    local total = 0
    for k,v in ipairs(cfg.weight)do
        total = total + v
    end
    list = {}
    for k,v in ipairs(cfg.pet_id)do
        table.insert(list,{
            icon = pet_cfg[v].icon,
            per = cfg.weight[k] / total * 100,
            quality = pet_cfg[v].quality,
        })
    end
    self.ui:SetShopFrameEggInfo(list,cfg.price)

    list = {}
    for k,v in ipairs(eternalShopCfg)do
        local name = self.parent.reward_cmp:GetName(v.reward)
        if v.goods_id then
            name = bigNumber:ToString(v.reward[3])
        end
        table.insert(list,{
            icon = self.parent.reward_cmp:GetIcon(v.reward),
            name = name,
            price = v.price,
            rewardType = v.reward[1],
            is_robux = v.goods_id,
            order = v.layout,
        })
    end
    self.ui:SetShopFrameItem(list)
    for k,v in ipairs(eternalShopCfg)do
        self.ui:SetShopFrameItemOwnedVisible(k,self.data.shop.list[k])
    end
end

function c:RefreshState()
    local len = #eternalRewardCfg
    for i = 1,len - 1 do
        local f_state = 0
        local p_state = 0
        if self.data.lv >= i then
            if self.data.get.free[i] then
                f_state = 2
            else
                f_state = 3
            end
            if self.data.get.primium[i] then
                p_state = 2
            else
                p_state = 3
            end
        else
            f_state = 1
            p_state = 1
        end
        self.ui:SetPassFrameItemFreeState(i,f_state)
        self.ui:SetPassFrameItemPrimiumState(i,p_state)
    end

    local state = 0
    if self.data.lv >= len then
        if self.data.get.free[len] then
            state = 2
        else
            state = 3
        end
    else
        state = 1
    end
    self.ui:SetLastState(state)
end

function c:Update()
    local now = workspace:GetServerTimeNow()
    local h_mark = self.data.hour_mark
    local d_mark = self.data.daily_mark

    local dcd = (d_mark+1) * D_INTERVAL + BASETIME - now
    local hcd = (h_mark+1) * H_INTERVAL + BASETIME - now

    self.ui:SetCD(math.max(0,OVERTIME - now))

    if dcd <= 0 then
        dcd = 0
        local re,d_num = self:Invoke('refreshEternalDailyTask')
        if re then
            self.data.daily_mark = d_num
            for i = 1,6 do
                self.data.task[i].done = false
                self.data.task[i].num = 0
                self.ui:SetTaskFrameItemComplete(i,self.data.task[i].done)
                self.ui:SetTaskFrameItemPro(i,self.data.task[i].num,eternalTaskCfg[i].num)
            end
        end
    end
    if hcd <= 0 then
        hcd = 0
        local re,h_num = self:Invoke('refreshEternalHourTask')
        if re then
            self.data.hour_mark = h_num
            for i = 7,9 do
                self.data.task[i].done = false
                self.data.task[i].num = 0
                self.ui:SetTaskFrameItemComplete(i,self.data.task[i].done)
                self.ui:SetTaskFrameItemPro(i,self.data.task[i].num,eternalTaskCfg[i].num)
            end
        end
    end

    self.ui:SetDailyTaskCD(dcd)
    self.ui:SetHourTaskCD(hcd)
end

function c:AddPoint(id,num)
    self.data.task[id].num = math.min(eternalTaskCfg[id].num,self.data.task[id].num + num)
    self.ui:SetTaskFrameItemPro(id,self.data.task[id].num,eternalTaskCfg[id].num)
    if self.data.task[id].num >= eternalTaskCfg[id].num then
		self.ui:SetTaskFrameItemComplete(id,true)
	end
end

function c:AddExp(exp,lv,add_exp)
    self.data.exp = exp
    self.data.lv = lv

    self:RefreshState()
    local len = #eternalRewardCfg
    if self.data.lv >= len then
        local exp = eternalRewardCfg[len].exp
        self.ui:SetPassFrameLeftExp(len,exp,exp)
    else
        self.ui:SetPassFrameLeftExp(
            self.data.lv,
            self.data.exp,
            eternalRewardCfg[self.data.lv+1].exp
        )
    end
    self.ui:SetPassFrameItemLv(self.data.lv)

    -- ui_manager.ui_list.tips_gui:TipsMessage('Get Eternal Exp:'..exp,'success')
    self.parent.reward_cmp:AddReward({{1,9,add_exp}})
end

function c:AddTicket(num)
    self.data.ticket = self.data.ticket + num
    self.ui:SetSpinTicketNum(self.data.ticket)
end

function c:AddCoins(num)
    self.data.coin = self.data.coin + num
    self.ui:SetCoinNum(self.data.coin)
    ui_manager.ui_list.hud_gui:PlayEternalNumAddAnim(num)
    ui_manager.ui_list.hud_gui:SetEternalNum(self.data.coin)
end

function c:CostCoins(num)
    self.data.coin = self.data.coin - num
    self.ui:SetCoinNum(self.data.coin)
    ui_manager.ui_list.hud_gui:SetEternalNum(self.data.coin)
end

function c:GetCoins()
    return self.data.coin
end

function c:CodePurchase()
    local data = self.parent.save_data:GetData('pay')
    self.data.is_primium = true
    data.pay_list[133] = true
    self.ui:SetPassFramePremiumOwnedVisible(true)
    self.ui:SetDoubleCoinsOwnedVisible(true)
end

function c:ClaimFree(lv)
    if lv > self.data.lv then
        return
    end
    if self.data.get.free[lv] then
        return
    end
    local re = self:Invoke('getFreeEternal',lv)
    if re then
        self.data.get.free[lv] = true
        ui_manager.ui_list.tips_gui:TipsMessage('Claimed Successful!','success')
        self:RefreshState()
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
    local re = self:Invoke('getPrimiumEternal',lv)
    if re then
        self.data.get.primium[lv] = true
        ui_manager.ui_list.tips_gui:TipsMessage('Claimed Successful!','success')
        self:RefreshState()
    end
end

function c:ClickBuyPrimium()
    if self.gift_player then
        local re = self:Invoke('buy_goods',133)
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
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Purchase failed','error')
        end
        return
    end
    local data = self.parent.save_data:GetData('pay')
    if data.pay_list[133] then
        return
    end
    local re = self:Invoke('buy_goods',133)
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
        data.pay_list[133] = true
        self.ui:SetPassFramePremiumOwnedVisible(true)
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

function c:ClickBuyDoubleCoins()
    if self.gift_player then
        local re = self:Invoke('buy_goods',134)
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
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Purchase failed','fail')
        end
        return
    end
    local re = self:Invoke('buy_goods',134)
    if re then
        local data = self.parent.save_data:GetData('pay')
        data.pay_list[134] = true
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
        spawn(function()
            pcall(function()
                audioManager:PlayGloble('purchase1')
                audioManager:PlayGloble('purchase2')
                wait(0.6)
                audioManager:PlayGloble('purchase3')
            end)
        end)
        self.ui:SetDoubleCoinsOwnedVisible(true)
    end
end

function c:ClickRefreshTask()
    local re = self:Invoke('buy_goods',67)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Refresh Successful!','success')
        spawn(function()
            pcall(function()
                audioManager:PlayGloble('purchase1')
                audioManager:PlayGloble('purchase2')
                wait(0.6)
                audioManager:PlayGloble('purchase3')
            end)
        end)

        for k,v in pairs(self.data.task)do
            v.done = false
            v.num = 0
            self.ui:SetTaskFrameItemComplete(k,v.done)
            self.ui:SetTaskFrameItemPro(k,v.num,eternalTaskCfg[k].num)
        end
    end
end

function c:ClickSpinUse1Btn()
    local ticket = self.data.ticket
    if ticket <= 0 then
        ui_manager.ui_list.tips_gui:TipsMessage('No Ticket','fail')
        return
    end
    local re,id = self:Invoke('useTicket')
    if re then
        self.data.ticket = ticket - 1
        self.ui:SetSpinTicketNum(self.data.ticket)
        self.ui:PlaySpin(id)
        wait(3.15)
        self.parent.reward_cmp:AddReward({eternalSpinCfg[id].reward})
    end
end

function c:ClickSpinUseAllBtn()
    local ticket = self.data.ticket
    if ticket <= 0 then
        return
    end
    local re,list,reList = self:Invoke('useAllTicket')
    if re then
        self.data.ticket = 0
        self.ui:SetSpinTicketNum(self.data.ticket)
        self.ui:PlaySpin(list[1])
        wait(3.15)
        self.parent.reward_cmp:AddReward(reList)
    end
end

function c:ClickBuyEgg(count)
    if self.parent.pet_cmp:GetBagRemain() < count then
            ui_manager.ui_list.tips_gui:TipsMessage('The remaining capacity of the backpack is insufficient','fail')
            return false
        end
    local cfg = gachaCfg[40]
    local price = cfg.price
    local cost = price * count
    if self:GetCoins() < cost then
        ui_manager.ui_list.tips_gui:TipsMessage('No Enough Coins','fail')
        return
    end
    local re,list = self:Invoke('buyEternalEgg',count)
    if re then
        ui_manager.ui_list.gacha_gui:SetStopBtnVisible(false)
        self.ui.insts.Frame.Visible = false
        self.parent.gacha_cmp:QueueOpenEgg(list,count,40,true)
        wait(.5)
        self.ui.insts.Frame.Visible = true
    end
end

function c:ClickBuyItem(id)
    local cfg = eternalShopCfg[id]
    if not cfg then
        return
    end
    
    if cfg.goods_id then
        local goods_id = cfg.goods_id
        local re = self:Invoke('buy_goods',goods_id)
        if re then
            self.parent.shop_cmp:PlayPurchaseSound()
            ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
        end
        return
    end

    if self.data.shop.list[id] then
        return
    end

    local price = cfg.price
    if self:GetCoins() < price then
        ui_manager.ui_list.tips_gui:TipsMessage('No Enough Coins','fail')
        return
    end
    local re = self:Invoke('buyEternalItem',id)
    if re then
        self.data.shop.list[id] = true
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
        self.ui:SetShopFrameItemOwnedVisible(id,true)
    end
end

function c:MouseInPassItem(lv,isfree)
    local cfg = eternalRewardCfg[lv]
    local reward = cfg.reward2
    if isfree then
        reward = cfg.reward1
    end
    local r1 = reward[1]
    local r2 = reward[2]
    local info = {}

    if r1 == 1 then
        info.name = hotpot.config.resource[r2].name
        info.desc = hotpot.config.resource[r2].desc or ''

        self.ui:SetTipsFrame1Info(info)
        self.ui:SetTipsFrame1Visible(true)
        self.ui:SetPetTipsFrameVisible(false)
        self.ui:SetRelicstipsFrameVisible(false)
        self.ui:SetBoxtipsFrameVisible(false)
    elseif r1 == 2 then
        info.name = hotpot.config.pet[r2].name
        info.quality = hotpot.config.pet[r2].quality
        info.atk = hotpot.config.pet[r2].value

        self.ui:SetPetTipsFrameInfo(info)
        self.ui:SetTipsFrame1Visible(false)
        self.ui:SetPetTipsFrameVisible(true,lv == #eternalRewardCfg)
        self.ui:SetRelicstipsFrameVisible(false)
        self.ui:SetBoxtipsFrameVisible(false)
    elseif r1 == 3 then
        info.name = hotpot.config.boosts[r2].name
        info.desc = hotpot.config.boosts[r2].desc or ''

        self.ui:SetTipsFrame1Info(info)
        self.ui:SetTipsFrame1Visible(true)
        self.ui:SetPetTipsFrameVisible(false)
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

        self.ui:SetRelicstipsFrameInfo(info)
        self.ui:SetTipsFrame1Visible(false)
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
        self.ui:SetTipsFrame1Visible(false)
        self.ui:SetPetTipsFrameVisible(false)
        self.ui:SetRelicstipsFrameVisible(false)
        self.ui:SetBoxtipsFrameVisible(true)
    end
end

function c:MouseInEggItem(id)
    local cfg = gachaCfg[40]
    local pet_id = cfg.pet_id[id]
    local info = {
        name = hotpot.config.pet[pet_id].name,
        quality = hotpot.config.pet[pet_id].quality,
        atk = hotpot.config.pet[pet_id].value,
    }
    self.ui:SetPetTipsFrameInfo(info)
    self.ui:SetPetTipsFrameVisible(true)
end

function c:MouseInShopItem(id)
    if id == 0 then
        local cfg = eternalSpinCfg[5]
        local reward = cfg.reward
        local r2 = reward[2]
        local info = {}
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
        self.ui:SetTipsFrame1Visible(false)
        self.ui:SetPetTipsFrameVisible(false)
        self.ui:SetRelicstipsFrameVisible(true)
        self.ui:SetBoxtipsFrameVisible(false)
        return
    end
    local cfg = eternalShopCfg[id]
    local reward = cfg.reward
    local r1 = reward[1]
    local r2 = reward[2]
    local info = {}
    if r1 == 2 then
        info.name = hotpot.config.pet[r2].name
        info.quality = hotpot.config.pet[r2].quality
        info.atk = hotpot.config.pet[r2].value

        self.ui:SetPetTipsFrameInfo(info)
        self.ui:SetTipsFrame1Visible(false)
        self.ui:SetPetTipsFrameVisible(true)
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

        self.ui:SetRelicstipsFrameInfo(info)
        self.ui:SetTipsFrame1Visible(false)
        self.ui:SetPetTipsFrameVisible(false)
        self.ui:SetRelicstipsFrameVisible(true)
        self.ui:SetBoxtipsFrameVisible(false)
    end
end

function c:ClickGiftBtn()
    self.ui:SetSelectPlayerBgVisible(true)
end

function c:ClickSelectPlayerItem(player)
    self.gift_player = player
    self:Fire('eternalGiftPlayer',player)
    self.ui:SetGiftPlayerName(player.Name)
end

function c:ClickGiftCancelBtn()
    local pay_list = self.parent.save_data:GetData('pay').pay_list
    self.ui:SetDoubleCoinsOwnedVisible(pay_list[134])
    self.ui:SetPassFramePremiumOwnedVisible(pay_list[133])
end

function c:ClickCloseBtn()
    self.ui:SetSelectPlayerBgVisible(false)
    self:Fire('eternalGiftPlayer',nil)
end

function c:OtherSendPrimium(name,str)
    if str == 'Primium' then
        ui_manager.ui_list.tips_gui:TipsMessage(name..' tom has given you Christmas Premium!','success')
        local data = self.parent.save_data:GetData('pay')
        self.data.is_primium = true
        data.pay_list[133] = true
        self.ui:SetPassFramePremiumOwnedVisible(true)
    elseif str == 'doubleCoins' then
        ui_manager.ui_list.tips_gui:TipsMessage(name..' tom has given you Double Christmas Coins!','success')
        local data = self.parent.save_data:GetData('pay')
        self.data.is_primium = true
        data.pay_list[134] = true
        self.ui:SetDoubleCoinsOwnedVisible(true)
    elseif str == 'Coins' then
        ui_manager.ui_list.tips_gui:TipsMessage(name..' tom has given you Christmas Coins!','success')
    end
end

c:RegistEvent('eternalAddPoint',c.AddPoint)
c:RegistEvent('eternalAddExp',c.AddExp)
c:RegistEvent('eternalAddTicket',c.AddTicket)
c:RegistEvent('eternalAddCoins',c.AddCoins)
c:RegistEvent('eternalCostCoins',c.CostCoins)
c:RegistEvent('eternalCodePurchase',c.CodePurchase)
c:RegistEvent('sendEternalPrimium',c.OtherSendPrimium)

return c