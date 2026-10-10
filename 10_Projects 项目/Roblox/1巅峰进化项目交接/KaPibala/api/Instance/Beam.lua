---@class Beam:Instance @一个光束对象，通过在两个 Attachment 之间绘制纹理来连接它们。
---@field Attachment0 Attachment @Beam（光束）起点的 Attachment（附件）。
---@field Attachment1 Attachment @Beam（光束）终点的 Attachment（附件）。
---@field Color ColorSequence @决定光束所有分段的颜色。
---@field CurveSize0 number @和 Beam.Attachment0 一起，确定 Beam（光束）贝塞尔曲线的第一个控制点的位置。
---@field CurveSize1 number @和 Beam.Attachment1 一起，确定 Beam（光束）贝塞尔曲线的第二个控制点的位置。
---@field Enabled boolean @决定 Beam（光束）是否可见。
---@field FaceCamera boolean @决定光束的 Beam.Segments 是否在任何方向都面对镜头。
---@field LightEmission number @确定`光束‘的颜色与其后面颜色的混合程度。
---@field LightInfluence number @确定`光束‘受环境照明影响的程度。
---@field Segments number @设置光束由多少个直线分段组成。
---@field TextureLength number @如果 Beam.TextureMode 为 ‘Wrap’ 或是 ‘Static’，则设置 Beam 的长度。如果 Beam.TextureMode 为 ‘Stretch’ ，则将由它决定相对于 Beam's 长度的纹理大小。
---@field TextureMode TextureMode @决定 Beam.Texture 缩放及重复的方式。
---@field TextureSpeed number @决定 Beam.Texture 图像沿 Beam 移动的速度。
---@field Texture string @显示在 Beam（光束） 上纹理的内容 ID。
---@field Transparency NumberSequence @决定 Beam（光束）所有分段的透明度。
---@field Width0 number @Beam 在其基座上以格计的宽度。
---@field Width1 number @Beam 在其末端以格计的宽度。
---@field ZOffset number @显示的 Beam 相对于 Workspace.CurrentCamera 偏移的距离（以格计）。
local module = {}
---@type fun(param:number) @设置光束纹理周期的当前偏移量。
---@param offset number
function module:SetTextureOffset()
end
