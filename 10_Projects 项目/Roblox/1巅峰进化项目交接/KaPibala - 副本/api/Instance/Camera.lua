---@class Camera:Instance @Camera （镜头）对象用于定义 3D 游戏世界的视角。
---@field CFrame CFrame @Camera 的 CFrame，决定了它在 3D 世界中的位置和朝向
---@field CameraSubject Instance @为 Camera's 主体的 Humanoid 或者 BasePart
---@field CameraType CameraType @指定将要被镜头脚本读取的 CameraType
---@field FieldOfView number @设置镜头垂直视野的角度
---@field Focus CFrame @在3D空间中设置Roblox图形系统优先处理的区域
---@field HeadLocked boolean @负责切换 Camera 是否会自动追踪使用 VR 设备的玩家的头部运动
---@field HeadScale number @设置使用 VR 时用户头部的相对比例
---@field NearPlaneZ number @描述近截面 Camera's 的负 z-offset（Z 偏移），以格为单位
---@field ViewportSize Vector2 @描述客户端视口的尺寸（以像素为单位）
local module = {}
---@type fun():number @返回 Camera 当前的 ‘pan’ 速度
---@return number @Camera 在 Y 轴上绕其 Camera/Focus 旋转的速度
function module:GetPanSpeed()
end
---@type fun(param:Vector3[],param:BasePart[]):BasePart[] @本函数返回一组遮挡 Camera’s 和 Camera.CFrame 二者与 castPoints 之间视线的 BaseParts。
---@param castPoints Vector3[] @投射点的 Vector3 位置数组
---@param ignoreList BasePart[] @将被忽略的实例的数组及其子代
---@return BasePart[] @一个 BasePart 数组，该数组遮蔽镜头的 Camera.CFrame 和 castPoints 之间的视线
function module:GetPartsObscuringTarget()
end
---@type fun():CFrame @返回 Camera 被渲染的实际 CFrame（包括应用的任意滚动以及 VR 设备的影响）
---@return CFrame @Camera 正在以何种 DataType/CFrame 被渲染
function module:GetRenderCFrame()
end
---@type fun():number @返回通过 Camera:SetRoll 应用至 Camera 的当前滚动、或是绕 Camera’s 的 Z 轴的旋转之角度（单位为弧度）
---@return number @通过 Camera:SetRoll 应用的当前滚动角度，单位为弧度
function module:GetRoll()
end
---@type fun():number @返回 Camera 当前的 ‘tilt’ （倾斜）速度
---@return number @Camera 在 Camera|Camera’s X 轴上绕其 Camera/Focus 旋转的速度
function module:GetTiltSpeed()
end
---@type fun(param:number,param:number,param:number):Ray @以朝向镜头的方向，通过设置的距 Camera 的深度，在屏幕上的某个位置创建单位 Ray（以像素为单位）。考虑 GUI 嵌入
---@param x number @发射 DataType/Ray 的屏幕点的 X 轴上的位置（以像素为单位）。此位置考虑 GUI 嵌入
---@param y number @发射 Ray 的屏幕点的 Y 轴上的位置（以像素为单位）。此位置考虑 GUI 嵌入
---@param depth number @距 Ray 原点与之偏移的 Camera 的深度（以格为单位）
---@return Ray @一种单元 Ray，发射自距 Camera 一定深度处给定屏幕坐标的等效 Vector3 世界位置。射线的方向与 Camera 的方向一致
function module:ScreenPointToRay()
end
---@type fun(param:CameraPanMode) @设置在移动设备上将被 Camera 使用的 CameraPanMode
---@param mode CameraPanMode @Camera 设置使用的 CameraPanMode
function module:SetCameraPanMode()
end
---@type fun(param:number) @设置围绕镜头的 Z 轴应用的当前旋转
---@param rollAngle number @应用于 Camera 的滚动角度（以弧度为单位）
function module:SetRoll()
end
---@type fun(param:number,param:number,param:number):Ray @以朝向镜头的方向，通过给定的距 Camera 的深度，在视口上的某个位置创建单位 Ray（以像素为单位）。不考虑 GUI 嵌入
---@param x number @发射 DataType/Ray 的视口点的 X 轴上的位置（以像素为单位）。此位置不考虑 GUI 嵌入
---@param y number @发射 Ray 的视口点的 Y 轴上的位置（以像素为单位）。此位置不考虑 GUI 嵌入
---@param depah number @距 Ray 原点与之偏移的 Camera 的深度（以格为单位）
---@return Ray @一种单元 Ray，发射自距 Camera 一定深度处给定视口坐标的等效 Vector3 世界位置。射线方向与 Camera 的方向一致
function module:ViewportPointToRay()
end
---@type fun(param:Vector3):table @返回世界中 Vector3 位置的 2D 屏幕位置、距离屏幕的深度以及是否可见。负责 GUI 嵌入
---@param worldPoint Vector3 @Vector3 世界位置
---@return table @一个元组，按顺序包括： 一个 Vector3，其 X 和 Y 分量表示 worldPoint 距屏幕左上角的偏移（以像素为单位）。Vector3 的 Z 分量表示 worldPoint 距屏幕的深度（以格为单位）。 一个布尔值，指示 worldPoint 是否在屏幕的边界内
function module:WorldToScreenPoint()
end
---@type fun(param:Vector3):table @返回世界中 Vector3 位置的 2D 屏幕位置，但不考虑 GUI 嵌入
---@param worldPoint Vector3 @Vector3 世界位置
---@return table @一个元组，按顺序包括： 一个 Vector3，其 X 和 Y 分量表示 worldPoint 距视口左上角的偏移（以像素为单位）。Vector3 的 Z 分量表示 worldPoint 距屏幕的深度（以格为单位）。 一个布尔值，指示 worldPoint 是否在视口的边界内。
function module:WorldToViewportPoint()
end