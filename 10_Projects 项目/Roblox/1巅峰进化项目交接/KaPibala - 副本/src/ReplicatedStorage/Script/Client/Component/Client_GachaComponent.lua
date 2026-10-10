local hotpot = _G.ClientHotpot
---@type TweenService
local TweenService = game:GetService("TweenService")
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type ParticleHelper
local ParticleHelper = hotpot.load.ParticleHelper()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()
local Debris = game:GetService("Debris")

local Easing = hotpot.load.EasingHelper()
local egg_fol = hotpot:GetPath_Loop('Egg',_G.Resource)
local pet_fol = hotpot:GetPath_Loop('Pet',_G.Resource)
local gacha_cfg = hotpot.config.gacha
local pet_cfg = hotpot.config.pet
local goods_cfg = hotpot.config.goods
local isRunning = false
local OpenEggQueue = {}
local BasePart = 'BasePart'
local Random_new_ret = Random.new()
local Confetti = hotpot:GetPath_Loop('pfb.Confetti',_G.Resource)
local EggOpenPetInfo = hotpot:GetPath_Loop('pfb.EggOpenPetInfo',_G.Resource)
local EggEffFol = hotpot:GetPath_Loop('EggEffect',_G.Resource)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class Client_GachaComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.pay_list = self.parent.save_data:GetData('pay').pay_list
    self.ui = ui_manager.ui_list.gacha_gui
    self.ui:BindBtnClickHandle(self,self.ClickEgg)
    self.ui:BindBgCloseBtnClickHandle(self,self.ClickBgCloseBtn)
    self.ui:BindBtn1ClickHandle(self,self.ClickE)
    self.ui:BindBtn3ClickHandle(self,self.ClickThree)
    self.ui:BindGamepassClickHandle(self,self.ClickBuyGamepass)
    self.ui:BindStopBtnClickHandle(self,self.ClickStopAutoBtn)

    self.click_egg_cold = 0
    self.click_mark = false
    self.stop_auto = false

    self.DepthOfField = game:GetService('Lighting'):WaitForChild('DepthOfField')

    self:InitUi()
end

local function ScaleParticle(p1,p2)
    for _, val1 in ipairs(typeof(p1) == "table" and p1 or {p1}) do
		local table1 = {};
		for _, val2 in ipairs(val1.Size.Keypoints) do
			table.insert(table1, NumberSequenceKeypoint.new(val2.Time, val2.Value * p2, val2.Envelope * p2));
		end
		val1.Size = NumberSequence.new(table1);
		val1.Drag = val1.Drag * p2;
		val1.VelocityInheritance = val1.VelocityInheritance * p2;
		val1.Speed = NumberRange.new(val1.Speed.Min * p2, val1.Speed.Max * p2);
		val1.Acceleration = Vector3.new(val1.Acceleration.X * p2, val1.Acceleration.Y * p2, val1.Acceleration.Z * p2);
		val1.ZOffset = val1.ZOffset * p2;
	end
end

function c:InitUi()
    self.ui:SetLuckyOwnedVisible(self.pay_list[56])
    self.ui:SetSuperLuckyOwnedVisible(self.pay_list[57])
    self.ui:SetAutoOwnedVisible(self.pay_list[54])
    self.ui:SetMultipleOwnedVisible(self.pay_list[55])

    self.ui:SetBtn3Visible(self.pay_list[55])
end

