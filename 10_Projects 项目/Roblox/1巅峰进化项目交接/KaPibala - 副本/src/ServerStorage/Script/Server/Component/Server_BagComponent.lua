local hotpot = _G.ServerHotpot

local box_cfg = hotpot.config.relics_gacha
local buff_cfg = hotpot.config.boosts

---@class Server_BagComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end

function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('bag')

    -- self:AddBox(1,20)
    local fol = Instance.new('Folder',self.parent.main_inst)
    fol.Name = 'BuffFol'
    local expBuff = Instance.new('NumberValue',fol)
    expBuff.Name = 'ExpBuff'
    local LuckBuff = Instance.new('NumberValue',fol)
    LuckBuff.Name = 'LuckBuff'
    local CoinBuff = Instance.new('NumberValue',fol)
    CoinBuff.Name = 'CoinBuff'
    local sexpBuff = Instance.new('NumberValue',fol)
    sexpBuff.Name = 'sExpBuff'
    local sLuckBuff = Instance.new('NumberValue',fol)
    sLuckBuff.Name = 'sLuckBuff'
    local sCoinBuff = Instance.new('NumberValue',fol)
    sCoinBuff.Name = 'sCoinBuff'

    self.expBuff = expBuff
    self.luckBuff = LuckBuff
    self.coinBuff = CoinBuff
    self.sexpBuff = sexpBuff
    self.sLuckBuff = sLuckBuff
    self.sCoinBuff = sCoinBuff

    self.valueList = {expBuff,CoinBuff,LuckBuff,sexpBuff,sCoinBuff,sLuckBuff,}

    self:AddUpdate(self.UpdateBuff,1)
end

function c:AddBox(id,num)
    num = num or 1
    self.parent.save_data:Execut(function()
        if self.data.creates.list[id] then
            self.data.creates.list[id] = self.data.creates.list[id] + num
        else
            self.data.creates.list[id] = num
        end
    end)

    self:Fire('addBox',id,num)
end

function c:AddBuff(id,num)
    self.parent.save_data:Execut(function()
        if self.data.boosts.list[id] then
            self.data.boosts.list[id] = self.data.boosts.list[id] + num
        else
            self.data.boosts.list[id] = num
        end
    end)

    self:Fire('addBuff',id,num)

    return true
end

--开宝箱
function c:OpenBox(id)
    local cfg = box_cfg[id]
    if not cfg then
        return false
    end
    local num = self.data.__real.creates.list[id]
    if not num then
        return false
    end
    if num <= 0 then
        return false
    end

    local total = 0
    for k,v in ipairs(cfg.weight)do
        total = total + v
    end
    local relice_id
    local ran = math.random(1,total)
    local idx = 0
    for k,v in ipairs(cfg.weight)do
        ran = ran - v
        if ran <= 0 then
            relice_id = cfg.relics_id[k]
            idx = k
            break
        end
    end
    if not relice_id then
        relice_id = cfg.relics_id[1]
        idx = 1
    end
    self.parent.save_data:Execut(function()
        self.data.creates.list[id] = self.data.creates.list[id] - 1
        if self.data.creates.list[id] <= 0 then
            self.data.creates.list[id] = nil
        end
    end)

    if cfg.character and idx == 5 then
        self.parent.character_cmp:UnlockSecret(cfg.character,true)
    else
        self.parent.relics_cmp:AddRelics(relice_id)
    end

    -- self.parent.reward_cmp:AddReward({{4,relice_id,1}})
    return true,relice_id,idx
end

--开所有宝箱
function c:OpenAllBox(id)
    local cfg = box_cfg[id]
    if not cfg then
        return false
    end
    local num = self.data.__real.creates.list[id]
    if not num then
        return false
    end
    if num <= 0 then
        return false
    end
    local total = 0
    for k,v in ipairs(cfg.weight)do
        total = total + v
    end

    local re = {}
    for i = 1,num do
        local relice_id,idx
        local ran = math.random(1,total)
        for k,v in ipairs(cfg.weight)do
            ran = ran - v
            if ran <= 0 then
                relice_id = cfg.relics_id[k]
                idx = k
                break
            end
        end

        if not relice_id then
            relice_id = cfg.relics_id[1]
            idx = 1
        end
        table.insert(re,{relice_id = relice_id,idx = idx})
    end

    self.parent.save_data:Execut(function()
        self.data.creates.list[id] = nil
    end)

    for k,v in ipairs(re)do
        if v.idx == 5 and cfg.character then
            self.parent.character_cmp:UnlockSecret(cfg.character,true)
        else
            self.parent.relics_cmp:AddRelics(v.relice_id)
        end
    end

    return true,re
end

function c:UseBuff(id)
    local num = self.data.__real.boosts.list[id]
    if not num then
        return
    end
    if num < 1 then
        return
    end
    self.parent.save_data:Execut(function()
        self.data.boosts.list[id] = self.data.boosts.list[id] - 1
        if self.data.boosts.used[id] then
            self.data.boosts.used[id] = self.data.boosts.used[id] + buff_cfg[id].time_
        else
            self.data.boosts.used[id] = buff_cfg[id].time_
        end
    end)
    return true
end

function c:UpdateBuff()
    for k,v in pairs(buff_cfg)do
        local num = self.data.__real.boosts.used[k]
        local stop = v.stop
        if num and num > 0 then
            if stop then
                local stopNum = self.data.__real.boosts.used[stop]
                if stopNum and stopNum > 0 then
                else
                    num = num - 1
                    self.parent.save_data:Execut(function()
                        self.data.boosts.used[k] = num
                    end)
                    self.valueList[k].Value = num
                end
            else
                num = num - 1
                self.parent.save_data:Execut(function()
                    self.data.boosts.used[k] = num
                end)
                self.valueList[k].Value = num
            end
        end
    end
end

function c:GetBuff(id)
    local newId = id + 3
    local num = self.data.__real.boosts.used[newId]
    if num and num > 0 then
        return buff_cfg[newId].per
    else
        local num = self.data.__real.boosts.used[id]
        if num and num > 0 then
            return buff_cfg[id].per
        end
    end
    return 1
end

c:RegistFunction('openBox',c.OpenBox)
c:RegistFunction('useBuff',c.UseBuff)
c:RegistFunction('openAllBox',c.OpenAllBox)

return c