---
type: log
domain: vault
status: active
owner: mixed
source: self
created: 2026-06-26
updated: 2026-10-11
---

# LLM Wiki 整理日志

## 2026-06-26 初始结构

### 本次新增

- 新增 `AGENTS.md`，定义 Codex 维护 Obsidian + LLM Wiki 的项目级规则。
- 新增 `.gitignore`，修正之前只有 `.gitigore` 拼写错误的问题。
- 新增 `70_LLM_Wiki 知识库` 初始骨架。
- 新增五个领域入口：
  - Roblox 游戏开发
  - 个人理财与人生
  - 英语学习与表达
  - AI 编程与产品
  - GitHub 与资源
- 补齐 `30_MOC 内容地图/` 下的五个领域 MOC 入口：
  - `Roblox MOC.md`
  - `个人理财与人生 MOC.md`
  - `英语表达 MOC.md`
  - `AI 编程与产品 MOC.md`
  - `GitHub 与资源 MOC.md`

### 关键决策

- 不推倒现有 PARA/MOC 结构。
- 不移动旧笔记，不删除附件。
- Codex 优先维护 `70_LLM_Wiki 知识库`。
- `30_MOC 内容地图/` 作为人类阅读入口继续保留。
- 第一阶段优先整理 Roblox，因为当前库中 Roblox 和工作流资产最多。

## 2026-06-26 Roblox 第一批 Wiki 编译

### 读取来源

- `笔记导览.md`
- `70_LLM_Wiki 知识库/schema.md`
- `70_LLM_Wiki 知识库/index.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `20_Areas 领域/Roblox/框架/项目框架.md`
- `20_Areas 领域/Roblox/Rojo/Rojo 新项目前置准备.md`
- `10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/FirstLoop`
- `10_Projects 项目/Roblox/精灵/PROJECT_TAKEOVER_DEVELOPMENT_GUIDE.md`
- `81_WorkFlow 工作流/Roblox/Roblox项目读取/README.md`
- `81_WorkFlow 工作流/Roblox/Roblox游戏Gui界面读取/README.md`
- `81_WorkFlow 工作流/Roblox/Tripo多视图工作流/README.md`
- `81_WorkFlow 工作流/Roblox/Roblox 武器模型制作工作流/README.md`

### 新增页面

- `70_LLM_Wiki 知识库/Roblox/Roblox 项目架构职责边界.md`
- `70_LLM_Wiki 知识库/Roblox/Rojo 工程生产线.md`
- `70_LLM_Wiki 知识库/Roblox/Client Server Remote 请求链路.md`
- `70_LLM_Wiki 知识库/Roblox/DataService 与 DataSchema 边界.md`
- `70_LLM_Wiki 知识库/Roblox/Feature Pack 与 Feature Card.md`
- `70_LLM_Wiki 知识库/Roblox/Roblox 项目接手工作流.md`
- `70_LLM_Wiki 知识库/Roblox/Roblox GUI 读取工作流.md`
- `70_LLM_Wiki 知识库/Roblox/Tripo 多视图工作流.md`
- `70_LLM_Wiki 知识库/Roblox/Roblox 武器模型导入打包工作流.md`

### 关键决策

- 第一批页面做成入口型 Wiki，不直接覆盖原始项目笔记。
- Roblox 知识先围绕“项目结构、Rojo、Remote、DataService、Feature Pack、项目接手、GUI、武器资产工作流”建立主干。
- 工作流资产仍保留在 `81_WorkFlow 工作流/Roblox`，Wiki 只做索引和抽象。

## 2026-06-26 Roblox 第二批 Wiki 编译

### 读取来源

- `10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/FirstLoop/第 8 课：FirstLoop 涉及的 Luau 语法点.md`
- `20_Areas 领域/Roblox/框架/模块系统/动画系统/Roblox 原生动画系统.md`
- `20_Areas 领域/Roblox/框架/RobloxGameFramework/第2课：服务端启动链路.md`
- `20_Areas 领域/Roblox/框架/RobloxGameFramework/第3课：客户端启动链路.md`
- `20_Areas 领域/Roblox/框架/RobloxGameFramework/第4课：网络通信：NetService  NetClient  NetResult.md`
- `20_Areas 领域/Roblox/框架/RobloxGameFramework/第6课：用 001_FirstLoop 串成完整闭环.md`
- `20_Areas 领域/Roblox/框架/RobloxGameFramework/通用 Roblox 工程骨架.md`
- `10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/FirstLoop/1 FirstLoop 文件地图.md`
- `10_Projects 项目/Roblox/玩具/玩具箱守卫者_发条拼装核心特色策划方案.md`

### 新增页面

- `70_LLM_Wiki 知识库/Roblox/Luau 语法最小掌握.md`
- `70_LLM_Wiki 知识库/Roblox/Roblox 原生动画系统.md`
- `70_LLM_Wiki 知识库/Roblox/RobloxGameFramework 启动链路.md`
- `70_LLM_Wiki 知识库/Roblox/ToyBox 项目索引.md`

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/index.md`
- `30_MOC 内容地图/Roblox MOC.md`

### 关键决策

- Luau 语法页只沉淀当前 Roblox 项目最常遇到的最小语法集合，不做完整语言教程。
- 动画系统页围绕 Studio 编辑、资产发布、Animator 运行和排查路径组织。
- RobloxGameFramework 启动链路页把服务端、客户端、网络通信和 FirstLoop 接入方式连成一条学习路径。
- ToyBox 项目索引作为项目理解入口，不替代运行项目的 handoff 文档。

### 下一步

- 整理 CombatTrainingEnemy 和训练敌人链路。
- 整理 PlayerHUD 页面。
- 整理发条拼装台 UI、资源卡和奖励循环。
- 把低价值空壳笔记删除，把有价值但命名不清的 Inbox 笔记重命名或移动。

## 2026-06-26 命名修正与低风险清理

### 移动和重命名

- `00_Inbox 收集箱/GnomeCode教程.md` -> `40_Resources 资料/Roblox/GnomeCode 教程 YouTube.md`
- `00_Inbox 收集箱/动画脚本.md` -> `40_Resources 资料/Roblox/Roblox 动画脚本 YouTube.md`
- `00_Inbox 收集箱/周报.md` -> `10_Projects 项目/Roblox/周报素材/周四_Roblox_PS5_AI音乐_武器模型.md`
- `00_Inbox 收集箱/探灵笔记.md` -> `80_Idea 灵感/举报押金公告牌机制.md`
- `00_Inbox 收集箱/未命名.md` -> `10_Projects 项目/Roblox/待处理/奔跑与技能适配待处理.md`
- `00_Inbox 收集箱/未命名 1.md` -> `20_Areas 领域/Roblox/引导系统修复记录.md`
- `20_Areas 领域/UI/UI界面生成.md` -> `40_Resources 资料/UI/ForgeGUI AI 游戏界面生成.md`
- `20_Areas 领域/UI/UI资源.md` -> `40_Resources 资料/UI/Flaticon UI 图标资源.md`
- `80_Idea 灵感/PUBG.md` -> `80_Idea 灵感/射击生存玩法灵感.md`
- `80_Idea 灵感/通用.md` -> `80_Idea 灵感/死亡随机 Buff 与规则探索.md`

### 删除

- 删除 `.gitigore`，因为已由 `.gitignore` 替代。
- 删除 `00_Inbox 收集箱/Roblox聊天系统.md`，因为是空白笔记。
- 删除 `10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/003_PlayerHUD/003_PlayerHUD.md`，因为是空白笔记。
- 删除 `20_Areas 领域/Unity.md`，因为是空白笔记。
- 删除空目录 `.claude/agents`、`.claude/commands`、`.claude/skills`、`.claude`、`.claudian/sessions`、`00_Inbox 收集箱/assets/门禁卡`。

### 关键决策

- 有内容的笔记不删除，只重命名、移动并补最小 frontmatter。
- 视频链接类内容进入 `40_Resources 资料`。
- 玩法想法进入 `80_Idea 灵感`。
- 项目调试和待处理事项进入 Roblox 项目或领域目录。
- 附件和图片未做删除。

### 补充更新

- 更新 `笔记导览.md`，补齐 `70_LLM_Wiki 知识库`、`80_Idea 灵感`、`81_WorkFlow 工作流` 的用途说明。
- 修正 `笔记导览.md` 末尾多余的 Markdown 代码块结束符。

## 2026-06-26 Roblox 第三批 ToyBox 玩法 Wiki 编译

### 启动检查

- 使用 `toybox-guardians-workflow` 读取 ToyBox 当前状态与 Context Graph。
- 执行 `D:\AI\Codex\ToyBox\scripts\Invoke-ToyBoxCheck.ps1 -Mode Startup`：`PASS`。
- 执行 `codegraph status .`：索引最新，状态 `[OK]`。
- 执行 `codegraph explore "HUDConfig ResourceOrder ResourceConfig LootTableConfig resource loop"`，确认当前资源顺序、掉落表、资源快照和 HUD 配置。

### 读取来源

- `10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/02_CombatTrainingEnemy/000大纲.md`
- `10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/02_CombatTrainingEnemy/002.1 大纲.md`
- `10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/02_CombatTrainingEnemy/002.2.md`
- `10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/02_CombatTrainingEnemy/002.3.md`
- `10_Projects 项目/Roblox/玩具/玩具箱守卫者_发条拼装核心特色策划方案.md`
- `D:\AI\Codex\ToyBox\TOYBOX_CURRENT_STATE.md`
- `D:\AI\Codex\ToyBox\TOYBOX_CONTEXT_GRAPH.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\002_CombatTrainingEnemy.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\003_PlayerHUD_玩家HUD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\003_PlayerHUD_玩家HUD_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\003_PlayerHUD_UIBrief_玩家HUD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UX_SPEC.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\04_ToyAssembly.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\006_BasicMaterialEnemies.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\006_BasicMaterialEnemies_TDD.md`

### 新增页面

- `70_LLM_Wiki 知识库/Roblox/CombatTrainingEnemy 训练怪玩法闭环.md`
- `70_LLM_Wiki 知识库/Roblox/PlayerHUD 玩家 HUD.md`
- `70_LLM_Wiki 知识库/Roblox/发条拼装台 UI.md`
- `70_LLM_Wiki 知识库/Roblox/ToyBox 资源卡与奖励循环.md`

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/index.md`
- `30_MOC 内容地图/Roblox MOC.md`

### 关键决策

- `002_CombatTrainingEnemy` 明确写成父级玩法闭环索引，不把父级卡当作直接实现卡。
- `PlayerHUD` 只沉淀正式 HUD 最小闭环，不混入拼装台、ToyList、LevelUp 或 Boss。
- `发条拼装台 UI` 先写 UI/UX 和 Server / Client 边界，不声称当前运行实现已完成。
- `资源卡与奖励循环` 把 `SmallGear / WoodBody / BubbleCore` 的当前来源和 HUD 显示口径连起来，同时保留后四个资源为后续预留。

### 下一步

- 整理 `004_UpgradeBench` 的强化闭环。
- 整理 `005_ExpLevelProgression` 的经验升级与 PowerScore。
- 整理 `006_BasicMaterialEnemies` 的材料怪经验，可从当前资源页拆出独立页面。
- 整理 `008A_EquipmentService` 的装备服务与 ToyLoadout 边界。

## 2026-06-26 Roblox 第四批 ToyBox 成长链路 Wiki 编译

### 启动检查

- 使用 `toybox-guardians-workflow` 读取 ToyBox 当前状态、Context Graph、日常工作流和手动操作说明。
- 执行 `D:\AI\Codex\ToyBox\scripts\Invoke-ToyBoxCheck.ps1 -Mode Startup`：`PASS`。
- 执行 `codegraph status .`：索引最新，状态 `[OK]`。
- 执行 `codegraph explore "ProgressionConfig ApplyExp CalculatePowerScore LootDropService ResourceService HUDConfig 005 ExpLevelProgression"`，确认经验、等级、PowerScore、资源快照和 HUD 链路。
- 执行 `codegraph explore "EquipmentService ToyLoadout.Equip ToyConfig EquippedToyId Resource.GetSnapshot 008A"`，确认装备 Remote、拥有校验、`EquippedToyId` 写入和 PowerScore 重算链路。

### 读取来源

- `D:\AI\Codex\ToyBox\AGENTS.md`
- `D:\AI\Codex\ToyBox\TOYBOX_CURRENT_STATE.md`
- `D:\AI\Codex\ToyBox\TOYBOX_CONTEXT_GRAPH.md`
- `D:\AI\Codex\ToyBox\TOYBOX_DAILY_WORKFLOW.md`
- `D:\AI\Codex\ToyBox\项目协作与手动操作说明书.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\004_UpgradeBench.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\004_UpgradeBench_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\005_ExpLevelProgression.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\005_ExpLevelProgression_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\006_BasicMaterialEnemies.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\006_BasicMaterialEnemies_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\008A_EquipmentService_玩具装备服务.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\008A_EquipmentService_玩具装备服务_TDD.md`

### 新增页面

- `70_LLM_Wiki 知识库/Roblox/ExpLevelProgression 经验等级成长.md`
- `70_LLM_Wiki 知识库/Roblox/UpgradeBench 强化台闭环.md`
- `70_LLM_Wiki 知识库/Roblox/BasicMaterialEnemies 基础材料怪.md`
- `70_LLM_Wiki 知识库/Roblox/EquipmentService 玩具装备服务.md`

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/index.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- `005_ExpLevelProgression` 是已验收的成长中枢，负责经验、等级、PowerScore 的统一口径。
- `004_UpgradeBench` 当前写成 `Draft / Decisions confirmed, ready for execution`，不声明 Studio 已验收。
- `006_BasicMaterialEnemies` 是已验收的材料怪来源页，连接 `WoodBody / BubbleCore`、经验奖励和 HUD 反馈。
- `008A_EquipmentService` 当前写成 `Implemented / automated verification passed / Studio Play pending`，自动验证通过但成功路径仍等待 Studio Play seed/AssemblyBench 验收。
- 本批只整理 Obsidian Wiki，不修改 `D:\AI\Codex\ToyBox` runtime，也不改 `RobloxGameFramework`。

### 下一步

- 整理 `007 AssemblyBench`、`ToyResultUI`、`ToyInventory`、`ToyListUI`。
- 后续继续整理 `ProfileStore / Persistence`、`Deploy / UpgradeStar`、Boss 和长期玩法链路。

## 2026-06-26 Roblox 第五批 ToyBox 拼装与玩具库存 Wiki 编译

### 启动检查

- 使用 CodeGraph 查询 `AssemblyBench ToyResultUI ToyInventory ToyListUI ToyAssembly ToyListController AssemblyService`。
- 结果显示当前 runtime 未定位到正式 `ToyAssemblyService`、`ToyAssemblyController`、`ToyResultGui` 或 `ToyListUI` 实现。
- 因此本批页面标记为设计/待实现或 partial，不声明运行项目已完成。

### 读取来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\04_ToyAssembly.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UX_SPEC.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UI_ASSET_WORKFLOW.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\art\ASSET_REQUIREMENTS.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\008A_EquipmentService_玩具装备服务.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\008A_EquipmentService_玩具装备服务_TDD.md`

### 新增页面

- `70_LLM_Wiki 知识库/Roblox/AssemblyBench 第一次拼装闭环.md`
- `70_LLM_Wiki 知识库/Roblox/ToyResultUI 拼装结果弹窗.md`
- `70_LLM_Wiki 知识库/Roblox/ToyInventory 与 ToyListUI 玩具库存.md`

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/index.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/发条拼装台 UI.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- `AssemblyBench 第一次拼装闭环` 写成 `Design / planned / runtime not implemented`，只沉淀 007 的数据、Remote、UI 和验收口径。
- `ToyResultUI 拼装结果弹窗` 写成 P0 UI 需求页，不把 `DeployButton` 误写成已实现上阵功能。
- `ToyInventory 与 ToyListUI 玩具库存` 写成 `Planned / partial server slice exists`，明确只有 `008A_EquipmentService` 的 `ToyLoadout.Equip` 已落地。
- 继续保持 `发条拼装台 UI` 作为 UI 概览页，新页面负责服务闭环、结果弹窗和玩具库存拆解。

### 下一步

- 整理 `ProfileStore / Persistence` 的持久化边界。
- 整理 `Deploy / UpgradeStar` 与 ToyInventory 后续实现边界。
- 再继续整理 Boss、重启、长期成长和资源稀有度链路。

## 2026-06-26 Roblox 第六批 ToyBox 数据层与玩具动作边界 Wiki 编译

### 启动检查

- 使用 CodeGraph 查询 `DataService DataSchema ProfileStore Persistence ToyLoadout.Deploy ToyLoadout.UpgradeStar UpgradeStar Deploy`。
- 结果确认当前 `DataService` 是内存 profile + adapter 边界，`ProfileStore` 尚未接入。
- `DataSchema` 已包含 `Resources`、`Progression`、`Toys`、`Collection`、`Upgrade`、`AreaUnlocks`、`AreaAbilities`、`PermanentStats`。
- 使用 `rg` 确认当前 `src` 没有正式 `ToyLoadout.Deploy` 或 `ToyLoadout.UpgradeStar` Remote 实现。

### 读取来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_TODO.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\README.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\008A_EquipmentService_玩具装备服务.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\008A_EquipmentService_玩具装备服务_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ServerScriptService\Server\Framework\Services\DataService.lua`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\DataSchema.lua`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\ToyConfig.lua`

### 新增页面

- `70_LLM_Wiki 知识库/Roblox/ProfileStore 持久化边界.md`
- `70_LLM_Wiki 知识库/Roblox/ToyLoadout Deploy 与 UpgradeStar 边界.md`

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/DataService 与 DataSchema 边界.md`
- `70_LLM_Wiki 知识库/Roblox/EquipmentService 玩具装备服务.md`
- `70_LLM_Wiki 知识库/Roblox/ToyInventory 与 ToyListUI 玩具库存.md`
- `70_LLM_Wiki 知识库/Roblox/index.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- `ProfileStore 持久化边界` 标记为 `Reserved / not connected / v0.2 candidate`，明确 Demo 第一版不接真实持久化。
- `ToyLoadout Deploy 与 UpgradeStar 边界` 标记为 `Planned / schema reserved / runtime not implemented`。
- 明确区分 `Deploy`、`Equip`、`UpgradeStar`：Deploy 是上阵表现，Equip 是装备贡献，UpgradeStar 是碎片升星。
- 继续保留业务 Service 只依赖 `DataService` 的原则，不让玩法系统直接依赖底层持久化库。

