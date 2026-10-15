---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-10-15
updated: 2026-10-15
---

# Demo 素材与 HUD 试验工作流

用于已经明确授权的 Studio 派生试验：先在独立空白场景中验证一个模型展示区、主 HUD 与可操作背包，再验证骨架动画或 Blender 转换。输入来自 [[10_原始资产分类与素材库整理工作流|原始素材库]]，原 raw 与分类库保持只读。界面交互使用新写的演示 Luau；不恢复归档脚本、不执行归档游戏代码，也不据此宣称原游戏玩法已恢复。

## 1. 本机参数与目标绑定

实际目录和 Studio 目标写在 Vault 外的本机配置或本次运行参数中。共享文档只记录角色与相对路径，不能把历史案例的 PlaceId、机器盘符、用户名、端口、归档路径或 HTTP 地址当默认参数。

| 参数角色 | 含义与校验 |
|---|---|
| `archiveRoot` / `sourceScene` | 原归档根与原场景文件，执行前后核对 `sourceSceneSha256` |
| `libraryRoot` | 分类素材库根，按索引相对路径与 SHA256 选择模型、UI 图片和其他依赖 |
| `demoRoot` | 独立派生包目录，不得位于原归档或分类库内部 |
| `bridgeRoot` | 本次桥接服务提供的输入目录与 captures 写入目录，限定已审核输入与本次输出 |
| `bridgeBaseUrl` / `localPort` | 从本机运行配置构造回环地址，源脚本通过参数取得，不写死旧机器地址或端口 |
| `expectedPlaceId` / `expectedUniverseId` / `studioId` | 绑定当前明确确认的 Studio 实例；每次写入前重新读取核对 |
| `demoIdentity` / `demoLabel` | 本包身份与显示名称；属性标记用于限定安装、更新和撤回范围 |

先读取 Studio 编辑/运行状态、Workspace 与 StarterGui 等服务的原始顶层对象和数量。目标名称仅用于展示，实际写入核对 PlaceId/UniverseId 与实例身份。保存原生完整 `.rbxl` 副本及必要的编辑根 `.rbxm` 快照、状态 JSON，记录字节数和 SHA256；Terrain 的保留范围与快照范围分别说明。任何解码器警告原样保留；离线解码成功不等于所有引擎字段均被支持。

