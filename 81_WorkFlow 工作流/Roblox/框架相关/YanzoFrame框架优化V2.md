---
type: decision
domain: roblox
status: active
owner: mixed
source: self
created: 2026-07-27
updated: 2026-08-09
---

# YanzoFrame 框架优化 V2

## 候选：配置表导出工具

### 当前决策

先在独立项目 `RobloxFarmGame` 内实现并验证“可用 Excel 编辑的 CSV 配置源 → 导出脚本 → Luau 生成配置”流程，不直接修改原始 `YanzoFrame_V2`。

### 本次农场项目的边界

- 编辑源：`ConfigSource/Farm/*.csv`，可由 Excel 打开和修改。
- 构建入口：项目根目录的 `config_export.bat`。
- 运行时产物：`src/ReplicatedStorage/Module/Shared/GeneratedConfig/Farm/*.lua`。
- 玩家金币、背包、地块种植时间、任务进度等属于 `StorageService` 管理的玩家存档，不能进入配置表。
- 首版不做网页运营后台、在线热更新或让客户端修改配置。

### 候选的可复用部分

- CSV 表头与字段类型校验。
- 唯一 ID 检查、必填列检查和生成结果过期检查。
- `config_export.bat` 作为人工编辑后的统一入口。
- 静态配置生成 Luau ModuleScript 的目录约定。

### 必须留在游戏项目内的部分

- 作物、土地、任务、商店等具体列定义。
- 白萝卜、六阶段、肥料、偷菜、农场等级等玩法规则。
- 玩家存档 Schema 与服务端奖励、资产修改逻辑。

### 上移到 YanzoFrame 的条件

满足以下条件后，才单独评估抽取为 `YanzoConfigTool` 或 YanzoFrame 的开发工具层：

1. 农场项目已经稳定使用，并通过导出、静态检查和 Studio 验证。
2. 第二个不同玩法项目需要同一套 CSV 导出能力。
3. 可复用层中不存在 `Farm`、`Crop`、`Plot` 等农场专属判断。
4. 工具具备清晰的输入、输出、错误码和过期检查，且无需修改运行时框架代码。

### 当前状态

- 2026-07-27：已决定在 RobloxFarmGame 以 P0-01a 实现并验证。
- 2026-08-09：第二个不同玩法项目 `YanzoFrame_GameAnimationEffects` 已完成 Boss Trial 资产表的项目内复验：
  - WPS 实测证明 CSV 无法保存列宽且可能被重写为 GBK、日期或数值，因此权威源升级为 `ConfigSource/BossTrial/Assets.xlsx`；
  - `Assets.xlsx` 保存列宽、筛选、冻结首行、文本格式与枚举下拉，自动生成 UTF-8 `Assets.csv` 供 Git 审查；
  - `config_export.bat` 统一执行 XLSX → CSV → Luau，`--check` 检查两级生成结果是否过期；
  - 生成结果位于 `src/ReplicatedStorage/Module/Shared/GeneratedConfig/BossTrial/AssetCatalog.lua`；
  - 已覆盖精确表头、忽略大小写的 Key 唯一性、严格 UTF-8、日期、枚举、资源类型条件和 Roblox Asset ID 字符串校验；
  - `Verified` 只表示技术接入通过，允许使用权仍为 `Unverified`；只有 `Approved` 才强制要求明确使用权，避免把“Studio 可播放”误写成“版权已确认”；
  - 自动化测试、Stylua、Selene 和 Rojo build 已通过，且未修改 YanzoFrame 运行时代码。
- 结论：已经具备第二项目证据，可进入“通用导出器边界设计”阶段；在 RobloxFarmGame 的稳定使用与 Studio 验证证据补齐前，仍不直接并入 YanzoFrame。

## 候选：Studio-owned 二进制资产与 Rojo 共存

### 当前决策