### 下一步

- 整理 Boss、Reboot / PermanentStats、区域能力和更长期玩法链路。

## 2026-06-26 Roblox 第七批 ToyBox 长期玩法链路 Wiki 编译

### 启动检查

- 使用 CodeGraph 查询 `Boss Reboot PermanentStats AreaAbilities SecondJump AreaUnlocks Progression.Reboot BossReward ClockworkCore`。
- 结果确认当前 `ProgressionConfig` 已读取 `PermanentStats.Health / Attack / ToyMultiplier` 参与 MaxHealth 和 PowerScore。
- 当前未定位到正式 `Progression.Reboot`、`Progression.AssignPoint`、`AreaAbility.GetState`、`Boss.Start` 或 `Boss.GetState` runtime 实现。
- `DataSchema` 已预留 `Progression.RegionRebootDone`、`AreaAbilities`、`AreaUnlocks` 和 `PermanentStats` 相关字段。

### 读取来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\05_ProgressionAreaAbility.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_TODO.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\gdd-assessments\ToyboxGuardiansDemo_GDD_ASSESSMENT.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\art\ASSET_REQUIREMENTS.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\DataSchema.lua`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\ProgressionConfig.lua`

### 新增页面

- `70_LLM_Wiki 知识库/Roblox/RebootBench 与 PermanentStats 长期成长.md`
- `70_LLM_Wiki 知识库/Roblox/AreaAbility 二段跳与区域解锁.md`
- `70_LLM_Wiki 知识库/Roblox/BossEncounter 与 BossRewardUI.md`

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/index.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/ExpLevelProgression 经验等级成长.md`
- `70_LLM_Wiki 知识库/Roblox/PlayerHUD 玩家 HUD.md`
- `70_LLM_Wiki 知识库/Roblox/ToyBox 资源卡与奖励循环.md`
- `70_LLM_Wiki 知识库/Roblox/BasicMaterialEnemies 基础材料怪.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- `RebootBench 与 PermanentStats 长期成长` 标记为 `Planned / schema partially reserved / runtime not implemented`。
- `AreaAbility 二段跳与区域解锁` 标记为 `Planned / schema reserved / runtime not implemented`，并记录 `SecondJumpUnlocked` 与 `ToyboxWorkshop_DoubleJump` 的命名差异。
- `BossEncounter 与 BossRewardUI` 标记为 `Planned / runtime not implemented`，强调 Boss 状态、首通奖励和区域门必须由 Server 判定。
- Boss / Reboot / AreaAbility 是中后期目标，不抢占第一次拼装和 P0 UI 的优先级。

### 下一步

- 整理 EliteEnemies / RareMaterials、死亡复活、资产需求。
- Roblox 主线之后转入 AI 编程与产品、GitHub 资源、英语学习、个人理财人生四个非 Roblox 领域。

## 2026-06-26 Roblox 第八批 ToyBox 收尾与资产规范 Wiki 编译

### 启动检查

- 使用 CodeGraph 查询 `EliteEnemies RareMaterials DeathRespawn Death Respawn Health ClockworkCore ToyFragments MagnetSheet Spring`。
- 结果确认当前有训练怪死亡、刷新和敌人血条基础，但没有正式玩家 `DeathRespawnUI` runtime。
- 当前没有定位到正式 `EliteEnemies`、精英怪 AI、稀有材料掉落资格或多人奖励资格 runtime 实现。

### 读取来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_TODO.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UI_ASSET_WORKFLOW.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\art\ASSET_REQUIREMENTS.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\art\TOY_STYLE_GUIDE.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ServerScriptService\Server\Game\Services\TrainingEnemyService.lua`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ServerScriptService\Server\Game\Presentation\EnemyHealthBillboard.lua`

### 新增页面

- `70_LLM_Wiki 知识库/Roblox/EliteEnemies 与 RareMaterials 稀有材料.md`
- `70_LLM_Wiki 知识库/Roblox/DeathRespawn 资源保留 UI.md`
- `70_LLM_Wiki 知识库/Roblox/ToyBox 资产需求与风格规范.md`

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/index.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/PlayerHUD 玩家 HUD.md`
- `70_LLM_Wiki 知识库/Roblox/BossEncounter 与 BossRewardUI.md`
- `70_LLM_Wiki 知识库/Roblox/ToyBox 资源卡与奖励循环.md`
- `70_LLM_Wiki 知识库/Roblox/BasicMaterialEnemies 基础材料怪.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- `EliteEnemies 与 RareMaterials 稀有材料` 标记为 `Planned / existing enemy foundation / runtime not implemented`。
- `DeathRespawn 资源保留 UI` 标记为 `Planned / UI requirement / player death runtime not implemented`。
- `ToyBox 资产需求与风格规范` 做成 evergreen 资产索引页，聚合命名、占位、模型节点、图标和风格规则。
- Roblox 主线整理到此形成完整索引，后续转入非 Roblox 领域。

### 下一步

- 整理 AI 编程与产品。
- 整理 GitHub 资源。
- 整理英语学习。
- 整理个人理财与人生。

## 2026-06-26 AI 编程与产品第一批 Wiki 编译

### 读取来源

- `20_Areas 领域/AI/Codex/Codex.md`
- `20_Areas 领域/AI/Codex/Codex实用功能.md`
- `20_Areas 领域/AI/Codex/通用Codex新项目工作流_Obsidian版.md`
- `20_Areas 领域/AI/Codex/项目工作流.md`
- `20_Areas 领域/AI/ComfyUI/从零理解 ComfyUI.md`
- `40_Resources 资料/UI/ForgeGUI AI 游戏界面生成.md`

### 新增页面

- `70_LLM_Wiki 知识库/AI_Programming_Product/Codex 项目记忆与交接工作流.md`
- `70_LLM_Wiki 知识库/AI_Programming_Product/Codex 工具能力与使用边界.md`
- `70_LLM_Wiki 知识库/AI_Programming_Product/ComfyUI 节点工作流入门.md`
- `70_LLM_Wiki 知识库/AI_Programming_Product/AI 工具卡模板.md`
- `70_LLM_Wiki 知识库/AI_Programming_Product/产品思路记录模板.md`

### 更新页面

- `70_LLM_Wiki 知识库/AI_Programming_Product/index.md`
- `30_MOC 内容地图/AI 编程与产品 MOC.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- Codex 相关页面只沉淀稳定工作流原则，不把来源视频里的具体版本号当作永久事实。
- `Codex 项目记忆与交接工作流` 作为以后所有项目的通用启动和接手方法。
- `AI 工具卡模板` 和 `产品思路记录模板` 用于后续把零散资源和产品想法变成可复用结构。

### 下一步

- 整理 GitHub 与资源领域。

## 2026-06-26 GitHub 与资源第一批 Wiki 编译

### 读取来源

- `70_LLM_Wiki 知识库/GitHub_Resources/index.md`
- `30_MOC 内容地图/GitHub 与资源 MOC.md`
- `40_Resources 资料/Youtube.md`
- `40_Resources 资料/UI/ForgeGUI AI 游戏界面生成.md`
- `40_Resources 资料/UI/Flaticon UI 图标资源.md`
- `40_Resources 资料/Roblox/GnomeCode 教程 YouTube.md`
- `40_Resources 资料/Roblox/Roblox 动画脚本 YouTube.md`

### 新增页面

- `70_LLM_Wiki 知识库/GitHub_Resources/资源卡验证状态与收藏规则.md`
- `70_LLM_Wiki 知识库/GitHub_Resources/GitHub 仓库资源卡模板.md`
- `70_LLM_Wiki 知识库/GitHub_Resources/工具资源卡模板.md`
- `70_LLM_Wiki 知识库/GitHub_Resources/外部资源首批索引.md`

### 更新页面

- `70_LLM_Wiki 知识库/GitHub_Resources/index.md`
- `30_MOC 内容地图/GitHub 与资源 MOC.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 当前领域先按“资源库”整理，不强行制造不存在的 GitHub 仓库卡。
- 资源状态分为 `collected / skimmed / studied / tried / verified / deprecated`。
- 工具类资源以后必须补使用或验证记录，不能只存链接。

### 下一步

- 整理英语学习。

## 2026-06-26 英语学习第一批 Wiki 编译

### 读取来源

- `70_LLM_Wiki 知识库/English/index.md`
- `30_MOC 内容地图/英语表达 MOC.md`
- `20_Areas 领域/英语/英语单词积累.md`
- `20_Areas 领域/英语/音标.md`

### 新增页面

- `70_LLM_Wiki 知识库/English/CET4 友好商务英语句库.md`
- `70_LLM_Wiki 知识库/English/GitHub PR Issue 英文表达.md`
- `70_LLM_Wiki 知识库/English/英语常见错误与发音纠正.md`
- `70_LLM_Wiki 知识库/English/技术英语词汇积累方法.md`

### 更新页面

- `70_LLM_Wiki 知识库/English/index.md`
- `30_MOC 内容地图/英语表达 MOC.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 英语页默认按 CET-4 友好、短句、商务可用来组织。
- GitHub / PR 英文表达优先服务真实工程沟通，不做复杂写作课。
- 发音纠错保留 `tr / dr / tʃ / dʒ / ts / dz` 和 Bootstrap 读法。

### 下一步

- 整理个人理财与人生。

## 2026-06-26 个人理财与人生第一批 Wiki 编译

### 读取来源

- `70_LLM_Wiki 知识库/Finance_Life/index.md`
- `30_MOC 内容地图/个人理财与人生 MOC.md`
- `20_Areas 领域/钱包/ChatGPT Plus 充值流程笔记：Fiat24 + 欧易 + Arbitrum.md`
- `20_Areas 领域/钱包/汇丰香港 HSBC One + HSBC Mastercard Debit Card.md`
- `20_Areas 领域/钱包/教程.md`
- `20_Areas 领域/钱包/买币流程.md`
- `20_Areas 领域/钱包/地址.md`

### 新增页面

- `70_LLM_Wiki 知识库/Finance_Life/个人理财页面模板.md`
- `70_LLM_Wiki 知识库/Finance_Life/人生决策记录模板.md`
- `70_LLM_Wiki 知识库/Finance_Life/高风险金融内容核验清单.md`
- `70_LLM_Wiki 知识库/Finance_Life/钱包链与 Gas 基础.md`
- `70_LLM_Wiki 知识库/Finance_Life/跨境账户与订阅付款流程记录.md`
- `70_LLM_Wiki 知识库/Finance_Life/不适合 Codex 汇总的内容.md`

### 更新页面

- `70_LLM_Wiki 知识库/Finance_Life/index.md`
- `30_MOC 内容地图/个人理财与人生 MOC.md`
- `70_LLM_Wiki 知识库/log.md`

### 删除

- 删除 `20_Areas 领域/钱包/地址.md`，因为它包含不应进入普通知识库的生成地址和手机号，且属于高风险低价值内容。

### 关键决策

- 金融相关页面只做流程、风险和复盘结构，不提供实时金融、税务或投资建议。
- 钱包和跨境账户笔记只抽象链、Gas、核验清单和评估维度，不复制完整地址、卡号或敏感账号信息。

### 下一步

- 做全库最终验证。
- 更新总入口当前优先级和整理状态。

## 2026-06-26 全库第一轮收口

### 更新页面

- `70_LLM_Wiki 知识库/index.md`
- `70_LLM_Wiki 知识库/open_questions.md`
- `70_LLM_Wiki 知识库/log.md`

### 已完成领域

- Roblox：完成 ToyBox 主线第一轮 Wiki 入网。
- AI 编程与产品：完成 Codex、ComfyUI、工具卡和产品模板第一批。
- GitHub 与资源：完成资源卡规则、仓库模板、工具模板和外部资源索引。
- 英语学习与表达：完成 CET-4 友好商务句库、PR/Issue 表达、发音纠错和技术词汇方法。
- 个人理财与人生：完成理财模板、决策模板、高风险核验、钱包链/Gas 和敏感内容边界。

### 删除

- 删除 `20_Areas 领域/钱包/地址.md`，避免普通知识库保留生成地址、手机号等高风险低价值内容。

### 后续重点

- 定期清理 `00_Inbox 收集箱`。
- 对新增资源补验证状态。
- 评估是否把 Obsidian LLM Wiki 整理流程升级成 Codex Skill。

## 2026-06-26 Inbox 收口与根目录清理

### 移动归档

- `00_Inbox 收集箱/Obsidian初始配置.md` -> `40_Resources 资料/Obsidian/Obsidian 初始配置与免费同步 YouTube.md`
- `00_Inbox 收集箱/豆包总结Obsidian.md` -> `40_Resources 资料/Obsidian/Obsidian Git 同步与 AI 笔记工作流（豆包总结）.md`
- `00_Inbox 收集箱/assets/豆包总结Obsidian` -> `40_Resources 资料/Obsidian/assets/豆包总结Obsidian`
- `00_Inbox 收集箱/专业开发者如何搭建 Roblox 游戏.md` -> `40_Resources 资料/Roblox/How PRO Devs Set Up Roblox Games.md`
- `00_Inbox 收集箱/Roblox.md` -> `81_WorkFlow 工作流/Roblox/AI图生场景资源区工作流.md`
- `00_Inbox 收集箱/结构.md` -> `10_Projects 项目/Roblox/待处理/BagPageGui 结构与 SVN 卡顿待处理.md`
- `00_Inbox 收集箱/门禁卡.md` -> `10_Projects 项目/Roblox/待处理/门禁卡 OldProject 审计导出.md`
- `00_Inbox 收集箱/巅峰进化.md` -> `80_Idea 灵感/巅峰进化 UX 反馈.md`
- `00_Inbox 收集箱/assets/巅峰进化` -> `80_Idea 灵感/assets/巅峰进化`
- `00_Inbox 收集箱/老版本3D建模软件下载安装.md` -> `40_Resources 资料/3D建模/老版本 Autodesk 软件安装资源.md`
- `00_Inbox 收集箱/deepseek对接codex/Gemini生成文档.md` -> `40_Resources 资料/AI/Codex 接 DeepSeek V4 极速指南 Gemini版.md`
- `00_Inbox 收集箱/deepseek对接codex/gpt生成文档.md` -> `40_Resources 资料/AI/Codex 接 DeepSeek V4-Pro 操作手册 GPT版.md`

### 删除

- 删除根目录临时转写、播放器 JSON 和音频缓存：`F3ASTJuO82A_transcript.json`、`F3ASTJuO82A_transcript.txt`、`F3ASTJuO82A_ytplayer.json`、`video_audio.m4a`、`video_transcript_tiny.json`、`video_transcript_tiny.txt`、`ytplayer.json`。
- 删除 `00_Inbox 收集箱` 下已清空的空目录。

### 更新页面

- `30_MOC 内容地图/Obsidian MOC.md`
- `30_MOC 内容地图/AI 编程与产品 MOC.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `30_MOC 内容地图/GitHub 与资源 MOC.md`
- `70_LLM_Wiki 知识库/index.md`
- `70_LLM_Wiki 知识库/log.md`
- `20_Areas 领域/Roblox/框架/模块系统/动画系统/Roblox 原生动画系统.md`

### 关键决策

- DeepSeek / Codex 对接文档只作为未验证资料保留，并在页首标注 API Key、代理、模型路由和计费风险。
- Roblox Studio 审计导出作为项目证据归档，不强行压缩成 Wiki，避免丢失旧项目结构细节。
- 截图类 UX 反馈保留图片并移动 assets，使 Obsidian 相对链接继续可用。
- 修复移动资料和既有动画系统页的 Markdown 代码块闭合问题，避免 Obsidian 渲染异常。

## 2026-06-26 ToyBox GDD Word 备份

### 新增 / 复制

- `10_Projects 项目/Roblox/玩具/ToyboxGuardiansDemo/GDD备份/玩具箱守卫者_GDD_Work_v2_5_2026-06-26.docx`
- `10_Projects 项目/Roblox/玩具/ToyboxGuardiansDemo/GDD备份/玩具箱守卫者 GDD v2.5 Word 备份.md`

### 更新页面

- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/ToyBox 项目索引.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- Word 文件是 ToyBox 具体项目交付备份，放入 `10_Projects 项目/Roblox/玩具/ToyboxGuardiansDemo/GDD备份`，不放 Inbox。
- LLM Wiki 只新增索引入口，不把 Word 全文压缩成 Wiki 页面，避免丢失原始传阅版证据。
- 源文件与备份文件 SHA256 一致：`B4FF2439A186051098A8AD881C83D07874B720CA01F658082AE6637C10AAEB2F`。

### 下一步

- 后续 GDD 升版时，追加新的备份说明页，保留历史传阅版。

## 2026-06-26 线上项目制作流程与 UI 美术交接沉淀

### 读取来源

- 用户口述的 Roblox 线上项目学习流程。
- 用户提供的卡皮巴拉进化、铁魂、巫师炼金术、主界面 UE 标注截图。
- `D:\SVN\新界面`
- `D:\SVN\新界面\炼药\炼药界面视频初步分析.md`
- `D:\SVN\新界面\炼药\NEXT_CHAT_HANDOFF_炼药UI搭建.md`
- `20_Areas 领域/Roblox/游戏市场判断框架.md`
- `80_Idea 灵感/巅峰进化 UX 反馈.md`

### 新增页面

- `70_LLM_Wiki 知识库/Roblox/线上项目完整制作流程.md`

### 新增素材

- `70_LLM_Wiki 知识库/Roblox/assets/线上项目完整制作流程/capybara-evolution-reference.png`
- `70_LLM_Wiki 知识库/Roblox/assets/线上项目完整制作流程/iron-soul-reference.png`
- `70_LLM_Wiki 知识库/Roblox/assets/线上项目完整制作流程/wizard-alchemy-reference.png`
- `70_LLM_Wiki 知识库/Roblox/assets/线上项目完整制作流程/main-ui-ue-annotated.png`
- `70_LLM_Wiki 知识库/Roblox/assets/线上项目完整制作流程/main-ui-tooltip-annotated.png`
- `70_LLM_Wiki 知识库/Roblox/assets/线上项目完整制作流程/alchemy-ui-ue-annotated.png`
- `70_LLM_Wiki 知识库/Roblox/assets/线上项目完整制作流程/shop-ui-ue-annotated.png`
- `70_LLM_Wiki 知识库/Roblox/assets/线上项目完整制作流程/common-rarity-colors.png`

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/index.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 把本次内容沉淀为 `workflow` 类型 Wiki 页，而不是只放聊天记录。
- 图片复制进 Wiki 附近的 assets 目录，避免依赖临时截图路径。
- `D:\SVN\新界面` 被描述为 UI 美术与开发交接包，保留原路径作为来源证据。
- 明确线上热度和活跃玩家数属于时间敏感信息，正式立项前需要重新核验。

