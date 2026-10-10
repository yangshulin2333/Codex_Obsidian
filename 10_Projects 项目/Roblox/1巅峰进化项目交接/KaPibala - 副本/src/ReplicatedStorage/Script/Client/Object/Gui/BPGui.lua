local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type BigNumberHelper
local bigNumber = hotpot.load.BigNumberHelper()
---@type Players
local players = game:GetService('Players')
---@type Player
local player = players.LocalPlayer
---@type Mouse
local mouse = player:GetMouse()

local tweenInfo = TweenInfo.new(0.2)
local lv_str = 'LV%s  EXP:%s/%s'
local qualityColor = hotpot:GetPath_Loop('qualityColor',_G.Resource)

---@class BPGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.close = 'Frame.bg.close'    

    ---@type ImageButton		
	c.insts.passBtn = 'Frame.bg.passBtn'    
    ---@type ImageButton		
	c.insts.taskBtn = 'Frame.bg.taskBtn'    

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
	c.insts.taskFrame = 'Frame.bg.taskFrame'  
    ---@type Frame		
	c.insts.taskFrame_list = 'Frame.bg.taskFrame.bg.list'    
    ---@type Frame		
	c.insts.taskFrame_item = 'Frame.bg.taskFrame.bg.list.item'     
    
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

    ---@type TextLabel		
	c.insts.cd = 'Frame.bg.cd'    

    ---@type ImageLabel		
	c.insts.pettipsFrame = 'Frame.bg.pettipsFrame'   
    ---@type ImageLabel		
	c.insts.relicstipsFrame = 'Frame.bg.relicstipsFrame'    
    ---@type ImageLabel		
	c.insts.boxtipsFrame = 'Frame.bg.boxtipsFrame' 
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.BPGui',_G.Resource)
    c.super.ctor(self,ui)

    self.bp_item_list = {}
    self.task_item_list = {}

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
    self.insts.passBtn.MouseButton1Click:Connect(function()
        if self.insts.passFrame.Visible then
            return
        end
        self:SetBattlePassFrameVisible(true)
        self:SetTaskFrameVisible(false)
        self:SetBattlePassBtnSelect(true)
        self:SetTaskBtnSelect(false)
    end)
    self.insts.taskBtn.MouseButton1Click:Connect(function()
        if self.insts.taskFrame.Visible then
            return
        end
        self:SetBattlePassFrameVisible(false)
        self:SetTaskFrameVisible(true)
        self:SetBattlePassBtnSelect(false)
        self:SetTaskBtnSelect(true)
    end) 
end

function c:SetCD(cd)
    self.insts.cd.Text = bigNumber:GetTime(cd)
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

function c:Show()
    self.insts.Frame.Position = UDim2.fromScale(0.5,0.7)
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
        {Position = UDim2.fromScale(0.5,0.7)},
        function()
            c.super.Hide(self)
        end
    )
    ui_manager.ui_list.hud_gui:Show()
end

function c:SetBattlePassBtnSelect(se)
    self.insts.passBtn.ImageTransparency = se and 0 or 1
    self.insts.passBtn.info.TextColor3 = se and Color3.fromRGB(255,255,255) or Color3.fromRGB(179,176,176)
end

