local STEP_SHOW_TIME = 0.5
local STEP_COMPLETE_TIME = 0.25
local SHOW_PER = -1

local UDim2 = UDim2
local wait = wait
local math = math
local Enum = Enum
local os = os
local ipairs = ipairs
local _G = _G
local script = script
local game = game
local assert = assert
local tostring = tostring
---@type TweenService
local TweenService = game:GetService("TweenService")
---@type Players
local Players = game:GetService("Players")
---@type Player
local local_player = Players.LocalPlayer
local hotpot = _G.ClientHotpot
local enum = hotpot.enum
---@class LoadingGui:HotpotScreenBase
---@field __update HotpotConnection
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())
function c.new()
    return c()
end
c.insts = {}
---@type Frame
c.insts.load_bar = "main.loadbar"
c.insts.load_points = {}
---@type Frame
c.insts.load_points[1] = "main.loadbar.1"
---@type Frame
c.insts.load_points[2] = "main.loadbar.2"
---@type Frame
c.insts.load_points[3] = "main.loadbar.3"
---@type Frame
c.insts.load_points[4] = "main.loadbar.4"
---@type Frame
c.insts.load_points[5] = "main.loadbar.5"
c.insts.loading_imgs = {}
---@type ImageLabel
c.insts.loading_imgs[1] = "main.loadbar.1.loading"
---@type ImageLabel
c.insts.loading_imgs[2] = "main.loadbar.2.loading"
---@type ImageLabel
c.insts.loading_imgs[3] = "main.loadbar.3.loading"
---@type ImageLabel
c.insts.loading_imgs[4] = "main.loadbar.4.loading"
---@type ImageLabel
c.insts.loading_imgs[5] = "main.loadbar.5.loading"
c.insts.loaded_imgs = {}
---@type ImageLabel
c.insts.loaded_imgs[1] = "main.loadbar.1.loaded"
---@type ImageLabel
c.insts.loaded_imgs[2] = "main.loadbar.2.loaded"
---@type ImageLabel
c.insts.loaded_imgs[3] = "main.loadbar.3.loaded"
---@type ImageLabel
c.insts.loaded_imgs[4] = "main.loadbar.4.loaded"
---@type ImageLabel
c.insts.loaded_imgs[5] = "main.loadbar.5.loaded"
c.insts.logo = {}
---@type ImageLabel
c.insts.logo.fire = "main.logo.fire"
c.insts.logo.hotpot = {}
---@type ImageLabel
c.insts.logo.hotpot.cn = "main.logo.hotpot_cn"
---@type ImageLabel
c.insts.logo.hotpot.en = "main.logo.hotpot_en"
---@type ImageLabel
c.insts.logo.pot = "main.logo.pot"
---@type Frame
c.insts.logo.over = "main.logo.over"
---@type ImageLabel
c.insts.logo.bg = "main.logo.bg"
---@type Frame
c.insts.main = "main"

function c:ctor()
    local ui = hotpot:GetPath_Loop("ReplicatedStorage.Resource.UI.LoadingGui")
    c.super.ctor(self,ui)
    local player_gui = hotpot:GetPath_Loop("PlayerGui",local_player)
    self:SetParentInstance(player_gui)
    self.insts.logo.hotpot.cn.ImageTransparency = 1
    self.insts.logo.hotpot.en.ImageTransparency = 1
    self.fire_org_size = self.insts.logo.fire.Size
    self.step_funcs = {}
    self.now_step = 1
end
function c:dtor()
    if self.main_inst and self.main_inst.Parent then
        self.main_inst:Destroy()
    end
    c.super.dtor(self)
