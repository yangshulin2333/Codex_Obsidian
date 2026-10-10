---
type: concept
domain: ai-programming-product
status: summarized
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# ComfyUI 节点工作流入门

## 一句话说明

ComfyUI 是一个基于节点的本地 AI 图像工作流界面，它把模型、提示词、采样器、VAE、图片输入输出拆成可视化流程，适合理解、复现和维护生成系统。

## 基础文生图流程

```text
Load Checkpoint
-> CLIP Text Encode 正向提示词
-> CLIP Text Encode 反向提示词
-> Empty Latent Image
-> KSampler
-> VAE Decode
-> Save Image
```

## 核心概念

| 概念 | 含义 |
|---|---|
| Node | 一个功能块，例如加载模型、编码提示词、采样 |
| Workflow | 多个节点连接成完整处理链 |
| Latent | 模型内部处理的压缩表示 |
| VAE | 像素图和 latent 之间的翻译器 |
| KSampler | 从噪声逐步去噪，生成符合提示词的 latent |
| Seed | 初始噪声编号，相同设置可复现结果 |

## 常调参数

| 参数 | 作用 |
|---|---|
| Seed | 控制可复现性 |
| Steps | 去噪步数 |
| CFG | 提示词约束强度 |
| Sampler | 每一步怎么去噪 |
| Scheduler | 噪声随时间怎么下降 |
| Denoise | 图生图保留原图结构的程度 |

## 图生图流程

```text
Load Image
-> VAE Encode
-> KSampler
-> VAE Decode
-> Save Image
```

`Denoise` 是图生图的核心：

- `0.1-0.4`：轻微修改，保留原结构。
- `0.5-0.7`：明显风格变化。
- `0.8-1.0`：大幅重绘。

## LoRA 和 ControlNet

LoRA 用来附加风格、角色、服装或特定概念。

ControlNet 用来控制结构，例如姿势、边缘、深度、构图。

使用原则：

- LoRA 要匹配模型体系。
- LoRA 强度从 `0.7-0.9` 起步。
- ControlNet strength 从 `0.6-0.9` 起步。
- 一次只改一个变量，才能知道变化来自哪里。

## 学习路径

1. 先搭基础文生图工作流。
2. 理解 seed、steps、CFG、sampler、scheduler。
3. 学图生图和 denoise。
4. 加一个 LoRA。
5. 加一个 ControlNet。
6. 用 subgraph 整理常用模块。
7. 保存 golden workflow。
8. 学会拖 PNG 回 ComfyUI 复现工作流。

## 来源

- `20_Areas 领域/AI/ComfyUI/从零理解 ComfyUI.md`

## 相关链接

- [[Codex 工具能力与使用边界]]
- [[AI 工具卡模板]]
- [[ToyBox 资产需求与风格规范]]
