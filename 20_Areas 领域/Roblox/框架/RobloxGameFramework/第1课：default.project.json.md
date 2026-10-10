先记一句话：

`default.project.json` 是 Rojo 的“同步地图”。

它告诉 Rojo：

```
本地 Windows 文件夹
应该放到 Roblox Studio Explorer 的哪个位置
```

文件位置：

[default.project.json (line 1)](D:/AI/Codex/ToyBox/RobloxGameFramework/default.project.json:1)

**1. 最外层**

```
{
  "name": "RobloxGameFramework",
  "tree": {
    "$className": "DataModel"
  }
}
```

意思是：

```
这个 Rojo 工程叫 RobloxGameFramework。
tree 表示 Roblox Studio 里的整棵 Explorer 树。
DataModel 就是 Roblox 游戏的最顶层。
```

你可以把 `DataModel` 理解成 Roblox Studio 里所有服务的根：

```
DataModel
  ReplicatedStorage
  ServerScriptService
  StarterPlayer
  StarterGui
  Workspace
  ...
```

这里没有写 `Workspace`，说明这个框架暂时不管理地图场景。

**2. ReplicatedStorage**

对应这里：

[default.project.json (line 5)](D:/AI/Codex/ToyBox/RobloxGameFramework/default.project.json:5)

```
"ReplicatedStorage": {
  "$className": "ReplicatedStorage",
  "Framework": {
    "$path": "src/ReplicatedStorage/Framework"
  },
  "Game": {
    "$path": "src/ReplicatedStorage/Game"
  },
  "Packages": {
    "$path": "Packages"
  }
}
```

意思是 Roblox Studio 里会变成：

```
ReplicatedStorage
  Framework
  Game
  Packages
```

它们分别来自本地：

```
src/ReplicatedStorage/Framework
src/ReplicatedStorage/Game
Packages
```

重点理解：

```
ReplicatedStorage 是 Server 和 Client 都能读取的地方。
```

所以这里适合放：

```
共享配置
共享类型
Remote 名称
Client/Server 都需要 require 的模块
第三方包
```

但不适合放：

```
服务端秘密逻辑
真实发奖逻辑
存档写入逻辑
```

**3. ServerScriptService**

对应这里：

[default.project.json (line 17)](D:/AI/Codex/ToyBox/RobloxGameFramework/default.project.json:17)

```
"ServerScriptService": {
  "$className": "ServerScriptService",
  "Server": {
    "$path": "src/ServerScriptService/Server"
  }
}
```

意思是：

```
本地 src/ServerScriptService/Server
会同步到 Roblox Studio 的 ServerScriptService/Server
```

Studio 里大概是：

```
ServerScriptService
  Server
    Main.server.lua
    Framework
    Game
```

重点理解：

```
ServerScriptService 只在服务端运行。
Client 看不到、也不能直接访问这里的 ModuleScript。
```

所以这里适合放：

```
DataService
NetService
伤害计算
奖励发放
掉落判定
ProfileStore 接入
Boss AI
```

以后 `ToyboxGuardiansGame` 的真实玩法 Service，也应该主要在这条线下面。

**4. StarterPlayerScripts**

对应这里：

[default.project.json (line 23)](D:/AI/Codex/ToyBox/RobloxGameFramework/default.project.json:23)

```
"StarterPlayer": {
  "$className": "StarterPlayer",
  "StarterPlayerScripts": {
    "$className": "StarterPlayerScripts",
    "Client": {
      "$path": "src/StarterPlayer/StarterPlayerScripts/Client"
    }
  }
}
```

意思是：

```
本地 src/StarterPlayer/StarterPlayerScripts/Client
会同步到 Studio 的 StarterPlayer/StarterPlayerScripts/Client
```

游戏运行时，每个玩家客户端都会得到这些脚本。

这里适合放：

```
Main.client.lua
ControllerRegistry
InputController
UIController
CameraController
AudioController
VFXController
游戏客户端 Controller
```

重点：

```
这里的代码运行在玩家电脑上。
所以这里不能相信，不能发奖，不能改存档，不能决定伤害结果。
```

它只负责：

```
收集输入
显示 UI
播放动画
播放音效
调用 Remote 请求 Server
```

**5. StarterGui**

对应这里：

[default.project.json (line 32)](D:/AI/Codex/ToyBox/RobloxGameFramework/default.project.json:32)

```
"StarterGui": {
  "$className": "StarterGui",
  "StudioTemplates": {
    "$path": "src/StarterGui/StudioTemplates"
  }
}
```

意思是：

```
本地 src/StarterGui/StudioTemplates
会同步到 Studio 的 StarterGui/StudioTemplates
```

当前它只有说明文档，还没有真正 UI 模板。

这个目录未来用于：

```
复杂静态 UI 模板
比如背包界面、强化台界面、Boss 血条模板
```

框架的思路是：

```
复杂布局在 Studio 里做
动态刷新用 Lua / Fusion / Controller 连接
```

**6. 你要形成的目录脑图**

看这个最重要：

```
Roblox Studio
DataModel
  ReplicatedStorage
    Framework        <- 共享框架模块，Server/Client 都能读
    Game             <- 当前游戏共享配置
    Packages         <- Wally 第三方包

  ServerScriptService
    Server           <- 服务端代码，只 Server 运行

  StarterPlayer
    StarterPlayerScripts
      Client         <- 客户端代码，每个玩家运行

  StarterGui
    StudioTemplates  <- UI 模板
```

对应 Windows：

```
D:\AI\Codex\ToyBox\RobloxGameFramework
  src
    ReplicatedStorage
      Framework
      Game

    ServerScriptService
      Server

    StarterPlayer
      StarterPlayerScripts
        Client

    StarterGui
      StudioTemplates

  Packages
```

**7. 对初学者最关键的判断**

以后你看到一个文件，先问：

```
它在 Roblox 里会跑在哪一侧？
```

如果在：

```
ServerScriptService
```

它是服务端代码，可以做可信判断。

如果在：

```
StarterPlayerScripts
```

它是客户端代码，只能做输入和表现。

如果在：

```
ReplicatedStorage
```

它是共享代码，Server 和 Client 都能读，所以不要放秘密逻辑。

**8. 本课你只需要掌握这 4 句话**

```
default.project.json 是 Rojo 的同步地图。

$path 表示本地文件夹路径。

$className 表示 Roblox Studio 里的实例类型。

ServerScriptService 可信，StarterPlayerScripts 不可信，ReplicatedStorage 共享。
```

下一课建议讲：

```
Main.server.lua -> ServiceRegistry -> ServiceList
```

也就是服务端到底是怎么从一个入口，把所有 Service 按顺序启动起来的。