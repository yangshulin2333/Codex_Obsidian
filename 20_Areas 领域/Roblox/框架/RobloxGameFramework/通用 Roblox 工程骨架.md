**一句话理解**  
这不是完整 RPG 框架，而是一个“通用 Roblox 工程骨架”。它已经解决：

- 代码放哪里：Rojo 映射
- 启动顺序怎么控制：显式 `ServiceList` / `ControllerList`
- Server / Client 怎么分工
- Remote 怎么统一创建和调用
- 数据入口怎么统一经过 `DataService`
- 后续具体玩法怎么以 `Feature Pack` 接入

它还没做：

- 战斗
- 背包
- 怪物 AI
- 掉落
- Boss
- 真实 ProfileStore
- 正式 UI

**三条主线**  
服务端启动线：

```
Main.server.lua
-> ServiceRegistry
-> ServiceList
-> 每个 Service 的 Init()
-> 每个 Service 的 Start()
```

入口在 [Main.server.lua (line 6)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Main.server.lua:6)。  
核心注册器在 [ServiceRegistry.lua (line 28)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Runtime/ServiceRegistry.lua:28)。  
显式服务列表在 [ServiceList.lua (line 7)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Runtime/ServiceList.lua:7)。

客户端启动线：

```
Main.client.lua
-> ControllerRegistry
-> ControllerList
-> 每个 Controller 的 Init()
-> 每个 Controller 的 Start()
```

入口在 [Main.client.lua (line 6)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/StarterPlayer/StarterPlayerScripts/Client/Main.client.lua:6)。  
客户端注册器在 [ControllerRegistry.lua (line 30)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/StarterPlayer/StarterPlayerScripts/Client/Framework/Runtime/ControllerRegistry.lua:30)。  
显式控制器列表在 [ControllerList.lua (line 7)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/StarterPlayer/StarterPlayerScripts/Client/Framework/Runtime/ControllerList.lua:7)。

网络线：

```
Client Controller
-> NetClient.Request()
-> RemoteFunction
-> NetService:RegisterRequest()
-> Server handler
-> NetResult.Ok / NetResult.Err
-> Client UI 展示
```

核心在 [NetService.lua (line 119)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/NetService.lua:119)、[NetClient.lua (line 57)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/NetClient.lua:57)、[NetResult.lua (line 5)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/NetResult.lua:5)。

**最重要的语法点**  
`--!strict`：开启 Luau 严格模式，让编辑器和检查工具更早发现类型/变量问题。

`local X = { Name = "X" }`：这里用普通 table 表示一个 Service / Controller。

`function X:Init(context)`：冒号写法，等于函数自动带 `self`。  
也就是：

```
function X:Init(context)
```

近似等于：

```
function X.Init(self, context)
```

`setmetatable({}, ServiceRegistry)`：这是 Luau/Lua 常见的“类实例”写法。`ServiceRegistry.new()` 创建一个实例，里面保存 `_services`、`_context`、`_initialized` 等状态。

`require(...)`：加载 ModuleScript。`ServiceList` 里每个 `require(...)` 都会得到一个 Service table。

`ipairs(self._services)`：按数组顺序从上到下遍历，所以 `ServiceList` 的顺序就是启动顺序。

**当前代码最该先掌握的 8 个文件**

1. [AGENTS.md](D:/AI/Codex/ToyBox/RobloxGameFramework/AGENTS.md)  
    项目规矩。
    
2. [default.project.json](D:/AI/Codex/ToyBox/RobloxGameFramework/default.project.json)  
    Rojo 把本地文件映射到 Roblox 的规则。
    
3. [ServiceRegistry.lua](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Runtime/ServiceRegistry.lua)  
    服务端启动核心。
    
4. [ControllerRegistry.lua](D:/AI/Codex/ToyBox/RobloxGameFramework/src/StarterPlayer/StarterPlayerScripts/Client/Framework/Runtime/ControllerRegistry.lua)  
    客户端启动核心。
    
5. [NetService.lua](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/NetService.lua)  
    Server Remote 边界。
    
6. [NetClient.lua](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/NetClient.lua)  
    Client Remote 调用。
    
7. [DataService.lua](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/DataService.lua)  
    数据唯一入口。
    
8. [FeatureService.lua](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/FeatureService.lua)  
    后续玩法包登记入口。
    

**验证结果**  
我没有改代码/文档；但运行 `rojo sourcemap` 和 `rojo build` 会重新生成已有的 `sourcemap.json` 和 `build.rbxlx` 构建产物。

验证通过：

```
stylua --check .
selene src
rojo sourcemap default.project.json --output sourcemap.json
rojo build default.project.json --output build.rbxlx
```

结果：`selene` 为 0 errors / 0 warnings，Rojo build 成功。当前机器能找到 `rojo/wally/stylua/selene`，没找到 `rokit`。

**建议学习顺序**  
下一步不要直接看所有文件。建议我们按这 6 课来：

1. 先讲 `default.project.json` 和 Roblox 目录映射。
2. 讲 `Main.server.lua -> ServiceRegistry -> ServiceList`。
3. 讲 `Main.client.lua -> ControllerRegistry -> ControllerList`。
4. 讲 `NetService / NetClient / NetResult`。
5. 讲 `DataService / DataSchema`。
6. 讲怎么把 `ToyboxGuardiansGame` 的 `001_FirstLoop` 接到这套框架里。

下一轮我建议从第 1 课开始：`default.project.json` 到底把这些文件放进 Roblox Studio 的哪里。