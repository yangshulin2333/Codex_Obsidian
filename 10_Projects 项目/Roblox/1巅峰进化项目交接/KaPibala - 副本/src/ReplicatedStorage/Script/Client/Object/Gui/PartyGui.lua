local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Players
local players = game:GetService('Players')
---@type Player
local player = players.LocalPlayer
---@type Mouse
local mouse = player:GetMouse()
local GuiService = game:GetService("GuiService")

local tweenInfo = TweenInfo.new(0.2)

---@class PartyGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    

    ---@type ImageLabel		
	c.insts.mainBg = 'Frame.mainBg'    
    ---@type ImageButton		
	c.insts.mianBg_joinbtn = 'Frame.mainBg.left.btn'    
    ---@type ImageButton		
	c.insts.mainBg_createbtn = 'Frame.mainBg.right.btn'   
    ---@type ImageButton		
	c.insts.mainBg_close = 'Frame.mainBg.close'     

    ---@type ImageLabel		
	c.insts.joinSelectStageBg = 'Frame.joinSelectStageBg'    
    ---@type Frame		
	c.insts.joinSelectStageBg_list = 'Frame.joinSelectStageBg.list'   
    ---@type ImageButton		
	c.insts.joinSelectStageBg_close = 'Frame.joinSelectStageBg.close'     
    ---@type Frame		
	c.insts.joinSelectStageBg_item = 'Frame.joinSelectStageBg.list.item'   
    ---@type ImageButton		
	c.insts.joinSelectStageBg_backBtn = 'Frame.joinSelectStageBg.backBtn'    
    
    ---@type ImageLabel		
	c.insts.joinSelectRoomBg = 'Frame.joinSelectRoomBg'    
    ---@type ScrollingFrame		
	c.insts.joinSelectRoomBg_scroll = 'Frame.joinSelectRoomBg.ScrollingFrame'   
    ---@type ImageButton		
	c.insts.joinSelectRoomBg_close = 'Frame.joinSelectRoomBg.close'  
    ---@type Frame		
	c.insts.joinSelectRoomBg_item = 'Frame.joinSelectRoomBg.ScrollingFrame.item'   
    ---@type TextLabel		
	c.insts.joinSelectRoomBg_tips = 'Frame.joinSelectRoomBg.tips'  
    ---@type ImageButton		
	c.insts.joinSelectRoomBg_backBtn = 'Frame.joinSelectRoomBg.backBtn'          

    ---@type ImageLabel		
	c.insts.roomBg = 'Frame.roomBg'  
    ---@type ImageButton		
	c.insts.roomBg_close = 'Frame.roomBg.close' 
    ---@type TextLabel		
	c.insts.roomBg_title = 'Frame.roomBg.title'     
    ---@type ImageLabel		
	c.insts.roomBg_right_icon = 'Frame.roomBg.right.icon'   
    ---@type TextLabel		
	c.insts.roomBg_right_name = 'Frame.roomBg.right.name'     
    ---@type Frame		
	c.insts.roomBg_lootlist = 'Frame.roomBg.right.loot.list'    
    ---@type Frame		
	c.insts.roomBg_lootitem = 'Frame.roomBg.right.loot.list.item'    
    ---@type ImageButton		
	c.insts.roomBg_StartBtn = 'Frame.roomBg.right.StartBtn'   
    ---@type ImageButton		
	c.insts.roomBg_LeaveBtn = 'Frame.roomBg.right.LeaveBtn'    
    ---@type ImageButton		
	c.insts.roomBg_delBtn = 'Frame.roomBg.right.delBtn'       
    ---@type Frame		
	c.insts.roomBg_left_list = 'Frame.roomBg.left.list'    
    ---@type Frame		
	c.insts.roomBg_left_item = 'Frame.roomBg.left.list.item'    
    ---@type ImageLabel		
	c.insts.roomBg_bossIcon = 'Frame.roomBg.right.bossIcon'    

    ---@type ImageLabel		
	c.insts.createSelectStageBg = 'Frame.createSelectStageBg'    
    ---@type Frame		
	c.insts.createSelectStageBg_list = 'Frame.createSelectStageBg.list'    
    ---@type Frame		
	c.insts.createSelectStageBg_item = 'Frame.createSelectStageBg.list.item'    
    ---@type ImageButton		
	c.insts.createSelectStageBg_close = 'Frame.createSelectStageBg.close'  
    ---@type ImageButton		
	c.insts.createSelectStageBg_backBtn = 'Frame.createSelectStageBg.backBtn'    

    ---@type ImageLabel		
	c.insts.createBg = 'Frame.createBg'    
    ---@type ImageLabel		
	c.insts.createBg_righticon = 'Frame.createBg.right.icon'      
    ---@type TextLabel		
	c.insts.createBg_rightname = 'Frame.createBg.right.name'    
    ---@type Frame		
	c.insts.createBg_lootlist = 'Frame.createBg.right.loot.list'     
    ---@type Frame		
	c.insts.createBg_lootitem = 'Frame.createBg.right.loot.list.item'    
    ---@type ImageButton		
	c.insts.createBg_createBtn = 'Frame.createBg.right.createBtn'    
    ---@type TextBox		
	c.insts.createBg_TextBox = 'Frame.createBg.left.TextBox'   
    ---@type ImageButton		
	c.insts.createBg_btn1 = 'Frame.createBg.left.btn1'    
    ---@type ImageButton		
	c.insts.createBg_btn2 = 'Frame.createBg.left.btn2'    
    ---@type ImageButton		
	c.insts.createBg_btn3 = 'Frame.createBg.left.btn3'    
    ---@type ImageButton		
	c.insts.createBg_btn4 = 'Frame.createBg.left.btn4'    
    ---@type ImageButton		
	c.insts.createBg_btn5 = 'Frame.createBg.left.btn5'    
    ---@type ImageButton		
	c.insts.createBg_btn6 = 'Frame.createBg.left.btn6'    
    ---@type ImageButton		
	c.insts.createBg_close = 'Frame.createBg.close'    
    ---@type TextLabel		
	c.insts.createBg_diffDes = 'Frame.createBg.left.diffDes'    
    ---@type ImageButton		
	c.insts.createBg_backBtn = 'Frame.createBg.backBtn'  
    ---@type ImageLabel		
	c.insts.createBg_bossIcon = 'Frame.createBg.right.bossIcon'      

    ---@type ImageLabel		
	c.insts.boxtipsFrame = 'Frame.boxtipsFrame'    
    ---@type ImageLabel		
	c.insts.relicstipsFrame = 'Frame.relicstipsFrame'    
    ---@type ImageLabel		
	c.insts.chaTipsFrame = 'Frame.chaTipsFrame'   
    ---@type ImageLabel		
	c.insts.suitFrame = 'Frame.relicstipsFrame.suitFrame'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.PartyGui',_G.Resource)
    c.super.ctor(self,ui)

    self.typeBtns = {self.insts.createBg_btn1,self.insts.createBg_btn2,self.insts.createBg_btn3,}
    self.difficultyBtns = {self.insts.createBg_btn4,self.insts.createBg_btn5,self.insts.createBg_btn6,}

    -- self.insts.mianBg_joinbtn.MouseButton1Click:Connect(function()
    --     self:SetMainBgVisible(false)
    --     self:SetJoinSelectStageBgVisible(true)
    -- end)
    -- self.insts.mainBg_createbtn.MouseButton1Click:Connect(function()
    --     self:SetMainBgVisible(false)
    --     self:SetCreateSelectStageBgVisible(true)
    -- end)
    self.insts.joinSelectStageBg_backBtn.MouseButton1Click:Connect(function()
        self:SetMainBgVisible(true)
        self:SetJoinSelectStageBgVisible(false)
    end)
    self.insts.joinSelectRoomBg_backBtn.MouseButton1Click:Connect(function()
        -- self:SetJoinSelectStageBgVisible(true)
        self:SetMainBgVisible(true)
        self:SetJoinSelectRoomBgVisible(false)
    end)
    self.insts.createSelectStageBg_backBtn.MouseButton1Click:Connect(function()
        self:SetCreateSelectStageBgVisible(false)
        self:SetMainBgVisible(true)
    end)
    self.insts.createBg_backBtn.MouseButton1Click:Connect(function()
        -- self:SetCreateSelectStageBgVisible(true)
        self:SetMainBgVisible(true)
        self:SetCreateBgVisible(false)
    end)
    self.insts.createBg_close.MouseButton1Click:Connect(function()
        self:Hide()
        self:Close()
    end)
    self.insts.mainBg_close.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    self.insts.roomBg_close.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    self.insts.joinSelectRoomBg_close.MouseButton1Click:Connect(function()
        self:Hide()
        self:Close()
    end)
    self.insts.joinSelectStageBg_close.MouseButton1Click:Connect(function()
        self:Hide()
        self:Close()
    end)
    self.insts.createSelectStageBg_close.MouseButton1Click:Connect(function()
        self:Hide()
        self:Close()
    end)

    self.suit_name_list = {}
    self.suit_eff_list = {}
