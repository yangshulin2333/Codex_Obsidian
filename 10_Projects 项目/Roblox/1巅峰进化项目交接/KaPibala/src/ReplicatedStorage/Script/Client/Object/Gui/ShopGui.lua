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
---@type UIGradientHelper
local UIGradientHelper = hotpot.load.UIGradientHelper()
local GuiService = game:GetService("GuiService")

local tweenInfo = TweenInfo.new(0.2)
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)
local chaTipsStr = 'Character will always be %s%% stronger as your best character!'

local boardList = {
    'rbxassetid://113933060122201','rbxassetid://134820174884911','rbxassetid://137139791849220',
    'rbxassetid://96145768188365','rbxassetid://116641707711023','rbxassetid://130870938962099',

    'rbxassetid://113933060122201','rbxassetid://134820174884911','rbxassetid://137139791849220',
    'rbxassetid://96145768188365',

    'rbxassetid://130870938962099','rbxassetid://116641707711023',
    'rbxassetid://130870938962099','rbxassetid://116641707711023',

    'rbxassetid://113933060122201','rbxassetid://134820174884911','rbxassetid://137139791849220',
    'rbxassetid://96145768188365','rbxassetid://116641707711023','rbxassetid://130870938962099',
}
local limitQualityList = {3,4,5,6}

---@class ShopGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ScrollingFrame		
	c.insts.ScrollingFrame = 'Frame.bg.ScrollingFrame'   
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'    
    
    ---@type Frame		
	c.insts.topBtns = 'Frame.bg.topBtns'  
    ---@type ImageButton		
	c.insts.btn1 = 'Frame.bg.topBtns.btn1.btn'      
    ---@type ImageButton		
	c.insts.btn2 = 'Frame.bg.topBtns.btn2.btn' 
    ---@type ImageButton		
	c.insts.btn3 = 'Frame.bg.topBtns.btn3.btn' 
    ---@type ImageButton		
	c.insts.btn4 = 'Frame.bg.topBtns.btn4.btn' 
    ---@type ImageButton		
	c.insts.btn5 = 'Frame.bg.topBtns.btn5.btn' 

    ---@type Frame		
	c.insts.giftFrame = 'Frame.bg.ScrollingFrame.giftFrame'    
    ---@type Frame		
	c.insts.giftFrame_show1 = 'Frame.bg.ScrollingFrame.giftFrame.show1'    
    ---@type Frame		
	c.insts.giftFrame_show2 = 'Frame.bg.ScrollingFrame.giftFrame.show2'     
    ---@type Frame		
	c.insts.giftFrame_list = 'Frame.bg.ScrollingFrame.giftFrame.list'  
    ---@type Frame		
	c.insts.giftFrame_list_item = 'Frame.bg.ScrollingFrame.giftFrame.list.item'  
    ---@type Frame		
	c.insts.giftFrame_list_temp = 'Frame.bg.ScrollingFrame.giftFrame.list.temp'  
    ---@type ImageLabel		
	c.insts.giftFrame_tipsFrame = 'Frame.bg.ScrollingFrame.giftFrame.tipsFrame'    
    ---@type TextLabel		
	c.insts.giftFrame_done = 'Frame.bg.ScrollingFrame.giftFrame.tip'          

    ---@type Frame		
	c.insts.choicenessFrame = 'Frame.bg.ScrollingFrame.choicenessFrame'  
    ---@type Frame		
	c.insts.choicenessFrame_startpack = 'Frame.bg.ScrollingFrame.choicenessFrame.startpack'     
    ---@type Frame		
	c.insts.choicenessFrame_egg = 'Frame.bg.ScrollingFrame.choicenessFrame.egg'  
    ---@type Frame		
	c.insts.choicenessFrame_suit = 'Frame.bg.ScrollingFrame.choicenessFrame.suit' 
    ---@type Frame		
	c.insts.newSuit = 'Frame.bg.ScrollingFrame.choicenessFrame.newSuit'  
    ---@type Frame		
	c.insts.newSuit_item = 'Frame.bg.ScrollingFrame.choicenessFrame.newSuit.item'    
    
    ---@type Frame		
	c.insts.gamepassFrame = 'Frame.bg.ScrollingFrame.gamepassFrame'  
    ---@type Frame		
	c.insts.gamepassFrame_list = 'Frame.bg.ScrollingFrame.gamepassFrame.list'    
    ---@type Frame		
	c.insts.gamepassFrame_item = 'Frame.bg.ScrollingFrame.gamepassFrame.list.item'   
    ---@type Frame		
	c.insts.gamepassFrame_vip = 'Frame.bg.ScrollingFrame.gamepassFrame.vip'       

    ---@type Frame		
	c.insts.limitPetFrame = 'Frame.bg.ScrollingFrame.limitPetFrame'   
    ---@type Frame		
	c.insts.limitPetFrame_list = 'Frame.bg.ScrollingFrame.limitPetFrame.list'   
    ---@type Frame		
	c.insts.limitPetFrame_item = 'Frame.bg.ScrollingFrame.limitPetFrame.list.item'   
    
    ---@type Frame		
	c.insts.boostsFrame = 'Frame.bg.ScrollingFrame.boostsFrame'    
    ---@type Frame		
	c.insts.boostsFrame_list = 'Frame.bg.ScrollingFrame.boostsFrame.list'    
    ---@type Frame		
	c.insts.boostsFrame_item_1 = 'Frame.bg.ScrollingFrame.boostsFrame.list.1'    
    ---@type Frame		
	c.insts.boostsFrame_item_2 = 'Frame.bg.ScrollingFrame.boostsFrame.list.2'    
    ---@type Frame		
	c.insts.boostsFrame_item_3 = 'Frame.bg.ScrollingFrame.boostsFrame.list.3'    

    ---@type Frame		
	c.insts.winsFrame = 'Frame.bg.ScrollingFrame.winsFrame'   
    ---@type Frame		
	c.insts.winsFrame_list = 'Frame.bg.ScrollingFrame.winsFrame.list'    
    ---@type Frame		
	c.insts.winsFrame_item = 'Frame.bg.ScrollingFrame.winsFrame.list.item'   
    
    ---@type Frame		
	c.insts.luckyFrame = 'Frame.bg.ScrollingFrame.luckyFrame'    
    ---@type TextLabel		
	c.insts.luckyFrame_old = 'Frame.bg.ScrollingFrame.luckyFrame.old'  
    ---@type TextLabel		
	c.insts.luckyFrame_new = 'Frame.bg.ScrollingFrame.luckyFrame.new'      
    ---@type TextLabel		
	c.insts.luckyFrame_cd = 'Frame.bg.ScrollingFrame.luckyFrame.cd'    
    ---@type ImageButton		
	c.insts.luckyFrame_btn = 'Frame.bg.ScrollingFrame.luckyFrame.btn' 
    
    ---@type ImageButton		
	c.insts.GiftBtn = 'Frame.bg.GiftBtn'    
    ---@type ImageButton		
	c.insts.cancelBtn = 'Frame.bg.cancelBtn'    
    ---@type TextLabel		
	c.insts.cancelBtn_info = 'Frame.bg.cancelBtn.info'    

    ---@type ImageLabel		
	c.insts.selectPlayerBg = 'Frame.selectPlayerBg'    
    ---@type ScrollingFrame		
	c.insts.selectPlayerBg_ScrollingFrame = 'Frame.selectPlayerBg.ScrollingFrame'    
    ---@type Frame		
	c.insts.selectPlayerBg_item = 'Frame.selectPlayerBg.ScrollingFrame.item'    
    ---@type ImageButton		
	c.insts.selectPlayerBg_closeBtn = 'Frame.selectPlayerBg.closeBtn'    

    ---@type ImageButton		
	c.insts.halloween_btn = 'Frame.bg.ScrollingFrame.choicenessFrame.halloweenpack.bg.btn'   
    ---@type Frame		
	c.insts.choicenessFrame_halloweenpack = 'Frame.bg.ScrollingFrame.choicenessFrame.halloweenpack'     

    ---@type ImageLabel		
	c.insts.relics_tipsFrame = 'Frame.bg.relicsTipsFrame'    
    ---@type ImageLabel		
	c.insts.chatipsFrame = 'Frame.bg.chatipsFrame'  
    ---@type ImageLabel		
	c.insts.boxtipsFrame = 'Frame.bg.boxtipsFrame'   
    ---@type ImageLabel		
	c.insts.petTipsFrame2 = 'Frame.bg.petTipsFrame2'  
    ---@type ImageLabel		
	c.insts.suitFrame = 'Frame.bg.relicsTipsFrame.suitFrame'       
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.ShopGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self:Init()
    self:ListenScroll()

    self.suit_name_list = {}
    self.suit_eff_list = {}

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

    self.insts.GiftBtn.MouseButton1Click:Connect(function()
        self.insts.bg.Visible = false
        self:SetSelectPlayerBgVisible(true)
    end)
    self.insts.selectPlayerBg_closeBtn.MouseButton1Click:Connect(function()
        self:SetSelectPlayerBgVisible(false)    
        self.insts.bg.Visible = true
    end)
    self.insts.cancelBtn.MouseButton1Click:Connect(function()
        self.insts.cancelBtn.Visible = false
        self.insts.GiftBtn.Visible = true
        self:SetGiftIconVisible(false)
        if self.__cancelBtnClickHandle then
            self.__cancelBtnClickHandle(self.__cancelBtnClickObj)
        end
    end)
