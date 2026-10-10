local hotpot = _G.ServerHotpot
---@type Server_GuildMonsterObj
local Server_GuildMonsterObj = hotpot.load.Server_GuildMonsterObj()
---@type Players
local Players = game:GetService('Players')
---@type InstanceManager
local InstanceManager = hotpot.load.InstanceManager()
local Debris = game:GetService('Debris')
---@type BigNumberHelper
local bignumber = hotpot.load.BigNumberHelper()

local eff = hotpot:GetPath_Loop('pfb.PumpkinEff',hotpot.Resource)
local monsterCfg = hotpot.config.monster
local monsterIds = {8,15,22,29,36,43,50,57,64,71}
local monsterFol = hotpot:GetPath_Loop('monster',hotpot.Resource)
local stageMonsterFol = workspace:WaitForChild('Stage'):WaitForChild('monster')
local STARTTIME = 1767139200
local ExpTree = workspace:WaitForChild('ExpTree')

---@class Server_GuildStageObj:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new()
    return c()
end
function c:ctor()
    c.super.ctor(self)

    self.player_list = {}

    self.BossArea = workspace:WaitForChild('BossArea')
    self.pk_cd_ui = hotpot:GetPath_Loop('Stage.pk.Part.StartUi.txt',workspace)
    self.pk1_color = hotpot:GetPath_Loop('Stage.pk.c1.color',workspace)
    self.pk2_color = hotpot:GetPath_Loop('Stage.pk.c2.color',workspace)

    self.tree_ui = hotpot:GetPath_Loop('Stage.NPC.tree.HumanoidRootPart.cd.info',workspace)
    self.boss_ui = hotpot:GetPath_Loop('Stage.NPC.boss.HumanoidRootPart.cd.info',workspace)

    self:InitRank()
end

function c:InitRank()
    local pkRig = hotpot:GetPath_Loop('SenceModel.Rank.Rigs.pk',workspace)
    self:AddProcess(function()
        local time = 60
        while true do
            if pkRig:GetAttribute('uid') then
                break
            end
            time = time - 1
            if time <= 0 then
                break
            end
            self:Wait(1)
        end
        local uid = pkRig:GetAttribute('uid')
        uid = tonumber(uid)
        ---@type RankRig
        local obj = hotpot.load.RankRig().new()
        obj:SetRig(uid,pkRig)
    end)

    local contributeRig = hotpot:GetPath_Loop('SenceModel.Rank.Rigs.contribute',workspace)
    self:AddProcess(function()
        local time = 60
        while true do
            if contributeRig:GetAttribute('uid') then
                break
            end
            time = time - 1
            if time <= 0 then
                break
            end
            self:Wait(1)
        end
        local uid = contributeRig:GetAttribute('uid')
        uid = tonumber(uid)
        ---@type RankRig
        local obj = hotpot.load.RankRig().new()
        obj:SetRig(uid,contributeRig)
    end)
end

function c:StartCreateBoss()
    if self.__create_boss then
        return
    end
    self.__create_boss = true
    self.boss_idx = 1
    self:CreateBoss(monsterIds[self.boss_idx])
end

function c:OverBoss()
    if not self.nowBoss then
        return
    end
    self.__create_boss = false
    self.nowBoss:dtor()
    self.BossArea:SetAttribute('bossHp',0)
    self.BossArea:SetAttribute('bossAlive',false)
    self.BossArea:SetAttribute('nowBossId',0)
    self.BossArea:SetAttribute('bossMaxHp',0)
    self.nowBoss = nil
end

function c:CreateBoss(id)
    local cfg = monsterCfg[id]
    local model = cfg.model
    model = monsterFol:FindFirstChild(model)
    model = hotpot:CloneInst_Loop(model)
    local obj = Server_GuildMonsterObj.new(model,cfg,self.BossArea,self)
    model.Parent = stageMonsterFol
    self.nowBoss = obj
    obj.idx = self.boss_idx
    obj:LoadAnimation()
    local eff_model = hotpot:CloneInst_Loop(eff)
    eff_model.Parent = workspace
    eff_model:SetPrimaryPartCFrame(self.BossArea.CFrame)
    
    Debris:AddItem(eff_model,10)

    hotpot.event_manager:FireAll('updateGuildBossHp',{
        hp = obj.hp,
        max_hp = obj.max_hp,
        idx = obj.idx,
        id = obj.cfg.id,
    })
