local hotpot = _G.ServerHotpot
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local forgeCostCfg = hotpot.config.forgeCost
local relics_cfg = hotpot.config.relics
local relics_gacha_cfg = hotpot.config.relics_gacha
local box_cd = hotpot.pro_cfg.relice_box_cd
local Relics_fol = hotpot:GetPath_Loop('Relics',hotpot.Resource)
local PropList = {DMG = true,EXP = true,MaxHp = true,Speed = true}
local PropList_Order = {'DMG','EXP','MaxHp','Speed'}
local scroll_cfg = hotpot.config.relicsScorll
local forgeCostCfg = hotpot.config.forgeCost
local luckyStoneCfg = hotpot.config.luckyStone
local forgeEff = hotpot:GetPath_Loop('pfb.forgeEff',hotpot.Resource)
local weaponFol = hotpot:GetPath_Loop('weapon',hotpot.Resource)
local suitCfg = hotpot.config.suit

---@class Server_RelicsComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end

function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('relics')

    if not self.data.__real.show then
        self.parent.save_data:Execut(function()
            self.data.show = {}
        end)
    end

    self:UpdateData()

    self.rig = nil
    self:AddProcess(function()
        self.rig = hotpot:GetPath_Check(
            'PlayerGui.RelicsGui.Frame.bg.ViewportFrame.WorldModel.Rig',
            self.parent.main_inst
        )

        local count = 10
        while count > 0 do
            if self.rig then
                break
            end
            count = count - 1
            self.rig = hotpot:GetPath_Check(
                'PlayerGui.RelicsGui.Frame.bg.ViewportFrame.WorldModel.Rig',
                self.parent.main_inst
            )
        end
    end)

    self:RefreshProp()

    local event = game.ReplicatedStorage:WaitForChild('Event')
    event.Event:Connect(function(player)
        if player == self.parent.main_inst then
            self:Init()
        end
    end)

    -- self:AddProcess(function()
    --     self:Wait(10)
    --     -- self:AddRelics(191)

    -- end)
end

function c:Init()
    local show = self.data.__real.show
    for pos,inst_id in pairs(show)do
        local tab = self.data.newlist[inst_id]
        if tab then
            local relics_id = tab.relics_id
            self:AddProcess(function()
                if not self.rig then
                    return
                end
                local name = relics_cfg[relics_id].model
                if not name then
                    return true
                end

                if relics_cfg[relics_id].type_ == 7 then

                    self.parent.Weaponvalue.Value = relics_id

                    local weapon = self.rig:FindFirstChild('weapon')
                    if weapon then
                        weapon:Destroy()
                    end
                    local modelName = relics_cfg[relics_id].model
                    local model = weaponFol:FindFirstChild(modelName)
                    model = hotpot:CloneInst_Loop(model)
                    model.Name = 'weapon'

                    model.Parent = self.rig

                    self:EquipWeapon(relics_id)
                else
                    local acc = Relics_fol:FindFirstChild(name)
                    acc = hotpot:CloneInst_Loop(acc)
                    acc.Name = 'relicsAcc_'..relics_cfg[relics_id].type_
    
                    local oldAcc = self.rig:FindFirstChild(acc.Name)
                    if oldAcc then
                        oldAcc:Destroy()
                        oldAcc = nil
                    end
                    oldAcc = self.parent.character.main_inst:FindFirstChild(acc.Name)
                    if oldAcc then
                        oldAcc:Destroy()
                        oldAcc = nil
                    end
    
                    acc:SetAttribute('relics',true)
                    local acc1 = hotpot:CloneInst_Loop(acc)
                    
                    acc.Parent = self.rig
                    acc1.Parent = self.parent.character.main_inst
                end

                if place_manager:GetIdByName('challengesence') == game.PlaceId then
                    return
                end
                self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetSpeed())
            end)
        end
    end

    self:RefreshProp()
    self:RefrehPower()
end

function c:GetEquipWeaponId()
    local inst_id =  self.data.__real.show[7] or nil
    if inst_id then
        return self.data.__real.newlist[inst_id].relics_id
    end
end

