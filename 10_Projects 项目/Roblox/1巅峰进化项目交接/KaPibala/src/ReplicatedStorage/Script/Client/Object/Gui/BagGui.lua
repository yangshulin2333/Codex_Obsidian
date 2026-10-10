local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type Players
local players = game:GetService('Players')
---@type Player
local player = players.LocalPlayer
---@type Mouse
local mouse = player:GetMouse()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()

local tipsStr = "Pet will always be %.0f%% stronger as your best pet!."
local chaTipsStr = 'Character will always be %s%% stronger as your best character!'
local tweenInfo = TweenInfo.new(0.2)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class BagGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'   
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'     
    ---@type TextLabel		
	c.insts.title = 'Frame.bg.title'   
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'     

    ---@type Frame		
	c.insts.leftBtns = 'Frame.bg.leftBtns'   
    ---@type ImageButton		
	c.insts.left_character_btn = 'Frame.bg.leftBtns.character.btn'    
    ---@type ImageButton		
	c.insts.left_item_btn = 'Frame.bg.leftBtns.item.btn'     
    ---@type ImageButton		
	c.insts.left_pet_btn = 'Frame.bg.leftBtns.pet.btn'     

    ---@type Frame		
	c.insts.chaFrame = 'Frame.bg.chaFrame'    
    ---@type ScrollingFrame		
	c.insts.chaFrame_ScrollingFrame = 'Frame.bg.chaFrame.ScrollingFrame'    
    ---@type Frame		
	c.insts.chaFrame_item = 'Frame.bg.chaFrame.ScrollingFrame.item'    
    ---@type Frame		
	c.insts.chaFrame_SecretItem = 'Frame.bg.chaFrame.ScrollingFrame.SecretItem'    
    ---@type Frame		
	c.insts.chaFrame_cItem = 'Frame.bg.chaFrame.ScrollingFrame.item.bg.cItem'  
    ---@type ImageLabel		
	c.insts.chaFrame_tipsFrame = 'Frame.bg.chaFrame.tipsFrame'     
    ---@type TextLabel		
	c.insts.chaFrame_tips_atk = 'Frame.bg.chaFrame.tipsFrame.atk'    
    ---@type TextLabel		
	c.insts.chaFrame_tips_name = 'Frame.bg.chaFrame.tipsFrame.name'  
    ---@type TextLabel		
	c.insts.chaFrame_tips_lv = 'Frame.bg.chaFrame.tipsFrame.lv'      
    ---@type TextLabel		
	c.insts.chaFrame_tips_hp = 'Frame.bg.chaFrame.tipsFrame.hp'  
    ---@type ImageButton		
	c.insts.chaFrame_equipBest = 'Frame.bg.chaFrame.equipBest'     
    ---@type ImageLabel		
	c.insts.chaFrame_tipsFrame2 = 'Frame.bg.chaFrame.tipsFrame2'     
    
    ---@type Frame		
	c.insts.petFrame = 'Frame.bg.petFrame'    
    ---@type ScrollingFrame		
	c.insts.petFrame_ScrollingFrame = 'Frame.bg.petFrame.ScrollingFrame'    
    ---@type Frame		
	c.insts.petFrame_item = 'Frame.bg.petFrame.ScrollingFrame.item'    
    ---@type ImageButton		
	c.insts.UnequipAll = 'Frame.bg.petFrame.UnequipAll'   
    ---@type ImageButton		
	c.insts.equipBest = 'Frame.bg.petFrame.equipBest'   
    ---@type ImageButton		
	c.insts.pet_cancelBtn = 'Frame.bg.petFrame.cancelBtn'     
    ---@type ImageButton		
	c.insts.pet_delBtn = 'Frame.bg.petFrame.delBtn'    
    ---@type ImageButton		
	c.insts.pet_addcapacityBtn = 'Frame.bg.petFrame.capacityPanel.addEquipBtn'     
    ---@type TextLabel		
	c.insts.pet_equipNum = 'Frame.bg.petFrame.equipPanel.capacityNum'     
    ---@type ImageButton		
	c.insts.pet_addEquipBtn = 'Frame.bg.petFrame.equipPanel.addEquipBtn'    
    ---@type TextLabel		
	c.insts.pet_capacityNum = 'Frame.bg.petFrame.capacityPanel.capacityNum'    
    ---@type ImageLabel		
	c.insts.pet_tipsFrame = 'Frame.bg.petFrame.tipsFrame'    
    ---@type TextLabel		
	c.insts.pet_tipsFrame_name = 'Frame.bg.petFrame.tipsFrame.name'  
    ---@type TextLabel		
	c.insts.pet_tipsFrame_atk = 'Frame.bg.petFrame.tipsFrame.atk.num'   
    ---@type ImageLabel		
	c.insts.pet_tipsFrame2 = 'Frame.bg.petFrame.tipsFrame2'         
    
    ---@type Frame		
	c.insts.itemFrame = 'Frame.bg.itemFrame'    
    ---@type ScrollingFrame		
	c.insts.itemFrame_ScrollingFrame = 'Frame.bg.itemFrame.ScrollingFrame'   
    ---@type Frame		
	c.insts.itemFrame_item = 'Frame.bg.itemFrame.ScrollingFrame.item'     
    ---@type ImageLabel		
	c.insts.itemFrame_tipsFrame = 'Frame.bg.itemFrame.tipsFrame'    

    ---@type ImageLabel		
	c.insts.itemBtnRed = 'Frame.bg.leftBtns.item.btn.red'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.BagGui',_G.Resource)
    c.super.ctor(self,ui)

    self:Init()
