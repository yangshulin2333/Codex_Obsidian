# 霜蓝秘银三叉戟 建模友好版四视图状态

## 当前状态

- 状态：model_friendly_four_view_ready
- 用途：Tripo / 3D AI 武器建模输入参考
- 武器类型：长柄枪头型 / 三叉戟
- 生成路线：built-in image_gen + local mirror for right side
- 源设计：霜蓝秘银三叉戟美术版四视图

## 正式输出

- front: `frost_blue_mithril_trident_model_friendly_front.png`
- back: `frost_blue_mithril_trident_model_friendly_back.png`
- left: `frost_blue_mithril_trident_model_friendly_left.png`
- right: `frost_blue_mithril_trident_model_friendly_right.png`
- contact sheet: `frost_blue_mithril_trident_model_friendly_contact_sheet.png`

## 建模友好化规则

- 保留：长柄、三尖枪头、中央主尖、两侧副尖、弧形护架、中心冰蓝晶体、底部尖形端帽。
- 简化：复杂晶体切面、小尖角、碎装饰、高频纹理、过多护架分层。
- 强化：大块低模平面、清晰插槽、可读厚度、材质色块分区。
- 侧视：表达厚度和连接关系，不展开正面宽护架。

## 视觉检查

- front：结构明显块状化，适合让 Tripo 识别主形。
- back：与 front 结构一致，背面晶体更简单。
- left：真 90 度侧视倾向，护架和晶体只保留窄边厚度。
- right：由 left 镜像得到，保持左右一致。

## Tripo 使用建议

- 先继续用 20000 面或 30000 面测试，不要直接把面数当作主问题。
- 这版重点解决结构理解问题；如果材质仍丢失，再优先检查 Tripo 的贴图 / 纹理 / 材质开关。
- 如果生成结果仍然变成灰白素模，下一步应做更高对比的纯色材质版，而不是继续增加装饰。
- 如果枪头仍碎裂，下一步应继续减少护架端帽和晶体数量。

## 边界

本目录只交付 Tripo / 3D AI 建模参考图。没有执行 Roblox FBX / GLB 打包，也没有做 Blender 修模。

