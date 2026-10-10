--！！必读：由于版本变化，现在TextChannel的ChatVersion有两种，GM需要根据这个进行自适应变化
--当玩家使用代码时自己可以看见输入但是别人不应该看见相关的文本
--旧版为：LegacyChatService
--新版为：TextChatService  --监听方式：通过channel
--开发人员特供命令符操作
local hotpot = _G.ServerHotpot

local player_lv_cfg = hotpot.config.playerLv
local white_id_list = {
    [1646291580] = "老王",
    [-1] = "开发者1",
    [-2] = "开发者2",
    [-3] = "开发者3",
    [4358197495] = 'test'
    ,[10804390126] = "test2"
}
local TRIGGER_STR = "."
local LINE_SPLIT_STR = "\'[^\\n|]+\'"
local CODE_SPLIT_STR = "\'[^%s]+\'"
local TextChatService = game:GetService("TextChatService")
---@type Chat
local Chat = game:GetService( 'Chat' )
---@type Players
local Players = game:GetService('Players')
local inst_manager = hotpot.load.InstanceManager()
local gm_funcs = {}
---@class GMCommand
local c = hotpot.class.new(script)
---@param str string
local function Split(str,line_type)
    local filter_str
    if line_type then
        filter_str = LINE_SPLIT_STR
    else
        filter_str = CODE_SPLIT_STR
    end
    local codes = {}
    if line_type then
        for code in string.gmatch(str,'[^\n|]+') do
            codes[#codes + 1] = code
        end
    else
        for code in string.gmatch(str, '[^%s]+') do
            codes[#codes + 1] = code
        end
    end
    return codes
end
---@type fun() @监听到消息
---@param message TextChatMessage
local function ReceiveMessage(message)
    -- print(message)
    local user_id = message.SpeakerUserId
    local adm_name = white_id_list[user_id]
    --进行权限判断
    if not adm_name then
        warn("You don't have the permission.")
        return
    end
    local message_str = message.Message
    local first_str = string.sub(message_str,1,1)
    if first_str ~= TRIGGER_STR then
        return
    end
    if false then --是开发者并且在执行命令则不转发给其他玩家
        message.ShouldDeliver = false
    end
    --将触发字符删除
    message_str = string.sub(message_str,2)
    --拿到玩家对象
    local player_inst = Players:GetPlayerByUserId(user_id)
    if not player_inst then
        warn("GMCommand can't find player instance id = "..tostring(user_id))
        return
    end
    local player_obj = inst_manager:FindObject(player_inst)
    if not player_obj then
        warn("can't find player object id = "..tostring(user_id))
        return
    end
    --进行分行处理
    local codes = Split(message_str)
    local command_name = table.remove(codes,1)
    for i,v in ipairs(codes) do
        codes[i] = tonumber(v) or v
    end
    local func = gm_funcs[command_name]
    if not func then
        warn("no command = "..tostring(command_name))
    else
        local r,e = xpcall(func,debug.traceback,player_obj,table.unpack(codes))
        if not r then
            warn("gm command ["..command_name.."] execute failed!\n"..tostring(e))
        else
            print("gm command[",command_name,"] execute success!")
        end
    end
    return message
end
---@type fun() @playerchat
---@param textChatMessage TextChatMessage
local function ReceiveNewChat(textChatMessage)
    local user_id = textChatMessage.TextSource.UserId
    local adm_name = white_id_list[user_id]
    --进行权限判断
    if not adm_name then
        warn("You don't have the permission.")
        return true --直接转发
    end
    local message_str = textChatMessage.Text
    local first_str = string.sub(message_str,1,1)
    if first_str ~= TRIGGER_STR then
        return true --直接转发
    end
    --将触发字符删除
    message_str = string.sub(message_str,2)
    --拿到玩家对象
    local player_inst = Players:GetPlayerByUserId(user_id)
    if not player_inst then
        warn("GMCommand can't find player instance id = "..tostring(user_id))
        return
    end
    local player_obj = inst_manager:FindObject(player_inst)
    if not player_obj then
        warn("can't find player object id = "..tostring(user_id))
        return true
    end
    --进行分行处理
    local codes = Split(message_str)
    local command_name = table.remove(codes,1)
    for i,v in ipairs(codes) do
        codes[i] = tonumber(v) or v
    end
    local func = gm_funcs[command_name]
    if not func then
        warn("no command = "..tostring(command_name))
        return true
    else
        local r,e = xpcall(func,debug.traceback,player_obj,table.unpack(codes))
        if not r then
            warn("gm command ["..command_name.."] execute failed!\n"..tostring(e))
        else
            print("gm command[",command_name,"] execute success!")
        end
    end
    return --命令完成不转发
end
local co = coroutine.create(function()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then--
        ---@type Folder
        local channels = TextChatService:WaitForChild("TextChannels")
        ---@type TextChannel
        local TextChannel = channels:WaitForChild("RBXGeneral")
        --会响应很多次
        TextChannel.ShouldDeliverCallback = function(textChatMessage,textSource)
            if textChatMessage.TextSource.UserId == textSource.UserId then
                return ReceiveNewChat(textChatMessage)
            else        
                return true
            end
        end
    else --LegacyChatService
        ---@param message message
        Chat:RegisterChatCallback(Enum.ChatCallbackType.OnServerReceivingMessage,ReceiveMessage)
    end
end)
coroutine.resume(co)
--清空存档
---@param player Server_Player
gm_funcs.clean_data = function(player)
    ---@type Server_PlayerDataComponent
    local data_component = player:GetComponent(hotpot.load.Server_PlayerDataComponent())
    data_component:Clean()
    player:Kick("clean data!")
end

---@param player Server_Player
gm_funcs.add_lv = function(player,num)
    num = num or 1
    local max_lv = #player_lv_cfg
    local now = player.prop_cmp:GetLv()
    if now + num > max_lv then
        return
    end
    player.prop_cmp:AddLv(num)
end

---@param player Server_Player
gm_funcs.sub_lv = function(player,num)
    num = num or 1
    local now = player.prop_cmp:GetLv()
    if now - num < 0 then
        return
    end
    local data = player.prop_cmp.data
    player.save_data:Execut(function()
        data.exp = 0
    end)
    player.prop_cmp:AddLv(-num)
end

---@param player Server_Player
gm_funcs.add_gold = function(player,num)
    num = num or 10^20
    player.prop_cmp:AddWins(num)
end

---@param player Server_Player
gm_funcs.add_gems = function(player,num)
    num = num or 100000000000000
    player.prop_cmp:AddGems(num)
end

---@param player Server_Player
gm_funcs.set_reborn = function(player,num)
    num = num or 1
    local data = player.prop_cmp.data
    player.save_data:Execut(function()
        data.reborn = num
    end)
end

return c