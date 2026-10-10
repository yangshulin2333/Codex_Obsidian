local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()

local pet_cfg = hotpot.config.pet
local pet_fol = hotpot:GetPath_Loop('Pet',_G.Resource)
local starAdd = {[0]=1,[1]=1.15,[2]=1.3,[3]=1.5}
local petInterval = 3.5
local petIndex = 0
local play_animation = 'play_animation'
local run = 'run'
local idle = 'idle'

---@class Client_PetComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('pet')
    self.ui = ui_manager.ui_list.bag_gui
    self.ui:BindPetFrameTipsFrameMouseEnter(self,self.PetItemMouseEnter)
    self.ui:BindPetFrameEquipBestClick(self,self.ClickEquipBest)
    self.ui:BindPetFrameUnequipAllClick(self,self.ClickUnequipAll)
    self.ui:BindPetFrameCancelBtnClick(self,self.ClickCancelBtn)
    self.ui:BindPetFrameDelBtnClick(self,self.ClickDelBtn)
    self.ui:BindPetFrameItemClick(self,self.ClickItem)
    self.ui:BindPetFrameAddEquipBtnClickHandle(self,self.ClickBuyEquiped)
    self.ui:BindPetFrameAddCapacityBtnClickHandle(self,self.ClickBuyCapacity)

    ui_manager.ui_list.merge_gui:BindItemClickEvent(self,self.ClickMergeItem)
    ui_manager.ui_list.merge_gui:BindItemMouseEnterEvent(self,self.MergeItemMouseEnter)
    ui_manager.ui_list.merge_gui:BindResetBtnClickEvent(self,self.ClickResetBtn)
    ui_manager.ui_list.merge_gui:BindMergeBtnClickEvent(self,self.ClickMergeBtn)
    self.merge_list = {}
    self.track_list = {}

    self.fol = workspace:WaitForChild('PlayerPet'):WaitForChild(self.parent:GetName())

    self.cold = 0

    self:InitUi()
end

function c:InitUi()
    for inst_id,tab in pairs(self.data.list)do
        local name = pet_cfg[tab.pet_id].model
        local model = pet_fol:FindFirstChild(name)
        model = hotpot:CloneInst_Loop(model)
        self.ui:AddItemInPetFrame(
            inst_id,
            pet_cfg[tab.pet_id].icon,
            pet_cfg[tab.pet_id].quality,
            self:GetPetPerWithInstId(inst_id),
            tab.star
        )
        if tab.star < 3 then
            ui_manager.ui_list.merge_gui:AddItemInScroll(
                inst_id,
                pet_cfg[tab.pet_id].icon,
                pet_cfg[tab.pet_id].quality,
                self:GetPetPerWithInstId(inst_id),
                tab.star
            )
            ui_manager.ui_list.merge_gui:SetItemLayout(inst_id,-self:GetPetPerWithInstId(inst_id)*100)
        end

        self.ui:SetPetItemEquipVisible(inst_id,self.data.equiped[inst_id])
    end

    self:RefreshOrder()
    self:RefreshNum()

    self.del_list = {}
    self.att_list = {}

    self.ui:SetPetFrameCancelBtnVisible(false)
    self:AddUpdate(self.Update,0.05)

    local data = self.parent.save_data:GetData('pay').pay_list
    if data[26] and data[27] then
        self.ui:SetPetFrameAddEquipBtnVisible(false)
    end
end

--添加宠物
function c:AddPet(inst_id,pet_id,star)
    self.data.list[inst_id] = {
        pet_id = pet_id,
        star = star,
    }

    local name = pet_cfg[pet_id].model
    local model = pet_fol:FindFirstChild(name)
    model = hotpot:CloneInst_Loop(model)

    self.ui:AddItemInPetFrame(
        inst_id,
        pet_cfg[pet_id].icon,
        pet_cfg[pet_id].quality,
        self:GetPetPerWithInstId(inst_id),
        star
    )

    if star < 3 then
        ui_manager.ui_list.merge_gui:AddItemInScroll(
            inst_id,
            pet_cfg[pet_id].icon,
            pet_cfg[pet_id].quality,
            self:GetPetPerWithInstId(inst_id),
            star
        )
        ui_manager.ui_list.merge_gui:SetItemLayout(inst_id,-self:GetPetPerWithInstId(inst_id)*100)
    end

    self:RefreshOrder()
    self:RefreshNum()

    self:AddProcess(function()
        -- self:Wait(1)
        if self:GetEquipedNum() < self.data.max_equip then
            if os.clock() - self.cold < 0.1 then
                return
            end
            self.cold = os.clock()
            self:ClickEquipBest()
        end 
    end)
end

--删除宠物
function c:RemovePet(inst_id)
    self.data.list[inst_id] = nil
    self.ui:DelItemInPetFrame(inst_id)
    ui_manager.ui_list.merge_gui:DelItemInScroll(inst_id)

    self:RefreshOrder()
    self:RefreshNum()
