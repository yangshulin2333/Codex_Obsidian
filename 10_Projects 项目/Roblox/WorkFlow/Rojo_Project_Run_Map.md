# Rojo 项目是怎么运行的

## 一句话结论

```text
Roblox Studio 运行游戏；VSCode 编辑本地源码；Rojo 按 default.project.json 把本地源码同步进 Studio。
```

不要把 VSCode、Rojo、Studio 理解成同一个东西。

| 工具 | 负责什么 |
|---|---|
| VSCode | 编辑本地 `.luau` 源码文件 |
| Rojo server | 读取 `default.project.json`，把本地文件变成 Roblox Studio 里的对象 |
| Roblox Studio | 真正运行游戏、Play 测试、编辑场景、发布 |

## default.project.json 是什么

`default.project.json` 是 Rojo 的同步地图。

它告诉 Rojo：

```text
本地哪个文件夹
→
同步到 Studio 里的哪个服务/目录
```

当前配置：

```json
{
  "name": "EatDemoReplica",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "Shared": {
        "$path": "src/ReplicatedStorage/Shared"
      },
      "Packages": {
        "$path": "Packages"
      }
    },
    "ServerScriptService": {
      "$path": "src/ServerScriptService"
    },
    "StarterPlayer": {
      "StarterPlayerScripts": {
        "$path": "src/StarterPlayer/StarterPlayerScripts"
      }
    }
  }
}
```

逐行翻译：

| 配置 | 意思 |
|---|---|
| `"name": "EatDemoReplica"` | Rojo 项目名字，只是显示用 |
| `"$className": "DataModel"` | Studio 里的整个游戏根对象 |
| `"ReplicatedStorage"` | Studio 的 `ReplicatedStorage` 服务 |
| `"Shared": { "$path": "src/ReplicatedStorage/Shared" }` | 本地 `src/ReplicatedStorage/Shared` 同步到 Studio 的 `ReplicatedStorage/Shared` |
| `"Packages": { "$path": "Packages" }` | 本地 `Packages` 同步到 Studio 的 `ReplicatedStorage/Packages` |
| `"ServerScriptService": { "$path": "src/ServerScriptService" }` | 本地 `src/ServerScriptService` 同步到 Studio 的 `ServerScriptService` |
| `"StarterPlayerScripts": { "$path": "src/StarterPlayer/StarterPlayerScripts" }` | 本地客户端脚本同步到 Studio 的 `StarterPlayer/StarterPlayerScripts` |

## 什么会同步，什么不会同步

当前会同步：

```text
D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\src\ReplicatedStorage\Shared
→ ReplicatedStorage/Shared

D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\Packages
→ ReplicatedStorage/Packages

D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\src\ServerScriptService
→ ServerScriptService

D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\src\StarterPlayer\StarterPlayerScripts
→ StarterPlayer/StarterPlayerScripts
```

当前不会同步：

```text
src/Workspace
src/StarterGui
src/ReplicatedStorage 下面没有被映射的散文件
Workspace 里的地图、Part、模型、装饰物
```

重点：

```text
不是放进 src 就一定同步。
只有 default.project.json 里 $path 指到的目录才会同步。
```

例如：

```text
src/ReplicatedStorage/test.luau
```

这个文件当前不会同步，因为配置里没有：

```json
"ReplicatedStorage": {
  "$path": "src/ReplicatedStorage"
}
```

现在只映射了：

```text
src/ReplicatedStorage/Shared
```

所以共享模块要放这里：

```text
src/ReplicatedStorage/Shared/TestModule.luau
```

不要放这里：

```text
src/ReplicatedStorage/TestModule.luau
```

## 文件后缀怎么变成 Roblox 脚本对象

Rojo 会根据文件名后缀判断 Studio 里创建什么对象。

| 本地文件名 | Studio 里变成什么 |
|---|---|
| `EatDemoServer.server.luau` | `Script` |
| `EatDemoClient.client.luau` | `LocalScript` |
| `DataService.luau` | `ModuleScript` |

所以：

```text
.server.luau = 服务端 Script
.client.luau = 客户端 LocalScript
.luau = ModuleScript
```

