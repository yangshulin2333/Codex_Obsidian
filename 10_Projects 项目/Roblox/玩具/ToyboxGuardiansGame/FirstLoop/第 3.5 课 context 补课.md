好。按我们调整后的节奏，**第 3 课先讲 `context`**。  
因为你后面看所有 `Init(context)` 都会遇到它。

这一课只解决一个问题：

```
context 到底是谁创建的？
里面有什么？
为什么 FirstLoopController / FirstLoopService 可以从里面拿工具？
```

**一、context 是什么**  
你可以先把 `context` 理解成：

```
框架启动时，Registry 发给每个模块的“工具包”。
```

Client 侧的 Controller 需要这些工具：

```
Logger：打日志
NetClient：请求 Server
其他 Controller：比如 UIController
```

Server 侧的 Service 需要这些工具：

```
Logger：打日志
其他 Service：比如 DataService、NetService
```

所以框架统一做一件事：

```
我先把常用工具装进 context
然后每个模块 Init(context) 时自己领取需要的工具
```

**二、Client 侧 context 长什么样**  
Client 的 context 在：

[ControllerRegistry.lua (line 27)](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/StarterPlayer/StarterPlayerScripts/Client/Framework/Runtime/ControllerRegistry.lua:27)

核心结构大概是：

```
self._context = {
	Logger = Logger,
	Net = NetClient,
	Controllers = self._controllersByName,
}
```

真实含义：

```
context.Logger = 日志模块
context.Net = NetClient 网络工具
context.Controllers = 所有 Controller 的字典表
```

其中 `Controllers` 大概长这样：

```
{
	InputController = InputController,
	UIController = UIController,
	CameraController = CameraController,
	FirstLoopController = FirstLoopController,
}
```

所以在 FirstLoopController 里：

```
self._uiController = context.Controllers.UIController
```

意思就是：

```
从 context.Controllers 这个字典表里，取出 UIController。
```

**三、为什么 UIController 能拿到**  
这里有个关键点：`ControllerRegistry` 不是一上来就 Init。它先注册所有 Controller 名字。

流程是：

```
第一轮：
for controller in ControllerList
-> self._controllersByName[controller.Name] = controller

第二轮：
for controller in ControllerList
-> controller:Init(self._context)
```

为什么要分两轮？

因为如果直接边注册边 Init，可能出现：

```
FirstLoopController Init 时想拿 UIController
但 UIController 还没登记进 Controllers 表
```

所以框架先把所有 Controller 放进字典，再统一 Init。

这就是：

```
先登记名单
再开始初始化
```

**四、FirstLoopController:Init(context) 逐行看**  
代码：

```
function FirstLoopController:Init(context)
	self._logger = context.Logger
	self._net = context.Net
	self._uiController = context.Controllers.UIController
end
```

逐行翻译：

```
self._logger = context.Logger
把日志工具存到自己身上，后面想打日志就用 self._logger

self._net = context.Net
把 NetClient 存起来，后面发 Remote 请求就用 self._net.Request(...)

self._uiController = context.Controllers.UIController
把 UIController 存起来，后面挂载 UI 模板就用 self._uiController
```

这里的 `self._xxx` 是当前模块自己的字段。

你可以理解成：

```
Init 阶段不是干活，是把以后要用的工具先放到抽屉里。
```

**五、为什么不直接 require UIController**  
你可能会问：

```
local UIController = require(...)
```

不是也能拿到吗？为什么绕一圈 context？

原因是框架要统一管理模块生命周期。

如果到处直接 `require`，会变成：

```
谁依赖谁不清楚
启动顺序不清楚
测试时不好替换
模块之间乱连
```

用 `context` 后，关系更清楚：

```
ControllerRegistry 负责创建工具包
每个 Controller 只从工具包领取依赖
```

这叫“依赖注入”。

别被名字吓到，它的意思就是：

```
不要自己到处找工具。
由框架把工具递给你。
```

**六、Server 侧 context 也类似**  
Server 的 FirstLoopService 里：

```
function FirstLoopService:Init(context)
	self._logger = context.Logger
	self._dataService = context.Services.DataService
	self._netService = context.Services.NetService
end
```

Server 的 context 大概长这样：

```
context = {
	Logger = Logger,
	Services = {
		DataService = DataService,
		NetService = NetService,
		PlayerSessionService = PlayerSessionService,
		FirstLoopService = FirstLoopService,
	}
}
```

所以：

```
context.Services.DataService
= DataService 服务

context.Services.NetService
= NetService 服务
```

FirstLoopService 拿到它们后，后面就可以：

```
self._dataService:UpdateProfile(...)
self._netService:RegisterRequest(...)
```

**七、context 和参数的关系**  
你之前说“看到入参就想知道具体是什么”。这是对的。

以后看到：

```
function Xxx:Init(context)
```

你就问：

```
谁调用 Init？
传进来的 context 是在哪里创建的？
context 里面有哪些字段？
这个模块从 context 里拿了哪些字段？
```

拿 FirstLoopController 举例：

```
谁调用：
ControllerRegistry

传入什么：
self._context

context 有什么：
Logger
Net
Controllers

FirstLoopController 拿了什么：
Logger
Net
Controllers.UIController
```

这就是看入参的正确方式。

**八、本课最重要的一句话**  
`context` 是框架给模块的工具包。

```
Registry 负责准备 context。
Init(context) 负责领取工具。
Start() 才开始真正干活。
```

你现在只需要记住这条：

```
ControllerRegistry 创建 Client 工具包。
ServiceRegistry 创建 Server 工具包。
每个模块 Init(context) 时，从工具包里拿自己需要的依赖。
```

下一课建议讲：

```
MountStudioTemplate(TEMPLATE_NAME, { Contract = FIRST_LOOP_UI_CONTRACT })
```

因为这里涉及你最不舒服的三个点：入参、table 语法、UI Contract。