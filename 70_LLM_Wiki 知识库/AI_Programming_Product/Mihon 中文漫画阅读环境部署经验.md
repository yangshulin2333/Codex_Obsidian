---
type: concept
domain: ai-programming-product
status: evergreen
owner: mixed
source: mixed
created: 2026-10-11
updated: 2026-10-11
---

# Mihon 中文漫画阅读环境部署经验

Windows 可以通过 USB 和 ADB 为 Android 手机安装 Mihon，再配置中文漫画源和存储目录。交付应包括实际能打开的中文内容，不能仅以安装命令返回 Success 作为完成标准。

完整操作步骤、PowerShell 命令、本次版本与哈希、故障处理和复用提示词见 [[81_WorkFlow 工作流/Android/通过ADB部署Mihon中文漫画阅读环境_工作流|通过 ADB 部署 Mihon 中文漫画阅读环境工作流]]。

## 可以长期复用的做法

- 从 Mihon 官方发布取得 APK，用发布资产的 SHA-256 核对本地文件；下载慢时可以对剩余字节分段下载，合并后仍需核对完整文件。
- 用 ADB 确认目标设备和已有安装，再安装应用；手机上的安装确认、存储文件夹选择、插件信任属于部署流程的一部分。
- 阅读器、插件商店、具体图源分别配置。Keiyoushi 是社区插件仓库；插件登记地址和手机内的信任状态都要确认。
- 选择提供中文内容的图源。插件名可能是英文，但中文标记 zh 和实际作品页面才决定能否直接阅读中文。
- 域名解析失败时先检查故障发生在哪一层。本次用 Mihon 内的 AliDNS 加密解析修复，再重启应用并复查图源。
- UI 自动化根据当前文本、描述和可点击节点定位。手机型号、屏幕尺寸和用户操作变化后，旧坐标可能失效。

## 2026 年 10 月 11 日验证记录

| 验证对象 | 本次结果 |
|---|---|
| 设备与应用 | 一加 Ace 6T，Android 16；Mihon 0.20.4，中文界面 |
| 中文图源 | Mangabz 1.6.1、漫画柜 1.6.0、再漫画 1.6.0，安装并逐个手动信任 |
| 插件商店 | Keiyoushi，使用 index.pb 地址添加成功 |
| 存储 | 选择手机里的 Mihon 专用目录作为存储根目录 |
| DNS 故障 | 再漫画域名解析失败；Mihon 内选 AliDNS 并重启后列表加载成功 |
| 运行验收 | 三个源的热门列表加载成功；漫画柜的中文漫画第一页试读成功 |

本次完成了目录配置，没有验收离线下载或自动备份。列表可加载也不等于所有作品、所有章节持续可读。

## 下次复用时核验

版本、扩展发布文件、兼容要求、网站域名和可用性具有时间敏感性。上表用于追溯本次部署；下次安装前重新核对官方发布和当前仓库，并在目标手机上复查列表与阅读页面。

## 来源与关联

- 2026-10-11 本次 USB 安装、手机 UI 配置与实际阅读验证。
- [Mihon 官方下载](https://mihon.app/download/)
- [Keiyoushi 官方安装指南](https://keiyoushi.github.io/docs/guides/getting-started)
- [Mihon 常见故障指南](https://mihon.app/docs/guides/troubleshooting/common-issues)
- [[30_MOC 内容地图/AI 编程与产品 MOC]]
- [[70_LLM_Wiki 知识库/AI_Programming_Product/index|AI 编程与产品 Wiki]]
