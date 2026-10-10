local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local character_cfg = hotpot.config.character
local cha_fol = hotpot:GetPath_Loop('character',_G.Resource)

---@class Client_CharacterComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('character')
    self.ui = ui_manager.ui_list.bag_gui
    self.ui:BindChaFrameTipsFrameMouseEnter(self,self.ChaFrameItemOnMouseEnter)
    self.ui:BindChaFrameItemClick(self,self.ClickItem)
    self.ui:BindChaFrameEquipBestClickHandle(self,self.ClickEquipBest)

    self:InitUi()
end

function c:InitUi()
    local list = {}
    for k,v in ipairs(character_cfg) do
        list[v.order] = list[v.order] or {}
        table.insert(list[v.order],v)
    end

    local id = 0
    for name,tab in ipairs(list) do
        id = id + 1
        local temp = {}
        for k,v in ipairs(tab) do
            name = v.stage
            local model = v.model
            model = cha_fol:FindFirstChild(model)
            if model then
                model = hotpot:CloneInst_Loop(model)
                table.insert(temp,{
                    icon = v.icon,
                    value = v.value,
                    id = v.id,
                    quality = v.quality,
                })
            end
        end
        self.ui:AddItemInChaFrame(id,name,temp)
    end
    for k,v in pairs(character_cfg)do
        self.ui:SetChaFrameItemLock(v.id,not self.data.list[v.id])
        self.ui:SetChaFrameItemEquipVisible(v.id,self.data.equiped == v.id)
    end

    self:RefreshHudModel()
end

--刷新hudModel
function c:RefreshHudModel()
    local equiped = self.data.equiped
    if not equiped then
        return
    end
    local cfg = character_cfg[equiped]
    if not cfg then
        return
    end
    local model = cfg.model
    model = cha_fol:FindFirstChild(model)
    model = hotpot:CloneInst_Loop(model)
end

--鼠标进入ui
function c:ChaFrameItemOnMouseEnter(id)
    local cfg = character_cfg[id]
    if not cfg then
        return
    end
    if self.data.list[id] then
        if cfg.stage == 'Secret' then
            self.ui:SetChaFrameTipsFrame2Info(cfg.name,(cfg.per + 1) * 100)
            self.ui:SetChaFrameTipsFrameVisible(false)
            self.ui:SetChaFrameTipsFrame2Visible(true)
        else
            self.ui:SetChaFrameTipsFrameInfo(cfg.value,cfg.name,cfg.hp,cfg.lv)
            self.ui:SetChaFrameTipsFrameVisible(true)
            self.ui:SetChaFrameTipsFrame2Visible(false)
        end
    end
end

--点击item
function c:ClickItem(id)
    local cfg = character_cfg[id]
    if not cfg then
        return
    end
    if not self.data.list[id] then
        return
    end
    local re = self:Invoke('equip_character',id)
    if re then
        local old = self.data.equiped
        self.ui:SetChaFrameItemEquipVisible(old,false)
        self.ui:SetChaFrameItemEquipVisible(id,true)
        self.data.equiped = id
        self.parent.character:LoadAnimation()
        self:RefreshHudModel()
    end
end

--解锁character
function c:UnLockCharacter(old,id)
    old = 1
    for i = old,id do
        if character_cfg[i].stage ~= 'Secret' then
            self.data.list[i] = true
            self.ui:SetChaFrameItemLock(i,false)
        end
    end
    -- self:ClickItem(id)
end

function c:UnlockSecret(id)
    self.data.list[id] = true
    self.ui:SetChaFrameItemLock(id,false)
    self.parent.prop_cmp:PlayUpgrade(id,true)
    -- self:ClickItem(id)
    self:ClickEquipBest()
end

--锁定character
function c:LockCharacter(old,id)
    for i = old,id do
        if character_cfg[i].stage ~= 'Secret' then
            self.data.list[i] = nil
            self.ui:SetChaFrameItemLock(i,true)
        end
    end
end

--点击装备最佳
function c:ClickEquipBest()
    local max = 0
    local per = 0
    for k,v in pairs(self.data.list)do
        if character_cfg[k].stage == 'Secret' then
            if character_cfg[k].per > per then
                max = k
                per = character_cfg[k].per
            end
        end
    end

    if max == 0 then
        for k,v in pairs(self.data.list)do
            if k > max then
                max = k
            end
        end
    end


    self:ClickItem(max)
end

function c:IsEquipSecret()
    local now = self.data.equiped

    local cfg = character_cfg[now]
    if cfg then
        if cfg.stage == 'Secret' then
            return true
        end
    end
end

c:RegistEvent('unlock_character',c.UnLockCharacter)
c:RegistEvent('lock_character',c.LockCharacter)
c:RegistEvent('unlock_secretCha',c.UnlockSecret)

return c