end

function c:Init()
    self.gift_item_list = {}
    self.gamepass_item_list = {}
    self.limitPet_item_list = {}
    self.wins_item_list = {}

    self.scroll_list = {
        self.insts.choicenessFrame,
        self.insts.gamepassFrame,
        self.insts.limitPetFrame,
        self.insts.boostsFrame,
        self.insts.winsFrame
    }

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    local top_btns = {
        self.insts.btn1,self.insts.btn2,self.insts.btn3,self.insts.btn4,self.insts.btn5,
    }
    self.top_btns = top_btns
    for k,v in ipairs(top_btns)do
        local id = k
        local btn = v
        v.MouseButton1Click:Connect(function()
            self:SetScrollFrameCavasPos(id,btn)
            audioManager:PlayGloble('pick')
        end)
    end

    self:SetGiftIconVisible(false)

    local show1 = self.insts.giftFrame_show1
    local show2 = self.insts.giftFrame_show2
    local list = {}
    for k,v in ipairs(show1:GetChildren())do
        if v.Name == 'board' then
            table.insert(list,v)
        end
    end
    for k,v in ipairs(show2:GetChildren())do
        if v.Name == 'board' then
            table.insert(list,v)
        end
    end
    for k,ui in ipairs(list)do
        local type_ = ui:GetAttribute('showType')
        local id = ui:GetAttribute('id')
        ui.MouseEnter:Connect(function()
            if self.__giftFrameItemMouseEnterHandle and self.__giftFrameItemMouseEnterObj then
                self.__giftFrameItemMouseEnterHandle(self.__giftFrameItemMouseEnterObj,nil,type_,id)
            end
            local x = mouse.X
            local y = mouse.Y
            if hotpot.is_mobile then
                x = x + ui.AbsoluteSize.X / 2
            end
            local pos = self.insts.giftFrame.AbsolutePosition
            local pos1 = self.insts.bg.AbsolutePosition
            local size = self.insts.bg.AbsoluteSize
            local p = UDim2.fromScale((x-pos1.X)/size.X,(y-pos1.Y)/size.Y)
            self.insts.giftFrame_tipsFrame.Position = UDim2.new(0,x-pos.X,0,y-pos.Y)
            self.insts.relics_tipsFrame.Position = p
            self.insts.boxtipsFrame.Position = p
            self.insts.petTipsFrame2.Position = p
            self.insts.chatipsFrame.Position = p
        end)
        ui.MouseLeave:Connect(function()
            if self.__giftFrameItemMouseLeaveHandle and self.__giftFrameItemMouseLeaveObj then
                self.__giftFrameItemMouseLeaveHandle(self.__giftFrameItemMouseLeaveObj)
            end
        end)
        ui.MouseMoved:Connect(function()
            local x = mouse.X
            local y = mouse.Y
            if hotpot.is_mobile then
                x = x + ui.AbsoluteSize.X / 2
            end
            local pos = self.insts.giftFrame.AbsolutePosition
            local pos1 = self.insts.bg.AbsolutePosition
            local size = self.insts.bg.AbsoluteSize
            local p = UDim2.fromScale((x-pos1.X)/size.X,(y-pos1.Y)/size.Y)
            self.insts.giftFrame_tipsFrame.Position = UDim2.new(0,x-pos.X,0,y-pos.Y)
            self.insts.relics_tipsFrame.Position = p
            self.insts.boxtipsFrame.Position = p
            self.insts.petTipsFrame2.Position = p
            self.insts.chatipsFrame.Position = p
        end)
    end