function c:GachaOne(egg_id,pet_id)
    if self.__playing then
        return
    end
    self:AddRenderProcess('render',function()
        self.__playing = true
        self.parent.now_stage:SetGachaUiVisible(egg_id,false)

        ---@type Model
        local petModel = pet_cfg[pet_id].model
        petModel = pet_fol:FindFirstChild(petModel)
        petModel = hotpot:CloneInst_Loop(petModel)

        self.DepthOfField.Enabled = true
        ---@type Model
        local egg = egg_fol:FindFirstChild(tostring(egg_id))
        egg = hotpot:CloneInst_Loop(egg)
        local camera_cf = workspace.Camera.CFrame
        workspace.Camera.CameraType = Enum.CameraType.Scriptable
        egg.Parent = workspace

        self.egg_rotate = self:AddRenderUpdate('render',function()
            egg:PivotTo(egg:GetPivot() * CFrame.Angles(0,0.01,0))
        end)

        local start_cf = camera_cf + camera_cf.LookVector * 5 - camera_cf.UpVector * 10
        local end_cf = camera_cf + camera_cf.LookVector * 5
        local cf

        local time_len = 0.2
        local interval = 0
        while true do
            interval = math.min(time_len,interval + self:Wait())
            cf = start_cf:Lerp(end_cf,TweenService:GetValue(interval / time_len,2,1))
            egg:PivotTo(cf)

            if interval >= time_len then
                break
            end
        end

        local left = 1
        local function Click()
            start_cf = end_cf
            end_cf = start_cf + camera_cf.LookVector * 4
            end_cf = end_cf * CFrame.Angles(0,0,math.rad(60) * left)
            interval = 0
            time_len = 0.05
            while true do
                interval = math.min(time_len,interval + self:Wait())
                cf = start_cf:Lerp(end_cf,TweenService:GetValue(interval / time_len,1,1))
                egg:PivotTo(cf)
    
                if interval >= time_len then
                    break
                end
            end
            start_cf = end_cf
            end_cf = start_cf - camera_cf.LookVector * 4
            end_cf = end_cf * CFrame.Angles(0,0,-math.rad(60) * left)
            interval = 0
            time_len = 0.25
            while true do
                interval = math.min(time_len,interval + self:Wait())
                cf = start_cf:Lerp(end_cf,TweenService:GetValue(interval / time_len,6,1))
                egg:PivotTo(cf)
    
                if interval >= time_len then
                    break
                end
            end

            left = -left
        end
        self.click_mark = false
        local count = 3
        while true do
            self:Wait()
            if self.click_mark then
                self.click_mark = false
                Click()
                count = count - 1
                if count == 0 then
                    break
                end
            end
        end
        -- print('done')
        self.egg_rotate:Disconnect()
        egg:Destroy()

        interval = 0
        time_len = 0.2
        self.ui.insts.Frame.Transparency = 0
        while true do
            interval = math.min(time_len,interval + self:Wait())
            self.ui.insts.Frame.Transparency = interval / time_len
            if interval >= time_len then
                break
            end
        end

        start_cf = camera_cf + camera_cf.LookVector * 5
        petModel.PrimaryPart.Anchored = true
        petModel.Parent = workspace.CurrentCamera
        petModel:ScaleTo(0.01)
        petModel:PivotTo(CFrame.new(start_cf.Position,workspace.CurrentCamera.CFrame.Position))
        start_cf = petModel:GetPivot()

        interval = 0
        time_len = 0.5
        local val = 0
        local angle = 0
        while true do
            interval = math.min(time_len,interval + self:Wait())
            val = TweenService:GetValue(interval / time_len,2,1)
            angle = interval / time_len * 360
            petModel:PivotTo(start_cf * CFrame.Angles(0,math.rad(angle),0))
            petModel:ScaleTo(val*0.2)
            if interval >= time_len then
                break
            end
        end

        local over_cf = petModel:GetPivot() + Vector3.new(0,-10,0)

        self:Wait(1)
        interval = 0
        time_len = 0.3
        while true do
            interval = math.min(time_len,interval + self:Wait())
            
            val = TweenService:GetValue(interval / time_len,2,1)
            petModel:PivotTo(start_cf:Lerp(over_cf,val))
            if interval >= time_len then
                break
            end
        end

        petModel:Destroy()

        self.DepthOfField.Enabled = false
        -- workspace.Camera.CameraType = Enum.CameraType.Custom
        -- self.parent.now_stage:SetGachaUiVisible(egg_id,true)
        self.ui:SetBGVisible(true)

        self.__playing = false
    end)
end

function c:ClickBgCloseBtn()
    self.ui:SetBGVisible(false)
    self.parent.character.root_part.Anchored = false
    ui_manager.ui_list.hud_gui:Show()
    self.ui:Hide()
    self.ui:SetStopBtnVisible(false)
    if self.now_part then
        self.parent.now_stage:InGacha(self.now_part)
    end
end

--点击ui
function c:ClickEgg()
    if os.clock() - self.click_egg_cold < 0.33 then
        return
    end
    self.click_egg_cold = os.clock()
    self.click_mark = true

end