end

---@param player Server_Player
function c:PlayerIn(player)
    self.player_list[player] = true
    player.sync_cmp:AddHandle('attackGuildMonster',self,function(_,info)
        if not self.nowBoss then
            return
        end
        if self.nowBoss.is_die then
            return
        end
        local root = info.root
        if not root then
            return
        end
        if root ~= self.nowBoss.collider then
            return
        end

        self:PlayerAttackBoss(player)
    end)

    spawn(function()
        if not self.guildInfo then
            self.guildInfo = player.guild_cmp:GetGuildInfo()

            if not self.guildInfo then
                return
            end
            self.guild_id = self.guildInfo.guild_id

            self.guildInfo.last_boss_time = self.guildInfo.last_boss_time or 0
            self.guildInfo.last_tree_time = self.guildInfo.last_tree_time or 0

            self.next_boss_time = self.guildInfo.last_boss_time + 3600 * 72
            self.next_tree_time = self.guildInfo.last_tree_time + 3600 * 12

            self:StartUpdateBossCD()
            self:StartUpdateTreeCD()
        end
    end)
end

function c:PlayerOut(player)
    self.player_list[player] = nil
end

function c:RefreshCD()
    spawn(function()
        wait(5)
        ---@type GameServer
        local server = _G.server
        ---@type GuildManager
        local guild_manager = server.guild_manager

        local info = guild_manager:SearchGuildByGuildId(self.guild_id)
        if not info then
            return
        end
        self.guildInfo = info
        self.guildInfo.last_boss_time = self.guildInfo.last_boss_time or 0
        self.guildInfo.last_tree_time = self.guildInfo.last_tree_time or 0

        self.next_boss_time = self.guildInfo.last_boss_time + 3600 * 72
        self.next_tree_time = self.guildInfo.last_tree_time + 3600 * 12

        self:StartUpdateBossCD()
        self:StartUpdateTreeCD()
    end)
end

function c:StartUpdateTreeCD()
    if self.__tree_cd then
        return
    end
    self.__tree_cd = self:AddUpdate(self.UpdateTreeCD,1)
end

function c:StopUpdateTreeCD()
    if self.__tree_cd then
        self.__tree_cd:Disconnect()
        self.__tree_cd = nil
    end
end

function c:StartUpdateBossCD()
    if self.__boss_cd then
        return
    end
    self.__boss_cd = self:AddUpdate(self.UpdateBossCD,1)
end

function c:StopUpdateBossCD()
    if self.__boss_cd then
        self.__boss_cd:Disconnect()
        self.__boss_cd = nil
    end
end

function c:UpdateTreeCD()
    if not self.next_tree_time then
        return
    end
    local now = os.time()
    if now >= self.next_tree_time then
        self.tree_ui.Text = 'Can be opened'
        self.tree_ui.TextColor3 = Color3.new(0,1,0)
        self:StopUpdateTreeCD()
        return
    end
    self.tree_ui.Text = bignumber:TransformDateToString(self.next_tree_time - now)
    self.tree_ui.TextColor3 = Color3.new(1,1,1)
end

function c:UpdateBossCD()
    if not self.next_boss_time then
        return
    end
    local now = os.time()
    if now >= self.next_boss_time then
        self.boss_ui.Text = 'Can be opened'
        self.boss_ui.TextColor3 = Color3.new(0,1,0)
        self:StopUpdateBossCD()
        return
    end
    self.boss_ui.Text = bignumber:TransformDateToString(self.next_boss_time - now)
    self.boss_ui.TextColor3 = Color3.new(1,1,1)
end

---@param player Server_Player
function c:PlayerAttackBoss(player)
    local atk = player.prop_cmp:GetAttack()
    self.nowBoss:BeDamage(player,atk)
end

