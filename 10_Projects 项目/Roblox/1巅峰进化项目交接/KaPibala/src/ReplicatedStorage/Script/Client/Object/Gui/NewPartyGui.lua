local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local bigNumber = hotpot.load.BigNumberHelper()

---@class NewPartyGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageButton		
	c.insts.OutBg = 'Frame.OutBg'    
    ---@type Frame		
	c.insts.OutBg_item = 'Frame.OutBg.item'    

    ---@type ImageButton		
	c.insts.close = 'Frame.bg.close'    

    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ScrollingFrame		
	c.insts.ScrollingFrame = 'Frame.bg.ScrollingFrame'    
    ---@type Frame		
	c.insts.scroll_item = 'Frame.bg.ScrollingFrame.item'    
    ---@type ImageButton		
	c.insts.exitParty = 'Frame.bg.exitParty'    
    ---@type ImageLabel		
	c.insts.recivaRequestPanel = 'Frame.bg.reciveRequestPanel'    
    ---@type ImageButton		
	c.insts.openBtn = 'Frame.bg.reciveRequestPanel.openBtn'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.reciveRequestPanel.closeBtn'    
    ---@type ImageLabel		
	c.insts.ownerPanel = 'Frame.bg.ownerPanel'    
    ---@type ImageButton		
	c.insts.SetOwnerBtn = 'Frame.bg.ownerPanel.SetOwnerBtn'    
    ---@type ImageButton		
	c.insts.KickPlayerBtn = 'Frame.bg.ownerPanel.KickPlayerBtn'    

    ---@type ImageLabel		
	c.insts.invitePanel = 'Frame.invitePanel'    
    ---@type ImageButton		
	c.insts.noBtn = 'Frame.invitePanel.noBtn'    
    ---@type ImageButton		
	c.insts.yesBtn = 'Frame.invitePanel.yesBtn'    
    ---@type TextLabel		
	c.insts.invitePanel_info = 'Frame.invitePanel.info'    

    ---@type TextLabel		
	c.insts.tips = 'Frame.tips'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.NewPartyGui',_G.Resource)
    c.super.ctor(self,ui)

    self.scrllItem = {}
    self.OutBgItem = {}

    self.insts.close.MouseButton1Click:Connect(function()
        self:SetBgVisible(false)
        self:SetOutBgVisible(true)
    end)
end

function c:SetTipsVisible(visible)
    self.insts.tips.Visible = visible
end

function c:SetTipsPos(pos)
    self.insts.tips.Position = pos
end

function c:SetInvitePanelVisible(visible)
    self.insts.invitePanel.Visible = visible
end

function c:SetInvitePanelInfo(info)
    self.insts.invitePanel_info.Text = info
end

function c:SetBgVisible(visible)
    self.insts.bg.Visible = visible
    self:SetOwnerPanelVisible(false)
end

function c:SetOwnerPanelVisible(visible)
    self.insts.ownerPanel.Visible = visible
end

function c:SetRecivaRequestPanelVisible(visible)
    self.insts.recivaRequestPanel.Visible = visible
end

function c:SetOpenBtnVisible(visible)
    self.insts.openBtn.Visible = visible
end

function c:SetCloseBtnVisible(visible)
    self.insts.closeBtn.Visible = visible
end

function c:AddItemInScroll(uid,icon,now,max)
    if self.scrllItem[uid] then
        return
    end
    local ui = hotpot:CloneInst_Loop(self.insts.scroll_item)
    ui.Parent = self.insts.ScrollingFrame
    ui.Name = uid
    ui.Visible = true
    ui.icon.Image = icon
    ui.bg.fg.Size = UDim2.fromScale(math.clamp(now/max,0,1),1)
    ui.bg.num.Text = string.format('%s/%s(%.2f%%)',bigNumber:ToString(now),bigNumber:ToString(max),now/max*100)
    self.scrllItem[uid] = ui

    ui.btn.MouseButton1Click:Connect(function()
        if self.__scrollItemHandle then
            self.__scrollItemHandle(self.__scrollItemObj,uid)
        end

        local pos = ui.AbsolutePosition
        local bgPos = self.insts.bg.AbsolutePosition
        local bgSize = self.insts.bg.AbsoluteSize
        local y = (pos.Y - bgPos.Y)/bgSize.Y
        self.insts.ownerPanel.Position = UDim2.fromScale(-0.035,y)
    end)
