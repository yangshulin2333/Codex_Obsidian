---
type: resource
created: 2026-05-18
status: inbox
---

### 一、 界面导航与基础操作 (视图控制)

在 Blender 中，熟练使用鼠标和快捷键组合是高效建模的基础。

- **缩放视图**：滚动鼠标中轮。
    
- **旋转视图**：按住鼠标中轮并拖动。
    
- **平移视图**：按住 `Shift` + 鼠标中轮拖动。
    
- **正交视角切换 (数字小键盘)**：
    
    - `1`：前视图 (Front)
        
    - `3`：右视图 (Right)
        
    - `7`：顶视图 (Top)
        
    - `9`：底视图 (Bottom)
        
- **无小键盘替代方案**：按住 `Alt` + 鼠标中轮拖动，可自动吸附至最近的视角。
    

### 二、 核心模式与选择技巧

Blender 分为多种模式，新手只需关注以下两种：

1. **物体模式 (Object Mode)**：处理物体的整体，如移动、旋转或缩放整个模型。快捷键 `Tab` 可快速切换至编辑模式。
    
2. **编辑模式 (Edit Mode)**：对物体的具体几何结构进行修改。
    
    - **顶点 (Vertices)**：点的操作。
        
    - **边 (Lines/Edges)**：线的操作。
        
    - **面 (Faces)**：面的操作。
        

- **全选**：在编辑模式下按 `A` 键选中所有几何体。
    

### 三、 建模基础快捷键 (核心动作)

掌握这几个快捷键组合，就能完成大部分基础建模任务：

- **G (Grab/Move)**：移动物体或元素。
    
- **S (Scale)**：缩放大小。
    
- **R (Rotate)**：旋转。配合轴向键（如 `R` + `Y`）可锁定在特定轴向旋转。
    
- **E (Extrude)**：挤出。最常用的建模手段，可从现有面挤出新的几何体。
    
- **Ctrl + R (Loop Cut)**：环切。为模型添加新的循环边，增加细节。
    
- **Ctrl + B (Bevel)**：倒角。使锋利的边缘变圆滑，滚动鼠标中轮可增加细分段数。
    

### 四、 添加与编辑物体

- **添加物体**：按下 `Shift + A` 呼出菜单，常用的是“网格 (Mesh)”子菜单下的立方体、球体、圆柱体等。
    
- **低多边形设置 (Low Poly)**：添加圆柱体等物体时，可在左下角设置窗口减少“顶点 (Vertices)”数（例如设为 8），以适应移动端游戏或低模风格。
    
- **删除物体**：选中物体后按 `Delete` 或 `X`。
    
- **平滑着色**：右键点击物体选择 `Shade Smooth` 或 `Shade Smooth Auto Smooth`，可以让模型看起来更圆润而无需增加大量面数。
    

### 五、 实战练习：快速制作一颗松树

1. **树干**：`Shift + A` 添加圆柱体 (Cylinder)，进入编辑模式缩放并拉长。
    
2. **树冠**：`Shift + A` 添加一个圆 (Circle) 或圆锥，使用 `E` (挤出) 并配合 `S` (缩放) 做出漏斗状。
    
3. **组合**：使用 `Shift + D` 复制树冠层，通过 `G` (移动) 和 `R` (旋转) 进行堆叠，快速形成一颗松树模型。
    

### 小贴士

- **撤销**：习惯使用 `Ctrl + Z` 返回上一步。
    
- **轴向锁定**：在执行移动、缩放、旋转时，紧接着按 `X`、`Y` 或 `Z` 键，可以精准控制变换方向。


---


这是一份基于 Blender Guru 官方快捷键指南（Blender Shortcuts）翻译并整理的 **Blender 常用快捷键中文速查表**。内容已采用易于阅读的 Markdown 表格格式进行排版，涵盖了从基础操作、视图导航到建模和渲染的核心快捷键。

# 🍩 Blender 核心快捷键速查表 (中英对照)

## 🌍 通用与选择 (General Selection)

| 操作 | 英文 | 快捷键 |
| --- | --- | --- |
| **选择** | Select | `鼠标左键 (LMB)` |
| **全选** | Select All | `A` |
| **取消全选** | Deselect All | `Alt` + `A` |
| **框选** | Marquee Box Select | `B` |
| **刷选 / 圈选** | Circle Select | `C` |
| **套索选择** | Lasso Select | `Ctrl` + `鼠标右键拖拽` |
| **反选** | Invert Selection | `Ctrl` + `I` |
| **选择相连元素** | Select Linked | `Shift` + `L` |
| **选择相似元素** | Select Similar | `Shift` + `G` |

