---
type: project
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-07-17
updated: 2026-07-26
---

# YanzoFrame 框架优化候选记录

## 一句话说明

在开发 `YanzoFrame_V2_JumpGame` 时记录真实暴露的问题，再对照 Hotpot 商业框架的处理方式，最后决定是否回到 `YanzoFrame_V1_StorageModule` 单独优化。

## 三条并行主线

1. **真实游戏验证**：在 `YanzoFrame_V2_JumpGame` 中先做出可见、可玩的功能。
2. **自研框架演进**：只有被真实项目证明为通用问题，才进入 `YanzoFrame_V1_StorageModule`。
3. **Hotpot 对照学习**：按当前问题定点阅读 KaPibala 中的 Hotpot 实现，学习成熟边界和失败处理，不整套照搬。

Hotpot 参考项目：

`D:\AI\Codex\Codex_Obsidian\10_Projects 项目\Roblox\1巅峰进化项目交接\KaPibala`

## 候选进入框架的流程

```text
JumpGame 暴露真实问题
→ 记录复现证据和影响
→ 定点查找 Hotpot 对应实现
→ 比较两种方案的复杂度与适用边界
→ 判断是否具有至少两个真实使用场景
→ 回到 YanzoFrame_V1_StorageModule 单独修改和验证
→ 再在 JumpGame 中回归
```

## 当前候选

### YF-001 Logger 缺少业务调用位置

- **状态**：已验证；采用“日志文本显示调用方路径与行号”的轻量方案。
- **真实现象**：`Logger.Debug`、`Logger.Info`、`Logger.Warn` 最终在 `Logger.lua` 内调用 `print` 或 `warn`，Studio Output 的源码链接只能定位到 `Logger.lua`。
- **影响**：日志很多时，无法直接跳到真正发出日志的业务 Service 或 Controller，排错效率下降。
- **当前证据**：JumpGame 启动及训练日志均显示 `Logger:82`、`Logger:90` 等 Logger 内部行号。
- **Hotpot 对照项**：后续只在处理日志系统时，检查 KaPibala 的 Logger、错误包装和调用栈策略；未阅读前不假设 Hotpot 已解决。
- **目标仓库**：若确认属于通用框架问题，只修改 `YanzoFrame_V1_StorageModule`，不在 JumpGame 中顺手重构。
- **验收结果（2026-07-26）**：`Logger.Debug`、`Logger.Info`、`Logger.Warn` 通过 `debug.info(2, "sl")` 在日志文本末尾显示直接调用方的 Roblox 脚本路径与行号；Studio Play 已验证 `ServiceRegistry:79`、`ResourceService:47` 等真实业务位置。原有调用 API、日志级别与 scope 保持不变。
- **已知边界**：Studio Output 的默认可点击链接仍指向实际执行 `print/warn` 的 `Logger.lua`。这是普通输出 API 的来源机制，不能只在 `Logger.lua` 内改写为调用方；若未来必须让普通日志的默认点击链接直达业务脚本，需把 `print/warn` 移至每个调用方执行，属于 API 与全量调用点迁移，当前不做。
- **Error 说明**：`Logger.Error(..., 2)` 保持原样；`error` 属于异常机制，可通过层级参数使错误堆栈定位调用方。

### YF-002 Rokit 工具被系统 PATH 中的同名工具覆盖

- **状态**：已验证；验证脚本已固定使用 Rokit 工具入口。
- **真实现象**：项目 `rokit.toml` 锁定 `JohnnyMorganz/stylua@2.4.1`，但直接执行 `stylua` 时实际命中 `C:\Users\14176\.cargo\bin\stylua.exe`。
- **影响**：Cargo 路径下的 StyLua 构建不能解析项目中的 Luau 类型注解，导致 `stylua --check src` 和 `Validate-ModuleBase.ps1` 大量误报语法错误；Rokit 路径下的 StyLua 可以识别 Luau。
- **当前证据**：`Get-Command stylua` 指向 Cargo；`C:\Users\14176\.rokit\bin\stylua.exe --help` 明确包含 `Luau` 语法选项。
- **Hotpot 对照项**：后续检查 KaPibala 的 Makefile、工具安装与命令入口，观察其如何保证团队使用同一套版本和执行路径。
- **目标范围**：优先作为项目脚手架、验证脚本或本机工具链配置问题处理；未证明是运行时通用能力前，不修改 YanzoFrame 核心模块。
- **实现结果（2026-07-26）**：`Validate-ModuleBase.ps1` 不再调用 Windows PATH 中的裸命令，改为固定调用 `$env:USERPROFILE\.rokit\bin` 中的 `wally`、`stylua`、`selene`、`rojo`；README 和项目 AGENTS 规则同步为相同入口。工具缺失时会中文提示先执行 `rokit install`。
- **验收结果（2026-07-26）**：系统裸 `stylua` 仍明确指向 `C:\Users\14176\.cargo\bin\stylua.exe`，但执行 `Validate-ModuleBase.ps1` 输出的四个实际工具路径均为 `.rokit\bin`，并完成 Wally、StyLua、Selene 和 Rojo Build 检查，最终输出 `MODULE_BASE_CHECK_OK`。
- **边界**：本项只优化 YanzoFrame 的工程工具层可复现性；不修改 Windows 全局 PATH、Rojo 映射、Studio 场景或任何运行时代码。