end

function c:Show()
    self.insts.Frame.Position = UDim2.fromScale(0.5,0.7)
    c.super.Show(self)
    TweenHelper:PlayTween(
        self.insts.Frame,
        tweenInfo,
        {Position = UDim2.fromScale(0.5,0.5)}
    )
    ui_manager.ui_list.hud_gui:Hide()
end

function c:Hide()
    TweenHelper:PlayTween(
        self.insts.Frame,
        tweenInfo,
        {Position = UDim2.fromScale(0.5,0.7)},
        function()
            c.super.Hide(self)
        end
    )
    ui_manager.ui_list.hud_gui:Show()
end

function c:Close()
    self:SetMainBgVisible(true)
    self:SetJoinSelectRoomBgVisible(false)
    self:SetJoinSelectStageBgVisible(false)
    self:SetCreateSelectStageBgVisible(false)
    self:SetCreateBgVisible(false)
end

---------------------------------------------Tips
function c:SetRelicstipsFrameInfo(info,suitInfo)
    local len = #info.list
    self.insts.relicstipsFrame.name.Text = info.name

    for i = 1,7 do
        local color = self.insts.relicstipsFrame.name:FindFirstChild(tostring(i))
        color.Enabled = i == info.quality
    end

    local ui
    for i = 1,4 do
        ui = self.insts.relicstipsFrame:FindFirstChild(tostring(i))
        ui.Visible = i == len
    end

    ui = self.insts.relicstipsFrame:FindFirstChild(tostring(len))

    for k,v in ipairs(info.list)do
        local TextLabel = ui:FindFirstChild('info'..k)
        if TextLabel then
            TextLabel.Text = v
        end
    end

    local sf = self.insts.suitFrame
    if suitInfo then
        for k,v in pairs(self.suit_eff_list)do
            k:Destroy()
        end
        self.suit_eff_list = {}
        for k,v in pairs(self.suit_name_list)do
            k:Destroy()
        end
        self.suit_name_list = {}

        sf.title.Text = suitInfo.title

        local item1 = sf.suitNameList.item
        for i,v in pairs(suitInfo.nameList)do
            local u = item1:Clone()
            u.Parent = sf.suitNameList
            u.Visible = true
            u.Text = i
            self.suit_name_list[u] = true
        end

        local item2 = sf.suitList.ScrollingFrame.Titleitem
        local item3 = sf.suitList.ScrollingFrame.effectitem
        for i,v in ipairs(suitInfo.suitScroll)do
            local u = nil
            if v.is_title then
                u = item2:Clone()
            else
                u = item3:Clone()
            end
            u.Parent = sf.suitList.ScrollingFrame
            u.Visible = true
            u.LayoutOrder = i
            u.Text = v.text
            self.suit_eff_list[u] = true
        end

        self:SetSuitFrameVisible(true)
    else
        self:SetSuitFrameVisible(false)
    end
