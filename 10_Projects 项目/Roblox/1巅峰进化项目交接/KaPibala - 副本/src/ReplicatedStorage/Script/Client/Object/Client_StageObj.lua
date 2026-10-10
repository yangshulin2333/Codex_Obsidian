local hotpot = _G.ClientHotpot
---@type Client_MonsterObj
local monster_obj = hotpot.load.Client_MonsterObj()
---@type InstanceManager
local inst_manager = hotpot.load.InstanceManager()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type TweenHelper
local tween_helper = hotpot.load.TweenHelper()
---@type RayManager
local RayManager = hotpot.load.RayManager()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()
---@type Client_TranstionsAnimation
local TranstionsAnimation = hotpot.load.Client_TranstionsAnimation()
---@type CurveHelper
local CurveHelper = hotpot.load.CurveHelper()
local Debris = game:GetService('Debris')

local monster_fol = hotpot:GetPath_Loop('monster',_G.Resource)
local dmgUi = hotpot:GetPath_Loop('pfb.dmgUi',_G.Resource)
local monster_cfg = hotpot.config.monster
local christmasMonsterCfg = hotpot.config.ChristmasMonster
local gacha_cfg = hotpot.config.gacha
local pet_cfg = hotpot.config.pet
local gacha_ui = hotpot:GetPath_Loop('pfb.gachaUi',_G.Resource)
local upgrade_cfg = hotpot.config.upgrade
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)
local weatherFol = hotpot:GetPath_Loop('weather',_G.Resource)
local weatherCfg = hotpot.config.Weather
local ready_str = 'Ready!'
local DropFol = hotpot:GetPath_Loop('Drop',_G.Resource)

---@class Client_StageObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model,id,cmp)
    return c(model,id,cmp)
end
function c:ctor(model,id,cmp)
    c.super.ctor(self,model)

    self.id = id
    ---@type Client_StageComponent
    self.cmp = cmp

    self.delPetList = {}

    self:Init()
end

function c:dtor()
    if self.__fol_co then
        self.__fol_co:Disconnect()
        self.__fol_co = nil
    end
    if self.gacha_list then
        for k,v in pairs(self.gacha_list)do
            v.show_ui:Destroy()
        end
    end
    if self.rank_obj then
        for k,v in pairs(self.rank_obj)do
            k:dtor()
        end
    end
    if self.main_inst then
        self.main_inst:Destroy()
    end
    if self.monster_fol then
        self.monster_fol:ClearAllChildren()
    end
    if self.wind_co then
        self.wind_co:Disconnect()
    end
    c.super.dtor(self)
end

function c:Init()
    ---@type table<Client_Player,boolean>
    self.player_list = {}
    ---@type table<part,Client_MonsterObj>
    self.monster_list = {}
    ---@type table<number,Client_MonsterObj>
    self.guid_to_monster = {}

    self.monster_fol = self.main_inst:WaitForChild('monster')
    self.spawn_part = self.main_inst:WaitForChild('spawn')

    self:AddProcess(self.MountAnimation)
end

