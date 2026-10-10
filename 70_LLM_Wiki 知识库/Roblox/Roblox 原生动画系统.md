---
type: concept
domain: roblox
status: evergreen
owner: codex
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# Roblox 原生动画系统

## 一句话说明

Roblox 原生动画系统分三层：编辑层做关键帧，资产层发布 AnimationId，运行层用 Animator 和 AnimationTrack 播放。

## 三层结构

| 层级 | 你在做什么 | 关键对象 |
|---|---|---|
| 编辑层 | 在时间轴上摆姿势、打关键帧 | Rig、Track、Keyframe、Easing |
| 资产层 | 保存本地编辑数据或发布成 Roblox 资产 | KeyframeSequence、AnimationId |
| 运行层 | 用脚本加载并播放动画 | Animation、Animator、AnimationTrack |

## Save 和 Publish

| 操作 | 结果 | 是否适合脚本播放 |
|---|---|---|
| Save | 保存本地编辑数据 | 不推荐作为正式运行入口 |
| Publish to Roblox | 上传为云端动画资产，生成 AnimationId | 可以脚本播放 |

最小记忆：

```text
Save 是保存工程文件。
Publish 是生成可运行资产 ID。
```

## 运行时对象

- `Animation`：保存 `AnimationId`。
- `Animator`：真正加载动画的对象。
- `AnimationTrack`：播放控制对象，可以 `Play`、`Stop`、调速度、调权重、监听事件。

## 播放位置选择

| 场景 | 推荐位置 | 原因 |
|---|---|---|
| 本地玩家自己的输入反馈 | LocalScript | 响应快 |
| NPC / Dummy / 怪物 | 服务端 Script | 所有玩家都要看到 |
| 攻击命中、扣血、奖励 | 服务端决定 | 防作弊 |
| 镜头、纯视觉特效 | 客户端 | 不影响权威状态 |

经验规则：

```text
动画可以客户端先播，结果必须服务端决定。
```

## 优先级心智模型

动画优先级不是简单地整个人物覆盖。它按有关键帧的关节覆盖。

如果攻击动画只给右手打关键帧，腿部可能仍然播放走路动画。攻击动画通常要给上半身关键关节也打关键帧。

常见选择：

- 待机：`Idle`
- 走路 / 跑步：`Movement`
- 普通攻击 / 交互：`Action`
- 技能 / 受击：`Action2` / `Action3`
- 死亡 / 强控：`Action3` / `Action4`

## Animation Event Marker

Marker 用于动画播放到某一帧时触发逻辑：

- 脚步声。
- 命中帧。
- 技能特效。
- 拾取动作。

正式战斗里，Marker 只能作为表现触发点或请求点，不能让客户端单方面决定伤害成立。

## 常见排查

- 动画不播放：检查 AnimationId、Publish、Animator、Rig 类型、权限。
- 自己能看别人看不到：检查是否只在 LocalScript 播 NPC，或 owner 与 experience owner 不一致。
- 优先级不生效：检查目标关节是否有关键帧，是否有更高优先级动画。
- 循环卡顿：检查第一帧和最后一帧是否能无缝衔接。
- FBX 扭曲：检查 R15/R6、骨骼命名、Bake Animation、缩放和坐标轴。

## 来源

- [[20_Areas 领域/Roblox/框架/模块系统/动画系统/Roblox 原生动画系统]]

## 相关链接

- [[Roblox 项目架构职责边界]]
- [[Client Server Remote 请求链路]]