### 下一步建议

- 确认巅峰进化融合的另一款参考游戏。
- 如果该流程继续复用，可以再升级为 `81_WorkFlow 工作流/Roblox/UI 美术交接工作流`。

## 2026-06-26 Blender 入门视频知识手册

### 读取来源

- 用户指定视频：`https://www.youtube.com/watch?v=z-Xl9tGqH14`
- `笔记导览.md`
- `70_LLM_Wiki 知识库/schema.md`
- `70_LLM_Wiki 知识库/index.md`
- `30_MOC 内容地图/Roblox MOC.md`

### 新增页面

- `40_Resources 资料/3D建模/Blender Guru Beginner Blender Tutorial 2026 知识手册.md`

### 关键决策

- 视频属于外部学习资料，放入 `40_Resources 资料/3D建模`，不直接放入 LLM Wiki。
- 手册不是逐字稿，而是面向 Roblox / Tripo / 低模游戏道具目标整理的学习路线。
- 明确甜甜圈教程只承担 Blender 基础操作学习，后续应转向拆部件、清理 AI 模型、低模重建和导出测试。

### 下一步建议

- 学完基础操作后，整理一套 `拆部件 / 清理 AI 模型 / 分离 Mesh / 低模重建` 的专项资源笔记。
- 如果魔法书资产流程继续推进，沉淀为 `81_WorkFlow 工作流/Roblox/魔法书资产制作工作流`。

## 2026-06-27 Blender 甜甜圈 5 教程资料离线整理

### 读取来源

- `https://www.blenderguru.com/posts/blender-donut-v5-tutorial`
- `https://www.poliigon.com/blender`
- `笔记导览.md`
- `70_LLM_Wiki 知识库/schema.md`
- `70_LLM_Wiki 知识库/index.md`
- `30_MOC 内容地图/Roblox MOC.md`

### 新增页面

- `40_Resources 资料/3D建模/Blender甜甜圈5教程资料/Blender甜甜圈5教程资料索引.md`
- `40_Resources 资料/3D建模/Blender甜甜圈5教程资料/Blender快捷键表_中文学习版.md`

### 新增素材

- `40_Resources 资料/3D建模/Blender甜甜圈5教程资料/assets/杯子参考图.webp`
- `40_Resources 资料/3D建模/Blender甜甜圈5教程资料/assets/Blender快捷键表.pdf`
- `40_Resources 资料/3D建模/Blender甜甜圈5教程资料/assets/Blender快捷键表.txt`
- `40_Resources 资料/3D建模/Blender甜甜圈5教程资料/assets/Poliigon_Blender_Addon.zip`

### 关键决策

- 只离线保存教程页面明确提供且可直接下载的资料，不抓取视频正文或付费课程内容。
- 英文快捷键表保留原始 PDF/TXT，同时新增中文学习版，优先翻译当前游戏道具建模会用到的快捷键。
- Poliigon 纹理资源通常需要账号登录，因此本轮仅记录下载入口和处理建议，没有代替用户登录下载。
- Academy、Discord、Unstuck 指南属于在线或账号门槛资源，本轮以中文索引记录，不作为本地完整资料保存。

### 下一步建议

- 用户登录 Poliigon 后，把教程纹理下载到 `assets`，再由 Codex 继续整理中文说明。
- 后续可以建立 `3D建模 MOC`，集中管理 Blender、Tripo、Meshy、Roblox 资产导入和低模道具资料。

## 2026-06-28 Blender AI 模型清理学习路线

### 读取来源

- 用户要求：为 Blender 阶段 2-6 生成详细知识笔记，写入 `D:\AI\Codex\Codex_Obsidian`。
- 当前对话中的魔法书模型处理经验：Tripo / 混元 AI 一体高模不适合强行拆件，更适合清理、减面、局部手修、材质分配和导出。
- `笔记导览.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/index.md`

### 新增页面

- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/README.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/01_基础清理命令.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/02_Decimate减面与质量判断.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/03_局部选择与保护.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/04_简单手修.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/05_材质与Roblox导出.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/06_魔法书练习任务清单.md`

### 更新页面

- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/index.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 放入 `81_WorkFlow 工作流/Roblox`，因为这套内容是可重复执行的资产清理学习流程，不是一次性资源摘录。
- 按阶段拆成多篇短笔记，避免把 Blender 入门、AI 模型清理、减面、局部选择、导出混在一篇长文里。
- 每篇都围绕 `D:\Blender\MagicBook.blend` 的实际练习，不写抽象大而全教程。

### 下一步建议

- 用户按 `06_魔法书练习任务清单.md` 逐项练习；如果卡在某一步，再把截图或 `.blend` 状态给 Codex 做针对性说明。
- 后续可补一篇 `07_常见失败截图诊断.md`，专门记录封面波纹、扣条破边、书脊塌陷、法线错误等视觉症状。

## 2026-06-28 Blender AI 模型清理学习路线中文术语优化

### 触发原因

- 用户反馈英文按钮和术语不易理解，要求至少中英双语，笔记以中文为主。

### 新增页面

- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/00_中文术语表.md`

### 更新页面

- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/README.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/01_基础清理命令.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/02_Decimate减面与质量判断.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/03_局部选择与保护.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/04_简单手修.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/05_材质与Roblox导出.md`
- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/06_魔法书练习任务清单.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/index.md`

### 调整原则

- 统一改为“中文操作名（英文界面名）”。
- 英文只作为 Blender 界面对照，不作为主要学习语言。
- 新增术语表，集中解释对象模式、编辑模式、按距离合并、精简修改器、顶点组、材质槽、FBX 导出等常见按钮。

## 2026-06-29 Blender 清理菜单命令速查

### 触发原因

- 用户在清理魔法书封面、封底和侧面时，需要把 `网格 > 清理` 菜单里的常用项整理成可复用知识点。
- 用户反馈整本书平滑着色后有“塌陷/融化”观感，需要明确平滑着色与真实几何变形的区别。

### 新增页面

- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/07_清理菜单命令速查.md`

### 更新页面

- `81_WorkFlow 工作流/Roblox/Blender AI模型清理学习路线/README.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/index.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 把清理菜单作为独立速查页，不塞回 `01_基础清理命令.md`，避免基础练习篇过长。
- 明确清理菜单不是万能修复菜单：按距离合并、删除松散元素、有限融并、填充洞等命令各有适用范围。
- 明确魔法书这种硬表面资产不建议整本书平滑着色；圆柱、圆环可局部平滑，封面、扣条、浮雕和护角更适合平直着色。

## 2026-06-29 AI 道具模型参考图工作流迁移与解耦

### 触发原因

- 用户要求将当前工作流移动到 `81_WorkFlow 工作流` 路径下。
- 用户指出原文档中包含固定项目路径和 Level 批次输出路径，耦合过高，不适合作为通用工作流。

### 新增页面

- `81_WorkFlow 工作流/Roblox/AI道具模型参考图工作流/README.md`
- `81_WorkFlow 工作流/Roblox/AI道具模型参考图工作流/CHECKLIST_8视图自检.md`
- `81_WorkFlow 工作流/Roblox/AI道具模型参考图工作流/PROMPT_TEMPLATES.md`
- `81_WorkFlow 工作流/Roblox/AI道具模型参考图工作流/STATUS.md`

### 更新页面

- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/index.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 将“魔法书参考图流程”升级为通用的 Roblox 单体道具 image-to-3D 参考图工作流。
- 主流程只使用 `{PROJECT_ROOT}`、`{OUTPUT_ROOT}`、`{ASSET_TYPE}`、`{ASSET_NAME}` 等变量，不写死具体项目路径。
- 魔法书、Level5、right45 顶部页层等内容只作为失败模式和经验抽象，不作为主流程依赖。
- 原项目目录保留迁移提示，避免旧工作流和 Obsidian 新工作流分叉维护。

### 下一步建议

- 后续如果书本、武器、宝箱等资产类型差异继续扩大，再新增“资产类型补充模板”，但仍保持通用解耦。
## 2026-06-30 Accessory 武器挂载知识卡

### 触发原因

- 用户在 Roblox Studio 中完成 `9-7_direct_512tex` 镰刀 Accessory 手动挂载实验后，希望把原理、脚本归属、模型结构要求和是否抽象成模块的判断沉淀到 `D:\AI\Codex\Codex_Obsidian`。
- 用户要求中文命名，并允许自行创建文件夹，方便后续沉淀类似功能知识卡。

### 新增页面

- `70_LLM_Wiki 知识库/Roblox/知识卡/README.md`
- `70_LLM_Wiki 知识库/Roblox/知识卡/Accessory 武器挂载知识卡.md`

### 更新页面

- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/index.md`
- `70_LLM_Wiki 知识库/Roblox/Roblox 武器模型导入打包工作流.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 将该内容放入 `70_LLM_Wiki 知识库/Roblox/知识卡`，因为它首先是可长期复用的 Roblox 原理知识，不是某个项目的运行时代码。
- 明确“制作 Accessory 模板”优先靠 Studio 手动校准，模块只能负责运行时克隆、挂载、卸下、替换和重生恢复。
- 把验收标准写成 `Handle.RightGripAttachment.WorldCFrame` 与角色手部同名 Attachment 的 `WorldCFrame` 重合，避免误以为只要本地 `Position/Orientation` 一样就一定正确。

### 下一步建议

- 后续如果出现双手武器、背挂武器、拔刀动画或多挂点切换，再新增独立知识卡，不把这些高级情况塞进当前基础卡。
## 2026-06-30 Accessory 武器挂载知识卡结构调整

### 触发原因

- 用户反馈知识卡开头应优先告诉“怎么操作”，原理说明应放到后面。
- 用户明确指出真实 Roblox Studio 项目中会先在 `Workspace` 操作和确认，确认没问题后才拖到 `ReplicatedStorage` 或其他模板目录。

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/知识卡/Accessory 武器挂载知识卡.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 将知识卡改为“实操优先”结构：开头先给 Workspace 制作、调试、测试、归档流程，后面再讲 Accessory / Handle / Attachment 原理。
- 明确 `Workspace` 是临时制作和验证区，`ReplicatedStorage` / `ServerStorage` 是确认成功后的模板存放区。
- 保留正式脚本推荐放 `ServerScriptService` 的建议，但承认临时实验阶段把 `Script` 放在 `Workspace` 是合理的。

## 2026-06-30 把武器挂到手上知识卡精简

### 触发原因

- 用户反馈知识卡仍然过于复杂，不需要覆盖多种情况，只需要给出一条最合适、可直接操作的方案。
- 用户要求命名见名知意，英文单词尽量简单，适合 CET-4 水平阅读。

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/知识卡/把武器挂到手上知识卡.md`
- `70_LLM_Wiki 知识库/Roblox/知识卡/README.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/index.md`
- `70_LLM_Wiki 知识库/Roblox/Roblox 武器模型导入打包工作流.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 将文件名从 `Accessory 武器挂载知识卡.md` 改为 `把武器挂到手上知识卡.md`。
- 只保留推荐路径：`Workspace` 手动调好，放到 `ReplicatedStorage/WeaponAssets`，再用 `ServerScriptService/GiveWeapon` 测试。
- 采用简单命名：`Weapon_01`、`WeaponAssets`、`GiveWeapon`。
- 删除备用脚本、模块升级建议、多情况说明和长错误表。

## 2026-07-01 v2rayN 全局代理应用直连 Skill

### 触发原因

- 用户在 v2rayN 全局路由和 TUN 必须开启的前提下，遇到 QQ 登录失败，并随后要求把 QQ/微信直连代理修复流程沉淀成可迁移、可复用的 Skill。
- 用户指定保存到 `81_WorkFlow 工作流/VPS`，并要求中文命名，同时下次可能是其他 `.exe` 文件。

### 新增页面

- `81_WorkFlow 工作流/VPS/v2rayN 全局代理应用直连 Skill/SKILL.md`
- `81_WorkFlow 工作流/VPS/v2rayN 全局代理应用直连 Skill/scripts/update_v2rayn_app_direct_route.py`
- `81_WorkFlow 工作流/VPS/v2rayN 全局代理应用直连 Skill/references/v2rayN 路由规则参考.md`
- `81_WorkFlow 工作流/VPS/v2rayN 全局代理应用直连 Skill/agents/openai.yaml`

### 关键决策

- 将工作流做成通用应用直连 Skill，而不是只写死 QQ/微信。
- 保留中文文件夹和中文标题；`SKILL.md` 的 `name` 使用英文机器名，确保将来复制到 Codex skills 目录时仍可通过校验。
- 脚本支持任意 `.exe` 进程名、域名和 IP，并默认备份 v2rayN 的 `guiNDB.db` 与 `guiNConfig.json`。
- 明确不默认使用 `geoip:cn`，因为用户要求保持全局代理，仅对指定应用直连。

### 验证

- `quick_validate.py` 校验 Skill 结构通过。
- `py_compile` 校验脚本语法通过。
- 使用当前 v2rayN 根目录执行 dry-run，确认脚本能读取活动路由且不会写入。

## 2026-07-02 ProximityPrompt 漂浮道具穿戴知识卡

### 触发原因

- 用户已跑通鞋子漂浮展示、靠近交互、服务器穿戴流程，希望沉淀成简单、可照做、可复用的 Roblox 知识卡。
- 用户明确决定：`Accessory` 模板本身由人工在 Studio 中做好；本卡只抽象“物品浮动和交互装备”。

### 新增或修改页面

- `70_LLM_Wiki 知识库/Roblox/知识卡/ProximityPrompt漂浮道具穿戴知识卡.md`
- `70_LLM_Wiki 知识库/Roblox/知识卡/README.md`
- `70_LLM_Wiki 知识库/Roblox/index.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 明确本卡引用 `把武器挂到手上知识卡`，但不重复讲 `Accessory` / `Handle` / `Attachment` 制作。
- 将运行时职责拆开：`Visual` 只展示，`Hitbox` 只做交互范围，`ProximityPrompt` 只触发，服务器脚本只校验和穿戴，客户端脚本只做漂浮动画。
- 保留当前验证成功的 `Parent = character` 穿戴方式，并记录 `FindFirstChildOfClass("ProximityPrompt")` 用于避免 Prompt 改名后找不到。

### 下一步建议

- 如果后续出现多个帽子、披风、武器、光环等交互装备点，再从知识卡升级为 `PickupEquipService` / `FloatPickupController` 类型的可复用模块。

## 2026-07-02 ProximityPrompt 漂浮道具穿戴知识卡实操化重排

### 触发原因

- 用户强调知识卡的第一目标是让读者快速实现功能，开头应简单直白说明功能，然后直接进入不跳步骤的 Studio 操作。
- 用户要求知识点、必坑点和常见问题后置，避免一开始被原理和边界打断。

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/知识卡/ProximityPrompt漂浮道具穿戴知识卡.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 将卡片前半部分重排为：功能目标、前置模板检查、创建场景对象、服务器脚本、客户端漂浮脚本、Play 测试、最终结构检查。
- 将 `Visual` / 穿戴模板区别、`FindFirstChildOfClass`、服务器触发链路、Anchored 坑、长按坑等内容统一后移到知识点、必坑点和常见问题。
- 保留完整可复制脚本，同时把 Studio 中每个对象的创建类型、右键位置和属性设置写清楚。

## 2026-07-02 ProximityPrompt 漂浮道具穿戴知识卡代码注释优化

### 触发原因

- 用户指出知识卡默认面向新建 Roblox 项目，不需要保留“关闭旧自动穿鞋脚本”的说明。
- 用户希望两个代码块增加中文注释，让开发者能直接看懂脚本每段在做什么。

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/知识卡/ProximityPrompt漂浮道具穿戴知识卡.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 删除旧项目迁移场景下才需要的自动穿鞋脚本提示，保持教程默认从新建项目出发。
- 给 `ShoePickupEquip` 和 `ShoePickupFloat` 代码块补充中文注释，重点解释对象查找、服务器距离校验、克隆穿戴、展示物物理属性、`basePivot`、`RenderStepped`、`math.sin` 和 `PivotTo`。

## 2026-07-02 Accessory 挂到角色身体部位知识卡重写

### 触发原因

- 用户确认 `ProximityPrompt` 漂浮道具穿戴知识卡的结构后，希望把前置卡 `把武器挂到手上知识卡` 也按同一标准改造。
- 原标题只覆盖“武器挂手上”，不够通用；实际知识点是 `Accessory + Handle + 同名 Attachment` 挂到任意角色身体部位。

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/知识卡/Accessory挂到角色身体部位知识卡.md`
- `70_LLM_Wiki 知识库/Roblox/知识卡/ProximityPrompt漂浮道具穿戴知识卡.md`
- `70_LLM_Wiki 知识库/Roblox/知识卡/README.md`
- `70_LLM_Wiki 知识库/Roblox/index.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/Roblox 武器模型导入打包工作流.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 将文件名从 `把武器挂到手上知识卡.md` 改为 `Accessory挂到角色身体部位知识卡.md`，并在 frontmatter 中保留旧名 alias。
- 将卡片前半部分改为纯操作流程：创建 R15 参考角色、整理 `Accessory/Handle`、复制目标 `Attachment`、用 `WorldCFrame` 对齐、放入 `ReplicatedStorage`、用服务器脚本测试。
- 将原理、坑点、常见问题后置，保持和 `ProximityPrompt漂浮道具穿戴知识卡` 一致的阅读顺序。

## 2026-07-02 Roblox 知识卡 README 优化

### 触发原因

- 用户希望 `70_LLM_Wiki 知识库/Roblox/知识卡/README.md` 也按照最新知识卡要求优化。
- 当前 README 只说明文件夹用途，没有说明知识卡的阅读顺序、写作标准和归档边界。

### 更新页面

- `70_LLM_Wiki 知识库/Roblox/知识卡/README.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 将 README 改成知识卡入口页，先告诉使用者“现在先看哪张”。
- 明确两张现有卡的适用场景：`Accessory挂到角色身体部位知识卡` 负责可穿戴模板，`ProximityPrompt漂浮道具穿戴知识卡` 负责漂浮交互穿戴。
- 固化知识卡写作标准：先讲功能目标，再写不跳步骤的操作，代码块带中文注释，知识点、必坑点、常见问题后置。

