local hotpot = _G.ServerHotpot
---@type Server_ChallengeMonsterObj
local monsterObj = hotpot.load.Server_ChallengeMonsterObj()

local relics1 = {6,7,8,11,12,13,27,28,29,32,33,48,49,52,53,56,57,60,61}
local relics2 = {27,28,29,32,33,34,48,49,52,53,56,57,60,61,5,9,10,14,15,30,31,34,35,50,54,62,66,70,74}
local relics3 = {33,34,48,49,52,53,56,57,60,61,5,9,10,14,15,30,31,34,35,50,54,62,66,70,74,15,16,31,38,44,45,51,55,59,81,87}
local stagelist = workspace:WaitForChild('stagelist')
local monsterFol = hotpot:GetPath_Loop('monster',hotpot.Resource)
local challengeCfg = hotpot.config.challengeMonster
local monsterCfg = hotpot.config.monster
local bossCfg = {}
local normalCfg = {}
for k,v in ipairs(hotpot.config.monster)do
    if v.stage < 12 then
        if v.is_boss then
            table.insert(bossCfg,v)
        else
            table.insert(normalCfg,v)
        end
    end
end
local baseNameList = {}
local serverFol = game.ServerStorage:WaitForChild('stagelist')
for k,v in ipairs(serverFol:GetChildren())do
    local basename = v:getAttribute('baseName')
    if basename then
        baseNameList[basename] = v
    end
end

---@class Server_ChallengeStageObj:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new()
    return c()
end
function c:ctor()
    c.super.ctor(self)

    self.area_list = {}
    self.guid_to_monster = {}
    self.guid_to_player = {}
    self.area_monster = {}

    self.pass_num = 0
    self.reward_list = {}

    -- self:LoadBase()
end

function c:LoadBase()
    for k,v in ipairs(stagelist:GetChildren())do
        local id = tonumber(v.Name)
        if id then
            self.area_list[id] = {
                model = stagelist:WaitForChild(tostring(id)),
            }
            self:LoadMonster(id)
            self:CloseDoor(id)
        end
    end
end

function c:LoadArea(idx)
    if self.area_list[idx] then
        return
    end
    local count = (idx % 3)
    if count == 0 then
        count = 3
    end
    local model = baseNameList[tostring(count)]
    if model then
        local cloneModel = hotpot:CloneInst_Loop(model)
        local lastModel =  self:FindMaxModel()
        local tail = lastModel:FindFirstChild('tail')
        local head = cloneModel:FindFirstChild('head')
        if not tail or not head then
            return
        end
        
        -- 当前模型整体的 CFrame
        local modelPivot = cloneModel:GetPivot()
        -- head 在模型中的相对变换
        local relative = modelPivot:ToObjectSpace(head.CFrame)
        -- 目标模型 CFrame
        local targetPivot = tail.CFrame * relative:Inverse()
        -- 应用新的 CFrame
        cloneModel:PivotTo(targetPivot)

        cloneModel.Name = tostring(idx)

        cloneModel.Parent = stagelist
        self.area_list[idx] = {
            model = cloneModel
        }

        self:AddProcess(self.DelModel,idx - 4)
        self:LoadMonster(idx)
        self:CloseDoor(idx)
    end
end

function c:FindMaxModel()
    local max = 0
    local model = nil
    for k,v in pairs(self.area_list)do
        local num = tonumber(v.model.Name)
        if num > max then
            max = num
            model = v.model
        end
    end
    return model
end

function c:CloseDoor(idx)
    local area = self.area_list[idx]
    if not area then
        return
    end
    local model = area.model
    if not model then
        return
    end
    local door = model:FindFirstChild('door')
    if not door then
        return
    end
    door.CanCollide = true
end

function c:OpenDoor(idx)
    local area = self.area_list[idx]
    if not area then
        return
    end
    local model = area.model
    if not model then
        return
    end
    local door = model:FindFirstChild('door')
    if not door then
        return
    end
    door.CanCollide = false
end

function c:DelModel(idx)
    if idx < 4 then
        return
    end

    local area = self.area_list[idx]
    if not area then
        return
    end
    area.model:Destroy()
    self.area_list[idx] = nil
end

