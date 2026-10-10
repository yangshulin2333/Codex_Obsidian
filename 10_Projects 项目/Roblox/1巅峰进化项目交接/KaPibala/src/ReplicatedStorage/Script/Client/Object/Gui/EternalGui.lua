local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type BigNumberHelper
local bigNumber = hotpot.load.BigNumberHelper()
---@type BtnHelper
local BtnHelper = hotpot.load.BtnHelper()
---@type Players
local players = game:GetService('Players')
---@type Player
local player = players.LocalPlayer
---@type Mouse
local mouse = player:GetMouse()

local tweenInfo = TweenInfo.new(0.2)
local lv_str = 'LV%s  EXP:%s/%s'
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class EternalGui:HotpotScreenBase
local c = hotpot.class.new(script, hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.close = 'Frame.bg.close'    
    ---@type ImageButton		
	c.insts.double_btn = 'Frame.bg.doubleCoins.btn'   
    ---@type TextLabel		
	c.insts.double_owned = 'Frame.bg.doubleCoins.owned'   
    ---@type TextLabel		
	c.insts.double_price = 'Frame.bg.doubleCoins.price'      

    ---@type ImageButton		
	c.insts.passBtn = 'Frame.bg.passBtn'    
    ---@type ImageButton		
	c.insts.shopBtn = 'Frame.bg.shopBtn'   
    ---@type ImageButton		
	c.insts.spinBtn = 'Frame.bg.spinBtn'    
    ---@type ImageButton		
	c.insts.taskBtn = 'Frame.bg.taskBtn'    
    ---@type TextLabel		
	c.insts.coinsNum = 'Frame.bg.coins.num'    

    ---@type Frame		
	c.insts.passFrame = 'Frame.bg.passFrame'        
    ---@type ImageLabel		
	c.insts.passFrame_left = 'Frame.bg.passFrame.left'    
    ---@type Frame		
	c.insts.passFrame_left_proBg = 'Frame.bg.passFrame.left.proBg'    
    ---@type Frame		
	c.insts.passFrame_left_proFg = 'Frame.bg.passFrame.left.proBg.proFg'    
    ---@type TextLabel		
	c.insts.passFrame_left_Pronum = 'Frame.bg.passFrame.left.proBg.num'    
    ---@type ImageButton		
	c.insts.passFrame_left_primium_buyBtn = 'Frame.bg.passFrame.left.premium.buyBtn'    
    ---@type TextLabel		
	c.insts.passFrame_left_primium_owned = 'Frame.bg.passFrame.left.premium.owned'    
    ---@type ScrollingFrame		
	c.insts.passFrame_ScrollingFrame = 'Frame.bg.passFrame.scroll.ScrollingFrame'   
    ---@type Frame		
	c.insts.passFrame_scroll_item = 'Frame.bg.passFrame.scroll.ScrollingFrame.item'     
    ---@type Frame		
	c.insts.passFrame_last = 'Frame.bg.passFrame.scroll.ScrollingFrame.last'    

    ---@type Frame		
	c.insts.taskFrame = 'Frame.bg.taskFrame'    
    ---@type Frame		
	c.insts.hourTask = 'Frame.bg.taskFrame.ScrollingFrame.hourTask'    
    ---@type Frame		
	c.insts.hourTask_list = 'Frame.bg.taskFrame.ScrollingFrame.hourTask.bg.list'    
    ---@type Frame		
	c.insts.hourTask_item = 'Frame.bg.taskFrame.ScrollingFrame.hourTask.bg.list.item'    
    ---@type TextLabel		
	c.insts.hourTask_refresh = 'Frame.bg.taskFrame.ScrollingFrame.hourTask.bg.title.refresh'   
    ---@type Frame		
	c.insts.dailyTask = 'Frame.bg.taskFrame.ScrollingFrame.dailyTask'    
    ---@type Frame		
	c.insts.dailyTask_list = 'Frame.bg.taskFrame.ScrollingFrame.dailyTask.bg.list'    
    ---@type Frame		
	c.insts.dailyTask_item = 'Frame.bg.taskFrame.ScrollingFrame.dailyTask.bg.list.item'    
    ---@type TextLabel		
	c.insts.dailyTask_refresh = 'Frame.bg.taskFrame.ScrollingFrame.dailyTask.bg.title.refresh'   
    ---@type ImageButton		
	c.insts.buyRefreshBtn = 'Frame.bg.taskFrame.ScrollingFrame.buyFrame.bg.buyBtn'    

    ---@type Frame		
	c.insts.spinFrame = 'Frame.bg.spinFrame'    
    ---@type ImageButton		
	c.insts.spin_use1 = 'Frame.bg.spinFrame.left.use1'    
    ---@type ImageButton		
	c.insts.spin_useall = 'Frame.bg.spinFrame.left.useall'    
    ---@type TextLabel		
	c.insts.spin_ticketNum = 'Frame.bg.spinFrame.left.ticket.num'    
    ---@type ImageLabel		
	c.insts.spin_rotate = 'Frame.bg.spinFrame.right.bg.rotate'   
    ---@type Frame		
	c.insts.spin_r1 = 'Frame.bg.spinFrame.right.bg.rotate.r1'   
    ---@type Frame		
	c.insts.spin_r2 = 'Frame.bg.spinFrame.right.bg.rotate.r2'   
    ---@type Frame		
	c.insts.spin_r3 = 'Frame.bg.spinFrame.right.bg.rotate.r3'   
    ---@type Frame		
	c.insts.spin_r4 = 'Frame.bg.spinFrame.right.bg.rotate.r4'   
    ---@type Frame		
	c.insts.spin_r5 = 'Frame.bg.spinFrame.right.bg.rotate.r5'   

    ---@type Frame		
	c.insts.shopFrame = 'Frame.bg.shopFrame'    
    ---@type Frame		
	c.insts.shopEgglist = 'Frame.bg.shopFrame.scroll.egg.list'    
    ---@type Frame		
	c.insts.shopEggitem = 'Frame.bg.shopFrame.scroll.egg.list.item'   
    ---@type Frame		
	c.insts.shoplist = 'Frame.bg.shopFrame.scroll.list'     
    ---@type Frame		
	c.insts.shopListitem = 'Frame.bg.shopFrame.scroll.list.item'  
    ---@type ImageButton		
	c.insts.shopEggbtn1 = 'Frame.bg.shopFrame.scroll.egg.btn1'  
    ---@type ImageButton		
	c.insts.shopEggbtn3 = 'Frame.bg.shopFrame.scroll.egg.btn3' 
    ---@type ImageButton		
	c.insts.shopEggbtn10 = 'Frame.bg.shopFrame.scroll.egg.btn10'       
    
    ---@type ImageLabel		
	c.insts.pettipsFrame = 'Frame.bg.pettipsFrame'   
    ---@type ImageLabel		
	c.insts.relicstipsFrame = 'Frame.bg.relicstipsFrame'   
    ---@type ImageLabel		
	c.insts.tipsFrame1 = 'Frame.bg.tipsFrame1'    
    ---@type ImageLabel		
	c.insts.boxtipsFrame = 'Frame.bg.boxtipsFrame'     
    
    ---@type TextLabel		
	c.insts.cd = 'Frame.bg.cd'    

    ---@type ImageButton		
	c.insts.GiftBtn = 'Frame.bg.GiftBtn'    

    ---@type ImageLabel		
	c.insts.selectPlayerBg = 'Frame.selectPlayerBg'    
    ---@type ScrollingFrame		
	c.insts.selectPlayerBg_ScrollingFrame = 'Frame.selectPlayerBg.ScrollingFrame'    
    ---@type Frame		
	c.insts.selectPlayerBg_item = 'Frame.selectPlayerBg.ScrollingFrame.item'    
    ---@type ImageButton		
	c.insts.selectPlayerBg_closeBtn = 'Frame.selectPlayerBg.closeBtn'   
    
    ---@type ImageButton		
	c.insts.cancelBtn = 'Frame.bg.cancelBtn'    
    ---@type TextLabel		
	c.insts.cancelBtn_info = 'Frame.bg.cancelBtn.info'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.EternalGui',hotpot.resource)
    c.super.ctor(self,ui,true)

    self.bp_item_list = {}
    self.task_item_list = {}
    self.now_angle = 0
    self.shop_item_list = {}
    self.selectPlayerList = {}
    for k,v in ipairs(players:GetPlayers())do
        if v ~= player then
            self:AddItemInPlayerBg(v)
        end
    end
    players.PlayerAdded:Connect(function(player)
        self:AddItemInPlayerBg(player)
    end)
    players.PlayerRemoving:Connect(function(player)
        self:RemoveItemInPlayerBg(player)
    end)

    self.insts.close.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    local btns = {self.insts.passBtn,self.insts.shopBtn,self.insts.spinBtn,self.insts.taskBtn}
    local funs = {self.SetBattlePassFrameVisible,self.SetShopFrameVisible,self.SetSpinFrameVisible,self.SetTaskFrameVisible}
    for k,v in ipairs(btns) do
        local btn = v
        btn.MouseButton1Click:Connect(function()
            for _,b in ipairs(btns)do
                if b == btn then
                    b.ImageTransparency = 0
                    b.info.TextColor3 = Color3.fromRGB(255,255,255)
                else
                    b.ImageTransparency = 1
                    b.info.TextColor3 = Color3.fromRGB(176,176,176)
                end
            end
            for i,fun in ipairs(funs)do
                fun(self,i == k)
            end
            self.insts.pettipsFrame.Visible = false
            self.insts.relicstipsFrame.Visible = false
            self.insts.tipsFrame1.Visible = false
            self.insts.boxtipsFrame.Visible = false
        end)
    end

    self.top_btns = btns
    self.top_funs = funs

    self.insts.cancelBtn.MouseButton1Click:Connect(function()
        self.insts.cancelBtn.Visible = false
        self.insts.GiftBtn.Visible = true
        self:SetGiftIconVisible(false)
        if self.__cancelBtnClickHandle then
            self.__cancelBtnClickHandle(self.__cancelBtnClickObj)
        end
    end)
end

function c:Show()
    self.insts.Frame.Position = UDim2.fromScale(0.5,0.7)
    c.super.Show(self)
    ui_manager.ui_list.hud_gui:Hide()
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
        {Position = UDim2.fromScale(0.5,0.7)},
        function()
            c.super.Hide(self)
        end
    )
    ui_manager.ui_list.hud_gui:Show()

    self.now_angle = 0
    self.insts.spin_rotate.Rotation = 0

    self.insts.pettipsFrame.Visible = false
    self.insts.relicstipsFrame.Visible = false
    self.insts.tipsFrame1.Visible = false
    self.insts.boxtipsFrame.Visible = false

    self.insts.cancelBtn.Visible = false
    self.insts.GiftBtn.Visible = true
    self:SetGiftIconVisible(false)
    if self.__cancelBtnClickHandle then
        self.__cancelBtnClickHandle(self.__cancelBtnClickObj)
    end
