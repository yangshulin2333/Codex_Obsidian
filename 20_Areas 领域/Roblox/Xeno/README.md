---
type: index
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-10-12
updated: 2026-10-21
---

# Roblox 客户端归档与派生处理工作流（Xeno 采集方案）

**跨 AI 统一入口：[00_通用工作流_AI执行入口](00_通用工作流_AI执行入口.md)。** 将整个目录交给 DeepSeek、Claude、ChatGPT、Codex 或其他 AI，从任务、能力映射、本地参数和证据开始；无需上一段聊天或特定厂商的 Skill/MCP。首次使用复制入口中的任务提示，中途接手另附填写后的 [handoff.example.json](handoff.example.json)。纯聊天助手由用户执行命令并回传结果，不能声称已直接操作电脑。

默认先保存当前 Roblox 客户端能读取、能取得的原始场景、已有 Source、bytecode、资源与缺失清单，完成文件和 ZIP 校验后停止。**不默认反编译、不清理原场景、不生成预览，也不运行归档游戏脚本。** 以后明确需要 Luau 参考源码时，再对原始包的副本开启恢复阶段。

本目录是一套可复用说明、参数模板和只读配置检查工具；具体采集器/下载器需由当前环境发现、审核并登记。它不包含 Xeno、导出器、反编译二进制或历史游戏资产，也不保证所有工具未来继续兼容。先归档保留了重建输入，不能承诺未来一定恢复源码或完整玩法。

## 从这里开始

先读跨 AI 入口并选择本次目标；下列详细文档及原文件名继续保留，便于旧链接兼容。

1. [[08_环境迁移与参数配置|首次执行或换电脑：发现环境、建立本地配置]]。
2. [[02_快速执行与验收清单|默认原始归档任务提示与阶段验收]]。
3. [[01_Xeno客户端内容归档通用工作流|采集、资源、Terrain、完整性与交付流程]]。
4. [[03_故障排查与适用边界|诊断、缺失、断点与适用边界]]。

所有入口使用当前明确绑定的参数，工具版本、游戏 ID、日期、路径、脚本名不从案例段落推导。`config.example.json` 仅是共享模板；真实机器配置及本次运行文件放在 Vault 外的本地配置目录，见“08”。素材库入口不自动读取本地JSON，archive/output/Lune路径经本机配置确认后通过CLI显式传入。

## 默认拿到什么

```text
<ARTIFACT_ROOT>/captures/<CAPTURE_ID>/
  target.json                         本次身份、范围、时间、版本
  effective-config.sanitized.json      本次有效参数，不含机器绝对路径/凭据
  artifact-index.json                 artifactId、角色、包内相对路径、SHA256
  snapshot/                           原始 XML/原生文件、inventory、start/finish
  scripts/original-bytecode/           实际取得的编译后字节与索引
  scripts/readable-original/           客户端实际能读到的 Source，未反编译
  assets/                             已下载文件、来源、依赖、最终缺失
  terrain/                            可读探针/明确扫描范围、原始通道数据
  tools/                              本次导出器、审核改动、许可、依赖、API dump
  provenance/                         Player/Xeno/引擎/导出器版本与输入哈希
  validation/                         捕获、下载、逐文件与 ZIP 验收
  README.txt                          实际取得范围、未覆盖项、后续入口
<ARTIFACT_ROOT>/packages/<CAPTURE_ID>.zip
```

原生 `.rbxl` 若此次实际取得就原样保存。默认不为了“完整归档”强制启动 Studio 或转换格式；没有原生文件时仍保留可解析原始 `.rbxlx`。原生另存、地形恢复验证可在独立派生目录单独选择，不修改 raw。多个 Place、回合或楼层各自保存独立快照。

“能下载的所有东西”指本次已加载/可读内容、清单中的明示资源及可验证依赖，逐项归档成功或失败；不能补出服务端私有脚本、未加载地图和受限素材。HTTP 权限失败、动态场景变化、decoder 缺口均写入缺失记录。

## 后续可选阶段与历史案例

- [[10_原始资产分类与素材库整理工作流|organize_assets：模型、贴图、骨架/动画、音效素材库与相对索引]]。明确要求素材整理才开启，独立 `asset-library.config.example.json` 保存本机参数，CLI显式传入；原raw保持不变，不转Luau、不自动Play。先执行分类器 `--check-inputs-only` 校验正式原ZIP解压后的metadata/内容hash；素材库从 `index.html` 离线查找，JSON/CSV与全部nested模型索引保留来源关系。原件保留、结构及样本解码证据随库保存于 `validation/`；它们不证明Studio、播放或动画映射已通过。
- [[11_Demo素材与HUD试验工作流|Demo：独立试验场中的模型展示、主 HUD 与可操作背包]]。明确授权后选择来源，保留原生场景基线；模板 UI 与运行态 HUD 分开，交互使用新写演示代码。桥地址、源目录、派生目录和 Studio 目标来自本机参数。模型/UI 导入、Play、撤回与再次导入分别保留实际证据；包结构/hash 校验不代替运行效果。
- [[06_字节码恢复与场景优化工作流|阶段 1：在副本中恢复 Luau 参考源码；阶段 2：独立静态预览]]，必须明确请求后开启。
- [[04_成功案例与参考实现|归档历史案例]]、[[07_EvoMon优化预览版案例与验收|EvoMon 恢复与预览历史案例]]。日期、游戏 ID、版本和数量均为当时案例证据，不是默认参数。
- [[09_历史案例资源索引|历史 artifactId 与根内相对路径]]。换机只变更本地 `historicalEvidenceRoot` 映射；按记录的 hash 核对真实证据。笔记中的索引不是工具文件副本。
- [[05_Obsidian Git每30分钟同步说明|历史笔记同步环境记录]]。笔记同步与游戏归档分开配置；本工作流不自动创建定时任务或推送。

## 保存与迁移

同步本目录的小型文档、模板、检查脚本与历史资源索引；外置保存工具二进制、原始捕获和大 ZIP。执行产物统一使用 artifactId、资源角色与包内相对路径，机器绝对路径只用于本机解析，不写回共享笔记。原件只读，修复/恢复都写新派生目录。

## 相关入口

- [[../../../30_MOC 内容地图/Roblox MOC|Roblox MOC]]
- [[../../../70_LLM_Wiki 知识库/Roblox/Xeno 客户端内容归档|Wiki 摘要入口]]
