---@class Players:Instance @Players 游戏服务包含的是当前已经连接到 Roblox 游戏服务器的客户端的 Player 对象。它还包含了场景的配置信息（如泡泡聊天或是经典聊天）。它可以获取未连接到服务器的玩家的信息，如角色外观、好友和虚拟角色缩略图。
---@field BubbleChat boolean @指示气泡聊天是否启用。可用 Players:SetChatStyle 方法设置。
---@field CharacterAutoLoads boolean @指示角色是否将自动重生。
---@field ClassicChat boolean @指示是否启用经典聊天；由Players：SetChatStyle方法设置。
---@field MaxPlayers number @该服务器中可以包含的最大播放器数量。
---@field LocalPlayer Player @运行LocalScript的播放器
---@field MaxPlayersInternal number @供内部使用的Players.MaxPlayers。
---@field PreferredPlayers number @此服务器的首选播放器数量。
---@field PreferredPlayersInternal number @供内部使用的Players.PreferredPlayers。
---@field RespawnTime number @控制玩家角色重生所需的时间
---@field PlayerAdded RBXScriptSignal @玩家进入游戏时触发。
---@field PlayerChatted RBXScriptSignal @玩家聊天时触发。
---@field PlayerConnecting RBXScriptSignal @在玩家正在连接游戏时触发。
---@field PlayerDisconnecting RBXScriptSignal @当玩家与游戏断开连接时触发。
---@field PlayerRejoining RBXScriptSignal @在玩家断开连接后重新加入游戏会话时触发
---@field PlayerRemoving RBXScriptSignal @当玩家即将离开游戏时触发
local module = {}
---@type fun(message:string) @此函数可使本地玩家发送指定聊天消息。由于此项受保护，所以尝试在 Script 或 LocalScript 中使用该项时会导致错误。 而在创建自定义聊天系统或需要访问聊天的系统时，开发者可以使用 Chat 服务的 Chat:Chat 函数。
---@param message string 发送的聊天消息
function module:Chat(message)
end
---@type fun():Player @游戏会使用该函数来创建 Players.LocalPlayer。由于该项目已经过保护，因此尝试在 Script 或 LocalScript 中使用该项目会导致错误。 尽管你无法创建 LocalPlayer，但可以使用以下 LocalScript 中的代码来引用游戏创建的 LocalPlayer
---@return Player @一种代表已创建的本地玩家的 Player 实例
function module:CreateLocalPlayer()
end
---@type fun(user_id:number):Model @返回一个模型，其中包含玩家穿戴的资产（不包括装备）
---@param user_id number @指定玩家的 Player.UserId
---@return Instance @一个包含玩家穿戴物品（不包括装备）的 Model
function module:GetCharacterAppearanceAsync(user_id)
end
---@type fun(user_id:number):table<number,table<table,string>> 返回有关给定用户的角色外观的信息
---@param user_id number @指定用户的 *userId 。
---@return table<number,table<table,string>> @包含指定用户的角色外观信息的字典
function module:GetCharacterAppearanceInfoAsync(user_id)
end
---@type fun(user_id:number):FriendPages @返回一个FriendPages对象，其中包含有关给定玩家所有朋友的信息
---@param user_id number @指定玩家的 userId
---@return FriendPages @一个 FriendPages 对象，该对象包含指定玩家所有好友的信息
function module:GetFriendsAsync(user_id)
end
---@type fun(out_fit_id:number):Instance
---@param out_fit_id number
---@return Instance
function module:GetHumanoidDescriptionFromOutfitId(out_fit_id)
end
---@type fun(user_id:number):Instance
---@param user_id number
---@return Instance
function module:GetHumanoidDescriptionFromUserId(user_id)
end
---@type fun(user_id:number):string @向Roblox网站发送查询，查询具有给定UserId的帐户的用户名
---@param user_id number @指定玩家的 Player/UserId
---@return string @指定玩家的 Player/UserId
function module:GetNameFromUserIdAsync(user_id)
end
---@type fun(user_id:number):Player @此函数用于在 Players 中查找 Player.UserId 与给定 UserId 匹配的玩家。如果不存在符合要求的玩家，会返回 nil
---@param user_id number @指定玩家的 Player.UserId
---@return Player @具有指定 Player.UserId 的玩家，若指定玩家不在游戏中，则为 nil
function module:GetPlayerByUserId(user_id)
end
---@type fun(character:Model):Player @返回其角色与给定实例匹配的Player；如果找不到一个，则返回nil
---@param character Model @您想要从中获取玩家的角色实例。
---@return Player @与作为输入传递的角色相对应的玩家实例
function module:GetPlayerFromCharacter(character)
end
---@type fun():Player[] @返回所有当前连接的Player对象的表
---@return Player[] @包含服务器中所有玩家的表
function module:GetPlayers()
end
---@type fun(user_name:string):number @向 Roblox 网站发送一个具有给定用户名的账户 userId 的查询。
---@param user_name string @指定玩家的 username（用户名）
---@return number @使用指定 name 的用户的 Player.UserId
function module:GetUserIdFromNameAsync(user_name)
end
---@type fun(user_id:number,thumbnail_type:ThumbnailType,thumbnail_size:thumbnailSize) @返回给定大小和类型（头像，胸像，头像）的播放器缩略图的内容URL，以及描述图像是否准备就绪可以使用的布尔值
---@param user_id number @指定玩家的 Player.UserId
---@param thumbnail_type ThumbnailType @一个 ThumbnailType，描述缩略图的类型
---@param thumbnail_size ThumbnailSize @一个 ThumbnailSize，指定缩略图的尺寸
---@return table @一个元组，包含基于指定参数的用户缩略图的内容URL，以及一个 bool 值，描述图片是否已经可供使用
function module:GetUserThumbnailAsync(user_id,thumbnail_type,thumbnail_size)
end
---@type fun(message:string,player:Player) @在没有任何其他人能够看到的情况下将给定消息传递给一名接收者
---@param message string @正在聊天的消息
---@param player Player @接收者 Player
function module:WhisperChat(message,player)
end