--加载功能区
---@param player Client_Player
function c:LoadFunction(player)
    local funFolder = self.main_inst:WaitForChild('Function')
    local Merge = funFolder:FindFirstChild('Merge')
    if Merge then
        RayManager:AddRayCast(
            Merge,
            player.pet_cmp,
            player.pet_cmp.PlayerInMerge,
            function()
                ui_manager.ui_list.merge_gui:Hide()
            end
        )
    end
    local Reborn = funFolder:FindFirstChild('Reborn')
    if Reborn then
        RayManager:AddRayCast(
            Reborn,
            player.prop_cmp,
            player.prop_cmp.PlayerInReborn,
            player.prop_cmp.PlayerOutReborn
        )
        self:SetRebornVisible(player)
        self.rebornPart = Reborn
    end

    if self.id ~= 'base' then
        local bossArea = self.main_inst:WaitForChild('bossArea')
        if bossArea then
            RayManager:AddRayCast(
                bossArea,
                self.cmp,
                self.cmp.InBossArea,
                self.cmp.OutBossArea
            )
        end
    end

    local ReliceBox = funFolder:FindFirstChild('ReliceBox')
    if ReliceBox then
        self.ReliceBox = ReliceBox
        RayManager:AddRayCast(
            ReliceBox,
            player.relics_cmp,
            player.relics_cmp.PlayerInReliceBox
        )
    end

    local FreeGems = funFolder:FindFirstChild('FreeGems')
    if FreeGems then
        self.FreeGems = FreeGems
        RayManager:AddRayCast(
            FreeGems,
            player.prop_cmp,
            player.prop_cmp.PlayerInFreeGems
        )
    end

    local shop = funFolder:FindFirstChild('shop')
    if shop then
        -- local people = shop:WaitForChild('People')
        -- local humanoid = people:WaitForChild('Humanoid')
        -- local anima = people:WaitForChild('Animation')
        -- humanoid:LoadAnimation(anima):Play()
        -- local Shirt = people:WaitForChild('Shirt')
        -- local Pants = people:WaitForChild('Pants')
        -- Shirt.ShirtTemplate = 'rbxassetid://6592971067'
        -- Pants.PantsTemplate = 'rbxassetid://5062455468'

        RayManager:AddRayCast(
            shop,
            ui_manager.ui_list.shop_gui,
            function()
                ui_manager.ui_list.shop_gui:Show()
                ui_manager.ui_list.hud_gui:Hide()
            end,
            function()
                ui_manager.ui_list.shop_gui:Hide()
            end
        )
    end

    local group = funFolder:FindFirstChild('group')
    if group then
        RayManager:AddRayCast(
            group,
            ui_manager.ui_list.free_pet_gui,
            function()
                ui_manager.ui_list.free_pet_gui:Show()
                ui_manager.ui_list.hud_gui:Hide()
            end,
            function()
                ui_manager.ui_list.free_pet_gui:Hide()
            end
        )
    end

    local Mapshop = funFolder:FindFirstChild('mapshop')
    if Mapshop then
        local people = Mapshop:WaitForChild('People')
        local Pants = people:WaitForChild('Pants')
        Pants.PantsTemplate = 'rbxassetid://6768152654'
        RayManager:AddRayCast(
            Mapshop,
            ui_manager.ui_list.map_shop_gui,
            function()
                ui_manager.ui_list.map_shop_gui:Show()
            end,
            function()
                ui_manager.ui_list.map_shop_gui:Hide()
            end
        )
    end

    local Potion = funFolder:FindFirstChild('Potion')
    if Potion then
        RayManager:AddRayCast(
            Potion,
            ui_manager.ui_list.buy_posion_gui,
            ui_manager.ui_list.buy_posion_gui.Show,
            ui_manager.ui_list.buy_posion_gui.Hide
        )
    end

    local mapScrollshop = funFolder:FindFirstChild('mapScrollshop')
    if mapScrollshop then
        RayManager:AddRayCast(
            mapScrollshop,
            ui_manager.ui_list.map_scroll_shop_gui,
            ui_manager.ui_list.map_scroll_shop_gui.Show,
            ui_manager.ui_list.map_scroll_shop_gui.Hide
        )
    end

    local relicsForge = funFolder:FindFirstChild('relicsForge')
    if relicsForge then
        RayManager:AddRayCast(
            relicsForge,
            ui_manager.ui_list.forge_relics_gui,
            ui_manager.ui_list.forge_relics_gui.Show,
            ui_manager.ui_list.forge_relics_gui.Hide
        )
    end

    local relicsSmelt = funFolder:FindFirstChild('relicsSmelt')
    if relicsSmelt then
        RayManager:AddRayCast(
            relicsSmelt,
            ui_manager.ui_list.relics_smelter_gui,
            ui_manager.ui_list.relics_smelter_gui.Show,
            ui_manager.ui_list.relics_smelter_gui.Hide
        )
    end

    local discord = funFolder:FindFirstChild('discord')
    if discord then
        RayManager:AddRayCast(
            discord,
            ui_manager.ui_list.join_discord_gui,
            ui_manager.ui_list.join_discord_gui.Show,
            ui_manager.ui_list.join_discord_gui.Hide
        )
    end

    local FreePotion = funFolder:FindFirstChild('FreePotion')
    if FreePotion then
        RayManager:AddRayCast(
            FreePotion,
            player.stage_cmp,
            player.stage_cmp.GetFreePotion
        )
        self.FreePotion = FreePotion
    end

    local christmas = funFolder:FindFirstChild('christmas')
    if christmas then
        RayManager:AddRayCast(
            christmas,
            player.stage_cmp,
            player.stage_cmp.TeleportChristmas
        )
        self.FreePotion = FreePotion
    end

    local challenge = funFolder:FindFirstChild('challenge')
    if challenge then
        RayManager:AddRayCast(
            challenge,
            player.stage_cmp,
            function()
                hotpot.event_manager:Fire('teleportChallenge')
            end
        )
    end

    local Windmill = self.main_inst:FindFirstChild('Windmill')
    if Windmill then
        if self.id == 'base' then
            local model = Windmill:WaitForChild('Model')
            self.wind_co = self:AddRenderProcess('render',function()
                while true do
                    model:PivotTo(model:GetPivot() * CFrame.fromEulerAnglesXYZ(0,0,0.01))
                    self:Wait()
                end
            end)
        else
            local rotate = hotpot:GetPath_Loop('Model.rotate',Windmill)
            self.wind_co = self:AddRenderProcess('render',function()
                while true do
                    rotate.CFrame = rotate.CFrame * CFrame.fromEulerAnglesXYZ(0,0,0.01)
                    self:Wait()
                end
            end)
        end
    end

    local party1 = funFolder:FindFirstChild('party1')
    if party1 then
        RayManager:AddRayCast(
            party1,
            self,
            function()
                if player.prop_cmp:GetLv() < 15 then
                    ui_manager.ui_list.tips_gui:TipsMessage('Not Enough Lv','fail')
                    return
                end
                local idx = party1:GetAttribute('idx')
                player.in_party_idx = idx
                ui_manager.ui_list.party_gui:Show()
            end,
            function()
                ui_manager.ui_list.party_gui:Hide()
                ui_manager.ui_list.party_gui:Close()
            end
        )
    end

    local party2 = funFolder:FindFirstChild('party2')
    if party2 then
        RayManager:AddRayCast(
            party2,
            self,
            function()
                if player.prop_cmp:GetLv() < 36 then
                    ui_manager.ui_list.tips_gui:TipsMessage('Not Enough Lv','fail')
                    return
                end
                local idx = party2:GetAttribute('idx')
                player.in_party_idx = idx
                ui_manager.ui_list.party_gui:Show()
            end,
            function()
                ui_manager.ui_list.party_gui:Hide()
                ui_manager.ui_list.party_gui:Close()
            end
        )
    end

    local party3 = funFolder:FindFirstChild('party3')
    if party3 then
        RayManager:AddRayCast(
            party3,
            self,
            function()
                if player.prop_cmp:GetLv() < 57 then
                    ui_manager.ui_list.tips_gui:TipsMessage('Not Enough Lv','fail')
                    return
                end
                local idx = party3:GetAttribute('idx')
                player.in_party_idx = idx
                ui_manager.ui_list.party_gui:Show()
            end,
            function()
                ui_manager.ui_list.party_gui:Hide()
                ui_manager.ui_list.party_gui:Close()
            end
        )
    end

    local party4 = funFolder:FindFirstChild('party4')
    if party4 then
        RayManager:AddRayCast(
            party4,
            self,
            function()
                if player.prop_cmp:GetLv() < 78 then
                    ui_manager.ui_list.tips_gui:TipsMessage('Not Enough Lv','fail')
                    return
                end
                local idx = party4:GetAttribute('idx')
                player.in_party_idx = idx
                ui_manager.ui_list.party_gui:Show()
            end,
            function()
                ui_manager.ui_list.party_gui:Hide()
                ui_manager.ui_list.party_gui:Close()
            end
        )
    end

    local forge = funFolder:FindFirstChild('forge')
    if forge then
        RayManager:AddRayCast(
            forge,
            ui_manager.ui_list.guild_forge_gui,
            ui_manager.ui_list.guild_forge_gui.Show,
            ui_manager.ui_list.guild_forge_gui.Hide
        )
    end

    local mount = funFolder:FindFirstChild('Mount')
    if mount then
        RayManager:AddRayCast(
            mount,
            ui_manager.ui_list.mount_gui,
            ui_manager.ui_list.mount_gui.Show,
            ui_manager.ui_list.mount_gui.Hide
        )
    end

    local skill = funFolder:FindFirstChild('skill')
    if skill then
        RayManager:AddRayCast(
            skill,
            self,
            function()
                local lv = player.prop_cmp:GetLv()
                if lv < 8 then
                    ui_manager.ui_list.tips_gui:TipsMessage('Not Enough Lv','fail')
                    return
                end
                ui_manager.ui_list.skill_gui:Show()
            end,
            function()
                ui_manager.ui_list.skill_gui:Hide()
            end
        )
    end

    local skillBox = funFolder:FindFirstChild('skillBox')
    if skillBox then
        RayManager:AddRayCast(
            skillBox,
            ui_manager.ui_list.open_skill_gui,
            function()
                ui_manager.ui_list.open_skill_gui:SetSureBgVisible(true)
                ui_manager.ui_list.open_skill_gui:Show()
                self.__in_skill_box = true
            end,
            function()
                ui_manager.ui_list.open_skill_gui:SetSureBgVisible(false)
                self.__in_skill_box = false
            end
        )
    end
