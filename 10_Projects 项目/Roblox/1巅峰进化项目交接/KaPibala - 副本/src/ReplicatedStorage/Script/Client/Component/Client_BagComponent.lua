local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()

local box_cfg = hotpot.config.relics_gacha
local buff_cfg = hotpot.config.boosts
local relice_cfg = hotpot.config.relics

---@class Client_BagComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end

function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('bag')
    self.ui = ui_manager.ui_list.bag_gui
    self.ui:BindItemFrameItemMouseEnterHandle(self,self.MouseEnterItem)
    self.ui:BindItemFrameItemClickHandle(self,self.ClickItem)
    ui_manager.ui_list.open_box_gui:BindBtnClickHandle(self,self.ClickOpenBox)
    ui_manager.ui_list.open_box_gui:BindBtnAllClickHandle(self,self.ClickOpenAllBox)

    self:InitUi()
end

function c:InitUi()
    --箱子
    for id,num in pairs(self.data.creates.list)do
        self.ui:AddItemInItemFrame(
            'creates',
            id,
            box_cfg[id].icon,
            box_cfg[id].quality,
            num
        )
    end

    for k,v in pairs(self.data.boosts.list)do
        if v > 0 then
            self.ui:AddItemInItemFrame(
                'boost',
                k,
                buff_cfg[k].icon,
                buff_cfg[k].quality,
                v
            )
        end
    end

    self:CheckRed()
end

function c:AddBox(id,num)
    num = num or 1
    local old = self.data.creates.list[id]
    if old and old > 0 then
        self.data.creates.list[id] = old + num
        self.ui:SetItemFrameItemNum('creates',id,old + num)
    else
        self.data.creates.list[id] = num
        self.ui:AddItemInItemFrame(
            'creates',
            id,
            box_cfg[id].icon,
            box_cfg[id].quality,
            num
        )
    end

    self:CheckRed()
end

function c:AddBuff(id,num)
    num = num or 1
    local old = self.data.boosts.list[id]
    if old and old > 0 then
        self.data.boosts.list[id] = old + num
        self.ui:SetItemFrameItemNum('boost',id,old + num)
    else
        self.data.boosts.list[id] = num
        self.ui:AddItemInItemFrame(
            'boost',
            id,
            buff_cfg[id].icon,
            buff_cfg[id].quality,
            num
        )
    end
end

function c:MouseEnterItem(type_,id)
    if type_ == 'creates' then
        local cfg = box_cfg[id]
        self.ui:SetItemFrameTipsFrameInfo(
            cfg.name,
            'open it can get equipment'
        )
        self.ui:SetItemFrameTipsFrameVisible(true)
    elseif type_ == 'boost' then
        local cfg = buff_cfg[id]
        self.ui:SetItemFrameTipsFrameInfo(
            cfg.name,
            cfg.desc
        )
        self.ui:SetItemFrameTipsFrameVisible(true)
    elseif type_ == 'forgeStone' then
        local cfg = hotpot.config.forgeStone[id]
        self.ui:SetItemFrameTipsFrameInfo(
            cfg.name,
            cfg.desc
        )
        self.ui:SetItemFrameTipsFrameVisible(true)
    elseif type_ == 'luckyStone' then
        local cfg = hotpot.config.luckyStone[id]
        self.ui:SetItemFrameTipsFrameInfo(
            cfg.name,
            cfg.desc
        )
        self.ui:SetItemFrameTipsFrameVisible(true)
    end
end

function c:ClickItem(type_,id)
    if type_ == 'creates' then
        self.__click_id = id
        self.ui:Hide()
        ui_manager.ui_list.hud_gui:Hide()
        local event = game.ReplicatedStorage:FindFirstChild('Event')
        event:Fire('ExitBagView')
        ui_manager.ui_list.open_box_gui:SetSureBgIcon(box_cfg[id].icon)
        ui_manager.ui_list.open_box_gui:Show()
        ui_manager.ui_list.open_box_gui:SetSureBgVisible(true)
        self.ui:SetItemFrameTipsFrameVisible(false)
    elseif type_ == 'boost' then
        local re = self:Invoke('useBuff',id)
        if re then
            pcall(function()
                audioManager:PlayGloble('boosts')
            end)
            self.data.boosts.list[id] = self.data.boosts.list[id] - 1
            if self.data.boosts.list[id] <= 0 then
                self.ui:DelItemFrameItem('boost',id)
                self.ui:SetItemFrameTipsFrameVisible(false)
            else
                self.ui:SetItemFrameItemNum('boost',id,self.data.boosts.list[id])
            end
        end
    end