--点击单抽
function c:ClickE()
    self.stop_auto = false
    self.ui:SetStopBtnVisible(self.pay_list[54])
    while true do
        if not self.now_gacha_id then
            return
        end
        if self.__playing then
            return 
        end
        if self.parent.pet_cmp:GetBagRemain() < 1 then
            ui_manager.ui_list.tips_gui:TipsMessage('The remaining capacity of the backpack is insufficient','fail')
            return false
        end
    
        local cfg = gacha_cfg[self.now_gacha_id]
        if not cfg then
            return
        end
        if cfg.p_type ~= 3 then
            return
        end
        if self.parent.prop_cmp:GetWins() < cfg.price then
            ui_manager.ui_list.tips_gui:TipsMessage('Not enough wins!','fail')
            return
        end
        local egg_id = self.now_gacha_id
        local re = self:Invoke('gacha_one',egg_id)
        if re then
            self.ui:SetBGVisible(false)
            self.ui:SetStopBtnVisible(self.pay_list[54])
            self:QueueOpenEgg({{pet_id = re}},1,egg_id)
        end
        if not (self.pay_list[54] and self.stop_auto == false) then
            break
        end
    end
end

--点击三连抽
function c:ClickThree()
    if not self.pay_list[55] then
        local re = nil
        if goods_cfg[55].isGamePass then
            re = self:Invoke('buy_gamepass',55)
        else
            re = self:Invoke('buy_goods',55)
        end
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
        return
    else
        self.stop_auto = false
        self.ui:SetStopBtnVisible(self.pay_list[54])
        while true do
            if not self.now_gacha_id then
                return
            end
            if self.__playing then
                return 
            end
    
            if self.parent.pet_cmp:GetBagRemain() < 3 then
                ui_manager.ui_list.tips_gui:TipsMessage('The remaining capacity of the backpack is insufficient','fail')
                return false
            end
    
            local cfg = gacha_cfg[self.now_gacha_id]
            if not cfg then
                return
            end
            if cfg.p_type ~= 3 then
                return
            end
            if self.parent.prop_cmp:GetWins() < cfg.price * 3 then
                ui_manager.ui_list.tips_gui:TipsMessage('Not enough wins!','fail')
                return
            end
            local egg_id = self.now_gacha_id
            local re = self:Invoke('gacha_three',egg_id)
            if re then
                self.ui:SetBGVisible(false)
                self.ui:SetStopBtnVisible(self.pay_list[54])
                self:QueueOpenEgg(re,3,egg_id)
            end
            if not (self.pay_list[54] and self.stop_auto == false) then
                break
            end
        end
    end
end

--点击购买gamepass
function c:ClickBuyGamepass(cfg_id)
    if self.pay_list[cfg_id] then
        return
    end
    local re = nil
    if goods_cfg[cfg_id].isGamePass then
        re = self:Invoke('buy_gamepass',cfg_id)
    else
        re = self:Invoke('buy_goods',cfg_id)
    end
    if re then
        spawn(function()
            pcall(function()
                audioManager:PlayGloble('purchase1')
                audioManager:PlayGloble('purchase2')
                wait(0.6)
                audioManager:PlayGloble('purchase3')
            end)
        end)
        self.pay_list[cfg_id] = true
        self:InitUi()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

--点击停止自动按钮
function c:ClickStopAutoBtn()
    self.stop_auto = true
    self.ui:SetStopBtnVisible(false)
end

function c:QueueOpenEgg(list,num,egg_id,notOpen)
    self.notOpen = notOpen
    -- table.insert(OpenEggQueue, {list, num, egg_id})
    while #list > 0 do
        local temp = {}
        for i = 1,3 do
            temp[i] = list[i]
        end
        table.insert(OpenEggQueue, {temp, num, egg_id})
        for i = 1,3 do
            table.remove(list, 1)
        end
    end
    if not isRunning then
		isRunning = true
		self:ProcessQueue()
	end
end

function c:ProcessQueue()
    self.isRunning = true
    self.parent.character.root_part.Anchored = true
    while #OpenEggQueue > 0 do
		local list = table.remove(OpenEggQueue, 1)
		self:OpenEgg(list[1], list[2], list[3])
	end
	isRunning = false
    if not self.notOpen then
        self.ui:SetBGVisible(true)
    end
    self.isRunning = false
    self.parent.character.root_part.Anchored = false
end