## 2026-07-04 v2rayN WeGame / 英雄联盟应用直连工作流升级

### 触发原因

- 用户在 v2rayN 全局/TUN 模式下要求 WeGame 和 WeGame 版英雄联盟走本地网络，不翻墙。
- 实测发现仅放行 WeGame/LOL 主进程不够，网络质量评估、内嵌浏览器、反作弊和反馈组件也会发起连接。

### 更新页面

- `81_WorkFlow 工作流/VPS/v2rayN 全局代理应用直连 Skill/SKILL.md`
- `81_WorkFlow 工作流/VPS/v2rayN 全局代理应用直连 Skill/references/v2rayN 路由规则参考.md`
- `81_WorkFlow 工作流/VPS/v2rayN 全局代理应用直连 Skill/scripts/update_v2rayn_app_direct_route.py`
- `81_WorkFlow 工作流/VPS/v2rayN 全局代理应用直连 Skill/scripts/discover_wegame_lol_targets.py`
- `81_WorkFlow 工作流/VPS/v2rayN 全局代理应用直连 Skill/agents/openai.yaml`

### 关键决策

- 新增 `discover_wegame_lol_targets.py`，通过卸载项、快捷方式、运行进程和候选安装根目录自动发现 WeGame / 英雄联盟目标，不写死安装盘符。
- 将 `browser.exe`、`icreateLol.exe`、`SGuard64.exe`、`SGuardSvc64.exe`、`SGuardUpdate64.exe`、`FeedBack.exe` 等本次验证过的关键进程固化进 WeGame/LOL 直连规则。
- 强化验证标准：优先使用 sing-box Clash API `/connections` 查看 `processPath` 和 `chains`，不要只看 v2rayN 底部日志。
- 保持原则：不使用 `geoip:cn` 兜底，避免破坏“全局代理，但指定应用直连”的目标。
- 已通过脚本语法检查、相对路径发现流程和 Skill `quick_validate.py` 校验。

## 2026-07-06 Roblox 魔法书参考图目录回迁与魔法杖工作流初版

### 触发原因

- 用户要求将 `AI道具模型参考图工作流` 移回 `Roblox 魔法书模型制作工作流` 目录。
- 用户要求基于魔法书、武器和 Tripo 多视图经验，生成 `Roblox 魔法杖模型制作工作流` 初版。

### 更新页面

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法书模型制作工作流/WORKFLOW_MOVED.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法书模型制作工作流/AI道具模型参考图工作流/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法书模型制作工作流/AI道具模型参考图工作流/STATUS.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/PROMPT_TEMPLATES.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/CHECKLIST.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/STATUS.md`
- `30_MOC 内容地图/Roblox MOC.md`
- `70_LLM_Wiki 知识库/Roblox/index.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- `AI道具模型参考图工作流` 仍保持通用道具规则，但物理位置回到魔法书工作流目录下，承接魔法书和书本类道具经验。
- 魔法杖流程采用“先生成并确认一张正视图，再锁定设计生成 back / left / right”的四视图路线。
- 合集参考图只作为风格来源，不直接上传 Tripo / 混元 3D。
- 魔法杖初版强调单根、正交、完整、纯背景、无文字水印、无粒子光效、杖头和装饰必须有可解释连接关系。

## 2026-07-06 精灵魔法杖 8 视图测试与工作流修正

### 触发原因

- 用户决定模仿魔法书工作流，先用混元 AI 测试 8 视图生成模型。
- 在生成过程中发现魔法杖不能机械套用普通道具 `top / bottom`，应使用杖头和尾部端面图。

### 更新页面

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/PROMPT_TEMPLATES.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/CHECKLIST.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/STATUS.md`

### 新增运行产物

- `D:\AI\Codex\Codex_3DModel\outputs\elf_magic_wand_8view_20260706\00_final_hunyuan_upload`
- `D:\AI\Codex\Codex_3DModel\outputs\elf_magic_wand_8view_20260706\_checks\contact_sheet.png`
- `D:\AI\Codex\Codex_3DModel\outputs\elf_magic_wand_8view_20260706\_checks\checklist_result.md`
- `D:\AI\Codex\Codex_3DModel\outputs\elf_magic_wand_8view_20260706\_docs\RUN_STATE.md`
- `D:\AI\Codex\Codex_3DModel\outputs\elf_magic_wand_8view_20260706\_docs\PROMPT.md`

### 关键决策

- 魔法杖 8 视图使用 `front / back / left / right / head_top / tail_bottom / left45 / right45`。
- `head_top` 和 `tail_bottom` 必须是轴向端面图，不是正面特写。
- 侧视图和 45 度图容易被拉成长法杖，新增 `SIDE_VIEW_STAFF_LENGTH_DRIFT` 风险标签。
- 右侧和右 45 度优先镜像通过检查的左侧视图，减少左右漂移。

## 2026-07-06 Roblox 魔法杖工作流默认八视图与正交视角门禁

### 触发原因

- 用户要求 `Roblox 魔法杖模型制作工作流` 默认生成八视图。
- 用户特别强调武器一致性和 8 视图视角必须正确：顶视图必须从正上方看，左右视图必须从正左 / 正右看，不能有任何偏移。

### 更新页面

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/PROMPT_TEMPLATES.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/CHECKLIST.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/STATUS.md`
- `70_LLM_Wiki 知识库/log.md`

### 关键决策

- 默认最终文件改为 `front / back / left / right / top / bottom / left45 / right45` 八视图；四视图只作为用户明确要求或工具限制时的额外版本。
- `top` 定义为从魔法杖正上方沿纵轴垂直向下看，`bottom` 定义为从正下方沿纵轴垂直向上看；旧命名 `head_top / tail_bottom` 只作为别名。
- `left / right` 定义为正左 / 正右 90 度工程侧视图；轻微 3/4、压扁正面或任何水平偏移都判失败。
- 在 Prompt、Checklist 和 Status 同步加入八视图一致性门禁，单张图好看但不像同一根魔法杖或视角不正时必须重做。

## 2026-07-06 Roblox 魔法杖 V2 八视图实测与工作流补强

- 新增魔法杖 V2 八视图实测记录：`81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/2026-07-06_v2_8view_lessons.md`
- 更新魔法杖工作流状态：记录 V2 输出目录、镜像生成右侧/右45、标准最终文件名 `top.png / bottom.png`。
- 更新魔法杖检查清单：新增 `TAIL_GEM_UNWANTED`、`SIDE_GEM_OFF_CENTER`、`OUTPUT_SOURCE_MIXED`、`FINAL_FILENAME_ALIAS_MISMATCH`。
- 输出图片目录：`D:\AI\Codex\Codex_3DModel\outputs\elf_magic_wand_8view_v2_20260706`

## 2026-07-06 Roblox 魔法杖 V3 八视图修正（已废弃）

- 新增魔法杖 V3 八视图修正记录：`81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/2026-07-06_v3_8view_revision.md`
- 本轮重点修正：正背叶子和粗细不一致、叶子位置漂移、顶视图过度抽象、底视图未表达细尾向上可见粗杖头体量。
- 关键规则：背面可在建模验证阶段复用正面以保持同构；右侧和右 45 度优先由左侧 / 左 45 镜像；顶 / 底视图按轴向投影解释体量关系。
- 用户复核后判定：V3 从人类视觉上不如 V2，更像规则化投影而不是可用魔法杖参考图。
- 处理结果：V3 项目输出目录已删除，保留文档作为失败样本；后续改为以 V2 为审美基准制作 V2.5。

## 2026-07-07 Roblox 魔法杖多视图本地 Skill 固化

- 新增本地 Codex Skill：`C:\Users\14176\.codex\skills\roblox-magic-wand-multiview`
- Skill 目标：服务混元 3D / TripoAI 生成可用 Roblox 魔法杖模型，而不是生成单纯好看的插画。
- 固化规则：V2 是当前视觉基准，V3 是废弃样本，下一步应做 V2.5 局部修正。
- Skill 包含：`SKILL.md`、`references/view-contracts.md`、`references/failure-gates.md`、`references/prompt-blocks.md`。
- 已通过 `quick_validate.py` 校验。

## 2026-07-07 Roblox 直接导入 FBX 外部贴图策略固化

### 读取来源

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程`
- 用户在 Roblox Studio 中复测确认：外部贴图 FBX 测试包可导入，原内嵌贴图 FBX 曾报 `base_color_texture` 上传失败。

### 更新页面

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/scripts/Prepare-RobloxWeaponImport.ps1`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/01_单个模型转Roblox可直接导入版_SOP.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/02_源文件问题诊断.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/03_交付与记录模板.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/scripts/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/outputs/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/logs/工作记录.md`
- `70_LLM_Wiki 知识库/Roblox/Roblox 武器模型导入打包工作流.md`

### 关键决策

- 默认 Studio 导入包输出根目录改为 `%USERPROFILE%\Documents\RobloxImportPackages`，减少 Roblox Studio 读取 FBX 外部贴图时受 Obsidian 中文长路径影响的概率。
- `*_direct_512tex.fbx` 改为外部相对贴图优先；同目录 `*_texture_512.jpg` 是 direct FBX 的必要伴随文件。
- 新增 `*_embedded_512tex.fbx` 作为兼容性排查文件，不作为首选交付。
- GLB 仍作为 FBX 贴图上传失败时的主要备用方案；mesh-only + JPG 仍作为最终保底。

### 验证记录

- 使用 `MagicWand-01_3292` 重新跑固定脚本。
- 输出目录：`C:\Users\14176\Documents\RobloxImportPackages\MagicWand-01_3292_roblox_direct`
- 结果：`ROBLOX_WEAPON_EXPORT_OK`，faces=3292，texture=512x512 Format24bppRgb。
- Blender 读回确认：direct FBX 为 `packed=False`，embedded FBX 为 `packed=True`，mesh-only FBX 无图片引用。

## 2026-07-07 Roblox 直接导入 FBX 尺寸修正

### 触发原因

- 用户在 Roblox Studio 中确认外部贴图 FBX 能导入，但 FBX 比 GLB 明显大。
- 目标是让 FBX 默认导入尺寸和 GLB 一样接近 1 单位。

### 更新页面

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/scripts/Prepare-RobloxWeaponImport.ps1`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/01_单个模型转Roblox可直接导入版_SOP.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/02_源文件问题诊断.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/03_交付与记录模板.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/scripts/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/outputs/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/logs/工作记录.md`
- `70_LLM_Wiki 知识库/Roblox/Roblox 武器模型导入打包工作流.md`

### 关键决策

- 根因是旧 FBX 写入 `Lcl Scaling=(100,100,100)`，而顶点最大尺寸仍是 1；Roblox Studio 会把这层节点缩放作为真实尺寸应用。
- 当前脚本对所有 FBX 导出加入 `global_scale=0.01` 和 `apply_scale_options='FBX_SCALE_ALL'`。
- 新验证标志为 `fbx_scale_mode=roblox_unit_1`。

### 验证记录

- 使用 `MagicWand-01_3292` 重新跑固定脚本。
- 输出目录：`C:\Users\14176\Documents\RobloxImportPackages\MagicWand-01_3292_roblox_direct`
- 结果：`ROBLOX_WEAPON_EXPORT_OK`，faces=3292，texture=512x512 Format24bppRgb。
- 二进制读回确认 direct / embedded / mesh-only 三类 FBX 均满足：`UnitScaleFactor=1`，`Lcl Scaling=(1,1,1)`，`vertex max dimension=1`。

## 2026-07-07 Roblox 魔法杖模型制作工作流 V2 固化

### 读取来源

- `D:\AI\Codex\Codex_3DModel\output\magic_wands\MULTIVIEW_RULES.md`
- `D:\AI\Codex\Codex_3DModel\output\magic_wands\dark_wood_purple_crystal_wand_3dai_20260707\_docs\FINAL_6_VIEW_STATUS.md`
- `D:\AI\Codex\Codex_3DModel\output\magic_wands\dark_wood_purple_crystal_wand_3dai_20260707\_docs\STRUCTURE_LOCK.md`
- `D:\AI\Codex\Codex_3DModel\output\magic_wands\dark_wood_purple_crystal_wand_3dai_20260707\_docs\MEASUREMENTS.md`

### 更新页面

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流V2/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流V2/PROMPT_TEMPLATES.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流V2/CHECKLIST.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流V2/RUN_TEMPLATES.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流V2/STATUS.md`
- `30_MOC 内容地图/Roblox MOC.md`

### 关键决策

- V2 默认交付 6 视图：`front.png`、`back.png`、`left.png`、`right.png`、`left45.png`、`right45.png`。
- 默认不交付 `top.png` / `bottom.png`，因为仅凭 2D 正视参考无法可靠推断正上方和正下方结构。
- 每把魔法杖必须先确认 `front.png`，再写比例锁和结构锁，最后逐个生成并审核其他视图。
- `left.png` / `right.png` 固定为垂直 90°正侧面；如果主宝石仍显示宽正面，直接标记 `SIDE_VIEW_NOT_90_DEGREE`。

### 下一步建议

- 后续每一把魔法杖都按 V2 执行：先正视图、再比例锁、再 6 视图、最后 contact sheet 和 bbox 表。
- 如果未来已有真实 3D 模型或可靠深度资料，再单独扩展 top/bottom 分支，不要把推断图混入默认上传包。

## 2026-07-08 YanzoFrame_V0 框架学习文档精简

### 读取来源

- `10_Projects 项目/Roblox/1框架模块化开发`
- 当前框架学习对话中已确认的 ServiceRegistry、Net、Storage、Logger、Lifecycle、复制模块规则

### 更新页面

- `10_Projects 项目/Roblox/1框架模块化开发/00_YanzoFrame_V0_学习入口.md`
- `10_Projects 项目/Roblox/1框架模块化开发/01_框架总览.md`
- `10_Projects 项目/Roblox/1框架模块化开发/02_启动链路_Main与Registry.md`
- `10_Projects 项目/Roblox/1框架模块化开发/03_Service与Controller规则.md`
- `10_Projects 项目/Roblox/1框架模块化开发/04_Net网络层.md`
- `10_Projects 项目/Roblox/1框架模块化开发/05_Storage最小存储边界.md`
- `10_Projects 项目/Roblox/1框架模块化开发/06_复制框架做新模块规则.md`
- `10_Projects 项目/Roblox/1框架模块化开发/99_易错点与错题.md`

### 关键决策

- 框架学习文档统一使用 `YanzoFrame_V0`。
- 删除碎片化长稿和空占位笔记，改为 8 个短文档入口。
- 保留 Storage 学习截图附件，并迁移到目标目录根级 `assets/存储模块`。
- 商店方向只保留为未来 CommerceCore 提醒，不进入框架本体文档。

### 验证记录

- 目标目录内无旧实验名残留。
- `00_YanzoFrame_V0_学习入口.md` 的 Obsidian 链接检查通过。
- 目标目录最终保留 8 个 Markdown 和 1 张图片附件。

## 2026-07-08 Roblox 直接导入 FBX 内嵌贴图提取修复

### 读取来源

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程`
- `D:\Download\3DModel\魔法杖模型\低模\HY014.fbx`
- `D:\Download\3DModel\魔法杖模型\低模\HY016.fbx`

### 更新页面

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/scripts/Prepare-RobloxWeaponImport.ps1`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/scripts/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/01_单个模型转Roblox可直接导入版_SOP.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/logs/工作记录.md`
- `70_LLM_Wiki 知识库/Roblox/Roblox 武器模型导入打包工作流.md`

### 关键决策

- 真单文件 FBX 如果没有外部贴图，不能直接判定为 `texture=none`；需要继续检查材质节点里 packed 的 Base Color 图。
- 提取到 packed 颜色图后，仍统一导出为同目录 `*_texture_512.jpg`，让 direct FBX 走外部相对贴图链路。
- `*_embedded_512tex.fbx` 继续只作为兼容性排查文件，不作为首选交付。

### 验证记录

- `HY014`、`HY016` 已重新导出，结果均包含 direct FBX、GLB、embedded FBX、mesh-only FBX、`*_texture_512.jpg` 和 README。
- 两张贴图均为 `512x512 Format24bppRgb JPG`。
- 6 个 FBX 均验证为 `UnitScaleFactor≈1`、`Lcl Scaling=(1,1,1)`，未恢复旧的 100 倍节点缩放问题。

## 2026-07-09 Git + TortoiseGit Windows 标准安装规则沉淀

### 读取来源

- 本机安装记录：Git for Windows、TortoiseGit、TortoiseGit 简体中文语言包。
- `D:\Work\TortoiseGit\TortoiseGit-LanguagePack-zh_CN-install-admin.log`
- `D:\AI\Codex\Codex_ModuleDev\YanzoFrame_V0\docs\TortoiseGit使用教程.md`

### 新增或更新页面

- `81_WorkFlow 工作流/Git/Git 与 TortoiseGit Windows 标准安装流程.md`
- `81_WorkFlow 工作流/Git/TortoiseGit 使用教程.md`
- `70_LLM_Wiki 知识库/AI_Programming_Product/Git 与 TortoiseGit Windows 标准安装规则.md`
- `70_LLM_Wiki 知识库/AI_Programming_Product/index.md`
- `30_MOC 内容地图/AI 编程与产品 MOC.md`

### 关键决策

- 以后新 Windows 设备安装 Git 时，默认把 Git for Windows、TortoiseGit、TortoiseGit 简体中文语言包视为一套 Git 环境。
- 记录 TortoiseGit 简体中文语言值为 `HKCU:\Software\TortoiseGit\LanguageID = 2052`。
- 保留 `81_WorkFlow 工作流/Git/` 作为人类可照做的安装与使用流程；同时在 `70_LLM_Wiki 知识库/AI_Programming_Product/` 建立 Codex 可检索的标准规则页。

### 下一步建议

- 下次用户说“安装 Git”或“新设备配置 Git”时，先读取 `Git 与 TortoiseGit Windows 标准安装规则`。
- 安装前重新核验 winget 包 ID、官方语言包 URL 和当前版本。

## 2026-07-10 Demo001 角色绑定知识文档整理

### 读取来源

- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/角色绑定.md` 的原始记录。
- Demo001 角色模型绑定 Studio 截图：源模型预处理、R15 命名、Head 网格替换、`SurfaceAppearance` 复制与脚本结果。