end

function c:Show()
    self.insts.Frame.Position = UDim2.fromScale(0.5,0.7)
    c.super.Show(self)
    TweenHelper:PlayTween(
        self.insts.Frame,
        tweenInfo,
        {Position = UDim2.fromScale(0.5,0.5)}
    )
    wait()
    self.size_list = {}
    local list = {
        self.insts.giftFrame,
        self.insts.choicenessFrame,
        self.insts.gamepassFrame,
        self.insts.limitPetFrame,
        self.insts.boostsFrame,
        self.insts.winsFrame,
    }
    for k,v in ipairs(list)do
        self.size_list[k] = v.AbsoluteSize.Y-3
    end
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

    self.insts.cancelBtn.Visible = false
    self.insts.GiftBtn.Visible = true
    self:SetGiftIconVisible(false)
    if self.__cancelBtnClickHandle then
        self.__cancelBtnClickHandle(self.__cancelBtnClickObj)
    end
end

--设置scrollPos
function c:SetScrollFrameCavasPos(id,btn)
    self.gift_size_y = self.insts.giftFrame.AbsoluteSize.Y

    local y = self.gift_size_y
    for i = 1,id - 1 do
        y = y + self.scroll_list[i].AbsoluteSize.Y
    end
    self.insts.ScrollingFrame.CanvasPosition = Vector2.new(0,y)

    for k,v in ipairs(self.top_btns)do
        if v == btn then
            v.select.Visible = true
            v.TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
        else
            v.select.Visible = false
            v.TextLabel.TextColor3 = Color3.fromRGB(180,180,180)
        end
    end
end

--监听滑动
function c:ListenScroll()
    self.insts.ScrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        local y = self.insts.ScrollingFrame.CanvasPosition.Y
        local idx = 1
        local temp = self.size_list[1]
        for i = 2,#self.size_list do
            temp = temp + self.size_list[i]
            if y < temp then
                idx = i
                break
            end
        end
        -- print(idx-1)
        -- self:SetScrollFrameCavasPos(idx,self.top_btns[idx])
        for k,v in ipairs(self.top_btns)do
            if k == idx-1 then
                v.select.Visible = true
                v.TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
            else
                v.select.Visible = false
                v.TextLabel.TextColor3 = Color3.fromRGB(180,180,180)
            end
        end
    end)
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

--设置礼物盒的显示
function c:SetGiftIconVisible(vis)
    for k,v in ipairs(self.insts.bg:GetDescendants())do
        if v.Name == 'giftIcon' then
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

------------------------------------------GiftFrame_Start
---设置giftFrameDone显示
function c:SetGiftFrameDoneVisible(vis)
    self.insts.giftFrame_done.Visible = vis
end
---设置宠物tips显示
function c:SetPetTips2Visible(vis)
    self.insts.petTipsFrame2.Visible = vis
end

--设置宠物tips的info
function c:SetPetTips2Info(name,quality,atk,per)
    local ui = self.insts.petTipsFrame2
    ui.name.Text = name
    ui.quality.Text = hotpot.pro_cfg.quality[quality].name
    ui.atk.num.Text = '+'..big_number:ToString(atk)
    ui.tip.Text = string.format("Pet will always be %.0f%% stronger as your best pet!",(per*100))
end

--设置boxTips显示
function c:SetBoxTipsVisible(vis)
    self.insts.boxtipsFrame.Visible = vis
end

--设置boxTips的info
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

