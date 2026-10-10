local hotpot = _G.ServerHotpot
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local MAX = 15
local pet_fol = hotpot:GetPath_Loop('Pet',hotpot.Resource)
local pet_cfg = hotpot.config.pet
local AnimationFol = workspace:WaitForChild('Animation')
local BasePart = 'BasePart'
local run = 'run'
local idle = 'idle'
local PetGui = hotpot:GetPath_Loop('pfb.PetGui',hotpot.Resource)
local qualityColor = hotpot:GetPath_Loop('qualityColor',hotpot.Resource)

local starAdd = {[0]=1,[1]=1.15,[2]=1.3,[3]=1.5}

---@class Server_PetComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('pet')
    -- print(self.data.__real.list)
    self.att_list = {}
    self.fol = Instance.new('Folder',workspace.PlayerPet)
	self.fol.Name = self.parent:GetName()
    self.total_time = 0

    self.track_list = {}
    self.pet_list = {}
    for k,v in ipairs(self.fol:GetChildren())do
        local Humanoid = v:FindFirstChild('Humanoid')
        if Humanoid then
            local Animator = Humanoid:FindFirstChild('Animator')
            if Animator then
                local track = Animator:LoadAnimation(AnimationFol:FindFirstChild('RunAnim'))
                local idle = Animator:LoadAnimation(AnimationFol:FindFirstChild('Idle2'))

                self.track_list[v] = {
                    run = track,
                    idle = idle,
                }
            end
        end
    end
    self.fol.ChildAdded:Connect(function(v)
        local Humanoid = v:FindFirstChild('Humanoid')
        if Humanoid then
            local Animator = Humanoid:FindFirstChild('Animator')
            if Animator then
                local track = Animator:LoadAnimation(AnimationFol:FindFirstChild('RunAnim'))
                local idle = Animator:LoadAnimation(AnimationFol:FindFirstChild('Idle2'))
                self.track_list[v] = {
                    run = track,
                    idle = idle,
                }
            end
        end
    end)
    self.fol.ChildRemoved:Connect(function(v)
        self.track_list[v] = nil
    end)
    self:CheckSolt()

    -- self:AddProcess(function()
    --     self:Wait(10)
    --     for i = 283,297 do
    --         self:AddPet(i)
    --     end
    -- end)
end

function c:dtor()
    if self.fol then
        self.fol:Destroy()
    end
    c.super.dtor(self)
end

function c:Init()
    for inst_id,_ in pairs(self.data.__real.equiped)do
        self:CharacterEquipPet(inst_id)
    end
end

--检查slot
function c:CheckSolt()
    if self.data.__real.max_equip > MAX then
        self.parent.save_data:Execut(function()
            self.data.max_equip = MAX
        end)
        for k,v in pairs(self.data.__real.equiped)do
            self.data.equiped[k] = nil
        end
    end
end

--增加宠物
function c:AddPet(pet_id,star)
    star = star or 0
    local inst_id = self.data.__real.inst_id
	inst_id = inst_id + 1
	self.parent.save_data:Execut(function()
		self.data.list[inst_id] = {
			pet_id = pet_id,
			star = star,
		}
		self.data.inst_id = inst_id

        self.data.index[pet_id] = true
	end)

	self:Fire('add_pet',inst_id,pet_id,star)

	return true
end

--移除宠物
function c:DelPet(inst_id)
    local pet = self.data.__real.list[inst_id]
	if not pet then
		return false
	end

	self.parent.save_data:Execut(function()
		self.data.list[inst_id] = nil
	end)

    self:Fire('del_pet',inst_id)
	return true
end

--获取背包数量
function c:GetBagCapacity()
    local num = 0
    for k,v in pairs(self.data.__real.list)do
        num = num + 1
    end
    return num
end

--获取已装备的数量
function c:GetEquipedNum()
    local num = 0
    for k,v in pairs(self.data.__real.equiped)do
        num = num + 1
    end
    return num
end

--获取背包剩余容量
function c:GetBagRemain()
    return self.data.__real.max_capacity - self:GetBagCapacity()
end

--获取宠物加成
function c:GetPetPerWithInstId(inst_id)
    local tab = self.data.__real.list[inst_id]
    local val = pet_cfg[tab.pet_id].value
    return val
end