### YF-003 StorageService 缺少统一的数据就绪等待入口

- **状态**：已完成并验证（2026-07-26）；JumpGame 暂停，不在本项中迁移现有业务服务。
- **真实现象**：`StorageService` 当前只提供 `IsPlayerDataReady(player)`；`SpeedService` 初始化持久化 Speed 前，需要自行循环检查数据是否已经打开。
- **影响**：未来金币、胜利数、装备等服务可能重复编写等待、玩家离开退出和超时处理，容易产生不同的失败行为。
- **当前证据**：`StorageService:Start()` 通过 `task.spawn` 异步打开档案，而 `SpeedService` 的 `PlayerAdded` 初始化不能假设数据已经就绪。2026-07-20 新增 `WinService:_waitForPlayerData(player)`，已形成第二处相同的轮询、玩家离开退出与 `0.1` 秒等待代码。
- **Hotpot 对照项**：后续检查 KaPibala 的登录流程、`DataBaseManager`、`Server_PlayerDataComponent` 或玩家数据初始化链，确认它如何通知业务模块数据已准备完成。
- **实现结果（2026-07-26）**：在 `StorageService` 增加服务器接口 `WaitForPlayerData(player, timeoutSeconds?)`；内部保留最小轮询，但将状态跟踪和失败语义收回存储服务。返回值统一为 `true, "READY"`，或 `false` 加 `PLAYER_LEFT`、`DATA_LOAD_FAILED`、`DATA_SESSION_ENDED`、`DATA_READY_TIMEOUT`。`IsPlayerDataReady(player)` 保持为不等待的即时检查，未改变现有调用方行为。
- **验收结果（2026-07-26）**：Rokit 完整检查输出 `MODULE_BASE_CHECK_OK`；Studio Play 中 `StorageService` 以 ProfileStore 正常启动并打开当前玩家档案。隔离的运行时探针覆盖 `READY`、超时、加载失败、会话中断、玩家离开五个结果分支，均返回约定结果；探针已销毁，未读写真实玩家数据。
- **边界**：这是服务器存档生命周期 API，不属于 `Util`；不新增 Remote、不修改客户端、不将 JumpGame 业务逻辑迁入 V1。本项只提供接口，现有游戏服务何时迁移由其各自的业务改造单独验收。

### YF-004 Controller 启动可能被未就绪的 Studio UI 阻塞

