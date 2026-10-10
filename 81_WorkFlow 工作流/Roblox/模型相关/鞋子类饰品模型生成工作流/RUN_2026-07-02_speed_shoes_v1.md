---
type: workflow
domain: roblox
status: processing
owner: mixed
source: chatgpt
created: 2026-07-02
updated: 2026-07-02
---

# 2026-07-02 Speed Shoes v1 生成记录

## 目标

为 Roblox 跑酷 / 速度类游戏装备生成鞋子 2D 输入图。后续用于 Tripo / 混元 3D 生成，并最终拆成：

- `RightShoe` Accessory -> `RightFootAttachment`
- `LeftShoe` Accessory -> `LeftFootAttachment`

## 风格锚点

- `assets/style_anchor/speed_shoes_style_anchor_pair.png`

锚点特征：

- 白色大鞋头
- 橙黄色鞋面
- 青蓝色鞋舌和内衬
- 深灰色宽绑带
- 黑色边缘
- 白色厚鞋底
- 青蓝 / 橙色鞋底侧边装备块

## 本轮输出

- `assets/single_shoe_inputs/speed_shoes_v1/RightShoe_3Q.png`
- `assets/single_shoe_inputs/speed_shoes_v1/LeftShoe_3Q.png`

## 检查结论

| 项目 | RightShoe | LeftShoe |
|---|---|---|
| 只有一只鞋 | 通过 | 通过 |
| 背景干净 | 通过 | 通过 |
| 无角色 / 脚 / UI / 文字 | 通过 | 通过 |
| 鞋头清楚 | 通过 | 通过 |
| 鞋底清楚 | 通过 | 通过 |
| 鞋面清楚 | 通过 | 通过 |
| 绑带清楚 | 通过 | 通过 |
| 鞋口结构清楚 | 通过 | 通过 |
| 游戏装备感 | 通过 | 通过 |
| 低多边形友好 | 基本通过 | 基本通过 |

## 风险记录

- 鞋底侧边蓝橙块仍然偏多。若 Tripo / 混元生成碎面，下一版优先减少鞋底侧边小块，只保留 1-2 个大块面。
- 当前只有 3/4 单鞋图。如果 3D 后跟、内侧或鞋口结构不稳定，需要补正侧面、背面或顶部图。
- 左右鞋是分别生成，不是几何镜像。进入 Roblox 前要检查比例、鞋口高度和鞋底厚度是否一致。

## 下一步

1. 用户确认 `RightShoe_3Q.png` 和 `LeftShoe_3Q.png` 的效果。
2. 如果通过，将两张图投入 Tripo / 混元测试。
3. 如果 3D 模型结构不稳，再补单鞋侧视图和后视图。
4. 3D 结果进入 Blender / Studio 前，记录面数、贴图尺寸、附件命名和 Attachment 绑定结果。
