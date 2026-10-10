---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-04
updated: 2026-08-04
---

# 当前状态

## 当前入口

`README.md`

## 当前版本

`v1.1 - 2026-08-04`

## 已完成

- 建立魔法剑专用、但不写死项目内容的独立工作流。
- 默认输出 8 张图：front、back、left、right、top、bottom、left45、right45。
- 明确 X、Y、Z 三轴和每张图的投影平面。
- 将 top/bottom 定义为沿 Y 轴观察的 X×Z 端视图。
- 加入端视图 60%-80% 画布占比和 X/Z 等比放大规则。
- 加入 45 度整剑刚体旋转门禁。
- 加入设计锁、Prompt、自检和自动文件验收。
- 完成文件契约验证，并通过批量结果复盘发现轴向语义验收缺口。
- 禁止跨资产复用 top/bottom 作为布局参考。
- 禁止拿失败候选图继续修相机或表面归属。
- top 与 bottom 改为从同一资产纯净来源独立生成。
- 加入两次 AI 轴向尝试上限、`AXIAL_BLOCKED` 和 Six / proxy 降级分支。
- 新增 `view_review.json` 人工确认记录与通用 `Validate-ViewSet.ps1`。
- 保留 `Validate-8ViewSet.ps1` 作为旧命令兼容入口。

## 当前边界

- 本目录只负责效果图到 8 视图参考图。
- Blender 清理、纹理修复、Roblox 打包继续由相邻武器工作流维护。
- 不在本目录保存具体批次图片和绝对输出路径。

## 已知风险

- 生成模型仍可能把多层护手融合成一块。
- 正面高凸宝石可能被平台夸大厚度。
- 复杂非对称剑不能使用镜像捷径。
- 平台若不支持轴向端视图，应减少输入视图，不能用错误 top/bottom 替代。
- 图像生成器没有真实持久相机；即使 Prompt 正确，轴向候选仍可能变成独立横向装饰物。
- 自动脚本只能核验人工确认记录是否完整，不能自行判断图中相机与表面归属。

## 已关闭的流程缺口

- `AXIAL_CROSS_ASSET_REFERENCE`：上一资产 top 被下一资产当作布局模板，造成轮廓语法累积漂移。
- `AXIAL_FAILED_CANDIDATE_REFERENCE`：失败 top 被继续 edit，错误导轨和中央结构被锚定。
- `AXIAL_BOTTOM_INHERITS_TOP`：bottom 直接引用错误 top，导致成对传播。
- `CONTACT_SHEET_FALSE_PASS`：只看缩略联系表，检查了薄度和占比，却没有检查正面专属表面是否泄漏。

## 下一次更新触发条件

- 新的 3D 模型暴露可重复的输入图错误。
- 混元或 Tripo 调整多视图槽位语义。
- 新增非对称剑、弯刀或双头剑等特殊剑类。
- 自动验收需要增加图像相似度或背景检测。