end

--获取背包数量
function c:GetBagCapacity()
    local num = 0
    for k,v in pairs(self.data.list)do
        num = num + 1
    end
    return num
end

--获取背包剩余容量
function c:GetBagRemain()
    return self.data.max_capacity - self:GetBagCapacity()
end

--获取已装备的数量
function c:GetEquipedNum()
    local num = 0
    for k,v in pairs(self.data.equiped)do
        num = num + 1
    end
    return num
end

--获取宠物加成
function c:GetPetPerWithInstId(inst_id)
    local tab = self.data.list[inst_id]
    if not tab then
        return 0
    end
    local star = tab.star
    local val = pet_cfg[tab.pet_id].value
    local per = pet_cfg[tab.pet_id].value_per
    if per then
        return val * starAdd[star] * per
    else
        return val * starAdd[star]
    end

end

--增加宠物装备数量
function c:AddEquipedNum(num)
    self.data.max_equip = self.data.max_equip + num
    self:RefreshNum()
end

--增加宠物背包数量
function c:AddCapacityNum(num)
    self.data.max_capacity = self.data.max_capacity + num
    self:RefreshNum()
end

--刷新排序
function c:RefreshOrder()
    local normal_list = {}
    for inst_id,tab in pairs(self.data.list)do
        if not self.data.equiped[inst_id] then
            table.insert(normal_list,{
                inst_id = inst_id,
                value = self:GetPetPerWithInstId(inst_id),
                quality = pet_cfg[tab.pet_id].quality
            })
        end
    end
    table.sort(normal_list,function(a,b)
        if a.value == b.value then
            return a.quality > b.quality
        else
            return a.value > b.value
        end
    end)

    local equip_list = {}
    for inst_id,_ in pairs(self.data.equiped)do
        table.insert(equip_list,{
            inst_id = inst_id,
            value = self:GetPetPerWithInstId(inst_id),
            quality = pet_cfg[self.data.list[inst_id].pet_id].quality,
        })
    end
    table.sort(equip_list,function(a,b)
        if a.value == b.value then
            return a.quality > b.quality
        else
            return a.value > b.value
        end
    end)
    for k,v in ipairs(equip_list)do
        table.insert(normal_list,k,{inst_id = v.inst_id,value = v.value})
    end

    local order = 1
    for k,tab in ipairs(normal_list) do
        self.ui:SetPetItemLayout(tab.inst_id,order)
        order = order + 1
    end
end

--刷新数量
function c:RefreshNum()
    local equiped = self:GetEquipedNum()
    self.ui:SetPetFrameEquipNum(equiped,self.data.max_equip)
    local capacity = self:GetBagCapacity()
    self.ui:SetPetFrameCapacityNum(capacity,self.data.max_capacity)
end

--item鼠标进入
function c:PetItemMouseEnter(inst_id)
    local pet_id = self.data.list[inst_id].pet_id
    local cfg = pet_cfg[pet_id]

    if cfg.value_per then
        local best = self:GetBestPetValue()
        self.ui:SetPetFrameTipsFrame2Info(cfg.name,best * cfg.value_per,cfg.quality,cfg.value_per * 100)
        self.ui:SetPetFrameTipsFrame2Visible(true)
        self.ui:SetPetFrameTipsFrameVisible(false)
    else
        local value = self:GetPetPerWithInstId(inst_id)
        self.ui:SetPetFrameTipsFrameInfo(cfg.name,value,cfg.quality)
        self.ui:SetPetFrameTipsFrameVisible(true)
        self.ui:SetPetFrameTipsFrame2Visible(false)
    end
end

--获取最强宠物数值
function c:GetBestPetValue()
    local best_val = 0
    for inst_id,tab in pairs(self.data.list)do
        local pet_id = tab.pet_id
        local val = pet_cfg[pet_id].value
        if val > best_val then
            best_val = val
        end
    end
    return best_val
end

--更新
function c:Update()
    if not self.parent.character then
        return
    end

    petIndex = 0

    if not (self.parent.character and self.parent.character.IsExist and self.parent.character:IsExist()) then
        return
    end

    ---@type CFrame
    local centerCf = self.parent.character:GetCFrame()
    local speed = self.parent.character:GetWalkSpeed()
    local has_mount = self.parent.mount_cmp.mount

    for k,model in ipairs(self.fol:GetChildren())do
        petIndex = petIndex + 1
        local pos = centerCf.Position - centerCf.LookVector * petInterval * petIndex
        if has_mount then
            pos = pos + Vector3.new(0,-3,0)
        end
        local dis = (model:GetPivot().Position - pos).Magnitude
        if dis >= 100 then
            model:PivotTo(CFrame.new(pos + Vector3.new(0,3,0)))
        else
            local Humanoid = model:FindFirstChild('Humanoid')
            if Humanoid then
                Humanoid.WalkSpeed = speed - 0.2
                Humanoid:MoveTo(pos)
            end
        end
        -- print(dis)
        if dis <= 4 then
            self:Fire(play_animation,model,idle)
        else
            self:Fire(play_animation,model,run)
        end
    end