---设置GiftFrameInfo
function c:SetGiftFrameInfo(info)
    local list = info
    local len = 0
    for k,v in ipairs(list)do
        local idx = k
        len = len + 1
        local ui = hotpot:CloneInst_Loop(self.insts.giftFrame_list_item)
        ui.Visible = true
        ui.Parent = self.insts.giftFrame_list
        ui.LayoutOrder = len
        ui.board.icon.Image = v.icon

        if v.type_ then
            ui.board.icon.Size = UDim2.fromScale(1,1)
        end

        ui.board.num.Text = 'x'..big_number:ToString(v.num)
        -- ui.board.Image = hotpot.pro_cfg.quality[v.quality].board
        local color = qualityColor:FindFirstChild(tostring(v.quality))
        color:Clone().Parent = ui.board
        color:Clone().Parent = ui.board.UIStroke
        self.gift_item_list[k] = ui
        ui.buyBtn.MouseButton1Click:Connect(function()
            if self.__giftFrameItemClickHandle and self.__giftFrameItemClickObj then
                self.__giftFrameItemClickHandle(self.__giftFrameItemClickObj,idx)
            end
        end)
        ui.freeBtn.MouseButton1Click:Connect(function()
            if self.__giftFrameItemClickHandle and self.__giftFrameItemClickObj then
                self.__giftFrameItemClickHandle(self.__giftFrameItemClickObj,idx)
            end
        end)
        ui.board.MouseEnter:Connect(function()
            if self.__giftFrameItemMouseEnterHandle and self.__giftFrameItemMouseEnterObj then
                self.__giftFrameItemMouseEnterHandle(self.__giftFrameItemMouseEnterObj,idx)
            end
            local x = mouse.X
            local y = mouse.Y
            if hotpot.is_mobile then
                x = x + ui.AbsoluteSize.X / 2
            end
            local pos = self.insts.giftFrame.AbsolutePosition
            local pos1 = self.insts.bg.AbsolutePosition
            local size = self.insts.bg.AbsoluteSize
            local p = UDim2.fromScale((x-pos1.X)/size.X,(y-pos1.Y)/size.Y)
            self.insts.giftFrame_tipsFrame.Position = UDim2.new(0,x-pos.X,0,y-pos.Y)
            self.insts.relics_tipsFrame.Position = p
            self.insts.boxtipsFrame.Position = p
            self.insts.petTipsFrame2.Position = p
            self.insts.chatipsFrame.Position = p
        end)
        ui.board.MouseLeave:Connect(function()
            if self.__giftFrameItemMouseLeaveHandle and self.__giftFrameItemMouseLeaveObj then
                self.__giftFrameItemMouseLeaveHandle(self.__giftFrameItemMouseLeaveObj,idx)
            end
        end)
        ui.board.MouseMoved:Connect(function()
            local x = mouse.X
            local y = mouse.Y
            if hotpot.is_mobile then
                x = x + ui.AbsoluteSize.X / 2
            end
            local pos = self.insts.giftFrame.AbsolutePosition
            local pos1 = self.insts.bg.AbsolutePosition
            local size = self.insts.bg.AbsoluteSize
            local p = UDim2.fromScale((x-pos1.X)/size.X,(y-pos1.Y)/size.Y)
            self.insts.giftFrame_tipsFrame.Position = UDim2.new(0,x-pos.X,0,y-pos.Y)
            self.insts.relics_tipsFrame.Position = p
            self.insts.boxtipsFrame.Position = p
            self.insts.petTipsFrame2.Position = p
            self.insts.chatipsFrame.Position = p
        end)

        len = len + 1
        local temp = hotpot:CloneInst_Loop(self.insts.giftFrame_list_temp)
        temp.Visible = true
        temp.Parent = self.insts.giftFrame_list
        temp.LayoutOrder = len
        temp.Name = 'temp'..k
    end
    len = #list
    local temp = self.insts.giftFrame_list:FindFirstChild('temp'..len)
    if temp then
        temp.Visible = false
    end

    self:RefreshGiftFrameState(list)
end

--刷新GiftFrameState
function c:RefreshGiftFrameState(list)
    ----state 0已拥有  1可领取  2可购买  3不可领取-免费 4不可领取-付费
    for k,v in ipairs(list)do
        local ui = self.gift_item_list[k]
        local temp = self.insts.giftFrame_list:FindFirstChild('temp'..k)
        if v.state == 0 then
            ui.Visible = false
            temp.Visible = false
        elseif v.state == 1 then
            ui.freeBtn.Visible = true
            ui.freeBtnUnlock.Visible = false
            ui.buyBtn.Visible = false
            ui.buyBtnUnlock.Visible = false
        elseif v.state == 2 then
            ui.freeBtn.Visible = false
            ui.freeBtnUnlock.Visible = false
            ui.buyBtn.Visible = true
            ui.buyBtnUnlock.Visible = false
            ui.buyBtn.TextLabel.Text = v.price
        elseif v.state == 3 then
            ui.freeBtn.Visible = false
            ui.freeBtnUnlock.Visible = true
            ui.buyBtn.Visible = false
            ui.buyBtnUnlock.Visible = false
        else
            ui.freeBtn.Visible = false
            ui.freeBtnUnlock.Visible = false
            ui.buyBtn.Visible = false
            ui.buyBtnUnlock.Visible = true
            ui.buyBtnUnlock.TextLabel.Text = v.price
        end
    end
end

--设置礼物的tipsFrame的显示
function c:SetGiftFrameTipsFrameVisible(vis)
    self.insts.giftFrame_tipsFrame.Visible = vis
end

--设置礼物的tipsFrame的信息
function c:SetGiftFrameTipsFrameInfo(name,atk)
    self.insts.giftFrame_tipsFrame.name.Text = name
    self.insts.giftFrame_tipsFrame.atk.Text = big_number:ToString(atk)
end

--设置礼物的TipFrame的位置
function c:SetGiftFrameTipsFramePos(pos)
    self.insts.giftFrame_tipsFrame.Position = pos
end

--绑定giftFrame点击事件
function c:BindGiftFrameItemClickHandle(obj,handle)
    self.__giftFrameItemClickHandle = handle
    self.__giftFrameItemClickObj = obj
end

--绑定giftFrame的item鼠标进入事件
function c:BindGiftFrameItemMouseEnterHandle(obj,handle)
    self.__giftFrameItemMouseEnterObj = obj
    self.__giftFrameItemMouseEnterHandle = handle
end

--绑定giftFrame的item鼠标离开事件
function c:BindGiftFrameItemMouseLeaveHandle(obj,handle)
    self.__giftFrameItemMouseLeaveObj = obj
    self.__giftFrameItemMouseLeaveHandle = handle
end

------------------------------------------GiftFrame_End