### 新增或更新页面

- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/角色绑定.md`
- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/assets/角色绑定/01-源模型与标准Rig.png`
- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/assets/角色绑定/02-上半身命名规范.png`
- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/assets/角色绑定/03-下半身命名规范.png`
- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/assets/角色绑定/04-Head-MeshId替换.png`
- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/assets/角色绑定/05-SurfaceAppearance复制.png`
- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/assets/角色绑定/06-脚本绑定结果.png`
- `30_MOC 内容地图/Roblox MOC.md`

### 关键决策

- 方案 A 固定为“保持标准 R15 Rig，批量替换 15 个身体 MeshPart 的网格与外观”。
- 批量脚本以标准 R15 后缀精确匹配源模型部位，避免用宽松的 `find()` 匹配到附件或名称相近对象。
- `SurfaceAppearance` 作为独立外观对象处理：先清理目标旧对象，再复制源对象；没有该对象时回退复制 `TextureID`。
- `WeldConstraint` / Attachment 方案仅保留为独立装饰部件的备选流程，待有完整实际案例后再补充脚本和操作步骤。

### 验证记录

- 角色绑定文档已包含 6 张本次操作截图、1 段可复用 Luau 脚本、15 个部位清单、Studio 验收清单与风险排查表。
- `Roblox MOC` 已加入项目知识文档入口。

### 下一步建议

- 下次使用非 R15 兼容角色时，先记录其部位层级、Attachment 名称和需跟随的 Rig 部位，再补充方案 B 的完整操作手册。

## 2026-07-10 Demo001 饰品 WeldConstraint 绑定补充

### 读取来源

- Demo001 头盔和肩甲绑定 Studio 截图：拖入 `Head`、对齐 CFrame Position、`WeldConstraint.Part0/Part1`、关闭物理干扰和肩甲缩放。

### 更新页面

- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/角色绑定.md`
- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/assets/角色绑定/07-头盔拖入Head.png`
- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/assets/角色绑定/08-头盔对齐Head位置.png`
- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/assets/角色绑定/09-WeldConstraint-Part0-Part1.png`
- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/assets/角色绑定/10-头盔物理属性.png`
- `10_Projects 项目/Roblox/1巅峰进化项目交接/Demo001更新/assets/角色绑定/11-肩甲对齐与缩放.png`

### 关键决策

- 单个 MeshPart 饰品统一按“拖入目标部位 -> 对齐位置/角度/大小 -> 创建 WeldConstraint -> 关闭物理干扰”的顺序操作。
- `Part0` 固定指向饰品自身，`Part1` 指向要跟随的 Rig 身体部位。
- `Anchored = false`、`CanCollide = false`、`Massless = true` 作为饰品绑定的必设属性。

## 2026-07-10 Demo001 MeshId 尺寸缝隙风险补充

### 关键决策

- 单纯替换 `MeshId`、`TextureID` 或 `SurfaceAppearance` 不能保证源模型与 Rig 的部位尺寸一致；躯干和四肢可能出现明显缝隙。
- 缝隙明显时，不建议继续靠逐件修改标准 Rig 的 `Size` 修补；应将源躯干或四肢作为外观外壳，使用 `WeldConstraint` 绑定到对应 Rig 部位。
- 保留标准 Rig 部位、关节和 Humanoid 负责动画与逻辑；源躯体部件只负责显示。

### 下一步建议

- 下次拿到多部件盔甲或背饰时，补充内部根部件选择与多 MeshPart 焊接的实际案例。

## 2026-07-11 Roblox 魔法杖多视图流程稳定性复盘