function c:SetTaskBtnSelect(se)
    self.insts.taskBtn.ImageTransparency = se and 0 or 1
    self.insts.taskBtn.info.TextColor3 = se and Color3.fromRGB(255,255,255) or Color3.fromRGB(179,176,176)
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
        local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

        local p_x = math.min(viewSize.X - pettipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local r_x = math.min(viewSize.X - relicstipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local b_x = math.min(viewSize.X - boxtipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)

        if hotpot.is_mobile then
            b_y = b_y - 50
        end
        
        p_x = (p_x - a_pos.X) / a_size.X 
        p_y = (p_y - a_pos.Y) / a_size.Y 
        r_x = (r_x - a_pos.X) / a_size.X 
        r_y = (r_y - a_pos.Y) / a_size.Y 
        b_x = (b_x - a_pos.X) / a_size.X 
        b_y = (b_y - a_pos.Y) / a_size.Y 

        self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
        self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
        self.insts.boxtipsFrame.Position = UDim2.fromScale(b_x,b_y)
    end)
    ui.free.MouseLeave:Connect(function()
        self.insts.pettipsFrame.Visible = false
        self.insts.relicstipsFrame.Visible = false
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
        local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

        local p_x = math.min(viewSize.X - pettipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local r_x = math.min(viewSize.X - relicstipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local b_x = math.min(viewSize.X - boxtipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        
        if hotpot.is_mobile then
            b_y = b_y - 50
        end

        p_x = (p_x - a_pos.X) / a_size.X 
        p_y = (p_y - a_pos.Y) / a_size.Y 
        r_x = (r_x - a_pos.X) / a_size.X 
        r_y = (r_y - a_pos.Y) / a_size.Y 
        b_x = (b_x - a_pos.X) / a_size.X 
        b_y = (b_y - a_pos.Y) / a_size.Y 

        self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
        self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
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
        local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

        local p_x = math.min(viewSize.X - pettipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local r_x = math.min(viewSize.X - relicstipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local b_x = math.min(viewSize.X - boxtipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        
        if hotpot.is_mobile then
            b_y = b_y - 50
        end

        p_x = (p_x - a_pos.X) / a_size.X 
        p_y = (p_y - a_pos.Y) / a_size.Y 
        r_x = (r_x - a_pos.X) / a_size.X 
        r_y = (r_y - a_pos.Y) / a_size.Y 
        b_x = (b_x - a_pos.X) / a_size.X 
        b_y = (b_y - a_pos.Y) / a_size.Y 

        self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
        self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
        self.insts.boxtipsFrame.Position = UDim2.fromScale(b_x,b_y)
    end)
    ui.premium.MouseLeave:Connect(function()
        self.insts.pettipsFrame.Visible = false
        self.insts.relicstipsFrame.Visible = false
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
        local boxtipsSize = self.insts.boxtipsFrame.AbsoluteSize

        local p_x = math.min(viewSize.X - pettipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local p_y = math.min(viewSize.Y - pettipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local r_x = math.min(viewSize.X - relicstipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local r_y = math.min(viewSize.Y - relicstipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        local b_x = math.min(viewSize.X - boxtipsSize.X - ui.free.AbsoluteSize.Y / 2,x)
        local b_y = math.min(viewSize.Y - boxtipsSize.Y - ui.free.AbsoluteSize.Y / 2,y)
        
        if hotpot.is_mobile then
            b_y = b_y - 50
        end

        p_x = (p_x - a_pos.X) / a_size.X 
        p_y = (p_y - a_pos.Y) / a_size.Y 
        r_x = (r_x - a_pos.X) / a_size.X 
        r_y = (r_y - a_pos.Y) / a_size.Y 
        b_x = (b_x - a_pos.X) / a_size.X 
        b_y = (b_y - a_pos.Y) / a_size.Y 

        self.insts.pettipsFrame.Position = UDim2.fromScale(p_x,p_y)
        self.insts.relicstipsFrame.Position = UDim2.fromScale(r_x,r_y)
        self.insts.boxtipsFrame.Position = UDim2.fromScale(b_x,b_y)
    end)

    self.bp_item_list[lv] = ui
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

function c:AddItemInTaskFrame(id,desc,exp)
    local ui = hotpot:CloneInst_Loop(self.insts.taskFrame_item)
    ui.Visible = true
    ui.Parent = self.insts.taskFrame_list
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

function c:SetPetTipsFrameVisible(vis)
    self.insts.pettipsFrame.Visible = vis
end

function c:SetRelicstipsFrameVisible(vis)
    self.insts.relicstipsFrame.Visible = vis
end

function c:SetBoxtipsFrameVisible(vis)
    self.insts.boxtipsFrame.Visible = vis
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

function c:BindMouseInPassItemHandle(obj,handle)
    self.passMouseIn_handle = handle
    self.passMouseIn_obj = obj
end

return c
