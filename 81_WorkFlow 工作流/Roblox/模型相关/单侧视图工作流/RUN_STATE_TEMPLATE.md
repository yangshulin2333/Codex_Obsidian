---
type: workflow
domain: roblox
status: active
owner: mixed
source: self
created: 2026-08-17
updated: 2026-08-17
---

# 单侧视图运行状态模板

复制到：

```text
<run_dir>\_docs\RUN_STATE.md
```

---

## 基本信息

- 资产名：`<asset_name>`
- 资产类型：`<weapon / prop / machine / container / ornament / other>`
- 用途：`<Tripo / Hunyuan / Meshy / other>`
- 创建日期：`<YYYY-MM-DD>`
- 父工作流：`<none / run directory>`
- 输出模式：`<standalone_single_side / parent_workflow_repair>`
- 当前状态：`SIDE_RUN_CREATED`
- 当前目标文件：`<left.png / right.png / side_a_90.png / side_b_90.png>`
- 当前活动生成任务：`<none / task id>`

## 输入图片角色

| Image | 路径 | 角色 | 是否已确认 | 备注 |
|---|---|---|---|---|
| 1 | `<path>` | accepted front design lock | `<yes/no>` | |
| 2 | `<path/none>` | back / double-sided evidence | `<yes/no>` | |
| 3 | `<path/none>` | structure / 45° evidence | `<yes/no>` | |
| 4 | `<path/none>` | opposite-side thickness benchmark only | `<yes/no>` | 禁止镜像 / 像素复用 |
| 5 | `<path/none>` | current edit target | `<yes/no>` | 修复模式使用 |

## 相机合同

- `camera_count=1`
- `projection=ORTHOGRAPHIC`
- `view=<LEFT / RIGHT / SIDE A / SIDE B>`
- `yaw=<-90° / +90° / confirmed semantic value>`
- `pitch=0°`
- `roll=0°`
- 主轴：`<vertical / horizontal / custom>`
- 平台轴向映射：`<default / remapped with reason>`

## 几何分类

- 基础类：`<P1_THIN_PLATE / P2_LONG_HEAD / P3_LAYERED_FLAT_VOLUME / V1_ROUND_VOLUME / V2_BOX_IRREGULAR_VOLUME / O1_OPEN_FRAME>`
- 修饰合同：`<A_ASYMMETRIC / D_DOUBLE_SIDED / R_ROTATIONAL / H_SHAFT_ANCHORED / C_CAVITY_CRITICAL / none>`
- 分类证据：`<front/back/45/user statement>`
- 不采用其他分类的原因：`<short reason>`

## 结构卡

- 主体横截面：`<thin plate / layered slab / round / box / irregular / open frame>`
- 主体前后深度：`<relative value or evidence>`
- 前侧凸起：`<parts and thickness>`
- 后侧凸起：`<parts and thickness>`
- 侧向结构：`<parts, count, order, position>`
- 孔洞 / 插槽：`<visibility and occlusion>`
- 柄 / 轴：`<start, end, diameter, straightness>`
- 接口 / 环箍 / 尾饰：`<count and landmarks>`

## 当前目标侧可见性合同

- `target_view`：`<target>`
- `must_visible`：
  - `<item>`
- `must_hidden`：
  - `<item>`
- `count_order_position`：
  - `<item>`
- `occlusion`：
  - `<item: full / partial / edge / hidden>`
- `thickness_landmarks`：
  - `<item>`
- `forbidden_transfer`：
  - `<opposite-side item>`
- 用户确认原话：`<quote / already explicit in request>`
- 确认日期：`<YYYY-MM-DD>`

## 锚点与画布

| 锚点 | 设计锁位置 / 比例 | 当前候选 | 状态 |
|---|---|---|---|
| 总高度 / 长度 | `<value>` | `<value>` | `<PASS/FAIL>` |
| 主体中心 | `<value>` | `<value>` | `<PASS/FAIL>` |
| 柄 / 轴起点 | `<value>` | `<value>` | `<PASS/FAIL>` |
| 柄 / 轴终点 | `<value>` | `<value>` | `<PASS/FAIL>` |
| 环箍 / 接口 | `<value>` | `<value>` | `<PASS/FAIL>` |
| 尾饰 / 端帽 | `<value>` | `<value>` | `<PASS/FAIL>` |
| 画布尺寸 | `<WxH>` | `<WxH>` | `<PASS/FAIL>` |

## 镜像授权

- 授权状态：`NOT_AUTHORIZED`
- 来源文件：`<none>`
- 目标文件：`<none>`
- 用户原话：`<none>`
- 授权日期：`<none>`
- 执行方式：`<independent_generation / deterministic_horizontal_flip>`
- 往返像素校验：`<NOT_APPLICABLE / PASS / FAIL>`

## 候选记录

| Candidate | 路径 | SHA-256 | 尺寸 | 主失败码 | 处理 |
|---|---|---|---|---|---|
| 01 | `<path>` | `<hash>` | `<WxH>` | `<none/code>` | `<waiting/approved/rejected>` |

## 当前提示词

- 文件：`_docs/PROMPT.md`
- 本轮只修改：`<camera / thickness / visibility / landmark / background / none>`
- 参考模板：`<base + geometry supplement + modifier>`

## 自动检查

- 文件可解码：`<PASS/FAIL>`
- 相机 90°：`<PASS/FAIL>`
- 正交无透视：`<PASS/FAIL>`
- 主轴姿态：`<PASS/FAIL>`
- 几何分类：`<PASS/FAIL>`
- 可见性合同：`<PASS/FAIL>`
- 锚点：`<PASS/FAIL>`
- 身份 / 风格：`<PASS/FAIL>`
- 背景 / UI：`<PASS/FAIL>`
- 未授权镜像检查：`<PASS/FAIL/NOT_APPLICABLE>`

## 人工审核

- 审核副本：`<path>`
- 资源管理器已置前：`<yes/no>`
- 用户结论：`<waiting/approved/rejected>`
- 用户原话：`<quote>`
- 日期：`<YYYY-MM-DD>`

## 正式输出

- 正式文件：`<path>`
- SHA-256：`<hash>`
- 尺寸：`<WxH>`
- 来源候选：`<candidate path>`
- 正式目录文件数：`<1 / parent contract>`
- 最终状态：`<SIDE_FINALIZED / not finalized>`

## 下一步

```text
<只写一个下一步动作>
```

## 不需要读取

- 旧资产输出。
- 被拒绝候选（除非当前失败复盘明确指向）。
- 与当前目标侧无关的联系表和平台结果。

相关入口：[[README|单侧视图生成工作流]]。