--创建att
function c:CreateAtt()
    if not self.parent.character then
        return
    end
	self.pet_part = self.pet_part or self.parent.character.pet_part
	local att = Instance.new('Attachment',self.pet_part)
	table.insert(self.att_list,att)
	local len = #self.att_list
	att.Name = len
	local dis = 10
	local angle = 15

	local part = self.pet_part

	local row = math.ceil(len / 3)

	local total_angle_list = {}

	for i = 1,row do
		local temp_angel = 0
		for j = 2,3 do
			local idx = (i - 1) * 3 + j
			if idx > len then
				break
			end
			temp_angel = (j - 1) * angle
		end
		total_angle_list[i] = temp_angel
	end
	for i = 1,row do
		local temp_dis = dis + (i - 1) * dis/2
		local total_angle = total_angle_list[i]
		local cf = self.pet_part.CFrame * CFrame.fromEulerAnglesXYZ(0,math.rad(-total_angle),0)
		for j = 1,3 do
			local idx = (i - 1) * 3 + j
			if idx > len then
				break
			end
			if j == 1 then
				self.att_list[idx].WorldCFrame = CFrame.new(part.Position - cf.LookVector * temp_dis,part.Position)
			else
				cf = cf * CFrame.fromEulerAnglesXYZ(0,math.rad(angle * 2),0)
				self.att_list[idx].WorldCFrame = CFrame.new(part.Position - cf.LookVector * temp_dis,part.Position)
			end
		end
	end

	return att
end

--移除att
function c:RemoveAtt(att)
	for k,v in ipairs(self.att_list)do
		if v == att then
			table.remove(self.att_list,k)
			att:Destroy()
			break
		end
	end
	local len = #self.att_list
	local part = self.pet_part

	local dis = 10
	local angle = 15
	local row = math.ceil(len / 3)

	local total_angle_list = {}

	for i = 1,row do
		local temp_angel = 0
		for j = 2,3 do
			local idx = (i - 1) * 3 + j
			if idx > len then
				break
			end
			temp_angel = (j - 1) * angle
		end
		total_angle_list[i] = temp_angel
	end
	for i = 1,row do
		local temp_dis = dis + (i - 1) * dis/2
		local total_angle = total_angle_list[i]
		local cf = self.pet_part.CFrame * CFrame.fromEulerAnglesXYZ(0,math.rad(-total_angle),0)
		for j = 1,3 do
			local idx = (i - 1) * 3 + j
			if idx > len then
				break
			end
			if j == 1 then
				self.att_list[idx].WorldCFrame = CFrame.new(part.Position + cf.LookVector * temp_dis,part.Position)
			else
				cf = cf * CFrame.fromEulerAnglesXYZ(0,math.rad(angle * 2),0)
				self.att_list[idx].WorldCFrame = CFrame.new(part.Position + cf.LookVector * temp_dis,part.Position)
			end
		end
	end
end

--玩家卸载宠物
function c:CharacterUnequipPet(inst_id)
    local tab = self.pet_list[inst_id]
    if not tab then
        return false
    end
    local att = tab.att
    self.pet_list[inst_id] = nil
    tab.model:Destroy()
    self:RemoveAtt(att)
end