end

function c:HideAllPet()
    local tempfol = game.ReplicatedStorage:FindFirstChild('OtherPlayerFol')
    local petFol = workspace:WaitForChild('PlayerPet')
    for k,v in ipairs(petFol:GetChildren())do
        v.Parent = tempfol
    end
    self.__fol_co = petFol.ChildAdded:Connect(function(child)
        if child:IsA('Folder') then
            child.Parent = tempfol
        end
    end)
end

---@param player Client_Player
function c:ResetPet(player)
    local setting = player.setting_pets
    local tempfol = game.ReplicatedStorage:FindFirstChild('OtherPlayerFol')
    local petFol = workspace:WaitForChild('PlayerPet')
    if tempfol then
        if setting then
            local fol = tempfol:FindFirstChild(player:GetName())
            if fol then
                fol.Parent = petFol
            end
        else
            for k,v in ipairs(tempfol:GetChildren())do
                v.Parent = petFol
            end
        end
    end
end

--加载圣诞功能区
---@param player Client_Player
function c:LoadChristmasArea(player)
    local funFolder = self.main_inst:WaitForChild('Function')
    local bossArea = self.main_inst:WaitForChild('bossArea')
    if bossArea then
        RayManager:AddRayCast(
            bossArea,
            self.cmp,
            self.cmp.InBossArea,
            self.cmp.OutBossArea
        )
    end

    local shop = funFolder:FindFirstChild('shop')
    if shop then
        RayManager:AddRayCast(
            shop,
            ui_manager.ui_list.shop_gui,
            function()
                ui_manager.ui_list.eternal_gui:Show()
                ui_manager.ui_list.eternal_gui:ClickTop(2)
            end,
            function()
                ui_manager.ui_list.eternal_gui:Hide()
            end
        )
    end

    local teleport = funFolder:FindFirstChild('teleport')
    if teleport then
        RayManager:AddRayCast(
            teleport,
            player.stage_cmp,
            function()
                player.stage_cmp:Teleport(1)
            end
        )
    end

    local skillBox = funFolder:FindFirstChild('skillBox')
    if skillBox then
        RayManager:AddRayCast(
            skillBox,
            ui_manager.ui_list.open_skill_gui,
            function()
                ui_manager.ui_list.open_skill_gui:SetSureBgVisible(true)
                ui_manager.ui_list.open_skill_gui:Show()
                self.__in_skill_box = true
            end,
            function()
                ui_manager.ui_list.open_skill_gui:SetSureBgVisible(false)
                self.__in_skill_box = false
            end
        )
    end