- **状态**：已记录，先确认 `GameHUD` 的 Studio 运行时来源，不立即修改 V1。
- **真实现象**：`JumpController:Start()` 无期限等待 `PlayerGui.GameHUD`；约 5 秒后 Studio 输出 `Infinite yield possible`。当前 `ControllerRegistry` 又按 `ControllerList` 同步串行调用 `Start()`，因此 `SpeedController` 和 `TrainingController` 直到 `GameHUD` 后来出现才继续启动。
- **影响**：一个 Controller 缺少非核心表现对象，就可能延迟全部后续 Controller；当前跳跃输入绑定也位于 HUD 等待之后，因此 HUD 延迟还会连带延迟玩法输入。
- **当前证据**：日志在 `18:44:13` 报告 `JumpController:112` 等待 `GameHUD`，直到 `18:44:20` 才继续启动 `SpeedController` 和 `TrainingController`。当前 `default.project.json` 没有映射 `StarterGui`，仓库 `src` 中也没有 `GameHUD` 模板或创建代码，因此还需在 Studio 中确认它是延迟复制、放错父级，还是只存在于运行态。
- **Hotpot 对照项**：后续定点检查 KaPibala 客户端启动链和 UI 初始化完成通知，确认业务模块如何等待必需 UI，以及单个 UI 模块失败时是否会阻塞其他模块。
- **当前处理顺序**：先在 JumpGame 明确 `StarterGui.GameHUD` 到 `PlayerGui.GameHUD` 的对象来源与出现时机；只有多个 Controller 或第二个项目再次暴露相同问题，才评估 V1 的 UI 就绪合同或 Controller 启动隔离。
- **验收方向**：HUD 正常存在时无无限等待警告；HUD 缺失时能在有限时间内给出明确错误；非 HUD Controller 不被永久阻塞；启动顺序仍然可预测。
- **风险**：不能简单把所有 `Controller:Start()` 改成并行执行，否则会掩盖真实依赖并破坏确定性启动顺序。

### YF-005 通用开发者面板与安全的数据重置入口

- **状态**：已完成最小可用版本：V1 已提供“初始化当前玩家整档数据”的服务器安全入口，以及仅在 Studio Play 显示的最小开发者面板和二次确认交互。各游戏的 Speed、Wins 等业务调试快捷按钮不属于此框架项。
- **真实现象**：JumpGame 的持久化 `Speed` 已达到较高数值，`WalkSpeed` 长期命中上限，无法方便地重复验证初始成长过程，因此需要开发者面板重置测试数据。
- **候选边界**：框架层只负责开发者权限检查、请求入口、操作结果和审计日志，并可提供“重置当前玩家全部个人数据”这类通用能力；`ResetSpeed`、增加胜利数等具体游戏动作仍由 Game Service 持有，框架不得反向依赖 `SpeedService`。
- **已实现入口**：`DeveloperService` 注册 `Developer.ResetMyData`；服务端只接受空表载荷、只操作请求者本人、先校验开发环境/白名单权限，再调用 `StorageService:ResetPlayerData(player)`。后者以 `StorageConfig.DefaultData` 的深拷贝覆盖整档，成功后让玩家重新进入游戏，使业务缓存、Player Attribute、HUD 与派生角色状态统一走正常初始化链路。
- **权限默认值**：Studio Play 可由 `DeveloperConfig.AllowDataResetInStudio` 开启；正式服务器默认因空白 `AllowedUserIds` 拒绝。客户端即使知道 Remote 名称，也不能指定目标玩家或传入任意数据。
- **已验证**：V1 静态检查通过（StyLua、Selene、Rojo Build）；Studio Play 已确认 `DeveloperService` 启动并注册 `Developer.ResetMyData`；隔离探针验证默认档不复用引用、非法载荷被拒绝、合法请求仅调用一次存储重置并要求重新进入。未自动调用真实 Remote，因此未改动现有持久化档案。
- **Hotpot 对照项**：后续定点检查 KaPibala 是否存在开发者命令、GM 面板、权限校验、数据重置和操作审计实现；未阅读源码前不推断其能力。
- **客户端入口**：`ReplicatedStorage.Resources.UI.DeveloperPanel` 是唯一模板；`DeveloperPanelController` 只在 Studio Play 中克隆一份至 `PlayerGui`。点击“初始化全部数据”后必须再次确认，才会向服务器发送空载荷请求。UI 二次确认仅是防误触，服务器权限校验才是安全边界。
- **风险**：重新进入是当前最简单且确定的全链路一致性方案；若未来要求“不退出游戏热重置”，必须先为每个业务 Service 定义缓存、Attribute、HUD 与角色派生状态的统一刷新合同。

### YF-006 UI 从 StarterGui 草稿迁移到 Resource/UI 模板

