---
type: checklist
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-04
updated: 2026-08-12
---

# 魔法剑 8 视图自检清单

## 使用方式

1. 在生成任何 `left/right/left45/right45` 前，检查 Codex 是否主动询问并复述四个输出的 must-visible、must-hidden、方向性结构数量/位置与遮挡，且用户已逐输出确认。
2. 先检查每张候选图的参考来源，确认没有跨资产端视图和失败稿。
3. 再检查联系表。
4. 把 front、left、right、top、bottom 五张单图以全分辨率打开，检查表面归属和逐输出合同。
5. 逐张检查其余视图。
6. 填写 `view_review.json`，再运行 `Validate-ViewSet.ps1`。
7. 任何一票否决项命中时，只处理对应视图；相机或表面归属错误必须丢弃重生，不能编辑失败稿。
8. 通过后才复制到 `00_final_image_to_3d_upload/`。

## 一票否决项

- [ ] `EIGHT_VIEW_MISSING`：不是恰好 8 张正式 PNG。
- [ ] `DESIGN_IDENTITY_DRIFT`：某张图明显像另一把剑。
- [ ] `OPPOSITE_SURFACES_VISIBLE`：同一图同时大面积显示相反表面。
- [ ] `PERSPECTIVE_TOO_STRONG`：正交图出现明显透视汇聚、广角或斜相机。
- [ ] `SIDE_VISIBILITY_CONTRACT_MISSING`：生成侧视或 45 度图前，没有四份经用户确认的逐输出可见性合同。
- [ ] `SIDE_VISIBILITY_CONTRACT_BROKEN`：候选图违反对应输出的 must-visible、must-hidden、方向性结构数量/位置或遮挡合同。
- [ ] `UNCONFIRMED_SIDE_MIRROR`：没有用户明确授权记录，却镜像或复用了另一侧输出的几何。
- [ ] `SIDE_NOT_90_DEG`：侧视图仍看到宽正面剑身或展开护手。
- [ ] `TOP_VIEW_OFF_AXIS`：top 不是从剑尖沿 Y 轴观察。
- [ ] `BOTTOM_VIEW_OFF_AXIS`：bottom 不是从剑首沿 Y 轴观察。
- [ ] `AXIAL_FRONT_FACE_LEAK`：端视图出现完整正面宝石、装甲或翼板。
- [ ] `AXIAL_FULL_LENGTH_VISIBLE`：top/bottom 显示完整剑长。
- [ ] `AXIAL_TOO_SMALL`：端视图在平台缩略图中近似空白。
- [ ] `AXIAL_NONUNIFORM_SCALE`：端视图单独拉宽 X 或拉厚 Z。
- [ ] `AXIAL_CROSS_ASSET_REFERENCE`：top/bottom 引用了其他资产的端视图。
- [ ] `AXIAL_FAILED_CANDIDATE_REFERENCE`：重试或修复继续引用了失败候选图。
- [ ] `AXIAL_INHERITED_LAYOUT`：端视图继承了另一资产或失败稿的导轨、中央插座、纹章或轮廓语法。
- [ ] `AXIAL_SURFACE_OWNERSHIP_CONFLICT`：正面专属 P-ID 在端视图中仍以完整正面出现。
- [ ] `AXIAL_PAIR_CONFLICT`：top 与 bottom 的 X/Z、中央层级或零件数量互相矛盾。
- [ ] `ANGLE45_PARTIAL_ROTATION`：45 度图只旋转剑身或部分组件。
- [ ] `FLOATING_PART`：晶体、翼板、冠部或剑首零件漂浮。
- [ ] `COMPONENT_COUNT_DRIFT`：关键零件数量跨视图变化。
- [ ] `GLUED_ON_DECORATION`：高凸装饰只有正面贴片，没有厚度或托座。
- [ ] `BACKGROUND_CONTAMINATION`：人物、手、地面、场景、文字、粒子或大光效出现。

## 全局一致性

- [ ] 8 张图属于同一把剑。
- [ ] 总长、护手位置、握柄长度和剑首位置一致。
- [ ] 主色、辅色、核心色和主体材质一致。
- [ ] P-ID 数量与 `design_lock.md` 一致。
- [ ] L2/L3 零件通过 L1 连到 L0。
- [ ] 所有图都完整显示对象且不裁切。
- [ ] 背景为统一纯白或浅灰。
- [ ] 画布尺寸一致且为正方形。
- [ ] 没有横向或纵向单轴拉伸。

## front.png

