
资料依据：YouTube 元数据、可访问字幕页、作者 Reddit 章节列表、课程学习指南。字幕页显示视频有 50,614 词、7,049 段英文转写，但网页只开放了前段内容。

**核心定位**
ComfyUI 是一个基于节点的本地 AI 工作流界面。它不是单纯的“画图软件”，而是把模型、提示词、采样器、VAE、图片输入输出等步骤拆成可视化节点，让你能看到 AI 图像生成的完整流程。

它适合想真正理解生成流程的人：模型如何加载、提示词如何变成 conditioning、噪声如何被 KSampler 去噪、latent 如何通过 VAE Decode 变成图像。

**1. ComfyUI 的基本概念**
- **Node 节点**：一个功能块，例如加载模型、编码提示词、采样、解码、保存图片。
- **Workflow 工作流**：多个节点连接成的一条完整处理链。
- **数据流方向**：通常从左到右，模型、文本、latent、图像逐步流动。
- **优势**：透明、可复现、可拆解、可调试，比黑盒式界面更适合学习和专业流程。

一个最基础的文生图流程是：

```text
Load Checkpoint
→ CLIP Text Encode 正向提示词
→ CLIP Text Encode 反向提示词
→ Empty Latent Image
→ KSampler
→ VAE Decode
→ Save Image
```

**2. 安装与硬件**
视频推荐 Windows + NVIDIA 显卡，课程基于便携版 ComfyUI / Easy Install 展示。便携版的好处是 Python、依赖、模型、设置都在一个文件夹里，便于移动、备份和删除，也不容易污染系统 Python。

硬件重点是 VRAM：
- 6-8GB 显存：能跑基础 SD1.5、小模型、部分 FP8 工作流。
- 12-24GB 显存：更适合 SDXL、Flux、Z-Image、ControlNet、多分辨率工作流。
- NVIDIA CUDA 支持最好；AMD 和 Mac 可以用，但兼容性和速度可能不同。

**3. 界面操作**
常用界面元素：
- Canvas：搭建节点的画布。
- 双击画布：搜索并添加节点。
- 右键菜单：按分类添加节点。
- Manager：安装、更新、修复缺失 custom nodes。
- Console：看运行日志、报错、下载进度。
- Tabs / Minimap / Fit View：管理大型工作流。

常用操作：
- 拖拽端口连接节点。
- 节点标题可重命名，便于整理。
- 可以折叠、复制、删除、旁路、静音节点。
- Reroute 节点用于整理连线，避免工作流混乱。

**4. Diffusion 图像生成原理**
视频强调：AI 不是直接“画”图，而是在 latent space 里从噪声逐步去噪，最终得到符合提示词的图像。

关键参数：
- **Seed**：初始噪声编号。相同 seed + 相同设置 = 可复现结果。
- **Steps**：去噪步数。更多步数通常更细，但超过一定值收益下降。
- **CFG**：提示词约束强度。太低会发散，太高可能僵硬或出伪影。
- **Sampler**：每一步怎么去噪，例如 Euler a、DPM++ 2M。
- **Scheduler**：噪声随时间如何下降，例如 Karras、Linear。
- **Denoise**：图生图时控制保留原图多少。低值更保守，高值变化更大。

**5. VAE 与 Latent**
VAE 是像素图和 latent 表示之间的翻译器：
- **VAE Encode**：图片 → latent，用于图生图。
- **VAE Decode**：latent → 图片，用于最终输出。
- 如果图像发灰、过饱和或颜色奇怪，可以检查 VAE 是否与模型匹配。

**6. 提示词系统**
ComfyUI 通常用两个 CLIP Text Encode：
- **Positive Prompt**：想要什么。
- **Negative Prompt**：不想要什么，比如 blurry、low quality、watermark、extra fingers。

提示词不是直接生成图，而是引导 KSampler 去噪。更好的写法是明确主体、风格、构图、光线、材质，而不是堆砌大量形容词。

**7. 图生图**
图生图流程把 `Empty Latent Image` 换成：

```text
Load Image
→ VAE Encode
→ KSampler
→ VAE Decode
→ Save Image
```

核心是 denoise：
- 0.1-0.4：轻微修改，保留原结构。
- 0.5-0.7：明显风格变化。
- 0.8-1.0：大幅重绘，只保留少量结构。

**8. LoRA**
LoRA 用来给基础模型附加风格、角色、服装、画风或特定概念。

基本接法：
```text
Load Checkpoint
→ Load LoRA
→ KSampler
```

