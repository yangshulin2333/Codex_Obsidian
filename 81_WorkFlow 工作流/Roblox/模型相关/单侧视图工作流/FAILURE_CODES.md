---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-17
updated: 2026-08-17
---

# 单侧视图失败码与恢复表

## 记录规则

1. 每个失败候选只记录一个**主失败码**。
2. 先修最上游错误：输入 > 相机 > 几何分类 > 可见性 > 锚点 > 风格 > 背景。
3. 只重做当前侧，不回滚已确认设计锁和其他正式视图。
4. 同一主失败码连续出现两次，停止盲目生图，回到合同或补结构证据。

## 启动与上下文

| 失败码 | 表现 | 恢复 |
|---|---|---|
| `SIDE_TARGET_NOT_DEFINED` | 不知道要生成 left、right 还是语义侧 | 明确一个目标文件和观察方向 |
| `SIDE_DESIGN_LOCK_MISSING` | 没有已确认设计锁 | 先确认当前正视图或明确唯一主参考 |
| `SIDE_REFERENCE_ROLE_AMBIGUOUS` | 不知道哪张是设计锁、证据图或编辑目标 | 为每张输入按 Image 1–5 标注角色 |
| `SIDE_CONTEXT_OVERLOAD` | 加载过多候选导致身份漂移或调用失败 | 只保留当前设计锁、必要结构证据和目标候选 |
| `OLD_ASSET_CONTEXT_POLLUTION` | 新资产混入旧武器 / 旧道具特征 | 开新上下文，只读取当前运行状态和设计锁 |
| `DUPLICATE_SIDE_TASK_ACTIVE` | 同一目标出现两个活动生成任务 | 等待或恢复原任务，取消重复提交 |

## 相机与姿态

| 失败码 | 表现 | 恢复 |
|---|---|---|
| `SIDE_VIEW_NOT_90_DEGREE` | 能看到明显正面或背面，属于 3/4 | 强化单相机正交、精确 yaw、pitch/roll 0；只重做相机 |
| `SIDE_VIEW_PERSPECTIVE` | 近大远小、平行边收敛 | 明确 `orthographic projection / no perspective distortion` |
| `SIDE_CAMERA_DIRECTION_AMBIGUOUS` | left/right 命名与观察方向不清 | 临时改用 Side A/B，确认映射后再命名 |
| `SIDE_VIEW_NOT_ALIGNED` | 物体倾斜、斜摆、交叉或 roll 偏移 | 锁主轴和画面中轴；禁止继承正面姿态 |
| `SIDE_VIEW_CROPPED` | 头部、手柄或尾饰被裁切 | 保持等比缩放并增加安全边距 |
| `SIDE_NONUNIFORM_SCALE` | 为变窄而横向挤压，比例失真 | 撤销非等比缩放，重新生成真实侧面几何 |

## 几何分类与体积

| 失败码 | 表现 | 恢复 |
|---|---|---|
| `SIDE_GEOMETRY_CLASS_MISSING` | 只写 side view，没有说明物体体积类型 | 选择 P1/P2/P3/V1/V2/O1 |
| `SIDE_GEOMETRY_CLASS_WRONG` | 薄片、层叠盘、圆体块或箱体规则套错 | 回到几何分类门，改写体积解释 |
| `SIDE_GEOMETRY_EVIDENCE_MISSING` | 隐藏深度没有任何证据，多种解释都合理 | 向用户询问一次或补 45° / 草图 / 模型证据 |
| `SIDE_VIEW_FRONT_COMPRESSED_FAKE` | 正面图被横向压扁，仍能看出完整正面纹理 | 禁止把 front 作为编辑目标；重建侧面厚度和遮挡 |
| `SIDE_TOO_THIN_FOR_VOLUME` | 层叠盘、圆体块或箱体被压成细线 | 改用 P3/V1/V2，补主体层和前后深度卡 |
| `SIDE_TOO_WIDE_OR_FACE_ON` | 侧面仍像正面，宽轮廓展开 | 强化 must_hidden，只保留边、薄边和浅凸层 |
| `SIDE_LONG_HEAD_COLLAPSED` | 枪头 / 长钻头变成普通针或长度缩短 | 使用 P2，锁定头部长度、护颈、插槽和连接 |
| `SIDE_ROUND_VOLUME_MISSING` | 球、圆鼓、桶、瓶变成薄板 | 使用 V1，按横截面证据恢复体积 |
| `SIDE_BOX_DEPTH_WRONG` | 锤头 / 箱体前后深度、台阶或接口错误 | 使用 V2 深度结构卡重建 |
| `SIDE_CAVITY_FILLED` | 镂空框、孔洞或空腔被填死 | 使用 O1/C_CAVITY_CRITICAL，明确空腔必须保持为空 |
| `SIDE_SPIKES_MISSING` | 体块侧向尖刺被删掉 | 区分侧向尖刺与前后尖刺，恢复 must_visible 数量 |

## 可见性与遮挡