function c:UpdateData()
    if not self.data.__real.newlist then
        self.parent.save_data:Execut(function()
            self.data.newlist = {}
        end)

        local list = self.data.__real.list
        for id,num in pairs(list)do
            for i = 1,num do
                self:AddRelics(id)
            end
        end

        self.parent.save_data:Execut(function()
            self.data.list = {}
            self.data.equiped[1].relics_id = nil
            self.data.equiped[2].relics_id = nil
            self.data.equiped[3].relics_id = nil    
            self.data.equiped[4].relics_id = nil
            self.data.equiped[5].relics_id = nil
            self.data.equiped[6].relics_id = nil       
        end)
    end
end

function c:AddRelics(id)
    local inst_id = self.data.__real.inst_id
    inst_id = inst_id + 1
    self.parent.save_data:Execut(function()
        self.data.inst_id = inst_id
        self.data.newlist[inst_id] = {
            relics_id = id,
            equip = false,
            big = 0,
            small = 0,
        }
        self.data.index[id] = inst_id
    end)

	self:Fire('add_relics',id,inst_id)

	return true 
end

function c:AddRelicsWithStar(id,big,small)
     local inst_id = self.data.__real.inst_id
    inst_id = inst_id + 1
    self.parent.save_data:Execut(function()
        self.data.inst_id = inst_id
        self.data.newlist[inst_id] = {
            relics_id = id,
            equip = false,
            big = big,
            small = small,
        }
        self.data.index[id] = inst_id
    end)

	self:Fire('add_relicsByStar',id,inst_id,big,small)

	return true 
end

function c:DelRelics(inst_id)
    local tab = self.data.__real.newlist[inst_id]
    if not tab then
        return 
    end
    if tab.equip then
        return
    end
    self.parent.save_data:Execut(function()
        self.data.newlist[inst_id] = nil
    end)
    self:Fire('del_relics',inst_id)
    return true
end

--装备
function c:EquipRelics(inst_id,solt)
    if not (solt >= 1 and solt <= 9) then
        return
    end
    local tab = self.data.__real.newlist[inst_id]
    if not tab then
        return 
    end
    
    --判断solt是否解锁
    if not self.data.__real.equiped[solt].unlock then
        return
    end

    --判断是否已装备
    if self.data.__real.equiped[solt].inst_id then
        return
    end

    self.parent.save_data:Execut(function()
        self.data.equiped[solt].inst_id = inst_id
        self.data.newlist[inst_id].equip = true
    end)

    self:RefreshProp()
    self:RefrehPower()
    self:RefreshEff()

    self:AddProcess(function()
        if not self.rig then
            return
        end

        local tab = self.data.__real.newlist[inst_id]
        local relics_id = tab.relics_id

        local name = relics_cfg[relics_id].model
        if not name then
            return true
        end

        local type_ = relics_cfg[relics_id].type_

        if type_ == 7 then
            self.parent.save_data:Execut(function()
                self.data.show[type_] = inst_id
            end)
            
            self.parent.Weaponvalue.Value = relics_id
            self:EquipWeapon(relics_id)

            local weapon = self.rig:FindFirstChild('weapon')
            if weapon then
                weapon:Destroy()
            end
            local modelName = relics_cfg[relics_id].model
            local model = weaponFol:FindFirstChild(modelName)
            model = hotpot:CloneInst_Loop(model)
            model.Name = 'weapon'

            model.Parent = self.rig
            
        else
            local acc = Relics_fol:FindFirstChild(name)
            acc = hotpot:CloneInst_Loop(acc)
    
            acc.Name = 'relicsAcc_'..type_
    
            self.parent.save_data:Execut(function()
                self.data.show[type_] = inst_id
            end)
    
            local oldAcc = self.rig:FindFirstChild(acc.Name)
            if oldAcc then
                oldAcc:Destroy()
                oldAcc = nil
            end
    
            if not (self.parent.character and self.parent.character.main_inst and self.parent.character.main_inst.Parent) then
                return
            end
    
            oldAcc = self.parent.character.main_inst:FindFirstChild(acc.Name)
            if oldAcc then
                oldAcc:Destroy()
                oldAcc = nil
            end
    
            acc:SetAttribute('relics',true)
            local acc1 = hotpot:CloneInst_Loop(acc)
            
            acc.Parent = self.rig
            acc1.Parent = self.parent.character.main_inst
        end

        self.parent.character:RefreshHp()
        if place_manager:GetIdByName('challengesence') == game.PlaceId then
            return
        end
        self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetSpeed())
    end)

    return true
end

