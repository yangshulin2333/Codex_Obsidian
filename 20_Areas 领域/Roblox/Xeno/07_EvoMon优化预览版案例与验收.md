---
type: project
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-10-10
updated: 2026-10-12
---

# EvoMon 优化预览版案例与验收

**历史案例：** 本页所有游戏 ID、日期、文件名、版本、目录命名、地点/脚本数量和 hash 只描述这次已记录运行。当前默认只做原始归档，不能从本页自动启用恢复/预览或复制本机路径。环境与本次参数见 [[08_环境迁移与参数配置]]；外部证据统一由 artifactId/角色/相对路径解析。

2026-10-10，在 `Roblox_EvoMon客户端补全归档V2_含启动入口_20261009` 的基础上生成独立优化副本：恢复可读脚本、清理不可用引用、修正预览启动问题，交付可用 Studio 打开的 `.rbxl` 和带入口 ZIP。结果是**静态客户端场景与源码浏览版**，原游戏玩法和服务端工程没有恢复。

通用方法见 [[06_字节码恢复与场景优化工作流]]，原始归档流程见 [[01_Xeno客户端内容归档通用工作流]]。

## 目标与成果

- 原 Place：`134381727982611`，Universe：`9826885587`。
- 原输入是之前捕获的 EvoMon V2，不是处理时电脑上的其他游戏。
- 输出目录：[EvoMon 优化预览版](09_历史案例资源索引.md#hist-evomon-preview-evomon-20261010)。
- 场景：[EvoMon_优化预览场景.rbxl](09_历史案例资源索引.md#hist-evomon-preview-evomon)。
- 交付：[完整压缩包](09_历史案例资源索引.md#hist-evomon-preview--evomon-20261010)。
- 汇总：[optimization-summary.json](09_历史案例资源索引.md#hist-evomon-preview-optimization-summary)。

| 项目 | 实际结果 | 含义 |
|---|---:|---|
| 有效原字节码 | 2,787 份 | v13 2,786 份，v9 1 份；2,522 个独立 SHA |
| 严格模式恢复源码 | 2,780 份 | 官方解析/重新编译通过，AST 分析完成；57 份结构差异待复核，已写回副本 |
| 原本为空的编译 chunk | 15 份 | 属于上述 2,780，不计作恢复了有内容的功能 |
| 合成控制流候选 | 2 份 | 单独放 `scripts/candidates`，没有写回场景 |
| 仍未恢复的字节码 | 5 份 | 严格失败的 7 个实例均保留反汇编，2 个另有候选 |
| AST 函数数量差异 | 57 份 | 需要复核，不能由编译通过推断运行等价 |
| 索引中没有字节码的条目 | 23 条 | 12 个服务端源码未复制、10 个 Source 缺失、1 个导出 README |
| 本地素材 | 668 文件 | 全部包内及本机部署 SHA/大小验证通过 |
| 原生场景大小 | 11,063,939 字节 | Lune 0.10.5 生成标准 `.rbxl`，Studio 编辑加载与 Play 预览通过 |
| ZIP | 90,375,653 字节，6,269 文件 | 文件集合、CRC、每条目大小与 SHA256 全通过 |

## 脚本恢复做了什么

采用本机实测的 **Tovek 2.5.1**，识别该导出的 opcode 编码后先抽样，再严格批量恢复；用官方 **Luau 0.742** 编译器、语法/AST 工具验证。工具下载包对照开发者发布 digest 验证，保留本地 SHA 和审阅范围。上述版本是这次验证记录，不代表下次的最新版或兼容性保证。

恢复代码分别保存在 `scripts/readable`、`scripts/candidates`、`scripts/unrecovered-listings`，原字节码复制到 `scripts/original-bytecode`。统一索引保留 `index / referent / fullPath / bytecodeSha256 / sourceFile / sourceSha256`，路径相对于成果包；5,576 个索引文件的复制长度与 SHA 全部一致。

2,780 份严格模式源码写回对应实例。原 Script/LocalScript 默认停用，ModuleScript 保留为可阅读资料，不由预览入口 require；未恢复的占位脚本转为资料 Folder。只有两个独立编写的预览脚本启用。解析与编译通过只是静态门槛，AST 差异不因成功输出而自动消失。

两份 MessagePack 脚本的 AST 输出含非 UTF-8 二进制字符串，使用保留原字节的解码方式复核，六种相关字节串均逐字保持。没有把丢失 AST 统计或 `return nil` 占位当成成功恢复，也没有运行原游戏或恢复后的游戏逻辑。

证据：[脚本统一索引](09_历史案例资源索引.md#hist-evomon-preview-index)、[工具来源与 SHA](09_历史案例资源索引.md#hist-evomon-work-tool-provenance)、[完整静态验收](09_历史案例资源索引.md#hist-evomon-work-full-source-validation)。

## 资源与场景清理

原 V2 的 9,988 个下载请求中有 7,348 次 401、1,946 次 403、9 次 404；这些数字不是当前场景不可用对象数。只处理与实际对象、class/property、规范资源键和正常渲染验证对应的项。

额外核对 21 个旧清单遗漏 ID，普通无凭据下载取得 3 个 PNG、1 个 mesh，其余记录权限失败。最终本地素材有 668 文件；38 个字体 JSON 的 182 个 face 依赖已派生为明确的本地 URI。启动器把素材部署到所选 Studio 的专属 `content/codex-evomon-v3-20261010` 目录，再验证 SHA 后打开场景，未改变执行策略或安全设置。

| 清理动作 | 记录数量 | 解释 |
|---|---:|---|
| 清除不可用 URI | 16,069 | 序列化字段级统计，不是独立资产数 |
| 移除不可用素材实例 | 8,357 | 与实际字段用途对应，未按下载失败数整件删除模型 |
| 本地 URI 重映射 | 19,240 | 字段级计数；部分网格仍保留原在线/缓存引用 |
| 内容重复别名去重 | 62,227 | 同一内容的旧/新字段重复项，保留兼容字段 |
| 移除云端包链接及不支持的 PBR 组件 | 12,293 | 保留父几何，降为基础材质，可能出现白色或无贴图表面 |
| 清除自定义基础材质覆盖 | 40 | 解除 MaterialVariant 依赖 |
| 固定 Workspace 动态零件 | 3,872 | 防止静态预览时下坠 |
| 默认关闭旧 ScreenGui | 368 | 保留界面资料，避免依赖旧逻辑的界面覆盖预览 |
| 修正同名服务快照 Folder | 2 | 归档玩家快照/客户端模块改名，不冒充真实服务 |
| 修正无效脚本容器 | 2 | 旧特殊容器位于归档 Folder 中，降为普通资料 Folder |
| 未恢复占位脚本转为资料 Folder | 30 | 23 条无字节码记录＋7 个严格恢复失败实例；其中 2 个候选另存，不作为运行脚本 |

### 两个不能再重复的误判

**通用 URI 预加载不能判定所有模型或字体不可用。** 一次把 5,824 个 URI 当普通字符串预加载得到 5,214 个 Failure，但不能由此证明对应 MeshPart 或 FontFace 的实际用途失败。由此尝试的网格替换已撤回，最终没有按这批结果把网格改成方块。最终保留网格，使用正常编辑/预览中的真实属性和日志验证。

**本地 PNG 可读不等于 PBR 能用。** SurfaceAppearance/MaterialVariant 的 texture pack 用途不同；本机出现 `Local asset is not supported in client` 后移除了这些组件并解除覆盖。由此产生的外观降级明确保留，不能称完全还原了原画面。

## 独立预览与实际验收

预览服务器脚本关闭 Avatar 自动出生，客户端脚本提供 Scriptable 自由相机。原导出人物仍可作为静态快照显示，但不是正在运行的玩家角色。支持 WASD、Q/E、右键转向、Shift 加速、滚轮调速、F 回入口、H 面板开关及八个已保存地点的菜单。

预览关闭了 `StreamingEnabled`：没有活动角色作为加载中心时，原游戏的流式规则会卸载保存的岛屿。关闭后客户端 Workspace 保留 3,672 个网格零件；这只适用于本次静态浏览，不作为生产游戏优化建议，也不会补出未捕获的地图。

Studio 0.742.0.7421053 的实际测试结果：

本次场景由 **Lune 0.10.5** 从派生 XML 转换生成 `.rbxl`，并完成二进制重开检查；随后由 Studio 实际编辑加载与 Play 预览验证。该生成路径没有使用 Studio SaveAs，不借旧原始归档的 SaveAs 证据证明本次优化生成过程。见 [格式转换记录](09_历史案例资源索引.md#hist-evomon-work-preview-conversion-record)。

- 编辑加载通过，只有 `ArchivePreviewSetup` 和 `ArchivePreviewCamera` 两个脚本启用；Workspace 未锚定零件为 0。
- 客户端自由相机、预览 GUI 正常出现；地点 2 和面板切换已测。
- 最终编辑日志为空，Play 日志只有两个预览就绪信息，本次测试中权限/加载报错为 0。
- 测试覆盖静态预览，不覆盖全部原玩法、所有资产未来账户/网络条件或全部恢复脚本运行。

证据：[Studio 验收](09_历史案例资源索引.md#hist-evomon-preview-studio-preview-verification)、[已部署素材校验](09_历史案例资源索引.md#hist-evomon-preview-local-content-deployment)、[入口与脚本边界独立审查](09_历史案例资源索引.md#hist-evomon-preview-launcher-and-script-boundary-audit)。

## 使用与交付校验

完整解压 ZIP，双击 `启动场景.cmd` 完成该版本 Studio 的本地素材部署，再点 Play 进入预览。当前电脑已部署后也可以直接打开根 `.rbxl`；换电脑或 Studio 安装版本更新后重新运行入口。`-CheckOnly` 只读验证，不部署素材或打开 GUI。原游戏逻辑默认不运行。

```text
ZIP SHA256
396a21ce89b299c13e8f80acd6ceb28ac79e0d1b04bec202d1d5877157ff2235

最终 rbxl SHA256
1066c844f56db29a36b827b23e31229b205685471248f83b09188326a7aeaac4
```

[最终 ZIP 验收报告](09_历史案例资源索引.md#hist-evomon-work-complete-package-verification)确认文件集合、CRC、逐条目大小/SHA 和原生场景 SHA；lock、缓存和处理中间 XML 不入最终包。

原 V2 的 `.rbxl`、原 XML、脚本索引和字节码数据没有改写。本轮导入历史 Python 解析器曾生成一枚 `__pycache__`，缓存清理受审批限制未完成，但没有带入新包；不声称原目录文件集合完全不变。后续只读导入先关闭 Python 缓存写入或使用工作区副本。

## 保留的限制与下一步

原服务端脚本、完整玩法、未加载区域、所有动画行为没有恢复；部分网格依赖在线或缓存；PBR 降级后有白色/基础材质；编译通过不证明原运行等价。没有开展 FPS、内存或完整玩法性能对比，因此不以“优化”宣称性能提升百分比。

后续优先按模块复核 57 份 AST 差异和两个候选，再针对具体需要恢复的功能建立独立运行测试。返回 [[README|工作流入口]]。