在独立项目 `RobloxFarmGame` 中验证以下边界：代码、配置和资源目录外壳由 Rojo 管理；Tripo/Studio
导入的二进制模型仍直接保留在 Studio 的目标资源目录中。通过资源目录的 `init.meta.json` 设置
`ignoreUnknownInstances: true`，让 Rojo 同步目录但不删除它不认识的 Studio 模型子项。

### 本次农场项目的落点

- Studio 运行时路径：`ReplicatedStorage.Resources.Farm.Crops`。
- Rojo 元数据路径：`src/ReplicatedStorage/Resources/Farm/Crops/init.meta.json`。
- 原始资产备份：`art/ImportReady/Crops/` 内的 `.glb`。
- 里程碑恢复备份：`art/StudioExports/` 内按整个资源文件夹导出的 `.rbxm`。
- 不要求将每个 Studio 模型保存为 `src` 内的 `.rbxm`，也不要求为每次导入运行接管脚本。

### 可复用价值与约束

- 适用：Tripo、FBX/GLB、贴图、Terrain 等 Studio 导入后难以文本化的资产。
- 保持：代码仍通过明确的 `ReplicatedStorage` 路径读取资源；每次大批量修改后仍做 Studio Play 验收。
- 风险：Rojo 静态 build 不能证明 live sync 后 Studio 子项一定保留，必须在真实连接会话中检查一次。
- 恢复：出现资产误删时，优先从最近的 `.rbxm` 文件夹备份恢复，不使用 Git 覆盖 Studio 的二进制资产。

### 上移到 YanzoFrame 的条件

1. `RobloxFarmGame` 已完成至少一次“导入 → 同步 → 重开 Studio → Play”无丢失验证。
2. 第二个不同项目也需要同一类 Studio-owned 资源目录。
3. 抽出的内容只包含目录约定、备份清单和验证步骤，不携带 `Farm`、`Crop` 等玩法名称。
4. 在 YanzoFrame 文档或项目模板中新增资源边界说明前，先复核当前 Rojo 文档版本。

### 当前状态

- 2026-07-28：已在 `RobloxFarmGame` 采用，等待 Studio 同步与 Play 验收。
- 2026-08-09：在 `YanzoFrame_GameAnimationEffects` 的 `ServerStorage.Resources.Bosses` 上完成第二项目 live sync 探针验证：Rojo 能删除受管测试项，同时保留 Studio 创建的未知测试项；`ignoreUnknownInstances: true` 只放在 `Bosses` 子目录，没有放宽整个 `Resources` 根目录。
- 2026-08-09：Magma 与 Dragon 已分别导出完整 `.rbxm`；实例数 90/294，与 Studio 根 Model 加全部后代严格一致。错误的 OBJ/MTL/贴图静态导出已识别为可删除项。
- 2026-08-09：两个 Boss 已分别建立 `art/ImportReady/Bosses/<BossName>/source.md`。产品名、动画清单与模型结构高置信匹配 Meshtint Studio 的 `Polygonal - Magma` 和 `Polygonal - Dragon`，并记录了 Elven Academy 群组下的 Roblox Mesh/贴图 ID、工作台路径和 `.rbxm` 备份。
- 2026-08-09：用户确认两个 Meshtint 资源均由东哥购买，当前用途仅为 `Elven Academy` Experience 内部非商用 Demo。本项目将模型、Magma 发布动画与动画源记录设为 `UsageRights=Licensed`，同时在 Notes/source.md 固定 `InternalDemoOnly` 范围和“用户确认、订单未归档”的证据等级。
- 当前缺口：迁往飞哥公司的正式项目、公开发布或商业上线时，仍需重新确认购买主体、Single Entity / Multi Entity 范围或重新购买。应把“原始产品来源”“Roblox 上传归属”“当前项目使用权”作为三个独立门禁，不能互相替代。
- 结论：当前内部 Demo 的来源门禁已闭环，可以继续 Magma 迁移和 Enemy 模块；跨公司/发布许可与 round-trip 验收仍未闭环。该工作流仍是框架文档/模板候选，不是 YanzoFrame V2 的运行时能力。

