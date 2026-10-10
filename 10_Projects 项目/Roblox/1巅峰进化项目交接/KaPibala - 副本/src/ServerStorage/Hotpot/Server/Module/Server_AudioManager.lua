local _G = _G
local script = script
---@type SoundService
local SoundService = game:GetService("SoundService")
local hotpot = _G.ServerHotpot
local audio_config = hotpot.config.audio
---@class Server_AudioManager:AudioManager
local c = hotpot.class.new(script,hotpot.files.AudioManager())
---@type table<string,SoundGroup>
local groups = {}
---@type table<string,Sound>
local sounds = {}
---@type Folder
local sound_folder = Instance.new("Folder",SoundService)
sound_folder.Name = "Sounds"
---@type Folder
local group_folder = Instance.new("Folder",SoundService)
group_folder.Name = "Groups"
---@type Folder
local globle_folder = Instance.new("Folder",workspace)
globle_folder.Name = "ServerGlobleSounds"

function c:CreateGroup(group_name)
    if not group_name then
        return
    end
    if not groups[group_name] then
       local group_inst = Instance.new("SoundGroup",group_folder)
       group_inst.Name = group_name
       groups[group_name] = group_inst
    end
    return groups[group_name]
end
function c:CreateSound(id,rid,volume,group)
    local r,e = xpcall(function()
        ---@type Sound
        local sound_inst = Instance.new("Sound",sound_folder)
        sound_inst.Name = id
        sound_inst.SoundId = rid
        sound_inst.Volume = volume or 1
        sound_inst.SoundGroup = group
        sounds[id] = sound_inst
        sound_inst.Loaded:Connect(function(...)
        end)
    end,debug.traceback)
    if not r then
        warn(e)
    end
end
---@return Sound
function c:PlayToInst(id,inst,speed,repeat_times)
    local audio_inst = sounds[id]
    if audio_inst.SoundId == "" then
        return
    end
    return c.super.PlayToInst(self,audio_inst,inst,speed,repeat_times)
end
---@return Sound
function c:PlayGloble(id,speed,repeat_times)
    return self:PlayToInst(id,globle_folder,speed,repeat_times)
end
function c:SetGroupVolume(group_name,volume)
    local group = groups[group_name]
    group.Volume = volume
end
function c:GetGroupVolume(group_name)
    local group = groups[group_name]
    return group.Volume
end
---加载的时候就创建所有资源
for id,cfg in pairs(audio_config) do
    local group_name = cfg.group
    local rid = cfg.rid
    local volume = cfg.volume
    local group_inst = c:CreateGroup(group_name)
    c:CreateSound(id,rid,volume,group_inst)
end
return c