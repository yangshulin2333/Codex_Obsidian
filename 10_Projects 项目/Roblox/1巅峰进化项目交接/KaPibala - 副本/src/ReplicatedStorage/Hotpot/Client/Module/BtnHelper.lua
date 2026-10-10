local hotpot = _G.ClientHotpot
---@type TweenHelper
local tweenHelper = hotpot.load.TweenHelper()
local btn_tween_info = TweenInfo.new(0.1, Enum.EasingStyle.Quad)
---@class BtnHelper
local module = {}
local EnterRatio, downRatio, upRatio = 1.05, 0.85, 1.05
---@type Client_AudioManager
local audio_player = hotpot.load.Client_AudioManager()
local btn_sound = "clickBtn"
local ShrinkDownRatio = 0.85
local orgSize = {}
---@param button ImageButton
function module:InitButton(button, tempEnterRatio, tempDownRatio, tempUpRatio, downHandle)
    if button:GetAttribute("ignore_btn_init") then
        return
    end
    -- if button.AnchorPoint ~= centerPoint then return end
    orgSize[button] = button.Size
    local orgX = button.Size.X.Scale
    local orgY = button.Size.Y.Scale
    local offsetX = button.Size.X.Offset
    local offsetY = button.Size.Y.Offset
    -- 打开鼠标不会卡死
    -- button.Modal = true
    tempEnterRatio = tempEnterRatio and tempEnterRatio or EnterRatio
    tempDownRatio = tempDownRatio and tempDownRatio or downRatio
    tempUpRatio = tempUpRatio and tempUpRatio or upRatio
    button.MouseEnter:Connect(function()
        audio_player:PlayGloble('btnIn',2)
        tweenHelper:PlayTween(
            button, 
            btn_tween_info,
            {
                Size = UDim2.new(
                    orgX * tempEnterRatio,
                    offsetX * tempEnterRatio, 
                    orgY * tempEnterRatio,
                    offsetY * tempEnterRatio
                )
            }
        )
    end)
    button.MouseLeave:Connect(function()
        tweenHelper:PlayTween(
            button,
            btn_tween_info,
            {
                Size = UDim2.new(
                    orgX,
                    offsetX, 
                    orgY,
                    offsetY
                )
            }
        )
    end)
    button.MouseButton1Down:Connect(function()
        if downHandle then
            downHandle()
        end
        audio_player:PlayGloble(btn_sound,1.2)
        tweenHelper:PlayTween(
            button,
            btn_tween_info,
            {
                Size = UDim2.new(
                    orgX * tempDownRatio,
                    offsetX * tempDownRatio, 
                    orgY * tempDownRatio,
                    offsetY * tempDownRatio
                )
            }
        )
    end)
    button.MouseButton1Up:Connect(function()
        tweenHelper:PlayTween(
            button,
            btn_tween_info,
            {
                Size = UDim2.new(orgX,offsetX,orgY,offsetY)
            }
        )
    end)
end

function module:ResetBtn(btn)
    local orgX = orgSize[btn].X.Scale
    local orgY = orgSize[btn].Y.Scale
    local offsetX = orgSize[btn].X.Offset
    local offsetY = orgSize[btn].Y.Offset
    tweenHelper:PlayTween(
        btn,
        btn_tween_info,
        {
            Size = UDim2.new(orgX,offsetX,orgY,offsetY)
        }
    )
end
function module:PressBtn(button, state)
    local btnOrgSize = orgSize[button]
    if not btnOrgSize then
        warn("please InitButton() before use this func")
        return
    end
    if state == Enum.UserInputState.Begin then -- 开始点击
        tweenHelper:PlayTween(button, btn_tween_info, {Size = UDim2.fromScale(btnOrgSize.X.Scale * ShrinkDownRatio,
            btnOrgSize.Y.Scale * ShrinkDownRatio)})
    elseif state == Enum.UserInputState.End then -- 退出
        tweenHelper:PlayTween(button, btn_tween_info, {Size = UDim2.fromScale(btnOrgSize.X.Scale, btnOrgSize.Y.Scale)})
    end
end
return module