- **状态**：已完成首个最小迁移：`DeveloperPanel` 已由 `StarterGui` 草稿迁移为 Rojo 管理的 `ReplicatedStorage.Resources.UI` 模板。
- **真实现象**：当前 JumpGame 直接在 `StarterGui` 中制作并运行 UI；Hotpot 项目截图显示完成后的 UI 资源集中放在 `ReplicatedStorage.Resource.ui`，运行时再由客户端逻辑使用。
- **已实现工作流**：可在 Studio 中先制作并验收可见布局；验收后固化为 `Resources/UI/*.model.json` 模板；运行时由对应 Controller 克隆到 `PlayerGui`。只有一个模板时不引入统一 UI 管理器；框架自带 UI 与具体游戏 UI 必须使用不同所有权目录。
- **当前证据**：`ReplicatedStorage.Resources.UI.DeveloperPanel` 已在 Studio Edit 中存在且默认 `Enabled = false`；`StarterGui` 已无同名 GUI。两次 Studio Play 均由 `DeveloperPanelController` 在 `PlayerGui` 创建恰好一份运行时副本，二次确认、折叠和展开交互正常。
- **Hotpot 对照项**：后续确认其模板克隆、缓存、销毁、重复打开和玩家重生处理链，而不是只模仿文件夹名称。
- **已验收**：模板只有一个权威来源；运行时 `PlayerGui` 来源可追踪；Stop 后再次 Play 不会重复克隆；缺失模板时 Controller 会给出明确错误；Studio Edit 可直接检查模板层级。
- **风险**：如果 `StarterGui` 和 Resource/UI 同时保留同一份 GUI，会产生重复界面和来源不明；迁移规则必须包含“验证后删除旧草稿”。

### YF-007 统一 UI 控制器与每个 GUI 独立控制模块的分工

- **状态**：已记录；至少完成 DeveloperPanel 和第二个复杂 GUI 后再判断是否通用化。
- **真实现象**：Hotpot 除全局客户端框架外，还在 `Script/Client/Object/Gui` 下为各 GUI 提供独立控制模块；JumpGame 当前主要由 Controller 直接查找并绑定具体 UI。
- **候选边界**：统一 UIController 只负责模板注册、打开、关闭、生命周期和公共按钮绑定；每个 GUI 的独立模块负责本界面的节点查找、局部交互和显示刷新；游戏状态修改仍通过对应 Service/Remote 完成。
- **Hotpot 对照项**：后续定点阅读 `BagGui.lua` 等模块，确认它们与全局 UI 列表、Component、Remote 和资源模板的真实职责分界。
- **验收方向**：删除某个 GUI 模块只影响该界面；公共生命周期逻辑不在各 GUI 重复；单个 GUI 缺失或报错不会永久阻塞所有 Controller；业务数据所有权不下沉到 UI 模块。
- **风险**：简单 GUI 也拆独立脚本可能制造大量只有转发作用的浅模块。只有第二个真实复杂界面出现相同绑定和生命周期问题后，才固定该规范。

### YF-008 Service 依赖注入缺少类型合同与自动补全

- **状态**：已完成首个局部类型合同验证（2026-07-26）；未建立完整类型系统。
- **真实现象**：Service 使用 `_logger = nil` 保存依赖，`Init(context)` 的 `context` 又没有明确类型，因此 Luau LSP 不知道 `_logger` 最终是 Logger，输入 `self._logger.` 时无法补全 `Debug`、`Info`、`Warn` 等方法。
- **影响**：开发者需要反复跳转源码记忆 API；拼写错误和错误参数只能较晚发现；`NetService`、`StorageService` 等注入依赖也会出现同样问题。
- **实现结果**：只在 `DeveloperService` 中声明 `LoggerType`、`StorageServiceType`、`NetServiceType`、`ServiceDependencies` 与 `ServiceInitContext`；`Init(context)` 明确只接收 Logger、StorageService 和 NetService 这三个当前真实依赖。`_logger`、`_services` 保持可空，使用 Logger 前统一经 `_getLogger()` 完成 nil 收窄，未初始化时给出明确配置错误。
- **实际收益**：编辑器可据此识别 `logger.Info/Warn`、`StorageService:ResetPlayerData` 和 `NetService:RegisterRequest` 的方法名、关键参数和返回值；不会替换运行时 ServiceRegistry，也不会让类型定义持有游戏业务。
- **候选边界**：后续评估统一的 `InitContext`、Logger API 类型和 Service 合同；避免每个业务 Service 重复手写同一份接口，也避免用大量 `any` 让 `--!strict` 失去作用。
- **Hotpot 对照项**：后续检查 KaPibala 如何表达模块公共 API、依赖获取和编辑器导航；Hotpot 使用 Lua 模块不等于已经具备静态类型能力，未读源码前不下结论。
- **验收结果（2026-07-26）**：Rokit 完整检查输出 `MODULE_BASE_CHECK_OK`；Studio Play 中 `DeveloperService` 正常启动，仍注册原有 `Developer.ResetMyData`，没有新增 Remote 或数据修改。类型标注只影响编辑阶段，正常运行路径不变。
- **边界与后续**：`ServiceRegistry` 的完整 Services 字典仍是动态注册，当前不建立全局递归类型图；后续只有另一处 Service 出现同样的依赖注入标注需求时，再提取共享 `InitContext` 类型模块。

