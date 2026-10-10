local hotpot = _G.ClientHotpot
---@type LocalizationHelper
local LocalizationHelper = hotpot.load.LocalizationHelper()

local nil_str = ""
local yellow_color = Color3.fromRGB(235,235,10)
local white_color = Color3.fromRGB(255,255,255)
local new_icon = "rbxassetid://9832769952"
local repiar_icon = "rbxassetid://9832814427"

local cfg = hotpot.config.UpdateLog

if not cfg then
    warn("cfg is nil")
    return 
end

---@class UpdateLogGui:HotpotScreenBase
local c = hotpot.class.new(script, hotpot.files.HotpotScreenBase())
function c.new()
    return c()
end

c.insts = {}
---@type ScrollingFrame
c.insts.ScrollingFrame = "Frame.BG.ScrollingFrame"
---@type TextLabel
c.insts.Title = "Frame.BG.Title"
---@type UIGradient
c.insts.Title_UIGradient = "Frame.BG.Title.UIGradient"
---@type TextLabel
c.insts.UDP_info = "UDP_info"
---@type TextLabel
c.insts.UDP_title = "UDP_title"

---@type ImageButton
c.insts.btn = "Frame.BG.btn"

function c:ctor()
    local ui = hotpot:GetPath_Loop("ReplicatedStorage.Resource.XY.UI.UDPGui")
    ui = hotpot:CloneInst_Loop(ui)
    c.super.ctor(self, ui, nil)
    self.__rotate = 0
    self.insts.Title.Text = LocalizationHelper:Translate(cfg[1].title)
end

function c:Load()
    local update_list = {}
    local bug_fix_list = {}
    for k,v in ipairs(cfg)do
        if v.u_type == 1 then
            table.insert(update_list,v.content)
        else
            table.insert(bug_fix_list,v.content)
        end
    end

    local count = 0

    if #update_list > 0 then
        local upd_title = hotpot:CloneInst_Loop(self.insts.UDP_title)
        upd_title.LayoutOrder = count
        count = count + 1
        local title_info = hotpot:GetPath_Loop("info",upd_title)
        title_info.Text = LocalizationHelper:Translate(cfg[2].title)..":"..cfg[1].version
        local icon = hotpot:GetPath_Loop("icon",upd_title)
        icon.Image = new_icon
        upd_title.Visible = true
        upd_title.Parent = self.insts.ScrollingFrame

        local mark = 0
        local ui
        for k,v in ipairs(update_list)do
            if mark == 0 then
                ui = hotpot:CloneInst_Loop(self.insts.UDP_info) 
                local info1 = hotpot:GetPath_Loop("info1",ui)
                info1.Text = "."..LocalizationHelper:Translate(v)
                --info1.TextColor3 = green_color
                mark = 1
                ui.LayoutOrder = count
                count = count + 1
                ui.Visible = true
                ui.Parent = self.insts.ScrollingFrame
            elseif mark == 1 then
                local info2 = hotpot:GetPath_Loop("info2",ui)
                info2.Text = "."..LocalizationHelper:Translate(v)
                --info2.TextColor3 = green_color
                mark = 0
            end
        end
    end
    if #bug_fix_list > 0 then
        local upd_title = hotpot:CloneInst_Loop(self.insts.UDP_title)
        upd_title.LayoutOrder = count
        count = count + 1
        local title_info = hotpot:GetPath_Loop("info",upd_title)
        title_info.Text = LocalizationHelper:Translate(cfg[3].title)
        title_info.TextColor3 = white_color
        local icon = hotpot:GetPath_Loop("icon",upd_title)
        icon.Image = repiar_icon
        upd_title.Visible = true
        upd_title.Parent = self.insts.ScrollingFrame

        local mark = 0
        local ui
        for k,v in ipairs(bug_fix_list)do
            if mark == 0 then
                ui = hotpot:CloneInst_Loop(self.insts.UDP_info) 
                local info1 = hotpot:GetPath_Loop("info1",ui)
                info1.Text = "."..LocalizationHelper:Translate(v)
                info1.TextColor3 = yellow_color
                mark = 1
                ui.LayoutOrder = count
                count = count + 1
                ui.Visible = true
                ui.Parent = self.insts.ScrollingFrame
            elseif mark == 1 then
                local info2 = hotpot:GetPath_Loop("info2",ui)
                info2.Text = "."..LocalizationHelper:Translate(v)
                info2.TextColor3 = yellow_color
                mark = 0
            end
        end
    end
end

function c:BindBtnClickHandle(obj,handle)
    self.insts.btn.MouseButton1Click:Connect(function()
        self:Hide()
        if obj and handle then
            handle(obj)
        end
    end)
end

function c:RotateTitle()
    self.__rotate = self.__rotate + 0.015
    if self.__rotate >= 1 then
        self.__rotate = -1
    end
    self.insts.Title_UIGradient.Offset = Vector2.new(self.__rotate,0)
end

function c:StartRotateTitle()
    if self.__rotate_title_co then
        return 
    end
    self.__rotate_title_co = self:AddUpdate(self.RotateTitle)
end

function c:StopRotateTitle()
    if self.__rotate_title_co then
        self.__rotate_title_co:Disconnect()
        self.__rotate_title_co = nil 
    end
end

function c:Show()
    self:StartRotateTitle()
    c.super.Show(self)
end
function c:Hide()
    c.super.Hide(self)
    self:StopRotateTitle()
end

return c