------------------------------------------choicenessFrame_Start
---设置初始礼包信息
function c:SetStarterPackInfo(info)
    local list = info.list
    local len = #list
    local sum = 0
    for k,v in ipairs(list)do
        local ui = hotpot:CloneInst_Loop(self.insts.choicenessFrame_startpack.bg.list.item)
        ui.Visible = true
        ui.Parent = self.insts.choicenessFrame_startpack.bg.list
        sum = sum + 1
        ui.LayoutOrder = sum
        ui.board.icon.Image = v.icon
        ui.board.num.Text = 'x'..big_number:ToString(v.num)
        if v.type_ then
            ui.board.icon.Size = UDim2.fromScale(1,1)
        end
        local color = qualityColor:FindFirstChild(tostring(v.quality))
        color:Clone().Parent = ui.board
        color:Clone().Parent = ui.board.UIStroke

        if k ~= len then
            sum = sum + 1
            local temp = hotpot:CloneInst_Loop(self.insts.choicenessFrame_startpack.bg.list.temp)
            temp.Visible = true
            temp.Parent = self.insts.choicenessFrame_startpack.bg.list
            temp.LayoutOrder = sum
            temp.Name = 'temp'..k
        end
    end
    self.insts.choicenessFrame_startpack.bg.btn.TextLabel.Text = info.price
    self.insts.choicenessFrame_startpack.bg.btn1.TextLabel.Text = info.old_price
end

--设置初始礼包是否拥有
function c:SetStartPackOwned(owned)
    self.insts.choicenessFrame_startpack.bg.btn.Visible = not owned
    self.insts.choicenessFrame_startpack.bg.btn1.Visible = not owned
    self.insts.choicenessFrame_startpack.bg.owned.Visible = owned
end

--绑定购买初始礼包按钮
function c:BindBuyStartPackHandle(obj,handle)
    self.insts.choicenessFrame_startpack.bg.btn.MouseButton1Click:Connect(function()
        if handle and obj then
            handle(obj)
        end
    end)
end

--设置抽奖信息
function c:SetEggInfo(info)
    local list = info.list
    for k,v in ipairs(list)do
        local ui = hotpot:CloneInst_Loop(self.insts.choicenessFrame_egg.bg.list.item)
        ui.Visible = true
        ui.Parent = self.insts.choicenessFrame_egg.bg.list
        ui.bg.icon.Image = v.icon
        -- ui.bg.Image = hotpot.pro_cfg.quality[v.quality].board
        local color = qualityColor:FindFirstChild(tostring(v.quality))
        color:Clone().Parent = ui.bg
        color:Clone().Parent = ui.bg.UIStroke
        ui.bg.per.Text = v.per..'%'
        ui.LayoutOrder = v.order

        local idx = k
        ui.bg.MouseEnter:Connect(function()
            if self.__relics_mouseEnterHandle and self.__relics_mouseEnterObj then
                self.__relics_mouseEnterHandle(self.__relics_mouseEnterObj,idx)
            end
            local x = mouse.X
            local y = mouse.Y
            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize
            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y
            self.insts.relics_tipsFrame.Position = UDim2.fromScale(x,y)
            self.insts.chatipsFrame.Position = UDim2.fromScale(x,y)
        end)
        ui.bg.MouseLeave:Connect(function()
            self:SetRelicsTipsFrameVisible(false)
            self:SetChaTipsFrameVisible(false)
        end)
        ui.bg.MouseMoved:Connect(function()
            local x = mouse.X
            local y = mouse.Y
            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize
            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y
            self.insts.relics_tipsFrame.Position = UDim2.fromScale(x,y)
            self.insts.chatipsFrame.Position = UDim2.fromScale(x,y)
        end)
    end
    self.insts.choicenessFrame_egg.bg.btn1.price.Text = info.price1
    self.insts.choicenessFrame_egg.bg.btn3.price.Text = info.price3
    self.insts.choicenessFrame_egg.bg.btn10.price.Text = info.price10
end

--设置当前蛋的数量
function c:SetEggNum(num)
    self.insts.choicenessFrame_egg.bg.useBtn.num.Text = string.format('Use(%s)',num)
end

--设置relicsTipsFrame的显示
function c:SetRelicsTipsFrameVisible(vis)
    self.insts.relics_tipsFrame.Visible = vis
end

--设置tipsInfo
function c:SetRelicsTipsInfo(name,list,quality,suitInfo)
    local len = #list
    self.insts.relics_tipsFrame.name.Text = name

    for i = 1,7 do
        local color = self.insts.relics_tipsFrame.name:FindFirstChild(tostring(i))
        color.Enabled = i == quality
    end

    local ui
    for i = 1,4 do
        ui = self.insts.relics_tipsFrame:FindFirstChild(tostring(i))
        ui.Visible = i == len
    end

    ui = self.insts.relics_tipsFrame:FindFirstChild(tostring(len))

    for k,v in ipairs(list)do
        local TextLabel = ui:FindFirstChild('info'..k)
        if TextLabel then
            TextLabel.Text = v
        end
    end

    local sf = self.insts.relics_tipsFrame:FindFirstChild('suitFrame')
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

        sf.Visible = true
    else
        sf.Visible = false
    end
end

--设置chatTipsFrame的显示
function c:SetChaTipsFrameVisible(vis)
    self.insts.chatipsFrame.Visible = vis
end

--设置chatTipsInfo
function c:SetChaTipsInfo(name,per)
    self.insts.chatipsFrame.name.Text = name
    self.insts.chatipsFrame.desc.Text = string.format(chaTipsStr,per)
end

--设置圣诞礼包是否拥有
function c:SetHalloweenPackOwned(owned)
    self.insts.choicenessFrame_halloweenpack.bg.btn.Visible = not owned
    self.insts.choicenessFrame_halloweenpack.bg.btn1.Visible = not owned
    self.insts.choicenessFrame_halloweenpack.bg.owned.Visible = owned