end

--设置免费倒计时
function c:SetFreePotionCD(num)
    local FreePotion = self.FreePotion
    if not FreePotion then
        return
    end
    if num > 0 then
        FreePotion.BillboardGui.cd.Text = big_number:TransformDateToString(num)
    else
        FreePotion.BillboardGui.cd.Text = ready_str
    end
end

--设置重生显示
---@param player Client_Player
function c:SetRebornVisible(player)
    local funFolder = self.main_inst:WaitForChild('Function') 
    local Reborn = funFolder:FindFirstChild('Reborn')
    if Reborn then
        local num = Reborn:GetAttribute('num')
        local rebornNum = player.prop_cmp:GetReborn()
        if rebornNum >= num then
            local paid = Reborn:FindFirstChild('Pad1')
            if paid then
                paid:Destroy()
            end
        end

        local model = Reborn:FindFirstChild('Model')
        if not model then
            return
        end
        local show = model:FindFirstChild('show')
        if not show then
            return
        end
        show.Color = rebornNum >= num and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(28, 137, 220)

        local s10 = Reborn:FindFirstChild('s10')
        if s10 then
            s10.Color = rebornNum >= num and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(75, 180, 131)
        end
    end
end

--设置免费宝石的领取显示
function c:SetFreeGemsGetVisible(vis)
    local FreeGems = self.FreeGems
    if not FreeGems then
        return
    end
    local ui = FreeGems:FindFirstChild('BillboardGui')
    if not ui then
        return
    end
    ui.canGet.Visible = vis
    ui.cd.Visible = not vis
end

--设置免费宝石的倒计时
function c:SetFreeGemsCD(num)
    local FreeGems = self.FreeGems
    if not FreeGems then
        return
    end
    local ui = FreeGems:FindFirstChild('BillboardGui')
    if not ui then
        return
    end
    ui.cd.TextLabel.Text = big_number:TransformDateToString(num)
end

--设置reliceBox的领取显示
function c:SetReliceBoxGetVisible(vis)
    local ReliceBox = self.ReliceBox
    if not ReliceBox then
        return
    end
    local ui = ReliceBox:FindFirstChild('BillboardGui')
    if not ui then
        return
    end
    ui.canGet.Visible = vis
    ui.cd.Visible = not vis
end

--设置reliceBox的倒计时
function c:SetReliceBoxCD(num)
    local ReliceBox = self.ReliceBox
    if not ReliceBox then
        return
    end
    local ui = ReliceBox:FindFirstChild('BillboardGui')
    if not ui then
        return
    end
    ui.cd.TextLabel.Text = big_number:TransformDateToString(num)
end

--加载扭蛋信息
---@param player Client_Player
function c:LoadGacha(player)
    self.gacha_list = {}
    local fol = self.main_inst:FindFirstChild('Gacha')
    if not fol then
        return
    end
    local collider = hotpot:GetPath_Loop('Gacha.collider',self.main_inst)
    local PlayerGui = player.main_inst:WaitForChild('PlayerGui')
    for _,part in ipairs(collider:GetChildren())do
        ---@type ProximityPrompt
        local ProximityPrompt = part:WaitForChild('ProximityPrompt')
        ProximityPrompt.UIOffset = Vector2.new(0,60)
        local id = tonumber(part.Name)
        local cfg = gacha_cfg[id]
        local ui = hotpot:CloneInst_Loop(gacha_ui)
        ui.Parent = PlayerGui
        ui.Adornee = part
        ui.Name = id

        local priceText = hotpot:GetPath_Loop('GuiAttachment.EggTitle.PriceLabel',part)
        priceText.Text = big_number:ToString(cfg.price)

        local total = 0
        for k,v in ipairs(cfg.weight)do
            total = total + v
        end

        for i,j in ipairs(cfg.pet_id)do
            local petC = pet_cfg[j]
            local item = hotpot:CloneInst_Loop(ui.Frame.list.item)
            item.Parent = ui.Frame.list
            item.Visible = true
            item.bg.Image = hotpot.pro_cfg.quality[petC.quality].board
            item.Name = j 
            item.bg.icon.Image = pet_cfg[j].icon
            item.bg.per.Text = string.format('%.2f%%',cfg.weight[i]/total*100)
            item.bg.btn.MouseButton1Click:Connect(function()
                local rebornValue = player.main_inst:FindFirstChild('reborn')
                if not rebornValue then
                    return
                end
                if rebornValue.Value < 4 then
                    return
                end
                if self.delPetList[j] then
                    self.delPetList[j] = nil
                    item.bg.del.Visible = false
                else
                    self.delPetList[j] = true
                    item.bg.del.Visible = true
                end
                hotpot.event_manager:Fire('changeGachaDelPet',self.delPetList)
            end)
            item.bg.del.Visible = self.delPetList[cfg.pet_id]

            local color = qualityColor:FindFirstChild(petC.quality)
            color:Clone().Parent = item.bg
            color:Clone().Parent = item.bg.UIStroke
        end

        RayManager:AddRayCast(part,self,self.InGacha,self.OutGacha)

        ProximityPrompt.Triggered:Connect(function()
            local price = cfg.price
            ui_manager.ui_list.gacha_gui:SetBtnPrice(price,price*3)
            ui_manager.ui_list.gacha_gui:SetIcon(cfg.icon)
            ui_manager.ui_list.gacha_gui:Show()
            ui_manager.ui_list.hud_gui:Hide()
            ui_manager.ui_list.gacha_gui:SetBGVisible(true)

            local tab = self.gacha_list[id]
            self:SetGachaUiVisible(id,false)
            local p = part:WaitForChild('ProximityPrompt')
            p.Enabled = false
        end)

        self.gacha_list[id] = {
            show_ui = ui,
            -- btn_ui = btn,
            player = player,
        }
    end

    local model = hotpot:GetPath_Loop('Gacha.model',self.main_inst)

    local info = TweenInfo.new(4,1,1,-1,true)

    for k,v in ipairs(model:GetChildren())do
        local part = v.PrimaryPart
        if part:GetAttribute('mul') then
            for a,b in ipairs(part:GetChildren())do
                if b:IsA('BasePart') then
                    tween_helper:PlayTween(
                        b,
                        info,
                        {Position = b.Position + Vector3.new(0,1.5,0)}
                    )
                end
            end
        end
        tween_helper:PlayTween(
            part,
            info,
            {Position = part.Position + Vector3.new(0,1.5,0)}
        )
    end