- [ ] 严格从 +Z 看向 -Z。
- [ ] 剑尖向上，完整居中。
- [ ] 正面轮廓清楚。
- [ ] 背面完全隐藏。
- [ ] 侧面只形成极窄边线。
- [ ] 护手和宝石没有漂浮。

## back.png

- [ ] 严格从 -Z 看向 +Z。
- [ ] X×Y 外轮廓与 front 一致。
- [ ] 背面结构是可信的封闭后壳。
- [ ] 没有复制完整高凸正面核心。
- [ ] 没有变成另一把剑。

## left.png / right.png

- [ ] 严格 90 度 Z×Y 工程侧视。
- [ ] `left.png` 与 `right.png` 各有独立、已确认的 must-visible / must-hidden 合同。
- [ ] 两张图的方向性结构数量、位置、朝向和遮挡分别符合自己的合同。
- [ ] 剑刃只显示真实厚度与刃口楔形。
- [ ] 护手只显示前后深度，不显示正面展开宽度。
- [ ] 宝石和托座都收成侧面厚度。
- [ ] 握柄、环带和剑首与剑身使用同一相机方向。
- [ ] 没有根据外观或“对称性”自行镜像；如使用镜像/几何复用，设计锁内存在用户授权原文和指定输出对。

## top.png

- [ ] 参考图只来自当前资产的已通过 front、严格 side 或当前资产真实 3D 代理。
- [ ] 没有引用其他资产 top/bottom、当前资产 bottom 或任何失败候选图。
- [ ] 相机位于剑尖，从 +Y 看向 -Y。
- [ ] 只显示 X×Z 截面。
- [ ] 完整剑长不可见。
- [ ] 护手没有摊开成宽平面。
- [ ] 没有横向重复正面装甲。
- [ ] 正面宝石和晶体面没有翻到端面。
- [ ] 正面专属 P-ID 只显示窄边或完全隐藏。
- [ ] 护手的 X 位置、曲率和根部能由 front / side 解释，没有被替换成通用直导轨。
- [ ] 中央截面没有新增纹章、宝石面、圆环或插座正面。
- [ ] X/Z 同倍缩放。
- [ ] 主体长边约占画布 60%-80%。

## bottom.png

- [ ] 由当前资产纯净来源独立生成，没有把 top.png 当图像参考。
- [ ] 没有引用其他资产端视图或任何失败候选图。
- [ ] 相机位于剑首，从 -Y 看向 +Y。
- [ ] 只显示 X×Z 截面。
- [ ] 剑首端盖连续且左右对称。
- [ ] 正面剑首宝石没有完整翻到端面。
- [ ] 正面专属 P-ID 只显示窄边或完全隐藏。
- [ ] 没有新增未登记的晶体、尖刺或端盖。
- [ ] 与 top 使用相同 X:Z、零件 X 位置和层级数量，但不是复制 top 的像素结构。
- [ ] X/Z 同倍缩放。
- [ ] 主体长边约占画布 60%-80%。

## left45.png / right45.png

- [ ] 两张图各有独立、已确认的 must-visible / must-hidden、方向性结构数量/位置和遮挡合同。
- [ ] 整把剑绕 Y 轴旋转约 45 度。
- [ ] 剑身、护手、握柄、剑首、宝石和托座方向一致。
- [ ] 正面装饰产生一致的横向缩短。
- [ ] 只显示正面和一个近侧面。
- [ ] 背面与相反侧面没有翻出。
- [ ] 相机水平，无俯拍、仰拍和广角。
- [ ] 没有默认镜像；如复用几何，设计锁内存在用户对指定输出对的明确授权记录。

## 联系表检查

`orthographic_preview_contact_sheet.png`：

- [ ] 顺序为 front、back、left、right、top、bottom。
- [ ] 可以直接比较 X/Y/Z 比例。

`reference_preview_contact_sheet.png`：

- [ ] 顺序为 top、left45、front、right45、left、right、back、bottom。
- [ ] 一眼可看出 45 度整剑旋转。
- [ ] 一眼可看出端视图不是完整竖剑。
- [ ] 联系表没有重新裁切或改变单图倍率。

轴向联系表只能发现明显异常，不能完成最终通过。以下内容必须在单图全分辨率检查：

- [ ] front-only 宝石、纹章、翼板是否在 top/bottom 仍保持完整正面。
- [ ] side 中的 Z 厚度能否解释 top/bottom 的总厚度。
- [ ] top 和 bottom 的中央端面是否分别对应剑尖端与剑首端。
- [ ] 是否出现仅在缩略图中看似合理、放大后却是另一件横向道具的结构。