end

function c:ClickTop(idx)
    for k,v in ipairs(self.top_btns)do
        if k == idx then
            v.ImageTransparency = 0
            v.info.TextColor3 = Color3.fromRGB(255,255,255)
        else
            v.ImageTransparency = 1
            v.info.TextColor3 = Color3.fromRGB(176,176,176)
        end
    end
    for i,fun in ipairs(self.top_funs)do
        fun(self,i == idx)
    end
    self.insts.pettipsFrame.Visible = false
    self.insts.relicstipsFrame.Visible = false
    self.insts.tipsFrame1.Visible = false
    self.insts.boxtipsFrame.Visible = false
end

--设置selectPlayerBgVisible
function c:SetSelectPlayerBgVisible(visible)
    self.insts.selectPlayerBg.Visible = visible
end

--向player添加item
---@param player Player
function c:AddItemInPlayerBg(player)
    self:AddProcess(function()
        local ui  = hotpot:CloneInst_Loop(self.insts.selectPlayerBg_item)
        ui.Visible = true
        ui.Name = player.UserId
        ui.Parent = self.insts.selectPlayerBg_ScrollingFrame
        local r,e = pcall(function()
            return players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size80x80)
        end)
        if not r then
            e = ''
        end
        ui.bg.icon.Image = e
        ui.bg.name1.Text = player.DisplayName
        ui.bg.name2.Text = player.Name
        self.selectPlayerList[player] = ui

        ui.bg.btn.MouseButton1Click:Connect(function()
            if self.__selectPlayerItemClickHandle and self.__selectPlayerItemClickObj then
                self.__selectPlayerItemClickHandle(self.__selectPlayerItemClickObj,player)
            end 
            self:ClickTop(1)
            self:SetGiftIconVisible(true)
            self:SetDoubleCoinsOwnedVisible(false)
            self:SetPassFramePremiumOwnedVisible(false)
        end)
    end)