end

--加载升级信息
---@param player Client_Player
function c:LoadUpgrade(player)
    local data = player.save_data:GetData('upgrade')
    local fol = self.main_inst:FindFirstChild('Upgrade')
    if not fol then
        return
    end
    for _,part in ipairs(fol:GetChildren())do
        local id = tonumber(part.Name)
        local cfg = upgrade_cfg[id]
        local ui = part:WaitForChild('BillboardGui')
        ui.desc.Text = 'Increase '..cfg.name
        ui.price.Text = big_number:ToString(cfg.price)
        self:SetUpgradeOwned(id,data.list[id])
        RayManager:AddRayCast(part,self,function()
            player.upgrade_cmp:Unlock(id)
        end)
    end
end

--加载场景gamepass
---@param player Client_Player
function c:LoadStageGamepass(player)
    local fol = self.main_inst:FindFirstChild('gamepass')
    if not fol then
        return
    end
    for k,model in ipairs(fol:GetChildren())do
        local id = tonumber(model.Name)
        ---@type SurfaceGui
        local ui = hotpot:GetPath_Loop('001.SurfaceGui',model)
        local part = ui.Parent
        ui.Parent = player.main_inst:FindFirstChild('PlayerGui')
        ui.Adornee = part
        ui.Frame.Buy.MouseButton1Click:Connect(function()
            player.shop_cmp:ClickGamepass(id)
        end)
    end
end

--设置升级的拥有显示
function c:SetUpgradeOwned(id,bool)
    local part = self.main_inst:WaitForChild('Upgrade'):FindFirstChild(id)
    if not part then
        return
    end
    local ui = part:WaitForChild('BillboardGui')
    if bool then
        ui.owned.Visible = true
        ui.price.Visible = false
        for k,v in ipairs(part:GetDescendants())do
            if v.Name == 'change' then
                v.Color = Color3.fromRGB(182, 124, 69)
            end
        end

        local model = part:FindFirstChildOfClass('Model')
        if model then
            local Pad1 = model:FindFirstChild('Pad1')
            if Pad1 then
                Pad1:Destroy()
            end
        end
    else
        ui.owned.Visible = false
        ui.price.Visible = true
    end
end

--播放升级特效
function c:PlayUpgradeEff(id)
    local fol = self.main_inst:FindFirstChild('Upgrade')
    if not fol then
        return
    end
    local part = fol:FindFirstChild(tostring(id))
    if not part then
        return
    end
    for k,v in ipairs(part:GetDescendants())do
        if v:IsA('ParticleEmitter') then
            local EmitCount = v:GetAttribute('EmitCount') or v.Rate
            local EmitDelay = v:GetAttribute('EmitDelay') or 0
            delay(EmitDelay,function()
                v:Emit(EmitCount)
            end)
        end
    end
end

--设置抽奖ui显示
function c:SetGachaUiVisible(egg_id,vis,reborn)
    local tab = self.gacha_list[egg_id]
    if not tab then
        return
    end
    tab.show_ui.Enabled = vis

    if reborn and reborn >= 4 then
        tab.show_ui.Frame.delTip.Visible = true
    else
        tab.show_ui.Frame.delTip.Visible = false
    end
end

--玩家踩扭蛋
function c:InGacha(part)
    local id = tonumber(part.Name)
    local tab = self.gacha_list[id]

    local reborn = tab.player.prop_cmp:GetReborn()
    self:SetGachaUiVisible(id,true,reborn)
    tab.player.gacha_cmp.now_gacha_id = id
    tab.player.gacha_cmp.now_part = part

    local ProximityPrompt = part:WaitForChild('ProximityPrompt')
    ProximityPrompt.Enabled = true
end

--退出蛋
function c:OutGacha(part)
    local id = tonumber(part.Name)
    local tab = self.gacha_list[id]
    self:SetGachaUiVisible(id,false)
    tab.player.gacha_cmp.now_gacha_id = nil
    tab.player.gacha_cmp.now_part = nil

    ui_manager.ui_list.gacha_gui:SetBGVisible(false)
    ui_manager.ui_list.gacha_gui:Hide()
    ui_manager.ui_list.hud_gui:Show()
    
    local ProximityPrompt = part:WaitForChild('ProximityPrompt')
    ProximityPrompt.Enabled = false