| 失败码 | 表现 | 恢复 |
|---|---|---|
| `SIDE_VISIBILITY_CONTRACT_MISSING` | 未确认当前侧必须看见和隐藏什么 | 填写单侧可见性合同后再生成 |
| `SIDE_VISIBILITY_CONTRACT_BROKEN` | 合同要求的结构缺失或禁显结构出现 | 只修当前目标侧的 must_visible / must_hidden |
| `SIDE_OCCLUSION_ORDER_WRONG` | 前后层、支撑、孔洞或尖刺遮挡顺序错误 | 写明从相机到远处的层级顺序 |
| `SIDE_COMPLETE_FACE_DETAIL_VISIBLE` | 完整宝石、徽章、纹理或正面装饰露出 | 改为 edge/sliver/shallow protrusion/hidden |
| `OPPOSITE_SIDE_DETAIL_COPIED` | 当前侧出现另一侧独有结构 | 删除 forbidden_transfer 中的内容 |
| `SIDE_ASYMMETRY_ERASED` | 单侧结构被自动对称化 | 启用 A_ASYMMETRIC 并锁数量、顺序和位置 |

## 锚点与身份

| 失败码 | 表现 | 恢复 |
|---|---|---|
| `SIDE_LANDMARK_DRIFT` | 主体中心、接口、环箍或尾饰高度错位 | 使用锚点表重做当前候选 |
| `SIDE_HANDLE_LENGTH_DRIFT` | 手柄 / 长轴变短、变长或弯曲 | 单点修复柄起止、直径和中轴 |
| `SIDE_IDENTITY_DRIFT` | 像同系列新资产而不是同一件物体 | 强化 exact same physical asset 和设计锁角色 |
| `SIDE_NEW_GEOMETRY_ADDED` | 新增尖刺、鳍片、按钮、宝石或机械件 | 列出禁止新增项，只保留设计锁证据 |
| `SIDE_REQUIRED_GEOMETRY_MISSING` | 插槽、护颈、端帽、把手或接口消失 | 把缺失件写入 must_visible 与锚点 |
| `SIDE_STYLE_DRIFT` | 材质、画风、细节密度或低模语言改变 | 重新声明风格锁，只重做当前候选 |
| `LOW_POLY_CHILDISH_SIMPLIFICATION` | 低模变成儿童玩具或简陋训练模型 | 改写为 premium stylized Roblox game asset |

## 左右与镜像

| 失败码 | 表现 | 恢复 |
|---|---|---|
| `UNCONFIRMED_SIDE_MIRROR` | 未授权就翻转另一侧 | 拒绝候选，按当前侧合同独立生成 |
| `LEFT_RIGHT_SAME_CAMERA` | 两张图看起来来自同一个观察方向 | 明确相反 yaw 和方向性遮挡 |
| `LEFT_RIGHT_MISMATCH` | 共享厚度、总高度或锚点不一致 | 用已通过侧作厚度/锚点基准，独立重建对侧 |
| `MIRROR_AUDIT_FAILED` | 授权镜像往返像素误差不为 0 | 停止交付，重新执行确定性翻转 |

## 背景、文件与审核

| 失败码 | 表现 | 恢复 |
|---|---|---|
| `BACKGROUND_NOT_CLEAN` | 有地面、地平线、渐变、墙角或噪声 | 不伤主体边缘的前提下清理，必要时重生成 |
| `TEXT_UI_WATERMARK` | 出现文字、UI、坐标轴或水印 | 重生成当前候选并加强禁止项 |
| `SIDE_IMAGE_DECODE_FAILED` | 文件不存在、损坏或尺寸无效 | 回到生成产物，不能提升正式文件 |
| `CODEX_LOCAL_PREVIEW_UNAVAILABLE` | 本地文件可解码但 Codex 预览失败 | 不重生成；复制短英文审核路径并主动打开 |
| `REVIEW_WINDOW_NOT_FOREGROUND` | 资源管理器已打开但不在前台 | 使用 Computer Use 定位、置前并核对文件列表 |
| `SIDE_USER_APPROVAL_MISSING` | 只有自动检查，没有用户确认 | 停在审核态，等待明确批准 |
| `FINAL_SIDE_FOLDER_DIRTY` | 单侧正式目录含候选、文档或多个文件 | 把非正式内容移到同级目录，重新验证 |

## 超时与重试

| 失败码 | 表现 | 恢复 |
|---|---|---|
| `SIDE_GENERATION_TIMEOUT_PENDING` | 图像生成长时间无输出，但任务状态未知 | 等待 / 恢复原任务，不重复提交 |
| `SIDE_GENERATION_FAILED` | 原任务明确失败或返回不可用产物 | 保留合同，允许重试一次 |
| `SIDE_REPEAT_FAILURE_LIMIT` | 同一主失败码连续出现两次 | 停止生图，补证据、重写结构卡或用 Blender 块模 |

## 恢复优先级

```text
1. SIDE_DESIGN_LOCK / REFERENCE_ROLE
2. SIDE_CAMERA
3. SIDE_GEOMETRY_CLASS
4. SIDE_VISIBILITY / OCCLUSION
5. SIDE_LANDMARK / IDENTITY
6. SIDE_STYLE
7. BACKGROUND / FILE / REVIEW
```

不要用背景修复掩盖相机或几何错误，也不要用“更高质量”参数替代正确合同。

相关入口：[[README|单侧视图生成工作流]]。
