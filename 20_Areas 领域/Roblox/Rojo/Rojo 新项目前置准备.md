#### **Rojo 新项目前置准备**

Rojo 不是“装一个插件”这么简单，它是把你的 Roblox 项目变成一条工程生产线：VS Code 写代码，Git 管版本，Rojo 同步到 Studio，Studio 负责运行、调试、摆场景、发布。

完整工作内容分 6 步：

1. **先定开发边界**
   - 代码来源：本地文件 + Git。
   - 场景、美术摆放：Roblox Studio。
   - 服务端逻辑：`ServerScriptService`。
   - 客户端逻辑：`StarterPlayerScripts` / `StarterGui`。
   - 共享配置：`ReplicatedStorage/Shared`。
   - 安全规则：客户端永远不可信。

2. **安装工具**
   - Roblox Studio。
   - VS Code。
   - Git。
   - Rojo CLI / Server。
   - Rojo Studio Plugin。
   - 可选：Rojo VS Code extension。

   我刚核了官方 Rojo v7 文档：Rojo 当前明确分为 Server 和 Roblox Studio plugin 两部分；VS Code extension 方便启动同步，但不会把 `rojo` 加进系统 PATH。官方推荐可用 Rokit 安装 CLI，例如 `rokit add rojo-rbx/rojo`、`rokit install`，插件可用 `rojo plugin install`。来源：[Rojo Installation](https://rojo.space/docs/v7/getting-started/installation/)。

3. **创建项目骨架**
   - 用 `rojo init my-game` 初始化，或手写 `default.project.json`。
   - 建议一开始就建这些目录：

```text
src/
  ReplicatedStorage/
    Shared/
  ServerScriptService/
    Services/
  StarterPlayer/
    StarterPlayerScripts/
      ClientModules/
default.project.json
README.md
.gitignore
```

4. **写 Rojo 映射**
   `default.project.json` 决定本地目录映射到 Roblox 的 DataModel。官方项目文件核心字段是 `name` 和 `tree`，`$path` 是把本地目录挂进 Roblox 实例树，路径相对 `.project.json` 所在目录。来源：[Rojo Project Format](https://rojo.space/docs/v7/project-format/)。

5. **建立最小可运行闭环**
   第一版不要急着做复杂玩法。只做：

```text
服务端启动
-> 客户端启动
-> 创建一个 RemoteEvent
-> 客户端点击按钮
-> 服务端收到请求
-> 服务端返回结果
-> 客户端显示反馈
```

6. **验证同步**
   - 运行 `rojo serve`。
   - 打开 Roblox Studio。
   - 用 Rojo 插件 Connect。
   - 检查文件是否进入正确服务。
   - Play 测一次。
   - 必要时运行 `rojo build -o build.rbxlx` 生成 place 文件。

官方同步规则里，`.server.lua` 会变成 `Script`，`.client.lua` 会变成 `LocalScript`，普通 `.lua` 会变成 `ModuleScript`；目录默认会变成 `Folder`。来源：[Rojo Sync Details](https://rojo.space/docs/v7/sync-details/)。

以后我们按这个节奏来：每课只拆一个真实链路，先让你能解释，再让你动手改。下一课我建议正式追踪你第 4 题里的“领取奖励”链路，从按钮创建位置开始。