end

--绑定购买蛋按钮
function c:BindBuyEggHandle(obj,handle)
    self.insts.choicenessFrame_egg.bg.btn1.MouseButton1Click:Connect(function()
        if handle and obj then
            handle(obj,1)
        end
    end)
    self.insts.choicenessFrame_egg.bg.btn3.MouseButton1Click:Connect(function()
        if handle and obj then
            handle(obj,3)
        end
    end)
    self.insts.choicenessFrame_egg.bg.btn10.MouseButton1Click:Connect(function()
        if handle and obj then
            handle(obj,10)
        end
    end)
end

--绑定使用蛋按钮
function c:BindBuySuitHandle(obj,handle)
    self.insts.choicenessFrame_suit.bg.btn1.MouseButton1Click:Connect(function()
        if handle and obj then
            handle(obj,1)
        end
    end)
    self.insts.choicenessFrame_suit.bg.btn3.MouseButton1Click:Connect(function()
        if handle and obj then
            handle(obj,3)
        end
    end)
    self.insts.choicenessFrame_suit.bg.btn10.MouseButton1Click:Connect(function()
        if handle and obj then
            handle(obj,10)
        end
    end)
end

--绑定relicsItem的鼠标进入事件
function c:BindRelicsItemMouseEnterHandle(obj,handle)
    self.__relics_mouseEnterHandle = handle
    self.__relics_mouseEnterObj = obj
end

--设置套装
function c:SetSuitInfo(info)
    local list = info.list
    for k,v in ipairs(list)do
        local ui = hotpot:CloneInst_Loop(self.insts.choicenessFrame_suit.bg.list.item)
        ui.Visible = true
        ui.Parent = self.insts.choicenessFrame_suit.bg.list
        ui.bg.icon.Image = v.icon
        -- ui.bg.Image = hotpot.pro_cfg.quality[v.quality].board
        local color = qualityColor:FindFirstChild(tostring(v.quality))
        color:Clone().Parent = ui.bg
        color:Clone().Parent = ui.bg.UIStroke
        ui.bg.per.Text = v.per..'%'
        ui.LayoutOrder = v.order

        local idx = k
        ui.bg.MouseEnter:Connect(function()
            if self.__relics_mouseEnterHandle and self.__relics_mouseEnterObj then
                self.__relics_mouseEnterHandle(self.__relics_mouseEnterObj,idx,true)
            end
            local x = mouse.X
            local y = mouse.Y
            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize

            local topbarInset = GuiService:GetGuiInset()
            local view = workspace.CurrentCamera.ViewportSize
            local suitSize = self.insts.suitFrame.AbsoluteSize
            local tipsSize = self.insts.relics_tipsFrame.AbsoluteSize
            if x + tipsSize.X + suitSize.X > view.X then
                x = view.X - tipsSize.X - suitSize.X - 5
            end
            if y + suitSize.Y > view.Y then
                y = view.Y - suitSize.Y - 5 - topbarInset.Y
            end

            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y
            self.insts.relics_tipsFrame.Position = UDim2.fromScale(x,y)
            self.insts.chatipsFrame.Position = UDim2.fromScale(x,y)
        end)
        ui.bg.MouseLeave:Connect(function()
            self:SetRelicsTipsFrameVisible(false)
            self:SetChaTipsFrameVisible(false)
        end)
        ui.bg.MouseMoved:Connect(function()
            local x = mouse.X
            local y = mouse.Y
            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize

            local topbarInset = GuiService:GetGuiInset()
            local view = workspace.CurrentCamera.ViewportSize
            local suitSize = self.insts.suitFrame.AbsoluteSize
            local tipsSize = self.insts.relics_tipsFrame.AbsoluteSize
            if x + tipsSize.X + suitSize.X > view.X then
                x = view.X - tipsSize.X - suitSize.X - 5
            end
            if y + suitSize.Y > view.Y then
                y = view.Y - suitSize.Y - 5 - topbarInset.Y
            end

            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y
            self.insts.relics_tipsFrame.Position = UDim2.fromScale(x,y)
            self.insts.chatipsFrame.Position = UDim2.fromScale(x,y)
        end)
    end
    self.insts.choicenessFrame_suit.bg.btn1.price.Text = info.price1
    self.insts.choicenessFrame_suit.bg.btn3.price.Text = info.price3
    self.insts.choicenessFrame_suit.bg.btn10.price.Text = info.price10
end