### 读取来源

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流V2/`
- 2026-07-11 精灵魔法杖正视图截断与侧视纸片化失败截图。

### 更新页面

- `README.md`
- `CHECKLIST.md`
- `PROMPT_TEMPLATES.md`
- `STATUS.md`
- `V2.1_稳定图片实验流程.md`
- `scripts/extract_fronts.py`
- `30_MOC 内容地图/Roblox MOC.md`

### 关键决策

- 固定列宽矩形只能定位目标，最终正视图改为遮罩扣图，并增加前景触边硬门禁。
- 废止“侧视宽度占整杖高度 6%-8%”的通用目标，改为杖身、宝石、托架、尾部的组件级深度合同。
- 视图顺序改为 `front -> left45 -> left90`，90°侧视同时参考正面和已确认的 45°图。
- 90°侧视同时检查相机角度和物体体积；过宽与过扁都拒绝。
- V2 当前降为 Review，待 3 类结构连续试跑通过后再升级为稳定版。
- 自动扣图脚本已在 10 把精灵魔法杖效果图上试跑，检测 10/10 个主体，并成功去除相邻法杖碎片；输出保留为审核候选，不自动进入最终目录。

## 2026-07-11 Roblox 魔法杖正式生产基线确认

### 读取来源

- `Roblox 魔法杖模型制作工作流V2` 的裁切失败与侧视纸片化复盘。
- Verdant Aurora Wand 六视图实跑结果与用户审核结论。

### 新增或更新页面

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/README.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/CHECKLIST.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/PROMPT_TEMPLATES.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/RUN_TEMPLATES.md`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/STATUS.md`
- `30_MOC 内容地图/Roblox MOC.md`

### 关键决策

- 新目录升级为当前正式入口；V2 目录保留为历史实验与失败复盘。
- 固定执行顺序为“效果图筛选 -> 单独确认 front -> left45 深度桥 -> 严格 left90 -> 镜像成对视图 -> back”。
- 用户确认 `front.png` 前禁止生成任何其他视图。
- 对称物体的 `right/right45` 由合格的 `left/left45` 镜像，减少独立生成漂移。
- 侧视采用角度门禁与组件级体积门禁，不再追求全局最窄轮廓。
- 默认只交付 6 张图，不生成缺少可靠三维证据的 `top/bottom`。

### 验证记录

- Verdant Aurora Wand 的厚晶体、四片托架、圆柱杖身、双金环和圆润尾帽在六视图中保持一致。
- 用户明确确认该版本效果很好，并指定为最新框架。

## 2026-07-13 通用游戏素材道具多视图工作流建立

### 读取来源

- `81_WorkFlow 工作流/Roblox/模型相关/Tripo多视图工作流/`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法杖模型制作工作流/`
- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法书模型制作工作流/AI道具模型参考图工作流/`
- 彩虹闪电户外跑步机六视图实跑与卡顿恢复记录。

### 新增或更新

- 新增 `81_WorkFlow 工作流/Roblox/模型相关/Roblox 通用游戏素材道具制作工作流/`。
- 更新 `Tripo多视图工作流/README.md` 到 v1.4。
- 更新 `30_MOC 内容地图/Roblox MOC.md`。
- 更新 `70_LLM_Wiki 知识库/Roblox/index.md` 与 `Tripo 多视图工作流.md`。

### 关键决策

- 通用入口支持 4 / 6 / 8 视图，不再默认强制所有道具生成顶底图。
- 复杂落地长体和开放框架默认使用 `front -> left45 -> left90 -> mirror pair -> back` 六视图链。
- `front` 通过后，用户可授权批量继续；批量只减少人工停顿，不取消设计锁和一致性门。
- 对称右侧图改为本地确定性镜像，往返像素差必须为 `0`。
- 图像生成沉默时必须恢复原任务，不得重复提交。
- 正式图只允许等比归一化；最终目录按视图集执行文件白名单。

### 验证

- `Finalize-PropMultiview.ps1` 已在彩虹闪电跑步机六视图上实跑，返回 `FINALIZATION_OK`。
- 6 张正式图统一为 `1536x1024`；左右与左右 45°镜像检查均为 `0` 差异。
- 新流程当前为 Review，等待闭合体、非对称体和轴向关键体继续验证。

## 2026-07-14 通用道具工作流 v1.2 与 RPG 批量生产门

### 读取来源

- `81_WorkFlow 工作流/Roblox/模型相关/Roblox 通用游戏素材道具制作工作流/` v1.1 文档与脚本。
- 跑步机四款批次的联系表、正式 PNG、批次索引和目录结构；只作为审计证据，不继续加工跑步机。
- 当前知识库规则、Roblox MOC 和工作流注册表。

### 新增或更新

- 更新 `README.md`、`CHECKLIST.md`、`PROMPT_TEMPLATES.md`、`RUN_TEMPLATES.md`、`FAILURE_CODES.md`、`WORKFLOW_REGISTRY.md`、`STATUS.md`。
- 新增 `NORMALIZATION_CONTRACT.md` 与 `RPG_BATCH_PROFILE.md`。
- 重构 `scripts/Finalize-PropMultiview.ps1`，新增 `scripts/Approve-PropMultiview.ps1`。
- 新增 `tests/Test-PropMultiviewWorkflow.ps1`。

### 关键决策

- 把画布尺寸、同一道具跨视图主体比例、Roblox 游戏内 Studs 尺度拆成三层合同。
- 新运行必须具备 Identity Lock、结构锁、运行状态、提示词记录和归一化 JSON。
- 自动归一化只允许整体等比修正；默认超过 `10%` 返回 `SUBJECT_SCALE_DRIFT`，不允许用后期缩放掩盖几何漂移。
- 脚本机械成功状态改为 `FILES_READY`，结果先进入待审核目录；人工批准联系表后才生成正式上传目录。
- 待审核目录新增 SHA-256 清单；文件在审批前发生变化时阻断正式发布。
- RPG 批量生产先验证药水瓶、宝箱、长轴武器和非对称任务道具，再锁定批量阈值。

### 验证与下一步

- 集成测试覆盖：主体 / 接地归一化、待审核到正式审批、比例漂移阻断、身份文档门、异常背景门、批次索引门和待审核文件篡改阻断。
- 当前仍为 Review；自动化只证明脚本行为，下一步需要真实 RPG 道具和 3D 结果验证。

## 2026-07-14 通用道具工作流 v1.3 低模精简

### 读取来源

- 用户对炼狱红莲、幻彩之莲的实际生成反馈。
- `Roblox 通用游戏素材道具制作工作流` v1.2.1 文档、脚本和测试。
- Vault 规则、Roblox MOC 和 LLM Wiki 索引。

### 新增或更新

- 新增 `快速执行卡_QUICK_START.md`。
- 新增 `下一对话交接_重新生成前两个RPG道具.md`。
- 精简 `README.md`、`CHECKLIST.md`、`PROMPT_TEMPLATES.md`、`RUN_TEMPLATES.md` 和 `RPG_BATCH_PROFILE.md`。
- 更新归一化合同、失败代码、注册表、状态页、Finalize 脚本和集成测试。
- 更新 Roblox MOC 与 Roblox Wiki 索引入口。

### 关键决策

- Roblox 道具默认追求少量大形体、清楚轮廓、受控倒角和简单材质区；不以密集碎片、随机切面和微几何制造精致感。
- 新运行把三份设计合同合并为一份资产锁，只保留正视图和联系表两个人工门。
- 装饰性重复结构不默认逐片计数，只有身份关键部件使用精确数量。
- 新流程使用 v1.3 精简文档，同时保留 v1.2 详细文档兼容。
- 红莲和幻彩莲保留 Six 视图规格，但必须从原始卡面重新制作正视图，不沿用旧高细分图作设计锁。

### 验证与下一步

- 8 项脚本集成测试全部通过，包括 v1.3 精简路径和 v1.2 向后兼容。
- 下一步在新对话先验证炼狱红莲低模正视图，再扩展六视图并检查实际 3D 结果。

## 2026-07-17 Roblox 框架教学模式 v1.0

### 读取来源

- YanzoFrame_V2_JumpGame 跑步机训练纵向切片的实际实现与排错过程。
- 当前 Vault 规则、LLM Wiki Schema 与 Roblox MOC。

### 新增或更新

- 完成 `81_WorkFlow 工作流/Roblox/框架相关/框架教学模式.md`。
- 在 `30_MOC 内容地图/Roblox MOC.md` 增加工作流入口。

### 关键决策

- 用户默认先实现，Codex 按思路、伪代码、骨架、核心片段逐级辅助。
- 把服务器权威、客户端镜像、真实玩法、持久化和生命周期清理拆成五个完成层级。
- 用户保存后必须读取真实文件并执行静态检查；Studio 验收必须覆盖与功能有关的生命周期边界。
- 具体游戏规则先留在游戏项目；只有经过至少两个真实场景验证的稳定语义，才记录为框架升级候选。

### 验证与下一步

- 工作流以 JumpGame 的多跑步机、重生清理和动画轨道重建为真实验证来源。
- 下一步回到 JumpGame，先把 Speed 持久化接入 `StorageService`，仍按一个可见纵向切片推进。

### 三轨目标补充

- 新增 `81_WorkFlow 工作流/Roblox/框架相关/YanzoFrame 框架优化候选记录.md`。
- 固定“JumpGame 真实验证 → Hotpot 定点对照 → YanzoFrame V1 独立优化 → JumpGame 回归”的路径。
- 首个候选为 YF-001：Logger 的 Debug、Info、Warn 缺少业务调用位置，Studio Output 只能定位到 `Logger.lua`。
- Hotpot 只作为商业框架参考；没有完成具体源码对照前，不把猜测写成已采用方案。
- 新增 YF-002：系统 PATH 中的 Cargo StyLua 覆盖 Rokit 锁定工具，造成 Luau 类型语法误报；先记录为工程化候选，不在当前 Speed 存储步骤顺手修复。
- 新增 YF-003：StorageService 缺少统一的数据就绪等待入口；先由 JumpGame 的 SpeedService 验证轮询边界，出现第二个真实消费者后再决定是否提升到 V1。

## 2026-07-23 ElevenLabs 游戏宣传 BGM 工具卡

### 读取来源

- 本次 `Peak Evolution` 47 秒宣传视频的 ElevenLabs Studio 实操：Music v2 候选生成、时间线叠轨、MP4 导出和音频导出限流。
- ElevenLabs 的 Music、Studio 与 Music v2 官方说明。
- 当前 Vault 规则、AI 编程与产品 Wiki 入口及 AI 编程与产品 MOC。

### 新增或更新

- 新增 `70_LLM_Wiki 知识库/AI_Programming_Product/ElevenLabs 游戏宣传 BGM 实操与复用清单.md`。
- 更新 `70_LLM_Wiki 知识库/AI_Programming_Product/index.md` 与 `30_MOC 内容地图/AI 编程与产品 MOC.md` 的入口链接。

### 关键决策

- 将 ElevenLabs 定位为“BGM 候选生成 + 轻量宣传片音频整合”，不把生成音乐直接等同于可上线成片。
- 明确区分已验证的 Studio 基础混音/MP4 导出、需人工试听的 Music v2，和仍需 PoC 的音频单独导出、配音、音效与多语言能力。
- 套餐、余额、自动续费和导出限制均按时间敏感信息记录；后续运行前必须在平台页面复核。

### 验证与下一步

- 本次确认笔记、AI Wiki 索引和 MOC 已互相链接；纯 BGM MP3 因导出频率限制未完成，保留为下一轮独立验收项。
- 下一步优先验证中文 TTS、Roblox 音效导入和纯 BGM MP3 导出，再决定是否把 ElevenLabs 扩展到生产流程。

## 2026-07-24 YanzoFrame 可穿戴 Accessory 流程候选

### 读取来源

- `YanzoFrame_V2_JumpGame` 黑鞋的 Studio Play 实测、`ShoeService.lua` 与 `ServerStorage` 模板结构。
- Accessory 挂载与漂浮道具知识卡、Vault 规则与 Roblox MOC。

### 新增或更新

- 更新 `81_WorkFlow 工作流/Roblox/框架相关/YanzoFrame 框架优化候选记录.md`，新增 `YF-010`。

### 关键决策

- 记录“模板对齐、服务器 Clone + AddAccessory、标记清理、重生恢复、Studio 验收”的可复用流程。
- 不把黑鞋 ID、左右脚路径或装备存档规则抽进 V1；至少等待第二种真实饰品验证。

### 验证与下一步

- 黑鞋左右模板在运行时均生成 `AccessoryRigidConstraint`，脚部 Attachment 误差为 `0.000000`。
- 下一步在 JumpGame 只完成黑鞋展示模型的客户端悬浮，继续使用服务器触碰解锁，不引入 ProximityPrompt。

## 2026-07-29 AI 道具参考图与剑类入口升级

### 读取来源

- 五件高凸魔法书道具、40 张正式 8 视图及 Tripo / 混元 AI 建模反馈。
- `Roblox 魔法书模型制作工作流/AI道具模型参考图工作流`。
- `Roblox 武器模型制作工作流` 的旧三视图流程和风格一致性失败复盘。

### 新增或更新

- 更新 AI 道具参考图工作流的 `README.md`、`EFFECT_TO_8VIEW.md`、`CHECKLIST_8视图自检.md`、`PROMPT_TEMPLATES.md` 与 `STATUS.md`。
- 新增 `DESIGN_LOCK_TEMPLATE.md`。
- 新增 `Roblox 武器模型制作工作流/剑类效果图到多视图_V2.md`，并更新武器工作流入口说明。

### 关键决策

- 效果图只锁视觉身份与结构设计，不锁透视和侧面曝光。
- 用视觉 DNA 锁、几何锁、关键零件 P-ID、固定数量和表面归属约束跨视图一致性。
- 顶/底视图必须记录正面轨道与背面轨道归属，禁止把正面高凸装饰复制到两侧。
- 图片生成与 FBX / GLB 打包继续解耦；剑类先确认一张效果图，再进入工程多视图。

### 验证与下一步

- 已将魔法书实测暴露的箍带数量漂移、端盖多余晶体、开放端封闭和远侧面翻出问题写成一票否决项。
- 下一步用同系列剑效果图验证新入口，再根据实际 3D 结果补充剑刃厚度与护手连接失败类型。
- 已用“幻彩圣裁巨剑”完成首套 8 视图验证，并补充长剑 top/bottom 轴向端视规则、正面装饰表面归属和纯 8 PNG 最终上传目录门禁。

## 2026-07-29 Tripo 武器局部纹理修复与 Roblox 导入闭环

### 读取来源

- 当前 Tripo 低模长剑、原始 Base Color、修复后 Blender 文件和 3D 视图反馈。
- `Roblox 武器模型制作工作流`、`Roblox 可直接导入版打包流程`。
- Roblox Creator Hub 的 Importer、Reimport、Texture specifications 与 MeshPart 文档。

### 新增或更新

- 新增 `81_WorkFlow 工作流/Roblox/模型相关/Roblox 武器模型制作工作流/Tripo武器低模清理与局部纹理修复流程.md`。
- 更新武器工作流 `README.md`、`Roblox导入_直接可用打包流程.md`、`STATUS.md` 与 `工作记录.md`。
- 将武器目录的旧打包脚本改为相对路径兼容入口，权威实现继续由 `Roblox 可直接导入版打包流程` 维护。
- 更新 `70_LLM_Wiki 知识库/Roblox/Roblox 武器模型导入打包工作流.md`。
- 更新 `30_MOC 内容地图/Roblox MOC.md` 的武器工作流入口。

### 关键决策

- 原 Tripo 纹理大部分可用时，禁止重画整张 UV 图集。
- 局部修复必须从原 Base Color 开始，保护非目标 UV，并同时检查正面、侧面和异常面。
- 2K 保留为 Blender 修复母版；Roblox 默认交付 512，只有目标游戏近景确认模糊后才测试 1024。
- Blender 回导和 Roblox Studio 验收是两个独立完成门。
- 武器工作流只负责路由，通用打包器保持单一权威实现，避免不同道具目录复制后规则漂移。

### 验证

- 修复模型保持 `1466` 顶点、`2928` 三角面和 `UVMap`。
- FBX 与 GLB 回导均保持 `2928` 三角面并识别 512 贴图。
- 通用脚本返回 `ROBLOX_WEAPON_EXPORT_OK`、`source_texture_mode=external_file`、`direct_fbx_texture_mode=external_relative`、`fbx_scale_mode=match_glb_world_scale` 和 `fbx_glb_scale_match=True`。
- 首轮标准打包发现旧版固定 `global_scale=0.01` 会把已正常化 FBX 缩小 100 倍；脚本已改为 `global_scale=1` 并加入 FBX / GLB 自动回导包围盒门禁。
- Studio 游戏内比例、贴图和挂载方式仍需人工验收。

## 2026-08-04 Roblox 魔法剑 8 视图工作流落地

### 读取来源

- 现有 `Roblox 武器模型制作工作流/剑类效果图到多视图_V2.md`。
- 魔法书和魔法杖的通用 8 视图门禁。
- 2026-08-03 完成的 5 把魔法剑、40 张正式视图、4 张隔离失败稿和对应设计锁记录。

### 新增或更新

- 新建 `81_WorkFlow 工作流/Roblox/模型相关/Roblox 魔法剑模型制作工作流/`。
- 新增主流程、设计锁模板、Prompt 模板、8 视图自检清单、状态说明和参数化验收脚本。
- 更新 `30_MOC 内容地图/Roblox MOC.md`，加入魔法剑工作流入口。

### 关键决策

- 工作流只负责效果图到 image-to-3D 参考图，与 Blender 清理和 Roblox 打包解耦。
- 使用 X/Y/Z 三轴归一化：front/back 为 X×Y，left/right 为 Z×Y，top/bottom 为 X×Z。
- top/bottom 是沿剑长轴观察的轴向端视图，可对 X/Z 同倍放大到画布长边 60%-80%，禁止单轴拉伸。
- 45 度图必须旋转整把剑；对称资产优先镜像已通过的一侧。
- 正式上传目录必须恰好包含 8 张同尺寸正方形 PNG。

### 验证

- `Validate-8ViewSet.ps1` 已对 5 个真实上传目录执行，共验证 40 张图片。
- 5 组均返回 `VALIDATION_PASSED`，文件名、数量、解码和尺寸一致性全部通过。
- 视觉相机、结构连接和 image-to-3D 结果仍保留人工验收门。

## 2026-08-04 AI x 3D 游戏道具课程笔记

### 读取来源

- `AI x 3D — 从创意到游戏角色` 原声第 4 课视频目录、课程摘要、提示文件与示例工程清单。
- 同课程原声第 7 课视频目录、课程摘要、提示文件与纹理素材清单。
- Blender 官方 Face Orientation、Image Settings 与 Normal Map 文档。
- Modddif 当前 Texture、Subscription、Project Privacy 与 Blender 导入说明。
- 现有 Roblox 通用道具、武器模型和 512 贴图打包规则。

### 新增

- `20_Areas 领域/3D建模/AI x 3D 第4课｜游戏道具拓扑重构与优化.md`
- `20_Areas 领域/3D建模/AI x 3D 第7课｜游戏道具纹理与 PBR 贴图.md`

### 关键决策

- 只保留刚性游戏道具需要的拓扑、UV 前置、烘焙衔接、AI 纹理、PBR 和质量门禁，删除角色关节、眼睛和绑定内容。
- 修正课程提示文件中 Face Orientation 红蓝含义写反的问题：Blender 外侧通常应为蓝色，红色表示背面。
- 修正课程摘要把 AO 一律归为 sRGB、Emission 一律归为 Non-Color 的过度简化；按颜色贴图与数据贴图区分。
- 保留 2K 作为 AI 生成和修复母版，沿用现有项目约定输出 512 游戏版；是否升到 1024 由实机近景验收决定。
- 明确 Modddif 当前免费项目为公开项目，课程中的免费私有项目演示不再作为现行规则。

### 验证与下一步

- 已检查两份 Markdown 的 UTF-8、frontmatter、标题、双向链接和代码围栏。
- 后续如继续整理第 5、6 课，可沿用相同“游戏道具输入 / 输出合同 + 质量门禁”结构。

## 2026-08-05 DMIT 服务器 3x-ui / Xray 运维手册

### 读取来源

- 20_Areas 领域/VPS/3XUI搭建.md：确认它是 Docker 部署方案，不能用于当前原生 systemd 安装。
- 当前 DMIT 服务器的只读核验：Ubuntu 22.04.5、3x-ui 3.6.0、Xray 26.7.28、x-ui.service。
- 本次升级、REALITY 兼容性排障与 v2rayN 连接测试记录。

### 新增

- 20_Areas 领域/VPS/DMIT服务器_3X-UI_Xray运维操作手册.md

### 关键决策

- 保留旧 Docker 笔记，不覆盖用户原始内容；新手册明确限定为当前原生 systemd 安装。
- 连接信息采用占位符，不记录私钥、面板路径、UUID 或完整订阅。
- 将“流量耗尽”和“升级后的 REALITY 兼容性”拆成两条故障路径，避免误判为同一个问题。
- 数据库批量操作只作为高级路径，要求先备份、先验证、再重启服务。

### 当前状态与下一步

- 当前发现 16 个入站：15 个为 30GB/月/每月 1 日重置，Backup-01 仍为不限量且不重置，未经用户确认不自动修改。
- 全部 16 个 REALITY 入站已配置 minClientVer = "0.0.0" 以兼容较旧客户端；这有 Xray 明确提示的 IP 封锁风险。
- 后续以 v2rayN 实测和客户端 Xray-core 升级结果为准，再决定是否恢复更严格的最低客户端版本。

## 2026-08-08 YanzoFrame 新项目初始化候选

### 读取来源

- `81_WorkFlow 工作流/Roblox/框架相关/YanzoFrame框架优化V2.md`。
- 独立 Boss Trial 项目 `YanzoFrame_GameAnimationEffects` 的项目名、Logger、Remote、Storage 与开发者面板实现。

### 更新

- 在 `YanzoFrame框架优化V2.md` 追加“新项目身份初始化与开发者面板默认状态”候选。

### 关键决策

- 新项目身份配置和 Studio 调试面板默认收起，先作为复制框架后的项目内流程记录，不直接上移为 YanzoFrame 正式能力。
- 将持久化命名空间改名列为高风险动作：仅允许新项目初始化，已上线项目必须另行走迁移决策。

### 验证与下一步

- `YanzoFrame_GameAnimationEffects` 已完成静态检查和 Studio Play：开发者面板默认收起，展开/收起按钮均可用。
- 等第二个独立项目复验后，再评估 `ProjectIdentityConfig` 与初始化工具是否应进入框架。

## 2026-08-12 模型多视图侧向可见性门统一

### 读取来源

- Roblox 通用道具、Tripo 武器、魔法剑、魔法杖、魔法书 / AI 道具多视图工作流及其提示词、检查表和运行模板。
- `70_LLM_Wiki 知识库/Roblox/Tripo 多视图工作流.md` 检索摘要。

### 更新

- 统一加入 `SIDE_VISIBILITY_CONTRACT`：生成 `left/right` 及对应 45 度视图前，Codex 必须主动询问并复述每个观察方向必须看见、必须隐藏的结构。
- 对方向性结构记录零件 ID / 数量 / 位置 / 顺序 / 遮挡；用户确认后才能生成。
- 移除“先判断对称或非对称，再默认镜像”的执行分流。镜像默认未授权，只有用户明确指定来源与目标文件时才允许，并记录授权。
- 统一失败码：`SIDE_VISIBILITY_CONTRACT_MISSING`、`SIDE_VISIBILITY_CONTRACT_BROKEN`、`UNCONFIRMED_SIDE_MIRROR`。
- 通用道具最终化脚本公开参数改为 `-ApprovedMirrorPairs`，旧 `-SymmetricPairs` 仅保留兼容别名。

### 验证与边界

- 两个 Codex 模型技能通过 `quick_validate.py`。
- 通用道具 PowerShell 脚本解析通过，8 项现有回归测试全部通过。
- 已检查相关 Markdown 代码围栏与旧默认镜像规则；历史运行记录、已完成输出、鞋子配对规则和 Blender Mirror 修改器教程未改动。

## 2026-08-13 Roblox 本地美术迭代画布工作流

### 读取来源

- `D:\AI\Codex\Codex_3DModel\art_iteration_board` 的本地画布事实源与追加记录脚本。
- Roblox 多视图、AI 道具参考图与现有 Prompt/视角约束工作流。

### 新增与更新

- 新增 `81_WorkFlow 工作流/Roblox/美术相关/本地美术迭代画布工作流/`：部署、单轮记录与放大复核、新对话迁移分流，以及资产 Brief / 迁移 Prompt 模板。
- 为本地画布补充项目根目录参数：可初始化任意项目的 `art_iteration_board`，并以 `-BoardRoot` 启动和写入。
- 在 `30_MOC 内容地图/Roblox MOC.md` 增加工作流入口。

### 关键决策

- 原图、`board.json`、`iterations/Ixxx.json` 是可迁移事实源；无限画布仅是本地显示层。
- `Accepted` 是下游专用工作流的唯一可用母版；候选、复核和淘汰图保留为诊断证据但不能作为后续编辑来源。
- 新开对话由资产状态/任务类型变化触发，而不是机械地每一轮必开。

### 验证与下一步

- 待在新项目路径运行初始化脚本并通过 `/health`、`/api/board` 和一次真实 `I001` 写入复验。
- 首次把实际的角色立绘或三视图任务接入时，补充其对应专用美术流程；不在本工作流中猜测具体角色/资产合同。

### 2026-08-13 退役说明

- 用户已确认改用已有的 Obsidian Excalidraw 作为无限画布，不再使用本地网页画布。
- `D:\Applications\ArtIterationCanvas`、`D:\AI\Codex\Codex_3DModel\art_iteration_board` 和对应工作流目录已送入 Windows 回收站；已移除 Roblox MOC 入口。
- 本日志保留为决策历史，不再把该工作流作为可执行入口。

## 2026-08-13 Roblox 高级武器模型制作工作流

### 读取来源

- 猫猫剑从完整效果图、四部件拆分、逐件多视图、混元/Tripo 输入到 Blender 拼接、材质、FBX 和 Studio 导入的实测产物。
- 现有 Roblox 魔法剑、Tripo 多视图、通用道具、AI 网格清理和 Roblox 可直接导入版打包流程。

### 新增与更新

- 新增 `81_WorkFlow 工作流/Roblox/模型相关/高级武器模型制作/`：总入口、快速执行卡、立项/拆件、多视图、Blender/材质/FBX、Studio、检查表、失败码、模板、注册表和猫猫剑案例复盘。
- 在 `30_MOC 内容地图/Roblox MOC.md` 与 `70_LLM_Wiki 知识库/Roblox/index.md` 增加入口。

### 关键决策

- 新目录只做端到端总编排；相机、多视图归一化、AI 网格清理和格式打包继续引用现有权威工作流，避免复制第二套实现。
- 左右侧视不再用“是否对称”作为默认判断；每个输出文件必须先有摄像机、可见/隐藏、数量/位置、遮挡、厚度和接口合同。
- 项目状态改为 required 部件的汇总 Gate；单部件通过只更新部件状态，不能提前推进整把武器。
- Blender 预览程序材质与 Roblox 可迁移贴图明确分离；FBX 必须回导验证后才能进入 Studio。
- 动画、Trail、粒子、动态灯光和运行时 VFX 不属于模型主流程；只能在 `STUDIO_ACCEPTED` 后另立任务。

### 验证与下一步

- 本版本按猫猫剑真实产物完成规格与事实核对，状态保持 `Review`。
- 待使用本流程从零完成另一把拆件型高级武器后，再根据偏差升级为 `Approved`。

## 2026-08-14 高级武器部件视图冗余门

### 读取来源

- 冰晶战锤拆件运行中“近似轴对称手柄只需正视图”的用户确认。
- `高级武器模型制作` 现有部件多视图、侧向可见性、运行状态和交付门禁。

### 新增与更新

- 在高级武器流程加入部件级 `VIEW_REDUNDANCY_GATE` 与 `VIEW_SET_CONTRACT_TEMPLATE.md`。
- 同步更新主入口、部件多视图流程、快速执行卡、项目锁/运行状态模板、检查表、失败码和注册表。

### 关键决策

- 近似轴对称或四向信息高度重复只能成为提问触发条件，不能自动推出单正视图。
- Codex 必须先询问用户；只有绑定明确用户原话与日期，才能采用 `FRONT_ONLY_USER_APPROVED`。
- 未明确授权时继续 `MULTI_VIEW` 与逐侧可见性合同；单正视图模式只豁免冗余方向，不豁免接口、厚度或 Blender 精确重建证据。

### 验证与下一步

- 冰晶战锤手柄已记录为本次首个 `FRONT_ONLY` 实例；锤身仍按体块型多视图继续。
- 后续再遇到类似零件时，先执行冗余门，不再先生成多余方向后补判断。

## 2026-08-14 高级武器 45° 空间桥接修复门

### 读取来源

- 冰晶战锤锤身的基础四视图、首轮混元 3D 结果截图，以及用户确认的 `left45/right45` 辅助视图；首轮失败模型文件与平台 task ID 未取得，均明确记录为 `NOT_AVAILABLE`。
- `高级武器模型制作` 的多视图、运行状态、检查表、失败码和注册表。

### 新增与更新

- 将流程升级为 `v1.3`，新增部件级 P5A `VIEW_EVIDENCE_REPAIR` 回路。
- 新增 `CROSS_SECTION / END_PROFILE` 几何卡、45° 正交相机合同、正式生图两次上限和并行最小参考集规则。
- 新增首轮 P5A 输入 Manifest、平台截图、SHA-256 与结论记录；没有持久证据不得触发辅助 45° 正式包。
- 基础包继续使用 `00_final_image_to_3d_upload`；只有 P5A 触发后才创建恰好含两张图的 `01_auxiliary_45_upload`。
- 新增 [[../81_WorkFlow 工作流/Roblox/模型相关/高级武器模型制作/冰晶战锤45度空间桥接复盘|冰晶战锤45度空间桥接复盘]]。

### 关键决策

- 六视图不是高级武器默认。先用单正视图或基础四视图试模，再依据 P5A 的真实网格证据决定是否补左右 45°。
- front-only 若证据不足，必须先经用户批准升级并完成基础四视图；不能从单图直接跳到辅助 45°。
- 基础四图与辅助两图物理分目录，平台提交时才按槽位组合 `4 + 2`，避免基础包与修复证据混淆。
- 45° 必须为正交 yaw ±45°、pitch/roll 0°；近远同源结构无透视缩放，平端面不能球化，中央机构只能随刚体旋转而压缩。
- 候选先过几何再清背景；正式统一画布只允许平移与补边，不得逐图缩放。
- 外部归一化合同在本流程中只按 `measure-only / padding-only` 使用，禁止主体自动缩放；允许裁去纯背景后等量补边，但不能裁切物体。
- 同一正式视图连续两次失败后停止盲目生图，转回合同/Proxy 或 Blender 正交块模。

### 验证与下一步

- 冰晶战锤的两张辅助 45° 已提升到稳定目录并记录哈希；工作流文档与模板已同步。
- 下一步用基础四图加辅助两图重生成锤身，并把新一轮 P5A 结果写回案例；通过后再判断工作流是否可从 `Review` 升级。

## 2026-08-14 多零件模型 Roblox 直接导入工作流

### 读取来源

- 猫猫剑四部件 FBX 的已知成功 Studio 导入结果。
- 冰晶战锤两部件导出失败记录、干净 v04 导出副本、Manifest 与 Blender 空场景回导报告。
- Roblox 官方 FBX 导出、纹理、单位和 3D Importer 文档。
- 现有高级武器模型制作与单体模型兼容打包流程。

### 新增与更新

- 新增 `81_WorkFlow 工作流/Roblox/模型相关/多零件模型转为roblox可导入文件/`：主入口、Blender 导出副本、材质/纹理/FBX、回导/Studio、快速执行卡、检查表、失败码、Manifest 模板与案例复盘。
- 在 Roblox MOC 和 Roblox Wiki 增加入口。
- 高级武器工作流改为按输入类型路由：已装配多零件 Blender 文件走新流程；下载站单体模型包、伪 FBX 和 `.fbm` 兼容问题继续走旧打包流程。

### 关键决策

- “一个可直接导入 FBX”不等于“一个 MeshPart”；正式语义零件继续保持独立 Mesh，并共享同一公共 Pivot 和坐标系。
- Blender 必须完成拼接、比例、单位、材质归属和公共枢轴；Studio 不重新手工对位，只设置根件、Weld 和碰撞策略。
- 每个 Mesh 默认一套可迁移材质；贴图扩展名必须与真实编码一致。正常内嵌 FBX 导入只选 FBX，外部贴图目录作为事实源和回退证据。
- 单位只允许一种策略；禁止顶点缩放、对象 100 倍缩放和导出 `0.01` 同时补偿。
- 最终 FBX 必须先在空 Blender 场景回导并与 Manifest 对比；本地回导通过与 Studio 云端验收分开记录。
- Studio 红叉但没有详细错误时，使用已知成功 FBX、无贴图候选和单独贴图上传做 A/B，不靠警告日志猜根因。

### 验证与下一步

- 猫猫剑保留为 Studio 已知成功控制组。
- 冰晶战锤 v04 已通过 Blender 空场景回导，并由用户于 2026-08-14 确认成功导入 Studio；正式文件 SHA-256 为 `B97DF67DACC971B7CDAF067C2DBE697109DBFFE11D4750446B67DC6426934CE4`。证据支持 `studio_import=PASS`；Root/Weld/碰撞与 Play 未单独记录，因此 `runtime_assembly=NOT_RECORDED`，不把完整 P9 过度标为 `STUDIO_ACCEPTED`。
- v04 的 `.png` 名称实际承载 JPEG 编码，但本次仍成功导入；因此该现象只记录为兼容性偏差，不视为失败根因，也不升级为推荐做法。
- 下一次完成新的多零件资产时，用本流程的 Manifest 和检查表复跑；连续两个 Studio 成功案例后，再考虑抽象通用自动导出脚本。

## 2026-08-14 高级武器 Blender/FBX 主流程与新项目冷启动

### 读取来源

- 猫猫剑与冰晶战锤的 Blender 导出、纹理内嵌、空场景回导和 Studio 导入证据。
- `高级武器模型制作` 与 `多零件模型转为roblox可导入文件` 的现行主入口、模板、清单和失败码。

### 新增与更新

- 将高级武器流程升级到 `v1.4`，把多零件直导专项设为 P8 权威执行入口，而不是可选参考链接。
- 将 P8 拆为 `P8A EXPORT_COPY_READY`、`P8B FBX_EXPORTED`、`P8C FBX_REIMPORT_VERIFIED`，补齐对象白名单、公共 Pivot、逐件 `0/0/1`、唯一单位策略、真实贴图格式、`Copy + Embed` 和空场景回导合同。
- 新增 [[../81_WorkFlow 工作流/Roblox/模型相关/高级武器模型制作/新武器_新对话启动模板|新武器新对话启动模板]]，加入 `NEW_PROJECT_BOOTSTRAP` 和案例参数隔离门。
- 同步更新 PROJECT_LOCK、RUN_STATE、EXPORT_MANIFEST、Quick Start、Checklist、Failure Codes、Registry、Studio 验收与案例复盘。

### 关键决策

- Blender 必须完成多零件拼接和公共坐标；Studio 只创建 Root/Weld/碰撞等运行结构，不重新手工拼位置。
- `.blend` 的“打包资源”不等于 FBX 的“内嵌纹理”；正式 FBX 必须使用 `Path Mode=Copy` 并点亮 `Embed Textures` 小包裹。
- 回导信息采集脚本当前不能单独签发 PASS；必须与 Manifest 人工比较缺失字段，直到验证器升级。
- `FBX_REIMPORT_VERIFIED`、`studio_import=PASS` 与 `STUDIO_ACCEPTED` 分层记录；导入显示成功不能替代 Root/Weld/Play 验收。
- 新项目只继承 Gate、命名和验证规则；拆件、尺寸、轴向、接口、视图数、Root 和预算全部重新确认。

### 验证与下一步

- 下一把武器应从新对话启动模板进入，只完成 P0 后等待用户确认，不提前生图。
- 第三把武器完整跑通后，再根据新偏差决定是否把高级武器流程从 `Review` 升级为 `Approved`。

## 2026-08-15 狼首月牙战斧：自定义视图集与正式参考打包

### 读取来源

- 狼首月牙战斧的用户确认记录、斧头四视图、斧柄正视与严格 90° `Side A`，以及被拒绝的三分之四/过度压扁侧视候选。
- `高级武器模型制作` 的主入口、多视图执行规范、视图合同、Manifest、检查表、失败码、运行状态模板和注册表。

### 新增与更新

- 新增 [[../81_WorkFlow 工作流/Roblox/模型相关/高级武器模型制作/狼首月牙战斧_视图合同与正式参考集复盘|狼首月牙战斧视图合同与正式参考集复盘]]。
- 工作流升级到 `v1.5`：新增 `PART_VIEW_CONTRACT_GATE`，以 `required_final_views / not_required_views` 和用户原话锁定每件正式图，而非固定套用 1 张或 4 张。
- 允许不对称件使用语义化 `Side A / Side B`，并将严格侧视升级为单相机正交合同：`camera_count=1 / ORTHOGRAPHIC / yaw / pitch / roll`。
- 新增 `critical_side_profile`：严格 90° 侧视仍必须保留合同要求的狼首、尾环、端面等立体局部剪影与厚度。
- 增加项目级 `00_formal_model_references/` 与 `FORMAL_REFERENCE_SET.md`，将用户确认参考图与候选、历史未选图、联系表和平台输入包分离。

### 关键决策

- 两张、四张或其他有证据的视图集可以作为正式建模参考，但必须由用户明确指定文件语义与排除项；已确认但未选的历史图保留而不混入交付。
- 平台槽位不匹配时，先记录限制并由用户决定补图或改用其他建模路径；禁止复制、翻转、镜像或把候选改名凑数。
- 每张候选继续一张一张生成、给出准确路径并由用户逐图确认。

### 验证与下一步

- 当前案例的正式参考目录已核对为 6 张 PNG；与确认源图逐字节一致，尺寸正确，角点背景均为 `#B3C0C5`。
- 本案例仍停留在图生 3D 前，尚未验证 Tripo / 混元对当前图数的接受情况；下一步只在用户明确启动建模后执行。

