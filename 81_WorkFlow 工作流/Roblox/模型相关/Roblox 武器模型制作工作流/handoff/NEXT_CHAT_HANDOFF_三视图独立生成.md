# 新对话入口：Roblox 武器三视图独立生成

更新时间：2026-06-15

## 适用场景

用户提供武器截图，并要求：

```text
生成同系列改款三视图
用于 3D AI 模型生成
注意图片一致性
颜色和形状稍微变化
三视图分成三张
```

## 必须先读

```text
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\三视图生成_独立三张流程.md
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\Prompt_素材库.md
```

如果上一轮用户已经反馈“风格不对 / 风格变了 / 不像 / 失望”，还必须先读：

```text
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\三视图失败复盘_风格一致性.md
```

## 固定规则

默认直接生成三张独立视角图：

```text
*_front_view.png
*_side_view.png
*_back_view.png
```

不要默认只生成一张三视图合图再裁切。合图只作为可选人工检查图。

## 错误图隔离规则

用户如果指出“风格变了 / 太劣质 / 重新生成”，下一版不要继续盲目调用内置图像生成。正式交付优先走本地可控生成路线，例如 Blender 正交渲染、可控矢量绘制、Three.js 场景或已有模型固定视角截图。

如果内置图像生成出现过无关信息图、图表、人物、咖啡、税表、文字海报或任何非武器内容：

1. 立刻废弃该候选。
2. 不要复制到 `generated_views`。
3. 不要作为最终交付展示。
4. 在新版本目录使用 `_v2_`、`_v3_` 命名。
5. 在 `PROMPT.md` 记录实际 `generation_route`。

## 执行重点

1. 先写共用 `Design lock`，锁定武器类型、比例、结构、配色、装饰位置和允许变化范围。
2. 如果用户刚反馈风格问题，先只做一张正视图纠偏小样，不要直接完整交付三张。
3. 三张图复用同一段 `Design lock`。
4. 每次只改变视角要求：front / side / back。
5. 输出到：

```text
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\generated_views\武器名_日期_three_views
```

6. 最终回复给三张图的可点击链接。
7. 更新：

```text
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\工作记录.md
```

## 风格纠偏底线

“同系列改款”不是重新设计。第一优先级是保留参考截图的 Roblox 视口感、低模游戏资产感、材质语言、比例和装饰密度。颜色和形状只能轻微变化；如果不像原图同系列，就不要交付。

## 和 Roblox 导入打包的边界

如果用户给的是 FBX / GLB / Meshy 下载目录，并说“生成可直接导入 roblox 版本”，不要走本流程。改走：

```text
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\handoff\NEXT_CHAT_HANDOFF_模型下载直接打包.md
```