--卸载
function c:UnequipRelics(solt)
    local tab = self.data.__real.equiped[solt]
    if not tab then
        return 
    end

    local inst_id = tab.inst_id

    if not inst_id then
        return
    end

    self.parent.save_data:Execut(function()
        self.data.equiped[solt].inst_id = nil
        self.data.newlist[inst_id].equip = false
    end)
    self:RefreshProp()
    self:RefrehPower()
    self:RefreshEff()

    self:AddProcess(function()
        if not self.rig then
            return
        end
        local tab = self.data.__real.newlist[inst_id]
        if not tab then
            return
        end
        local relics_id = tab.relics_id
        local type_ = relics_cfg[relics_id].type_
        if not type_ then
            return
        end

        if type_ == 7 then
            if self.data.__real.show[type_] then
                self.parent.save_data:Execut(function()
                    self.data.show[type_] = nil
                end)
            end
            
            self.parent.Weaponvalue.Value = 0
            self:UnEquipWeapon()

            local weapon = self.rig:FindFirstChild('weapon')
            weapon:Destroy()

            local name = self.parent.character_cmp.character_value
            local model = weaponFol:FindFirstChild(name)
            model = hotpot:CloneInst_Loop(model)
            model.Name = 'weapon'

            model.Parent = self.rig
        else
            local name ='relicsAcc_'..type_
            local acc = self.rig:FindFirstChild(name)
            if acc then
                acc:Destroy()
            end
    
            if self.data.__real.show[type_] then
                self.parent.save_data:Execut(function()
                    self.data.show[type_] = nil
                end)
            end
    
            local acc1 = self.parent.character.main_inst:FindFirstChild(name)
            if acc1 then
                acc1:Destroy()
            end
        end


        if place_manager:GetIdByName('challengesence') == game.PlaceId then
            return
        end
        self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetSpeed())
        self.parent.character:RefreshHp()
    end)

    return true,inst_id
end

function c:EquipWeapon(relics_id)
    --先删除原先的weapon
    ---@type Server_PlayerCharacter
    local character = self.parent.character

    local weapon = character.main_inst:FindFirstChild('weapon')
    if weapon then
        weapon:Destroy()
    end

    local modelName = relics_cfg[relics_id].model
    local model = weaponFol:FindFirstChild(modelName)
    model = hotpot:CloneInst_Loop(model)
    model.Name = 'weapon'

    model.Parent = character.main_inst

    self.parent.character:AddEff()
end

function c:UnEquipWeapon()
    ---@type Server_PlayerCharacter
    local character = self.parent.character

    local weapon = character.main_inst:FindFirstChild('weapon')
    if weapon then
        weapon:Destroy()
    end

    local name = self.parent.character_cmp.character_value
    local model = weaponFol:FindFirstChild(name)
    model = hotpot:CloneInst_Loop(model)
    model.Name = 'weapon'

    model.Parent = character.main_inst

    self.parent.character:AddEff()
end

--改变模型
function c:ChangeRig(model)
    local cf = self.rig:GetPivot()
    local parent = self.rig.Parent
    if self.rig then
        self.rig:Destroy()
        self.rig = nil
    end
    model.Parent = parent
    model:PivotTo(cf)
    self.rig = model
end

--领取宝箱
function c:GetReliceBox()
    local now = os.time()
    local mark = self.data.__real.box.mark
    if mark + box_cd > now then
        return false
    end

    -- self.parent.bag_cmp:AddBox(1)
    self.parent.reward_cmp:AddReward({{6,2,1}})

    self.parent.save_data:Execut(function()
        self.data.box.mark = now
        self.data.box.num = self.data.box.num + 1
    end)

    return true
end