本地桥仅绑定回环地址，并限定输入文件与 capture 写入角色。启动端口、服务根、请求 URL 和源文件名全部由本次参数构造。若 HTTP 设置需要临时改变，先记录原值并在撤回时恢复；不要把开发桥依赖留入游戏正式运行代码。Roblox 的 Studio 插件可与 localhost 服务通信，但各插件的请求权限仍按当前环境实际状态检查。[官方 HTTP 说明](https://create.roblox.com/docs/cloud-services/http-service)

## 2. 区分模板 UI 与运行时 HUD

`StarterGui` 保存启动模板；客户端 `PlayerGui` 可包含进入游戏后动态创建或修改的 HUD。只提取 StarterGui 不能据此声称取得了完整运行态界面。先对照原始场景与已有索引，记录 UI 来源角色、原实例路径、referent、捕获时间和来源 hash：

- `StarterGui` 模板保留可编辑的面板、按钮、布局与初始状态。
- 已实际捕获的本机玩家 `PlayerGui` 动态界面另存为 `HUDRuntime` 等明确角色；不能把别的玩家对象或无关 CoreGui 当作主 HUD。
- `HUDRuntime` 是派生包中的角色名，不预设原游戏存在同名对象。未捕获的运行态元素列为缺口，不凭截图补成“原件”。

模板、运行态 HUD 与新写的控制层分别保存来源关系，防止重复叠加两套血条/背包。导出派生 XML 时剔除 Script、LocalScript、ModuleScript 及 Source/ProtectedString，同时记录剔除数量和原路径；原始归档不动。

可复用的界面根保持为 `ScreenGui`，直接放在 `StarterGui` 下，通过属性标记分组，避免再套 Folder 而改变重生行为。需要重生后保留的界面设置 `ResetOnSpawn=false`，并实际测试一次重生后的数据与按钮连接。该属性的保留条件包括 ScreenGui 是 StarterGui 的直接子级。[官方界面容器说明](https://create.roblox.com/docs/ui/on-screen-containers)

## 3. 模型与资源依赖

第一轮只选一个模型，保留实例层级、比例和原变换证据。放入独立展示根，并记录移动/缩放/锚定/碰撞等派生变更。需要重新设置生成点、相机或基础场景属性时，记录原值与撤回值。

贴图、网格和音效的“本地原文件已保存”“模型属性仍为在线 ID/URL”“当前 Studio 能加载”“新项目有权限”“已替换为可部署引用”是不同状态。按依赖记录逐项填写，不把 PNG/mesh 副本存在当作模型已离线可用。缺失、403/404、格式不支持、未验证与成功分开记录，输出 `validation/missing-dependencies.json`。只根据本轮明确授权处理资产引用，不悄悄扩大下载、上传或发布范围。

对有本地文件的资源，记录复制来源 hash、派生位置、原 URI、使用属性及当前替换策略。保留 URL 便于重现来源，但应明确它仍依赖外部可访问性。无法关联时使用可辨识占位与替换入口，并保留原始引用记录。

## 4. 新写演示控制层

`fresh-demo-code` 只控制这次 Demo：模拟血量、能量、经验、货币，开关背包/属性面板，选择物品，显示技能冷却与通知。原界面只有结构时，新的控制层按实际组件名称绑定；缺失组件不得无声失败，应输出可诊断状态。演示状态与真实游戏状态隔离，不调用原游戏 RemoteEvent/RemoteFunction。

控制器保存在独立 `scripts/`，manifest 明确 `recoverOriginalLuau=false`、`executeArchivedScripts=false` 和脚本新写来源。控制器、安装与撤回脚本分别记录 hash。不要把新写 Luau 误记为“原脚本恢复”。

安装前检查专属命名根和身份标记；同名但未匹配本包身份的对象必须停止并报冲突。撤回只处理本包创建的模型、UI、脚本和记录的属性变化，不清空整项目。保存完整基线文件是恢复手段，不能把“已有基线副本”当作实际撤回已通过。

## 5. 派生包与同一只读验收命令

```text
<DEMO_ROOT>/
  build-manifest.json                 本次目标/来源hash/策略/相对文件索引
  baseline/<BASELINE_PLACE>.rbxl       实际取得的完整原生场景基线
  baseline/scene.rbxm                 明确范围的编辑根快照
  baseline/state.json                 原对象/属性/设置及快照范围
  assets/models/                     模型XML与Studio可加载副本
  assets/ui/                         模板/运行态HUD的XML与原生副本
  scripts/                           新写controller/install/rollback
  tools/verify_demo_package.py         stdlib只读包校验器
  validation/                        Studio实测、依赖缺口和命令证据
  README.md                           导入方法/交互/实际限制/来源关系
```

包中路径均相对于 Demo 根。`build-manifest.json` 使用同一 schema：基线 `stage=baseline` 且 `components`、`freshScripts`、`dependencyFiles` 为空；候选 `stage=modified`，各文件含相对路径/大小/SHA256。模型/UI XML 可独立解析；二进制副本由 nativeFiles 等明确索引。实际校验字段以包内 verifier 为准，不伪造示意字段。

在包根执行同一个只读命令，分别记录 BASELINE、MODIFIED 与 ROLLBACK 的命令、输入、stdout、stderr 和退出码：

```powershell
python tools/verify_demo_package.py --package .
```

需要同时验证原场景时，通过 `--source-scene <SOURCE_SCENE>` 显式传入本机路径；不把该路径写回共享模板。校验器独立检查实际 XML 根、实例类别与归档脚本剔除、文件路径边界/存在性/大小/hash、组件最小类别计数与新脚本角色。它不执行 Lua，也不替代 Studio 导入、渲染和交互验收。

## 6. Studio 实测、撤回与再次导入

依次记录真实状态：导入前空场景基线 → 导入后编辑态 → Play 中玩家界面与交互 → Stop → 撤回后基线 → 再次导入后的最终 Demo。每次写入仍核对已绑定目标，不能在另一个 Studio 场景重复执行旧命令。

| 实测项目 | 至少记录的观察 |
|---|---|
| 模型展示 | 主要几何/比例/位置、贴图成功与失败、碰撞/锚定、展示区域是否可到达 |
| 主 HUD | 可见组件、文字、条形/数值变化、菜单状态、运行日志 |
| 背包 | 打开/关闭、选择物品后的可见反馈与当前选择状态 |
| 重生 | ScreenGui 是否保留、模拟状态与信号连接是否重复或丢失 |
| 设备适配 | 实际测过的桌面/手机横屏/平板尺寸，未测尺寸列未验证 |
| 回退 | 专属根撤回、生成点/相机/HTTP等改动恢复、原对象身份与关键属性 |

除自动状态断言外，保留一次真实按钮/键盘操作与截图，避免只给隐藏属性赋值就宣称操作体验通过。若测试通过内部调试接口触发，明确它与人工点击的验证范围。

文件事务使用同四角色路径：`MODIFIED_FILE.zip`、可精确重构的 `DIFF_FILE.json`、追加旧证据的 `VERIFICATION.txt`、可执行 `ROLLBACK.sh`。旧角色及其基线先按字节保存到历史，再发布本轮角色。文件回滚在单独候选副本上运行，恢复 hash 等于基线后重新应用修改；Studio 撤回另用实际场景观察验证，两者不互相替代。

## 7. 迁移与后续阶段

迁移时复制原归档、分类素材库、Demo 包和所需工具，重新填写本机目录、桥地址与 Studio 目标，核对输入 hash 和包校验后在新的空白试验场导入。保留原案例 PlaceId 作为证据，不用它自动选择新目标。

第一轮完成到“一个模型展示区＋主 HUD＋可操作背包”。骨架/动画样本随后验证权重、静止姿态、命名映射和实际播放；Blender 另行记录几何、材质、骨架和动作的转换结果。任一阶段未执行都保持未验证，不把静态导入通过延伸为完整玩法、蒙皮动画或 Blender 可用承诺。

## 历史实例：2026-10-15 Demo001 首轮试验

本轮在已确认的空白场景中试验 2 个模型样本：一个 ChocolateIsland 网格样本和一个原生 Berry 部件样本；保留 Main/Backpack 模板与已捕获的运行态 HUDRoot，派生 XML 独立检查后共 1,778 与 87 个实例。场景实际启用 2 个直接位于 StarterGui 的 ScreenGui，资产源副本存入独立资料根。原逻辑未恢复，导入资产中没有归档脚本对象，所有交互来自新写演示代码。

桌面 Play 实际鼠标/键盘操作验证受伤、药水、背包选择/装备、货币/经验变化与技能能量状态；重新安装后等待 controllerReady，再验证 9 项模拟状态断言及冷却结束。实际撤回恢复到 Workspace 4 个顶层对象、StarterGui 0 个、ReplicatedStorage 0 个，原对象身份与主要几何属性匹配，然后再次安装并保留在 Edit 状态。初次桥连接错误与过早 readiness 断言失败均与成功重试一起保留。

手机模拟器只检查横屏布局，操作仍是桌面鼠标模拟，未做真实触控验收。ChocolateIsland 的网格/贴图仍是在线 URI，未重绑到本地资源，也未宣称完全离线可用。保留的完整 `.rbxl` 是导入前基线；安装后的 `.rbxm` 只含明确角色快照，未另存完整最终 `.rbxl`。骨架/动画、Blender 转换、重生与真实手机触摸不借本次结果升级为已验证。

这些实例名、日期与数量仅作历史证据，不作为下次执行参数。可迁移包内实际证据角色为 `validation/studio-events.json`、桌面/手机截图、`native` 角色快照及依赖缺失清单；位置由本机 Demo 根映射。

返回 [[README|工作流入口]]；素材分类见 [[10_原始资产分类与素材库整理工作流]]；本机配置见 [[08_环境迁移与参数配置]]。