---@param player Server_Player
function c:PlayerIn(player)
    self.player = player
    self.guid_to_player[player.guid] = player

    player.sync_cmp:AddHandle('challenge_in_area',self,self.InArea)
    player.sync_cmp:AddHandle('attackChallengeMonster',self,self.PlayerAtkMonster)
    player.sync_cmp:AddHandle('challenge_player_skill_monster',self,self.PlayerSkill)

    player.challenge_stage_obj = self

    local maxPassNum = player.challenge_cmp:GetMaxPassNum()
    local num = math.floor(maxPassNum / 10) * 10
    if num > 0 then
        local model1 = stagelist:FindFirstChild('1')
        local model2 = stagelist:FindFirstChild('2')
        local model3 = stagelist:FindFirstChild('3')
        model1.Name = num
        model2.Name = num + 1
        model3.Name = num + 2
    end
    self:LoadBase()
end

function c:InArea(info)
    local name = info.name
    local idx = tonumber(name)
    if not idx then
        return
    end
    self:LoadArea(idx + 2)
    self:CloseDoor(idx - 1)
end

function c:LoadMonster(idx)
    local area = self.area_list[idx]
    if not area then
        return
    end
    local model = area.model
    if not model then
        return
    end
    local monster = model:FindFirstChild('monster')
    if not monster then
        return
    end
    local monsterPos = model:FindFirstChild('monsterPos')
    if not monsterPos then
        return
    end
    for k,part in ipairs(monsterPos:GetChildren())do
        local cfg = challengeCfg[idx]
        local model,name,cfg2
        if part.Name == 'boss' then
            local i = math.random(1,#bossCfg)
            cfg2 = bossCfg[i]
            model = bossCfg[i].model
            name = bossCfg[i].name
        else
            local i = math.random(1,#normalCfg)
            model = normalCfg[i].model
            name = normalCfg[i].name
            cfg2 = normalCfg[i]
        end
        model = monsterFol:FindFirstChild(model)
        model = hotpot:CloneInst_Loop(model)
        model.Parent = monster
        if part.Name ~= 'boss' then
            model:ScaleTo(2)
        end
        
        local obj = monsterObj.new(model,self,cfg,part,idx,cfg2)
        self.guid_to_monster[obj.guid] = obj
        self.area_monster[idx] = self.area_monster[idx] or {}
        self.area_monster[idx][obj.guid] = true
    end
end

--怪物攻击玩家
function c:MonsterAttackPlayer(monster_guid,players,dmg)
    for player_guid,_ in pairs(players)do
        local r,e = pcall(function()
            local player = self.guid_to_player[player_guid]
            if not player then
                return
            end
            ---@type Server_PlayerCharacter
            local character = player.character
            if not (character and character.IsExist and character:IsExist()) then
                return
            end
            character:BeDamage(monster_guid,dmg)
            hotpot.event_manager:FireAll('play_dmg',{
                pos = character:GetPosition(),
                dmg = dmg,
            })
        end)
        if not r then
            warn(e)
        end
    end
end

function c:PlayerAtkMonster(info)
    for _,collider in ipairs(info.list)do
        local guid = collider:GetAttribute('guid')
        if guid then
            ---@type Server_ChallengeMonsterObj
            local monster = self.guid_to_monster[guid]
            if monster then
                if not monster.is_die then
                    local atk = self.player.prop_cmp:GetAttack()
                    monster:BeDamage(nil,atk)
                    pcall(function()
                        hotpot.event_manager:FireAll('play_dmg',{
                            pos = monster:GetPosition(),
                            dmg = atk,
                        })
                    end)
                end
            end
        end
    end
end

function c:PlayerSkill(info)
    local mguid = info.monster_guid
    local solt = info.slot
    local monster = self.guid_to_monster[mguid]
    if not monster then
        return
    end
    local skill_per = self.player.skill_cmp:GetSkillPer(solt)
    if not skill_per then
        return
    end
    local atk = self.player.prop_cmp:GetAttack()
    local dmg = atk * skill_per
    monster:BeDamage(nil,dmg)
    pcall(function()
        hotpot.event_manager:FireAll('play_dmg',{
            pos = monster:GetPosition(),
            dmg = dmg,
        })
    end)
end

---@param monster Server_ChallengeMonsterObj
function c:MonsterDie(monster)
    local guid = monster.guid
    local area_idx = monster.area_idx
    local is_boss = monster.is_boss
    --发奖励
    pcall(function()
        local can = self.player.challenge_cmp:CheckCanReward(area_idx)
        if can then
            local cfg = monster.cfg
            local monsterId = cfg.monster_id
            local mCfg = monsterCfg[monsterId]
            if not is_boss then
                if mCfg then
                    --金币
                    if math.random() <= 0.4 then
                        local wins = mCfg.wins
                        wins = wins * 0.33
                        self.player.reward_cmp:AddReward({{1,3,wins}})
                        self:AddRewardList(1,3,wins)
                    end
                    --钻石
                    local gems = mCfg.gems
                    local per = mCfg.per
                    if math.random(1,100) <= per then
                        self.player.reward_cmp:AddReward({{1,2,gems}})
                        self:AddRewardList(1,2,gems)
                    end
                end
            else
                if mCfg then
                    --金币
                    local wins = mCfg.wins * 2
                    self.player.reward_cmp:AddReward({{1,3,wins}})
                    self:AddRewardList(1,3,wins)
                    --钻石
                    local gems = mCfg.gems
                    local per = mCfg.per
                    if math.random(1,100) <= per then
                        self.player.reward_cmp:AddReward({{1,2,gems}})
                        self:AddRewardList(1,2,gems)
                    end
                    --药水
                    if math.random() <= 0.2 then
                        local bId = math.random(1,3)
                        self.player.reward_cmp:AddReward({{3,bId,1}})
                        self:AddRewardList(3,bId,1)
                    end
                    --锻造石
                    if area_idx <= 20 then
                        self.player.reward_cmp:AddReward({{11,1,2}})
                        self:AddRewardList(11,1,2)
                    else
                        self.player.reward_cmp:AddReward({{11,1,1}})
                        self:AddRewardList(11,1,1)
                        if math.random() <= 0.5 then
                            self.player.reward_cmp:AddReward({{11,2,1}})
                            self:AddRewardList(11,2,1)
                        end
                    end
                    if area_idx >= 30 then
                        if math.random() <= 0.1 then
                            self.player.reward_cmp:AddReward({{11,3,1}})
                            self:AddRewardList(11,3,1)
                        end
                    end
                    --幸运石
                    if area_idx >= 20 and area_idx < 40 then
                        if math.random() <= 0.05 then
                            self.player.reward_cmp:AddReward({{12,1,1}})
                            self:AddRewardList(12,1,1)
                        end
                    elseif area_idx >= 40 then
                        if math.random() <= 0.1 then
                            self.player.reward_cmp:AddReward({{12,2,1}})
                            self:AddRewardList(12,2,1)
                        end
                    end
                    --遗物
                    if area_idx <= 20 then
                        if math.random() <= 0.5 then
                            local rId = relics1[math.random(1,#relics1)]
                            self.player.reward_cmp:AddReward({{4,rId,1}})
                            self:AddRewardList(4,rId,1)
                        end
                    elseif area_idx <= 40 then
                        if math.random() <= 0.2 then
                            local rId = relics2[math.random(1,#relics2)]
                            self.player.reward_cmp:AddReward({{4,rId,1}})
                            self:AddRewardList(4,rId,1)
                        end
                    else
                        if math.random() <= 0.12 then
                            local rId = relics3[math.random(1,#relics3)]
                            self.player.reward_cmp:AddReward({{4,rId,1}})
                            self:AddRewardList(4,rId,1)
                        end
                    end
                end
            end
        end
    end)

    if self.guid_to_monster[guid] then
        self.guid_to_monster[guid] = nil
    end
    local area = self.area_monster[area_idx]
    if area and area[guid] then
        area[guid] = nil
    end
    -- self:AddProcess(self.CheckAllMonsterDie,area_idx)
    local r,e = pcall(function()
        self:CheckAllMonsterDie(area_idx)
    end)
    if not r then
        warn(e)
    end
end

function c:CheckAllMonsterDie(area_idx)
    local area = self.area_monster[area_idx]
    if not area then
        return
    end
    if not next(area) then
        self:OpenDoor(area_idx)
        self:AddProcess(self.PassStage,area_idx)
        return
    end


    self:AddProcess(function()
        self:Wait(5)
        local tab = self.area_list[area_idx]
        if tab then
            local model = tab.model
            if not model then
                return
            end
            local fol = model:FindFirstChild('monster')
            if fol then
                if #fol:GetChildren() == 0 then
                    self:OpenDoor(area_idx)
                    self:PassStage(area_idx)
                end
            end
        end
    end)
end

function c:AddRewardList(r1,r2,r3)
    -- if not next(self.reward_list) then
    --     table.insert(self.reward_list,{r1,r2,r3})
    --     return
    -- end
    -- for k,tab in ipairs(self.reward_list)do
    --     if tab[1] == r1 and tab[2] == r2 then
    --         tab[3] = tab[3] + r3
    --     else
    --         table.insert(self.reward_list,{r1,r2,r3})
    --     end
    -- end
end

function c:PassStage(area_idx)
    self.pass_num = area_idx
    self.player.challenge_cmp:PassStage(area_idx)

    hotpot.event_manager:FireAll('challenge_pass',self.pass_num)
end

return c