### YF-009 Rojo 项目缺少可维护的游戏资产模板源目录与临时工作台生命周期约定

- **状态**：已记录；目前只有 `YanzoFrame_V2_JumpGame` 一处真实证据，未满足进入 V1 的通用化门槛，不修改 `YanzoFrame_V1_StorageModule`。
- **真实现象**：JumpGame 导入左右鞋模型后，先在 `Workspace` 中检查外观是合理的；但若原始导入模型长期留在场景，容易与正式穿戴模板或场景展示模型混淆。当前 V2 的 `default.project.json` 也尚未映射 `ServerStorage`，因此服务器专用的可穿戴 `Accessory` 模板只能保存在 Place 中，缺少本地源目录与唯一来源约定。
- **当前证据**：黑鞋第一次 R15 试穿验收失败，运行截图中角色脚边仍可见单只鞋模型；需待 Studio MCP 恢复后确认它是否为未清理的原始导入模型。无论该模型最终归属为何，已暴露“临时预览、正式装备模板、场景展示模型”三者没有明确生命周期和位置边界的问题。
- **候选边界**：候选的不是鞋子系统，而是 Rojo 项目的通用资产约定：`Workspace._Workbenches` 仅用于临时导入、R15 对位和预览；正式模板按可见性放到已映射的 `ServerStorage`（服务器克隆）或 `ReplicatedStorage`（客户端必须直接读取）；`Workspace.Map` 只保留经过锚定的场景展示副本与交互 Trigger；验收后清理工作台原始件。
- **Hotpot 对照项**：KaPibala 的 `default.project.json` 已映射 `src/ServerStorage`，说明服务器资源也应纳入项目源结构；但其 `ReplicatedStorage.Config.resource` 是资源逻辑配置表，不是 3D 模型库，不能直接照搬为 JumpGame 的模型目录。
- **目标仓库**：先在 `YanzoFrame_V2_JumpGame` 完成可追踪的资产目录、Rojo 映射和清理验收；只有第二个真实项目也出现相同问题时，才评估把“资产来源/工作台/运行时副本”约定沉淀为 V1 工作流文档或脚手架能力。
- **验收方向**：同一资产能追踪到唯一正式模板；服务器专用模板不会直接出现在场景；场景展示与可穿戴模板职责分离；`Workspace` 扫描不会留下工作台外的原始导入件；Rojo 同步前后不误删 Studio 资产。
- **风险与回滚**：不能先给空的 `ServerStorage` 本地目录开启同步，否则可能影响现有 Place 资源；实施前保留 `.rbxl` 备份，若映射验证失败，回退项目映射并保留 Studio 中的现有模板。

### YF-010 可穿戴 Accessory 模板与服务器挂载流程