end

--移除玩家item
function c:RemoveItemInPlayerBg(player)
    if self.selectPlayerList[player] then
        self.selectPlayerList[player]:Destroy()
        self.selectPlayerList[player] = nil
    end
end

function c:SetGiftIconVisible(vis)
    for k,v in ipairs(self.insts.bg:GetDescendants())do
        if v:IsA('ImageLabel') and v.Name == 'giftIcon' then
            v.Visible = vis
        end
    end
end

--设置赠送玩家的名字
function c:SetGiftPlayerName(name)
    self.insts.bg.Visible = true
    self:SetSelectPlayerBgVisible(false)
    self.insts.GiftBtn.Visible = false
    self.insts.cancelBtn.Visible = true
    self.insts.cancelBtn_info.Text = 'Gifting to:'..name
end

function c:SetCoinNum(num)
    self.insts.coinsNum.Text = bigNumber:ToString(num)
end

function c:SetDoubleCoinsOwnedVisible(vis)
    self.insts.double_owned.Visible = vis
    self.insts.double_price.Visible = not vis
end

function c:SetBattlePassFrameVisible(vis)
    if vis then
        self.insts.passFrame.Size = UDim2.fromScale(0,0)
        self.insts.passFrame.Visible = true
        TweenHelper:PlayTween(
            self.insts.passFrame,
            tweenInfo,
            {Size = UDim2.fromScale(0.98,0.722)}
        )
    else
        self.insts.passFrame.Visible = false
    end
end

function c:SetTaskFrameVisible(vis)
    if vis then
        self.insts.taskFrame.Size = UDim2.fromScale(0,0)
        self.insts.taskFrame.Visible = true
        TweenHelper:PlayTween(
            self.insts.taskFrame,
            tweenInfo,
            {Size = UDim2.fromScale(0.98,0.722)}
        )
    else
        self.insts.taskFrame.Visible = false
    end
end

function c:SetShopFrameVisible(vis)
    if vis then
        self.insts.shopFrame.Size = UDim2.fromScale(0,0)
        self.insts.shopFrame.Visible = true
        TweenHelper:PlayTween(
            self.insts.shopFrame,
            tweenInfo,
            {Size = UDim2.fromScale(0.98,0.733)}
        )
    else
        self.insts.shopFrame.Visible = false
    end
end

function c:SetSpinFrameVisible(vis)
    if vis then
        self.insts.spinFrame.Size = UDim2.fromScale(0,0)
        self.insts.spinFrame.Visible = true
        TweenHelper:PlayTween(
            self.insts.spinFrame,
            tweenInfo,
            {Size = UDim2.fromScale(0.98,0.733)}
        )
    else
        self.insts.spinFrame.Visible = false
    end
end

function c:SetPassFramePremiumOwnedVisible(vis)
    self.insts.passFrame_left_primium_owned.Visible = vis
    self.insts.passFrame_left_primium_buyBtn.Visible = not vis
end

function c:SetPassFrameLeftExp(lv,now,max)
    self.insts.passFrame_left_Pronum.Text = string.format(lv_str,lv,now,max)
    self.insts.passFrame_left_proFg.Size = UDim2.fromScale(math.clamp(now/max,0,1),1)
end

