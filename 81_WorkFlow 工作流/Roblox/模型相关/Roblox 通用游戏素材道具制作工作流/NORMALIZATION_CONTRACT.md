---
type: workflow
domain: roblox
status: active
owner: mixed
source: codex
created: 2026-07-14
updated: 2026-07-14
---

# 主体归一化与比例合同

## 一句话说明

归一化只能统一同一道具跨视图的整体尺度、位置和画布，不能修复或掩盖组件、轮廓、深度和相机角度错误。

## 三层比例

| 层级 | 含义 | 当前责任方 | 通过证据 |
|---|---|---|---|
| 画布归一化 | PNG 的宽高、背景和文件格式一致 | 本地脚本 | `CanvasWidth × CanvasHeight` |
| 主体归一化 | 同一道具在水平转台视图中使用统一 pixels-per-unit、主轴占比和接地线 | 本地脚本 + 人工 | `归一化报告_NORMALIZATION_REPORT.md` + contact sheet |
| Roblox 尺度 | 导入后目标包围盒、Pivot、Forward、Up 和握持 / 落地位置 | 项目需求 + Studio 验证 | `X / Y / Z studs` + Studio 截图或检查记录 |

画布相同不代表主体比例相同；主体比例相同也不代表 Roblox 游戏内尺寸正确。

## 自动归一化前提

接受自动主体归一化的图片必须满足：

- 单一均匀背景，推荐 `#D7D7D7`。
- 无地面线、渐变、投影、烟雾、辉光和粒子。
- 主体四周有明确留白，不触碰画布边缘。
- 同一水平转台组使用相同朝向规则；`top / bottom` 不混入该组。
- 组件数量、轮廓比例和锚点已先通过身份锁检查。

若 ImageMagick 无法把主体从背景可靠分离，脚本返回 `SUBJECT_BOUNDS_UNRELIABLE`。禁止为了让脚本通过而提高模糊阈值到会吞掉浅色组件的程度。

## v1.3 配置

每个新运行必须在 `_文档_Docs/归一化配置_NORMALIZATION_CONFIG.json` 写入：

```json
{
  "version": "1.3",
  "profile": "grounded-yaw",
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

### Profile

| Profile | 适用对象 | 对齐方式 |
|---|---|---|
| `grounded-yaw` | 宝箱、木桶、祭坛、落地机器、地面机关 | 主轴统一，底部对齐 `groundDatumPercent` |
| `centered-yaw` | 剑、法杖、盾牌、头盔、药水瓶等居中展示道具 | 主轴统一，画布中心对齐 |
| `measure-only` | 背景或结构暂不适合自动处理的视图 | 只测量和报告，不宣称完成主体归一化 |

### 建议初值

- `scaleTolerancePercent = 5`：小于等于该值视为正常生成波动。
- `maxAutoScalePercent = 12`：只允许在该上限内做整体等比修正。
- 超过 `12%`：返回 `SUBJECT_SCALE_DRIFT`，重新生成或人工判断，不能靠后期缩放隐藏。
- `groundDatumPercent = 90`：落地道具的底部对齐到画布高度 90% 位置。

这些是建议初值，不是所有资产的美术硬标准。细长武器、扁平饰物或特殊画布可以在运行配置里调整，并在联系表中人工复核。

## 不得被归一化掩盖的问题

- 组件数量不同。
- 同一组件宽高比或深度改变。
- 锚点、连接关系或前后顺序改变。
- 90° 侧视变成 3/4 视图。
- 45° 视图带额外俯仰或透视。
- 隐藏结构由模型擅自发明。
- 材质分区、符号朝向或非对称绕向改变。

上述问题必须返回对应失败代码，只修失败视图。

## 状态和交接

```text
ACCEPTED_VIEWS_READY
  -> NORMALIZATION_PREFLIGHT
  -> FILES_READY
  -> CONTACT_SHEET_APPROVED
  -> 3D_RESULT_REVIEWED
  -> DELIVERED
```

- `FILES_READY`：机械处理通过，结果只在待审核目录。
- `FILES_READY` 同时生成 SHA-256 待审核清单；审批前文件发生任何变化都会阻断发布。
- `CONTACT_SHEET_APPROVED`：人工确认身份、比例、相机和材质，正式上传目录已生成。
- `3D_RESULT_REVIEWED`：混元 3D / TripoAI 的实际结果已检查。
- `DELIVERED`：批次索引、目录回显和证据完整。

## 假设与边界

- 当前主体测量依赖均匀背景和 ImageMagick `trim`，不等于通用语义分割。
- 自动缩放只验证整体主轴占比，不能证明局部几何正确。
- 顶 / 底视图的轴向比例需要独立配置，v1.3 默认保留人工复核。
- Roblox Studs 尺度不会从参考图自动推断，必须由项目需求确认。

## 相关文件

- [[README]]
- [[CHECKLIST]]
- [[RUN_TEMPLATES]]
- [[FAILURE_CODES]]
- [[RPG_BATCH_PROFILE]]