end

--点击装备最佳
function c:ClickEquipBest()
    local list = {}
    local max = self.data.max_equip
    for inst_id,tab in pairs(self.data.list)do
        local val = self:GetPetPerWithInstId(inst_id)
        table.insert(list,{
            inst_id = inst_id,
            value = val,
        })
    end
    table.sort(list,function(a,b)
        return a.value > b.value
    end)
    local best = {}
    for i = 1,max do
        if list[i] then
            -- best[list[i].inst_id] = true
            table.insert(best,list[i].inst_id)
        end
    end
    local re = self:Invoke('equip_best_pet',best)
    if re then
        for inst_id,_ in pairs(self.data.equiped)do
            self.ui:SetPetItemEquipVisible(inst_id,false)
        end
        self.data.equiped = {}
        for _,inst_id in pairs(best)do
            self.ui:SetPetItemEquipVisible(inst_id,true)
            self.data.equiped[inst_id] = true
        end
        self:RefreshOrder()
        self:RefreshNum()
        self:RefreshMerge()
    end
end

--点击卸载全部
function c:ClickUnequipAll()
    local re = self:Invoke('unequip_all_pet')
    if re then
        for inst_id,_ in pairs(self.data.equiped)do
            self.ui:SetPetItemEquipVisible(inst_id,false)
        end
        self.data.equiped = {}
        self:RefreshOrder()
        self:RefreshNum()
        self:RefreshMerge()
    end
end

--点击删除按钮
function c:ClickDelBtn()
    if self.del_state then--已经处于删除状态，再点击则为确认删除
        if not next(self.del_list)then
            self:ClickCancelBtn()
            return
        end
        local re = self:Invoke('del_pet',self.del_list)
        if re then
            self:ClickCancelBtn()
            self:RefreshNum()
        end
    else
        self.ui:SetPetFrameCancelBtnVisible(true)
        self.del_state = true
        self.ui:SetPetFrameEquipBestVisible(false)
        self.ui:SetPetFrameUnequipAllVisible(false)
    end
end

--点击取消按钮
function c:ClickCancelBtn()
    self.del_state = false
    self.ui:SetPetFrameCancelBtnVisible(false)
    self.ui:SetPetFrameEquipBestVisible(true)
    self.ui:SetPetFrameUnequipAllVisible(true)
    for inst_id,_ in pairs(self.del_list)do
        self.ui:SetPetItemDelVisible(inst_id,false)
    end
    self.del_list = {}
end

--点击item
function c:ClickItem(inst_id)
    if self.del_state then
        self:ClickItemInDelState(inst_id)
        return
    end
    if self.data.equiped[inst_id] then--已装备就卸载
        local re = self:Invoke('unequip_pet',inst_id)
        if re then
            self.data.equiped[inst_id] = nil
            self.ui:SetPetItemEquipVisible(inst_id,false)
            self:RefreshOrder()
            self:RefreshNum()
            self:RefreshMerge()
        end
    else--未装备就装备
        if self:GetEquipedNum() >= self.data.max_equip then
            ui_manager.ui_list.tips_gui:TipsMessage('Equiped Full!','fail')
            return
        end
        local re,un_id = self:Invoke('equip_pet',inst_id)
        if re then
            self.data.equiped[inst_id] = true
            self.ui:SetPetItemEquipVisible(inst_id,true)
            if un_id then
                self.data.equiped[un_id] = nil
                self.ui:SetPetItemEquipVisible(inst_id,false)
            end
            self:RefreshOrder()
            self:RefreshNum()
            self:RefreshMerge()
        end
    end
end

--删除状态下点击item
function c:ClickItemInDelState(inst_id)
    if self.del_list[inst_id] then
        self.del_list[inst_id] = nil
        self.ui:SetPetItemDelVisible(inst_id,false)
    else
        if self.data.equiped[inst_id] then
            return
        end
        self.del_list[inst_id] = true
        self.ui:SetPetItemDelVisible(inst_id,true)
    end
end

-----------------------------------------------------Merge
---玩家进入merge
function c:PlayerInMerge()
    self:RefreshMerge()
    ui_manager.ui_list.merge_gui:Show()
end

function c:RefreshMerge()
    for k,v in pairs(self.data.list)do
        if self.data.equiped[k] then--已装备不显示
            ui_manager.ui_list.merge_gui:SetItemVisible(k,false)
        else
            if v.star == 3 then--满星不显示
                ui_manager.ui_list.merge_gui:SetItemVisible(k,false)
            else
                ui_manager.ui_list.merge_gui:SetItemVisible(k,true)
            end
        end
    end