--设置套装
function c:SetNewSuitInfo(info)
    for k,v in ipairs(info)do
        local ui = hotpot:CloneInst_Loop(self.insts.newSuit_item)
        ui.Parent = self.insts.newSuit
        ui.Visible = true
        ui.bg.title.Text = v.name
        ui.bg.board.icon.Image = v.icon
        local color = qualityColor:FindFirstChild(tostring(v.quality))
        if color then
            color:Clone().Parent = ui.bg.board
            color:Clone().Parent = ui.bg.board.UIStroke
        end
        ui.bg.btn.price.Text = v.price

        local idx = k
        ui.bg.board.MouseEnter:Connect(function()
            if self.__relics_mouseEnterHandle and self.__relics_mouseEnterObj then
                self.__relics_mouseEnterHandle(self.__relics_mouseEnterObj,idx,true)
            end
            local x = mouse.X
            local y = mouse.Y
            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize

            local topbarInset = GuiService:GetGuiInset()
            local view = workspace.CurrentCamera.ViewportSize
            local suitSize = self.insts.suitFrame.AbsoluteSize
            local tipsSize = self.insts.relics_tipsFrame.AbsoluteSize
            if x + tipsSize.X + suitSize.X > view.X then
                x = view.X - tipsSize.X - suitSize.X - 5
            end
            if y + suitSize.Y > view.Y then
                y = view.Y - suitSize.Y - 5 - topbarInset.Y
            end

            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y
            self.insts.relics_tipsFrame.Position = UDim2.fromScale(x,y)
            self.insts.chatipsFrame.Position = UDim2.fromScale(x,y)
        end)
        ui.bg.board.MouseLeave:Connect(function()
            self:SetRelicsTipsFrameVisible(false)
            self:SetChaTipsFrameVisible(false)
        end)
        ui.bg.board.MouseMoved:Connect(function()
            local x = mouse.X
            local y = mouse.Y
            local a_pos = self.insts.bg.AbsolutePosition
            local a_size = self.insts.bg.AbsoluteSize

            local topbarInset = GuiService:GetGuiInset()
            local view = workspace.CurrentCamera.ViewportSize
            local suitSize = self.insts.suitFrame.AbsoluteSize
            local tipsSize = self.insts.relics_tipsFrame.AbsoluteSize
            if x + tipsSize.X + suitSize.X > view.X then
                x = view.X - tipsSize.X - suitSize.X - 5
            end
            if y + suitSize.Y > view.Y then
                y = view.Y - suitSize.Y - 5 - topbarInset.Y
            end

            x = (x - a_pos.X) / a_size.X
            y = (y - a_pos.Y) / a_size.Y
            self.insts.relics_tipsFrame.Position = UDim2.fromScale(x,y)
            self.insts.chatipsFrame.Position = UDim2.fromScale(x,y)
        end)

        local id = v.goods_id
        ui.bg.btn.MouseButton1Click:Connect(function()
            self.__winsItemClickHandle(self.__winsItemClickObj,id)
        end)
    end
end
------------------------------------------choicenessFrame_End

------------------------------------------gamepassFrame_Start
---设置GamepassFrameInfo
function c:SetGamepassFrameInfo(info)
    local list = info.list
    for k,v in ipairs(list)do
        local ui = hotpot:CloneInst_Loop(self.insts.gamepassFrame_item)
        ui.Visible = true
        ui.Parent = self.insts.gamepassFrame_list
        ui.bg.title.Text = v.name
        ui.bg.icon.Image = v.icon or ''
        ui.bg.desc.Text = v.desc or ''
        ui.bg.btn.price.Text = v.price or ''
        self.gamepass_item_list[v.id] = ui
        if v.id ~= 64 then
            local giftIcon = hotpot:GetPath_Loop('bg.btn.giftIcon',ui)
            giftIcon:Destroy()
        end

        local id = v.id
        ui.bg.btn.MouseButton1Click:Connect(function()
            if self.__gamepassItemClickHandle and self.__gamepassItemClickObj then
                self.__gamepassItemClickHandle(self.__gamepassItemClickObj,id)
            end
        end)
    end

    local vip = info.vip
    self.insts.gamepassFrame_vip.bg.desc.Text = vip.desc or ''
    self.insts.gamepassFrame_vip.bg.btn.price.Text = vip.price or ''
    self.gamepass_item_list[vip.id] = self.insts.gamepassFrame_vip
    local id = vip.id
    self.insts.gamepassFrame_vip.bg.btn.MouseButton1Click:Connect(function()
        if self.__gamepassItemClickHandle and self.__gamepassItemClickObj then
            self.__gamepassItemClickHandle(self.__gamepassItemClickObj,id)
        end
    end)
end

--设置gamepassFrame的item的购买状态
function c:SetGamepassItemOwned(id,owned)
    local ui = self.gamepass_item_list[id]
    if ui then
        ui.bg.btn.Visible = not owned
        ui.bg.owned.Visible = owned
    end
end

--绑定gamepassFrame的item的购买按钮
function c:BindGamepassItemClickHandle(obj,handle)
    self.__gamepassItemClickHandle = handle
    self.__gamepassItemClickObj = obj
end
------------------------------------------gamepassFrame_End

------------------------------------------limitPetFrame_Start
---设置limitPetFrameInfo
function c:SetLimitPetFrameInfo(info)
    local list = info
    for k,v in ipairs(list)do
        local ui = hotpot:CloneInst_Loop(self.insts.limitPetFrame_item)
        ui.Visible = true
        ui.Parent = self.insts.limitPetFrame_list
        ui.bg.title.Text = v.name
        ui.bg.icon.Image = v.icon or ''
        if v.icon2 then
            ui.bg.icon.ImageLabel.Image = v.icon2 or ''
        end
        local color = qualityColor:FindFirstChild(tostring(limitQualityList[k]))
        if color then
            color:Clone().Parent = ui.bg.icon.board
        end
        ui.bg.btn.price.Text = v.price or ''
        ui.bg.atk.Text = 'x'.. big_number:ToString(v.atk)
        ui.Value.Value = (k <= 2 and 1 or 2)
        self.limitPet_item_list[v.id] = ui

        if k == 4 then
            local color = qualityColor:FindFirstChild('6')
            local clone = color:Clone()
            clone.Parent = ui.bg.title
            UIGradientHelper:Add(clone)
        else
            local color = qualityColor:FindFirstChild(tostring(v.quality))
            color:Clone().Parent = ui.bg.title
        end

        local id = v.id
        ui.bg.btn.MouseButton1Click:Connect(function()
            if self.__limitPetItemClickHandle and self.__limitPetItemClickObj then
                self.__limitPetItemClickHandle(self.__limitPetItemClickObj,id)
            end
        end)
    end
end

--设置limitPetFrame的item的购买状态
function c:SetLimitPetItemOwned(id,owned)
    local ui = self.limitPet_item_list[id]
    if ui then
        ui.bg.btn.Visible = not owned
        ui.bg.owned.Visible = owned
    end
end

--绑定limitPetFrame的item的购买按钮
function c:BindLimitPetItemClickHandle(obj,handle)
    self.__limitPetItemClickHandle = handle
    self.__limitPetItemClickObj = obj