注意点：
- LoRA 通常有 trigger words，需要写进正向提示词。
- 强度建议从 0.7-0.9 开始。
- 太强会压过基础模型，导致画面单一或过拟合。
- SD1.5、SDXL、Flux 等模型体系的 LoRA 不要混用。

**9. ControlNet**
ControlNet 用于结构控制，例如姿势、边缘、深度、构图。

常见类型：
- OpenPose：控制人物姿势。
- Canny：控制边缘轮廓。
- Depth：控制空间深度。
- Lineart / Scribble：从线稿生成图像。

基本流程：
```text
参考图
→ 预处理器
→ Load ControlNet
→ Apply ControlNet
→ KSampler conditioning
```

参数建议：
- strength：0.6-0.9 起步。
- start_percent：通常 0。
- end_percent：可设 0.7 左右，让后期采样恢复一些自由度。

**10. Subgraph**
Subgraph 是把一组节点封装成可复用模块。适合封装：
- 正负提示词块。
- ControlNet 块。
- LoRA 块。
- Upscale 块。
- 常用保存/预览逻辑。

原则：只暴露经常调的参数，隐藏稳定不变的内部结构，降低复杂度。

**11. 模型与格式**
视频提到不同模型格式适合不同硬件：
- **FP16**：质量和性能平衡好，适合显存较充足的 GPU。
- **FP8**：更省显存，适合低显存或更快实验。
- **GGUF**：适合显存压力大或特殊运行场景。
- **AIO 模型**：组件打包更简单。
- **Modular 模型**：可单独替换 VAE、text encoder 等，更灵活。

建议少囤模型，多熟悉几个稳定模型。

**12. 批量生成与实验方法**
有效学习方式是一次只改一个变量：
- 固定 seed，测试 CFG。
- 固定 prompt，测试 sampler。
- 固定模型，测试 LoRA 强度。
- 固定结构，测试 ControlNet strength。

这样才能知道哪个参数真正影响了结果。

**13. 工作流保存与复现**
ComfyUI 的强项是可复现：
- 工作流可以保存成 JSON。
- 生成出的 PNG 通常嵌入 workflow 元数据。
- 把生成图片拖回 ComfyUI，可以还原当时的节点和参数。
- 建议保存“golden workflow”，作为以后项目模板。

**14. 目录管理**
模型必须放在正确目录，否则节点下拉框找不到：
- checkpoints：基础模型。
- loras：LoRA。
- controlnet：ControlNet 模型。
- vae：VAE。
- input：输入图片。
- output：生成结果。
- custom_nodes：自定义节点。

更新前建议备份整个便携版文件夹，尤其是 custom nodes 和 models 目录。

**15. 常见报错处理**
- 红色节点：缺少 custom node，用 Manager 安装缺失节点。
- 模型下拉框为空：模型放错目录，或需要刷新。
- 显存不足：降低分辨率、换 FP8/GGUF、减少 ControlNet、关闭其他占 GPU 的程序。
- 输出不符合提示词：检查 CFG、prompt、模型类型、LoRA 是否匹配。
- 图像质量怪：检查 VAE、采样器、steps、分辨率是否合理。

**推荐学习路径**
1. 先搭出基础文生图工作流。
2. 理解 seed、steps、CFG、sampler、scheduler。
3. 学图生图和 denoise。
4. 加一个 LoRA，理解 trigger words 和 strength。
5. 加一个 ControlNet，控制姿势或结构。
6. 用 subgraph 整理常用模块。
7. 学会保存、导入、拖 PNG 复现工作流。
8. 最后再研究 FP8、GGUF、Z-Image、API nodes 等进阶内容。

**一句话总结**
这个视频的核心不是教你“点哪个按钮出图”，而是建立 ComfyUI 的底层心智模型：图像生成是一条可视化、可拆解、可复现的节点流水线。掌握基础节点、KSampler、VAE、提示词、LoRA、ControlNet 和目录管理后，你就能从复制别人的 workflow，转向自己搭建、调试和维护稳定的生成系统。

参考来源：
- [YouTube 视频元数据](https://www.youtube.com/watch?v=HkoRkNLWQzY&t=380s)
- [YouTubeTranscript.dev 字幕页](https://www.youtubetranscript.dev/sv/transcript/HkoRkNLWQzY/comfyui-course-learn-comfyui-from-scratch-full-5-hour-course-ep01)
- [作者 Reddit 章节列表](https://www.reddit.com/r/comfyui/comments/1qdngdu/comfyui_course_learn_comfyui_from_scratch_full_5/)
- [Complete AI Training 学习指南](https://completeaitraining.com/course/comfyui-course-stable-diffusion-lora-and-controlnet-from-scratch-video-course/)