---
type: workflow
domain: roblox
status: active
owner: mixed
source: codex
created: 2026-07-13
updated: 2026-07-14
---

# 通用游戏道具运行模板

## v1.3 新运行只需三份文档

### 资产锁_ASSET_LOCK.md

```markdown
# [资产名称] - 资产锁

## 基本信息
- Identity ID:
- RPG 类别 / 用途:
- 目标工具: Hunyuan 3D / TripoAI / other
- 视图集: Four / Six / Eight
- left.png 必须看见 / 必须隐藏:
- right.png 必须看见 / 必须隐藏:
- 45° 对应合同（如使用）:
- 镜像授权: none / 用户明确授权的映射
- Approved front:

## 低模设计
- 一句话剪影:
- 主要结构块:
- 厚度与前后层次:
- 主材质区:
- 保留为几何的细节:
- 改为贴图 / 材质的细节:
- 删除的噪声细节:
- 背面 / 隐藏结构政策:

## 相机与尺寸
- 主轴方向:
- 接地: centered / grounded
- Pivot:
- Forward:
- Up: +Y
- Roblox size: X × Y × Z studs / SCALE_UNCONFIRMED

## 仅在必要时填写
- 身份关键数量:
- 方向性绕向 / 接口:
- 顶底证据:
```

“身份关键数量”只统计数量本身会改变物品身份的部件。装饰花瓣、裂纹、叶脉和光斑通常不逐片编号。

### 运行状态_RUN_STATE.md

```markdown
# 运行状态

- Current stage: INTAKE / FRONT_APPROVED / ACCEPTED_VIEWS_READY / FILES_READY / CONTACT_SHEET_APPROVED / 3D_RESULT_REVIEWED
- Identity ID:
- Approved front:
- Current view:
- Active task / cell id:
- Started at:
- Last heartbeat:
- Stall state: running / completed / GENERATION_STALLED
- Final view set:
- Accepted view count: actual / expected
- Run directory:
- Staged directory:
- Final directory:
- Contact sheet:
- Next action:
```

### 归一化配置_NORMALIZATION_CONFIG.json

```json
{
  "version": "1.3",
  "profile": "centered-yaw",
  "referenceView": "front",
  "referenceAxis": "vertical",
  "targetOccupancyPercent": 82.0,
  "groundDatumPercent": 90.0,
  "backgroundFuzzPercent": 6.0,
  "scaleTolerancePercent": 5.0,
  "maxAutoScalePercent": 12.0,
  "autoNormalizeWithinLimit": true,
  "normalizationViews": ["front", "back", "left", "right", "left45", "right45"],
  "manualReviewViews": ["top", "bottom"]
}
```

落地道具把 `profile` 改为 `grounded-yaw`。横向长轴道具把 `referenceAxis` 改为 `horizontal`。

## 按需文档

### 提示词记录_PROMPTS.md

只在需要复用、对比或修复提示词时创建：

```markdown
# 提示词记录

| Time | View | Input roles | Prompt summary | Result | Failure code |
|---|---|---|---|---|---|
| | front | source card | | accepted / rejected | |
```

### 批次交付索引_Batch_Delivery_Index.md

两个及以上资产使用：

```markdown
# [批次中文名] - 批次交付索引

| 序号 | Identity ID | 资产 | 视图集 | 运行目录 | 联系表 | 当前状态 | 下一步 |
|---:|---|---|---|---|---|---|---|
| 1 | | | | | | INTAKE | |
```

目标 Studs、失败代码等字段只有批次确实需要统一管理时再增加，不预先堆满空列。

## 脚本自动生成

以下文件不得手工伪造：

- `归一化报告_NORMALIZATION_REPORT.md`
- `待审核清单_STAGED_MANIFEST.json`
- `复制审计_COPY_AUDIT.md`
- `人工审核记录_HUMAN_APPROVAL.md`

## v1.2 兼容

旧运行目录仍可继续使用下面三份详细文档：

- `资产简报_ASSET_BRIEF.md`
- `物品一致性锁_IDENTITY_LOCK.md`
- `结构与深度锁_STRUCTURE_AND_DEPTH_LOCK.md`

Finalize 脚本接受“v1.3 单份资产锁”或“完整 v1.2 三份锁”，不会要求两套同时存在。