## 👁️ 视图导航 (Navigation - 3D Viewport)

| 操作 | 英文 | 快捷键 |
| --- | --- | --- |
| **旋转视图 (环视)** | Orbit | `鼠标中键拖拽 (MMB)` |
| **平移视图** | Pan | `Shift` + `鼠标中键拖拽` |
| **缩放视图** | Zoom In/Out | `鼠标滚轮` 或 `Ctrl` + `鼠标中键` |
| **飞行模式** | Fly / Walk Navigation | `Shift` + `~` (波浪号) |
## 🎥 视图控制 (View - 3D Viewport)

| 操作 | 英文 | 快捷键 |
| --- | --- | --- |
| **切换视角 (前/侧/顶)** | Numpad Views | 小键盘 `1`(前), `3`(侧), `7`(顶) |
| **摄像机视角** | Camera View | 小键盘 `0` |
| **切换 透视/正交 视图** | Perspective / Orthographic | 小键盘 `5` |
| **聚焦选中物体** | View Selected | 小键盘 `.` (句号) |
| **局部视图 (孤立显示)** | Local View (Isolate) | `/` (小键盘斜杠) |
## 🧊 物体模式基础变换 (Object Mode)

| 操作 | 英文 | 快捷键 |
| --- | --- | --- |
| **移动 / 抓取** | Move / Grab | `G` |
| **缩放** | Scale | `S` |
| **旋转** | Rotate | `R` |
| **清除位置** | Clear Location | `Alt` + `G` |
| **清除旋转** | Clear Rotation | `Alt` + `R` |
| **清除缩放** | Clear Scale | `Alt` + `S` |
| **应用变换** | Apply Transform | `Ctrl` + `A` |
| **复制物体** | Duplicate | `Shift` + `D` |
| **关联复制** | Duplicate Linked | `Alt` + `D` |
| **删除** | Delete | `X` 或 `Delete` |
| **隐藏选中项** | Hide | `H` |
| **隐藏未选中项** | Hide Unselected | `Shift` + `H` |
| **取消隐藏** | Unhide All | `Alt` + `H` |
| **添加新物体** | Add Object | `Shift` + `A` |
| **调出搜索菜单** | Search | `F3` |
## 🛠️ 建模 (Modelling - Edit Mode)

| 操作 | 英文 | 快捷键 |
| --- | --- | --- |
| **切换 顶点/边/面 模式** | Vertex/Edge/Face Select | 数字键 `1`, `2`, `3` |
| **挤出** | Extrude | `E` |
| **内插面** | Inset | `I` |
| **倒角** | Bevel | `Ctrl` + `B` |
| **顶点倒角** | Bevel Vertices | `Ctrl` + `Shift` + `B` |
| **环切** | Loop Cut | `Ctrl` + `R` |
| **顶点/边 滑移** | Vertex/Edge Slide | 连按两次 `G` |
| **切刀工具** | Knife | `K` |
| **填充面** | Fill Face | `F` |
| **合并顶点** | Merge | `M` |
| **重新计算法线(朝外)** | Recalculate Normals | `Shift` + `N` |
| **翻转法线** | Flip Normals | `Ctrl` + `Shift` + `N` |
| **开启/关闭衰减编辑** | Proportional Editing | `O` |
| **标记接缝 (UV展开用)** | Mark Seam | 呼出菜单 `Ctrl` + `E` |

## 🎨 材质与着色 (Shading)

| 操作 | 英文 | 快捷键 |
| --- | --- | --- |
| **着色方式饼形菜单** | Shading Pie Menu | `Z` |
| **开启/关闭透视模式** | Toggle X-Ray | `Alt` + `Z` |

## 🎬 渲染 (Rendering)

| 操作 | 英文 | 快捷键 |
| --- | --- | --- |
| **渲染当前帧图像** | Render Image | `F12` |
| **渲染动画** | Render Animation | `Ctrl` + `F12` |
| **查看渲染结果窗口** | View Render | `F11` |

## 🔌 节点操作 (Nodes - Materials)

| 操作 | 英文 | 快捷键 |
| --- | --- | --- |
| **切断连接线** | Cut Connection | `Ctrl` + `鼠标右键划过连线` |
| **禁用选中节点** | Mute Selected | `M` |