## 游戏 Play 时是怎么跑起来的

Roblox 不是从 `default.project.json` 运行游戏。

真正运行游戏的是 Studio 里的对象。

流程是：

```text
1. Rojo 把本地文件同步进 Studio
2. Studio 里出现 Script / LocalScript / ModuleScript
3. 你点 Play
4. Roblox 自动运行 ServerScriptService 里的 Script
5. Roblox 自动把 StarterPlayerScripts 里的 LocalScript 复制到玩家 PlayerScripts 并运行
6. ModuleScript 不会自己运行，只有被 require() 时才运行
```

当前服务端入口：

```text
src/ServerScriptService/EatDemoServer.server.luau
→ Studio: ServerScriptService/EatDemoServer
```

它负责：

```text
读取 Shared 配置
加载 Services 里的服务模块
创建 RemoteEvent
监听客户端请求
把请求分发给 EatService / ShopService / InventoryService / RewardService
```

当前客户端入口：

```text
src/StarterPlayer/StarterPlayerScripts/EatDemoClient.client.luau
→ Studio: StarterPlayer/StarterPlayerScripts/EatDemoClient
```

它负责：

```text
读取 Shared 配置
加载 ClientModules 里的客户端模块
创建 UI
扫描食物
监听按钮点击
向服务端 FireServer
接收服务端返回结果并刷新 UI / 音效 / 特效 / 体型
```

## 当前项目的运行链路

以吃食物为例：

```text
玩家进入游戏
→ EatDemoServer 自动启动
→ EatDemoServer 加载 EatService
→ EatService 生成食物
→ EatDemoClient 自动启动
→ EatDemoClient 加载 ScanController
→ ScanController 扫描附近食物
→ 靠近食物后客户端 FireServer
→ EatDemoServer 收到请求
→ EatService 校验距离和食物状态
→ DataService 修改 Muscle / Money / FoodCore
→ EatDemoServer FireClient 返回结果
→ EatDemoClient 收到结果
→ UIController 刷新 UI
→ FeedbackController 播放音效/特效
→ CharacterScaleController 更新角色体型
```

## 以后新建脚本该放哪里

| 你要做什么 | 新建位置 |
|---|---|
| 服务端玩法逻辑 | `src/ServerScriptService/Services` |
| 客户端 UI / 按钮 / 扫描 / 特效逻辑 | `src/StarterPlayer/StarterPlayerScripts/ClientModules` |
| 双端共享配置 | `src/ReplicatedStorage/Shared` |
| 服务端入口总控 | 修改 `src/ServerScriptService/EatDemoServer.server.luau` |
| 客户端入口总控 | 修改 `src/StarterPlayer/StarterPlayerScripts/EatDemoClient.client.luau` |
| 地图、模型、Part、场景对象 | 当前仍然在 Roblox Studio 里做 |

## 为什么现在不把 Workspace 也同步

因为 Workspace 是场景。

如果现在直接让 Rojo 接管 Workspace，风险是：

```text
Studio 里的场景对象可能被 Rojo 配置覆盖
手动摆好的模型可能被删除
地图和脚本同时变动时更难排查问题
```

所以当前策略是：

```text
代码交给 Rojo
场景先留在 Studio
```

后面项目稳定后，如果确实需要把地图也版本化，再单独设计 Workspace 的 Rojo 结构。

## 判断一个文件会不会同步

用这个规则：

```text
1. 看这个文件是不是在 Replica_Demo_RojoKnit 目录里
2. 看它是不是在 default.project.json 的 $path 目录下面
3. 如果是，会同步
4. 如果不是，不会同步
```

例子：

```text
src/ServerScriptService/Services/TestService.luau
```

会同步，因为 `src/ServerScriptService` 被映射了。

```text
src/ReplicatedStorage/Shared/TestConfig.luau
```

会同步，因为 `src/ReplicatedStorage/Shared` 被映射了。

```text
src/ReplicatedStorage/test.luau
```

不会同步，因为 `src/ReplicatedStorage` 没有整体映射。

```text
src/Workspace/TestPart.luau
```

不会同步，因为 Workspace 当前没有映射。