end

--鼠标进入mergeItem
function c:MergeItemMouseEnter(inst_id)
    local tab = self.data.list[inst_id]
    if not tab then
        return
    end
    local pet_id = tab.pet_id
    local cfg = pet_cfg[pet_id]
    ui_manager.ui_list.merge_gui:SetTipsFrameInfo(cfg.name,cfg.value)
    ui_manager.ui_list.merge_gui:SetTipsFrameVisible(true)
end

--点击MergeItem
function c:ClickMergeItem(inst_id)
    local tab = self.data.list[inst_id]
    if not tab then
        return
    end
    local pet_id = tab.pet_id
    local star = tab.star
    local num = 0
    for k,v in pairs(self.merge_list)do
        num = num + 1
    end
    if num == 3 then
        return
    end

    if self.merge_list[inst_id] then
        self.merge_list[inst_id] = nil
        ui_manager.ui_list.merge_gui:SetItemSelectVisible(inst_id,false)
        num = num - 1
    else
        self.merge_list[inst_id] = true
        ui_manager.ui_list.merge_gui:SetItemSelectVisible(inst_id,true)
        num = num + 1
    end

    if num == 0 then
        for k,v in pairs(self.data.list)do
            if not self.data.equiped[k] then
                ui_manager.ui_list.merge_gui:SetItemVisible(k,true)
            end
        end
    elseif num == 1 then
        for k,v in pairs(self.data.list)do
            if v.pet_id == pet_id and v.star == star then
                if not self.data.equiped[k] then
                    ui_manager.ui_list.merge_gui:SetItemVisible(k,true)
                end
            else
                ui_manager.ui_list.merge_gui:SetItemVisible(k,false)
            end
        end
    end

    local list = {}
    local name = 'Select a pet!'
    for k,v in pairs(self.merge_list)do
        local pet_id = self.data.list[k].pet_id
        table.insert(list,{
            icon = pet_cfg[pet_id].icon,
            star = self.data.list[k].star,
            quality = pet_cfg[pet_id].quality,
        })
        name = pet_cfg[pet_id].name
    end
    ui_manager.ui_list.merge_gui:SetRightPetInfo(list)
    ui_manager.ui_list.merge_gui:SetRightName(name)
end

--点击重置按钮
function c:ClickResetBtn()
    self.merge_list = {}
    for k,v in pairs(self.data.list)do
        ui_manager.ui_list.merge_gui:SetItemSelectVisible(k,false)
        if self.data.equiped[k] then--已装备不显示
            ui_manager.ui_list.merge_gui:SetItemVisible(k,false)
        else
            if v.star == 3 then--满星不显示
                ui_manager.ui_list.merge_gui:SetItemVisible(k,false)
            else
                ui_manager.ui_list.merge_gui:SetItemVisible(k,true)
            end
        end
    end
    ui_manager.ui_list.merge_gui:SetRightPetInfo({})
    ui_manager.ui_list.merge_gui:SetRightName('Select a pet!')
end

--点击合成按钮
function c:ClickMergeBtn()
    local num = 0
    local list = {}
    for k,v in pairs(self.merge_list)do
        num = num + 1
        list[k] = true
    end
    if num ~= 3 then
        ui_manager.ui_list.tips_gui:TipsMessage('Please select 3 pets!','fail')
        return
    end
    local re = self:Invoke('merge_pet',self.merge_list)
    if re then
        self:ClickResetBtn()
        ui_manager.ui_list.tips_gui:TipsMessage('Merge successfully!','success')
        self:RefreshMerge()
    end
end

--点击购买背包容量
function c:ClickBuyCapacity()
    local re = self:Invoke('buy_goods',62)
    if re then
        spawn(function()
            pcall(function()
                audioManager:PlayGloble('purchase1')
                audioManager:PlayGloble('purchase2')
                wait(0.6)
                audioManager:PlayGloble('purchase3')
            end)
        end)
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

--点击购买装备数量
function c:ClickBuyEquiped()
    local data = self.parent.save_data:GetData('pay').pay_list
    local cfg_id
    if not data[26] and not data[27] then
        cfg_id = 26
    end
    if data[26] and not data[27] then
        cfg_id = 27
    end
    if data[26] and data[27] then
        self.ui:SetPetFrameAddEquipBtnVisible(false)
        return
    end
    self.parent.shop_cmp:ClickGamepass(cfg_id)
end

c:RegistEvent('add_pet',c.AddPet)
c:RegistEvent('del_pet',c.RemovePet)
c:RegistEvent('add_equip_num',c.AddEquipedNum)
c:RegistEvent('add_capacity_num',c.AddCapacityNum)

return c