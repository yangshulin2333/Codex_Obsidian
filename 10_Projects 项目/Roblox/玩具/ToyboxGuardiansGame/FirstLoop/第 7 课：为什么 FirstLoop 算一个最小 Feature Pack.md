
先给结论：

```
FirstLoop 算 Feature Pack。
但它是“最小调试版 Feature Pack”，不是正式玩法版 Feature Pack。
```

它的目的不是做完整游戏玩法，而是证明：

```
UI -> Client -> Remote -> Server -> DataService -> 返回 -> UI刷新
```

这条闭环已经能跑通。

**1. Feature Pack 到底是什么**

你可以先把 `Feature Pack` 翻译成：

```
功能包
```

但它不是单纯一个文件夹，也不是必须能完全独立运行的插件。

在我们这套框架里，Feature Pack 更准确的意思是：

```
围绕一个具体玩法目标，整理出来的一组代码、配置、UI、数据字段、Remote合同、素材合同、验收规则。
```

也就是说，它是一种“功能交付单位”。

比如：

```
FirstLoop Feature Pack
CombatTrainingEnemy Feature Pack
Inventory Feature Pack
BossReward Feature Pack
ToyUpgrade Feature Pack
```

每个 Feature Pack 都应该能回答：

```
玩家看到什么？
Client 做什么？
Server 做什么？
用哪些 Remote？
读写哪些数据？
用哪些 UI？
用哪些素材？
怎么验收？
哪些内容明确不做？
```

**2. Feature Pack 不是“完全脱离框架单独运行”**

你之前问过一个关键问题：

```
既然是 Feature Pack，是不是可以单独运行，然后再接入框架？
```

答案要分清楚：

```
可以单独设计、单独实现、单独验收。
但通常不能脱离框架完全运行。
```

因为 Feature Pack 会依赖框架提供的东西：

```
ServiceRegistry
ControllerRegistry
NetService
DataService
UIController
Logger
DataSchema
```

所以它不是一个完全独立游戏。  
它更像一个“插到框架上的功能模块”。

正确理解是：

```
框架 = 提供通用能力
Feature Pack = 使用这些通用能力完成某个玩法
```

**3. FirstLoop 为什么算最小 Feature Pack**

FirstLoop 已经包含 Feature Pack 的核心要素。

Feature Card 在这里：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansDemo\\docs\\feature-cards\\001_FirstLoop.md](D:/AI/Codex/ToyBox/ToyboxGuardiansDemo/docs/feature-cards/001_FirstLoop.md)

它包含：

|要素|FirstLoop 有没有|
|---|---|
|功能目标|有：第一个可信数据闭环|
|玩家可见内容|有：小齿轮按钮和数量|
|Client 入口|有：`FirstLoopController`|
|Server 入口|有：`FirstLoopService`|
|Remote 合同|有：`FirstLoop.GetSnapshot` / `FirstLoop.GrantSmallGear`|
|Data 字段|有：`Resources.SmallGear` / `TutorialFlags.GainedSmallGear`|
|UI Contract|有：按钮、数量文本、错误文本等节点|
|Asset Contract|有：小齿轮图标占位素材|
|验收规则|有：F01-F05|
|明确不做什么|有：不做战斗、不做 ProfileStore、不做正式 HUD|

所以它满足 Feature Pack 的基本定义。

**4. 但 FirstLoop 为什么只是“最小版”**

因为它现在不是正式玩法。

当前 FirstLoop 的玩家行为是：

```
点击调试按钮
-> Server 增加 SmallGear
-> UI 显示数量
```

而正式 RPG 玩法应该是：

```
攻击怪物
-> Server 判定命中
-> 怪物死亡
-> 掉落材料
-> 玩家拾取
-> DataService 写入资源
-> UI 刷新
```

所以 FirstLoop 只是先验证最小闭环：

```
按钮代替战斗
固定 +1 代替掉落规则
Debug UI 代替正式 HUD
内存 Profile 代替 ProfileStore
```

它不是最终游戏内容，但它是后续玩法的基础验证。

**5. “接入框架”到底做了什么**

FirstLoop 接入框架，主要做了几件事：

第一，服务端接入：

```
FirstLoopService 加进 ServiceList
ServiceRegistry 启动时会 Init / Start 它
```

第二，客户端接入：

```
FirstLoopController 加进 ControllerList
ControllerRegistry 启动时会 Init / Start 它
```