end

function c:Init()
    self.cha_item_list = {}
    self.pet_item_list = {}
    self.equip_item_list = {}
    self.item_boosts_list = {}
    self.item_creates_list = {}
    self.item_forgeStone_list = {}
    self.item_luckyStone_list = {}

    self.cha_anima = {}

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
        local event = game.ReplicatedStorage:WaitForChild('Event')
        event:Fire('ExitBagView')
    end)

    self.insts.left_character_btn.MouseButton1Click:Connect(function()
        self:SetChaFrameVisible(true)
        self:SetPetFrameVisible(false)
        self:SetItemFrameVisible(false)
        self.insts.left_character_btn.select.Visible = true
        self.insts.left_item_btn.select.Visible = false
        self.insts.left_pet_btn.select.Visible = false
        audioManager:PlayGloble('pick')
    end)
    self.insts.left_item_btn.MouseButton1Click:Connect(function()
        self:SetChaFrameVisible(false)
        self:SetPetFrameVisible(false)
        self:SetItemFrameVisible(true)
        self.insts.left_character_btn.select.Visible = false
        self.insts.left_item_btn.select.Visible = true
        self.insts.left_pet_btn.select.Visible = false
        audioManager:PlayGloble('pick')

    end)
    self.insts.left_pet_btn.MouseButton1Click:Connect(function()
        self:SetChaFrameVisible(false)
        self:SetPetFrameVisible(true)
        self:SetItemFrameVisible(false)
        self.insts.left_character_btn.select.Visible = false
        self.insts.left_item_btn.select.Visible = false
        self.insts.left_pet_btn.select.Visible = true
        audioManager:PlayGloble('pick')

    end)
end

function c:Show()
    c.super.Show(self)
    TweenHelper:PlayTween(
        self.insts.Frame,
        tweenInfo,
        {Position = UDim2.fromScale(0.5,0.5)}
    )
end

function c:Hide()
    TweenHelper:PlayTween(
        self.insts.Frame,
        tweenInfo,
        {Position = UDim2.fromScale(1.15,0.5)},
        function()
            c.super.Hide(self)
        end
    )
    ui_manager.ui_list.hud_gui:Show()
end