end
------------------------------------------limitPetFrame_End

------------------------------------------boostsFrame_Start
---设置boostsFrameInfo
function c:SetBoostsFrameInfo(info)
    local list = info
    for k,v in ipairs(list)do
        local id = v.id
        local ui = hotpot:GetPath_Loop(tostring(k),self.insts.boostsFrame.list)
        ui.bg.icon.Image = v.icon
        ui.bg.title.Text = v.name
        ui.bg.desc.Text = v.desc
        ui.bg.useBtn.num.Text = string.format('Use(%s)',v.num)
        ui.bg.btn.TextLabel.Text = v.price
        ui.bg.btn.MouseButton1Click:Connect(function()
            if self.__boostItemClickHandle and self.__boostItemClickObj then
                self.__boostItemClickHandle(self.__boostItemClickObj,id)
            end
        end)
        ui.bg.useBtn.MouseButton1Click:Connect(function()
            if self.__boostUseBtnClickHandle and self.__boostUseBtnClickObj then
                self.__boostUseBtnClickHandle(self.__boostUseBtnClickObj,id)
            end
        end)
    end
end

--设置药水数量
function c:SetBoostsItemNum(id,num)
    local ui = hotpot:GetPath_Loop(tostring(id),self.insts.boostsFrame.list)
    ui.bg.useBtn.num.Text = string.format('Use(%s)',num)
end

--绑定boosts购买按钮
function c:BindBoostFrameItemClickHandle(obj,handle)
    self.__boostItemClickHandle = handle
    self.__boostItemClickObj = obj
end

--绑定boosts使用按钮
function c:BindBoostFrameUseBtnClickHandle(obj,handle)
    self.__boostUseBtnClickHandle = handle
    self.__boostUseBtnClickObj = obj
end
------------------------------------------boostsFrame_End

------------------------------------------winsFrame_Start
--设置winsFrame的信息
function c:SetWinsFrameInfo(info)
    local list = info
    for k,v in ipairs(list)do
        local ui = hotpot:CloneInst_Loop(self.insts.winsFrame_item)
        ui.Visible = true
        ui.Parent = self.insts.winsFrame_list
        ui.bg.title.Text = v.name
        ui.bg.btn.price.Text = v.price or ''
        ui.bg.icon.Image = v.icon or ''
        ui.bg.num.Text = v.num
        if v.isGems then
            ui.bg.num.ImageLabel.Image = 'rbxassetid://134804226826116'
        else
            ui.bg.btn.giftIcon:Destroy()
        end

        if v.isLuckyStone then
            ui.bg.num.ImageLabel.Visible = false
            ui.bg.num.Text = 'x'..v.num
            local size = ui.bg.icon.Size
            ui.bg.icon.Size = UDim2.fromScale(size.X.Scale/2,size.Y.Scale/2)
            ui.bg.desc.Visible = true
            ui.bg.desc.Text = string.format('Forge rate+%s%%',v.per)
        end
        if v.isForgeStone then
            ui.bg.num.ImageLabel.Visible = false
            ui.bg.num.Text = 'x'..v.num
            local size = ui.bg.icon.Size
            ui.bg.icon.Size = UDim2.fromScale(size.X.Scale/2,size.Y.Scale/2)
            ui.bg.desc.Visible = false
        end

        ui.bg.Image = boardList[k]
        self.wins_item_list[v.id] = ui

        local id = v.id
        ui.bg.btn.MouseButton1Click:Connect(function()
            if self.__winsItemClickHandle and self.__winsItemClickObj then
                self.__winsItemClickHandle(self.__winsItemClickObj,id)
            end
        end)
    end
end

--刷新金币
function c:RefreshGold(list)
    for k,v in ipairs(list)do
        local ui = self.wins_item_list[v.id]
        if ui then
            ui.bg.num.Text = v.num
        end
    end
end

--绑定winsFrame购买事件
function c:BindWinsFrameItemClickHandle(obj,handle)
    self.__winsItemClickHandle = handle
    self.__winsItemClickObj = obj
end
---------------------------------------------winsFrame_End

------------------------------------------LuckyFrame_Start
---设置幸运值
function c:SetLuckFrameLucky(old,new)
    self.insts.luckyFrame_old.Text = old..'x'
    self.insts.luckyFrame_new.Text = new..'x'
end

---设置幸运值cd
function c:SetLuckFrameLuckyCD(cd)
    if cd then
        self.insts.luckyFrame_cd.Text = big_number:TransformDateToString(cd)
    else
        self.insts.luckyFrame_cd.Text = ''
    end
end

--设置幸运价格
function c:SetLuckFramePrice(price)
    self.insts.luckyFrame_btn.price.Text = price
end

--设置幸运价格按钮显示
function c:SetLuckyFrameBtnVis(vis)
    self.insts.luckyFrame_btn.Visible = vis
end

--绑定luckyFrame的btn点击事件
function c:BindLuckyFrameBtnClickHandle(obj,handle)
    self.insts.luckyFrame_btn.MouseButton1Click:Connect(function()
        if handle and obj then
            handle(obj)
        end
    end)
end
------------------------------------------LuckyFrame_End

--绑定赠送礼物的玩家按钮
function c:BindSelectPlayerItemBtnClickHandle(obj,handle)
    self.__selectPlayerItemClickHandle = handle
    self.__selectPlayerItemClickObj = obj
end

--绑定取消按钮点击事件
function c:BindCancelBtnClickHandle(obj,handle)
    self.__cancelBtnClickHandle = handle
    self.__cancelBtnClickObj = obj
end

--绑定圣诞礼包按钮点击事件
function c:BindHalloweenBtnClickHandle(obj,handle)
    self.insts.halloween_btn.MouseButton1Click:Connect(function()
        if handle and obj then
            handle(obj)
        end
    end)
end

return c