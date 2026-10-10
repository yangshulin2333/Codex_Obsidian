这节只解决一个问题：**FirstLoop 到底分散在哪些文件里，每个文件负责什么。**

**一、先看总入口**  
Roblox 运行时分两边：

Server 入口：

[Main.server.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ServerScriptService/Server/Main.server.lua)

Client 入口：

[Main.client.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/StarterPlayer/StarterPlayerScripts/Client/Main.client.lua)

你可以先理解成：

```
Server = 裁判、数据、奖励、规则
Client = UI、按钮、显示、玩家输入
```

FirstLoop 就是一条从 Client 到 Server 再回 Client 的闭环。

**二、Server 这条线**  
Server 侧文件顺序是：

```
Main.server.lua
-> ServiceRegistry.lua
-> ServiceList.lua
-> FirstLoopService.lua
-> DataService.lua
-> DataSchema.lua
```

对应文件：

[ServiceRegistry.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ServerScriptService/Server/Framework/Runtime/ServiceRegistry.lua)

[ServiceList.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ServerScriptService/Server/Framework/Runtime/ServiceList.lua)

[FirstLoopService.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ServerScriptService/Server/Game/Services/FirstLoopService.lua)

[DataService.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ServerScriptService/Server/Framework/Services/DataService.lua)

[DataSchema.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ReplicatedStorage/Game/Shared/Config/DataSchema.lua)

你重点记这个：

```
ServiceList 决定“有哪些服务要启动”
ServiceRegistry 负责“按顺序启动这些服务”
FirstLoopService 负责“处理小齿轮 +1 的规则”
DataService 负责“真正改玩家数据”
DataSchema 负责“玩家数据默认长什么样”
```

**三、Client 这条线**  
Client 侧文件顺序是：

```
Main.client.lua
-> ControllerRegistry.lua
-> ControllerList.lua
-> FirstLoopController.lua
-> UIController.lua
-> FirstLoopDebugGui.model.json
```

对应文件：

[ControllerRegistry.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/StarterPlayer/StarterPlayerScripts/Client/Framework/Runtime/ControllerRegistry.lua)

[ControllerList.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/StarterPlayer/StarterPlayerScripts/Client/Framework/Runtime/ControllerList.lua)

[FirstLoopController.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/StarterPlayer/StarterPlayerScripts/Client/Game/Controllers/FirstLoopController.lua)

[UIController.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/StarterPlayer/StarterPlayerScripts/Client/Framework/Controllers/UIController.lua)

[FirstLoopDebugGui.model.json](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ReplicatedStorage/Game/UI/Templates/FirstLoopDebugGui.model.json)

你重点记这个：

```
ControllerList 决定“有哪些客户端控制器要启动”
ControllerRegistry 负责“按顺序启动这些控制器”
FirstLoopController 负责“绑定按钮、发请求、刷新 UI”
UIController 负责“从模板创建 UI”
FirstLoopDebugGui.model.json 是“UI 模板结构”
```

**四、通信这条线**  
Client 和 Server 不是直接互相改变量，而是走 Remote。

相关文件：

[NetClient.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ReplicatedStorage/Framework/Shared/Net/NetClient.lua)

[NetService.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ServerScriptService/Server/Framework/Services/NetService.lua)

[NetResult.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ReplicatedStorage/Framework/Shared/Net/NetResult.lua)

FirstLoop 用了两个 RemoteFunction：

```
FirstLoop.GetSnapshot
FirstLoop.GrantSmallGear
```

含义：

```
FirstLoop.GetSnapshot = Client 问 Server：我现在有多少小齿轮？
FirstLoop.GrantSmallGear = Client 请求 Server：请给我加 1 个小齿轮
```

注意：Client 不是说“我有 999 个小齿轮”。  
Client 只能请求，最终数量由 Server 决定。

**五、FirstLoop 的完整地图**  
你现在可以把它记成一条线：

```
玩家点击“小齿轮 +1”
-> FirstLoopController
-> NetClient.Request("FirstLoop.GrantSmallGear")
-> NetService 找到对应 RemoteFunction
-> FirstLoopService 校验请求
-> DataService 修改 Resources.SmallGear
-> FirstLoopService 返回最新数据
-> FirstLoopController 刷新 UI 文本
```

这就是 FirstLoop 闭环。

**六、这一课你只需要掌握一句话**  
FirstLoop 不是一个单独孤立的脚本，而是一个最小 Feature Pack：

```
Client 输入
+ UI 模板
+ Remote 通信
+ Server 规则
+ DataService 写数据
+ UI 刷新
```

你现在先不用急着看细节。  
下一课我们讲：**玩家点击按钮后，FirstLoopController 具体做了什么。**