function c:OpenEgg(list,num,egg_id)
    num = #list
    local mouseDown = false

    local auto = self.pay_list[54]
    if auto then
        mouseDown = true
    end

    ---@type Mouse
    local mouse = self.parent.main_inst:GetMouse()
    local mouse_co = mouse.Button1Down:Connect(function()
        mouseDown = true
    end)
    local egg = egg_fol:FindFirstChild(tostring(egg_id))

    local DepthOfFieldEffect = Instance.new("DepthOfFieldEffect");
	DepthOfFieldEffect.FarIntensity = 0;
	DepthOfFieldEffect.FocusDistance = 0;
	DepthOfFieldEffect.InFocusRadius = 1.5;
	DepthOfFieldEffect.NearIntensity = 0;
	DepthOfFieldEffect.Parent = game.Lighting;
    DepthOfFieldEffect.Enabled = false

    local num2 = 1
    if num == 3 then
        num2 = 3
    elseif num == 8 then
        num2 = 8
    end
    local is3 = num == 3
	local is8 = num == 8

    local eggTable = {}
    local eggCFTable = {}

    for index1 = 1,num2 do
        local clone_egg = egg:Clone()
        for k,v in ipairs(clone_egg:GetDescendants())do
            if v:IsA(BasePart) then
                v.CanCollide = false
                v.Anchored = true
                v.CastShadow = false
            end
        end
        clone_egg.Parent = workspace.CurrentCamera
        local cf = (not is3 and not is8 or is3) and 
            CFrame.new(
                index1 == 2 and 2 or index1 == 3 and -2 or 0,
                0,
                index1 > 1 and -1 or 0
            ) * CFrame.Angles(0,math.pi,0) or 
            CFrame.new(
                (index1 == 1 or index1 == 3) and 0.75 or (index1 == 2 or index1 == 4) and -0.75 or (index1 == 5 or index1 == 7) and 2.5 or (index1 == 6 or index1 == 8) and -2.5 or false,
                (index1 <= 2 or index1 > 4 and index1 <= 6) and 0.9 or -0.9, index1 <= 4 and 0 or -1
            ) * CFrame.Angles(0,math.pi,0)

        eggTable[index1] = clone_egg
        eggCFTable[index1] = cf

    end

    local os_clock_ret = os.clock();
    -- print(1)
    repeat
        local math_clamp_ret = math.clamp((os.clock() - os_clock_ret) / (0.85), 0, 1);
        local EasingArg = Easing(math_clamp_ret, "Quint", "Out");
        for key6, eggMdl in ipairs(eggTable) do
            local cf = eggCFTable[key6];
            -- 蛋位置
            eggMdl:PivotTo(workspace.CurrentCamera.CFrame * CFrame.new(0, EasingArg * 5 + -5, EasingArg * 5 + -7.5) * cf)
        end
        DepthOfFieldEffect.FarIntensity = math_clamp_ret;
        DepthOfFieldEffect.NearIntensity = math_clamp_ret;

        wait()
    until mouseDown

    local cf = CFrame.new(0, 0, -2.5)
	local t_Size = eggTable[1]:GetScale()

    for index2 = 1,2 do
        local v11 = index2 % 2 == 0 and Random_new_ret:NextNumber(-45, -25) or Random_new_ret:NextNumber(25, 45);
        if auto then
            mouseDown = true
        end
        local os_clock_ret8 = os.clock()
        local v12 = 0.1 / math.max(index2 * 0.6, 1)
        repeat
            local math_clamp_ret9 = math.clamp((os.clock() - os_clock_ret8) / (v12), 0, 1);
            local v25 = Easing(math_clamp_ret9, "Elastic", "Out");
            for key14, val14 in ipairs(eggTable) do
                val14:PivotTo(workspace.CurrentCamera.CFrame * cf * eggCFTable[key14] * CFrame.new(0, 0, v25 * 0.1) * CFrame.Angles(0, 0, (math.rad(v11 * v25))) )
            end
            wait()
        until math_clamp_ret9 >= 1

        local os_clock_ret9 = os.clock()
		local v13 = 0.4 / math.max(index2 * 0.7, 1)
        repeat
            local math_clamp_ret10 = math.clamp((os.clock() - os_clock_ret9) / (v13), 0, 1);
            local v26 = Easing(math_clamp_ret10, "Quad", "Out");
            for key15, val15 in ipairs(eggTable) do
                val15:PivotTo(workspace.CurrentCamera.CFrame * cf * eggCFTable[key15] * CFrame.new(0, 0, 0.1 - v26 * 0.1) * CFrame.Angles(0, 0, (math.rad(v11 - v26 * v11))))
            end
            wait()
        until mouseDown
        -- print(2)
        pcall(function()
            audioManager:PlayGloble('egge_shake',2)
        end)
    end

    local os_clock_ret2 = os.clock();
    repeat
        local math_clamp_ret2 = math.clamp((os.clock() - os_clock_ret2) / (0.4), 0, 1);
        local v14 = Easing(math_clamp_ret2, "Quart", "Out");
        for key7, val7 in ipairs(eggTable) do
            local v27 = eggCFTable[key7];
            val7:ScaleTo(math.max(0.01,t_Size * (1 - v14 * 0.75)));
            val7:PivotTo(workspace.CurrentCamera.CFrame * cf * v27 *CFrame.Angles(0,math.rad(-90),0) );
        end
        wait()
    until math_clamp_ret2 >= 1

    local t_Size2 = eggTable[1]:GetScale()

    local table4 = {};
	local t_CurrentCamera2 = workspace.CurrentCamera
    for index3 = 1, Random_new_ret:NextInteger(50, 100) do
        local table6 = {
            Random_new_ret:NextNumber(-2, 2),
            Random_new_ret:NextNumber(),
            Random_new_ret:NextNumber()
        };
        local NextNumber_ret = Random_new_ret:NextNumber(4, 8);
        local Clone_ret6 = Confetti:Clone();
        Clone_ret6.Color = Color3.fromHSV(Random_new_ret:NextNumber(), 1, 1);
        Clone_ret6.CFrame = t_CurrentCamera2.CFrame * CFrame.new(0, table6[2] + 1.5, -1);
        Clone_ret6.CastShadow = false;
        Clone_ret6.Parent = t_CurrentCamera2;
        table4[index3] = {
            confetti = Clone_ret6,
            floats = table6,
            speed = NextNumber_ret
        };
    end

    local u5 = 0;
    local Connect_ret = nil;
    Connect_ret = game:GetService("RunService").RenderStepped:Connect(function(p7)
        u5 = u5 + p7;
        local bool5 = false;
        for key16, val16 in pairs(table4) do
            local t_floats = val16.floats;
            local math_clamp_ret3 = math.clamp(u5 / 0.4, 0.001, 1);
            val16.confetti.CFrame = t_CurrentCamera2.CFrame * CFrame.new(t_floats[1], t_floats[2] + 1.5 - math_clamp_ret3 * 10, -1) * CFrame.Angles(t_floats[3] * (math_clamp_ret3 * 125), 0, 0);
            if math_clamp_ret3 >= 1 then
                table4[key16] = nil;
                Debris:AddItem(val16.confetti, 0)
                continue;
            end
            bool5 = true;
        end
        if not bool5 then
            Connect_ret:Disconnect();
        end
    end)

    local os_clock_ret3 = os.clock();
    repeat
        local math_clamp_ret4 = math.clamp((os.clock() - os_clock_ret3) / 0.075, 0, 1);
        local v15 = Easing(math_clamp_ret4, "Sine", "Out");
        for key8, val8 in ipairs(eggTable) do
            local v28 = eggCFTable[key8];
            val8:ScaleTo(math.max(0.01,t_Size2 * (v15 * 5)));
            val8:PivotTo(t_CurrentCamera2.CFrame * cf * v28)
        end
        wait()
    until math_clamp_ret4 >= 1

    for _, val2 in ipairs(eggTable) do
		Debris:AddItem(val2, 0);
	end

    --宠物
    for key3, val3 in ipairs(list) do
        --拿取宠物
        local pet_id = val3.pet_id
		local modelName = pet_cfg[pet_id].model
        local model = pet_fol:FindFirstChild(modelName)
        model = hotpot:CloneInst_Loop(model)
        wait()
        -- for k,v in ipairs(model:GetDescendants())do
        --     local descendant9 = v
        --     if descendant9.ClassName == "SpecialMesh" then
		-- 		descendant9.Scale = descendant9.Scale * 0.33;
		-- 	end
		-- 	if descendant9.ClassName == "Attachment" then
		-- 		descendant9.Position = descendant9.Position * 0.33;
		-- 	end
		-- 	if descendant9.ClassName == "ParticleEmitter" then 
        --         ScaleParticle(descendant9, 0.33);
        --     end
        -- end

        for k,v in ipairs(model:GetDescendants())do
            if v:IsA("BasePart") then
                v.CanCollide = false
                v.Anchored = true
                v.CastShadow = false
                v.CanTouch = false
                v.CanQuery = false
            end
        end

        model.Parent = t_CurrentCamera2
        local v17 = (not is3 and not is8 or is3) and CFrame.new(key3 == 2 and 2.8 or key3 == 3 and -2.8 or 0, 0, key3 > 1 and -0.15 or 0) or CFrame.new((key3 == 1 or key3 == 3) and -0.81 or (key3 == 2 or key3 == 4) and 0.81 or (key3 == 5 or key3 == 7) and -2.3 or (key3 == 6 or key3 == 8) and 2.3 or false, (key3 <= 2 or key3 > 4 and key3 <= 6) and 0.75 or -0.6, key3 <= 4 and 0 or -0.15);
		local v18 = (not is3 and not is8 or is3) and CFrame.new(key3 == 2 and 1.3 or key3 == 3 and -1.3 or 0, 0, key3 > 1 and -0.15 or 0) or CFrame.new((key3 == 1 or key3 == 3) and -0.81 or (key3 == 2 or key3 == 4) and 0.81 or (key3 == 5 or key3 == 7) and -2.3 or (key3 == 6 or key3 == 8) and 2.3 or false, (key3 <= 2 or key3 > 4 and key3 <= 6) and 0.75 or -0.6, key3 <= 4 and 0 or -0.15);
        
        val3.model = model
		val3.offset = v17
		val3.offset2 = v18
    end

    for _, val4 in ipairs(list) do
		--宠物名字
		local petName = pet_cfg[val4.pet_id].name 	
		
		local Clone_ret = EggOpenPetInfo:Clone();
		Clone_ret.SurfaceGui.PetIcon.Image = "rbxassetid://14968191202"
		Clone_ret.SurfaceGui.PetName.Text = petName;
        local quality = pet_cfg[val4.pet_id].quality
		Clone_ret.SurfaceGui.Rarity.Text = pet_cfg[val4.pet_id].name
        local color = qualityColor:FindFirstChild(tostring(quality))
        color:Clone().Parent = Clone_ret.SurfaceGui.Rarity
		Clone_ret.Parent = t_CurrentCamera2;
		val4.gui = Clone_ret;

        ---@type Model
        local model = val4.model
        for k,v in ipairs(model:GetDescendants())do
            if v:IsA("BasePart") then
                v.CanCollide = false
                v.Anchored = true
                v.CastShadow = false
                v.CanTouch = false
                v.CanQuery = false
            end
        end

        --特效
        ---@type Part
        local eff = EggEffFol:FindFirstChild('p'..quality)
        eff = hotpot:CloneInst_Loop(eff)
        eff.Parent = model
        ---@type CFrame
        local cf = model:GetPivot()
        eff.Position = cf.Position + cf.LookVector * (-2)

        for k,v in ipairs(eff:GetDescendants())do
            if v:IsA('ParticleEmitter') then
                v.Enabled = false
            end
        end

        delay(0.6,function()
            for k,v in ipairs(eff:GetDescendants())do
                if v:IsA('ParticleEmitter') then
                    v.Enabled = true
                end
            end
        end)

        ParticleHelper:ReSizeParticle(eff,2)

        ---@type WeldConstraint
        local we = Instance.new('WeldConstraint',eff)
        we.Part0 = eff
        we.Part1 = model.PrimaryPart
	end
    local bool6 = false;
	local table5 = {};
	local coroutine_wrap_ret2 = coroutine.wrap(function()
		local os_clock_ret4 = os.clock();
		repeat
			local math_clamp_ret5 = math.clamp((os.clock() - os_clock_ret4) / 0.75 , 0, 1);
			local v29 = Easing(math_clamp_ret5, "Expo", "Out");
			for key18, val18 in ipairs(list) do
				local t_gui = val18.gui;
				local v30 = val18.offset2;
				if is8 then
					v30 = v30 + ((key18 >= 3 and key18 <= 4 or key18 >= 7) and Vector3.new(0, 1.45, -0.4) or Vector3.new(0, -1.6, -0.4));
				end
				local t_p = (t_CurrentCamera2.CFrame * CFrame.new(0, 0, -30) * v30).p;
				local t_p2 = t_CurrentCamera2.CFrame.p;
				local v31 = CFrame.lookAt(t_p, t_p2, t_CurrentCamera2.CFrame.UpVector) * CFrame.new(0, -0.7, v29 * -28.3) * v30:Inverse();
				table5[t_gui] = v31;
				t_gui.CFrame = v31;
			end
            wait()
		until bool6
	end)

    pcall(function()
        audioManager:PlayGloble('egge_get1')
    end)

	coroutine_wrap_ret2()
    local os_clock_ret5 = os.clock()
    repeat
		local math_clamp_ret6 = math.clamp((os.clock() - os_clock_ret5) / 1, 0, 1);
		local v20 = Easing(math_clamp_ret6, "Quart", "Out");
		for _, val10 in ipairs(list) do
			local t_model3 = val10.model;
			local t_offset3 = val10.offset;
			local Inverse_ret3 = CFrame.new(Vector3.new(0,0,0) * 0.33):Inverse();

            for k,v in ipairs(t_model3:GetDescendants())do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                    v.Anchored = true
                    v.CastShadow = false
                    v.CanTouch = false
                    v.CanQuery = false
                end
            end

			t_model3:PivotTo(CFrame.lookAt((t_CurrentCamera2.CFrame * (CFrame.new(0, 0, -8) * Inverse_ret3 * t_offset3)).p, t_CurrentCamera2.CFrame.p, t_CurrentCamera2.CFrame.UpVector) * CFrame.Angles(0, math.rad(v20 * 360), 0));
		end
		wait()
	until math_clamp_ret6 >= 1
    local os_clock_ret6 = os.clock();
	local v7 = 2
	local mouseDown = false
    self:AddProcess(function()
        self:Wait(1.5)
        mouseDown = true
    end)
    repeat
		local math_clamp_ret7 = math.clamp((os.clock() - os_clock_ret6) / v7, 0, 1);
		for _, val11 in ipairs(list) do
			local t_model2 = val11.model;
			local t_offset2 = val11.offset;
			local Inverse_ret2 = CFrame.new(Vector3.new(0,0,0) * 0.33):Inverse();
			local CFrame_lookAt_ret2 = CFrame.lookAt((t_CurrentCamera2.CFrame * (CFrame.new(0, 0, -8) * Inverse_ret2 * t_offset2)).p, t_CurrentCamera2.CFrame.p, t_CurrentCamera2.CFrame.UpVector) * CFrame.Angles(0, math.rad(360), 0);
			t_model2:PivotTo(CFrame_lookAt_ret2);
		end
		wait()
	until math_clamp_ret7 >= 1 and mouseDown == true
    bool6 = true
    local os_clock_ret7 = os.clock();
	mouseDown = true
    repeat
        local math_clamp_ret8 = math.clamp((os.clock() - os_clock_ret7) / 0.5, 0, 1);
        local v21 = Easing(math_clamp_ret8, "Back", "In");
        for _, val12 in ipairs(list) do
            local t_model = val12.model;
            local t_offset = val12.offset;
            local Inverse_ret = CFrame.new(Vector3.new(0,0,0) * 0.33):Inverse()
            local CFrame_lookAt_ret = CFrame.lookAt((t_CurrentCamera2.CFrame * (CFrame.new(0, 0, -8) * Inverse_ret * t_offset * CFrame.new(0, v21 * -10, 0))).p, 
                t_CurrentCamera2.CFrame.p, t_CurrentCamera2.CFrame.UpVector)* CFrame.Angles(0, math.rad(360), 0);
            t_model:PivotTo(CFrame_lookAt_ret);
        end

        for _, val13 in ipairs(list) do
            local t_gui2 = val13.gui;
            t_gui2.CFrame = table5[t_gui2] * CFrame.new(0, -math_clamp_ret8 * 2, 0);
        end
        DepthOfFieldEffect.FarIntensity = 1 - math_clamp_ret8;
        DepthOfFieldEffect.NearIntensity = 1 - math_clamp_ret8;

        wait()
    until math_clamp_ret8 >= 1

    DepthOfFieldEffect:Destroy()

    wait(.5)
    for k,v in ipairs(list)do
        v.model:Destroy()
        v.gui:Destroy()
    end
    if mouse_co then
        mouse_co:Disconnect()
        mouse_co = nil
    end
end

return c