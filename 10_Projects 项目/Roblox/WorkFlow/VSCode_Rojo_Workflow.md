# VSCode + Rojo 工作流说明

## 是否必须用 VSCode

不是必须，但建议从现在开始使用。

原因很简单：

```text
Rojo 负责同步
VSCode 负责编辑源码
Roblox Studio 负责场景、Play 测试、发布
```

如果继续在 Studio 里大段改脚本，Rojo 的价值会下降，而且容易出现 Studio 版本和本地源码不一致。

## 推荐工作方式

以后改代码按这个顺序：

```text
1. 用 VSCode 打开 D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit
2. 修改 src 里的 .luau 文件
3. 保存文件
4. Rojo 自动/手动同步到 Roblox Studio
5. 在 Studio 里 Play 测试
6. 测试通过后再继续下一步
```

## VSCode 里重点看哪些目录

```text
src/ReplicatedStorage/Shared
src/ServerScriptService/EatDemoServer.server.luau
src/ServerScriptService/Services
src/StarterPlayer/StarterPlayerScripts/EatDemoClient.client.luau
src/StarterPlayer/StarterPlayerScripts/ClientModules
```

## Studio 以后主要做什么

Studio 主要负责：

```text
1. 场景、地图、模型、UI 可视化检查
2. Play 测试
3. Output 报错观察
4. 发布到 Roblox
5. 配置权限、资产、Developer Product
```

不建议在 Studio 里做：

```text
1. 大段改脚本
2. 同时改多个 ModuleScript
3. 临时复制旧代码覆盖新代码
```

## 推荐安装的 VSCode 扩展

优先级从高到低：

| 扩展 | 用途 |
|---|---|
| Luau Language Server | Luau 语法提示、类型提示、跳转定义 |
| Rojo | Rojo 项目辅助 |
| StyLua | Lua/Luau 格式化 |

如果你暂时不想装扩展，也可以先只用 VSCode 当普通文本编辑器。

## 文件修改规则

| 要改什么 | 优先改哪里 |
|---|---|
| 服务端吃食物逻辑 | `src/ServerScriptService/Services/EatService.luau` |
| 玩家数据 / leaderstats | `src/ServerScriptService/Services/DataService.luau` |
| Speed / Size / Auto 服务端 | `src/ServerScriptService/Services/ShopService.luau` |
| Bag / FoodCore 服务端 | `src/ServerScriptService/Services/InventoryService.luau` |
| Reward 服务端 | `src/ServerScriptService/Services/RewardService.luau` |
| UI 样式和布局 | `src/StarterPlayer/StarterPlayerScripts/ClientModules/UIController.luau` |
| 吃食物扫描 | `src/StarterPlayer/StarterPlayerScripts/ClientModules/ScanController.luau` |
| 体型变化 | `src/StarterPlayer/StarterPlayerScripts/ClientModules/CharacterScaleController.luau` |
| 音效/特效反馈 | `src/StarterPlayer/StarterPlayerScripts/ClientModules/FeedbackController.luau` |

## 当前阶段不要做

```text
不要马上引入 Knit
不要马上接 Robux
不要直接删除现有 Remote
不要把旧项目无权限 AssetId 重新塞回来
```

## 判断 VSCode + Rojo 工作流是否正常

做一个小测试即可：

```text
1. 在 VSCode 改一个不会影响玩法的注释
2. 保存
3. Studio Rojo 面板出现同步变化
4. Accept
5. Play 后功能正常
```

## Studio 提示 Couldn't connect 怎么办

如果 Roblox Studio 的 Rojo 插件弹出：

```text
Couldn't connect to the Rojo server.
Make sure the server is running - use `rojo serve` to run it!
```

意思是：

```text
Studio 插件打开了，但本地 Rojo server 没有启动。
```

解决步骤：

```text
1. 打开 PowerShell
2. 进入项目目录
   cd D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit

3. 启动 Rojo server
   rojo serve default.project.json --address 127.0.0.1 --port 34872

4. 保持这个 PowerShell 窗口不要关闭
5. 回到 Roblox Studio
6. Rojo 插件里点 Connect
```

如果是 Codex 帮你启动，看到这句就说明启动成功：

```text
Rojo server listening:
Address: localhost
Port: 34872
```

当前固定连接地址：

```text
localhost:34872
```

注意：

```text
Rojo 插件不是 server。
PowerShell 里跑的 rojo serve 才是 server。
Studio 插件只是连接这个 server。
```

## 当前项目不是双向同步

当前项目的规则是：

```text
VSCode / 本地 Rojo 源码 = 代码源头
Roblox Studio = 运行、测试、场景编辑、发布
```

不要把当前工作流理解成：

```text
VSCode 改代码会同步到 Studio
Studio 改代码也会同步回 VSCode
```

我们现在不依赖双向同步。

原因：