- **状态**：已记录；黑鞋已完成第一处真实验收，但尚未满足进入 V1 通用实现的第二消费者门槛。
- **真实现象**：JumpGame 的黑鞋由左右两个 `Accessory` 组成。将 `Workspace.left/right` 调整为 `Handle` 下含角色脚部同名 Attachment，并用 `WorldCFrame` 对齐后，服务器从 `ServerStorage.JumpGameAssets.ShoeAccessories.Black` 克隆模板、设置无碰撞非固定属性，再由 `Humanoid:AddAccessory()` 挂载。运行时实际生成的是 `AccessoryRigidConstraint`，不能再按旧教程只检测 `AccessoryWeld`。
- **当前证据**：2026-07-24 的 Studio Play 验收中，`ShoeService` 根据已装备的 `Black` 状态生成 `BlackLeft` 与 `BlackRight`；两个脚部 Attachment 对齐误差均为 `0.000000`，停止 Play 后运行时副本会正常回滚。此前仅把测试副本 Parent 到角色或只检查旧 Weld 名称，都会造成“看似进入角色但无法可靠证明穿戴成功”的误判。
- **候选流程合同**：
  1. 在 `Workspace._Workbenches` 用目标 R15 角色手工摆放模型；人工确认大小、方向和遮挡。
  2. `Accessory` 必须只有明确的 `Handle` 主零件；从目标身体部位复制同名 Attachment，并以两个 Attachment 的 `WorldCFrame` 对齐固定最终姿势。
  3. 正式模板按可见性保存：服务器独占克隆来源放 `ServerStorage`，客户端必须直接读取的模板才放 `ReplicatedStorage`；展示副本与触碰 Trigger 留在 `Workspace.Map`。
  4. 游戏 Server Service 只在已验证的装备/重生刷新点 Clone 模板，统一设置 `Anchored=false`、`CanCollide=false`、`CanTouch=false`、`CanQuery=false`、`Massless=true`，并调用 `Humanoid:AddAccessory()`。
  5. 运行时副本必须有服务专属 Attribute；重装、切换和重生时只清理该标记副本，不删除玩家原本 Avatar 饰品。
  6. Studio 验收同时检查角色下是否有左右 Accessory、是否生成当前 Roblox 使用的 `AccessoryRigidConstraint`、两侧 Attachment 世界坐标是否对齐，以及重生后是否恢复。
- **当前代码所有者**：JumpGame 的 `Server/Game/Services/ShoeService.lua`；模板路径和 `ShoeSide` Attribute 是游戏资产合同，不属于 V1。
- **Hotpot 对照项**：后续在需要第二种饰品时，定点检查 KaPibala 的服务器资源目录、角色外观挂载和重生恢复链；只借鉴资源所有权与生命周期处理，不假设其存在可直接复制的 Accessory 服务。
- **目标仓库**：当前只在 `YanzoFrame_V2_JumpGame` 维持这条流程；至少再用帽子、披风或其他身体饰品完成同样的模板、服务器挂载和重生验收后，才评估在 `YanzoFrame_V1_StorageModule` 增加轻量的模板校验/挂载辅助，仍不让 V1 持有具体装备 ID、部位或存档规则。
- **验收方向**：每个新饰品能追踪到唯一正式模板；服务器权威决定何时挂载；客户端只看到表现；已挂载副本不与玩家 Avatar 饰品混淆；R15 重生后不会重复叠加或丢失。
- **风险与回滚**：不同 Avatar/Rig 的 Attachment 名称和位置不保证一致，最终姿势必须人工验收；旧脚本或教程可能使用 `AccessoryWeld` 名称，不能把它当作唯一成功标志。若挂载异常，移除本服务 Attribute 标记的运行时副本、恢复 `EquippedShoeId` 的旧值即可，不修改玩家原始 Avatar 饰品。

### YF-011 Shared Util 缺少受控的无状态工具函数入口

- **状态**：已完成并验证（2026-07-26）。
- **真实证据**：`MemoryStorage`、`ProfileStoreStorage` 与 `StorageService` 各自维护了一份逻辑相同的 `deepCopy`，三处都用于隔离存储数据的 table 引用。
- **实现结果**：新增 `ReplicatedStorage.Framework.Shared.Util.TableUtil`，只公开 `TableUtil.DeepCopy(value)`；三处存储代码全部改为依赖该函数，仓库不再存在其他 `local function deepCopy`。
- **边界**：`Util` 只接收无状态、无 Roblox 生命周期依赖、至少存在两个真实调用点的纯函数；它不是 Service，不进入 `ServiceRegistry`，不放置玩家等待、存档、Remote、资源或任何游戏业务。
- **验收结果（2026-07-26）**：Rokit 完整检查输出 `MODULE_BASE_CHECK_OK`；Studio 已确认 `ReplicatedStorage.Framework.Shared.Util` 为 `Folder`、`TableUtil` 为 `ModuleScript`，两者没有 Tag 或 Attribute。运行态测试确认嵌套副本与原表互不引用，修改副本后原始 `Language` 与 `Wins` 保持不变；ProfileStore 玩家档案重新打开正常。
- **当前限制**：`DeepCopy` 只支持无循环引用的普通 Lua table；Instance 克隆、循环引用和序列化尚无第二个真实需求，暂不加入。

## 记录模板

每个新候选至少填写：