function c:SetItemBtnRedVisible(vis)
    self.insts.itemBtnRed.Visible = vis
end

------------------------------------------ChaFrame_Start--------
--设置chaFrame的显示
function c:SetChaFrameVisible(vis)
    self.insts.chaFrame.Visible = vis
end

--向chaFrame添加子项
function c:AddItemInChaFrame(id,name,list)
    local ui = nil
    if name == 'Secret' then
        ui = hotpot:CloneInst_Loop(self.insts.chaFrame_SecretItem)
    else
        ui = hotpot:CloneInst_Loop(self.insts.chaFrame_item)
    end

    ui.Name = id
    ui.Visible = true
    ui.Parent = self.insts.chaFrame_ScrollingFrame
    ui.title.Text = name

    for k,v in ipairs(list)do
        local c_ui = hotpot:CloneInst_Loop(self.insts.chaFrame_cItem)
        c_ui.Parent = ui.bg
        c_ui.Visible = true
        c_ui.btn.icon.Image = v.icon or ''
        if v.value == 0 then
            c_ui.btn.num.Text = '???'
        else
            c_ui.btn.num.Text = big_number:ToString(v.value)
        end
        local color = qualityColor:FindFirstChild(tostring(v.quality))
        color:Clone().Parent = c_ui.btn.bg
        color:Clone().Parent = c_ui.btn.bg.UIStroke

        self.cha_item_list[v.id] = c_ui

        local cha_id = v.id

        local model = v.model
        c_ui.btn.bg.MouseEnter:Connect(function()
            local viewSize = workspace.CurrentCamera.ViewportSize
            if self.__cha_item_mouse_enter_handle and self.__cha_item_mouse_enter_obj then
                self.__cha_item_mouse_enter_handle(self.__cha_item_mouse_enter_obj,cha_id)
            end
            local x = mouse.X
            local y = mouse.Y
            if hotpot.is_mobile then
                x = x + c_ui.AbsoluteSize.X / 2
            end

            local a_pos = self.insts.chaFrame.AbsolutePosition
            local a_size = self.insts.chaFrame.AbsoluteSize
            local tipSize = self.insts.chaFrame_tipsFrame.AbsoluteSize
            x = math.min(viewSize.X - tipSize.X - 5,x)
            y = math.min((a_pos.Y+a_size.Y - tipSize.Y),y)
            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y

            self.insts.chaFrame_tipsFrame.Position = UDim2.fromScale(x,y)
            self.insts.chaFrame_tipsFrame2.Position = UDim2.fromScale(x,y)
        end)
        c_ui.btn.bg.MouseLeave:Connect(function()
            self:SetChaFrameTipsFrameVisible(false)
            self:SetChaFrameTipsFrame2Visible(false)
        end)
        c_ui.btn.bg.MouseMoved:Connect(function()
            local viewSize = workspace.CurrentCamera.ViewportSize
            local x = mouse.X
            local y = mouse.Y
            if hotpot.is_mobile then
                x = x + c_ui.AbsoluteSize.X / 2
            end

            local a_pos = self.insts.chaFrame.AbsolutePosition
            local a_size = self.insts.chaFrame.AbsoluteSize
            local tipSize = self.insts.chaFrame_tipsFrame.AbsoluteSize
            x = math.min(viewSize.X - tipSize.X - 5,x)
            y = math.min((a_pos.Y+a_size.Y - tipSize.Y),y)
            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y

            self.insts.chaFrame_tipsFrame.Position = UDim2.fromScale(x,y)
            self.insts.chaFrame_tipsFrame2.Position = UDim2.fromScale(x,y)
        end)
        c_ui.btn.MouseButton1Click:Connect(function()
            if self.__chaFrame_item_click_handle and self.__chaFrame_item_click_obj then
                self.__chaFrame_item_click_handle(self.__chaFrame_item_click_obj,cha_id)
            end
        end)
    end
end