```text
1. Rojo 的稳定工作流是本地文件同步到 Studio
2. Studio 里的脚本修改不一定可靠写回本地文件
3. Rojo 插件里的 Two-Way Sync 标的是 UNSTABLE，不适合当前项目
4. 双向同步一旦冲突，很容易出现谁覆盖谁的问题
```

所以当前明确规定：

```text
映射目录里的脚本，不在 Studio 里改。
要改脚本，就去 VSCode 改本地 .luau 文件。
```

## 如果你不小心在 Studio 里改了脚本

不要继续让 Rojo 自动同步，也不要马上让我继续改本地代码。

按这个处理：

```text
1. 先停下来
2. 不要点新的 Accept
3. 告诉我：我刚才在 Studio 里改了哪个脚本
4. 把 Studio 里改过的代码复制出来，或截图给我
5. 我把这次改动补回 VSCode 的本地 .luau 文件
6. 再让 Rojo 从本地同步回 Studio
```

如果你在 Studio 里改了：

```text
ServerScriptService/EatDemoServer
```

本地对应文件是：

```text
D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\src\ServerScriptService\EatDemoServer.server.luau
```

如果你在 Studio 里改了：

```text
ReplicatedStorage/Shared/EatDemoConfig
```

本地对应文件是：

```text
D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\src\ReplicatedStorage\Shared\EatDemoConfig.luau
```

如果你在 Studio 里改了：

```text
StarterPlayer/StarterPlayerScripts/ClientModules/UIController
```

本地对应文件是：

```text
D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\src\StarterPlayer\StarterPlayerScripts\ClientModules\UIController.luau
```

## 为什么 Studio 改脚本会危险

例子：

```text
1. 你在 Studio 里改了 EatDemoServer
2. VSCode 里的 EatDemoServer.server.luau 还是旧版本
3. 我后面在 VSCode 里继续改 EatDemoServer.server.luau
4. Rojo 同步到 Studio
5. Studio 里你刚才手改的内容可能被覆盖
```

所以后面判断标准很简单：

```text
脚本代码：VSCode 改
场景地图：Studio 改
测试运行：Studio Play
Output 报错：Studio 看
```

## Rojo 的 Two-Way Sync 要不要开

当前不要开。

你截图里 Rojo 设置有类似：

```text
UNSTABLE Two-Way Sync
```

意思是：

```text
这个功能还不稳定。
```

当前项目先不使用它。

等你熟悉 Rojo 后，如果确实要试“双向同步”，也要先新建一个测试分支或测试项目，不要直接在当前 Demo 主流程里开。

## 你现在最容易混淆的点

一句话版本：

```text
VSCode 改本地源码，Rojo 把本地源码同步到 Studio，Studio 负责测试和编辑场景。
```

更准确地说：

| 问题 | 结论 |
|---|---|
| 后续脚本代码在哪里改？ | 优先在 VSCode 里改 `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\src` |
| VSCode 新建 Script 会不会进 Studio？ | 会，但前提是文件建在 Rojo 已映射的目录里 |
| VSCode 保存后会不会自动同步？ | Rojo server 正在运行、Studio Rojo 插件已连接时，会同步；有时 Studio 会弹出变更列表让你 Accept |
| Studio 里改脚本会不会自动回到 VSCode？ | 不会。当前工作流是本地文件到 Studio，基本不要反向改大段脚本 |
| Workspace 会不会同步？ | 现在不会，因为 `default.project.json` 没有映射 Workspace |
| 是不是只同步 `src`？ | 当前主要同步 `src`，另外 `Packages` 也映射到了 `ReplicatedStorage/Packages` |

当前 Rojo 配置只同步这些位置：

```text
src/ReplicatedStorage/Shared
→ Studio: ReplicatedStorage/Shared

Packages
→ Studio: ReplicatedStorage/Packages

src/ServerScriptService
→ Studio: ServerScriptService

src/StarterPlayer/StarterPlayerScripts
→ Studio: StarterPlayer/StarterPlayerScripts
```

所以你以后新建脚本时按这个规则：

```text
服务端功能模块
→ 新建在 src/ServerScriptService/Services

客户端功能模块
→ 新建在 src/StarterPlayer/StarterPlayerScripts/ClientModules

客户端入口脚本
→ 改 src/StarterPlayer/StarterPlayerScripts/EatDemoClient.client.luau

服务端入口脚本
→ 改 src/ServerScriptService/EatDemoServer.server.luau

双端共享配置
→ 新建或修改 src/ReplicatedStorage/Shared
```

Workspace 里的地图、模型、Part、装饰物，当前仍然在 Studio 里做。
如果以后要让 Workspace 也由 VSCode/Rojo 管理，需要单独在 `default.project.json` 里加映射；现在先不做，避免 Rojo 接管场景时误删或覆盖 Studio 里的对象。