--刷新属性
function c:RefreshProp()
    local prop = {}
    local equiped = self.data.__real.equiped

    local suitList = {}

    for pos,tab in pairs(equiped)do
        if tab.inst_id then
            local inst_id = tab.inst_id
            local data = self.data.__real.newlist[inst_id]
            local relics_id = data.relics_id
            local forge = data.forge
            local cfg = relics_cfg[relics_id]
            local big = data.big or 0
            local bigVal = forgeCostCfg[big] and (forgeCostCfg[big].big) or 0

            local suit = relics_cfg[relics_id].suit
            if suit then
                suitList[suit] = suitList[suit] or {
                    num = 0,
                    id = {},
                }
                if not suitList[suit].id[relics_id] then
                    suitList[suit].id[relics_id] = true
                    suitList[suit].num = suitList[suit].num + 1
                end
            end

            if cfg then
                for key,_ in pairs(PropList)do
                    if cfg[key] then
                        local val = cfg[key]
                        if forge and key == forge.key then
                            prop[key] = prop[key] or 0
                            if key == 'DMG' then
                                val = val * (1 + bigVal/100)
                            end
                            val = val + forge.val
                            prop[key] = val + prop[key]
                        else
                            prop[key] = prop[key] or 0
                            if key == 'DMG' then
                                val = val * (1 + bigVal/100)
                            end
                            prop[key] = val + prop[key]
                        end
                    end
                end
            end
        end
    end

    
    --套装
    for suitId,tab in pairs(suitList)do
        if tab.num >= 2 then
            local set2 = suitCfg[suitId].set2
            prop[set2.prop] = prop[set2.prop] or 0
            prop[set2.prop] = prop[set2.prop] + set2.value
        end
        if tab.num >= 4 then
            local set4 = suitCfg[suitId].set4
            prop[set4.prop] = prop[set4.prop] or 0
            prop[set4.prop] = prop[set4.prop] + set4.value
        end
        if tab.num >= 6 then
            local set6 = suitCfg[suitId].set6
            prop[set6.prop] = prop[set6.prop] or 0
            prop[set6.prop] = prop[set6.prop] + set6.value
        end
    end
    -- print(prop)

    if prop.AttackSpeed then
        self.parent.speedValue.Value = prop.AttackSpeed / 100
    else
        self.parent.speedValue.Value = 0
    end

    self.prop = prop
    if self.parent.stats_cmp then
        self.parent.stats_cmp:SyncAttack()
    end

end

function c:RefrehPower()
    local old_power = self.power or 0
    
    if self.parent.prop_cmp then
        local atk = self.parent.prop_cmp:GetAttack()
        local hp = self.parent.prop_cmp:GetHp()
        self.power = atk + hp
    
        self:Fire('changePower',old_power,self.power)
    end
end

--刷新特效
function c:RefreshEff()
    local BIG = 0
    for solt,v in pairs(self.data.__real.equiped)do
        if v.inst_id then
            local tab = self.data.__real.newlist[v.inst_id]
            if tab then
                local big = tab.big or 0
                BIG = math.max(BIG,big)
            end
        end
    end

    local fol = self.parent.character and self.parent.character.forgeEff_fol
    local val = 0
    if BIG >= 3 and BIG < 7 then
        val = 1
    elseif BIG >= 7 and BIG < 10 then
        val = 2
    elseif BIG >= 10 then
        val = 3
    end
    if self.eff_val == val then
        return
    end
    self.eff_val = val
    if self.eff_model then
        self.eff_model:Destroy()
        self.eff_model = nil
    end

    local eff = forgeEff:FindFirstChild('e'..val)
    if eff then
        eff = hotpot:CloneInst_Loop(eff)
        eff.Parent = fol
        eff:PivotTo(self.parent.character:GetCFrame())
        local we = Instance.new('WeldConstraint',eff.PrimaryPart)
        we.Part0 = eff.PrimaryPart
        we.Part1 = self.parent.character.root_part

        self.eff_model = eff
    end

end

--获取属性
function c:GetProp()
    return self.prop or {}
end

--解锁全部
function c:UnlockAll()
    for k,v in ipairs(self.data.__real.equiped)do
        self.parent.save_data:Execut(function()
            if v.unlock == false then
                self.data.equiped[k].unlock = true
            end
        end)
    end
    return true
end

--购买解锁solt
function c:BuyUnlockSolt(idx)
    if self.data.__real.equiped[idx].unlock then
        return
    end
    self.parent.save_data:Execut(function()
        self.data.equiped[idx].unlock = true
    end)
    return true
end

--解锁solt
function c:UnlockSolt()
    local idx = 0
    for i = 7,9 do
        if self.data.__real.equiped[i].unlock == false then
            idx = i
            break
        end
    end
    if idx == 0 then
        return
    end
    self.parent.save_data:Execut(function()
        self.data.equiped[idx].unlock = true
    end)

    self:Fire('unlockSolt',idx)

    return true
end

--增加卷轴
function c:AddScroll(id,num)
    num = num or 1
    self.parent.save_data:Execut(function()
        if self.data.scrolls[id] then
            self.data.scrolls[id] = self.data.scrolls[id] + num
        else
            self.data.scrolls[id] = num
        end
    end)

    self:Fire('addScroll',id,num)
