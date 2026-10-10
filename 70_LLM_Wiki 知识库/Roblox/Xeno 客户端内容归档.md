---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-10-10
updated: 2026-10-10
---

# Xeno 客户端内容归档

用户指定的主要工作流保存在 `20_Areas 领域/Roblox/Xeno`，本页只保留检索入口，避免维护两份完整流程。

- [[../../20_Areas 领域/Roblox/Xeno/README|工作流入口]]。
- [[../../20_Areas 领域/Roblox/Xeno/01_Xeno客户端内容归档通用工作流|下载、真实执行验证、清单、导出、资源下载、Terrain、Studio和ZIP全流程]]。
- [[../../20_Areas 领域/Roblox/Xeno/02_快速执行与验收清单|快速执行清单]]。
- [[../../20_Areas 领域/Roblox/Xeno/03_故障排查与适用边界|故障排查和能力边界]]。
- [[../../20_Areas 领域/Roblox/Xeno/04_成功案例与参考实现|历史成功案例与实现证据]]。
- [[../../20_Areas 领域/Roblox/Xeno/06_字节码恢复与场景优化工作流|字节码恢复与场景优化分支]]。
- [[../../20_Areas 领域/Roblox/Xeno/07_EvoMon优化预览版案例与验收|EvoMon 优化案例与验收]]。

核心判断：以当前 Place、Universe 和实测地图/楼层界定范围；成功通知需要真实日志验证；保存 bytecode 不代表恢复源码；附件下载与原生场景另行验收；不同场景分开交付。未加载区域、服务端逻辑和权限受限内容保留缺失说明。

优化分支把可编译的恢复源码、合成候选、反汇编失败分开保存，原游戏代码默认停用。权限清理依据实际属性用途与正常渲染证据；通用 URI 预加载不能判定网格/字体丢失。静态浏览可按需要关闭 Streaming、Avatar 和旧 GUI，并由独立相机验证；编译、预览和原玩法恢复是不同验收目标。

本页依据 2026-10-09 成功捕获及 2026-10-10 证据复核，工具版本属于历史值。参见 [[index|Roblox 游戏开发 Wiki]]、[[../../30_MOC 内容地图/Roblox MOC|Roblox MOC]]。