## 2026-08-17 多零件 Roblox 导入包：GLB 主交付升级

### 读取来源

- `多零件模型转为roblox可导入文件` 的入口、导出、回导、检查表、失败码和 Manifest。
- 黑曜狼首月牙战斧 v03 内嵌贴图 FBX 的 Studio 红叉截图。
- v04 四格式工厂空场景回导报告，以及用户对主 GLB 的 Studio 成功确认。

### 新增与更新

- 将多零件工作流从“内嵌贴图 FBX 单主交付”升级为“短英文路径 GLB 快速通道 + 按需生成外置 FBX / 纯网格 FBX / 内嵌 FBX 回退”。
- 更新 README、导出合同、Studio A/B 分流、快速执行卡、检查表、失败码和 Manifest 模板。
- 新增 [[../81_WorkFlow 工作流/Roblox/模型相关/多零件模型转为roblox可导入文件/案例_黑曜狼首月牙战斧_GLB导入复盘|黑曜狼首月牙战斧 GLB 导入复盘]]。
- 新增 `scripts/Export-RobloxMultiPartGlbFast.ps1` 与 `scripts/export_multi_part_glb_fast.py`：默认只输出主 GLB 和自动验证 JSON，不保存源 `.blend`。

### 关键决策

- 顶层只放一个带真实三角面和贴图尺寸命名的主 GLB；只有 GLB 失败或用户明确要求完整包时，才生成 `manual_fallback/`。
- 多零件必须保留 `Part -> Material -> Image` 映射，禁止用单材质兼容脚本覆盖已完成语义分件的双贴图装配。
- 主 GLB 成功即停止格式排查；Studio 导入成功与 Root/Weld/Play 运行验收继续分层记录。
- v03 失败可排除正式几何损坏；FBX 内嵌纹理链与长中文深层路径同时变化，尚不能把其中一个宣布为唯一原因。
- 登记固定触发词：`参考 ：D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\多零件模型转为roblox可导入文件 工作流，导出为可直接导入roblox的文件`。下次不要求用户补充 `.blend` 路径、资产名、格式或贴图尺寸。
- 源文件按“当前任务已知文件 → 当前 Blender 已保存文件 → 最近的 `*_ROBLOX_EXPORT_vNN.blend` → 当前项目唯一语义匹配文件”自动定位；只有多个候选同等可信时才询问一次。
- 资产名和正式零件已能从上下文确定时不再重复询问，脚本失败才展开完整工作流。

### 验证与下一步

- v04 主 GLB、外置 FBX、内嵌 FBX、纯网格 FBX 均通过 Blender 5.1 工厂空场景回导。
- 用户确认 `ObsidianWolfAxe_faces4355_1024tex.glb` 可导入 Studio，记录 `studio_import=PASS`；运行装配仍为 `NOT_RECORDED`。
- 后续多零件资产默认先复跑主 GLB 回导门；只有主 GLB 失败或明确要求完整包时才生成并验证 FBX 回退。
- 快速脚本用狼斧导出副本实测约 2 秒完成导出和回导；输出仍为 2 个零件、4355 三角面、两张 1024 贴图，尺寸一致。负向测试确认普通工作文件在未指定 `-Parts` 时以 `EXPORT_COPY_REQUIRED` 和非零退出码停止。

## 2026-08-17 Tripo 多视图候选图本地审阅修复

### 读取来源

- `Tripo多视图工作流/README.md`、当前翡翠鎏金双月战斧候选图，以及 Codex 右侧“无法加载文件”预览现象。

### 新增与更新

- 工作流升级到 `v1.6`：明确聊天内绝对本地文件链接不是可靠的图片预览入口。
- 新增 `scripts/Open-ReviewImage.ps1`：验证候选图可解码后，打开短英文审核副本所在的资源管理器和系统默认图片查看器。
- 规定候选复制到 `<workspace_root>/_tripo_review/<weapon_slug>/<view>.png`；审核副本不混入 `00_final_tripo_upload`。

### 验证与下一步

- `jade_gilded_axe/back.png` 已验证为 1024×2014、841007 bytes，并返回 `REVIEW_IMAGE_OPENED`。
- 如果 Codex 右侧预览仍失败，记录 `CODEX_LOCAL_PREVIEW_UNAVAILABLE`；不重做已通过本地解码检查的图片。
- 经实际点击验证，聊天内文件夹 Markdown 链接同样会被 Codex 内部预览接管，不能作为“点击打开资源管理器”按钮；工作流改为由 Codex 自动调用审核打开脚本。
- 再次实测发现 `Start-Process` 只保证资源管理器窗口创建，不能保证对用户置前；工作流升级到 `v1.7`，新增 `REVIEW_WINDOW_NOT_FOREGROUND` 与 Computer Use 的地址栏、文件列表、置前验证门。

## 2026-08-17 Roblox 通用单侧视图生成工作流

### 读取来源

- `Tripo多视图工作流` v1.9 的平面型、长柄枪头型、层叠盘形和体块型侧视规则。
- 高级武器模型制作中的自定义 `Side A / Side B`、逐侧可见性合同和镜像授权门。
- 已复现的侧视失败：3/4、正视横向压扁、体积丢失、完整正面宝石露出、左右内容复制、未授权镜像和重复生成任务。

### 新增与更新

- 新增 [[../81_WorkFlow 工作流/Roblox/模型相关/单侧视图工作流/README|Roblox 通用单侧视图生成与修复工作流]]。
- 新增快速执行卡、六类几何提示词模板、验收清单、失败码、运行状态模板和工作流状态页。
- 在 `Roblox MOC` 与 `Roblox Wiki` 增加新工作流入口。

### 关键决策

- 工作流只处理一个当前资产、一个目标侧和一个活动生成任务，不强制扩展完整四视图。
- 侧视正确性拆为五层：输入角色、相机、基础几何类、单侧可见性合同、锚点与比例；禁止只用一句“90° side view”代替完整合同。
- 基础几何统一分为 `P1_THIN_PLATE`、`P2_LONG_HEAD`、`P3_LAYERED_FLAT_VOLUME`、`V1_ROUND_VOLUME`、`V2_BOX_IRREGULAR_VOLUME`、`O1_OPEN_FRAME`。
- `left / right` 默认独立生成；已通过的另一侧只能作为厚度与锚点基准。只有用户明确授权来源和目标时才执行本地确定性镜像。
- 正式化必须同时通过自动检查和用户确认；修复父四视图时只替换当前目标侧，不改动其他正式文件。

### 验证与下一步

- 已检查新目录文件注册表、Obsidian 链接目标、Markdown 代码围栏、相机参数、几何分类和失败码覆盖。
- v1.0 规格状态保持 `Review`；需要再用薄片 / 长枪头、层叠盘形和体块 / 开放框架三类真实资产各完成一次单侧运行后升级为 `Approved`。

## 2026-08-18 微信普通小程序注册备案与发布工作流

### 读取来源

- 本次“吃啥小决定”个人主体普通小程序从注册、基础信息、类目、正式 AppID、本地开发、上传、备案、代码提审到体验测试的真实试跑记录。
- 微信小程序官方注册、项目配置、发布、备案、隐私与搜索说明；平台入口和规则具有时间敏感性。

### 新增与更新

- 将 `81_WorkFlow 工作流/WeChat小程序/其他/未命名/` 重命名为 `81_WorkFlow 工作流/WeChat小程序/普通小程序/注册备案与发布工作流/`。
- 新增“微信普通小程序从注册到公开发布工作流”和配套执行清单。
- 在 `AI 编程与产品 MOC` 增加工作流入口。

### 关键决策

- 备案与代码开发、代码审核并行；正式公开发布必须同时通过代码审核和备案。
- 备案等待期间，测试朋友只添加为“体验成员”，不授予开发者权限。
- 扫码、验证码、实名、人脸、法律协议、`12381` 短信和最终发布确认属于人工门禁；代码、配置、静态检查和文档整理可由 Codex 执行。
- 不在笔记、仓库或客户端代码中保存 AppSecret、密码、验证码、证件号码、二维码或会话凭据。

### 验证与下一步

- 已检查目录命名、Obsidian 链接、Frontmatter、Markdown 代码围栏、UTF-8 编码、敏感信息和本次改动边界。
- `vault_health_check.py` 检查到 545 个 Markdown、0 个奇数代码围栏、0 个损坏本地图片、0 个根目录缓存；另有 3 个任务外既存空笔记，本次未处理。
- 本次真实账号仍处于备案审核门禁；备案通过后需补做正式发布和非成员搜索验收，并将证据回填到执行清单。

## 2026-08-18 Roblox 角色模型 Rig 比例锁定与 15+ 分件工作流

### 读取来源

- Roblox Studio 中的 R15 `Rig` 与 `M_Hero_001` 结构对比。
- 用户确认的角色模型生产路径：完整效果图定稿、15+ 零件重新设计、逐件 Tripo 生成、Blender 对照 Rig 装配。
- 当前紫蓝青银河重甲角色截图；图中的翅膀和武器只用于识别排除项。

### 新增与更新

- 新增 `81_WorkFlow 工作流/Roblox/模型相关/Roblox角色模型/README.md`。
- 保存当前角色风格参考原图到工作流的 `assets/`，并在文档中明确可保留与必须排除的内容。
- 在 `Roblox MOC` 与 Roblox Wiki 索引增加当前工作流入口。

### 关键决策

- Rig 是裸体比例尺，最终 15 个身体部位是包在 Rig 外侧的可见衣服/盔甲，不是把 Rig 整体等比放大。
- 完整效果图锁定关键关节和设计语言；零件必须重新设计为独立完整物体，不能从全身图直接裁切。
- Tripo 不承担全局尺度和位置；每件生成后立即导入 Blender，并由同一个 Rig 重新标定。
- “整体导出”表示一个文件包含 15+ 个独立对象，不表示合并网格。
- 当前模型不做翅膀、武器、动画、蒙皮或可玩 R15 兼容实现。

### 验证与下一步

- `vault_health_check.py` 检查到 548 个 Markdown、0 个奇数代码围栏、0 个损坏本地图片、0 个根目录缓存；另有 3 个任务外既存空笔记，本次未处理。
- 已核对 README、参考图、MOC 入口和 Roblox Wiki 入口；`git diff --check` 未发现本次新增的空白错误。
- 下一步只导入目标 Rig 到 Blender，建立固定正交相机和全身比例母版；通过后再生成完整角色正面效果图。

## 2026-08-22 MPChat 云影卡充值流程笔记

### 读取来源

- 本次真实完成的“欧易 C2C 买入 103 USDT → Tron（TRC20）提币 → MPChat 入账审核 → 支付余额划转到虚拟卡”流程。
- 欧易 C2C、提币手续费与未到账排查官方说明；MPChat 卡片费用与 AML/KYT 入账审核官方说明。

### 新增与更新

- 新增 `20_Areas 领域/钱包/MPChat 云影卡充值流程（欧易 C2C + TRC20）.md`。
- 在 `个人理财与人生 MOC` 增加流程入口。

### 关键决策

- 将 MPChat/TRC20 路线与旧的 Fiat24/Arbitrum 路线分开记录，避免网络和手续费币混用。
- 只记录可复用步骤、风险判断和时间敏感费用，不保存卡号、钱包地址、TxID 等敏感信息。
- 把“欧易已提取”“链上确认”“MPChat 入账审核”“支付余额划转到卡”明确拆成四个不同状态，避免重复转账。

### 验证与下一步

- 已按 2026-08-22 官方页面核对 C2C 路径、动态提币费、MPChat 0.8% 卡消费费及充值审核规则。
- 后续每次充值前仍需以 App 实时页面复核网络、地址、最低入金额、提币费和 T+N 限制。

## 2026-08-26 风格化刀剑参考网站资源卡

### 读取来源