---@param bossobj Server_GuildMonsterObj
function c:BossDie(bossobj)
    local r,e = pcall(function()
        self.nowBoss = nil
        self.BossArea:SetAttribute('bossHp',0)
        self.BossArea:SetAttribute('bossAlive',false)
        self.BossArea:SetAttribute('nowBossId',0)
        self.BossArea:SetAttribute('bossMaxHp',0)
    
        local reward = hotpot.pro_cfg.guildBossReward[bossobj.idx]
        for player,dmg in pairs(bossobj.dmg_list)do
            for _,re in ipairs(reward)do
                local per = re.per
                local num = math.random()
                if num <= per then
                    player.reward_cmp:AddReward({re.reward})
                end
            end
        end
    end)
    if not r then
        error(e)
    end

    self:AddProcess(function()
        self:Wait(3)
        self.boss_idx = self.boss_idx + 1
        if self.boss_idx > #monsterIds then
            self:OverBoss()
            return
        end
        if os.time() < self.overBoss_time then
            self:CreateBoss(monsterIds[self.boss_idx])
        else
            self:OverBoss()
        end
    end)
end

function c:OpenTree(guild_id)
    if not ExpTree then
        return
    end
    local isOpen = ExpTree:FindFirstChild('IsOpen')
    local Time = ExpTree:FindFirstChild('Time')
    if not Time then
        return
    end
    if Time.Value > 0 then
        return
    end
    if isOpen then
        isOpen.Value = true
        
        self:AddProcess(function()
            local totalTime = 15*60
            while totalTime > 0 do
                self:Wait(1)
                totalTime = totalTime - 1
                hotpot.event_manager:FireAll('sendTreeTime',totalTime)
                Time.Value = totalTime
            end
            isOpen.Value = false
        end)

        hotpot.event_manager:FireAll('sendTreeTime',0)
        self:RefreshCD()
    end
end

function c:OpenBoss()
    self:StartCreateBoss()
    self.overBoss_time = os.time() + 3600 * 8

    self:RefreshCD()
end

---@param plr Server_Player
---@param part BasePart
function c:InPkArea(plr,part)
    if plr.pk_state then
        return false
    end
    if part.Name == 'pk1' then
        if self.pk1_player then
            return false
        end
        self.pk1_player = plr
        self.pk1_color.Color = Color3.fromRGB(0, 255, 255)
    end
    if part.Name == 'pk2' then
        if self.pk2_player then
            return false
        end
        self.pk2_player = plr
        self.pk2_color.Color = Color3.fromRGB(0, 255, 255)
    end
    self:CheckPK()
    return true
end

---@param plr Server_Player
---@param part BasePart
function c:OutPkArea(plr,part)
    if part.Name == 'pk1' then
        if self.pk1_player == plr then
            self.pk1_player = nil
            self.pk1_color.Color = Color3.fromRGB(188, 155, 93)
        end
    end
    if part.Name == 'pk2' then
        if self.pk2_player == plr then
            self.pk2_player = nil
            self.pk2_color.Color = Color3.fromRGB(188, 155, 93)
        end
    end
    return true
end

function c:CheckPK()
    if self.pk1_player and self.pk2_player then
        self:AddProcess(function()
            local t = 3
            while true do
                self:Wait(.1)
                t = t - 0.1
                if self.pk1_player and self.pk2_player then
                    self.pk_cd_ui.Text = string.format('PK start %.2f',t)
                else
                    self.pk_cd_ui.Text = ''
                    return true
                end
                if t <= 0 then
                    break
                end
            end

            self.pk_cd_ui.Text = ''
            --进入pk状态
            self:PlayerInPkState(self.pk1_player)
            self:PlayerInPkState(self.pk2_player)
            self.pk1_player.pk_player = self.pk2_player
            self.pk2_player.pk_player = self.pk1_player
            hotpot.event_manager:Fire(self.pk1_player,'openPKui',self.pk2_player.main_inst)
            hotpot.event_manager:Fire(self.pk2_player,'openPKui',self.pk1_player.main_inst)

            self:Wait(3)

            self.pk1_player = nil
            self.pk2_player = nil
            self.pk1_color.Color = Color3.fromRGB(188, 155, 93)
            self.pk2_color.Color = Color3.fromRGB(188, 155, 93)
        end)
    end