- 编号和标题。
- JumpGame 中的真实复现步骤。
- 当前代码所有者和影响范围。
- Hotpot 对应实现路径及其优缺点。
- 是否满足通用化门槛。
- 目标仓库。
- 验收方式与回滚方式。
- 当前状态：已记录、对照中、待决策、实现中、已验证或放弃。

## 2026-07-26 决策：资源模块进入 V1 框架设计主线

- **状态**：已接受“资源边界独立”的方向；当前处于设计与验收契约阶段，尚未修改 V1 运行时代码。
- **触发证据**：JumpGame 同时暴露了三类资源生命周期问题：
  1. 左右鞋 `Accessory` 需要区分临时对位、服务器正式模板与角色运行时副本；
  2. 跑步机场景模型只存在于 Place，代码回退不能恢复它，必须依赖 `.rbxl` 备份和 Roblox 作品资产；
  3. 场景展示、交互 Trigger 与可穿戴模板若长期混在 `Workspace`，来源和清理责任会不明确。
- **本次结论**：这些不是“鞋子系统”的特例，而是资源来源、可见性、运行时副本和 Studio 工作台的重复边界问题。`YF-009` 从“候选观察”提升为 V1 下一轮的设计主线。
- **框架边界**：V1 只提供资源目录约定、模板查找/克隆的通用入口及可验证的失败信息；游戏项目继续拥有资源 ID、装备 ID、价格、奖励、场景布局和具体业务规则。
- **暂定目录契约**：服务器专用模板预留给 `ServerStorage.Resources`；客户端必须读取的模板预留给 `ReplicatedStorage.Resources`；`Workspace._Workbenches` 只用于临时导入、对位和预览；`Workspace.Map` 只保留已锚定的场景展示副本与交互对象。
- **明确不做**：不把 Roblox `AssetService` 包装成同名服务；不让 V1 保存任何具体鞋子/翅膀/跑步机 ID；不自动上传、下载或迁移旧 Place 资源；不在 JumpGame 继续扩展资源内容。
- **下一阶段门槛**：先完成 V1 目录映射审计与 `ResourceModule` ADR，再用“服务器 Accessory 模板”和“客户端可读展示模板”两条实际链路完成最小验证，最后才考虑回写 JumpGame。
- **JumpGame 状态**：自本记录起暂停在当前可玩检查点；仅处理用户明确授权的修复或回归，不再扩展玩法、场景或资源。

## 2026-07-26 实现记录：YF-009 ResourceModule v0.1

- **状态**：已完成 V1 的最小目录与服务契约；尚未将任何游戏资产迁入框架。
- **实现位置**：`YanzoFrame_V1_StorageModule/default.project.json`、`src/ServerStorage/Resources`、`src/ReplicatedStorage/Resources`、`src/ServerScriptService/Server/Framework/Services/ResourceService.lua`。
- **接口边界**：仅 Server 内部使用 `FindServerTemplate(resourceKey)` 与 `CloneServerTemplate(resourceKey, parent)`；无 Remote、无 DataStore、无资源 ID、无鞋子/翅膀/跑步机业务。
- **验证结果**：Rojo 映射 JSON、锁定版 `wally install`、`stylua --check src`、`selene src`、`Validate-ModuleBase.ps1` 和 `rojo sourcemap --include-non-scripts` 均通过。
- **Studio 验收**：2026-07-26 已确认 `ServerStorage.Resources`、`ReplicatedStorage.Resources` 入口存在，Play 后 `[ResourceService]` 中文启动日志正常输出。
- **仍需后续验证**：当第二个游戏项目接入时，以一份服务器专用 Accessory 模板和一份客户端可读展示模板完成 Studio Play 链路验收；不要把 V2 已有资源反向迁入 V1 作为框架样例。

## 2026-07-26 决策：V1 进入最小框架收敛阶段

- **结论**：V1 只保留启动、日志、网络、存档、资源目录/查找、已证实的纯工具、安全整档重置和 UI 模板约定；不再因为“未来可能会用”新增模块。
- **执行规则**：YF-004、YF-007、YF-009、YF-010 等仍保留为候选，不进入实现，直到出现第二处真实证据或原问题再次可复现。
- **详细边界**：见 `YanzoFrame_V1_StorageModule/docs/V1最小框架边界_MinimumFrameworkScope.md`。

## 相关链接

- [[框架教学模式|Roblox 框架教学模式]]
- [[30_MOC 内容地图/Roblox MOC|Roblox MOC]]