--设置chaFrame的item的解锁状态 
function c:SetChaFrameItemLock(id,lock)
    local ui = self.cha_item_list[id]
    if not ui then
        return
    end
    ui.btn.icon.ImageColor3 = lock and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
end

--设置chaFrame的TipsFrame的信息
function c:SetChaFrameTipsFrameInfo(atk,name,hp,lv)
    self.insts.chaFrame_tips_atk.num.Text = '+'.. big_number:ToString(atk)
    self.insts.chaFrame_tips_name.Text = name
    self.insts.chaFrame_tips_lv.Text = 'Level'..lv
    self.insts.chaFrame_tips_hp.num.Text = '+'.. big_number:ToString(hp)
end

--设置chaFrame的TipsFrame的位置
function c:SetChaFrameTipsFramePos(pos)
    self.insts.chaFrame_tipsFrame.Position = pos
    self:SetChaFrameTips2FramePos(pos)
end

--设置chaFrame的TipsFrame的显示
function c:SetChaFrameTipsFrameVisible(vis)
    self.insts.chaFrame_tipsFrame.Visible = vis
end 

--设置chaFrame的TipsFrame的信息
function c:SetChaFrameTipsFrame2Info(name,per)
    self.insts.chaFrame_tipsFrame2.name.Text = name
    self.insts.chaFrame_tipsFrame2.desc.Text = string.format(chaTipsStr,per)
end

--设置chaFrame的TipsFrame的位置
function c:SetChaFrameTips2FramePos(pos)
    self.insts.chaFrame_tipsFrame2.Position = pos
end

--设置chaFrame的TipsFrame的显示
function c:SetChaFrameTipsFrame2Visible(vis)
    self.insts.chaFrame_tipsFrame2.Visible = vis
end 

--设置chaFrame的item的装备显示
function c:SetChaFrameItemEquipVisible(id,vis)
    local ui = self.cha_item_list[id]
    if not ui then
        return
    end
    ui.btn.equip.Visible = vis
end

--绑定chaFrame的TipsFrame的鼠标进入事件
function c:BindChaFrameTipsFrameMouseEnter(obj,handle)
    self.__cha_item_mouse_enter_handle = handle
    self.__cha_item_mouse_enter_obj = obj
end

--绑定item点击事件
function c:BindChaFrameItemClick(obj,handle)
    self.__chaFrame_item_click_handle = handle
    self.__chaFrame_item_click_obj = obj
end

--绑定装备最佳角色按钮点击事件
function c:BindChaFrameEquipBestClickHandle(obj,handle)
    self.insts.chaFrame_equipBest.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end
------------------------------------------ChaFrame_End--------

