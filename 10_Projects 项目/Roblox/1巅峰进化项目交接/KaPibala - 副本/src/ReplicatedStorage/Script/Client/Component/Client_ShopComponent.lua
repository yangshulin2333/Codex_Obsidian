local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()

local goods_cfg = hotpot.config.goods
local shop_gift_cfg = hotpot.config.shop_gift
local relice_cfg = hotpot.config.relics
local relice_gacha_cfg = hotpot.config.relics_gacha
local pet_cfg = hotpot.config.pet
local buff_cfg = hotpot.config.boosts
local PropList = {DMG = true,EXP = true,MaxHp = true,Speed = true}
local showStr = '%s:%s%%'
local characterCfg = hotpot.config.character

---@class Client_ShopComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('shop')
    self.pay_data = self.parent.save_data:GetData('pay')
    self.ui = ui_manager.ui_list.shop_gui
    self.ui:BindGiftFrameItemClickHandle(self,self.ClickGiftFrameItem)
    self.ui:BindBuyStartPackHandle(self,self.ClickStarterPack)
    self.ui:BindBuyEggHandle(self,self.ClickShopBox)
    self.ui:BindBuySuitHandle(self,self.ClickSuitBox)
    self.ui:BindGamepassItemClickHandle(self,self.ClickGamepass)
    self.ui:BindLimitPetItemClickHandle(self,self.ClickLimitPet)
    self.ui:BindBoostFrameItemClickHandle(self,self.ClickBoosts)
    self.ui:BindWinsFrameItemClickHandle(self,self.ClickWins)
    self.ui:BindGiftFrameItemMouseEnterHandle(self,self.MouseEnterGiftFrameItem)
    self.ui:BindGiftFrameItemMouseLeaveHandle(self,self.MouseLeaveGiftFrameItem)
    self.ui:BindLuckyFrameBtnClickHandle(self,self.ClickBuyLucky)
    self.ui:BindSelectPlayerItemBtnClickHandle(self,self.ClickGiftPlayerBtn)
    self.ui:BindCancelBtnClickHandle(self,self.ClickCancelBtn)
    self.ui:BindRelicsItemMouseEnterHandle(self,self.MouseEnterRelicsItem)
    ui_manager.ui_list.hud_gui:BindStarterpackClickHandle(self,self.ClickStarterPack)
    ui_manager.ui_list.hud_gui:BindLimitpetClickHandle(self,self.ClickBuyMount)
    ui_manager.ui_list.hud_gui:BindVipFrameBtnClickHandle(self,self.ClickGamepass)
    ui_manager.ui_list.hud_gui:BindDoubleAtkBtnClickHandle(self,self.ClickGamepass)


    self:LoadShopGift()
    self:LoadStarterpack()
    self:LoadEgg()
    self:LoadNewSuit()
    self:LoadGamepass()
    self:LoadLimitPet()
    self:LoadBoosts()
    self:LoadWins()
    self:LoadLucky()
    self:CheckRed()

    self.ui:SetGiftFrameDoneVisible(self.data.gift_list.get == #shop_gift_cfg)
    ui_manager.ui_list.hud_gui:SetLimitpetVisible(not self.pay_data.pay_list[92])

    ui_manager.ui_list.hud_gui:SetVipBtnVisible(not self.pay_data.pay_list[28])
end

function c:RefreshShopGift()
    local list = {}
    local get = self.data.gift_list.get
    for k,v in ipairs(shop_gift_cfg)do
        local state 
        if get >= v.id then--已领取
            state = 0
        else
            if v.id == get + 1 then--可领取
                if v.price == 0 then
                    state = 1
                else
                    state = 2
                end
            else
                if v.price == 0 then
                    state = 3
                else
                    state = 4
                end
            end
        end
        list[k] = {
            icon = self.parent.reward_cmp:GetIcon(v.reward[1]),
            num = v.reward[1][3],
            id = v.goods_id,
            state = state,
            price = v.price,
            quality = self.parent.reward_cmp:GetQulity(v.reward[1]),
            type_ = v.reward[1][1] == 2
        }
    end
    return list
end

--加载shopGift
function c:LoadShopGift()
    local list = self:RefreshShopGift()

    self.ui:SetGiftFrameInfo(list)
end

--加载Choiceness
function c:LoadStarterpack()
    local starterPack_id = 37
    local starterPack = {}
    local list = {}
    local cfg = goods_cfg[starterPack_id]
    for k,v in ipairs(cfg.reward)do
        list[k] = {
            icon = self.parent.reward_cmp:GetIcon(v),
            num = v[3],
            quality = self.parent.reward_cmp:GetQulity(v),
            type_ = v[1] == 2
        }
    end
    starterPack.list = list
    starterPack.price = cfg.price
    starterPack.old_price = cfg.args[1]

    self.ui:SetStarterPackInfo(starterPack)
    self.ui:SetStartPackOwned(self.pay_data.pay_list[starterPack_id])
    ui_manager.ui_list.hud_gui:SetStarterpackVisible(not self.pay_data.pay_list[starterPack_id])

    self.ui:SetHalloweenPackOwned(self.pay_data.pay_list[136])
end

--加载egg
function c:LoadEgg()
    local id1,id3,id10 = 38,39,40
    local gacha_id = 29
    local egg = {}
    local list = {}
    local total = 0
    local cfg = relice_gacha_cfg[gacha_id]
    for k,v in ipairs(cfg.weight)do
        total = total + v
    end
    for k,v in ipairs(cfg.weight)do
        if cfg.character and k == 5 then
            list[k] = {
                icon = characterCfg[cfg.character].icon,
                per = string.format("%.2f",v / total * 100),
                order = k,
                quality = characterCfg[cfg.character].quality,
            }
        else
            local relics_id = cfg.relics_id[k]
            list[k] = {
                icon = relice_cfg[relics_id].icon,
                per = string.format("%.2f",v / total * 100),
                order = k,
                quality = relice_cfg[relics_id].quality,
            }
        end
    end
    egg.list = list
    egg.price1 = goods_cfg[id1].price
    egg.price3 = goods_cfg[id3].price
    egg.price10 = goods_cfg[id10].price

    self.ui:SetEggInfo(egg)
end

--加载套装
function c:LoadSuit()
    local id1,id3,id10 = 123,124,125
    local gacha_id = 25
    local egg = {}
    local list = {}
    local total = 0
    local cfg = relice_gacha_cfg[gacha_id]
    for k,v in ipairs(cfg.weight)do
        total = total + v
    end
    for k,v in ipairs(cfg.weight)do
        if cfg.character and k == 5 then
            list[k] = {
                icon = characterCfg[cfg.character].icon,
                per = string.format("%.2f",v / total * 100),
                order = k,
                quality = characterCfg[cfg.character].quality,
            }
        else
            local relics_id = cfg.relics_id[k]
            list[k] = {
                icon = relice_cfg[relics_id].icon,
                per = string.format("%.2f",v / total * 100),
                order = k,
                quality = relice_cfg[relics_id].quality,
            }
        end
    end
    egg.list = list
    egg.price1 = goods_cfg[id1].price
    egg.price3 = goods_cfg[id3].price
    egg.price10 = goods_cfg[id10].price

    self.ui:SetSuitInfo(egg)
end

--加载新套装
function c:LoadNewSuit()
    local suit = {}
    local relics = 'relics'
    for k,v in ipairs(goods_cfg)do
        if v.g_type == relics then
            table.insert(suit,{
                name = v.name,
                icon = self.parent.reward_cmp:GetIcon(v.reward[1]),
                quality = self.parent.reward_cmp:GetQulity(v.reward[1]),
                price = v.price,
                goods_id = v.id,
            })
        end
    end

    self.ui:SetNewSuitInfo(suit)
end

--加载gamepass
function c:LoadGamepass()
    local gamepass = {}
    local vip = {}
    for k,v in pairs(goods_cfg)do
        if v.g_type == 'gamepass' then
            if v.name == 'VIP' then
                vip.id = v.id
                vip.desc = v.desc
                vip.price = v.price
            else
                table.insert(gamepass,{
                    price = v.price,
                    id = v.id,
                    name = v.name,
                    desc = v.desc,
                    icon = v.icon
                })
            end
        end
    end

    self.ui:SetGamepassFrameInfo({list = gamepass,vip = vip})

    for k,v in pairs(goods_cfg)do
        if v.g_type == 'gamepass' then
            self.ui:SetGamepassItemOwned(v.id,self.pay_data.pay_list[v.id])
        end
    end
    self:SetDoubleVisible()
end

function c:SetDoubleVisible()
    -- ui_manager.ui_list.hud_gui:SetDamagex2BtnVisible(not self.pay_data.pay_list[64])
    if self.pay_data.pay_list[64] then
        ui_manager.ui_list.hud_gui:SetDamagex2BtnVisible(false)
        if self.pay_data.pay_list[68] then
            ui_manager.ui_list.hud_gui:SetSpeedx2BtnVisible(false)
        else
            ui_manager.ui_list.hud_gui:SetSpeedx2BtnVisible(true)
        end
    else
        ui_manager.ui_list.hud_gui:SetDamagex2BtnVisible(not self.pay_data.pay_list[64])
        ui_manager.ui_list.hud_gui:SetSpeedx2BtnVisible(false)
    end
end

function c:GetDoubleSpeed()
    return self.pay_data.pay_list[68]
end

--加载限时宠物
function c:LoadLimitPet()
    local info = {}
    for k,v in pairs(goods_cfg)do
        if v.g_type == 'limit_pet' then
            table.insert(info,{
                id = v.id,
                price = v.price,
                icon = v.icon,
                icon2 = v.args[2],
                name = pet_cfg[v.args[1]].name,
                atk = pet_cfg[v.args[1]].value,
                quality = pet_cfg[v.args[1]].quality,
            })
        end
    end 
    self.ui:SetLimitPetFrameInfo(info)
end

--加载药水
function c:LoadBoosts()
    local boosts = {}
    for k,v in pairs(goods_cfg)do
        if v.g_type == 'boosts' then
            local buff_id = v.args[1]
            boosts[buff_id] = {
                id = v.id,
                icon = buff_cfg[buff_id].icon,
                desc = buff_cfg[buff_id].desc,
                name = buff_cfg[buff_id].name,
                price = v.price,
                num = 0
            }
        end
    end
    self.ui:SetBoostsFrameInfo(boosts)
end

--加载奖杯
function c:LoadWins()
    local wins = {}
    for k,v in ipairs(goods_cfg)do
        if v.g_type == 'wins' then
            table.insert(wins,{
                name = v.name,
                price = v.price,
                num = self.parent.reward_cmp:GetNum(v.reward[1]),
                id = v.id,
                icon = v.icon,
            })
        end

        if v.g_type == 'luckyStone' then
            table.insert(wins,{
                name = v.name,
                price = v.price,
                num = self.parent.reward_cmp:GetNum(v.reward[1]),
                id = v.id,
                icon = self.parent.reward_cmp:GetIcon(v.reward[1]),
                isLuckyStone = true,
                per = hotpot.config.luckyStone[v.reward[1][2]].per,
            })
        end

        if v.g_type == 'gems' then
            table.insert(wins,{
                name = v.name,
                price = v.price,
                num = big_number:ToString(v.args[1]),
                id = v.id,
                icon = v.icon,
                isGems = true,
            })
        end

        if v.g_type == 'forgeStone' then
            table.insert(wins,{
                name = v.name,
                price = v.price,
                num = self.parent.reward_cmp:GetNum(v.reward[1]),
                id = v.id,
                icon = self.parent.reward_cmp:GetIcon(v.reward[1]),
                isForgeStone = true,
            })
        end
    end
    self.ui:SetWinsFrameInfo(wins)
end

--加载幸运
function c:LoadLucky()
    self.luckyList = {}
    for k,v in pairs(goods_cfg)do
        if v.g_type == 'shop_lucky' then
            table.insert(self.luckyList,{
                id = v.id,
                price = v.price,
                num = v.args[1],
            })
        end
    end
    self:RefreshLucky()
end

--刷新金币
function c:RefreshGold()
    local wins = {}
    for k,v in pairs(goods_cfg)do
        if v.g_type == 'wins' then
            table.insert(wins,{
                name = v.name,
                price = v.price,
                num = self.parent.reward_cmp:GetNum(v.reward[1]),
                id = v.id,
                icon = v.icon,
            })
        end
    end
    self.ui:RefreshGold(wins)
end

--刷新幸运
function c:RefreshLucky()
    local data = self.data.lucky
    local max = #self.luckyList
    if data.num == 0 then
        self.ui:SetLuckFrameLucky(1,self.luckyList[1].num)
        self.ui:SetLuckyFrameBtnVis(true)
        self.ui:SetLuckFramePrice(self.luckyList[1].price)
        self.ui:SetLuckFrameLuckyCD()
    elseif data.num == max then
        self.ui:SetLuckFrameLucky(self.luckyList[max].num,'MAX')
        self.ui:SetLuckyFrameBtnVis(false)
        self:StartLuckyCD()
    else
        self.ui:SetLuckFrameLucky(self.luckyList[data.num].num,self.luckyList[data.num+1].num)
        self.ui:SetLuckFramePrice(self.luckyList[data.num+1].price)
        self:StartLuckyCD()
    end
end

--开始更新幸运
function c:StartLuckyCD()
    if self.__lucky_co then
        return
    end
    self.__lucky_co = self:AddUpdate(self.LuckyCD,1)
end

--停止更新幸运
function c:StopLuckyCD()
    if self.__lucky_co then
        self.__lucky_co:Disconnect()
        self.__lucky_co = nil
        self.ui:SetLuckFrameLuckyCD()
    end
end

--幸运cd
function c:LuckyCD()
    local value = self.data.lucky.time_ + 43200
    local now = workspace:GetServerTimeNow()
    if now > value then
        self.ui:SetLuckFrameLuckyCD(0)
        self:StopLuckyCD()
        self.data.lucky.num = 0
        self:RefreshLucky()
    else
        self.ui:SetLuckFrameLuckyCD(value - now)
    end
end

--点击购买luck
function c:ClickBuyLucky()
    local num = self.data.lucky.num
    if num == #self.luckyList then
        return
    end
    local re = self:Invoke('buy_goods',self.luckyList[num+1].id)
    if re then
        self:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
        wait(.1)
        self:StartLuckyCD()
    end
end

--giftFrame点击
function c:ClickGiftFrameItem(id)
    local cfg = shop_gift_cfg[id]
    if not cfg then
        return false
    end
    local data = self.data.gift_list.get
    if id ~= data + 1 then
        return false
    end

    local is_free = cfg.price == 0
    if is_free then
        local re = self:Invoke('get_gift_reward',id)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage('Claimed successfully','success')
            self.data.gift_list.get = id
            local list = self:RefreshShopGift()
            self.ui:RefreshGiftFrameState(list)
        end
    else
        local pay_id = cfg.goods_id
        local re = self:Invoke('buy_goods',pay_id)
        if re then
            self:PlayPurchaseSound()
            ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
            self.data.gift_list.get = id
            local list = self:RefreshShopGift()
            self.ui:RefreshGiftFrameState(list)
        end
    end
    self:CheckRed()
    self.ui:SetGiftFrameDoneVisible(id == #shop_gift_cfg)
end

--点击starterPack
function c:ClickStarterPack()
    local id = 37

    if self.pay_data.pay_list[id] then
        ui_manager.ui_list.tips_gui:TipsMessage('You have purchased','fail')
        return false
    end

    local re = self:Invoke('buy_goods',id)
    if re then
        self:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
        self.ui:SetStartPackOwned(true)
        ui_manager.ui_list.hud_gui:SetStarterpackVisible(false)
    end
end

--点击购买box
function c:ClickShopBox(count)
    local goods_id
    if count == 1 then
        goods_id = 38
    elseif count == 3 then
        goods_id = 39
    elseif count == 10 then
        goods_id = 40
    end
    local re = self:Invoke('buy_goods',goods_id)
    if re then
        self:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

--点击购买suit
function c:ClickSuitBox(count)
    local goods_id
    if count == 1 then
        goods_id = 123
    elseif count == 3 then
        goods_id = 124
    elseif count == 10 then
        goods_id = 125
    end
    local re = self:Invoke('buy_goods',goods_id)
    if re then
        self:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

--点击购买gamepass
function c:ClickGamepass(cfg_id)
    if not self.giftPlayer then
        if self.pay_data.pay_list[cfg_id] then
            ui_manager.ui_list.tips_gui:TipsMessage('You have purchased','fail')
            return false
        end
    else
        if cfg_id ~= 64 then
            return false
        end
        local re = self:Invoke('check_goods',cfg_id)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage( self.giftPlayer.Name .. ' has purchased','fail')
            return false
        end
    end
    local re = nil
    if goods_cfg[cfg_id].isGamePass then
        re = self:Invoke('buy_gamepass',cfg_id)
    else
        re = self:Invoke('buy_goods',cfg_id)
    end
    if re then
        self:PlayPurchaseSound()
        if not self.giftPlayer then
            self.pay_data.pay_list[cfg_id] = 1
            self.ui:SetGamepassItemOwned(cfg_id,true)
        end
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')

        if cfg_id == 28 then
            ui_manager.ui_list.hud_gui:SetVipVisible(false)
            ui_manager.ui_list.hud_gui:SetVipBtnVisible(false)
        end

        if cfg_id == 27 and not self.giftPlayer then
            ui_manager.ui_list.bag_gui:SetPetFrameAddEquipBtnVisible(false)
        end

        if cfg_id == 64 and not self.giftPlayer then
            self:SetDoubleVisible()
        end

        if cfg_id == 68 and not self.giftPlayer then
            self:SetDoubleVisible()
        end
    end
end

--点击购买limit_pet
function c:ClickLimitPet(cfg_id)
    local re = self:Invoke('buy_goods',cfg_id)
    if re then
        self:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

--点击购买坐骑
function c:ClickBuyMount()
    local re = self:Invoke('buy_goods',92)
    if re then
        self:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
        ui_manager.ui_list.hud_gui:SetLimitpetVisible(false)
    end
end

--点击购买boosts
function c:ClickBoosts(cfg_id)
    local re = self:Invoke('buy_goods',cfg_id)
    if re then
        self:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

--点击购买wins
function c:ClickWins(cfg_id)
    local re = self:Invoke('buy_goods',cfg_id)
    if re then
        self:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

--鼠标进入GiftFrameItem
function c:MouseEnterGiftFrameItem(id,type_,newId)
    local cfg = nil
    local reward = nil
    if id == nil then
        reward = {type_,newId,1}
    else
        cfg = shop_gift_cfg[id]
        if not cfg then
            return false
        end
        reward = cfg.reward[1]
    end
    local t = reward[1]
    if t == 2 then
        local pet_id = reward[2]
        local p_cfg = pet_cfg[pet_id]
        if p_cfg.value_per then
            self.ui:SetPetTips2Info(
                p_cfg.name,p_cfg.quality,p_cfg.value,p_cfg.value_per
            )
            self.ui:SetPetTips2Visible(true)
        else
            self.ui:SetGiftFrameTipsFrameInfo(
                p_cfg.name,p_cfg.value
            )
            self.ui:SetGiftFrameTipsFrameVisible(true)
        end
    elseif t == 4 then
        local relics_id = reward[2]
        local Rcfg = relice_cfg[relics_id]
        local list = {}
        for key,_ in pairs(PropList)do
            if Rcfg[key] then
                table.insert(list,string.format(showStr,key,Rcfg[key]))
            end
        end
        self.ui:SetRelicsTipsFrameVisible(true)
        self.ui:SetRelicsTipsInfo(Rcfg.name,list,Rcfg.quality)
    elseif t == 6 then
        local info = {}
        local cfg = hotpot.config.relics_gacha[reward[2]]
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
        self.ui:SetBoxTipsVisible(true)
    elseif t == 7 then
        local chaCfg = hotpot.config.character[reward[2]]
        self.ui:SetChaTipsInfo(chaCfg.name,(chaCfg.per + 1)*100)
        self.ui:SetRelicsTipsFrameVisible(false)
        self.ui:SetChaTipsFrameVisible(true)
    end
end

--鼠标离开GiftFrameItem
function c:MouseLeaveGiftFrameItem()
    self.ui:SetGiftFrameTipsFrameVisible(false)
    self.ui:SetChaTipsFrameVisible(false)
    self.ui:SetRelicsTipsFrameVisible(false)
    self.ui:SetBoxTipsVisible(false)
    self.ui:SetPetTips2Visible(false)
end

--鼠标进入relicsItem
function c:MouseEnterRelicsItem(idx,isSuit)
    if isSuit then
        self:MouseEnterSuit(idx)
        return
    end
    local cfg = relice_gacha_cfg[29]
    if not cfg then
        return false
    end
    local relics_id = cfg.relics_id[idx]
    if cfg.character and idx == 5 then
        local chaCfg = hotpot.config.character[cfg.character]
        self.ui:SetChaTipsInfo(chaCfg.name,(chaCfg.per + 1)*100)
        self.ui:SetRelicsTipsFrameVisible(false)
        self.ui:SetChaTipsFrameVisible(true)
    else
        local Rcfg = relice_cfg[relics_id]
        local list = {}
        for key,_ in pairs(PropList)do
            if Rcfg[key] then
                table.insert(list,string.format(showStr,key,Rcfg[key]))
            end
        end
        self.ui:SetRelicsTipsInfo(Rcfg.name,list,Rcfg.quality)
        self.ui:SetRelicsTipsFrameVisible(true)
        self.ui:SetChaTipsFrameVisible(false)
    end
end

--鼠标进入suit
function c:MouseEnterSuit(idx)
    local cfg = relice_gacha_cfg[25]
    local relics_id = cfg.relics_id[idx]
    local Rcfg = relice_cfg[relics_id]
    local list = {}
    for key,_ in pairs(PropList)do
        if Rcfg[key] then
            table.insert(list,string.format(showStr,key,Rcfg[key]))
        end
    end

    local suit_id = relice_cfg[relics_id].suit
    local sCfg = hotpot.config.suit[suit_id]
    local info = {}
    info.nameList = {}
    for k,rId in ipairs(sCfg.relics_id)do
        local name = relice_cfg[rId].name
        info.nameList[name] = true
    end
    info.title = sCfg.name
    info.suitScroll = {}
    local set2 = sCfg.set2
    if set2 then
        table.insert(info.suitScroll,{
            is_title = true,
            text = '(2) Set',
        })
        table.insert(info.suitScroll,{
            text = string.format('%s+%s%%',set2.prop,set2.value),
        })
    end

    local set4 = sCfg.set4
    if set4 then
        table.insert(info.suitScroll,{
            is_title = true,
            text = '(4) Set',
        })
        table.insert(info.suitScroll,{
            text = string.format('%s+%s%%',set4.prop,set4.value),
        })
    end

    local set6 = sCfg.set6
    if set6 then
        table.insert(info.suitScroll,{
            is_title = true,
            text = '(6) Set',
        })
        table.insert(info.suitScroll,{
            text = string.format('%s+%s%%',set6.prop,set6.value),
        })
    end

    self.ui:SetRelicsTipsInfo(Rcfg.name,list,Rcfg.quality,info)
    self.ui:SetRelicsTipsFrameVisible(true)
    self.ui:SetChaTipsFrameVisible(false) 
end

--鼠标离开relicsItem
function c:MouseLeaveRelicsItem()
    self.ui:SetChaTipsFrameVisible(false)
    self.ui:SetRelicsTipsFrameVisible(false)
end

--购买成功lucky
function c:BuyShopLucky(data)
    self.data.lucky = data
    self:RefreshLucky()
end

function c:PlayPurchaseSound()
    spawn(function()
        pcall(function()
            audioManager:PlayGloble('purchase1')
            audioManager:PlayGloble('purchase2')
            wait(0.6)
            audioManager:PlayGloble('purchase3')
        end)
    end)
end

function c:CheckRed()
    local red = false
    local get = self.data.gift_list.get
    local cfg = shop_gift_cfg[get + 1]
    if not cfg then
        ui_manager.ui_list.hud_gui:SetShopRedVisible(false)
        return
    end
    local price = cfg.price
    if price == 0 then
        red = true
    end
    ui_manager.ui_list.hud_gui:SetShopRedVisible(red)
end

function c:SendGift(id)
	self.data.gift_list.get = id
	local list = self:RefreshShopGift()
	self.ui:RefreshGiftFrameState(list)
    self:CheckRed()
end

--点击赠送玩家按钮
---@param player Player
function c:ClickGiftPlayerBtn(player)
    self.ui:SetGiftIconVisible(true)
    self.ui:SetGiftPlayerName(player.Name)
    self.giftPlayer = player
    self:Fire('GiftPlayer',player)

    for k,v in pairs(goods_cfg)do
        if v.g_type == 'gamepass' then
            self.ui:SetGamepassItemOwned(v.id,false)
        end
    end
    self.ui:SetHalloweenPackOwned(false)
end

--点击取消按钮
function c:ClickCancelBtn()
    self.giftPlayer = nil
    self:Fire('GiftPlayer')
    for k,v in pairs(goods_cfg)do
        if v.g_type == 'gamepass' then
            self.ui:SetGamepassItemOwned(v.id,self.pay_data.pay_list[v.id])
        end
    end
    self.ui:SetHalloweenPackOwned(self.pay_data.pay_list[136])
end

--其他玩家赠送礼物
function c:OtherSendGift(name,cfg_id)
    local cfg = goods_cfg[cfg_id]
    ui_manager.ui_list.tips_gui:TipsMessage(name .. ' gave you '..cfg.name,'success')
    if cfg.g_type == 'gamepass' then
        self.pay_data.pay_list[cfg_id] = 1
        self.ui:SetGamepassItemOwned(cfg_id,true)
    end
    if cfg_id == 27 then
        ui_manager.ui_list.bag_gui:SetPetFrameAddEquipBtnVisible(false)
    end
    if cfg_id == 64 then
        self:SetDoubleVisible()
    end
    if cfg_id == 68 then
        self:SetDoubleVisible()
    end
    if cfg_id == 81 then
        self.ui:SetHalloweenPackOwned(true)
        ui_manager.ui_list.hud_gui:SetHalloweenPackVisible(false)
    end
end

--使用code
function c:CodeBuyGoods(cfg_id)
    local cfg = goods_cfg[cfg_id]
    if not cfg then
        return false
    end

    self.pay_data.pay_list[cfg_id] = self.pay_data.pay_list[cfg_id] or 0
    self.pay_data.pay_list[cfg_id] = self.pay_data.pay_list[cfg_id] + 1

    local g_type = cfg.g_type
    if g_type == 'gamepass' then
        self.ui:SetGamepassItemOwned(cfg_id,true)
    end
    if cfg_id == 28 then
        ui_manager.ui_list.hud_gui:SetVipVisible(false)
        ui_manager.ui_list.hud_gui:SetVipBtnVisible(false)
    end

    if cfg_id == 27 then
        ui_manager.ui_list.bag_gui:SetPetFrameAddEquipBtnVisible(false)
    end

    if cfg_id == 64 then
        self:SetDoubleVisible()
    end
    if cfg_id == 68 then
        self:SetDoubleVisible()
    end

    self.parent.gacha_cmp:InitUi()
end

function c:GetAtkSpeed()
    return false
end

c:RegistEvent('buyShopLucky',c.BuyShopLucky)
c:RegistEvent('sendGift',c.SendGift)
c:RegistEvent('OtherSendGift',c.OtherSendGift)

return c