end

function c:SetBoxtipsFrameInfo(info)
    self.insts.boxtipsFrame.name.Text = info.name
    for k,v in ipairs(info.list)do
        local ui = self.insts.boxtipsFrame.list:FindFirstChild('item'..k)
        if ui then
            ui.icon.Image = v.icon
            ui.name.Text = v.name
            ui.per.Text = string.format('%.2f%%',v.per)
        end
    end
end

function c:SetChaTipsFrameInfo(info)
    self.insts.chaTipsFrame.name.Text = info.name
    self.insts.chaTipsFrame.desc.Text = info.desc
end

function c:SetRelicstipsFrameVisible(vis)
    self.insts.relicstipsFrame.Visible = vis
end

function c:SetBoxtipsFrameVisible(vis)
    self.insts.boxtipsFrame.Visible = vis
end

function c:SetChaTipsFrameVisible(vis)
    self.insts.chaTipsFrame.Visible = vis
end

---------------------------------------------mainBg_Start
--设置mainBg的显示
function c:SetMainBgVisible(visible)
    self.insts.mainBg.Visible = visible
    self:SetChaTipsFrameVisible(false)
    self:SetRelicstipsFrameVisible(false)
    self:SetBoxtipsFrameVisible(false)
end

function c:BindMainBgCreateBtnClickHandle(obj,handle)
    self.insts.mainBg_createbtn.MouseButton1Click:Connect(function()
        if handle then
            handle(obj)
        end
    end)
end

function c:BindMainBgJoinBtnClickHandle(obj,handle)
    self.insts.mianBg_joinbtn.MouseButton1Click:Connect(function()
        if handle then
            handle(obj)
        end
    end)
