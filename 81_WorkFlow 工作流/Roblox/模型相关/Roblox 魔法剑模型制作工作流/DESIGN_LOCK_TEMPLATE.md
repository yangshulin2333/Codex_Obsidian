---
type: template
domain: roblox
status: active
owner: mixed
source: self
created: 2026-08-04
updated: 2026-08-12
---

# 魔法剑设计锁模板

## 1. 资产信息

```text
ASSET_NAME=
ASSET_TYPE=
MODEL_TARGET=
OUTPUT_ROOT=
CANVAS_SIZE=
UPLOAD_VIEW_MODE=Eight | Six
AXIAL_SOURCE_MODE=same_asset_ai | proxy_render | not_included
SIDE_VISIBILITY_CONTRACT_STATUS=draft | confirmed
SIDE_GEOMETRY_REUSE_AUTHORIZATION=none | user_confirmed
SIDE_GEOMETRY_REUSE_AUTHORIZED_OUTPUTS=无 | 例如 left->right
```

## 2. 视觉 DNA

```text
造型语言：
主色 / 辅色 / 核心色：
主体金属：
宝石或能量材质：
装饰密度：
块面尺寸：
剑刃轮廓：
护手轮廓：
握柄轮廓：
剑首轮廓：
Roblox 质感：
禁止风格：
```

## 3. XYZ 几何锁

```text
X=护手左右宽度
Y=剑尖到剑首的总长
Z=正面到背面的厚度

X:Y:Z=
剑身长度 / 总长=
握柄长度 / 总长=
护手宽度 / 总长=
剑身最大宽度 / 总长=
剑身厚度 / 剑身最大宽度=
```

### 画布归一化

```text
理论包围盒 X:Y:Z=
front/back 交付占比=
left/right 交付占比=
top/bottom 原始占比=
top/bottom X/Z 统一放大倍数=
top/bottom 最终占比=60%-80%
```

## 4. L0-L3 连接层级

```text
L0：
L1：
L2：
L3：
```

## 5. 关键零件清单

| P-ID | 零件 | 数量 | 层级 | 所属表面 | 连接对象 | 有无厚度 | 允许在哪些视图出现 |
|---|---|---:|---|---|---|---|---|
| P-01 |  |  |  |  |  |  |  |

数量和表面归属一旦锁定，后续视图不得擅自增减。

## 6. 可见性矩阵

| 结构 | front | back | left | right | top | bottom | left45 | right45 |
|---|---|---|---|---|---|---|---|---|
| 剑身正面 | 完整 | 隐藏 | 极窄边 | 极窄边 | 截面 | 截面 | 缩短 | 缩短 |
| 正面核心 | 完整 | 隐藏/背板 | 侧厚度 | 侧厚度 | 不得翻到端面 | 不得翻到端面 | 缩短+厚度 | 缩短+厚度 |
|  |  |  |  |  |  |  |  |  |

### 6.1 侧向逐输出可见性合同（生成前必填并确认）

Codex 必须主动询问并逐文件复述以下四份合同。不得以“是否对称”代替此表，也不得凭外观补全。四份合同未经用户确认时，禁止生成 `left/right/left45/right45`。

| 输出 | 相机方向 | must-visible | must-hidden | 方向性结构 P-ID、数量和位置 | 遮挡关系 | 用户已确认 |
|---|---|---|---|---|---|---|
| `left.png` | 从 -X 看向 +X，正交 90° |  |  |  |  | 否 |
| `right.png` | 从 +X 看向 -X，正交 90° |  |  |  |  | 否 |
| `left45.png` | 绕 Y 轴 -45° |  |  |  |  | 否 |
| `right45.png` | 绕 Y 轴 +45° |  |  |  |  | 否 |

缺少任一行或未获确认时记录 `SIDE_VISIBILITY_CONTRACT_MISSING`。生成结果违反任一项时记录 `SIDE_VISIBILITY_CONTRACT_BROKEN`。

### 6.2 侧向几何复用 / 镜像授权记录

默认不授权。只有用户明确说明指定两个输出可以共用几何时才填写；不得由 Codex 根据外观或“对称性”自行判断。

```text
授权状态=none | user_confirmed
授权输出对=
允许动作=geometry_reuse | mirror
用户授权原文=
确认日期=
```

无有效记录而复用或镜像任何侧视 / 45 度输出，记为 `UNCONFIRMED_SIDE_MIRROR`。

## 7. 背面和端面定义

```text
背面是否简化：
背面核心结构：
剑尖端截面：
剑首端截面：
bottom 是否允许出现彩色侧边：
端面禁止出现的正面装饰：
```

### 7.1 轴向证据与来源白名单

```text
AXIAL_EVIDENCE_LEVEL=A | B | C
TOP_ALLOWED_IMAGE_REFERENCES=当前资产 front + 一张严格 side | 当前资产 proxy top
BOTTOM_ALLOWED_IMAGE_REFERENCES=当前资产 front + 一张严格 side | 当前资产 proxy bottom
CROSS_ASSET_AXIAL_REFERENCE_ALLOWED=false
FAILED_CANDIDATE_REFERENCE_ALLOWED=false
TOP_USES_BOTTOM_AS_IMAGE_REFERENCE=false
BOTTOM_USES_TOP_AS_IMAGE_REFERENCE=false
```

如果证据等级为 C，必须把 `UPLOAD_VIEW_MODE` 设为 `Six`，或先建立真实 3D 代理，不能凭空补齐 top/bottom。

### 7.2 轴向 X×Z 表面归属锁

| P-ID / 结构 | X 位置 | Z 厚度 | 从 top 可见形态 | 从 bottom 可见形态 | 是否正面专属 |
|---|---|---|---|---|---|
| 剑身主体 | 中央 |  | 剑尖端楔形/截面 | 刃体截面 | 否 |
| 护手承力结构 |  |  | 边缘/根部截面 | 边缘/根部截面 | 否 |
| 正面核心 |  |  | 隐藏或极窄边 | 隐藏或极窄边 | 是 |
| 剑首端盖 | 中央 |  | 远端遮挡 | 最近实体端盖 | 否 |
|  |  |  |  |  |  |

这张表是 top/bottom Prompt 的结构输入。禁止用“几条导轨”“一个插座”等通用视觉描述替代实际 P-ID、X 位置和 Z 厚度。

## 8. 状态

```text
BRIEF_READY=false
EFFECT_APPROVED=false
DESIGN_LOCKED=false
SIDE_VISIBILITY_CONTRACT_CONFIRMED=false
ORTHOGRAPHIC_APPROVED=false
AXIAL_SOURCE_APPROVED=false
AXIAL_APPROVED=false
AXIAL_BLOCKED=false
ANGLE45_APPROVED=false
PACKAGE_APPROVED=false
MODEL_TESTED=false
```

## 9. 修正记录

| 日期 | 视图 | 问题 | 处理 | 是否影响其他视图 |
|---|---|---|---|---|
|  |  |  |  |  |

## 10. 轴向尝试记录

| 视图 | 尝试次数 | source mode | 图像参考来源 | 是否使用跨资产端视图 | 是否使用失败稿 | 结果 |
|---|---:|---|---|---|---|---|
| top | 0 |  |  | 否 | 否 |  |
| bottom | 0 |  |  | 否 | 否 |  |

同一视图使用 `same_asset_ai` 连续失败两次后，必须设置 `AXIAL_BLOCKED=true`，不得继续追加第三轮 AI 轴向候选。