end

--加载怪物信息
function c:LoadMonster(data)
    -- local monsterPos = self.main_inst:WaitForChild('monsterPos')
    local monster_list = data.monster_list

    self:AddProcess(function()
        self:Wait()
        for _,tab in pairs(monster_list)do
            local part = tab.part
            -- local part = monsterPos:FindFirstChild(name)
            if tab.is_alive then
                local info = {
                    part = part,
                    guid = tab.guid,
                    max_hp = tab.max_hp,
                    hp = tab.hp,
                    stage = self,
                }
                local id = tonumber(part.Name)
                local cfg = nil
                if self.id == 'christmas' then
                    cfg = christmasMonsterCfg[id]
                else
                    cfg = monster_cfg[id]
                end
                local model = monster_fol:FindFirstChild(cfg.model)
                model = hotpot:CloneInst_Loop(model)
                local obj = monster_obj.new(model,info)
                if cfg.is_boss then
                    self.boss_obj = obj
                    ui_manager.ui_list.hud_gui:SetBossName(cfg.name)
                    ui_manager.ui_list.hud_gui:SetBossProgress(obj.hp,obj.max_hp)
                end
                self.monster_list[part] = obj
                self.guid_to_monster[tab.guid] = obj
                obj:LoadAnimation()
            end
        end
    end)
end

--加载传送门
---@param player Client_Player
function c:LoadTeleport(player)
    local fol = self.main_inst:FindFirstChild('teleport')
    for _,part in ipairs(fol:GetChildren())do

        if part.Name == 'base' then
            RayManager:AddRayCast(
                part,
                player.stage_cmp,
                function()
                    TranstionsAnimation:PlayTransitionsAnimation(1,function()
                        player.stage_cmp:LoadStage('base')
                    end)
                end
            )
        else
            local id = tonumber(part.Name)
    
            RayManager:AddRayCast(
                part,
                player.stage_cmp,
                function()
                    player.stage_cmp:Teleport(id)
                end
            )
        end

    end
end

--加载Rank()
function c:LoadRank()
    local list = {
        kill = 'kill',continuouslogin = 'continuous_login',
        partykill = 'party_kill',time = 'time',purchase = 'purchase'
    }

    local rank = self.main_inst:FindFirstChild('Rank')
    if rank then
        ---@type GameClient
        local client = _G.client

        ---@type Client_RankManager
        local rankManager = client.rank_manager

        self.rank_obj = {}

        for k,model in ipairs(rank:GetChildren())do
            ---@type Client_RankObj
            local obj = hotpot.load.Client_RankObj().new(model)
            self.rank_obj[obj] = true
            self:AddProcess(function()
                local name = model.Name
                local strName = list[name]
                repeat self:Wait(.3) until rankManager.rank_data[strName]

                obj:SetRank(rankManager.rank_data[strName])
            end)
        end
    end
end

--加载Rank()
function c:LoadChristmasRank()
    local rank = self.main_inst:FindFirstChild('Rank')
    if rank then
        ---@type GameClient
        local client = _G.client

        ---@type Client_RankManager
        local rankManager = client.rank_manager
        self.rank_obj = {}
        for k,model in ipairs(rank:GetChildren())do
            ---@type Client_RankObj
            local obj = hotpot.load.Client_RankObj().new(model)
            self.rank_obj[obj] = true
            self:AddProcess(function()
                repeat self:Wait(.3) until rankManager.rank_data[model.Name]
                obj:SetRank(rankManager.rank_data[model.Name])
            end)
        end
    end
end

--玩家进入
---@param player Client_Player
function c:PlayerIn(player)
    self.player_list[player] = true

    player.now_stage = self

    ---@type Server_PlayerCharacter
    local character = player.character

    local cf = self.spawn_part.CFrame

    character:SetCFrame(cf + Vector3.new(0,4,0))

    self:AddProcess(function()
        self:Wait(2)
        local lv = player.prop_cmp:GetLv()
        if lv >= 8 then
            self:SetSkillBoxEnabled(true)
        else
            self:SetSkillBoxEnabled(false)
        end
    end)
end

--玩家退出
---@param player Client_Player
function c:PlayerOut(player)
    self.player_list[player] = nil

    player.now_stage = nil
end

--玩家攻击
---@param player Client_Player
function c:PlayerAttack(root,player)
    if not root then
        return
    end

    if root:GetAttribute('Pumpkin') then
        player.sync_cmp:Add('player_attack_pumpkin',{
            collider = root,
        })
        return
    end

    if root:GetAttribute('WeatherMonster') then
        player.sync_cmp:Add('player_attack_weather',{
            collider = root,
        })
        return
    end

    local model = root.Parent

    if not model then
        return
    end

    ---@type Client_MonsterObj
    local obj = inst_manager:FindObject(model)
    if not obj then
        return
    end

    if not obj.die then
        pcall(function()
            audioManager:PlayGloble('hit')
        end)
    end

    player.sync_cmp:Add('player_attack_monster',{
        player_guid = player.guid,
        monster_guid = obj.guid,
        stage_id = self.id
    })
end