## 候选：新项目身份初始化与开发者面板默认状态

### 触发来源

2026-08-08，在独立 Boss Trial 项目 `YanzoFrame_GameAnimationEffects` 中，把一份
`YanzoFrame_V2` 底座复制为新的游戏项目时，出现两类不应靠人工全局替换记忆完成的配置：

1. 项目身份仍散落在多个文件中。
2. 开发者面板可用，但首次 Studio Play 默认展开，会遮挡玩法验收视野。

### 本次项目已经做的最小修改

- `default.project.json`：Rojo 项目名为 `YanzoFrame_GameAnimationEffects`。
- `Logger.lua`：运行日志前缀为 `[YanzoFrame_GameAnimationEffects]`。
- `RemoteNames.lua`：网络根目录为 `YanzoFrame_GameAnimationEffects_Remotes`。
- `StorageConfig.lua`：ProfileStore 名为 `YanzoFrame_GameAnimationEffects_PlayerData_V1`。
- `DeveloperPanelController.lua`：仅在 Studio 中启用面板时，默认调用 `_collapsePanel()`；完整面板隐藏，但右侧 `ToggleButton` 保留，可手动打开。
- 本次**没有**关闭 `EnableDataReset`、`AllowDataResetInStudio`，也没有放宽正式服白名单；只是改变 UI 初始显示状态。

### 当前问题与可复用候选

建议在“从 YanzoFrame 复制出新项目”的初始化流程中，集中维护一份项目级
`ProjectIdentityConfig`（名称仅为候选），至少明确以下值：

| 字段 | 用途 | 当前散落位置 |
|---|---|---|
| `ProjectName` | Rojo 项目、日志和开发工具显示名 | `default.project.json`、`Logger.lua`、脚本与文档 |
| `RemoteRootFolder` | `ReplicatedStorage` 下的 Remote 根目录 | `RemoteNames.lua` |
| `ProfileStoreName` | 玩家持久化数据命名空间 | `StorageConfig.lua` |
| `DefaultLogLevel` | 新项目日志默认等级 | `LogConfig.lua` |
| `DeveloperPanelDefaultCollapsed` | Studio 调试面板首次是否收起 | `DeveloperPanelController.lua` |

配套的初始化工具应只作用于“新复制、尚未上线”的项目，并在执行前列出将修改的文件与字段；
不应自动改动已上线项目的数据命名空间。

### 风险与边界

- 改 `ProfileStoreName` 等同切换玩家存档命名空间；已上线项目若直接改名，玩家会像进入新存档。必须有明确迁移方案，不能由初始化工具静默执行。
- 改 Remote 根目录会使旧客户端/旧服务器短时间内无法互通；只能在整包发布或新项目初始化时修改。
- 开发者面板默认收起不等于禁用：生产环境是否显示仍由 Studio 判断、数据重置开关和用户白名单共同决定。
- `Warn` 只约束 YanzoFrame 自己的 Logger；第三方库自行 `print` 的日志不在此配置控制范围内。

### 上移到 YanzoFrame 的条件

1. 至少两个独立游戏都完成了“复制底座 → 填写身份配置 → Rojo 同步 → Studio Play”的验证。
2. 初始化步骤不含 Boss、技能、场景、UI 美术等具体游戏业务。
3. 工具能在修改前输出预览，并提供“新项目初始化 / 已上线项目禁止改数据命名空间”的明确门禁。
4. Studio 中验证：调试面板默认收起、点击 `ToggleButton` 可展开、正式服务器仍不显示。

### 当前状态

- 2026-08-08：`YanzoFrame_GameAnimationEffects` 已完成第一份项目内验证记录。
- 结论：先保留为“框架复制与初始化流程候选”；等第二个独立游戏复验后，再决定是否提取为 YanzoFrame 的正式配置或工具。