function c:AddItemInPassFrame(lv,freeIcon,freeNum,priIcon,priNum,isLast)
    local ui = hotpot:CloneInst_Loop(self.insts.passFrame_scroll_item)
    ui.Visible = true
    ui.LayoutOrder = lv
    ui.Parent = self.insts.passFrame_ScrollingFrame
    ui.free.icon.Image = freeIcon
    ui.free.num.Text = 'x'.. bigNumber:ToString(freeNum)
    ui.free.lv.Text = lv
    ui.premium.icon.Image = priIcon
    ui.premium.num.Text = 'x'.. bigNumber:ToString(priNum)
    ui.premium.lv.Text = lv
    ui.centerLv.lv.Text = lv
    if lv == 1 then
        ui.leftExp.Visible = false
    end
    if isLast then
        ui.rightExp.Visible = false
    end

    ui.free.btn.MouseButton1Click:Connect(function()
        if self.__free_handle then
            self.__free_handle(self.__free_obj,lv)
        end
    end)

    ui.premium.btn.MouseButton1Click:Connect(function()
        if self.__primium_handle then
            self.__primium_handle(self.__primium_obj,lv)
        end
    end)

    ui.free.MouseEnter:Connect(function()
        if self.passMouseIn_handle then
            self.passMouseIn_handle(self.passMouseIn_obj,lv,true)
        end

        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y
        x = x + ui.free.AbsoluteSize.X / 2

        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        local pettipsSize = self.insts.pettipsFrame.AbsoluteSize
        local relicstipsSize = self.insts.relicstipsFrame.AbsoluteSize
        local tips1Size = self.insts.tipsFrame1.AbsoluteSize
        local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

        local p_x = math.min(viewSize.X - pettipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local r_x = math.min(viewSize.X - relicstipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local t_x = math.min(viewSize.X - tips1Size.X - ui.free.AbsoluteSize.Y / 2,x)
        local t_y = math.min(viewSize.Y - tips1Size.Y - ui.free.AbsoluteSize.Y / 2,y)
        local b_x = math.min(viewSize.X - boxtipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)

        if hotpot.is_mobile then
            b_y = b_y - 50
        end
        
        p_x = (p_x - a_pos.X) / a_size.X 
        p_y = (p_y - a_pos.Y) / a_size.Y 
        r_x = (r_x - a_pos.X) / a_size.X 
        r_y = (r_y - a_pos.Y) / a_size.Y 
        t_x = (t_x - a_pos.X) / a_size.X 
        t_y = (t_y - a_pos.Y) / a_size.Y 
        b_x = (b_x - a_pos.X) / a_size.X 
        b_y = (b_y - a_pos.Y) / a_size.Y 

        self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
        self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
        self.insts.tipsFrame1.Position = UDim2.fromScale(t_x,t_y)
        self.insts.boxtipsFrame.Position = UDim2.fromScale(b_x,b_y)
    end)
    ui.free.MouseLeave:Connect(function()
        self.insts.pettipsFrame.Visible = false
        self.insts.relicstipsFrame.Visible = false
        self.insts.tipsFrame1.Visible = false
        self.insts.boxtipsFrame.Visible = false
    end)
    ui.free.MouseMoved:Connect(function()
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y
        x = x + ui.free.AbsoluteSize.X / 2

        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        local pettipsSize = self.insts.pettipsFrame.AbsoluteSize
        local relicstipsSize = self.insts.relicstipsFrame.AbsoluteSize
        local tips1Size = self.insts.tipsFrame1.AbsoluteSize
        local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

        local p_x = math.min(viewSize.X - pettipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local r_x = math.min(viewSize.X - relicstipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local t_x = math.min(viewSize.X - tips1Size.X - ui.free.AbsoluteSize.Y / 2,x)
        local t_y = math.min(viewSize.Y - tips1Size.Y - ui.free.AbsoluteSize.Y / 2,y)
        local b_x = math.min(viewSize.X - boxtipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        
        if hotpot.is_mobile then
            b_y = b_y - 50
        end

        p_x = (p_x - a_pos.X) / a_size.X 
        p_y = (p_y - a_pos.Y) / a_size.Y 
        r_x = (r_x - a_pos.X) / a_size.X 
        r_y = (r_y - a_pos.Y) / a_size.Y 
        t_x = (t_x - a_pos.X) / a_size.X 
        t_y = (t_y - a_pos.Y) / a_size.Y 
        b_x = (b_x - a_pos.X) / a_size.X 
        b_y = (b_y - a_pos.Y) / a_size.Y 

        self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
        self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
        self.insts.tipsFrame1.Position = UDim2.fromScale(t_x,t_y)
        self.insts.boxtipsFrame.Position = UDim2.fromScale(b_x,b_y)
    end)
    ui.premium.MouseEnter:Connect(function()
        if self.passMouseIn_handle then
            self.passMouseIn_handle(self.passMouseIn_obj,lv,false)
        end
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y
        x = x + ui.free.AbsoluteSize.X / 2

        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        local pettipsSize = self.insts.pettipsFrame.AbsoluteSize
        local relicstipsSize = self.insts.relicstipsFrame.AbsoluteSize
        local tips1Size = self.insts.tipsFrame1.AbsoluteSize
        local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

        local p_x = math.min(viewSize.X - pettipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local r_x = math.min(viewSize.X - relicstipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local t_x = math.min(viewSize.X - tips1Size.X - ui.free.AbsoluteSize.Y / 2,x)
        local t_y = math.min(viewSize.Y - tips1Size.Y - ui.free.AbsoluteSize.Y / 2,y)
        local b_x = math.min(viewSize.X - boxtipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        
        if hotpot.is_mobile then
            b_y = b_y - 50
        end

        p_x = (p_x - a_pos.X) / a_size.X 
        p_y = (p_y - a_pos.Y) / a_size.Y 
        r_x = (r_x - a_pos.X) / a_size.X 
        r_y = (r_y - a_pos.Y) / a_size.Y 
        t_x = (t_x - a_pos.X) / a_size.X 
        t_y = (t_y - a_pos.Y) / a_size.Y 
        b_x = (b_x - a_pos.X) / a_size.X 
        b_y = (b_y - a_pos.Y) / a_size.Y 

        self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
        self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
        self.insts.tipsFrame1.Position = UDim2.fromScale(t_x,t_y)
        self.insts.boxtipsFrame.Position = UDim2.fromScale(b_x,b_y)
    end)
    ui.premium.MouseLeave:Connect(function()
        self.insts.pettipsFrame.Visible = false
        self.insts.relicstipsFrame.Visible = false
        self.insts.tipsFrame1.Visible = false
        self.insts.boxtipsFrame.Visible = false
    end)
    ui.premium.MouseMoved:Connect(function()
        local viewSize = workspace.CurrentCamera.ViewportSize
        local x = mouse.X
        local y = mouse.Y
        x = x + ui.free.AbsoluteSize.X / 2

        local a_pos = self.insts.bg.AbsolutePosition
        local a_size = self.insts.bg.AbsoluteSize
        local pettipsSize = self.insts.pettipsFrame.AbsoluteSize
        local relicstipsSize = self.insts.relicstipsFrame.AbsoluteSize
        local tips1Size = self.insts.tipsFrame1.AbsoluteSize
        local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

        local p_x = math.min(viewSize.X - pettipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local r_x = math.min(viewSize.X - relicstipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local t_x = math.min(viewSize.X - tips1Size.X - ui.free.AbsoluteSize.Y / 2,x)
        local t_y = math.min(viewSize.Y - tips1Size.Y - ui.free.AbsoluteSize.Y / 2,y)
        local b_x = math.min(viewSize.X - boxtipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        
        if hotpot.is_mobile then
            b_y = b_y - 50
        end

        p_x = (p_x - a_pos.X) / a_size.X 
        p_y = (p_y - a_pos.Y) / a_size.Y 
        r_x = (r_x - a_pos.X) / a_size.X 
        r_y = (r_y - a_pos.Y) / a_size.Y 
        t_x = (t_x - a_pos.X) / a_size.X 
        t_y = (t_y - a_pos.Y) / a_size.Y 
        b_x = (b_x - a_pos.X) / a_size.X 
        b_y = (b_y - a_pos.Y) / a_size.Y 

        self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
        self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
        self.insts.tipsFrame1.Position = UDim2.fromScale(t_x,t_y)
        self.insts.boxtipsFrame.Position = UDim2.fromScale(b_x,b_y)
    end)

    self.bp_item_list[lv] = ui
end

function c:SetLastInfoInPassFrame(icon,lv,name)
    -- self.insts.passFrame_last.bg.board.icon.Image = icon
    -- self.insts.passFrame_last.bg.lv.num.Text = lv
    -- self.insts.passFrame_last.bg.name.Text = name

    -- self.insts.passFrame_last.bg.board.MouseEnter:Connect(function()
    --     if self.passMouseIn_handle then
    --         self.passMouseIn_handle(self.passMouseIn_obj,lv,true)
    --     end

    --     local viewSize = workspace.CurrentCamera.ViewportSize
    --     local x = mouse.X
    --     local y = mouse.Y
    --     x = x + self.insts.passFrame_last.bg.board.AbsoluteSize.X / 2

    --     local a_pos = self.insts.bg.AbsolutePosition
    --     local a_size = self.insts.bg.AbsoluteSize
    --     local pettipsSize = self.insts.pettipsFrame.AbsoluteSize

    --     local p_x = math.min(viewSize.X - pettipsSize.X - self.insts.passFrame_last.bg.board.AbsoluteSize.Y / 2,x)
    --     local p_y = math.min(viewSize.Y - pettipsSize.Y - self.insts.passFrame_last.bg.board.AbsoluteSize.Y / 2,y)
        
    --     p_x = (p_x - a_pos.X) / a_size.X 
    --     p_y = (p_y - a_pos.Y) / a_size.Y 

    --     self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
    -- end)
    -- self.insts.passFrame_last.bg.board.MouseLeave:Connect(function()
    --     self:SetPetTipsFrameVisible(false)
    -- end)
    -- self.insts.passFrame_last.bg.board.MouseMoved:Connect(function()
    --     local viewSize = workspace.CurrentCamera.ViewportSize
    --     local x = mouse.X
    --     local y = mouse.Y
    --     x = x + self.insts.passFrame_last.bg.board.AbsoluteSize.X / 2

    --     local a_pos = self.insts.bg.AbsolutePosition
    --     local a_size = self.insts.bg.AbsoluteSize
    --     local pettipsSize = self.insts.pettipsFrame.AbsoluteSize

    --     local p_x = math.min(viewSize.X - pettipsSize.X - 5,x)
    --     local p_y = math.min(viewSize.Y - pettipsSize.Y - 5,y)
        
    --     p_x = (p_x - a_pos.X) / a_size.X 
    --     p_y = (p_y - a_pos.Y) / a_size.Y 

    --     self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
    -- end)

    self.insts.passFrame_last.btn.MouseButton1Click:Connect(function()
        if self.__free_handle then
            self.__free_handle(self.__free_obj,lv)
        end
    end)
end

---@param state number @1未解锁 2已领取 3可领取
function c:SetLastState(state)
    if state == 1 then
        self.insts.passFrame_last.bg.Image = 'rbxassetid://102011047551657'
        self.insts.passFrame_last.Notbtn.Visible = true
        self.insts.passFrame_last.btn.Visible = false
        self.insts.passFrame_last.claimed.Visible = false
    elseif state == 2 then
        self.insts.passFrame_last.bg.Image = 'rbxassetid://102011047551657'
        self.insts.passFrame_last.Notbtn.Visible = false
        self.insts.passFrame_last.btn.Visible = false
        self.insts.passFrame_last.claimed.Visible = true
    elseif state == 3 then
        self.insts.passFrame_last.bg.Image = 'rbxassetid://102011047551657'
        self.insts.passFrame_last.Notbtn.Visible = false
        self.insts.passFrame_last.btn.Visible = true
        self.insts.passFrame_last.claimed.Visible = false
    end
end

---@param state number @1未解锁 2已领取 3可领取
function c:SetPassFrameItemFreeState(lv,state)
    local ui = self.bp_item_list[lv]
    if not ui then
        return
    end
    if state == 1 then
        ui.free.btn.Visible = false
        ui.free.Notbtn.Visible = true
        ui.free.claimtop.Visible = false
        ui.free.notreadytop.Visible = true
        ui.free.claimed.Visible = false
    elseif state == 2 then
        ui.free.btn.Visible = false
        ui.free.Notbtn.Visible = false
        ui.free.claimtop.Visible = true
        ui.free.notreadytop.Visible = false
        ui.free.claimed.Visible = true
    elseif state == 3 then
        ui.free.btn.Visible = true
        ui.free.Notbtn.Visible = false
        ui.free.claimtop.Visible = false
        ui.free.notreadytop.Visible = false
        ui.free.claimed.Visible = false
    end
end

---@param state number @1未解锁 2已领取 3可领取
function c:SetPassFrameItemPrimiumState(lv,state)
    local ui = self.bp_item_list[lv]
    if not ui then
        return
    end
    if state == 1 then
        ui.premium.btn.Visible = false
        ui.premium.Notbtn.Visible = true
        ui.premium.claimtop.Visible = false
        ui.premium.notreadytop.Visible = true
        ui.premium.claimed.Visible = false
    elseif state == 2 then
        ui.premium.btn.Visible = false
        ui.premium.Notbtn.Visible = false
        ui.premium.claimtop.Visible = true
        ui.premium.notreadytop.Visible = false
        ui.premium.claimed.Visible = true
    elseif state == 3 then
        ui.premium.btn.Visible = true
        ui.premium.Notbtn.Visible = false
        ui.premium.claimtop.Visible = false
        ui.premium.notreadytop.Visible = false
        ui.premium.claimed.Visible = false
    end
end

function c:SetPassFrameItemLv(lv)
    for k,ui in ipairs(self.bp_item_list)do
        if lv > k then
            ui.leftExp.BackgroundColor3 = Color3.fromRGB(255, 170, 70)
            ui.rightExp.BackgroundColor3 = Color3.fromRGB(255, 170, 70)
        elseif lv == k then
            ui.leftExp.BackgroundColor3 = Color3.fromRGB(255, 170, 70)
            ui.rightExp.BackgroundColor3 = Color3.fromRGB(67, 68, 75)
        else
            ui.leftExp.BackgroundColor3 = Color3.fromRGB(67, 68, 75)
            ui.rightExp.BackgroundColor3 = Color3.fromRGB(67, 68, 75)
        end
    end
end

function c:AddItemInHourTask(id,desc,exp)
    local ui = hotpot:CloneInst_Loop(self.insts.hourTask_item)
    ui.Visible = true
    ui.Parent = self.insts.hourTask_list
    ui.Name = id
    ui.bg.desc.Text = desc
    local exp_ui = ui.bg.proBg:WaitForChild('exp')
    exp_ui.Text = '+'..exp..'EXP'

    self.task_item_list[id] = ui
end

function c:AddItemInDailyTask(id,desc,exp)
    local ui = hotpot:CloneInst_Loop(self.insts.dailyTask_item)
    ui.Visible = true
    ui.Parent = self.insts.dailyTask_list
    ui.Name = id
    ui.bg.desc.Text = desc
    local exp_ui = ui.bg.proBg:WaitForChild('exp')
    exp_ui.Text = '+'..exp..'EXP'

    self.task_item_list[id] = ui
end

function c:SetTaskFrameItemPro(id,now,max)
    local ui = self.task_item_list[id]
    if not ui then
        return
    end
    ui.bg.proBg.num.Text = string.format('%s/%s',now,max)
    ui.bg.proBg.proFg.Size = UDim2.fromScale(math.clamp(now/max,0,1),1)
end

function c:SetTaskFrameItemComplete(id,compl)
    local ui = self.task_item_list[id]
    if not ui then
        return
    end
    ui.bg.top.Visible = compl
end

function c:SetDailyTaskCD(cd)
    self.insts.dailyTask_refresh.Text = bigNumber:TransformDateToString(cd)
end

function c:SetHourTaskCD(cd)
    self.insts.hourTask_refresh.Text = bigNumber:TransformDateToString(cd)
end

function c:SetSpinTicketNum(num)
    self.insts.spin_ticketNum.Text = num
end

function c:SetSpinReward(list)
    local uis = {
        self.insts.spin_r1,
        self.insts.spin_r2,
        self.insts.spin_r3,
        self.insts.spin_r4,
        self.insts.spin_r5,
    }
    for k,v in ipairs(list)do
        local ui = uis[k]
        ui.icon.Image = v.icon
        ui.per.Text = v.per--string.format('%.2f%%',v.per)
        if v.rewardType == 4 then
            ui.icon.MouseLeave:Connect(function()
                self:SetRelicstipsFrameVisible(false)
                self:SetPetTipsFrameVisible(false)
            end)
            ui.icon.MouseEnter:Connect(function()
                if self.shopMouseIn_handle then
                    self.shopMouseIn_handle(self.shopMouseIn_obj,0)
                end

                local viewSize = workspace.CurrentCamera.ViewportSize
                local x = mouse.X
                local y = mouse.Y
                x = x + ui.icon.AbsoluteSize.X / 2

                local a_pos = self.insts.bg.AbsolutePosition
                local a_size = self.insts.bg.AbsoluteSize
                local pettipsSize = self.insts.pettipsFrame.AbsoluteSize
                local relicsSize = self.insts.relicstipsFrame.AbsoluteSize

                local p_x = math.min(viewSize.X - pettipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
                local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
                local r_x = math.min(viewSize.X - relicsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
                local r_y = math.min(viewSize.Y - relicsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
                
                p_x = (p_x - a_pos.X) / a_size.X 
                p_y = (p_y - a_pos.Y) / a_size.Y 
                r_x = (r_x - a_pos.X) / a_size.X 
                r_y = (r_y - a_pos.Y) / a_size.Y 

                self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
                self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
            end)
            ui.icon.MouseMoved:Connect(function()
                local viewSize = workspace.CurrentCamera.ViewportSize
                local x = mouse.X
                local y = mouse.Y
                x = x + ui.icon.AbsoluteSize.X / 2

                local a_pos = self.insts.bg.AbsolutePosition
                local a_size = self.insts.bg.AbsoluteSize
                local pettipsSize = self.insts.pettipsFrame.AbsoluteSize
                local relicsSize = self.insts.relicstipsFrame.AbsoluteSize

                local p_x = math.min(viewSize.X - pettipsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
                local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
                local r_x = math.min(viewSize.X - relicsSize.X - ui.icon.AbsoluteSize.Y / 2,x)
                local r_y = math.min(viewSize.Y - relicsSize.Y - ui.icon.AbsoluteSize.Y / 2,y)
                
                p_x = (p_x - a_pos.X) / a_size.X 
                p_y = (p_y - a_pos.Y) / a_size.Y 
                r_x = (r_x - a_pos.X) / a_size.X 
                r_y = (r_y - a_pos.Y) / a_size.Y 

                self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
                self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
            end)
        end
    end
end

function c:SetShopFrameEggInfo(list,price)
    for k,v in ipairs(list)do
        local ui = hotpot:CloneInst_Loop(self.insts.shopEggitem) 
        ui.Parent = self.insts.shopEgglist
        ui.bg.icon.Image = v.icon
        ui.bg.per.Text = string.format('%.2f%%',v.per)

        local g = qualityColor:FindFirstChild(tostring(v.quality))
        if g then
            g:Clone().Parent = ui.bg
            g:Clone().Parent = ui.bg.UIStroke
        end

        ui.Visible = true
        local id = k
        ui.bg.MouseEnter:Connect(function()
            if self.eggMouseIn_handle then
                self.eggMouseIn_handle(self.eggMouseIn_obj,id)
            end
            local viewSize = workspace.CurrentCamera.ViewportSize
            local x = mouse.X
            local y = mouse.Y
            x = x + ui.bg.AbsoluteSize.X / 2

            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize
            local pettipsSize = self.insts.pettipsFrame.AbsoluteSize

            local p_x = math.min(viewSize.X - pettipsSize.X - ui.bg.AbsoluteSize.Y / 2,x)
            local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.bg.AbsoluteSize.Y / 2,y)
            
            p_x = (p_x - a_pos.X) / a_size.X 
            p_y = (p_y - a_pos.Y) / a_size.Y 

            self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
        end)
        ui.bg.MouseLeave:Connect(function()
            self:SetPetTipsFrameVisible(false)
        end)
        ui.bg.MouseMoved:Connect(function()
            local viewSize = workspace.CurrentCamera.ViewportSize
            local x = mouse.X
            local y = mouse.Y
            x = x + ui.bg.AbsoluteSize.X / 2

            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize
            local pettipsSize = self.insts.pettipsFrame.AbsoluteSize

            local p_x = math.min(viewSize.X - pettipsSize.X - ui.bg.AbsoluteSize.Y / 2,x)
            local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.bg.AbsoluteSize.Y / 2,y)
            
            p_x = (p_x - a_pos.X) / a_size.X 
            p_y = (p_y - a_pos.Y) / a_size.Y 

            self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
        end)
    end
    self.insts.shopEggbtn1.price.Text = bigNumber:ToString(price)
    self.insts.shopEggbtn3.price.Text = bigNumber:ToString(price * 3)
    self.insts.shopEggbtn10.price.Text = bigNumber:ToString(price * 10)
end

function c:SetShopFrameItem(list)
    for k,v in ipairs(list)do
        local id = k
        local ui = hotpot:CloneInst_Loop(self.insts.shopListitem)
        ui.Parent = self.insts.shoplist
        ui.Visible = true
        ui.LayoutOrder = v.order
        ui.bg.board.icon.Image = v.icon
        ui.bg.board.name.Text = v.name
        ui.bg.btn.price.Text = bigNumber:ToString(v.price)
        BtnHelper:InitButton(ui.bg.btn)
        self.shop_item_list[k] = ui
        ui.bg.btn.MouseButton1Click:Connect(function()
            if self.__shop_item_obj then
                self.__shop_item_handle(self.__shop_item_obj,id)
            end
        end)

        ui.bg.board.MouseLeave:Connect(function()
            self:SetRelicstipsFrameVisible(false)
            self:SetPetTipsFrameVisible(false)
        end)
        ui.bg.board.MouseEnter:Connect(function()
            if self.shopMouseIn_handle then
                self.shopMouseIn_handle(self.shopMouseIn_obj,id)
            end

            local viewSize = workspace.CurrentCamera.ViewportSize
            local x = mouse.X
            local y = mouse.Y
            x = x + ui.bg.board.AbsoluteSize.X / 2

            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize
            local pettipsSize = self.insts.pettipsFrame.AbsoluteSize
            local relicsSize = self.insts.relicstipsFrame.AbsoluteSize

            local p_x = math.min(viewSize.X - pettipsSize.X - ui.bg.board.AbsoluteSize.Y / 2,x)
            local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.bg.board.AbsoluteSize.Y / 2,y)
            local r_x = math.min(viewSize.X - relicsSize.X - ui.bg.board.AbsoluteSize.Y / 2,x)
            local r_y = math.min(viewSize.Y - relicsSize.Y - ui.bg.board.AbsoluteSize.Y / 2,y)
            
            p_x = (p_x - a_pos.X) / a_size.X 
            p_y = (p_y - a_pos.Y) / a_size.Y 
            r_x = (r_x - a_pos.X) / a_size.X 
            r_y = (r_y - a_pos.Y) / a_size.Y 

            self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
            self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
        end)
        ui.bg.board.MouseMoved:Connect(function()
            local viewSize = workspace.CurrentCamera.ViewportSize
            local x = mouse.X
            local y = mouse.Y
            x = x + ui.bg.board.AbsoluteSize.X / 2

            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize
            local pettipsSize = self.insts.pettipsFrame.AbsoluteSize
            local relicsSize = self.insts.relicstipsFrame.AbsoluteSize

            local p_x = math.min(viewSize.X - pettipsSize.X - ui.bg.board.AbsoluteSize.Y / 2,x)
            local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.bg.board.AbsoluteSize.Y / 2,y)
            local r_x = math.min(viewSize.X - relicsSize.X - ui.bg.board.AbsoluteSize.Y / 2,x)
            local r_y = math.min(viewSize.Y - relicsSize.Y - ui.bg.board.AbsoluteSize.Y / 2,y)
            
            p_x = (p_x - a_pos.X) / a_size.X 
            p_y = (p_y - a_pos.Y) / a_size.Y 
            r_x = (r_x - a_pos.X) / a_size.X 
            r_y = (r_y - a_pos.Y) / a_size.Y 

            self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
            self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
        end)

        if v.rewardType == 8 then
            ui.bg.board.title.Text = v.name    
            ui.bg.board.title.Visible = true
        else
            ui.bg.board.title.Visible = false
        end

        if v.is_robux then
            ui.bg.btn.price.ImageLabel.Image = 'rbxassetid://11560341132'
            ui.bg.btn.price.Text = (v.price)
        else
            local giftIcon = ui.bg.btn:WaitForChild('giftIcon')
            if giftIcon then
                giftIcon:Destroy()
            end
        end
    end
end

function c:SetShopFrameItemOwnedVisible(id,vis)
    local ui = self.shop_item_list[id]
    if not ui then
        return
    end
    ui.bg.owned.Visible = vis
    ui.bg.btn.Visible = not vis
end

function c:PlaySpin(id)
    local total_rotation = (((id-1) * 76 + 36) + 360 * 6 + (360 - self.now_angle))
    self:AddRenderProcess('render',function()
        if self.__playing then
            return true
        end
        self.__playing = true
        local time_len = math.pi--定义为π代表[0,π]的积分
        local arg = total_rotation / 2--因为使用sin(x)作为被积函数,而sin(x)在[0,π]的积分为2,所以算出倍率
        local interval = 0

        -- audio_manager:PlayGloble('spin')

        while true do
            interval = interval + self:Wait()
            interval = math.min(interval,time_len)
            self.angle = arg * bigNumber:Trapezoidal_rule(0,interval,1000,math.sin)
            self.insts.spin_rotate.Rotation = self.angle + self.now_angle
            if interval >= time_len then
                break
            end
        end
        self:Wait(1)
        self.__playing = false
        self.now_angle = (total_rotation - (360 - self.now_angle)) % 360 
        self.angle = 0
    end)
end

function c:SetPetTipsFrameVisible(vis,isLast)
    self.insts.pettipsFrame.Visible = vis
    if isLast then
        self.insts.pettipsFrame.Size = UDim2.fromScale(0.205*1.5,0.183*1.5)
    else
        self.insts.pettipsFrame.Size = UDim2.fromScale(0.205,0.183)
    end
end

function c:SetRelicstipsFrameVisible(vis)
    self.insts.relicstipsFrame.Visible = vis
end

function c:SetTipsFrame1Visible(vis)
    self.insts.tipsFrame1.Visible = vis
end

function c:SetBoxtipsFrameVisible(vis)
    self.insts.boxtipsFrame.Visible = vis
end

function c:SetTipsFrame1Info(info)
    self.insts.tipsFrame1.name.Text = info.name
    self.insts.tipsFrame1.desc.Text = info.desc
end

function c:SetPetTipsFrameInfo(info)
    self.insts.pettipsFrame.name.Text = info.name
    self.insts.pettipsFrame.quality.Text = hotpot.pro_cfg.quality[info.quality].name
    local g = qualityColor:FindFirstChild(tostring(info.quality))
    if g then
        g:Clone().Parent = self.insts.pettipsFrame.quality
    end
    self.insts.pettipsFrame.atk.num.Text = bigNumber:ToString(info.atk)
end

function c:SetRelicstipsFrameInfo(info)
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
end

function c:SetBoxtipsFrameInfo(info)
    for k,v in ipairs(info)do
        local ui = self.insts.boxtipsFrame.list:FindFirstChild('item'..k)
        if ui then
            ui.icon.Image = v.icon
            ui.name.Text = v.name
            ui.per.Text = string.format('%.2f%%',v.per)
        end
    end
    self.insts.boxtipsFrame.name.Text = info.name
end

function c:SetCD(cd)
    self.insts.cd.Text = bigNumber:GetTime(cd)
    if cd <= 0 then
        self.insts.cd.Visible = false
    else
        self.insts.cd.Visible = true
    end
end

function c:BindGiftBtnClickHandle(obj,handle)
    self.insts.GiftBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindPlayerCloseBtnClickHandle(obj,handle)
    self.insts.selectPlayerBg_closeBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindSelectPlayerItemClickHandle(obj,handle)
    self.__selectPlayerItemClickHandle = handle
    self.__selectPlayerItemClickObj = obj
end

function c:BindPassFrameItemFreeBtnClickHandle(obj,handle)
    self.__free_obj = obj
    self.__free_handle = handle
end

function c:BindPassFrameItemPrimiumBtnClickHandle(obj,handle)
    self.__primium_obj = obj
    self.__primium_handle = handle
end

function c:BindBuyPremiumBtnClickHandle(obj,handle)
    self.insts.passFrame_left_primium_buyBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindBuyDoubleCoinsBtnClickHandle(obj,handle)
    self.insts.double_btn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindRefreshTaskBtnClickHandle(obj,handle)
    self.insts.buyRefreshBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindSpinFrameUse1BtnClickHandle(obj,handle)
    self.insts.spin_use1.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindSpinFrameUseAllBtnClickHandle(obj,handle)
    self.insts.spin_useall.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindEggBtnClickHandle(obj,handle)
    self.insts.shopEggbtn1.MouseButton1Click:Connect(function()
        handle(obj,1)
    end)
    self.insts.shopEggbtn3.MouseButton1Click:Connect(function()
        handle(obj,3)
    end)
    self.insts.shopEggbtn10.MouseButton1Click:Connect(function()
        handle(obj,10)
    end)
end

function c:BindShopFrameItemClickHandle(obj,handle)
    self.__shop_item_obj = obj
    self.__shop_item_handle = handle
end

function c:BindMouseInPassItemHandle(obj,handle)
    self.passMouseIn_handle = handle
    self.passMouseIn_obj = obj
end

function c:BindMouseInEggItemHandle(obj,handle)
    self.eggMouseIn_handle = handle
    self.eggMouseIn_obj = obj
end

function c:BindMouseInShopItemHandle(obj,handle)
    self.shopMouseIn_handle = handle
    self.shopMouseIn_obj = obj
end

--绑定取消按钮点击事件
function c:BindCancelBtnClickHandle(obj,handle)
    self.__cancelBtnClickHandle = handle
    self.__cancelBtnClickObj = obj
end

return c