end

--使用卷轴
function c:UseScroll(id,num)
    if not self.data.scrolls[id] then
        return
    end
    if self.data.scrolls[id] < num then
        return
    end

    num = num or 1
    self.parent.save_data:Execut(function()
        self.data.scrolls[id] = self.data.scrolls[id] - num
    end)
    self:Fire('useScroll',id,num)
end

--合成
function c:ForgeRelics(inst_id,scroll_id)
    local tab = self.data.__real.newlist[inst_id]
    if not tab then
        return false
    end
    local num = self.data.scrolls[scroll_id]
    if not num or num <= 0 then
        return false
    end

    local list = {}
    local cfg = relics_cfg[tab.relics_id]
    for idx,key in ipairs(PropList_Order)do
        if cfg[key] then
            table.insert(list,{key = key,val = cfg[key]})
        end
    end
    local random = math.random(1,#list)

    self:UseScroll(scroll_id,1)
    self.parent.save_data:Execut(function()
        self.data.newlist[inst_id].forge = {
            idx = random,
            key = list[random].key,
            val = scroll_cfg[scroll_id].add,
        }
    end)
    return true,random
end

--增加分解币
function c:AddSmeltCoin(num)
    self.parent.save_data:Execut(function()
        self.data.smelt_coin = self.data.smelt_coin + num
    end)
    self:Fire('addSmeltCoin',num)
end

--使用分解币
function c:UseSmeltCoin(num)
    if self.data.__real.smelt_coin < num then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.smelt_coin = self.data.smelt_coin - num
    end)
    self:Fire('useSmeltCoin',num)
    return true
end

--分解
function c:SmeltRelics(list)
    --检查
    for inst_id,_ in pairs(list)do
        local tab = self.data.__real.newlist[inst_id]
        if not tab then
            return false
        end
        if tab.equip then
            return false
        end
    end

    local coin = 0
    for inst_id,_ in pairs(list)do
        local tab = self.data.__real.newlist[inst_id]
        local cfg = relics_cfg[tab.relics_id]
        coin = coin + cfg.score
        if tab.forge then
            coin = coin + tab.forge.val
        end
    end

    self:AddSmeltCoin(coin)
    for inst_id,_ in pairs(list)do
        self:DelRelics(inst_id)
    end
    return true
end

--增加幸运石
function c:AddLuckyStone(id,num)
    num = num or 1
    self.parent.save_data:Execut(function()
        if self.data.luckyStone.list[id] then
            self.data.luckyStone.list[id] = self.data.luckyStone.list[id] + num
        else
            self.data.luckyStone.list[id] = num
        end
    end)
    self:Fire('changeLuckyStone',id,self.data.__real.luckyStone.list[id])
end

--使用幸运石
function c:UseLuckyStone(id,num)
    if not self.data.__real.luckyStone.list[id] then
        return false
    end
    if self.data.__real.luckyStone.list[id] < num then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.luckyStone.list[id] = self.data.luckyStone.list[id] - num
    end)
    self:Fire('changeLuckyStone',id,self.data.__real.luckyStone.list[id])
    return true
end

--增加锻造石
function c:AddForgeStone(idx,num)
    num = num or 1
    self.parent.save_data:Execut(function()
        if not self.data.forgeStone.list[idx] then
            self.data.forgeStone.list[idx] = 0
        end
        self.data.forgeStone.list[idx] = self.data.forgeStone.list[idx] + num
    end)
    self:Fire('changeForgeStone',idx,self.data.__real.forgeStone.list[idx])
end

--使用锻造石
function c:UseForgeStone(idx,num)
    if self.data.__real.forgeStone.list[idx] < num then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.forgeStone.list[idx] = self.data.forgeStone.list[idx] - num
    end)
    self:Fire('changeForgeStone',idx,self.data.__real.forgeStone.list[idx])
    return true
end 