--玩家技能
function c:PlayerSkill(player,skill_id,slot,root)
    local model = root.Parent

    if not model then
        return
    end

    if root:GetAttribute('Pumpkin') then
        player.sync_cmp:Add('player_skill_monster',{
            player_guid = player.guid,
            stage_id = self.id,
            skill_id = skill_id,
            slot = slot,
            is_pumpkin = true,
        })
        return
    end

    if root:GetAttribute('WeatherMonster') then
        player.sync_cmp:Add('player_skill_monster',{
            player_guid = player.guid,
            stage_id = self.id,
            skill_id = skill_id,
            slot = slot,
            is_weather = true,
        })
        return
    end
    ---@type Client_MonsterObj
    local obj = inst_manager:FindObject(model)
    if not obj then
        return
    end
    player.sync_cmp:Add('player_skill_monster',{
        player_guid = player.guid,
        monster_guid = obj.guid,
        stage_id = self.id,
        skill_id = skill_id,
        slot = slot,
        root = root,
    })
end

--怪物受伤
function c:MonsterBeDamage(info)
    local monster_guid = info.monster_guid
    local obj = self.guid_to_monster[monster_guid]
    if not obj then
        return
    end
    local pos = obj:GetPosition()
    -- if info.owner then
    -- end
    self:PlayDmg(pos,info.dmg)
    if obj then
        obj:BeDamage(info.dmg)
        if obj.cfg.is_boss then
            ui_manager.ui_list.hud_gui:SetBossProgress(obj.hp,obj.max_hp)
        end
    end
end

--怪物恢复
function c:MonsterRecover(info)
    local monster_guid = info.guid
    local obj = self.guid_to_monster[monster_guid]
    if not obj then
        return
    end
    obj:Recover()
    if obj.cfg.is_boss then
        ui_manager.ui_list.hud_gui:SetBossProgress(obj.hp,obj.max_hp)
    end
end

--怪物死亡
function c:MonsterDie(info)
    local list = info.dmg_list
    self:AddProcess(function()
        self:Wait(.1)
        local monster_guid = info.monster_guid
        local obj = self.guid_to_monster[monster_guid]
        if obj then
            obj.die = true
            if obj.cfg.is_boss then
                ui_manager.ui_list.hud_gui:SetBossPanelVisible(false)
                self.boss_obj = nil
            end
            obj:PlayHpUi(0,obj.max_hp)
            self.guid_to_monster[monster_guid] = nil
            self.monster_list[obj.part] = nil
            obj:dtor()

            -- if list and list[self.cmp.parent.guid] then
            --     obj:ShowDieUi()
            -- else
            -- end
        end
        -- self:Wait(3)
        -- self.monster_list[obj.part] = nil
        -- self.guid_to_monster[monster_guid] = nil
        -- if obj and obj.IsExist and obj:IsExist() then
        --     obj:dtor()
        -- end
    end)
end

--怪物移动
function c:MonsterMove(info)
    local monster_guid = info.guid
    local obj = self.guid_to_monster[monster_guid]
    if not obj then
        return
    end
    local pos = info.pos
    obj:Move(pos)
end

--怪物复活
function c:MonsterReborn(info)
    -- local monsterPos = self.main_inst:WaitForChild('monsterPos')
    local part = info.part
    local data = {
        part = part,
        guid = info.monster_guid,
        max_hp = info.max_hp,
        hp = info.hp,
        stage = self,
    }
    ---@type Model
    local model = nil
    if info.weather_id then
        model = weatherCfg[info.weather_id].model
        model = weatherFol:FindFirstChild(model)
        model = hotpot:CloneInst_Loop(model)
        local size = monster_cfg[tonumber(part.Name)].size
        if size and size > 1 then
            model:ScaleTo(size)
        end
    else
        local cfg = nil
        if self.id == 'christmas' then
            cfg = christmasMonsterCfg[tonumber(part.Name)]
        else
            cfg = monster_cfg[tonumber(part.Name)]
        end
        model = cfg.model
        model = monster_fol:FindFirstChild(model)
        model = hotpot:CloneInst_Loop(model)
    end
    local obj = monster_obj.new(model,data)
    if obj.cfg.is_boss then
        self.boss_obj = obj
        ui_manager.ui_list.hud_gui:SetBossProgress(obj.hp,obj.max_hp)
    end
    if self.cmp.parent.in_boss_area and obj.cfg.is_boss then
        ui_manager.ui_list.hud_gui:SetBossPanelVisible(true)

    end
    self.monster_list[part] = obj
    self.guid_to_monster[info.monster_guid] = obj
    obj:LoadAnimation()
end

--播放伤害动画
function c:PlayDmg(pos,dmg)
    local part = hotpot:CloneInst_Loop(dmgUi)
    part.Position = pos
    part.Parent = workspace
    
    part.BillboardGui.info.Text = '-'.. big_number:ToString(dmg)
    part.BillboardGui.Size = UDim2.fromScale(0,0)

    tween_helper:PlayTween(
        part,
        TweenInfo.new(0.2),
        {Position = pos + Vector3.new(0,5,0)},
        function()
            wait(1)
            part:Destroy()
        end
    )
    tween_helper:PlayTween(
        part.BillboardGui,
        TweenInfo.new(0.2),
        {Size = UDim2.fromScale(4,1.3)}
    )
end

