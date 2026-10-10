local _G = _G
local script = script
local hotpot = _G.CommonHotpot
local playing = {}
local playing_group = {}
---@class AudioManager
local c = hotpot.class.new(script)
---@param audio_inst Sound
---@param inst Instance
---@return Sound
function c:PlayToInst(audio_inst,inst,speed,repeat_times)
    assert(audio_inst,"audio_inst is nil")
    speed = speed or 1
    ---@type Sound
    local audio = audio_inst:Clone()
    audio.Stopped:Connect(function()
        audio:Destroy()
    end)
    audio.Ended:Connect(function()
        audio:Destroy()
    end)
    audio.PlaybackSpeed = speed
    if repeat_times then
        audio.Looped = true
        local cnnt = audio.DidLoop:Connect(function(__,times)
            if times == repeat_times then
                audio:Stop()
            end
        end)
    end
    audio.Parent = inst
    audio:Play()
    return audio
end
return c