function c:GuildForge(inst_id,list)
    local tab = self.data.__real.newlist[inst_id]
    if not tab then
        return false
    end
    local big = tab.big or 0
    local small = tab.small or 0
    if small >= 10 then
        return false
    end
    local cost = forgeCostCfg[small + 1].forgeStone

    local stoneIdx = 0
    if small <= 3 then
        stoneIdx = 1
    elseif small <= 6 then
        stoneIdx = 2
    else
        stoneIdx = 3
    end

    local stoneNum = self.data.__real.forgeStone.list[stoneIdx] or 0
    if stoneNum < cost then
        return false
    end
    local gold = forgeCostCfg[small + 1].gold
    if self.parent.prop_cmp:GetWins() < gold then
        return false
    end

    local addPer = 0
    for id,num in pairs(list)do
        local now = self.data.__real.luckyStone.list[id] or 0
        if now < num then
            return false
        end
        addPer = addPer + num * luckyStoneCfg[id].per
    end

    local per = forgeCostCfg[small + 1].per + addPer

    local success = false

    if per < 100 then
        local num = math.random(1,100*10000)
        if num > per*10000 then
            success = false
        else
            success = true
        end
    else
        success = true
    end

    self:UseForgeStone(stoneIdx,cost)
    self.parent.prop_cmp:CostWins(gold)
    self.parent.save_data:Execut(function()
        if success then
            if small == big then
                self.data.newlist[inst_id].small = small + 1
                self.data.newlist[inst_id].big = big + 1
            else
                self.data.newlist[inst_id].small = small + 1
            end
        else
            self.data.newlist[inst_id].small = 0
        end
    end)
    for id,num in pairs(list)do
        self:UseLuckyStone(id,num)
    end

    self:AddProcess(self.RefreshEff)

    pcall(function()
        if success and small >= 6 and big == small then
            hotpot.event_manager:FireAll('pvpforgeSuccess',{
                name = self.parent.main_inst.Name,
                upgrade = small + 1,
            })
        end
    end)

    local newBig = self.data.__real.newlist[inst_id].big or 0
    local newSmall = self.data.__real.newlist[inst_id].small or 0

    return true,success,newBig,newSmall 
end

function c:SetTransferSolt(idx,inst_id)
    if idx == 1 then
        self.transfer_solt1 = inst_id
    elseif idx == 2 then
        self.transfer_solt2 = inst_id
    end
end

function c:CheckTransfer(cfg_id)
    if not self.transfer_solt1 or not self.transfer_solt2 then
        return false
    end

    local tab1 = self.data.__real.newlist[self.transfer_solt1]
    local tab2 = self.data.__real.newlist[self.transfer_solt2]
    if not tab1 or not tab2 then
        return false
    end

    local big = tab1.big or 0
    if cfg_id == 116 then
        if big ~= 7 then
            return false
        end
    elseif cfg_id == 117 then
        if big ~= 8 then
            return false
        end
    elseif cfg_id == 118 then
        if big ~= 9 then
            return false
        end
    elseif cfg_id == 119 then
        if big ~= 10 then
            return false
        end
    end

    return true
end

function c:Transfer(cfg_id)
    local inst1 = self.transfer_solt1
    local inst2 = self.transfer_solt2

    if not inst1 or not inst2 then
        return false
    end

    local tab1 = self.data.__real.newlist[inst1]
    local tab2 = self.data.__real.newlist[inst2]

    if not tab1 or not tab2 then
        return false
    end

    local big1 = tab1.big or 0
    local small1 = tab1.small or 0
    local big2 = tab2.big or 0
    local small2 = tab2.small or 0

    self.parent.save_data:Execut(function()
        self.data.newlist[inst1].big = big2
        self.data.newlist[inst1].small = small2
        self.data.newlist[inst2].big = big1
        self.data.newlist[inst2].small = small1
    end)

    self:Fire('transferRelics',inst1,big2,small2)
    self:Fire('transferRelics',inst2,big1,small1)

    self.transfer_solt1 = nil
    self.transfer_solt2 = nil

    return true
end

function c:ClientTransfer(inst1,inst2)
    local tab1 = self.data.__real.newlist[inst1]
    local tab2 = self.data.__real.newlist[inst2]
    if not tab1 or not tab2 then
        return false
    end
    local big = tab1.big or 0
    if big > 6 then
        return false
    end

    self:Transfer()

    return true
end

c:RegistFunction('forgeGuildRelics',c.GuildForge)
c:RegistFunction('equip_relics',c.EquipRelics)
c:RegistFunction('unequip_relics',c.UnequipRelics)
c:RegistFunction('get_relics_box',c.GetReliceBox)
c:RegistFunction('forge_relics',c.ForgeRelics)
c:RegistFunction('smelt_relics',c.SmeltRelics)
c:RegistEvent('SetTransferSolt',c.SetTransferSolt)
c:RegistFunction('transferRelics',c.ClientTransfer)

return c