## 文件与确认记录契约

- [ ] `00_final_image_to_3d_upload/` 存在。
- [ ] `UPLOAD_VIEW_MODE=Eight` 时目录中恰好有 8 个文件。
- [ ] `UPLOAD_VIEW_MODE=Six` 时目录中恰好有 6 个文件，并且不包含 top/bottom。
- [ ] 文件名严格为：

```text
front.png
back.png
left.png
right.png
top.png
bottom.png
left45.png
right45.png
```

- [ ] 没有 Markdown、联系表、效果图、失败稿和子目录。
- [ ] 8 张图尺寸完全一致。
- [ ] 当前发布模式要求的全部图片都能被正常解码。
- [ ] 当前资产根目录存在有效的 `view_review.json`。
- [ ] Eight 模式的 `sameAssetSourcesOnly=true`。
- [ ] Eight 模式的 `crossAssetAxialReferenceUsed=false`。
- [ ] Eight 模式的 `failedCandidateUsedAsReference=false`。
- [ ] Eight 模式的 top/bottom、表面归属和成对一致性均由复核者明确通过。
- [ ] `same_asset_ai` 模式的 top/bottom 尝试次数各不超过 2。

## 常见失败与修正

| 失败现象 | 原因 | 修正 |
|---|---|---|
| 侧视 / 45 度图尚未生成但合同不完整 | Codex 未主动询问或用户尚未确认 | 记录 `SIDE_VISIBILITY_CONTRACT_MISSING`，停止生成；Codex 逐输出补问、复述并等待确认 |
| 单张侧向输出的结构显隐、数量、位置或遮挡错误 | 候选违反逐输出合同 | 记录 `SIDE_VISIBILITY_CONTRACT_BROKEN`，归档该候选并按合同从纯净来源单张重生 |
| 左右图被擅自镜像或共用结构 | 没有用户授权记录 | 记录 `UNCONFIRMED_SIDE_MIRROR` 并判废；独立生成，或先取得并记录指定输出对授权 |
| top 护手像横向翅膀 | 模型把 X×Y 正面当成 X×Z 截面 | 明确沿 Y 轴观察，只保留截面层 |
| top 横向重复装甲 | 生成器复制正面装饰填充横向轮廓 | 删除正面装甲，只保留金属边、刃厚和中心截面 |
| bottom 端盖形态与设计锁冲突 | 端盖生成漂移 | 按轴向 X×Z 表面归属锁重生成单张，不根据“对称性”自行补画 |
| top Z 厚度过大 | 把浮雕深度误认为剑身厚度 | 回到理论 Z 锁，降低端面层厚 |
| top/bottom 太小 | 理论同相机尺度导致缩略图不可读 | X/Z 等比放大到 60%-80%，记录倍数 |
| top 像上一把剑的横条结构 | 引用了其他资产 top 作为布局模板 | 候选直接判废；只用当前资产 front、side 和 design lock 重生 |
| 修正后仍保留错误导轨或纹章 | 把失败候选继续作为 edit 参考 | 停止编辑失败稿，从纯净来源独立重生 |
| bottom 复制了错误 top | bottom 把 top 当图像参考并继承其像素结构 | bottom 改为从同资产纯净来源独立生成，只共享数值锁 |
| 轴向连续两次失败 | 2D 证据不足或生成器无法稳定遵守轴向 | 标记 `AXIAL_BLOCKED`，转 3D 代理渲染或 Six 模式 |
| 45 度只有剑身转动 | Prompt 把剑身和护手当成不同对象 | 强制整剑刚体旋转；另一张仍按自己的已确认合同独立生成，除非有明确复用授权 |
| 侧视图仍像正面 | 生成器压扁正面冒充侧面 | 重做严格 Z×Y 90 度视图 |
| 单张尺寸不同 | 生成器输出尺寸漂移 | 等比缩放并居中到统一正方形画布 |

## 最终结论

```text
正交视图：通过 / 需修正
轴向端视图：通过 / 需修正
45 度视图：通过 / 需修正
结构连接：通过 / 需修正
文件契约：通过 / 需修正
参考来源隔离：通过 / 需修正
表面归属：通过 / 需修正
侧向可见性合同：通过 / 需修正
侧向几何复用授权：无 / 已记录 / 违规
是否适合继续用于 image-to-3D：是 / 否
残余风险：
```