end

function c:DelItemInScroll(uid)
    local ui = self.scrllItem[uid]
    if ui then
        ui:Destroy()
        self.scrllItem[uid] = nil
    end
end

function c:DelAllItemInScroll()
    for k,v in pairs(self.scrllItem) do
        v:Destroy()
    end
    self.scrllItem = {}
end

function c:SetItemPro(uid,now,max)
    local ui = self.scrllItem[uid]
    if not ui then
        return 
    end
    ui.bg.fg.Size = UDim2.fromScale(math.clamp(now/max,0,1),1)
    ui.bg.num.Text = string.format('%s/%s(%.2f%%)',bigNumber:ToString(now),bigNumber:ToString(max),now/max*100)
end

function c:SetItemTopVisible(uid,vis,tip)
    local ui = self.scrllItem[uid]
    if not ui then
        return 
    end
    -- ui.top.tip.Text = tip
    ui.bg.fg.top.Visible = vis
    ui.icon.ImageColor3 = vis and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
end

function c:SetItemCrownVisible(uid,vis)
    local ui = self.scrllItem[uid]
    if not ui then
        return 
    end
    ui.icon.crown.Visible = vis
end

function c:SetOutBgVisible(visible)
    self.insts.OutBg.Visible = visible
end

function c:AddItemInOut(uid,icon,now,max)
    if self.OutBgItem[uid] then
        return
    end
    local ui = hotpot:CloneInst_Loop(self.insts.OutBg_item)
    ui.Parent = self.insts.OutBg
    ui.Name = uid
    ui.Visible = true
    ui.icon.Image = icon
    ui.bg.fg.Size = UDim2.fromScale(math.clamp(now/max,0,1),1)
    ui.bg.num.Text = string.format('%s/%s(%.2f%%)',bigNumber:ToString(now),bigNumber:ToString(max),now/max*100)
    self.OutBgItem[uid] = ui
end

function c:DelItemInOut(uid)
    local ui = self.OutBgItem[uid]
    if ui then
        ui:Destroy()
        self.OutBgItem[uid] = nil
    end
end

function c:DelAllItemInOut()
    for k,v in pairs(self.OutBgItem) do
        v:Destroy()
    end
    self.OutBgItem = {}
end

function c:SetOutItemPro(uid,now,max)
    local ui = self.OutBgItem[uid]
    if not ui then
        return 
    end
    ui.bg.fg.Size = UDim2.fromScale(math.clamp(now/max,0,1),1)
    ui.bg.num.Text = string.format('%s/%s(%.2f%%)',bigNumber:ToString(now),bigNumber:ToString(max),now/max*100)
end

function c:SetOutItemCrownVisible(uid,vis)
    local ui = self.OutBgItem[uid]
    if not ui then
        return 
    end
    ui.icon.crown.Visible = vis
end

function c:SetOutItemTopVisible(uid,vis,tip)
    local ui = self.OutBgItem[uid]
    if not ui then
        return 
    end
    -- ui.top.tip.Text = tip
    ui.bg.fg.top.Visible = vis
    ui.icon.ImageColor3 = vis and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
end

function c:BindAgreeBtnClickHandle(obj,handle)
    self.insts.yesBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindRefuseBtnClickHandle(obj,handle)
    self.insts.noBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindOutBgClickHandle(obj,handle)
    self.insts.OutBg.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindExitBtnClickHandle(obj,handle)
    self.insts.exitParty.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindScrollItemClickHandle(obj,handle)
    self.__scrollItemHandle = handle
    self.__scrollItemObj = obj
end

function c:BindOpenBtnClickHandle(obj,handle)
    self.insts.openBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindCloseBtnClickHandle(obj,handle)
    self.insts.closeBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindSetOwnerBtnClickHandle(obj,handle)
    self.insts.SetOwnerBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindKickBtnClickHandle(obj,handle)
    self.insts.KickPlayerBtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end


return c