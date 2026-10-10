---
type: workflow
domain: roblox
status: active
owner: mixed
source: codex
created: 2026-07-13
updated: 2026-07-14
---

# 失败代码与恢复路径

| Code | 含义 | 恢复动作 |
|---|---|---|
| `FRONT_NOT_APPROVED` | 正面尚未成为设计锁 | 停止扩图，等待人工确认 |
| `FRONT_LOCK_COUNT_MISMATCH` | 生成前计划组件数量与用户批准 front 的实际数量不同 | 扩图前重新计数；以批准图更新 Identity Lock，或明确重做 front，禁止继续使用错误数量合同 |
| `RUN_DOCUMENT_MISSING` | 最小运行文档或配置缺失 | 新运行补齐资产锁、运行状态和归一化配置；旧运行可保留完整 v1.2 三份锁 |
| `IDENTITY_LOCK_MISSING` | 没有可审计的物品身份合同 | 创建 Identity ID、组件矩阵、可见性矩阵和隐藏结构政策 |
| `OLD_CONTEXT_POLLUTION` | 读取了旧资产或失败图 | 清空活动候选，重载当前状态和设计锁 |
| `IDENTITY_MISMATCH` | 某视图像另一件道具 | 只重做偏离视图，参考 accepted locks |
| `HIDDEN_GEOMETRY_UNAPPROVED` | 模型擅自补全未确认的背面、内部或顶底结构 | 将结构标为 unknown，索要证据或人工批准推断后再生成 |
| `STYLE_LOCK_BROKEN` | 风格、材质或细节密度漂移 | 保留几何，修复材质与渲染 |
| `SIDE_NOT_90_DEGREE` | 侧视仍是 3/4 | 从 accepted left45 继续旋转到 90° |
| `CAMERA_ANGLE_DRIFT` | 视图带额外俯仰、翻滚、透视或错误 yaw | 固定转台角度与光轴，只重做当前视图 |
| `FRONT_COMPRESSED_FAKE_SIDE` | 压窄正面冒充侧视 | 重建组件级侧面轮廓 |
| `DEPTH_COLLAPSE` | 体块、宝石、托架或框架变薄 | 按深度合同修单图 |
| `PROPORTION_DRIFT` | 总长 / 总高或锚点漂移 | 用比例锁和 accepted refs 归一化 |
| `LONG_AXIS_SHORTENED` | 长体明显缩短 | 恢复 L/W 和前中后锚点 |
| `GROUND_DATUM_BROKEN` | 底座上翘、楔形或不共面 | 将落地组件拉回唯一水平基线 |
| `OPEN_FRAME_SEALED` | 中空结构被封死 | 根据 45° / back 恢复穿透关系 |
| `SIDE_VISIBILITY_CONTRACT_MISSING` | 生成侧视前未确认左右各自显示 / 隐藏结构 | 停止生成，主动询问并复述两份合同 |
| `SIDE_VISIBILITY_CONTRACT_BROKEN` | 侧视遗漏本侧结构或复制对侧专属结构 | 只按该文件合同重做 |
| `UNCONFIRMED_SIDE_MIRROR` | 未经用户明确授权就镜像 / 复用另一侧 | 废弃该图，确认合同与授权后再处理 |
| `LEFT_RIGHT_GENERATIVE_DRIFT` | 左右比例或锚点漂移 | 对照两份已确认合同，只重做偏离视图 |
| `TOP_BOTTOM_EVIDENCE_MISSING` | 无法证明顶底结构 | 不生成 top/bottom，降为 4 / 6 视图 |
| `NORMALIZATION_CONFIG_INVALID` | v1.2 / v1.3 JSON 字段、范围或视图集不合法 | 使用 RUN_TEMPLATES 中的配置模板并重新填写 |
| `SUBJECT_BOUNDS_UNREADABLE` | 无法读取主体边界 | 检查 PNG 是否损坏及 ImageMagick 输出 |
| `SUBJECT_BOUNDS_UNRELIABLE` | 背景渐变、阴影或主体触边导致边界框碰到画布边缘 | 重新生成均匀背景并保留留白；不得盲目提高 fuzz |
| `SUBJECT_SCALE_DRIFT` | 原始主轴占比偏差超过自动修正上限 | 重做该视图或人工确认；禁止靠缩放隐藏几何漂移 |
| `SUBJECT_SCALE_REVIEW_REQUIRED` | 超过正常容差且配置禁止自动修正 | 人工判断是否允许整体等比修正 |
| `SUBJECT_NORMALIZATION_OVERFLOW` | 归一化后主体无法放入目标画布 | 调低目标占比或修正主体方向，不做非等比压缩 |
| `GENERATION_DUPLICATED` | 沉默时重复提交 | 停止副任务，只恢复最早活动任务 |
| `GENERATION_STALLED` | 生成连续 90 秒未完成或没有新输出 | 停止静默等待并立即告知用户；终止等待句柄、扫描生成目录一次，不自动重提 |
| `GENERATION_HANDLE_LOST` | 对话中断后 cell / task 句柄无法恢复 | 按原句柄、生成目录、运行目录顺序查找；找不到时停下并由用户决定是否重试 |
| `GENERATION_RESULT_MISSING` | 任务完成但未落盘 | 查缓存 / 会话结果；找不到再重生一次 |
| `CANVAS_MISMATCH` | 正式图片尺寸不同 | 等比缩放、居中和补边 |
| `NON_UNIFORM_STRETCH` | 为塞画布而拉伸 | 回到原图，按比例重新归一化 |
| `CONTACT_SHEET_FAILED` | 联系表显示视图不一致 | 定位单张偏离图，不重做全套 |
| `FINAL_FOLDER_DIRTY` | 正式目录混入非正式文件 | 移出检查图、日志、候选和子目录 |
| `ACCEPTED_FOLDER_DIRTY` | 已通过视图目录含未知文件或子目录 | 把候选和说明移回对应目录，只保留视图白名单 |
| `ACCEPTED_VIEW_MISSING` | 所选视图集缺少必要源图 | 按该文件可见性合同补齐；仅在用户授权时可镜像 |
| `ACCEPTED_VIEW_SET_INCOMPLETE` | Accepted 目录没有真实包含所选 4 / 6 / 8 视图全部文件 | 按合同补齐文件并核对文件数和白名单，再运行最终化 |
| `STAGED_OUTPUT_EXISTS` | 待审核目录已存在 | 先审核、批准或人工归档，不直接覆盖 |
| `APPROVED_FINAL_EXISTS` | 正式上传目录已存在 | 停止覆盖；明确归档策略后再重新执行 |
| `GENERATED_ARTIFACT_EXISTS` | 联系表或审计报告已存在 | 确认替换后显式使用 `-Force`，不影响正式目录 |
| `CONTACT_SHEET_NOT_APPROVED` | 机械处理已完成但没有人工确认 | 保持 `FILES_READY`，审核后运行 Approve 脚本 |
| `APPROVAL_EVIDENCE_MISSING` | 审批所需联系表、复制审计或归一化报告缺失 | 重新运行最终化并补齐证据 |
| `STAGED_MANIFEST_INVALID` | 待审核清单 JSON 无法读取 | 重新运行最终化，不手工伪造清单 |
| `STAGED_MANIFEST_MISMATCH` | 待审核文件名、数量或 SHA-256 与清单不一致 | 停止审批，查明文件变化并重新最终化 |
| `BATCH_INDEX_MISSING` | 提供了批次根目录但缺少批次交付索引 | 创建双语批次索引后重试 |
| `FINAL_LINKS_MISSING` | 未交付可点击路径 | 补齐批次、运行、正式上传和联系表的绝对路径 |
| `BATCH_ROOT_MISSING` | 两个及以上资产直接散落在输出根目录，或运行目录不在批次根目录下 | 创建含中文名称的批次外层目录并更新批次交付索引 |
| `PURE_ENGLISH_OUTPUT_NAME` | 用户可见目录或文件使用纯英文名称 | 改为中文或 `中文_English` 双语名称；旧版兼容目录不得复制为新模板 |
| `DELIVERY_DIRECTORY_NOT_REPORTED` | 完成后只说“已完成”，没有回显目录 | 输出批次根、运行目录、正式上传目录、联系表和交付索引的可点击绝对路径 |
| `3D_STRUCTURE_MISREAD` | 3D 工具误解结构 | 从症状反查给错信号的视图 |

## 恢复原则

```text
先恢复原活动任务；确认失败后才重生。
只修坏掉的视图；不要无意义重做全套。
先修身份、结构、相机和比例信号；不要先加面数或装饰。
自动归一化只修整体构图，不掩盖几何错误。
失败图不留在活动候选目录。
用户侧静默不得超过 45 秒；90 秒无完成信号即熔断并报告。
Accepted 目录文件数必须等于所选视图集数量，不能只保存独特生成源。
FILES_READY 不等于 CONTACT_SHEET_APPROVED，更不等于 3D_RESULT_REVIEWED。
```