end

function c:ClickOpenBox()
    local id = self.__click_id
    if not id then
        return 
    end
    local re,relice_id,idx = self:Invoke('openBox',id)
    if re then
        self.data.creates.list[id] = self.data.creates.list[id] - 1
        if self.data.creates.list[id] <= 0 then
            self.ui:DelItemFrameItem('creates',id)
        else
            self.ui:SetItemFrameItemNum('creates',id,self.data.creates.list[id])
        end

        local cfg = box_cfg[id]
        local character = cfg.character
        local ids = cfg.relics_id
        local list = {}
        for i = 1,100 do
            local ran = (i == 3) and (#ids) or math.random(1,#ids)
            local r_id = ids[ran]
            local icon
            if r_id == #ids and character then
                icon = hotpot.config.character[character].icon
            else
                icon = relice_cfg[r_id].icon
            end
            list[i] = {
                icon = icon,
                quality = relice_cfg[r_id].quality,
            }
        end

        local icon,quality
        if idx == #ids and character then
            icon = hotpot.config.character[character].icon
            quality = 5
        else
            icon = relice_cfg[relice_id].icon
        end
        list[98] = {
            icon = icon,
            quality = quality or relice_cfg[relice_id].quality,
        }

        ui_manager.ui_list.open_box_gui:SetRewardList(list)
        ui_manager.ui_list.open_box_gui:SetSureBgVisible(false)
        ui_manager.ui_list.open_box_gui:SetOpenBGVisible(true)
        wait(.5)
        ui_manager.ui_list.open_box_gui:Play(function()
            if idx == #ids and character then
                self.parent.character_cmp:UnlockSecret(character)
            else
                self.parent.reward_cmp:AddReward({{4,relice_id,1}})
            end
        end)
        ui_manager.ui_list.hud_gui:Show()
        self:CheckRed()
    end
end

function c:ClickOpenAllBox()
    local id = self.__click_id
    if not id then
        return 
    end
    local re,relist = self:Invoke('openAllBox',id)
    if re then
        local tab = relist[1]
        self.data.creates.list[id] = 0
        if self.data.creates.list[id] <= 0 then
            self.ui:DelItemFrameItem('creates',id)
        else
            self.ui:SetItemFrameItemNum('creates',id,self.data.creates.list[id])
        end

        local cfg = box_cfg[id]
        local character = cfg.character
        local ids = cfg.relics_id
        local list = {}
        for i = 1,100 do
            local ran = (i == 3) and (#ids) or math.random(1,#ids)
            local r_id = ids[ran]
            local icon
            if r_id == #ids and character then
                icon = hotpot.config.character[character].icon
            else
                icon = relice_cfg[r_id].icon
            end
            list[i] = {
                icon = icon,
                quality = relice_cfg[r_id].quality,
            }
        end
        local icon,quality
        if tab.idx == #ids and character then
            icon = hotpot.config.character[character].icon
            quality = 5
        else
            icon = relice_cfg[tab.relice_id].icon
        end
        list[98] = {
            icon = icon,
            quality = quality or relice_cfg[tab.relice_id].quality,
        }

        ui_manager.ui_list.open_box_gui:SetRewardList(list)
        ui_manager.ui_list.open_box_gui:SetSureBgVisible(false)
        ui_manager.ui_list.open_box_gui:SetOpenBGVisible(true)
        wait(.5)
        ui_manager.ui_list.open_box_gui:Play(function()
            local reward_list = {}
            for k,v in ipairs(relist)do
                if v.idx == #ids and character then
                    self.parent.character_cmp:UnlockSecret(character)
                else
                    table.insert(reward_list,{4,v.relice_id,1})
                end
            end
            self.parent.reward_cmp:AddReward(reward_list)
        end)
        ui_manager.ui_list.hud_gui:Show()
        self:CheckRed()
    end
end

function c:CheckRed()
    local red = false
    for k,num in pairs(self.data.creates.list)do
        if num > 0 then
            red = true
            break
        end
    end

    self.ui:SetItemBtnRedVisible(red)
    ui_manager.ui_list.hud_gui:SetBagRedVisible(red)
end

c:RegistEvent('addBox',c.AddBox)
c:RegistEvent('addBuff',c.AddBuff)

return c