end
---------------------------------------------mainBg_End

---------------------------------------------joinSelectStageBg_Start
--设置joinSelectStageBg的显示
function c:SetJoinSelectStageBgVisible(visible)
    self.insts.joinSelectStageBg.Visible = visible
    self:SetChaTipsFrameVisible(false)
    self:SetRelicstipsFrameVisible(false)
    self:SetBoxtipsFrameVisible(false)
end

--向joinSelectStageBg_list添加子项
function c:AddJoinSelectStageBgItem(id,icon,bossIcon,name,lv)
    local ui = hotpot:CloneInst_Loop(self.insts.joinSelectStageBg_item)
    ui.Name = id
    ui.Visible = true
    ui.bg.icon.Image = icon or ''
    ui.bg.bossIcon.Image = bossIcon or ''
    ui.bg.name.Text = name
    ui.bg.lv.Text = 'Level '..lv..'+'
    ui.Parent = self.insts.joinSelectStageBg_list
    ui.bg.btn.MouseButton1Click:Connect(function()
        if self.__joinSelectStageBgItemHandle then
            self.__joinSelectStageBgItemHandle(self.__joinSelectStageBgItemObj,id)
        end
    end)
end

--绑定joinSelectStageBgItem按钮点击事件
function c:BindJoinSelectStageBgItemClickHandle(obj,handle)
    self.__joinSelectStageBgItemHandle = handle
    self.__joinSelectStageBgItemObj = obj
end
---------------------------------------------joinSelectStageBg_End

---------------------------------------------joinSelectRoomBg_Start
--设置joinSelectRoomBg的显示
function c:SetJoinSelectRoomBgVisible(visible)
    self.insts.joinSelectRoomBg.Visible = visible
    self:SetChaTipsFrameVisible(false)
    self:SetRelicstipsFrameVisible(false)
    self:SetBoxtipsFrameVisible(false)
    self:CheckJoinSelectRoomBgTips()
end

--设置joinSelectRoomBg_tips的显示
function c:SetJoinSelectRoomBgTipsVisible(visible)
    self.insts.joinSelectRoomBg_tips.Visible = visible
end

--设置joinSelectRoomBg_tips的显示
function c:SetJoinSelectRoomBgTips(tips)
    self.insts.joinSelectRoomBg_tips.Text = tips
end

--向joinSelectRoomBg_list添加子项
function c:AddJoinSelectRoomBgItem(id,roomName,lv,icon,bossIcon,partyName,difficulty,playersNum)
    local ui = hotpot:CloneInst_Loop(self.insts.joinSelectRoomBg_item)
    ui.Name = id
    ui.Visible = true
    ui.bg.icon.Image = icon or ''
    ui.bg.bossIcon.Image = bossIcon or ''
    ui.bg.partyName.Text = partyName
    ui.bg.roomName.Text = roomName
    ui.bg.lv.Text = 'Level '..lv..'+'
    ui.bg.difficulty.Text = difficulty
    ui.bg.players.Text = playersNum .. '/4 Players'
    ui.Parent = self.insts.joinSelectRoomBg_scroll
    ui.bg.btn.MouseButton1Click:Connect(function()
        if self.__joinSelectRoomBgItemHandle then
            self.__joinSelectRoomBgItemHandle(self.__joinSelectRoomBgItemObj,id)
        end
    end)

    ui:SetAttribute('item',true)

    delay(0.05,function()
        self:CheckJoinSelectRoomBgTips()
    end)

    return ui
end

--设置joinSelectRoomBgItem的players
function c:SetJoinSelectRoomBgItemPlayers(id,playersNum)
    local ui = self.insts.joinSelectRoomBg_scroll:FindFirstChild(id)
    if ui then
        ui.bg.players.Text = playersNum .. '/4 Players'
    end
end

--删除joinSelectRoomBg_list的子项
function c:RemoveJoinSelectRoomBgItem(id)
    local ui = self.insts.joinSelectRoomBg_scroll:FindFirstChild(id)
    if ui then
        ui:Destroy()
    end

    delay(0.05,function()
        self:CheckJoinSelectRoomBgTips()
    end)
end

--检查Tips的显示
function c:CheckJoinSelectRoomBgTips()
    local vis = true
    for _,v in pairs(self.insts.joinSelectRoomBg_scroll:GetChildren()) do
        if v:GetAttribute('item') then
            if v.Visible then
                vis = false
            end
            break
        end
    end
    self:SetJoinSelectRoomBgTipsVisible(vis)
