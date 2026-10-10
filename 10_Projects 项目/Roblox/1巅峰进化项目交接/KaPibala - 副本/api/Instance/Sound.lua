---@class Sound:Instance @Sound（声音）是一个发出声音的对象。有关如何上传声音文件的详情，请参见添加声音。
---@field IsLoaded boolean @当 Sound 已从 Roblox 服务器加载并准备播放时，此属性将为 true。
---@field IsPaused boolean @此只读属性将在 Sound 未播放时返回 true。
---@field IsPlaying boolean @播放声音时，此只读属性将返回true
---@field Looped boolean @设置 Sound 在播放完毕时是否重复播放。
---@field PlayOnRemove boolean @当为 true 时，通过将 Sound 或其父项之一设为 nil 的子项，使 Sound 在从游戏中移除时播放。
---@field PlaybackLoudness number @一个介于 0 和 1000 之间的数字，表示 Sound 目前的播放音量。
---@field PlaybackSpeed number @决定一个 Sound 的播放速度，值越高播放的音调和速度就越快。
---@field Playing boolean @指示 Sound 是否正在播放。
---@field RollOffMaxDistance number @客户端的侦听器与 Sound\s 的来源之间仍能听到声音的最大距离。只适用于设为 Part 或 Attachment 的子项（3D 声音）
---@field RollOffMode RollOffMode @当侦听器和声音的父项之间的距离变化时，控制 3D Sound（为 BasePart 或 Attachment 的子项）的音量如何变化。
---@field SoundGroup SoundGroup @连接至此 Sound 的 SoundGroup。应用到此声音组的 Volume（音量）和 SoundEffects 将传递至其声音。一个声音无法同时属于多个组。
---@field SoundId string @此属性是一个 Sound 对象关联的声音文件的内容 ID。在声音上传至 Roblox 后，其内容 ID 可以在声音的 URL 中找到。
---@field TimeLength string @以秒为单位的 Sound 长度。如果 Sound 未加载，此值将为 0。
---@field TimePosition string @以秒为单位显示 Sound 的播放进度。播放前和播放中都可变更来移动 Sound 的播放进度。
---@field Volume number @Sound 的音量。可设为 0 至 10 之间的值。默认为 0.5。
---@field DidLoop RBXScriptSignal @DidLoop ( string soundId , int numOfTimesLooped ) 当 Sound 循环时触发。返回 soundId 和 numOfTimesLooped，分别表示声音的 contentID 和已循环的次数。
---@field Ended RBXScriptSignal @Ended ( string soundId ) 当 Sound 已播放完毕并停止时触发。
---@field Loaded RBXScriptSignal @Loaded ( string soundId ) 当 Sound 加载完毕时触发。
---@field Paused RBXScriptSignal @Paused ( string soundId ) 用 Sound:Pause 暂停播放 Sound 时触发。
---@field Played RBXScriptSignal @Played ( string soundId ) 用 Sound:Play 函数播放 Sound 时触发。
---@field Resumed RBXScriptSignal @Resumed ( string soundId ) 用 Sound:Resume 继续播放 Sound 时触发。
---@field Stopped RBXScriptSignal @Stopped ( string soundId ) 当 Sound 被 Sound:Stop 函数停止时触发。
local module = {}
---@type fun() @设置Sound.Playing为false。如果正在播放声音，这将暂停声音的播放。由于未重置Sound.TimePosition，因此当恢复声音时，它将从其先前位置继续
function module:Pause()
end
---@type fun() @播放声音。将Sound.TimePosition设置为脚本设置的最后一个值（如果尚未设置，则设置为0），然后将Sound.Playing设置为true。
function module:Play()
end
---@type fun() @继续播放 Sound。将 Sound.Playing 设为 true。不会变更 Sound.TimePosition，因此无法继续播放被 Sound:Pause 暂停的声音。
function module:Resume()
end
---@type fun() @停止 Sound （声音）。将 Sound.Playing 设置为 false，然后将 Sound.TimePosition 设置为 0。
function module:Stop()
end