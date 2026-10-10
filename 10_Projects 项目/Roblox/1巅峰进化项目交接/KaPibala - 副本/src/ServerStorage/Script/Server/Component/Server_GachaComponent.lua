local hotpot = _G.ServerHotpot

local gacha_cfg = hotpot.config.gacha

---@class Server_GachaComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.pay = self.parent.save_data:GetData('pay')

    self.delPetList = {}
end

function c:Gacha(egg_id)
    local luck = self:GetLucky()
    local cfg = gacha_cfg[egg_id]
    if not cfg then
        return
    end
    local total = 0
    local tempTable = {}
    for k,v in ipairs(cfg.weight)do
        if k == 1 then
            tempTable[k] = v
            total = total + v 
        else
            tempTable[k] = v * luck
            total = total + v * luck
        end
    end

    local relics_id
    local num = math.random(1,total)
    for k,v in ipairs(tempTable)do
        num = num - v
        if num <= 0 then
            relics_id = cfg.pet_id[k]
            break
        end
    end

    if not relics_id then
        return cfg.pet_id[1]
    end

    local r,e = pcall(function()
        self.parent.battle_pass_cmp:AddPoint(4,1)
        self.parent.battle_pass_cmp:AddPoint(6,1)
        self.parent.eternal_cmp:AddTaskPoint(4,1)
        self.parent.eternal_cmp:AddTaskPoint(6,1)
        self.parent.title_cmp:AddPoint(2,1)
    end)
    if not r then
        warn(e)
    end

    return relics_id
end

function c:GachaOne(egg_id)
    local cfg = gacha_cfg[egg_id]
    if not cfg then
        return 
    end

    if cfg.p_type ~= 3 then
        return false
    end
    if not self.parent.prop_cmp:CostWins(cfg.price)then
        return
    end

    local pet_id = self:Gacha(egg_id)
    if not pet_id then
        pet_id = cfg.pet_id[1]
    end

    if not self.delPetList[pet_id] then
        self.parent.pet_cmp:AddPet(pet_id)
    end

    if self.parent.guide_cmp then
        if self.parent.guide_cmp:GetNum() == 1 then
            self.parent.guide_cmp:ChangeNum(2)
        end
    end

    self.parent.stats_cmp:AddEggs(1)

    return pet_id
end

function c:GachaThree(egg_id)
    local cfg = gacha_cfg[egg_id]
    if not cfg then
        return 
    end

    if cfg.p_type ~= 3 then
        return false
    end

    if self.parent.pet_cmp:GetBagRemain() < 3 then
        return false
    end

    if not self.parent.prop_cmp:CostWins(cfg.price * 3)then
        return
    end
    local list = {}
    for i = 1,3 do
        local pet_id = self:Gacha(egg_id)
        if not pet_id then
            pet_id = cfg.pet_id[1]
        end
        list[i] = {pet_id = pet_id}
        if not self.delPetList[pet_id] then
            self.parent.pet_cmp:AddPet(pet_id)
        end
    end

    if self.parent.guide_cmp then
        if self.parent.guide_cmp:GetNum() == 1 then
            self.parent.guide_cmp:ChangeNum(2)
        end
    end

    self.parent.stats_cmp:AddEggs(3)

    return list
end

function c:GetLucky()
    local base = 1
    if self.pay.__real.pay_list[56] then
        base = base * 1.5
    end
    if self.pay.__real.pay_list[57] then
        base = base * 2
    end
    
    local lucky = self.parent.shop_cmp:GetLucky()
    local upgrade = self.parent.upgrade_cmp:GetValue('luck')

    local boost = self.parent.bag_cmp:GetBuff(3)
    boost = boost or 1

    base = base * lucky * boost * (1 + upgrade)

    return base
end

function c:ChangeGachaDelPet(delPetList)
    if self.parent.prop_cmp.data.__real.reborn < 4 then
        return
    end
    self.delPetList = delPetList
end

c:RegistFunction('gacha_one',c.GachaOne)
c:RegistFunction('gacha_three',c.GachaThree)
c:RegistEvent('changeGachaDelPet',c.ChangeGachaDelPet)

return c