- [Sketchfab - stylized sword，按点赞数排序](https://sketchfab.com/search?q=stylized+sword&sort_by=-likeCount&type=models)
- [ArtStation - WoW FanArt: Blood Knight's Warblade](https://www.artstation.com/artwork/lE109O)
- `AGENTS.md`、`笔记导览.md`、`70_LLM_Wiki 知识库/schema.md`、Roblox MOC 与 Roblox Wiki。

### 新增与更新

- 新增 `40_Resources 资料/3D建模/风格化刀剑参考网站（Sketchfab + ArtStation）.md`。
- 在 `30_MOC 内容地图/Roblox MOC.md` 和 `70_LLM_Wiki 知识库/Roblox/index.md` 增加资源入口。

### 关键决策

- 把 Sketchfab 定位为“大量浏览、旋转检查厚度和连接关系”的灵感入口，把 ArtStation 页面定位为“成品、线框、高模、Base Color 和公开性能规格齐全”的制作案例。
- ArtStation 案例的 2070 三角面、单材质组和 512 px 贴图只作为案例证据，不升级为 Roblox 武器的固定性能标准。
- 不复制或下载站内图片到 Vault；保留作者、页面链接、使用方法、许可证提醒和核验日期。
- 明确 `Downloadable` 不等于可商用，World of Warcraft 同人作品也不能直接复制为商业资产。

### 验证与下一步

- 两个页面均于 2026-08-26 通过网页读取核实；资源卡记录了 Sketchfab 当前筛选能力，以及 ArtStation 作者、制作规格和展示内容。
- 后续连续使用至少 3 把武器后，再补充经过实际 Tripo / Roblox 流程筛选的优质模型链接清单。

## 2026-08-26 Git 远端同步前审计与资产边界

### 读取来源

- `AGENTS.md`、`笔记导览.md`、Wiki schema、总入口、Open Questions 和 Obsidian MOC。
- 当前 Git 分支、远端、工作区状态、对象体积与 Vault 健康检查结果。

### 新增与更新

- 新增 [[Vault/Git 远端同步前审计与资产边界]]。
- 更新 Wiki 总入口、Obsidian MOC 和 Open Questions，补齐当前同步阻塞与决策门禁。

### 关键决策

- 保留 4 个既有空白占位笔记，不自动删除。
- 不自动恢复或提交 594 个既有删除状态项。
- 不把约 13.3 GB 未跟踪资产直接纳入普通 Git 提交。
- 在用户提供远端地址并确认资产策略前，不改写 Git 历史、不删除大型文件、不声称已上传。

### 验证与下一步

- Vault 最终检查：555 个 Markdown、Inbox 0、损坏本地图片 0、奇数代码围栏 0、根目录缓存 0。
- 当前仓库无远端；历史中有 10 个超过 100 MB 的文件，最大约 4.19 GB。
- 下一步由用户确认远端服务、仓库地址、公开性和大型资产策略，再执行敏感信息扫描、提交预览与推送验收。

## 2026-08-28 带动画角色导入 Roblox 工作流与可丽案例

### 读取来源

- 本次可丽角色转换对话、`D:\Work\Resource\Klee_20260828_112257\Roblox_Export_v1` 的实际导出/回读/打包脚本与 JSON 验收报告。
- Vault 规则、Schema、Roblox MOC、Wiki 索引，以及已有 R15 分件和静态道具导入流程。
- 2026-08-28 核对的 Roblox 官方 Importer、FBX 导出和 Blender 单位/朝向说明。

### 新增与更新

- 新增 [[../81_WorkFlow 工作流/Roblox/模型相关/带动画角色导入Roblox工作流/README|带动画角色导入 Roblox 工作流]] 与 [[../81_WorkFlow 工作流/Roblox/模型相关/带动画角色导入Roblox工作流/01_可丽案例与验收记录|可丽案例与验收记录]]。
- 更新 Roblox MOC、Roblox Wiki 索引、原角色模型入口与 Open Questions；保留已有内容和资产。

### 关键决策

- 已有蒙皮动画角色走 Custom Rig 路线，不与 R15 分件生成或静态武器打包混用。
- 明确可丽总计 19,099 三角面、4 网格、140 骨骼，首版未减面；流程拆分 G0–G6，实例只验收至 G3 预览。
- 保留未导出眨眼、配件循环回跳、walk 未适配、未实测性能等限制；不把数值回读或 Blender GIF 当成 Studio 运行证据。
- 知识库只新增文档和证据入口，不复制模型/ZIP、不重新执行转换、不上传资产、不操作现有 Studio 游戏。

### 验证与下一步

- 编写前基线：556 个 Markdown、4 个既有空白占位、图片断链 0、代码围栏异常 0、Inbox 0、根目录缓存 0；既有空白占位保留。
- 本轮新增两份文档，合计 558 个 Markdown；22 个正文链接及 6 个新增导航链接均有效，主/静止 FBX 和 ZIP 哈希仍与交付报告一致。
- Vault 健康检查仍仅报告原有 4 个空白占位，未新增图片断链、代码围栏异常、Inbox 文件或根缓存；`git diff --check` 通过。原索引正文和日志历史内容保留，除更新时间与换行形式外未改写。
- 独立只读审查发现“先通过 G5 再修循环”的顺序歧义，已改为：播放基线检查 → 修循环 → 重新回读/播放验收 → G5 通过 → G6。文档状态为 Review，不是 Approved；资产状态仍为 G3，未借文档审查升级运行验收状态。
- 下一步：确认资产使用及上传范围，完成实际导入、播放基线检查和循环修复；G5 通过后开展手机/电脑性能测试。本轮未提交或推送 Git。

## 2026-08-28 角色导入流程减负：当前场景直导，不自动另存

- 来源：用户明确反馈“只需要导入”，以及前序把额外 Save As 当作收尾条件的操作偏差；核对原角色工作流和 Vault 规则。
- 修改：原位更新 [[../81_WorkFlow 工作流/Roblox/模型相关/带动画角色导入Roblox工作流/README|带动画角色导入 Roblox 工作流]] 至 v0.2；沿用原导航和案例，不新建一套流程。
- 决策：默认直接操作当前目标场景，已有模型/兼容文件先复用；只生成必要转换产物。取消每次新建测试场景、保存检查版、项目另存、多份备份及完整打包的默认要求。未知覆盖先确认，原文件与现有副本均不自动删除。
- 验收边界：只要求导入则实际对象检查通过即完成；动画/角色控制/性能按本次请求验收。保存、备份和发布单独授权、单独记录，保存取消不等于导入失败；不关闭未保存窗口。
- 已检查：558 个 Markdown，图片断链 0、代码围栏异常 0、Inbox 0、根缓存 0；4 个既有空白占位保留。README v0.2 的代码围栏、行尾空白与历史 G3 状态检查通过；整理日志 `git diff --check` 通过。本次未操作 Studio、未保存项目、未重跑转换或删除副本，未提交/推送 Git。
- 独立只读审查指出“默认播放完整动作”和“回读默认隔离/渲染”两处残留开销，已限定为本次动画转换/动作验收或确有诊断需要时执行；保留文档 Review 状态。
- 下一步：后续按新起止条件执行；可丽案例仍是历史 G3 记录，不借流程修订升级其运行/性能验收状态。

## 2026-10-10 Xeno 归档经验整理与公开 Git 同步准备

- 来源：用户指定保存到 `20_Areas 领域/Roblox/Xeno`；复核 2026-10-09 Xeno 诊断、Steal An Egg、Brookhaven、Dandy’s World 大厅及实战第 3 层的脚本与验收报告；读取 Vault 规则、Schema、笔记导览、MOC 和既有资产边界记录。
- 新增：[[../20_Areas 领域/Roblox/Xeno/README|Xeno 工作流入口]]、完整 SOP、快速执行清单、故障与范围说明、成功案例及本机实现索引、Obsidian Git 同步状态说明；新增 [[Roblox/Xeno 客户端内容归档|Wiki 检索页]]，更新 Roblox MOC 与 Wiki 索引入口。
- 决策：主流程遵循用户指定位置，Wiki 只保留索引；历史工具版本不冒充最新版；当前 Place、Universe、楼层分别核对；Toast、bytecode、资源引用和真实完成分别验证。文档不复制 EXE、游戏素材、原始捕获或大 ZIP 到 Vault。
- 证据：Dandy’s World 总包 128,696,525 字节、3,678 文件，CRC 与每条目 SHA256 通过；范围只含大厅及当时实测第 3 层。Brookhaven Terrain 缺 42 索引块另行补采并保留原始文件，恢复范围以明确扫描框和三通道验证为准。
- Git：用户已授权公开仓库与每 30 分钟同步；已创建 `yangshulin2333/Codex_Obsidian`，正常 Git 凭据身份匹配。原历史包含 10 个超过 100 MiB 的对象，不能直接普通推送；上传边界与保留旧历史方案待确认。当前未推送、未启用插件定时操作，不自动恢复 594 个既有删除项。
- 验证与下一步：核验新文档本机来源与导航链接、Frontmatter、围栏和差异格式；保留公开上传预览于工作目录。确认范围后建立可上传历史、首次推送并核对远端，再验证插件运行中的 30 分钟同步设置。
- 后续范围确认：用户明确保留全部笔记，包括钱包、支付和理财；只排除大资产、缓存、凭据与本地配置。确认版初始候选为 4,460 文件、约 864.4 MiB，最大单文件约 8.8 MiB。旧 `.git` 已完整移到 Vault 外 `D:\AI\Codex_Obsidian_GitHistoryBackup_20261010_101250`，保留原 6 次提交和原状态；未改写、删除旧历史或改动嵌套 Git 元数据。
- 最终验证：7 份新文档的 Frontmatter、代码围栏、25 个 Wiki 链接及 67 个本机来源链接通过；文档内外部文件链接适配为 Obsidian 支持的格式。上传清单 4,460 项完全进入普通文件索引，未混入排除项或 Git 子仓库链接，首次推送成功且 `main` 跟踪 `origin/main`。
- 定时同步限制：用户通过 Esc 停止界面检查，随后未再操作 UI。已保存 30 分钟同步设置，并保留通知偏好；10:30:27–10:32:08 的 1 分钟短周期测试没有自动提交，测试后恢复原消息设置和 30 分钟周期。当前只确认首次上传及配置落地，不能宣称插件定时运行成功；后续需要验证初始化、暂停状态、Git 路径及自动提交/推送。

## 2026-10-10 EvoMon 字节码恢复与优化预览经验入库

- 来源：用户要求把本次优化写进现有 Xeno 文档；读取 EvoMon 优化包汇总、脚本索引/恢复摘要/工具来源、Studio 预览与部署验证、最终 ZIP 报告，以及处理与预览源码；沿用 Vault 规则、Schema、笔记导览和 Roblox 入口。
- 新增：[[../20_Areas 领域/Roblox/Xeno/06_字节码恢复与场景优化工作流|字节码恢复与场景优化工作流]]、[[../20_Areas 领域/Roblox/Xeno/07_EvoMon优化预览版案例与验收|EvoMon 优化案例与验收]]。
- 更新：Xeno README、01 原始工作流的可选优化分支、02 清单、03 故障、04 案例；Wiki 检索页、Roblox Wiki 索引与 MOC 添加新入口。原始归档与优化阶段分开，未复制 EXE、素材、脚本产物或 ZIP 进 Vault。
- 结果：2,787 份字节码中 2,780 严格恢复（含 15 空块）、2 合成候选独立、5 未恢复，57 份 AST 函数数量差异需复核；668 个本地素材已部署并校验。最终 ZIP 90,375,653 字节、6,269 文件、CRC/逐条目 SHA 通过；独立静态 Edit/Play 预览本次无权限/加载报错。
- 决策：不能用 generic URI Preload Failure 推断 MeshPart/字体不可用，误判的网格替换已经撤回；PBR 本地支持缺口明确降级，原网格与部分在线/缓存 URI 保留。静态预览关闭 Streaming、自动 Avatar 和原游戏启动代码；编译成功、可预览、原玩法恢复分别验收。
- 原数据边界：原场景、XML、索引与字节码没有改写；解析器导入产生的 Python 缓存没有进入新包，不声称原目录文件集完全未变。全文保留白色/基础材质、非完全离线及未恢复服务端玩法限制。
- 验证与下一步：检查链接、Frontmatter、围栏、事实与本地证据；按此前授权提交并同步新增文档，不改变插件设置或把未验证的定时同步写成已成功。后续按模块复核候选和 AST 差异，需要运行验证时另设具体目标。

## 2026-10-11 Mihon 手机安装与中文漫画部署工作流

- 读取来源：本次 Mihon 下载、USB/ADB 安装、手机 UI 配置、三个中文扩展的发布索引和实际试读记录；核对原安装包的大小与 SHA-256、下载与 UI 辅助脚本，并读取 Vault 规则、笔记导览、Schema、AI 编程与产品 MOC 和 Wiki 索引。
- 新增：[[81_WorkFlow 工作流/Android/通过ADB部署Mihon中文漫画阅读环境_工作流|通过 ADB 部署 Mihon 中文漫画阅读环境工作流]]，以及 [[AI_Programming_Product/Mihon 中文漫画阅读环境部署经验|Mihon 部署经验检索页]]；更新 AI 编程与产品 MOC 和对应 Wiki 索引入口。
- 关键决策：完整操作放在工作流目录，Wiki 保留短经验页与验收范围。版本和哈希明确为 2026-10-11 部署记录，下次重新核验；保存保留前缀的四段 Range 下载方法、ADB 命令、系统文件夹选择、插件手动信任与 AliDNS 应用内修复路径。知识库只保存文档，不复制 APK、手机截图、原始会话或真实设备序列号。
- 实测边界：一加 Ace 6T 上 Mihon 0.20.4 安装并完成中文配置，三个图源的热门列表成功，漫画柜《鬼灭之刃》第 23 卷第一页成功显示。目录配置与实际下载、备份恢复分别验收；不把列表成功升级为全部源的全部章节可读。
- 文档验证：四篇相关页面的 28 个 Wiki 链接可以解析，Frontmatter 和代码围栏通过，九段 PowerShell 代码完成静态语法解析；安装包记录与本地 SHA-256 一致。原导航正文和历史日志保留，本轮维护文档时未再次操作手机或执行部署代码。
- 下一步：后续重装按主工作流重新核验版本、扩展兼容性和手机上的列表与中文阅读页；需要离线下载、备份恢复或自动更新时再按具体目标补测。

## 2026-10-12 Xeno 原始归档默认模式与工作流便携化

- 来源：用户要求默认先下载可取得原始内容，后续明确需要时再恢复 Luau；并要求 Xeno 工作流换电脑、盘符或工作目录后仍可使用。读取 Xeno 八份文档、当前 Blox Fruits 第一海捕获证据及库级导览、Schema、索引和 Roblox MOC。
- 更新：Xeno README、01–07；新增 08 环境迁移、09 历史资源索引、共享 JSON 配置与标准库只读检查器；同步更新本 Wiki 检索页及 Roblox MOC。
- 决策：默认 raw_archive，反编译、native 转换、场景清理和预览关闭；身份/版本/入口按本次配置绑定，未知值用 null。57 条历史本机资源链接改为 artifactId、角色和根内相对路径，历史指标保留为案例。本机路径与本次运行文件置于 Vault 外，二进制、游戏素材和大 ZIP 不进入笔记库。
- 验证：副本中检查共享模板、内部链接、角色/hash、配置边界，并实测复制到新目录与不同工作目录；原版已保存为事务基线，修改/补丁/验证/可执行回滚保留在外置工作目录。配置测试不作为游戏采集或未来工具兼容性的证明。
- 下一步：新环境先发现并核验 Player、Xeno、workspace 与本地工具，填环境/run 配置再执行原始归档。日后源码恢复须保留原始字节、API dump、导出器、许可、版本与输入 hash，并单独选择派生阶段。

## 2026-10-13 旅行伙伴职责与游戏循环确认

- 来源：旅行伙伴项目聊天中用户接受的玩家职责、经营与陪伴双循环、第一版日常生活范围；沿用项目文档约定及此前打捞与休闲旅游方向记录。
- 更新：[[10_Projects 项目/Roblox/00旅行伙伴/04_打捞远航与休闲旅游_方向记录|打捞与休闲旅游方向]]；新增 [[10_Projects 项目/Roblox/00旅行伙伴/05_玩家职责与Demo游戏闭环|玩家职责与 Demo 游戏闭环]]，同步项目 AGENTS。
- 决策：玩家负责经营、照料和资产处置，伙伴自主生活探索；第一版日常先休息、看书、短散步。拍卖模式与价格、休闲旅游资源和奖励仍待确定，文档默认 Markdown。
- 边界与下一步：本轮只维护 Markdown，不改游戏代码或 Studio。文档区分已确认设计与已实现功能；后续按小阶段确定规则、开发和验证。

## 2026-10-13 旅行伙伴混合场景表现确认

- 来源：用户接受主岛与近岸3D、远方旅途2D的讨论建议；核对现有观察窗实现及 Roblox 官方 UI、性能设计文档。
- 更新：新增 [[10_Projects 项目/Roblox/00旅行伙伴/06_3D主岛与2D旅途表现方案|3D 主岛与 2D 旅途表现方案]]，关联玩家职责与游戏闭环，同步项目 AGENTS。
- 决策与边界：玩家留岛经营，主动查看伙伴2D旅途，船以3D离返港；当前为占位表现，正式美术及生活行为仍待接入。本轮没有修改游戏代码、制作图片、上传资源或操作 Studio。

## 2026-10-14 旅行伙伴 Blender 地编场景交接

- 来源：用户要求根据旅行伙伴项目目录生成面向 Blender 地编的游戏交接文档；读取 03 历史美术方案、04–13 方向与实现记录，核对游戏工程当前静态岛、模型模板和世界接入代码，并查阅 Roblox 官方导入、导出、网格碰撞与性能文档。
- 新增：[[10_Projects 项目/Roblox/00旅行伙伴/14_游戏与Blender地编场景交接|游戏与 Blender 地编场景交接]]，以及 `assets/Blender地编_功能布局示意.svg` 与同名 PNG；同步项目 AGENTS 入口。原方案和历史截图保留。
- 决策：先做四人岛结构与一个个人区样板；独立保留住宅、船、封箱、准备桌和家具，外观、碰撞与锚点分层交付。功能布局图不按比例，当前白模坐标与可调整的道路／美术建议分别标明；地点愿望复用准备桌，拍卖只预留，远方旅途仍为 2D。
- 核对：1 号地块与其余三块的住宅、箱位有差异；生活区外观位于 `LifeArea/Appearance`；直线船道和四点散步均没有避障寻路。旧全岛生成脚本未包含全部后续调整，不用于覆盖正式场景。示意图已渲染检查，文档的本地链接、图片、围栏和 Frontmatter 已核对。
- 边界与下一步：本轮仅交付文档与布局示意，没有操作 Blender／Studio 或修改游戏代码与模型，没有运行游戏测试。接下来按交接文档第 10 节起稿，整岛粗模与个人区样板的比例、动线、碰撞和性能由用户验收后继续细化。
