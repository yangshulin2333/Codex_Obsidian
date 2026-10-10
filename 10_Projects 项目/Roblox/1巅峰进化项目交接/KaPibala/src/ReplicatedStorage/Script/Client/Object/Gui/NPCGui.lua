local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

---@class NPCGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.closebtn = 'Frame.bg.normalbtns.closebtn'       
    ---@type TextLabel		
	c.insts.title = 'Frame.bg.title'    
    ---@type TextLabel		
	c.insts.info = 'Frame.bg.info'    
    ---@type ImageButton		
	c.insts.openbtn = 'Frame.bg.normalbtns.openbtn'       

    ---@type Frame		
	c.insts.normalbtns = 'Frame.bg.normalbtns'    
    ---@type Frame		
	c.insts.forgebtns = 'Frame.bg.forgebtns'    

    ---@type ImageButton		
	c.insts.mountbtn = 'Frame.bg.forgebtns.mountbtn'    
    ---@type ImageButton		
	c.insts.relicsbtn = 'Frame.bg.forgebtns.relicsbtn'    
    ---@type ImageButton		
	c.insts.relics_closebtn = 'Frame.bg.forgebtns.closebtn'    

    ---@type Frame		
	c.insts.challengebtns = 'Frame.bg.challengebtns'    
    ---@type ImageButton		
	c.insts.challenge_cliambtn = 'Frame.bg.challengebtns.cliambtn'  
    ---@type ImageButton		
	c.insts.challenge_closebtn = 'Frame.bg.challengebtns.closebtn'      

    ---@type Frame		
	c.insts.warbtns = 'Frame.bg.warbtns'    
    ---@type ImageButton		
	c.insts.war_closebtn = 'Frame.bg.warbtns.closebtn'    
    ---@type ImageButton		
	c.insts.war_Registerbtn = 'Frame.bg.warbtns.Registerbtn'    
    ---@type ImageButton		
	c.insts.war_claimbtn = 'Frame.bg.warbtns.claimbtn'    
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.NPCGui',_G.Resource)
    c.super.ctor(self,ui,true)

    self.insts.closebtn.MouseButton1Click:Connect(function()
        self:Hide()
        ui_manager.ui_list.hud_gui:Show()
        if self.close_obj and self.close_handle then
            self.close_handle(self.close_obj)
        end
    end)
    self.insts.relics_closebtn.MouseButton1Click:Connect(function()
        self:Hide()
        ui_manager.ui_list.hud_gui:Show()
        if self.close_obj and self.close_handle then
            self.close_handle(self.close_obj)
        end
    end)
    self.insts.challenge_closebtn.MouseButton1Click:Connect(function()
        self:Hide()
        ui_manager.ui_list.hud_gui:Show()
        if self.close_obj and self.close_handle then
            self.close_handle(self.close_obj)
        end
    end)
    self.insts.war_closebtn.MouseButton1Click:Connect(function()
        self:Hide()
        ui_manager.ui_list.hud_gui:Show()
        if self.close_obj and self.close_handle then
            self.close_handle(self.close_obj)
        end
    end)
end

function c:SetTitle(title)
    self.insts.title.Text = title
end

function c:SetInfo(info)
    local len = utf8.len(info)
	local chars = {}
    spawn(function()
        for i = 1, len do
            self.insts.info.Text = info:sub(1, i)
            task.wait(0.01)
        end
    end)
end

function c:SetNormalBtnVisible(visible)
    self.insts.normalbtns.Visible = visible
    if visible then
        self.insts.challengebtns.Visible = false
        self.insts.warbtns.Visible = false
    end
end

function c:SetForgeBtnVisible(visible)
    self.insts.forgebtns.Visible = visible
    if visible then
        self.insts.challengebtns.Visible = false
        self.insts.warbtns.Visible = false
    end
end

function c:SetChallengeBtnVisible(visible)
    self.insts.challengebtns.Visible = visible
    if visible then
        self.insts.warbtns.Visible = false
    end
end

function c:SetWarBtnVisible(visible)
    self.insts.warbtns.Visible = visible
end

function c:SetWarRegisterBtnState(bool)
    if bool then
        self.insts.war_Registerbtn.Image = 'rbxassetid://111460696655002'
        self.insts.war_Registerbtn.TextLabel.Text = 'Register'
    else
        self.insts.war_Registerbtn.Image = 'rbxassetid://106699665783834'
        self.insts.war_Registerbtn.TextLabel.Text = 'Already registered'
    end
end

function c:BindOpenBtnClickHandle(obj,handle)
    self.insts.openbtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindCloseBtnClickHandle(obj,handle)
    self.close_obj = obj
    self.close_handle = handle
end

function c:BindMountBtnClickHandle(obj,handle)
    self.insts.mountbtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindRelicBtnClickHandle(obj,handle)
    self.insts.relicsbtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindChallengeClaimBtnClickHandle(obj,handle)
    self.insts.challenge_cliambtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindWarRegisterBtnClickHandle(obj,handle)
    self.insts.war_Registerbtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

function c:BindWarClaimBtnClickHandle(obj,handle)
    self.insts.war_claimbtn.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c