第三，网络接入：

```
FirstLoopService 通过 NetService 注册 RemoteFunction
FirstLoopController 通过 NetClient.Request 调用 RemoteFunction
```

第四，数据接入：

```
FirstLoopService 不直接乱改数据
它通过 DataService:UpdateProfile 修改 Resources.SmallGear
```

第五，UI 接入：

```
FirstLoopController 通过 UIController 挂载 FirstLoopDebugGui
再按 UI Contract 找按钮和文本节点
```

这就叫“接入框架”。

不是把代码复制进去就完事，而是让它进入框架提供的启动、通信、数据、UI 管理流程。

**6. 解耦到底体现在哪里**

你之前质疑得对：

```
FirstLoopController 里现在既有 UI 节点绑定，也有请求逻辑，也有 UI刷新。
这是不是不够解耦？
```

答案是：

```
是的，它不是最理想的正式结构。
但作为 Debug FirstLoop，可以接受。
```

现在已经做到的解耦是这些：

```
Controller 不直接创建 RemoteFunction，而是用 NetClient。
Service 不直接创建 RemoteFunction，而是用 NetService。
Service 不直接管理存档底层，而是用 DataService。
UI 不再纯代码生成，而是通过 Studio Template + UI Contract。
素材 ID 不直接散落在 UI 里，而是走 AssetCatalog / AssetResolver。
```

还没完全做到的解耦是：

```
FirstLoopController 里还混着 UI 表现和客户端流程。
```

正式玩法更推荐拆成：

```
FirstLoopController
负责流程编排

FirstLoopView
负责 UI 显示和按钮绑定

FirstLoopClientApi
负责请求服务器

FirstLoopService
负责服务器规则

DataService
负责数据读写
```

但现在我们先用最小版本学习闭环，是合理的。  
等你掌握了这条链，再拆分会更容易理解。

**7. Feature Card 和 Feature Pack 的关系**

这里很容易混。

```
Feature Pack = 要实现的功能包
Feature Card = 这个功能包的说明书和验收单
```

也就是说：

```
FirstLoop 是 Feature Pack
001_FirstLoop.md 是它的 Feature Card
```

Feature Card 不只是文档，它是给人和 Codex 都看的：

```
人看：知道这个功能要做什么
Codex 看：知道边界、文件、Remote、数据、验收标准
```

所以我们后续每做一个重要玩法，都应该先有 Feature Card。

**8. 一个功能包完整流程应该是什么**

以后做正式功能，流程应该是：

```
1. 从 GDD 拆出一个 Feature Pack
2. 写 Feature Card
3. 明确 UI Contract / Asset Contract / Data 字段 / Remote 合同
4. 你确认 UI 效果图或 Studio 草稿
5. Codex 实现代码
6. Rojo 同步到 Studio
7. Studio Play 验收
8. 记录问题和修复
9. 更新 Feature Card 和交接文档
10. 再进入下一个 Feature Pack
```

这就是你之前强调的：

```
做完一步
校验一步
回看计划清单
再进入下一步
```

**9. FirstLoop 当前属于哪种状态**

现在 FirstLoop 的状态可以这样判断：

```
已完成最小闭环。
已接入框架。
已通过 Studio Play 基础验证。
可以作为学习样例。
可以作为后续 CombatTrainingEnemy 的前置基础。
但还不是正式游戏玩法。
```

所以它的定位是：

```
技术验证型 Feature Pack
```

不是：

```
正式玩法型 Feature Pack
```

**10. 这一课最小掌握结论**

你只需要记住这几句话：

```
Feature Pack 是一个具体功能的交付单位。
它不一定是一个独立文件夹，也不一定能脱离框架运行。
它必须有清楚的边界、代码入口、数据字段、Remote合同、UI合同、素材合同和验收规则。
FirstLoop 算 Feature Pack，因为它完整跑通了 UI 到数据的闭环。
但 FirstLoop 是最小调试版，不是正式战斗玩法。
```

再短一点：

```
框架负责通用能力。
Feature Pack 负责具体玩法。
Feature Card 负责把这个玩法说清楚。
```

下一课第 8 课：**FirstLoop 涉及的 Luau 语法点**。  
这节会专门讲你看代码时容易卡住的语法，比如 `:`、`.`、`self`、`local`、`return {}`、匿名函数、`or {}`、`pcall`、`type`、`pairs/ipairs`、`--!strict`。