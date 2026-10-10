local hotpot = _G.ClientHotpot

---@type Players
local Players = game:GetService("Players")
---@type ScreenGui
local ScreenGui = Instance.new('ScreenGui')
---@type Player
local Player = Players.LocalPlayer
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
local info = TweenInfo.new(0.2)
----------------------------------1
---@type Frame
local frame1 = Instance.new('Frame', ScreenGui)
frame1.AnchorPoint = Vector2.one * 0.5
frame1.Size = UDim2.fromScale(1, 1)
frame1.Position = UDim2.fromScale(0.5, 0.5)
frame1.Transparency = 1
---@type TextLabel
local pfb1 = Instance.new('TextLabel')
pfb1.Text = ''
pfb1.AnchorPoint = Vector2.one * 0.5
pfb1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pfb1.Size = UDim2.fromScale(0.063, 0.111)
local UICorner = Instance.new('UICorner', pfb1)
UICorner.CornerRadius = UDim.new(1, 0)

----------------------------------2
---@type TextLabel
local pfb2 = Instance.new('TextLabel')
pfb2.Text = ''
pfb2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pfb2.Size = UDim2.fromScale(0.1,1) 
pfb2.BorderSizePixel = 0

---@class Client_TranstionsAnimation
local c = hotpot.class.new(script)

local f = coroutine.wrap(function()
    local player_gui = hotpot:GetPath_Loop('PlayerGui', Player)
    ScreenGui.Parent = player_gui
    ScreenGui.Name = "TransitionsAnimation"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.ResetOnSpawn = false
end)
f()
local start_pos_x = 60 / 1920
local start_pos_y = 60 / 1080
local dir_x = 120 / 1920
local dir_y = 120 / 1080
local s_size = UDim2.fromScale(0.063, 0.111)
local t_size = UDim2.fromScale(0.0882, 0.1554)
local first = false
local function GetPos(count)
    local x
    if count % 9 == 0 then
        x = math.floor((count - 1) / 9)
    else
        x = math.floor(count / 9)
    end
    local y = count % 9
    if y == 0 then
        y = 9
    end
    y = y - 1
    return UDim2.fromScale(start_pos_x + dir_x * x, start_pos_y + dir_y * y)
end

local list = {}
local playing = false
local function Play1(wait_time, fun)
    if playing then
        return
    end
    playing = true
    local count = 1
    if not first then
        for i = 1, 16 do
            for j = 1, 9 do
                local ui = pfb1:Clone()
                ui.Parent = frame1
                ui.Position = GetPos(count)
                ui.Visible = false
                ui.Size = t_size
                ui.Name = count
                list[count] = ui
                count = count + 1
            end
        end
    end
    local ud = UDim2.fromScale(0, 0)

    local f_list1 = {}
    for i = 1, 16 do
        local f = coroutine.wrap(function()
            for j = (i - 1) * 9 + 1, i * 9 do
                list[j].Size = ud
                list[j].Visible = true
                local tw = TweenHelper:PlayTween(list[j], info, {Size = t_size})
                wait()
            end
        end)
        f_list1[i] = f
    end

    local f_list2 = {}
    for i = 1, 16 do
        local f = coroutine.wrap(function()
            for j = (i - 1) * 9 + 1, i * 9 do
                TweenHelper:PlayTween(list[j], info, {Size = UDim2.fromScale(0, 0)}, function()
                    list[j].Visible = false
                    list[j].Size = s_size
                end)
                wait()
            end
        end)
        f_list2[i] = f
    end

    for k, v in ipairs(f_list1) do
        v()
        wait()
    end
    if fun then
        fun()
    end
    wait(wait_time)
    for k, v in ipairs(f_list2) do
        v()
        wait()
    end
    wait(0.35)
    playing = false
    first = true
end

local ui_list = {}
local function Play2(wait_time,fun)
    if playing then
        return
    end
    playing = true

    if not next(ui_list)then
        for i = 1,10 do
            local ui = pfb2:Clone()
            ui.Position = UDim2.fromScale((i - 1) * 0.1,-1)
            ui_list[i] = ui
            ui.Parent = frame1
        end
    else
        for i = 1,10 do
            local ui = ui_list[i]
            ui.Position = UDim2.fromScale(i * 0.1,-1)
            ui.Visible = true
        end
    end

    for _,ui in ipairs(ui_list)do
        TweenHelper:PlayTween(
            ui,
            info,
            {Position = UDim2.fromScale(ui.Position.X.Scale,0)}
        )
        wait(0.1)
    end
    if fun then
        fun()
    end
    wait(wait_time)
    for _,ui in ipairs(ui_list)do
        TweenHelper:PlayTween(
            ui,
            info,
            {Position = UDim2.fromScale(ui.Position.X.Scale,1)},
            function()
                ui.Visible = false
            end
        )
        wait(0.1)
    end

end

function c:PlayTransitionsAnimation(wait_time, fun)
    wait_time = wait_time or 1
    Play1(wait_time, fun)
end

return c
