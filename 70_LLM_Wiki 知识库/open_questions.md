---
type: concept
domain: vault
status: active
owner: mixed
source: self
created: 2026-06-26
updated: 2026-08-28
---

# Open Questions

这里记录暂时不能直接整理定论的问题。

## Vault 结构

- [x] 是否需要把旧的 `.gitigore` 保留为历史文件，还是后续在确认后删除？已删除，由 `.gitignore` 替代。
- [x] 是否需要初始化 Git 仓库，给后续批量整理提供可回滚历史？已初始化，当前分支为 `main`。
- [ ] Git 远端使用哪个服务和仓库地址，仓库应为私有还是公开？
- [ ] 当前约 13.3 GB 未跟踪资产和既有大文件历史，是采用“笔记与大型资产分开”，还是迁移到目标服务支持的大文件扩展？详见 [[Vault/Git 远端同步前审计与资产边界]]。
- [ ] 是否需要建立 `90_Archive 归档`，用于存放已完成项目和不常用资料？

## Roblox

- [ ] 可丽 Custom Rig 已完成导出、FBX 回读和 Studio 预览；实际导入、同骨架播放、配件循环修复与手机/电脑性能何时验收？资源归属与上传范围确认后再推进，见 [[../81_WorkFlow 工作流/Roblox/模型相关/带动画角色导入Roblox工作流/01_可丽案例与验收记录|可丽验收记录]]。
- [x] Roblox 领域应该先从哪个项目开始编译 Wiki：ToyBox、吃食物 Demo、精灵 / Hotpot，还是工作流资产链？已从 ToyBox 主线开始，并完成第一轮入网。
- [ ] `81_WorkFlow 工作流/Roblox` 中的资产输出是否要建立资产索引，而不是移动图片？
- [ ] 冰晶战锤锤身使用“基础四图 + 独立左右 45°”后，混元 3D 是否能修复端面—侧壁—中央机构的空间过渡？结果需写回 [[../81_WorkFlow 工作流/Roblox/模型相关/高级武器模型制作/冰晶战锤45度空间桥接复盘|案例复盘]]，再判断高级武器流程能否从 `Review` 升级。

## Finance and Life

- [x] 个人理财笔记是否需要区分：账户信息、投资观点、资产配置、人生目标、复盘？已建立模板和核验边界。
- [x] 哪些内容属于敏感信息，不应该交给 Codex 汇总到普通 Wiki 页面？已建立 [[Finance_Life/不适合 Codex 汇总的内容]]。

## English

- [x] 英语学习优先做单词积累、表达模板、商务邮件，还是 Codex 对外沟通句库？已先做 CET-4 友好表达、PR/Issue 和技术词汇。

## AI / Programming / Product

- [ ] 哪些 Codex 工作流已经稳定到可以沉淀成 Skill？候选：ToyBox 工作流、Roblox UI 读取、Obsidian LLM Wiki 整理。
- [x] AI 工具记录是否需要统一为工具卡格式？已建立 [[AI_Programming_Product/AI 工具卡模板]]。

## GitHub and Resources

- [x] 长期资源是按主题整理，还是按使用场景整理？先按使用场景和验证状态整理，入口保留主题分类。
- [x] GitHub 仓库资源卡是否要记录安装验证结果？已纳入 [[GitHub_Resources/GitHub 仓库资源卡模板]]。

## 后续新增问题

- [x] 是否需要把本轮 Obsidian LLM Wiki 整理流程升级成 Codex Skill？已建立 `obsidian-llm-wiki-organizer`。
- [ ] 是否需要为 `00_Inbox 收集箱` 建立每周清理自动检查清单？
- [ ] 是否需要为金融/账号类笔记建立本地私密区或排除规则？