--怪物攻击玩家
function c:MonsterAttackPlayer(info)
    local monster = self.guid_to_monster[info.monster_guid]
    if not monster then
        return
    end
    monster:LookAtTarget(info.cha_pos)
    monster:Attack()
    self:PlayDmg(info.cha_pos,info.dmg)
end

--销毁怪物
function c:DestroyMonster(info)
    local monster_guid = info.monster_guid
    local obj = self.guid_to_monster[monster_guid]
    if obj then
        self.guid_to_monster[monster_guid] = nil
        -- self.monster_list[obj.part] = nil
        obj:dtor(true)
    end
end

--创建随机怪物
function c:CreateRandomMonster(info)
    local part = info.part
    local data = {
        part = part,
        guid = info.monster_guid,
        max_hp = info.max_hp,
        hp = info.hp,
        stage = self,
        weather_id = info.weather_id,
    }
    ---@type Model
    local model = nil
    if info.weather_id then
        model = weatherCfg[info.weather_id].model
        model = weatherFol:FindFirstChild(model)
        model = hotpot:CloneInst_Loop(model)
    else
        model = monster_cfg[tonumber(part.Name)].model
        model = monster_fol:FindFirstChild(model)
        model = hotpot:CloneInst_Loop(model)
    end
    local obj = monster_obj.new(model,data)
    if obj.cfg.is_boss then
        self.boss_obj = obj
        ui_manager.ui_list.hud_gui:SetBossProgress(obj.hp,obj.max_hp)
    end
    if self.cmp.parent.in_boss_area and obj.cfg.is_boss then
        ui_manager.ui_list.hud_gui:SetBossPanelVisible(true)
    end
    -- self.monster_list[part] = obj
    self.guid_to_monster[info.monster_guid] = obj
    obj:LoadAnimation()
end

function c:SetSkillBoxEnabled(enabled)
    local funFolder = self.main_inst:FindFirstChild('Function')
    if funFolder then
        local skillBox = funFolder:FindFirstChild('skillBox')
        if skillBox then
            if enabled then
                skillBox.Parent = funFolder
            else
                skillBox.Parent = nil
            end
        end
    end
end

function c:MountAnimation()
    local fol = self.main_inst:FindFirstChild('mount')
    if fol then
        for k,v in ipairs(fol:GetChildren()) do
            local idle = hotpot:GetPath_Loop('Mount.Animations.idle',v)
            local Animator = hotpot:GetPath_Loop('Mount.AnimationController.Animator',v)
            local track = Animator:LoadAnimation(idle)
            track:Play()
        end
    end

    local fol1 = self.main_inst:FindFirstChild('ForgeAnimation')
    if fol1 then
        local idle = hotpot:GetPath_Loop('forge.Animation',fol1)
        local Animator = hotpot:GetPath_Loop('forge.Humanoid.Animator',fol1)
        local track = Animator:LoadAnimation(idle)

        local idle1 = hotpot:GetPath_Loop('shop.Animation',fol1)
        local Animator1 = hotpot:GetPath_Loop('shop.Humanoid.Animator',fol1)
        local track1 = Animator1:LoadAnimation(idle1)

        local idle2 = hotpot:GetPath_Loop('mount.Animation',fol1)
        local Animator2 = hotpot:GetPath_Loop('mount.Humanoid.Animator',fol1)
        local track2 = Animator2:LoadAnimation(idle2)

        self:AddUpdate(function()
            track:Play()
            track1:Play()
            track2:Play()
        end,10)
    end
end

--掉落关卡遗物
---@param player Client_Player
function c:DropStageRelics(relics_id,guid,player)
    ---@type Client_MonsterObj
    local monster = self.guid_to_monster[guid]
    if not monster then
        return
    end

    local pos = monster:GetPosition()
    local bottom = monster:GetBottomPosition()

    local cfg = hotpot.config.relics[relics_id]
    if not cfg then
        return
    end
    local quality = cfg.quality
    if quality > 5 then
        quality = 5
    end
    local part = DropFol:FindFirstChild('relicsDrop'..quality)
    part = hotpot:CloneInst_Loop(part)
    part.Parent = workspace.Drop
    part.Anchored = true
    local img = hotpot:GetPath_Loop('a.Frame.ImageLabel',part)
    img.Image = cfg.icon
    part.Position = pos

    self:AddRenderProcess('render',function()
        local over = Vector3.new(
            pos.X + math.random(-10,10),
            bottom.Y + 2,
            pos.Z + math.random(-10,10)
        ) + Vector3.new(0,1,0)
        local center = (pos + over) / 2 + Vector3.new(0,7,0)

        local time_len = 1
        local interval = 0
        while true do
            interval = interval + self:Wait()
            interval = math.min(interval,time_len)
            part.Position = CurveHelper:BezierCurve(pos,center,over,interval / time_len)
            if interval >= time_len then
                break
            end
        end
        part.CanTouch = true

        part.Touched:Connect(function(p_)
            if p_ == player.collider then
                part:Destroy()
                hotpot.event_manager:Fire('touch_relics_drop',relics_id,guid)
            end
        end)

        Debris:AddItem(part,20)
    end)
end

---@param player Client_Player
hotpot.event_manager:RegistHandle('drop_stage_relics',function(player,relice_id,guid)
    local now_stage = player.now_stage 
    if not now_stage then
        return
    end
    now_stage:DropStageRelics(relice_id,guid,player)
end)

return c