--玩家装备宠物
function c:CharacterEquipPet(inst_id)
    if place_manager:GetIdByName('guildsence') == game.PlaceId then
        return 
    end
    if place_manager:GetIdByName('pvpsence') == game.PlaceId then
        return 
    end
    if place_manager:GetIdByName('challengesence') == game.PlaceId then
        return 
    end

    local pet_id = self.data.__real.list[inst_id].pet_id
    if not pet_id then
        return false
    end

    local star = self.data.__real.list[inst_id].star

    local name = pet_cfg[pet_id].model
    ---@type Model
    local pet = pet_fol:FindFirstChild(name)
    pet = hotpot:CloneInst_Loop(pet)

    if star > 0 then
        local eff = hotpot:GetPath_Loop('pfb.starEff'..star,hotpot.Resource)
        eff = eff:Clone()
        eff.Parent = pet
        eff.Position = pet.PrimaryPart.Position - Vector3.new(0,3,0)
        local we = Instance.new('WeldConstraint',eff)
        we.Part0 = eff
        we.Part1 = pet.PrimaryPart
    end

    pet:ScaleTo(pet:GetScale() / 1.5)
    pet.Parent = self.fol
    self:AddProcess(function()
        while true do
            self:Wait(0.5)
            if pet and pet.Parent then
	            pet.Parent = self.fol
	            if pet.Parent == self.fol then
	                return true
				end
			else
				return true
			end
        end
    end)
	pet:SetAttribute('inst_id',inst_id)

    self:AddProcess(function()
        local petGui = hotpot:CloneInst_Loop(PetGui)
        petGui.Parent = pet.PrimaryPart
        petGui.name.Text = pet_cfg[pet_id].name
        local quality = pet_cfg[pet_id].quality
        petGui.quality.Text = hotpot.pro_cfg.quality[quality].name

        local color = qualityColor:FindFirstChild(tostring(quality))
        color:Clone().Parent = petGui.quality
    end)


    local att = self:CreateAtt()
    if not att then
        return
    end
	pet:PivotTo(att.WorldCFrame + Vector3.new(0,3,0))

    local cf,size = pet:GetBoundingBox()
	local root = pet.PrimaryPart
	root.Anchored = true
	delay(0.3,function()
		root.Anchored = false
		for k,v in ipairs(pet:GetDescendants())do
			if v:IsA(BasePart) and not v:GetAttribute('ignore') then
				v.CollisionGroup = 'pet'
				v.CanCollide = true
				v.CanTouch = false
				v.CanQuery = false
				v:SetNetworkOwner(self.parent.main_inst)
			end
			if v:IsA('Humanoid') then
				v.WalkSpeed = 20
				v.DisplayDistanceType = 'None'
				v:SetStateEnabled('FallingDown',false)
				v:SetStateEnabled('Freefall',false)
				v:SetStateEnabled('Flying',false)
			end
            if v:IsA('Shirt') then
                if not v.ShirtTemplate or v.ShirtTemplate == '' then
                    v.ShirtTemplate = v:GetAttribute('res')
                end
            end
            if v:IsA('Pants') then
                if not v.PantsTemplate or v.PantsTemplate == '' then
                    v.PantsTemplate = v:GetAttribute('res')
                end
            end
		end
	end)
	local pet_att = Instance.new('Attachment',root)

    ---@type AlignOrientation
    local alignOrientation = Instance.new("AlignOrientation",root)
	alignOrientation.RigidityEnabled = false
	alignOrientation.Attachment0 = pet_att
    alignOrientation.Attachment1 = att

    local hi = Instance.new('Highlight',pet)
    hi.FillColor = Color3.new(0,0,0.5)
    hi.FillTransparency = 0.25
    hi.OutlineColor = Color3.new(1,1,1)
    hi.OutlineTransparency = 0
    hi.DepthMode = 'Occluded'

    hi.Parent = pet


    self.pet_list[inst_id] = {att = att,y = size.Y / 2,model = pet}
end

--装备
function c:Equip(inst_id)
    if not self.data.__real.list[inst_id] then
        return false
    end

    if self.data.__real.equiped[inst_id] then
        return false
    end

    local max = self.data.__real.max_equip
    local num = self:GetEquipedNum()
    if num == max then--满了就卸载一个
        -- un_id = next(self.data.__real.equiped)
        -- self:Unequip(un_id)
        return false
    end

    self.parent.save_data:Execut(function()
        self.data.equiped[inst_id] = true
    end)

    self:CharacterEquipPet(inst_id)

    self.parent.stats_cmp:SyncAttack()

    self.parent.relics_cmp:RefrehPower()

    return true
end

--卸下
function c:Unequip(inst_id)
    if not self.data.__real.list[inst_id] then
        return false
    end

    if not self.data.__real.equiped[inst_id] then
        return false
    end

    self.parent.save_data:Execut(function()
        self.data.equiped[inst_id] = nil
    end)
    self:CharacterUnequipPet(inst_id)
    self.parent.stats_cmp:SyncAttack()
    self.parent.relics_cmp:RefrehPower()
    return true
end

function c:Update(step)
    for _,att in ipairs(self.att_list)do
        att.Position = Vector3.new(
            att.Position.X,
            math.sin(os.clock() * 2) * 1,
            att.Position.Z
        )
    end

    self.total_time = self.total_time + step
    if self.total_time >= 0.5 then
        self.total_time = 0
        for _,tab in pairs(self.pet_list)do
            pcall(function()
                for k,v in ipairs(tab.model:GetDescendants())do
                    if v:IsA(BasePart) and not v:GetAttribute('ignore') then
                        v.CanCollide = false
                    end
                end
            end)
        end
    end

