---@class Chat:Instance @聊天服务包含了负责运行Lua聊天系统的Lua代码。与StarterPlayerScripts类似，默认对象（如Scripts和ModuleScripts）也会被插入到该服务中。除了提供运行Lua聊天系统的功能，该服务还提供了用于过滤文本的函数：FilterStringAsync()和FilterStringForBroadcast()。请注意，实现自定义聊天系统的游戏必须使用这些函数才能正确过滤聊天。有关更多信息，请参见文本和聊天过滤。
---@field BubbleChatEnabled boolean @如果为真，在聊天中输入一条消息将导致一个聊天气泡出现在玩家的Player.Character之上。这种行为可以通过在Studio中直接勾选此复选框或使用LocalScript来启用,这必须在客户端上完成，在服务器端脚本中切换此值将无效。
---@field LoadDefaultChat boolean @切换游戏运行时是否自动加载默认聊天框架。
local c = {}
---@type fun(part_or_character:Instance,message:string,color:ChatColor) @Chat功能会使用此方法中指定的参数触发Chat.Chatted事件。默认情况下，每个玩家的PlayerScripts对象中都有一个名为BubbleChat的LocalScript，当触发chatted事件时，它会在partOrCharacter的上方出现类似对话框的公告牌。注意：由于对话框是由LocalScript控制的，除非你在单人模式下运行，否则你将无法看到此方法创建的任何对话框。
---@param part_or_character Instance @一个实例，即BubbleChat对话框应出现在其上面的部分或角色。
---@param message string @聊天所传送的信息字符串。
---@param color ChatColor @一个ChatColor指定聊天消息的颜色。默认值：“蓝色”
function c:Chat(part_or_character,message,color)
end
---@type fun(part_or_character:Instance,message:string,color:ChatColor) @
---@param part_or_character Instance @一个实例，即BubbleChat对话框应出现在其上面的部分或角色。
---@param message string @聊天所传送的信息字符串。
---@param color ChatColor @一个ChatColor指定聊天消息的颜色。默认值：“蓝色”
function c:ChatLocal(part_or_character,message,color)
end
---@type fun():boolean
---@return boolean
function c:GetShouldUseLuaChat()
end
---@type fun(callback_type:ChatCallbackType,callback_arguments:table):table @InvokeChatCallback会调用RegisterChatCallback注册的函数，给定ChatCallbackType枚举和发送给函数的参数。它将返回注册函数的结果，如果没有注册函数，则会引发错误。此函数由Lua聊天系统调用，以便可以注册聊天回调以更改某些功能的行为。除非您用自己的系统替换默认的Lua聊天系统，否则不需要调用此函数。您可以在Chat:RegisterChatCallback()中阅读有关不同回调函数的信息。
---@alias ChatCallbackType  "Enum.ChatCallbackType.OnCreatingChatWindow" | "Enum.ChatCallbackType.OnClientSendingMessage" | "Enum.ChatCallbackType.OnClientFormattingMessage" | "Enum.ChatCallbackType.OnServerReceivingMessage"
---@param callback_type ChatCallbackType @回调要调用的类型。
---@param callback_arguments table @参数将被发送到已注册的回调函数。
---@return table
function c:InvokeChatCallback(callback_type,callback_arguments)
end
---@type fun(callback_type:ChatCallbackType) @RegisterChatCallback将函数绑定到Lua聊天系统的某些聊天系统事件，以影响其行为。第一个参数确定要绑定第二个参数（即函数）的事件（使用ChatCallbackType枚举）。默认的Lua聊天系统使用InvokeChatCallback来调用已注册的函数。尝试在不是服务器或客户端的对等体上注册仅服务器或仅客户端的回调时，将引发错误。 下面的部分描述了如何使用已注册的函数。
---@param callback_type ChatCallbackType @回调函数将被注册（这决定了函数的调用方式）。
---@param callback_function function @当使用Chat:InvokeChatCallback调用回调时要调用的函数。
function c:RegisterChatCallback(callback_type,callback_function)
end
---@type fun(settings:table) @这个函数可以自定义游戏中气泡聊天的各种设置。在使用之前，请确保通过将Chat.BubbleChatEnabled设置为true来启用气泡聊天。设置参数是一个表，其中键是要编辑的设置的名称，值是要更改这些设置的值。请注意，您不必在设置参数中包括所有设置，省略某些设置将导致它们保持其默认值。此函数仅限客户端，尝试在服务器上调用它将触发错误。有关更详细的指南，请参见气泡聊天。
---@param settings table @设置表。
function c:SetBubbleChatSettings(settings)
end