end
function c:SetStepFunc(num,func)
    assert(self.insts.load_points[num],"step is only "..tostring(#self.insts.load_points)..",can't be "..tostring(num))
    self.step_funcs[num] = func
end
---@param self LoadingGui
local function LoadPointShow(self,no,marks)
    ---@type Frame
    local point = self.insts.load_points[no]
    local dir_fix = 1
    local time_count = 0
    local clock_mark = os.clock()
    local org_pos_x = point.Position.X.Scale
    while not marks[no] or time_count ~= 0 or dir_fix < 0 do
        local now_clock = os.clock()
        local step = now_clock - clock_mark
        clock_mark = now_clock
        time_count = time_count + step
        local a = math.min(time_count / STEP_SHOW_TIME,1)
        a = TweenService:GetValue(a,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
        if dir_fix > 0 then
            point.Position = UDim2.fromScale(org_pos_x,SHOW_PER * (a))
        else
            point.Position = UDim2.fromScale(org_pos_x,SHOW_PER * (1 - a))
        end
        if a == 1 then
            time_count = 0
            dir_fix = 0 - dir_fix
        end
        self:Wait()
    end
    --如果方法已经结束，那么就进行表达
    local loaded = self.insts.loaded_imgs[no]
    loaded.Size = UDim2.fromScale(0,0)
    -- loaded.BackgroundColor3 = loaded.BorderColor3
    -- copy.Parent = self.insts.load_bar
    local org_size = point.Size
    while time_count < STEP_COMPLETE_TIME do
        local now_clock = os.clock()
        local step = now_clock - clock_mark
        clock_mark = now_clock
        time_count = math.min(time_count + step,STEP_COMPLETE_TIME)
        
        local a = time_count/STEP_COMPLETE_TIME
        a = TweenService:GetValue(a,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out)
        loaded.Size = UDim2.fromScale((org_size.X.Scale + 0.5) * a,(org_size.Y.Scale+0.5) * a)
        self:Wait()
    end
    marks[no] = nil
end
local fire_size_fix = 0.05
---@param self LoadingGui
local function LogoLoadingShow(self,step,run_time)
    local fire = self.insts.logo.fire
    local org_size = self.fire_org_size
    local count = math.floor(run_time / 0.5)
    local a = (run_time - count * 0.5)/0.5
    a = TweenService:GetValue(a,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut)
    if count%2 == 1 then
        fire.Size = UDim2.fromScale(org_size.X.Scale,org_size.Y.Scale + fire_size_fix * a)
    else
        fire.Size = UDim2.fromScale(org_size.X.Scale,org_size.Y.Scale + fire_size_fix *(1 - a))
    end
    local pot_count = math.floor(run_time/0.5)
    local state = count%4
    local pot = self.insts.logo.pot
    local pot_a = (run_time - pot_count * 0.5)/0.5
    if state == 0 then
        pot.Rotation = 3 * pot_a
    elseif state == 1 then
        pot.Rotation = 3 * (1 - pot_a)
    elseif state == 2 then
        pot.Rotation = -3 * pot_a
    elseif state == 3 then
        pot.Rotation = -3 * (1 - pot_a)
    else
        pot.Rotation = 0
    end
end
---@param self LoadingGui
---@param logo ImageLabel
local function ShowLogo(self,step,run_time,logo)
    local a = 1 - math.min(run_time / 0.5,1)
    logo.ImageTransparency = a
    if a >= 1 then
        return true
    end
end
function c:StartLoading()
    local over_marks = {}
    local show_logo
    ---@type ImageLabel
    local logo
    self:AddRenderUpdate("render",LogoLoadingShow)
    for no,func in ipairs(self.step_funcs) do
        self:AddRenderProcess('render',LoadPointShow,no,over_marks)
        if no == 3 and not show_logo then
            show_logo = true
            logo = self.insts.logo.hotpot.en
            if local_player.LocaleId == "zh-cn" then
                logo = self.insts.logo.hotpot.cn
            end
            self:AddRenderUpdate("render",ShowLogo,nil,logo)
        end
        func()
        over_marks[no] = true
        while over_marks[no] do
            self:Wait()
        end
    end
    logo.ImageTransparency = 0
    self:AddCoTo("render")
    local over_frame = self.insts.logo.over
    local mark = os.clock()
    local run_time = 0
    while true do
        local now_clock = os.clock()
        local step = now_clock - mark
        mark = now_clock
        run_time = run_time + step
        local a = math.min(run_time/0.5,1)
        a = TweenService:GetValue(a,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
        over_frame.Size = UDim2.fromScale(0.15*a,0.15*a)
        over_frame.Position = UDim2.fromScale(0.5,0.7 - 0.2 * a)
        over_frame.Transparency = 1 - a
        self:Wait()
        if a >= 1 then
            break
        end
    end
    mark = os.clock()
    run_time = 0
    while true do
        local now_clock = os.clock()
        local step = now_clock - mark
        mark = now_clock
        run_time = run_time + step
        local a = math.min(run_time/0.25,1)
        a = TweenService:GetValue(a,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
        over_frame.Position = UDim2.fromScale(0.5,0.5 + 0.2 * a)
        self:Wait()
        if a >= 1 then
            break
        end
    end
    mark = os.clock()
    run_time = 0
    local org_color = over_frame.BackgroundColor3
    while true do
        local now_clock = os.clock()
        local step = now_clock - mark
        mark = now_clock
        run_time = run_time + step
        local a = math.min(run_time/0.25,1)
        a = TweenService:GetValue(a,Enum.EasingStyle.Sine,Enum.EasingDirection.In)
        over_frame.Size = UDim2.fromScale(0.15 + 10 * a,0.15 + 10 * a)
        over_frame.BackgroundColor3 = Color3.fromRGB(org_color.r + (255-org_color.r) * a,org_color.g + (255 - org_color.g) * a,org_color.b + (255 - org_color.b) * a)
        self:Wait()
        if a >= 1 then
            break
        end
    end
    --隐藏其他所有单位
    self.insts.load_bar.Visible = false
    self.insts.logo.pot.Visible = false
    self.insts.logo.fire.Visible = false
    self.insts.logo.hotpot.cn.Visible = false
    self.insts.logo.hotpot.en.Visible = false
    self.insts.logo.bg.Visible = false
    self.insts.main.BackgroundTransparency = 1
    self:Wait(0.25)
    mark = os.clock()
    run_time = 0
    local org_color = over_frame.BackgroundColor3
    while true do
        local now_clock = os.clock()
        local step = now_clock - mark
        mark = now_clock
        run_time = run_time + step
        local a = math.min(run_time/0.5,1)
        a = TweenService:GetValue(a,Enum.EasingStyle.Sine,Enum.EasingDirection.In)
        over_frame.BackgroundTransparency = a
        -- over_frame.Size = UDim2.fromScale(0.15 + 10 * a,0.15 + 10 * a)
        -- over_frame.BackgroundColor3 = Color3.fromRGB(org_color.r + (255-org_color.r) * a,org_color.g + (255 - org_color.g) * a,org_color.b + (255 - org_color.b) * a)
        self:Wait()
        if a >= 1 then
            break
        end
    end
    --淡出
    self:dtor()
end

return c