------------------------------------------PetFrame_Start--------
--向PetFrame添加子项
function c:AddItemInPetFrame(inst_id,icon,quality,value,star)
    local ui = hotpot:CloneInst_Loop(self.insts.petFrame_item)
    ui.Visible = true
    local color = qualityColor:FindFirstChild(tostring(quality))
    color:Clone().Parent = ui.btn.bg
    color:Clone().Parent = ui.btn.bg.UIStroke

    ui.btn.icon.Image = icon

    ui.Name = inst_id
    ui.btn.value.Text = big_number:ToString(value)
    self.pet_item_list[inst_id] = ui
    ui.Parent = self.insts.petFrame_ScrollingFrame

    local stars = ui.btn.stars
    for i = 1,3 do
        local star_ui = stars:FindFirstChild(tostring(i))
        star_ui.Visible = star>=i
    end

    ui.btn.MouseEnter:Connect(function()
        local viewSize = workspace.CurrentCamera.ViewportSize
        if self.__pet_item_mouse_enter_handle and self.__pet_item_mouse_enter_obj then
            self.__pet_item_mouse_enter_handle(self.__pet_item_mouse_enter_obj,inst_id)
        end
        local x = mouse.X
        local y = mouse.Y
        if hotpot.is_mobile then
            x = x + ui.AbsoluteSize.X / 2
        end

        local a_pos = self.insts.petFrame.AbsolutePosition
        local a_size = self.insts.petFrame.AbsoluteSize
        local scorllPos = self.insts.petFrame_ScrollingFrame.AbsolutePosition
        local scrollSize = self.insts.petFrame_ScrollingFrame.AbsoluteSize
        local tipSize = self.insts.pet_tipsFrame2.AbsoluteSize

        x = math.min(viewSize.X - tipSize.X - 5,x)
        y = math.min((scorllPos.Y+scrollSize.Y - tipSize.Y),y)


        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.pet_tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    ui.btn.MouseLeave:Connect(function()
        self:SetPetFrameTipsFrameVisible(false)
        self:SetPetFrameTipsFrame2Visible(false)
    end)
    ui.btn.MouseMoved:Connect(function()
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y
        if hotpot.is_mobile then
            x = x + ui.AbsoluteSize.X / 2
        end

        local a_pos = self.insts.petFrame.AbsolutePosition
        local a_size = self.insts.petFrame.AbsoluteSize
        local scorllPos = self.insts.petFrame_ScrollingFrame.AbsolutePosition
        local scrollSize = self.insts.petFrame_ScrollingFrame.AbsoluteSize
        local tipSize = self.insts.pet_tipsFrame2.AbsoluteSize

        x = math.min(viewSize.X - tipSize.X - 5,x)
        y = math.min((scorllPos.Y+scrollSize.Y - tipSize.Y),y)
        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.pet_tipsFrame.Position = UDim2.fromScale(x,y)
        self.insts.pet_tipsFrame2.Position = UDim2.fromScale(x,y)
    end)
    ui.btn.MouseButton1Click:Connect(function()
        if self.__petFrame_item_click_handle and self.__petFrame_item_click_obj then
            self.__petFrame_item_click_handle(self.__petFrame_item_click_obj,inst_id)
        end
    end)
end

--删除Petitem的子项
function c:DelItemInPetFrame(inst_id)
    local ui = self.pet_item_list[inst_id]
    if not ui then
        return
    end
    ui:Destroy()
    self.pet_item_list[inst_id] = nil
end

--设置petItem的layout
function c:SetPetItemLayout(inst_id,order)
    local ui = self.pet_item_list[inst_id]
    if not ui then
        return
    end
    ui.LayoutOrder = order
end

--设置petItem的装备显示
function c:SetPetItemEquipVisible(inst_id,vis)
    local ui = self.pet_item_list[inst_id]
    if not ui then
        return
    end
    ui.btn.equip.Visible = vis
end

--设置petItem的删除显示
function c:SetPetItemDelVisible(inst_id,vis)
    local ui = self.pet_item_list[inst_id]
    if not ui then
        return
    end
    ui.btn.del.Visible = vis
end

--设置petFrame的cancelbtn显示
function c:SetPetFrameCancelBtnVisible(vis)
    self.insts.pet_cancelBtn.Visible = vis
end

--设置petFrame的equipbest显示
function c:SetPetFrameEquipBestVisible(vis)
    self.insts.equipBest.Visible = vis  
end

--设置petFrame的UnequipAll显示
function c:SetPetFrameUnequipAllVisible(vis)
    self.insts.UnequipAll.Visible = vis
end

--设置当前已装备的数量
function c:SetPetFrameEquipNum(now,max)
    self.insts.pet_equipNum.Text = now..'/'..max
end

--设置当前背包容量
function c:SetPetFrameCapacityNum(now,max)
    self.insts.pet_capacityNum.Text = now..'/'..max
end

--设置petFrame的TipsFrame的信息
function c:SetPetFrameTipsFrameInfo(name,atk,quality)
    self.insts.pet_tipsFrame_name.Text = name
    self.insts.pet_tipsFrame_atk.Text = '+' .. big_number:ToString(atk)
    self.insts.pet_tipsFrame.quality.Text = hotpot.pro_cfg.quality[quality].name
    self.insts.pet_tipsFrame.quality.TextColor3 = hotpot.pro_cfg.quality[quality].color
end

--设置petFrame的TipsFrame的显示
function c:SetPetFrameTipsFrameVisible(vis)
    self.insts.pet_tipsFrame.Visible = vis
end

--设置petFrame的TipsFrame2的显示
function c:SetPetFrameTipsFrame2Visible(vis)
    self.insts.pet_tipsFrame2.Visible = vis
end

--设置petFrame的TipsFrame2的信息
function c:SetPetFrameTipsFrame2Info(name,atk,quality,per)
    self.insts.pet_tipsFrame2.name.Text = name
    self.insts.pet_tipsFrame2.atk.num.Text = '+' .. big_number:ToString(atk)
    self.insts.pet_tipsFrame2.tip.Text = string.format(tipsStr,per)
    self.insts.pet_tipsFrame2.quality.Text = hotpot.pro_cfg.quality[quality].name
    self.insts.pet_tipsFrame2.quality.TextColor3 = hotpot.pro_cfg.quality[quality].color
end

--设置petframe的显示
function c:SetPetFrameVisible(vis)
    self.insts.petFrame.Visible = vis
end

--设置addEquipBtn的显示
function c:SetPetFrameAddEquipBtnVisible(vis)
    self.insts.pet_addEquipBtn.Visible = vis
end

--绑定AddEquipBtn的点击事件
function c:BindPetFrameAddEquipBtnClickHandle(obj,handle)
    self.insts.pet_addEquipBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定AddCapacityBtn的点击事件
function c:BindPetFrameAddCapacityBtnClickHandle(obj,handle)
    self.insts.pet_addcapacityBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定petFrame的TipsFrame的鼠标进入事件
function c:BindPetFrameTipsFrameMouseEnter(obj,handle)
    self.__pet_item_mouse_enter_handle = handle
    self.__pet_item_mouse_enter_obj = obj
end

--绑定item点击事件
function c:BindPetFrameItemClick(obj,handle)
    self.__petFrame_item_click_handle = handle
    self.__petFrame_item_click_obj = obj
end

--绑定petFrame的equipbest点击事件
function c:BindPetFrameEquipBestClick(obj,handle)
    self.insts.equipBest.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定petFrame的unequipAll点击事件
function c:BindPetFrameUnequipAllClick(obj,handle)
    self.insts.UnequipAll.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定petframe删除按钮
function c:BindPetFrameDelBtnClick(obj,handle)
    self.insts.pet_delBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定petframe取消按钮
function c:BindPetFrameCancelBtnClick(obj,handle)
    self.insts.pet_cancelBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

------------------------------------------PetFrame_End--------

------------------------------------------ItemFrame_Start--------
--设置ItemFrame的显示
function c:SetItemFrameVisible(vis)
    self.insts.itemFrame.Visible = vis  
end

--向ItemFrame添加子项
function c:AddItemInItemFrame(type_,id,icon,quality,num)
    quality = quality or 1
    local ui = hotpot:CloneInst_Loop(self.insts.itemFrame_item)
    ui.Visible = true
    ui.Parent = self.insts.itemFrame_ScrollingFrame
    ui.btn.icon.Image = icon
    ui.btn.num.Text = num
    ui.btn.bg.ImageColor3 = hotpot.pro_cfg.quality[quality].color
    ui.btn.bg.UIStroke.Color = hotpot.pro_cfg.quality[quality].color
    if type_ == 'boost' then
        self.item_boosts_list[id] = ui
    elseif type_ == 'creates' then
        self.item_creates_list[id] = ui
        ui.btn.red.Visible = true
    elseif type_ == 'forgeStone' then
        self.item_forgeStone_list[id] = ui
    elseif type_ == 'luckyStone' then
        self.item_luckyStone_list[id] = ui
    end

    ui.btn.MouseButton1Click:Connect(function()
        if self.itemFrame_item_click_handle then
            self.itemFrame_item_click_handle(self.itemFrame_item_click_obj,type_,id)
        end
    end)
    ui.btn.MouseEnter:Connect(function()
        if self.__item_mouse_enter_handle then
            self.__item_mouse_enter_handle(self.__item_mouse_enter_obj,type_,id)
        end
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.itemFrame.AbsolutePosition
        local a_size = self.insts.itemFrame.AbsoluteSize
        local scorllPos = self.insts.itemFrame_ScrollingFrame.AbsolutePosition
        local scrollSize = self.insts.itemFrame_ScrollingFrame.AbsoluteSize
        local tipSize = self.insts.itemFrame_tipsFrame.AbsoluteSize

        x = math.min(viewSize.X - tipSize.X - 5,x)
        y = math.min((scorllPos.Y+scrollSize.Y - tipSize.Y),y)


        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.itemFrame_tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    ui.btn.MouseMoved:Connect(function()
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y
        local a_pos = self.insts.itemFrame.AbsolutePosition
        local a_size = self.insts.itemFrame.AbsoluteSize
        local scorllPos = self.insts.itemFrame_ScrollingFrame.AbsolutePosition
        local scrollSize = self.insts.itemFrame_ScrollingFrame.AbsoluteSize
        local tipSize = self.insts.itemFrame_tipsFrame.AbsoluteSize

        x = math.min(viewSize.X - tipSize.X - 5,x)
        y = math.min((scorllPos.Y+scrollSize.Y - tipSize.Y),y)

        x = (x - a_pos.X) / a_size.X
        y = (y - a_pos.Y) / a_size.Y
        self.insts.itemFrame_tipsFrame.Position = UDim2.fromScale(x,y)
    end)
    ui.btn.MouseLeave:Connect(function()
        self:SetItemFrameTipsFrameVisible(false)
    end)
end

function c:SetItemFrameItemNum(type_,id,num)
    local ui 
    if type_ == 'boost' then
        ui = self.item_boosts_list[id]
    elseif type_ == 'creates' then
        ui = self.item_creates_list[id]
    elseif type_ == 'forgeStone' then
        ui = self.item_forgeStone_list[id]
    elseif type_ == 'luckyStone' then
        ui = self.item_luckyStone_list[id]
    end
    if not ui then
        return
    end
    ui.btn.num.Text = num
end

function c:DelItemFrameItem(type_,id)
    local ui 
    if type_ == 'boost' then
        ui = self.item_boosts_list[id]
        if not ui then
            return
        end
        ui:Destroy()
        self.item_boosts_list[id] = nil
    elseif type_ == 'creates' then
        ui = self.item_creates_list[id]
        if not ui then
            return
        end
        ui:Destroy()
        self.item_creates_list[id] = nil
    elseif type_ == 'forgeStone' then
        ui = self.item_forgeStone_list[id]
        if not ui then
            return
        end
        ui:Destroy()
        self.item_forgeStone_list[id] = nil
    elseif type_ == 'luckyStone' then
        ui = self.item_luckyStone_list[id]
        if not ui then
            return
        end
        ui:Destroy()
        self.item_luckyStone_list[id] = nil
    end
end

function c:SetItemFrameTipsFrameInfo(name,desc)
    self.insts.itemFrame_tipsFrame.name.Text = name
    self.insts.itemFrame_tipsFrame.desc.Text = desc
end

function c:SetItemFrameTipsFrameVisible(vis)
    self.insts.itemFrame_tipsFrame.Visible = vis
end

function c:BindItemFrameItemClickHandle(obj,handle)
    self.itemFrame_item_click_obj = obj
    self.itemFrame_item_click_handle = handle
end

function c:BindItemFrameItemMouseEnterHandle(obj,handle)
    self.__item_mouse_enter_obj = obj
    self.__item_mouse_enter_handle = handle

end

------------------------------------------ItemFrame_End--------
return c