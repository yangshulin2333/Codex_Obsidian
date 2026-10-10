local TIME_LIMIT = 3
local _G = _G
local script = script
---@type SoundService
local SoundService = game:GetService("SoundService")
local hotpot = _G.ClientHotpot
local audio_config = hotpot.config.audio
local group_marks = {}
for id,cfg in pairs(audio_config) do
    if cfg.group then
        group_marks[cfg.group] = true
    end
end
---@class Client_AudioManager:AudioManager
local c = hotpot.class.new(script,hotpot.files.AudioManager())
---@type table<string,SoundGroup>
local groups = {}
---@type table<string,Sound>
local sounds = {}
local sound_folder
local group_folder
local globle_folder = Instance.new("Folder",workspace)
globle_folder.Name = "ClientGlobleSounds"
function c:PreLoad(handle)
    local max_num = hotpot:CountTable(audio_config) + 2
    local count = 0
    local main_co = coroutine.running()
    local todo = {}
    if handle then
        handle(count,max_num)
    end
    if not sound_folder then
        sound_folder = hotpot:GetPath_Loop("Sounds",SoundService)
    end
    count = count + 1
    if handle then
        handle(count,max_num)
    end
    if not group_folder then
        group_folder = hotpot:GetPath_Loop("Groups",SoundService)
    end
    count = count + 1
    if handle then
        handle(count,max_num)
    end
    for id,cfg in pairs(audio_config) do
        local rid = cfg.rid
        local volume = cfg.volume
        local group_name = cfg.group
        if group_name and not groups[group_name] then
            groups[group_name] = hotpot:GetPath_Loop(group_name,group_folder)
        end
        if not sounds[id] then
            sounds[id] = hotpot:GetPath_Loop(id,sound_folder)
        end
        if volume then
            sounds[id].Volume = volume
        end
        count = count + 1
        if handle then
            handle(count,max_num)
        end
        -- local sound = sounds[id]
        -- if not sound.IsLoaded then
        --     print("not loaded")
        --     sound.Loaded:Connect(function()
        --         print("hahah")
        --         count = count + 1
        --         if handle then
        --             handle(count,max_num)
        --         end
        --         if count >= max_num then
        --             wait()
        --             coroutine.resume(main_co)
        --         end
        --     end)
        -- else
        --     print("loaded")
        --     count = count + 1
        --     if handle then
        --         handle(count,max_num)
        --     end
        -- end
    end
    -- if count < max_num then
    --     coroutine.yield()
    -- end
end
---@return Sound
function c:GetSound(id)
    assert(id,"param id is nil")
    assert(audio_config[id],"no such audio id = "..id)
    sounds[id] = sounds[id] or hotpot:GetPath_Loop("Sounds."..id,SoundService)
    if sounds[id].SoundId == "" then
        return
    end
    return sounds[id]
end
---@return SoundGroup
function c:GetGroup(name)
    assert(name,"param group name is nil")
    assert(group_marks[name],"param no such group name = "..name)
    groups[name] = groups[name] or hotpot:GetPath_Loop("Groups."..name,SoundService)
    return groups[name]
end
function c:SetGroupVolume(name,volume)
    local group = self:GetGroup(name)
    group.Volume = volume
end
function c:GetGroupVolume(name)
    local group = self:GetGroup(name)
    return group.Volume
end
function c:PlayToInst(id,inst,speed,repeat_times)
    local r,e = xpcall(function()
        local audio = self:GetSound(id)
        if audio then
            return c.super.PlayToInst(self,audio,inst,speed,repeat_times)
        end
    end,debug.traceback)
    if r then
        return e
    else
        if e then
            e:Destroy()
        end
    end
end
function c:PlayGloble(id,speed,repeat_times)
    local r,e = xpcall(function()
        return self:PlayToInst(id,globle_folder,speed,repeat_times)
    end,debug.traceback)
    if r then
        return e
   --else
        -- if e then
        --     pcall(function()
        --         e:Destroy()
        --     end)
        -- end
    end
end
return c