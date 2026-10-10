local hotpot = _G.ClientHotpot
---@type TweenHelper
local tweenHelper = hotpot.load.TweenHelper()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local info = TweenInfo.new(0.2)

---@class SettingGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())

local function GetInsts()
    c.insts = {}
    ---@type Frame		
	c.insts.Frame = 'Frame'    
    ---@type ImageLabel		
	c.insts.bg = 'Frame.bg'    
    ---@type ImageButton		
	c.insts.closeBtn = 'Frame.bg.closeBtn'       
    ---@type ImageButton		
	c.insts.music_btn = 'Frame.bg.ScrollingFrame.music.bg.btn' 
    ---@type ImageButton		
	c.insts.sfx_btn = 'Frame.bg.ScrollingFrame.SFX.bg.btn'   
    ---@type ImageButton		
	c.insts.pets_btn = 'Frame.bg.ScrollingFrame.pets.bg.btn'     
    ---@type TextBox		
	c.insts.code_TextBox = 'Frame.bg.ScrollingFrame.code.bg.TextBox'    
    ---@type ImageButton		
	c.insts.code_btn = 'Frame.bg.ScrollingFrame.code.bg.btn' 
    ---@type ImageButton		
	c.insts.shadow_btn = 'Frame.bg.ScrollingFrame.Shadow.bg.btn'       
end
GetInsts()

function c.new()
    return c()
end
function c:ctor()
    local ui = hotpot:GetPath_Loop('ui.SettingGui',_G.Resource)
    c.super.ctor(self,ui)

    self.music = true
    self.sfx = true
    self.pets = false
    self.shadow = true

    self.insts.closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)
end

function c:Show()
    self.insts.Frame.Position = UDim2.fromScale(0.5,0.7)
    c.super.Show(self)
    tweenHelper:PlayTween(
        self.insts.Frame,
        info,
        {Position = UDim2.fromScale(0.5,0.5)}
    )
end

function c:Hide()
    tweenHelper:PlayTween(
        self.insts.Frame,
        info,
        {Position = UDim2.fromScale(0.5,0.7)},
        function()
            c.super.Hide(self)
        end
    )
    ui_manager.ui_list.hud_gui:Show()
end

function c:SetMusic(open)
    self.music = open
    if self.music then
        self.insts.music_btn.Image = 'rbxassetid://123512123433080'
        self.insts.music_btn.show.Position = UDim2.fromScale(0.8,0.5)
    else
        self.insts.music_btn.Image = 'rbxassetid://123904801382091'
        self.insts.music_btn.show.Position = UDim2.fromScale(0.2,0.5)
    end
end

function c:SetSound(open)
    self.sfx = open
    if self.sfx then
        self.insts.sfx_btn.Image = 'rbxassetid://123512123433080'
        self.insts.sfx_btn.show.Position = UDim2.fromScale(0.8,0.5)
    else
        self.insts.sfx_btn.Image = 'rbxassetid://123904801382091'
        self.insts.sfx_btn.show.Position = UDim2.fromScale(0.2,0.5)
    end
end

function c:BindMusicBtnClickHandle(obj,handle)
    self.insts.music_btn.MouseButton1Click:Connect(function()
        self.music = not self.music
        handle(obj,self.music)
        if self.music then
            tweenHelper:PlayTween(
                self.insts.music_btn.show,
                info,
                {Position = UDim2.fromScale(0.8,0.5)},
                function()
                    self.insts.music_btn.Image = 'rbxassetid://123512123433080'
                end
            )
        else
            tweenHelper:PlayTween(
                self.insts.music_btn.show,
                info,
                {Position = UDim2.fromScale(0.2,0.5)},
                function()
                    self.insts.music_btn.Image = 'rbxassetid://123904801382091'
                end
            )
        end
    end)
end

function c:BindSFXBtnClickHandle(obj,handle)
    self.insts.sfx_btn.MouseButton1Click:Connect(function()
        self.sfx = not self.sfx
        handle(obj,self.sfx)
        if self.sfx then
            tweenHelper:PlayTween(
                self.insts.sfx_btn.show,
                info,
                {Position = UDim2.fromScale(0.8,0.5)},
                function()
                    self.insts.sfx_btn.Image = 'rbxassetid://123512123433080'
                end
            )
        else
            tweenHelper:PlayTween(
                self.insts.sfx_btn.show,
                info,
                {Position = UDim2.fromScale(0.2,0.5)},
                function()
                    self.insts.sfx_btn.Image = 'rbxassetid://123904801382091'
                end
            )
        end
    end)
end

function c:BindPetsBtnClickHandle(obj,handle)
    self.insts.pets_btn.MouseButton1Click:Connect(function()
        self.pets = not self.pets
        handle(obj,self.pets)
        if self.pets then
            tweenHelper:PlayTween(
                self.insts.pets_btn.show,
                info,
                {Position = UDim2.fromScale(0.8,0.5)},
                function()
                    self.insts.pets_btn.Image = 'rbxassetid://123512123433080'
                end
            )
        else
            tweenHelper:PlayTween(
                self.insts.pets_btn.show,
                info,
                {Position = UDim2.fromScale(0.2,0.5)},
                function()
                    self.insts.pets_btn.Image = 'rbxassetid://123904801382091'
                end
            )
        end
    end)
end

function c:BindShadowBtnClickHandle(obj,handle)
    self.insts.shadow_btn.MouseButton1Click:Connect(function()
        self.shadow = not self.shadow
        handle(obj,self.shadow)
        if self.shadow then
            tweenHelper:PlayTween(
                self.insts.shadow_btn.show,
                info,
                {Position = UDim2.fromScale(0.8,0.5)},
                function()
                    self.insts.shadow_btn.Image = 'rbxassetid://123512123433080'
                end
            )
        else
            tweenHelper:PlayTween(
                self.insts.shadow_btn.show,
                info,
                {Position = UDim2.fromScale(0.2,0.5)},
                function()
                    self.insts.shadow_btn.Image = 'rbxassetid://123904801382091'
                end
            )
        end
    end)
end

function c:BindCodeBtnClickHandle(obj,handle)
    self.insts.code_btn.MouseButton1Click:Connect(function()
        handle(obj,self.insts.code_TextBox.Text)
    end)
end

return c