---@class UserInputService:Instance @UserInputService 为某种用来检测与捕捉用户设备上可用输入类型的服务。
---属性
---@field AccelerometerEnabled boolean @描述用户的设备是否带有加速度计[readonly] [notreplicated]
---@field GamepadEnabled boolean @描述用户正在使用的设备是否有可用的游戏手柄[readonly] [notreplicated]
---@field GyroscopeEnabled boolean @描述用户的设备是否有陀螺仪 [readonly] [notreplicated]
---@field KeyboardEnabled boolean @描述用户当前的设备是否有可用的键盘[readonly] [notreplicated]
---@field ModalEnabled boolean @切换 Roblox 的移动控制是否在移动设备上隐藏
---@field MouseBehavior MouseBehavior @决定用户的鼠标可以自由移动或是被锁定
---@field MouseDeltaSensitivity float @缩放用户的 Mouse 的 Delta（位置改变）输出[notreplicated]
---@field MouseEnabled boolean @描述用户当前的设备是否有可用的鼠标 [readonly] [notreplicated]
---@field MouseIconEnabled boolean @决定 Mouse 的图标是否可见
---@field OnScreenKeyboardPosition Vector2 @决定了屏幕键盘的位置[readonly] [notreplicated]
---@field OnScreenKeyboardSize Vector2 @决定了屏幕键盘的尺寸 [readonly] [notreplicated]
---@field OnScreenKeyboardVisible boolean @描述屏幕键盘当前是否在用户的屏幕上可见 [readonly] [notreplicated]
---@field TouchEnabled  boolean @描述用户当前的设备是否有可用的触摸屏[readonly] [notreplicated]
---@field VREnabled boolean @表明用户是否正在使用头戴虚拟现实设备[readonly] [notreplicated]
---事件
---@field DeviceAccelerationChanged  RBXScriptSignal @当用户移动一个有加速度计的设备时触发。用于在 Roblox 游戏中追踪现实世界的设备移动。
---@field DeviceGravityChanged RBXScriptSignal @当有加速度计的设备（如移动设备）上的重力变化时触发。
---@field DeviceRotationChanged RBXScriptSignal @当用户旋转一个带有陀螺仪的设备时触发
---@field GamepadConnected RBXScriptSignal @当游戏手柄连接至客户端时触发。传递连接的游戏手柄的 ‘‘gamepadNum’’
---@field GamepadDisconnected RBXScriptSignal @当有游戏手柄从客户端断开连接时触发。传递断开连接的游戏手柄的 UserInputType
---@field InputBegan RBXScriptSignal @当用户开始使用人机交互设备时触发，例如鼠标或游戏手柄
---@field InputChanged RBXScriptSignal @当用户改变其与人机接口设备的交互方式时触发
---@field InputEnded RBXScriptSignal @当用户结束其与人机接口设备的交互时触发
---@field JumpRequest RBXScriptSignal @当客户端请求角色跳跃时触发
---@field LastInputTypeChanged RBXScriptSignal @当客户端 UserInputType 改变时触发
---@field PointerAction RBXScriptSignal @
---@field TextBoxFocusReleased RBXScriptSignal @当客户端取消对 TextBox 的聚焦时触发
---@field TextBoxFocused RBXScriptSignal @当客户端聚焦于 TextBox 时触发
---@field TouchEnded RBXScriptSignal @当用户从一台 TouchEnabled 启用的设备 - 比如某移动设备的屏幕上抬起手指时触发
---@field TouchLongPress RBXScriptSignal @当用户在一台 TouchEnabled 启用的设备 - 比如某移动设备的同一屏幕位置上按下至少一根手指，并保持一小段时间时触发
---@field TouchMoved RBXScriptSignal @当用户在一台 TouchEnabled 启用的设备 - 比如一台Apple iPad 、iPhone 或是 Google Android 手机上移动手指时触发
---@field TouchPan RBXScriptSignal @当用户在一台 TouchEnabled 启用的设备 - 比如某移动设备的屏幕上进行手指拖动操作时触发
---@field TouchPinch RBXScriptSignal @当用户在一台 TouchEnabled 启用的设备 - 比如某移动设备的屏幕上两指缩放时触发
---@field TouchRotate RBXScriptSignal @当用户在一台 TouchEnabled 启用的设备 - 比如某移动设备的屏幕上进行二指旋转时触发
---@field TouchStarted RBXScriptSignal @当用户把手指放在在一台 TouchEnabled 启用的设备 - 比如一台Apple iPad 、iPhone 或是 Google Android 手机上时触发
---@field TouchSwipe RBXScriptSignal @当用户在一台 TouchEnabled 启用的设备 - 比如某移动设备的屏幕上滑动手指时触发
---@field TouchTap RBXScriptSignal @当用户在一台 TouchEnabled 启用的设备 - 比如某移动设备的屏幕上手指点击时触发
---@field TouchTapInWorld RBXScriptSignal @当用户在一台 TouchEnabled 启用的设备 - 比如某移动设备的屏幕上点击游戏世界时触发
---@field UserCFrameChanged RBXScriptSignal @当指定虚拟现实设备的 CFrame 改变时触发
---@field WindowFocusReleased RBXScriptSignal @当 Roblox 客户端窗口在用户的屏幕上失去焦点时触发
---@field WindowFocused RBXScriptSignal @当 Roblox 客户端窗口在用户的屏幕上处于前台聚焦状态时触发
local module={}
---@type fun(param:UserInputType,param:KeyCode):boolean @返回给定 UserInputType 手柄是否支持对应给定 KeyCode 的按钮。
---@param gamepadNum UserInputType @游戏手柄的 Enum/UserInputType
---@param gamepadKeyCode KeyCode @需判定按钮的 KeyCode
---@return boolean @给定游戏手柄是否支持对应给定 KeyCode 的按钮
function module:GamepadSupports()
end
---@type fun():Array @此函数将返回当前连接的 UserInputType 游戏手柄数组.
---@return Array @对应连接至用户设备的游戏手柄的 UserInputType 数组
function module:GetConnectedGamepads()
end
---@type fun():Instance @函数决定用户设备当前的加速状态，将返回描述设备当前加速度的 InputObject。
---@return Instance @描述设备当前加速状态的 InputObject。
function module:GetDeviceAcceleration()
end	
---@type fun():Instance @此函数将会返回描述设备当前重力向量的 InputObject。
---@return Instance @描述设备当前重力向量的 InputObject
function module:GetDeviceGravity()
end
---@type fun():Tuple @返回描述设备当前旋转向量的 InputObject 和 CFrame
---@return Tuple @含有 2 个属性的元组：1.描述最近发生旋转量的 Delta 属性 2.设备当前的旋转 CFrame（相对于其默认参考位置）
function module:GetDeviceRotation()
end
---@type fun():Instance @返回当前客户端聚焦的 TextBox
---@return Instance @当前获得焦点的 TextBox，无选中 TextBox 时将会返回 nil
function module:GetFocusedTextBox()
end
---@type fun(param:UserInputType):boolean @返回拥有给定 UserInputType “gamepadNum” 的游戏手柄是否已连接
---@param gamepadNum UserInputType @游戏手柄的 UserInputType
---@return boolean @与 UserInputType 关联的游戏手柄是否已连接
function module:GetGamepadConnected()
end
---@type fun(param:UserInputType):Array @返回给定游戏手柄上所有可用输入的 InputObject 数组，代表了每个输入的最后输入状态
---@param gamepadNum UserInputType @所查询游戏手柄的 UserInputType
---@return Array @给定游戏手柄上所有可用输入的 InputObject 数组，代表了每个输入的当前状态
function module:GetGamepadState()
end
---@type fun():Array @返回对应当前被按下键盘按键的 InputObject 数组
---@return Array @对应当前被按下键盘按键的 InputObject 数组
function module:GetKeysPressed()
end
---@type fun():UserInputType @返回与用户最新输入所关联的 UserInputType
---@return UserInputType @与用户最新输入所关联的 UserInputType
function module:GetLastInputType()
end
---@type fun():Vector2 @返回玩家 Mouse 在最后渲染帧中的位置变化（以像素为单位）。仅适用于鼠标处于锁定状态时
---@return Vector2 @鼠标移动位置的变更
function module:GetMouseDelta()
end
---@type fun():Vector2 @返回玩家 Mouse 相对于屏幕左上角的当前屏幕位置
---@return Vector2 @代表鼠标当前屏幕位置的 DataType/Vector2|Vector2 值，以像素为单位
function module:GetMouseLocation()
end
---@type fun():Array @返回已连接且启用 GUI 导航的游戏手柄数组，按照优先度从高至低排列
---@return Array @可以用来进行 GUI 导航的 UserInputType|UserInputType 数组，按照优先度从高至低排列
function module:GetNavigationGamepads()
end
---@type fun(param:KeyCode):String @返回代表用户为输入给定 KeyCode 所应按下按键的字符串
---@param keyCode KeyCode @
---@return String @返回顾及用户键盘布局的字符串
function module:GetStringForKeyCode()
end
---@type fun(param:UserInputType):Array @返回与给定 UserInputType 相关联的游戏手柄所支持的 KeyCode 数组
---@param gamepadNum  UserInputType @游戏手柄的 UserInputType
---@return Array @给定游戏手柄所支持的 KeyCode 数组
function module:GetSupportedGamepadKeyCodes()
end
---@type fun(param:UserCFrame):CFrame @返回描述给定虚拟现实设备位置与方向的 CFrame
---@param type  UserCFrame @对应 VR 设备的 Enum/UserCFrame
---@return CFrame @	描述给定虚拟现实设备位置与方向的 CFrame
function module:GetUserCFrame()
end
---@type fun(param:UserInputType,param:KeyCode):boolean @决定给定游戏手柄上的特定按钮是否要被按下
---@param gamepadNum  UserInputType @给定游戏手柄的 UserInputType
---@param gamepadKeyCode KeyCode @特定按钮的 Enum\KeyCode
---@return boolean @给定游戏手柄上的特定按钮是否被按下
function module:IsGamepadButtonDown()
end
---@type fun(param:KeyCode):boolean @返回给定键是否正在被按下
---@param keyCode KeyCode @给定键的 Enum/KeyCode
---@return boolean @给定键是否正在被按下
function module:IsKeyDown()
end
---@type fun(param:UserInputType):boolean @返回给定鼠标键是否正在被按下
---@param mouseButton UserInputType @鼠标键的 UserInputType
---@return boolean @给定鼠标键是否正在被按下
function module:IsMouseButtonPressed()
end
---@type fun(param:UserInputType):boolean @当给定 UserInputTypeGamepad 被允许控制导航 GUI 时返回 true
---@param gamepadEnum UserInputType @给定游戏手柄的 UserInputType
---@return boolean @给定游戏手柄是否为导航游戏手柄
function module:IsNavigationGamepad()
end
---@type fun() @将头戴式 VR 设备的 CFrame 重定位至用户当前使用设备的方向
function module:RecenterUserHeadCFrame()
end
---@type fun(param:UserInputType,param:boolean) @设置给定 Gamepad 是否能够移动 GUI 导航器
---@param gamepadEnum UserInputType 给定游戏手柄的 UserInputType
---@param enabled boolean @给定游戏手柄是否能移动 GUI 导航器
function module:SetNavigationGamepad ()
end