end

--删除所有joinSelectRoomBg_list的子项
function c:GetJoinSelectRoomBgAllItem()
    local list = {}
    for _,v in pairs(self.insts.joinSelectRoomBg_scroll:GetChildren()) do
        if v:GetAttribute('item') then
            table.insert(list,v)
        end
    end
    return list
end

--绑定joinSelectRoomBgItem按钮点击事件
function c:BindJoinSelectRoomBgItemClickHandle(obj,handle)
    self.__joinSelectRoomBgItemHandle = handle
    self.__joinSelectRoomBgItemObj = obj
end
---------------------------------------------joinSelectRoomBg_End

---------------------------------------------roomBg_Start
--设置roomBg的显示
function c:SetRoomBgVisible(visible)
    self.insts.roomBg.Visible = visible

    self:SetChaTipsFrameVisible(false)
    self:SetRelicstipsFrameVisible(false)
    self:SetBoxtipsFrameVisible(false)

    self:RemoveAllRoomBgLeftItem()
end

--设置roomBg的右侧信息
function c:SetRoomBgInfo(info)
    self:RemoveAllRoomBgLootItem()
    self.insts.roomBg_right_icon.Image = info.icon or ''
    self.insts.roomBg_right_name.Text = info.name
    self.insts.roomBg_bossIcon.Image = info.bossIcon or ''
    
    local list = info.list
    for k,v in ipairs(list)do
        local id = k
        local ui = hotpot:CloneInst_Loop(self.insts.roomBg_lootitem)
        ui.Name = k
        ui.Visible = true
        ui.icon.Image = v.icon
        ui.Parent = self.insts.roomBg_lootlist
        ui:SetAttribute('item',true)

        ui.icon.MouseEnter:Connect(function()
            if self.MouseIn_handle then
                self.MouseIn_handle(self.MouseIn_obj,id,info.cfgid)
            end
            local viewSize = workspace.CurrentCamera.ViewportSize
            local x = mouse.X
            local y = mouse.Y
            x = x + ui.icon.AbsoluteSize.X

            local a_pos = self.insts.Frame.AbsolutePosition
            local a_size = self.insts.Frame.AbsoluteSize

            local relicstipsSize = self.insts.relicstipsFrame.AbsoluteSize
            local chaTipsSize = self.insts.chaTipsFrame.AbsoluteSize
            local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

            local r_x = math.min(viewSize.X - relicstipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
            local b_x = math.min(viewSize.X - boxtipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
            local c_x = math.min(viewSize.X - chaTipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local c_y = math.min(viewSize.Y - chaTipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)

            if hotpot.is_mobile then
                b_y = b_y - 50
            end

            if self.suit_vis then
                local topbarInset = GuiService:GetGuiInset()
                local view = workspace.CurrentCamera.ViewportSize
                local suitSize = self.insts.suitFrame.AbsoluteSize
                local tipsSize = self.insts.relicstipsFrame.AbsoluteSize

                if r_x + tipsSize.X + suitSize.X > view.X then
                    r_x = view.X - tipsSize.X - suitSize.X - 5
                end
                if r_y + suitSize.Y > view.Y then
                    r_y = view.Y - suitSize.Y - 5 - topbarInset.Y
                end
            end

            r_x = (r_x - a_pos.X) / a_size.X 
            r_y = (r_y - a_pos.Y) / a_size.Y 
            c_x = (c_x - a_pos.X) / a_size.X 
            c_y = (c_y - a_pos.Y) / a_size.Y 
            b_x = (b_x - a_pos.X) / a_size.X 
            b_y = (b_y - a_pos.Y) / a_size.Y 

            self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
            self.insts.chaTipsFrame.Position = UDim2.fromScale(c_x,c_y)
            self.insts.boxtipsFrame.Position = UDim2.fromScale(b_x,b_y)
        end)
        ui.icon.MouseMoved:Connect(function()
            local viewSize = workspace.CurrentCamera.ViewportSize
            local x = mouse.X
            local y = mouse.Y
            x = x + ui.icon.AbsoluteSize.X

            local a_pos = self.insts.Frame.AbsolutePosition
            local a_size = self.insts.Frame.AbsoluteSize

            local relicstipsSize = self.insts.relicstipsFrame.AbsoluteSize
            local chaTipsSize = self.insts.chaTipsFrame.AbsoluteSize
            local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

            local r_x = math.min(viewSize.X - relicstipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
            local b_x = math.min(viewSize.X - boxtipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
            local c_x = math.min(viewSize.X - chaTipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local c_y = math.min(viewSize.Y - chaTipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)

            if hotpot.is_mobile then
                b_y = b_y - 50
            end

            if self.suit_vis then
                local topbarInset = GuiService:GetGuiInset()
                local view = workspace.CurrentCamera.ViewportSize
                local suitSize = self.insts.suitFrame.AbsoluteSize
                local tipsSize = self.insts.relicstipsFrame.AbsoluteSize

                if r_x + tipsSize.X + suitSize.X > view.X then
                    r_x = view.X - tipsSize.X - suitSize.X - 5
                end
                if r_y + suitSize.Y > view.Y then
                    r_y = view.Y - suitSize.Y - 5 - topbarInset.Y
                end
            end

            r_x = (r_x - a_pos.X) / a_size.X 
            r_y = (r_y - a_pos.Y) / a_size.Y 
            c_x = (c_x - a_pos.X) / a_size.X 
            c_y = (c_y - a_pos.Y) / a_size.Y 
            b_x = (b_x - a_pos.X) / a_size.X 
            b_y = (b_y - a_pos.Y) / a_size.Y 

            self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
            self.insts.chaTipsFrame.Position = UDim2.fromScale(c_x,c_y)
            self.insts.boxtipsFrame.Position = UDim2.fromScale(b_x,b_y)
        end)
        ui.icon.MouseLeave:Connect(function()
            self.insts.relicstipsFrame.Visible = false
            self.insts.chaTipsFrame.Visible = false
            self.insts.boxtipsFrame.Visible = false
        end)
    end
end

--移除所有roomBg_lootlist的子项
function c:RemoveAllRoomBgLootItem()
    for _,v in pairs(self.insts.roomBg_lootlist:GetChildren()) do
        if v.Name ~= 'UIGridLayout' then
            if v:GetAttribute('item') then
                v:Destroy()
            end
        end
    end
end

--向roomBg_left添加子项
function c:AddRoomBgLeftItem(uid,icon,lv,name,isOwner)
    local ui = hotpot:CloneInst_Loop(self.insts.roomBg_left_item)
    ui.Name = uid
    ui.Visible = true
    ui.bg.icon.Image = icon
    ui.bg.lv.Text = 'Level '..lv
    ui.bg.name.Text = name
    ui.Parent = self.insts.roomBg_left_list
    ui.bg.icon.crown.Visible = isOwner
    ui:SetAttribute('item',true)
end

--删除roomBg_left的子项
function c:RemoveRoomBgLeftItem(uid)
    local ui = self.insts.roomBg_left_list:FindFirstChild(uid)
    if ui then
        ui:Destroy()
    end
end

--删除所有roomBg_left的子项
function c:RemoveAllRoomBgLeftItem()
    for _,v in pairs(self.insts.roomBg_left_list:GetChildren()) do
        if v.Name ~= 'UIListLayout' then
            if v:GetAttribute('item') then
                v:Destroy()
            end
        end
    end
end

--设置StartPartyBtn的显示
function c:SetStartPartyBtnVisible(vis)
    self.insts.roomBg_StartBtn.Visible = vis
end

--设置LeavePartyBtn的显示
function c:SetLeavePartyBtnVisible(vis)
    self.insts.roomBg_LeaveBtn.Visible = vis
end

--设置delPartyBtn的显示
function c:SetDelPartyBtnVisible(vis)
    self.insts.roomBg_delBtn.Visible = vis
end

--绑定StartBtn按钮点击事件
function c:BindStartBtnClickHandle(obj,handle)
    self.insts.roomBg_StartBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定LeaveBtn按钮点击事件
function c:BindLeaveBtnClickHandle(obj,handle)
    self.insts.roomBg_LeaveBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

--绑定DelBtn按钮点击事件
function c:BindDelBtnClickHandle(obj,handle)
    self.insts.roomBg_delBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end
---------------------------------------------roomBg_End

---------------------------------------------createSelectStageBg_Start
--设置createSelectStageBg的显示
function c:SetCreateSelectStageBgVisible(visible)
    self.insts.createSelectStageBg.Visible = visible
    self:SetChaTipsFrameVisible(false)
    self:SetRelicstipsFrameVisible(false)
    self:SetBoxtipsFrameVisible(false)
end

--向createSelectStageBg_list添加子项
function c:AddCreateSelectStageBgItem(id,icon,bossIcon,name,lv)
    local ui = hotpot:CloneInst_Loop(self.insts.createSelectStageBg_item)
    ui.Name = id
    ui.Visible = true
    ui.bg.icon.Image = icon or ''
    ui.bg.bossIcon.Image = bossIcon or ''
    ui.bg.name.Text = name
    ui.bg.lv.Text = 'Level '..lv..'+'
    ui.Parent = self.insts.createSelectStageBg_list
    ui.bg.btn.MouseButton1Click:Connect(function()
        if self.__createSelectStageBgItemHandle then
            self.__createSelectStageBgItemHandle(self.__createSelectStageBgItemObj,id)
        end
    end)
end

--绑定createSelectStageBgItem按钮点击事件
function c:BindCreateSelectStageBgItemClickHandle(obj,handle)
    self.__createSelectStageBgItemHandle = handle
    self.__createSelectStageBgItemObj = obj
end
---------------------------------------------createSelectStageBg_End

---------------------------------------------createBg_Start
--设置createBg的显示
function c:SetCreateBgVisible(visible)
    self.insts.createBg.Visible = visible

    self:SetChaTipsFrameVisible(false)
    self:SetRelicstipsFrameVisible(false)
    self:SetBoxtipsFrameVisible(false)

    for k,v in ipairs(self.typeBtns)do
        if k == 1 then
            v.Image = 'rbxassetid://111460696655002'
            v.row.Visible = true
        else
            v.Image = 'rbxassetid://106699665783834'
            v.row.Visible = false
        end
    end
    for k,v in ipairs(self.difficultyBtns)do
        if k == 1 then
            v.Image = 'rbxassetid://111460696655002'
            v.row.Visible = true
        else
            v.Image = 'rbxassetid://106699665783834'
            v.row.Visible = false
        end
    end
end

--设置createBg的右侧信息
function c:SetCreateBgInfo(info)
    self:RemoveAllCreateBgLootItem()
    self.insts.createBg_righticon.Image = info.icon or ''
    self.insts.createBg_rightname.Text = info.name
    self.insts.createBg_bossIcon.Image = info.bossIcon or ''
    
    local list = info.list
    for k,v in ipairs(list)do
        local ui = hotpot:CloneInst_Loop(self.insts.createBg_lootitem)
        ui.Name = k
        ui.Visible = true
        ui.icon.Image = v.icon
        ui.Parent = self.insts.createBg_lootlist
        ui:SetAttribute('item',true)
        local id = k
        ui.icon.MouseEnter:Connect(function()
            if self.MouseIn_handle then
                self.MouseIn_handle(self.MouseIn_obj,id,info.cfgid)
            end

            local viewSize = workspace.CurrentCamera.ViewportSize
            local x = mouse.X
            local y = mouse.Y
            x = x + ui.icon.AbsoluteSize.X
            

            local a_pos = self.insts.Frame.AbsolutePosition
            local a_size = self.insts.Frame.AbsoluteSize

            local relicstipsSize = self.insts.relicstipsFrame.AbsoluteSize
            local chaTipsSize = self.insts.chaTipsFrame.AbsoluteSize
            local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

            local r_x = math.min(viewSize.X - relicstipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
            local b_x = math.min(viewSize.X - boxtipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
            local c_x = math.min(viewSize.X - chaTipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local c_y = math.min(viewSize.Y - chaTipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)

            if hotpot.is_mobile then
                b_y = b_y - 50
            end

            if self.suit_vis then
                local topbarInset = GuiService:GetGuiInset()
                local view = workspace.CurrentCamera.ViewportSize
                local suitSize = self.insts.suitFrame.AbsoluteSize
                local tipsSize = self.insts.relicstipsFrame.AbsoluteSize

                if r_x + tipsSize.X + suitSize.X > view.X then
                    r_x = view.X - tipsSize.X - suitSize.X - 5
                end
                if r_y + suitSize.Y > view.Y then
                    r_y = view.Y - suitSize.Y - 5 - topbarInset.Y
                end
            end

            r_x = (r_x - a_pos.X) / a_size.X 
            r_y = (r_y - a_pos.Y) / a_size.Y 
            c_x = (c_x - a_pos.X) / a_size.X 
            c_y = (c_y - a_pos.Y) / a_size.Y 
            b_x = (b_x - a_pos.X) / a_size.X 
            b_y = (b_y - a_pos.Y) / a_size.Y 

            self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
            self.insts.chaTipsFrame.Position = UDim2.fromScale(c_x,c_y)
            self.insts.boxtipsFrame.Position = UDim2.fromScale(b_x,b_y)
        end)
        ui.icon.MouseMoved:Connect(function()
            local viewSize = workspace.CurrentCamera.ViewportSize
            local x = mouse.X
            local y = mouse.Y
            x = x + ui.icon.AbsoluteSize.X

            local a_pos = self.insts.Frame.AbsolutePosition
            local a_size = self.insts.Frame.AbsoluteSize

            local relicstipsSize = self.insts.relicstipsFrame.AbsoluteSize
            local chaTipsSize = self.insts.chaTipsFrame.AbsoluteSize
            local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

            local r_x = math.min(viewSize.X - relicstipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
            local b_x = math.min(viewSize.X - boxtipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
            local c_x = math.min(viewSize.X - chaTipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
            local c_y = math.min(viewSize.Y - chaTipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)

            if hotpot.is_mobile then
                b_y = b_y - 50
            end

            if self.suit_vis then
                local topbarInset = GuiService:GetGuiInset()
                local view = workspace.CurrentCamera.ViewportSize
                local suitSize = self.insts.suitFrame.AbsoluteSize
                local tipsSize = self.insts.relicstipsFrame.AbsoluteSize

                if r_x + tipsSize.X + suitSize.X > view.X then
                    r_x = view.X - tipsSize.X - suitSize.X - 5
                end
                if r_y + suitSize.Y > view.Y then
                    r_y = view.Y - suitSize.Y - 5 - topbarInset.Y
                end
            end

            r_x = (r_x - a_pos.X) / a_size.X 
            r_y = (r_y - a_pos.Y) / a_size.Y 
            c_x = (c_x - a_pos.X) / a_size.X 
            c_y = (c_y - a_pos.Y) / a_size.Y 
            b_x = (b_x - a_pos.X) / a_size.X 
            b_y = (b_y - a_pos.Y) / a_size.Y 

            self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
            self.insts.chaTipsFrame.Position = UDim2.fromScale(c_x,c_y)
            self.insts.boxtipsFrame.Position = UDim2.fromScale(b_x,b_y)
        end)
        ui.icon.MouseLeave:Connect(function()
            self.insts.relicstipsFrame.Visible = false
            self.insts.chaTipsFrame.Visible = false
            self.insts.boxtipsFrame.Visible = false
        end)
    end
end

--清除所有loot子项
function c:RemoveAllCreateBgLootItem()
    for _,v in pairs(self.insts.createBg_lootlist:GetChildren()) do
        if v.Name ~= 'UIGridLayout' then
            if v:GetAttribute('item') then
                v:Destroy()
            end
        end
    end
end

--设置房间名字
function c:SetCreateBgRoomName(name)
    self.insts.createBg_TextBox.PlaceholderText = name .. "'s Party"
end

--获取房间名字
function c:GetCreateBgRoomName()
    return self.insts.createBg_TextBox.Text or self.insts.createBg_TextBox.PlaceholderText
end

--设置createBg的难度描述
function c:SetCreateBgDiffDes(des)
    self.insts.createBg_diffDes.Text = des
end

--绑定CreateBgType按钮点击事件
function c:BindCreateBgTypeBtnClickHandle(obj,handle)
    for k,v in ipairs(self.typeBtns)do
        local id = k
        v.MouseButton1Click:Connect(function()
            handle(obj,id)
            for k2,v2 in ipairs(self.typeBtns)do
                if k2 == id then
                    v2.Image = 'rbxassetid://111460696655002'
                    v2.row.Visible = true
                else
                    v2.Image = 'rbxassetid://106699665783834'
                    v2.row.Visible = false
                end
            end
        end)
    end
end

--绑定CreateBgDifficulty按钮点击事件
function c:BindCreateBgDifficultyBtnClickHandle(obj,handle)
    for k,v in ipairs(self.difficultyBtns)do
        local id = k
        v.MouseButton1Click:Connect(function()
            handle(obj,id)
            for k2,v2 in ipairs(self.difficultyBtns)do
                if k2 == id then
                    v2.Image = 'rbxassetid://111460696655002'
                    v2.row.Visible = true
                else
                    v2.Image = 'rbxassetid://106699665783834'
                    v2.row.Visible = false
                end
            end
        end)
    end
end

--绑定CreateBgCreateBtn按钮点击事件
function c:BindCreateBgCreateBtnClickHandle(obj,handle)
    self.insts.createBg_createBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end
---------------------------------------------createBg_End

--绑定鼠标进入事件
function c:BindMouseInHandle(obj,handle)
    self.MouseIn_handle = handle
    self.MouseIn_obj = obj
end

--设置suitFrame的显示
function c:SetSuitFrameVisible(vis)
    self.suit_vis = vis
    self.insts.suitFrame.Visible = vis
end

return c