local hotpot = _G.ServerHotpot
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local charcter_cfg = hotpot.config.character
local charcter_fol = hotpot:GetPath_Loop('character',hotpot.Resource)
local eff_fol = hotpot:GetPath_Loop('eff',hotpot.Resource)
local Secret = 'Secret'

---@class Server_CharacterComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('character')

    local equiped = self.data.__real.equiped
    if equiped and not self.data.__real.list[equiped] then
        self.parent.save_data:Execut(function()
            self.data.equiped = 1
        end)
    end

    -- self:AddProcess(function()
    --     self:Wait(10)
    --     self:UnlockSecret(114)
    -- end)
end

function c:Init()
    local equiped = self.data.__real.equiped
    local name = charcter_cfg[equiped].model
    local model = charcter_fol:FindFirstChild(name)
    self.parent.character:ChangeCharacter(hotpot:CloneInst_Loop(model),equiped)
    self.parent.relics_cmp:ChangeRig(hotpot:CloneInst_Loop(model))
    local mmm = hotpot:CloneInst_Loop(model)
    mmm.Name = charcter_cfg[equiped].name
    spawn(function()
        self.parent.stats_cmp:ChangeCharacter(mmm)
    end)

    self.parent.character_value.Value = name
    self.character_value = name
end

function c:GetEquiped()
    return self.data.__real.equiped
end

--装备Charcter
function c:EquipCharacter(id)
    local equiped = self.data.__real.equiped
    if equiped == id then
        return
    end
    if not self.data.__real.list[id] then
        return
    end

    self.__equipId = id

    local name = charcter_cfg[id].model
    spawn(function()
        local model = charcter_fol:FindFirstChild(name)
        self.parent.character:ChangeCharacter(hotpot:CloneInst_Loop(model),id)
        self.parent.relics_cmp:ChangeRig(hotpot:CloneInst_Loop(model))
        local mmm = hotpot:CloneInst_Loop(model)
        mmm.Name = charcter_cfg[id].name
        self.parent.stats_cmp:ChangeCharacter(mmm)
    end)
    self.parent.save_data:Execut(function()
        self.data.equiped = id
    end)

    local hp = self.parent.prop_cmp:GetHp()
    if not self.parent.character then
        return
    end
    self.parent.character.hp = hp
    self.parent.character.max_hp = hp

    if place_manager:GetIdByName('pvpsence') ~= game.PlaceId then
        self.parent.sync_cmp:Add('sync_hp',{
            hp = hp,
            max_hp = hp,
        })
    end

    self.parent.character_value.Value = name
    self.character_value = name

    self.parent.stats_cmp:SyncAttack()
    self.parent.relics_cmp:RefrehPower()

    return true
end

--解锁character
function c:UnLockCharacter(old,id)
    for i = 1,id do
        self.parent.save_data:Execut(function()
            if charcter_cfg[i].stage ~= 'Secret' then
                self.data.list[i] = true
            end
        end)
    end

    local hp = self.parent.prop_cmp:GetHp()
    if not self.parent.character then
        return
    end
    if self.parent.character then
        self.parent.character.hp = hp
        self.parent.character.max_hp = hp
    end
    self.parent.sync_cmp:Add('sync_hp',{
        hp = hp,
        max_hp = hp,
    })

    self:Fire('unlock_character',1,id)

    return true
end

--锁定character
function c:LockCharacter(old,id)
    -- print('lock',id)

    for i = old,id do
        self.parent.save_data:Execut(function()
            if charcter_cfg[i].stage ~= 'Secret' then
                self.data.list[i] = nil
            end
        end)
    end

    self:Fire('lock_character',old,id)
end

function c:UnlockSecret(id,not_sync)
    self.parent.save_data:Execut(function()
        self.data.list[id] = true
    end)

    if not not_sync then
        self:Fire('unlock_secretCha',id)
    end

    self.parent.title_cmp:SetSecretNum(self:GetSecretNum())

    return true 
end

function c:GetSecretNum()
    local num = 0
    for k,v in pairs(self.data.__real.list)do
        if charcter_cfg[k].stage == Secret then
            num = num + 1
        end
    end
    return num
end

--获取已装备的攻击力
function c:GetAttack()
    local equiped = self.data.__real.equiped
    local cfg = charcter_cfg[equiped]
    if cfg.stage == Secret then
        local per = cfg.per + 1
        local maxAtk = 0
        for k,v in pairs(self.data.__real.list)do
            local atk = charcter_cfg[k] and charcter_cfg[k].value or 100
            maxAtk = math.max(maxAtk,atk)
        end
        return per * maxAtk
    end
    return cfg.value
end

--获取已装备的血量
function c:GetHP()
    local equiped = self.data.__real.equiped
    local cfg = charcter_cfg[equiped]
    if cfg.stage == Secret then
        local per = cfg.per + 1
        local maxHp = 0
        for k,v in pairs(self.data.__real.list)do
            local hp = charcter_cfg[k] and charcter_cfg[k].hp or 100
            maxHp = math.max(maxHp,hp)
        end
        return per * maxHp
    end
    return cfg.hp
end

c:RegistFunction('equip_character',c.EquipCharacter)

return c