end

--获取最强宠物数值
function c:GetBestPetValue()
    local best_val = 0
    for inst_id,tab in pairs(self.data.__real.list)do
        local pet_id = tab.pet_id
        local val = pet_cfg[pet_id].value
        if val > best_val then
            best_val = val
        end
    end
    return best_val
end

--装备最好
function c:EquipBest(best)
    if not next(best) then
        return
    end
    --检查宠物是否存在
    for k,inst_id in pairs(best)do
        if not self.data.__real.list[inst_id] then
            return false
        end
    end

    for inst_id,_ in pairs(self.data.__real.equiped)do
        self:Unequip(inst_id)
    end

    -- wait()

    for _,inst_id in pairs(best)do
        self:Equip(inst_id,true)
    end

    return true
end

--卸载全部
function c:UnequipAll()
    for inst_id,_ in pairs(self.data.__real.equiped)do
        self:Unequip(inst_id)
    end
    return true
end

--删除宠物
function c:DelPetList(list)
    for k,v in pairs(list)do
        if not self.data.__real.list[k] then
            return false
        end
        if self.data.__real.equiped[k] then
            return false
        end
    end
    for k,v in pairs(list)do
        self:DelPet(k)
    end

    return true
end

--合成宠物
function c:MergePet(list)
    local num = 0
    local pet_id
    local star

    local inst_id = next(list)
    pet_id = self.data.__real.list[inst_id].pet_id
    star = self.data.__real.list[inst_id].star

    for k,v in pairs(list)do
        if not self.data.__real.list[k] then
            return false
        end

        if self.data.__real.equiped[k] then
            return false
        end

        if self.data.__real.list[k].star == 3 then
            return false
        end
        if self.data.__real.list[k].pet_id ~= pet_id then
            return false
        end
        if self.data.__real.list[k].star ~= star then
            return false
        end
        num = num + 1
    end
    if num ~= 3 then
        return false
    end

    for k,v in pairs(list)do
        self:DelPet(k)
    end

    self:AddPet(pet_id,star + 1)

    pcall(function()
        self.parent.title_cmp:AddPoint(4,1)
    end)

    return true
end

--增加宠物装备数量
function c:AddEquipedNum(num)
    self.parent.save_data:Execut(function()
        self.data.max_equip = self.data.max_equip + num
    end)

    self.parent.title_cmp:AddPoint(9,self.data.__real.max_equip)

    self:Fire('add_equip_num',num)
    return true
end

--增加宠物背包数量
function c:AddCapacityNum(num)
    self.parent.save_data:Execut(function()
        self.data.max_capacity = self.data.max_capacity + num
    end)
    self:Fire('add_capacity_num',num)
    return true
end

--获取已装备的攻击力
function c:GetAttack()
    local atk = 0
    for inst_id,_ in pairs(self.data.__real.equiped)do
        local tab = self.data.__real.list[inst_id]
        local pet_id = tab.pet_id
        if pet_cfg[pet_id].value_per then
            local best = self:GetBestPetValue()
            local val = best * pet_cfg[pet_id].value_per
            local star = tab.star
            val = val * starAdd[star]
            atk = atk + val
        else
            local val = pet_cfg[pet_id].value
            local star = tab.star
            val = val * starAdd[star]
            atk = atk + val
        end
    end
    return atk
end

--播放动画
function c:PlayAnimation(model,id)
    local tab = self.track_list[model]
    if tab then
        if id == run then
            if not tab.run.IsPlaying then
                tab.run:Play()
            end
            tab.idle:Stop()
        elseif id == idle then
            if not tab.idle.IsPlaying then
                tab.idle:Play()
            end
            tab.run:Stop()
        end
    end
end

c:RegistFunction('equip_best_pet',c.EquipBest)
c:RegistFunction('unequip_all_pet',c.UnequipAll)
c:RegistFunction('del_pet',c.DelPetList)
c:RegistFunction('unequip_pet',c.Unequip)
c:RegistFunction('equip_pet',c.Equip)
c:RegistFunction('merge_pet',c.MergePet)
c:RegistEvent('play_animation',c.PlayAnimation)


return c