end

---@param player Server_Player
function c:PlayerInPkState(player)
    player.pk_state = true
    player.pk_stateValue.Value = true
    hotpot.event_manager:Fire(player,'pk_startTip',true)
    player.pk_co = player:AddProcess(function()
        local t = 60
        while t > 0 do
            self:Wait(1)
            t = t - 1
            hotpot.event_manager:Fire(player,'pkcd',t)
        end
        hotpot.event_manager:Fire(player,'pkcd',0)
        self:PlayerOutPkState(player)
    end)

    player.character:RefreshPKHP()
    player.character:SetWalkSpeed(player.prop_cmp:GetPKSpeed())
    player.character.hp_ui.Enabled = true
end

---@param player Server_Player
function c:PlayerOutPkState(player)
    player.pk_state = false
    player.pk_stateValue.Value = false
    if player.pk_co then
        player.pk_co:Disconnect()
        player.pk_co = nil
    end
    hotpot.event_manager:Fire(player,'outPkState')
    hotpot.event_manager:Fire(player,'pkcd',0)

    local ui = hotpot:GetPath_Loop('PlayerName.info.pk',player.character.root_part)
    ui.Visible = true
    ui.Visible = false

    player.character:SetWalkSpeed(player.prop_cmp:GetSpeed())
    player.character:RefreshHp()
end

function c:PlayerAtkPk(player,result)
    if not player.pk_state then
        return
    end
    for _,collider in ipairs(result)do
        local model = collider.Parent
        local p = Players:GetPlayerFromCharacter(model)
        if p then
            ---@type Server_Player
            local obj = InstanceManager:FindObject(p)
            if obj then
                if obj ~= player and player.pk_state then
                    obj.character:BeDamage(player.main_inst,player.prop_cmp:GetAttack())
                end
            end
        end
    end
end

---@param win Server_Player
---@param loss Server_Player
function c:PKWin(win,loss)
    self:AddProcess(function()
        win.guild_cmp:UpdatePKScore(10)
    end)
    self:AddProcess(function()
        loss.guild_cmp:UpdatePKScore(5)
    end)
    hotpot.event_manager:Fire(win,'pk_win',loss.main_inst)
    hotpot.event_manager:Fire(loss,'pk_lose',win.main_inst)
    self:AddProcess(function()
        self:Wait(1.2)
        hotpot.event_manager:Fire(win,'pkcd',0)
        hotpot.event_manager:Fire(loss,'pkcd',0)
    end)
end

hotpot.function_manager:SetHandle('InPkArea',function(player,part)
    ---@type GameServer
    local server = _G.server
    ---@type Server_GuildStageObj
    local stageObj = server.guild_stage_obj
    if not stageObj then
        return false
    end
    return stageObj:InPkArea(player,part)
end)

hotpot.function_manager:SetHandle('OutPkArea',function(player,part)
    ---@type GameServer
    local server = _G.server
    ---@type Server_GuildStageObj
    local stageObj = server.guild_stage_obj
    if not stageObj then
        return false
    end
    return stageObj:OutPkArea(player,part)
end)

hotpot.event_manager:RegistHandle('player_atk_pk',function(player,result)
    ---@type GameServer
    local server = _G.server
    ---@type Server_GuildStageObj
    local stageObj = server.guild_stage_obj
    if not stageObj then
        return false
    end
    stageObj:PlayerAtkPk(player,result)
end)

hotpot.event_manager:RegistHandle('pk_skill_dmg',function(player,info)
    if not player.pk_state then
        return
    end
    local list = info.list
    if not list then
        return
    end

    for _,collider in ipairs(list)do
        local model = collider.Parent
        local p = Players:GetPlayerFromCharacter(model)
        if p then
            ---@type Server_Player
            local obj = InstanceManager:FindObject(p)
            if obj then
                if obj ~= player and obj.pk_state then
                    local skillPer = player.skill_cmp:GetSkillPer(info.solt)
                    local atk = player.prop_cmp:GetAttack()
                    obj.character:BeDamage(player.main_inst,atk * skillPer)
                end
            end
        end
    end

end)

return c