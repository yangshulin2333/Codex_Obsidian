---
type: workflow
domain: ai-programming-product
status: evergreen
owner: mixed
source: mixed
created: 2026-10-11
updated: 2026-10-11
---

# 通过 ADB 部署 Mihon 中文漫画阅读环境

通过 Windows 电脑的 USB 和 ADB，为 Android 手机安装免费开源的 Mihon、配置中文图源、授予存储目录访问权限，并验证中文漫画能打开。该流程适用于用户已经授权操作其连接手机的场景，也可交给 Codex 执行。

2026-10-11 已在一加 Ace 6T 上完成部署：Mihon 中文界面可用，Mangabz、漫画柜、再漫画已安装并信任，三个源的热门列表能加载，漫画柜的一页中文漫画已打开。目录、插件信任、网络请求和阅读页面需要分别验收。

部署原理与本次经验见 [[70_LLM_Wiki 知识库/AI_Programming_Product/Mihon 中文漫画阅读环境部署经验]]；知识入口见 [[30_MOC 内容地图/AI 编程与产品 MOC]]。

## 本次部署版本与环境快照

| 项目 | 2026-10-11 实际记录 |
| --- | --- |
| 电脑 | Windows，PowerShell，已有 ADB 34.0.5 |
| 手机 | 一加 Ace 6T，ADB 型号 PLR110，Android 16 |
| 手机语言 | `zh-Hans-CN`，Mihon 首次启动已显示中文 |
| Mihon | 0.20.4 通用 APK，包名 `app.mihon`，versionCode 29 |
| 系统要求 | 本次 APK 的 minSdk 26，即 Android 8.0；targetSdk 36 |
| 中文扩展 | Mangabz 1.6.1、ManHuaGui 1.6.0、Zaimanhua 1.6.0 |
| 存储根目录 | `/storage/emulated/0/Mihon`，供下载章节与备份文件等使用 |
| 社区插件商店 | Keiyoushi，仓库入口 `index.pb` |
| 应用网络设置 | Mihon 内 DNS over HTTPS 选择 AliDNS |

表中版本是本次部署记录。下次执行先检查官方发布、扩展商店索引与兼容性，再确定安装版本；升级版本后同时更新文件名、下载地址、大小及哈希。

## 准备电脑和手机

1. 手机连接 USB，开启开发者选项和 USB 调试；保持解锁，遇到 RSA 调试授权提示时在手机确认。
2. 查找现有 `adb.exe`；没有时使用 [Android 官方 Platform Tools](https://developer.android.com/tools/releases/platform-tools)。USB 文件传输可用并不等于 ADB 已授权。
3. 用 `adb devices -l` 确认目标状态为 `device`。多个设备连接时必须用 `-s` 指定目标；`unauthorized` 需确认手机调试授权，`offline` 需检查连接。
4. 本文所有命令在同一 PowerShell 会话运行。工作目录示例为 `D:\Work\Mihon`，不要原样复用他人的设备序列号。

```powershell
$taskWorkspace = 'D:\Work\Mihon'
$taskWorkPath = Join-Path $taskWorkspace 'work'
$taskApkPath = Join-Path $taskWorkspace 'apk'
New-Item -ItemType Directory -Force -Path $taskWorkPath, $taskApkPath | Out-Null
$taskAdbPath = 'C:\Program Files (x86)\Android\android-sdk\platform-tools\adb.exe'
if (-not (Test-Path -LiteralPath $taskAdbPath)) { throw '请设置实际 adb.exe 路径。' }
& $taskAdbPath version
& $taskAdbPath devices -l
$taskDeviceSerial = '<从 devices -l 复制目标序列号>'
& $taskAdbPath -s $taskDeviceSerial shell getprop ro.build.version.release
& $taskAdbPath -s $taskDeviceSerial shell getprop persist.sys.locale
& $taskAdbPath -s $taskDeviceSerial shell pm list packages app.mihon
```

如果手机已经安装 Mihon，先核对版本和现有配置，保留原书架、目录及备份。安装更新使用 `install -r`，不要以清除数据解决常规部署问题。

## 从官方发布下载并验证 Mihon

本次使用 [Mihon v0.20.4 官方发布](https://github.com/mihonapp/mihon/releases/tag/v0.20.4) 的 `mihon-v0.20.4.apk`，大小 **66,875,196 字节**。GitHub Release API 返回的 asset digest 为：

```text
sha256:49450a6b85ea37a2e1a0a5ff84549b62a00de7c6745d85a0779c30adf7c6894a
```

这里选择官网推荐的 Stable 通用安装包。官网另有完全 FOSS 构建；若需要该构建，应选择对应 APK 并核对它自己的 digest，不能复用本次 Stable 包的哈希。

先从 API 读取指定版本的资源元数据，再下载对应 URL。以下脚本锁定本次历史版本；下次需先选定部署版本并修改 tag。

```powershell
$taskReleaseTag = 'v0.20.4'
$taskApkName = "mihon-$taskReleaseTag.apk"
$taskRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/mihonapp/mihon/releases/tags/$taskReleaseTag" -ErrorAction Stop
$taskAssets = @($taskRelease.assets | Where-Object { $_.name -eq $taskApkName })
if ($taskAssets.Count -ne 1) { throw '未找到唯一的官方通用 APK。' }
$taskAsset = $taskAssets[0]
if ($taskAsset.digest -notmatch '^sha256:[0-9a-fA-F]{64}$') { throw '官方 API 未提供可核对的 SHA-256。' }
$taskApkUrl = $taskAsset.browser_download_url
$taskExpectedSize = [long]$taskAsset.size
$taskExpectedHash = $taskAsset.digest.Substring(7).ToLowerInvariant()
$taskPartialPath = Join-Path $taskWorkPath "$taskApkName.partial"
$taskFinalPath = Join-Path $taskApkPath $taskApkName
curl.exe --location --fail --silent --show-error --retry 3 --connect-timeout 20 --max-time 600 --continue-at - --output $taskPartialPath $taskApkUrl
if ($LASTEXITCODE -ne 0) { throw '下载未完成。保留 partial，随后续传或使用分段方法。' }
if ((Get-Item -LiteralPath $taskPartialPath).Length -ne $taskExpectedSize) { throw 'APK 大小不一致。' }
$taskActualHash = (Get-FileHash -LiteralPath $taskPartialPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($taskActualHash -ne $taskExpectedHash) { throw 'APK SHA-256 与官方 digest 不一致。' }
Move-Item -LiteralPath $taskPartialPath -Destination $taskFinalPath -ErrorAction Stop
```

只有大小和 SHA-256 均匹配时才进入安装。若 API 暂时限流，保留已有文件，稍后重试；不要把页面显示的文件名当作完整性校验。

## 下载慢时保留前缀并用四个 Range 补齐

本次单连接下载较慢，已保存的前缀为 **40,988,672 字节**。保留前缀，将剩余字节分为四段并行下载，再按字节顺序合并，最终仍以官方总大小和 SHA-256 验证。

执行前确认旧下载已停止写入同一个 partial 文件。不要停止其他任务的下载进程。下列脚本复用上一节变量，段起点按当前 partial 大小计算，不固定复盘中的前缀长度。

```powershell
if (-not (Test-Path -LiteralPath $taskPartialPath)) { throw '需要已有 partial 前缀。' }
if (Test-Path -LiteralPath $taskFinalPath) { throw '最终文件已存在，请先核对它。' }
$taskPrefixSize = (Get-Item -LiteralPath $taskPartialPath).Length
if ($taskPrefixSize -ge $taskExpectedSize) { throw '前缀已完整或异常，请直接核对大小和哈希。' }
$taskRemainingSize = $taskExpectedSize - $taskPrefixSize
$taskPartSize = [long][math]::Ceiling($taskRemainingSize / 4.0)
$taskParts = @()
for ($taskPartIndex = 0; $taskPartIndex -lt 4; $taskPartIndex++) {
    $taskStart = $taskPrefixSize + $taskPartIndex * $taskPartSize
    if ($taskStart -ge $taskExpectedSize) { break }
    $taskEnd = [math]::Min($taskExpectedSize - 1, $taskStart + $taskPartSize - 1)
    $taskPartPath = Join-Path $taskWorkPath "part-$taskPartIndex.bin"
    if (Test-Path -LiteralPath $taskPartPath) { throw '分段文件已存在，请核对后换一组文件名。' }
    $taskErrorPath = Join-Path $taskWorkPath "part-$taskPartIndex.error.txt"
    $taskArguments = @('--location', '--fail', '--silent', '--show-error', '--retry', '2', '--connect-timeout', '20', '--max-time', '300', '--range', "$taskStart-$taskEnd", '--output', ".\work\part-$taskPartIndex.bin", $taskApkUrl)
    $taskProcess = Start-Process -FilePath 'curl.exe' -ArgumentList $taskArguments -WorkingDirectory $taskWorkspace -WindowStyle Hidden -PassThru -RedirectStandardError $taskErrorPath
    $taskParts += [pscustomobject]@{ Process=$taskProcess; Path=$taskPartPath; Size=$taskEnd-$taskStart+1; ErrorPath=$taskErrorPath }
}
foreach ($taskPart in $taskParts) {
    $taskPart.Process.WaitForExit()
    if ($taskPart.Process.ExitCode -ne 0) { throw "分段失败，请检查 $($taskPart.ErrorPath)" }
    if ((Get-Item -LiteralPath $taskPart.Path).Length -ne $taskPart.Size) { throw '服务器返回的分段长度不符合 Range。' }
}
$taskCombinedPath = Join-Path $taskWorkPath 'mihon-combined.apk'
if (Test-Path -LiteralPath $taskCombinedPath) { throw '合并文件已存在，请先核对。' }
$taskOutputStream = [System.IO.File]::Create($taskCombinedPath)
try {
    foreach ($taskInputPath in (@($taskPartialPath) + @($taskParts | ForEach-Object { $_.Path }))) {
        $taskInputStream = [System.IO.File]::OpenRead($taskInputPath)
        try { $taskInputStream.CopyTo($taskOutputStream) } finally { $taskInputStream.Dispose() }
    }
} finally { $taskOutputStream.Dispose() }
if ((Get-Item -LiteralPath $taskCombinedPath).Length -ne $taskExpectedSize) { throw '合并大小不一致。' }
$taskActualHash = (Get-FileHash -LiteralPath $taskCombinedPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($taskActualHash -ne $taskExpectedHash) { throw '合并文件 SHA-256 不一致。' }
Move-Item -LiteralPath $taskCombinedPath -Destination $taskFinalPath -ErrorAction Stop
```

该方法要求服务器支持 Range。单段返回整个 APK、各段长度错误或最终哈希不一致时，不进入安装。保留原前缀及分段用于排查；无需将 APK 或中间二进制复制到知识库。

## 安装 Mihon 并核对手机上的版本

```powershell
& $taskAdbPath -s $taskDeviceSerial install -r $taskFinalPath
if ($LASTEXITCODE -ne 0) { throw 'Mihon 安装失败。' }
& $taskAdbPath -s $taskDeviceSerial shell dumpsys package app.mihon | Select-String 'versionCode=|versionName='
& $taskAdbPath -s $taskDeviceSerial shell am start -n app.mihon/eu.kanade.tachiyomi.ui.main.MainActivity
```

本次安装返回 `Success`，手机包信息为 `versionName=0.20.4`、`versionCode=29`。ADB 命令运行中若手机出现安装确认，先处理手机提示再检查命令完成状态。

## 完成首次引导与存储授权

1. 如界面已是中文，直接继续；需要修改时在 Mihon 设置中选简体中文，再确认实际界面。
2. 通过 ADB 创建 `/sdcard/Mihon`，首次引导点击“选择文件夹”，进入内部存储中的 **Mihon**，点击“使用此文件夹”，处理系统访问确认。
3. 返回 Mihon，确认显示 **`已选文件夹：/storage/emulated/0/Mihon`**。仅创建文件夹不足以授予应用访问权限，必须完成系统选择器。
4. 授予“应用安装权限”：系统页面开启“允许从此来源安装应用”。这是供 Mihon 安装和更新图源插件使用。
5. 本次允许“通知权限”和“后台运行权限”；关闭“发送崩溃日志”和“数据分析”，然后“下一步 → 开始使用”。

```powershell
& $taskAdbPath -s $taskDeviceSerial shell mkdir -p /sdcard/Mihon
```

权限名称与确认样式可能随 Android 和厂商系统变化，按当前手机界面检查。目录选择成功只验证目录配置；实际章节下载、备份创建和恢复需要另做验收。

## 安装三个中文扩展

Mihon 是阅读器，扩展负责连接漫画网站。下面三个源在本次索引中语言均为 `zh`，提供中文漫画内容；扩展不会自动将所有外语漫画翻译成中文。

| 手机中的中文源 | 插件名及本次版本 | 包名后缀 |
| --- | --- | --- |
| Mangabz | Mangabz 1.6.1 | `zh.mangabz` |
| 漫画柜 | ManHuaGui 1.6.0 | `zh.manhuagui` |
| 再漫画 | Zaimanhua 1.6.0 | `zh.zaimanhua` |

包名完整前缀为 `eu.kanade.tachiyomi.extension.`。扩展来自 Keiyoushi 社区发布，并非 Mihon 官方随应用提供。

| 本次安装包及发布链接 | 字节数 | 本次 SHA-256 |
| --- | ---: | --- |
| [tachiyomi-zh.mangabz-v1.6.1.apk](https://github.com/keiyoushi/extensions/releases/download/4c8cda7/tachiyomi-zh.mangabz-v1.6.1.apk) | 59,291 | `34457ca72a6b14ce026957a91ecb5ede510f3e2a92779445a9773f8f213ac54b` |
| [tachiyomi-zh.manhuagui-v1.6.0.apk](https://github.com/keiyoushi/extensions/releases/download/24bc6c2/tachiyomi-zh.manhuagui-v1.6.0.apk) | 67,503 | `ba0076c903c3f203c4ed891244923f131bf54f8db78b2a31a02cfaa01e46d887` |
| [tachiyomi-zh.zaimanhua-v1.6.0.apk](https://github.com/keiyoushi/extensions/releases/download/24bc6c2/tachiyomi-zh.zaimanhua-v1.6.0.apk) | 55,035 | `f6605e36a7d1453b60814bb6f7340a8f724183b11ee3f95e02d9542753ba81fe` |

本次下载均核对了对应 GitHub Release API asset digest。下次安装用当前仓库索引确定资源，再读取对应 release metadata；不要把旧哈希用于新版 APK。

```powershell
$taskExtensions = @(
    [pscustomobject]@{ Name='tachiyomi-zh.mangabz-v1.6.1.apk'; Tag='4c8cda7' }
    [pscustomobject]@{ Name='tachiyomi-zh.manhuagui-v1.6.0.apk'; Tag='24bc6c2' }
    [pscustomobject]@{ Name='tachiyomi-zh.zaimanhua-v1.6.0.apk'; Tag='24bc6c2' }
)
foreach ($taskExtension in $taskExtensions) {
    $taskRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/keiyoushi/extensions/releases/tags/$($taskExtension.Tag)" -ErrorAction Stop
    $taskAssets = @($taskRelease.assets | Where-Object { $_.name -eq $taskExtension.Name })
    if ($taskAssets.Count -ne 1) { throw '未找到唯一的扩展安装包。' }
    $taskAsset = $taskAssets[0]
    if ($taskAsset.digest -notmatch '^sha256:[0-9a-fA-F]{64}$') { throw '扩展 API 未提供可核对的 SHA-256。' }
    $taskExtensionPath = Join-Path $taskApkPath $taskExtension.Name
    if (Test-Path -LiteralPath $taskExtensionPath) { throw '扩展文件已存在，请先核对它。' }
    curl.exe --location --fail --silent --show-error --retry 2 --output $taskExtensionPath $taskAsset.browser_download_url
    if ($LASTEXITCODE -ne 0) { throw '扩展下载失败。' }
    if ((Get-Item -LiteralPath $taskExtensionPath).Length -ne [long]$taskAsset.size) { throw '扩展大小不一致。' }
    $taskActualHash = (Get-FileHash -LiteralPath $taskExtensionPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($taskActualHash -ne $taskAsset.digest.Substring(7).ToLowerInvariant()) { throw '扩展 SHA-256 不一致。' }
    & $taskAdbPath -s $taskDeviceSerial install -r $taskExtensionPath
    if ($LASTEXITCODE -ne 0) { throw '扩展安装失败。' }
}
& $taskAdbPath -s $taskDeviceSerial shell pm list packages eu.kanade.tachiyomi.extension.zh
```

本次 ColorOS 显示“来自电脑端未知来源”及“继续安装”，处理后三个安装均成功。安装器里的应用推荐无需操作。ADB 安装成功后仍需在 Mihon 内确认扩展能加载。

## 添加社区商店并逐个信任

商店入口为 `https://github.com/keiyoushi/extensions/raw/repo/index.pb`。本次界面称“插件商店”，其他版本可能称“扩展仓库”；手动路径为 **更多 → 设置 → 浏览 → 插件商店 → 添加**，也可用以下应用深链。本次社区指南要求 Mihon 0.20.1 或以上使用该入口；本文引用的 index.json 只供电脑侧查阅扩展元数据。

```powershell
$taskStoreDeepLink = 'mihon://extension-store?url=https%3A%2F%2Fgithub.com%2Fkeiyoushi%2Fextensions%2Fraw%2Frepo%2Findex.pb'
& $taskAdbPath -s $taskDeviceSerial shell "am start -a android.intent.action.VIEW -p app.mihon -d '$taskStoreDeepLink'"
```

在手机确认“添加插件商店 → 添加”，等待商店列表显示 **Keiyoushi**。若已有此商店，复用现有条目。

本次深链最初触发“Mihon 想打开 Chrome”，取消后仓库仍未添加；强制停止 Mihon，再发显式指定 `-p app.mihon` 的深链，才进入正确添加对话框。

添加商店后，三个插件仍显示“未信任”。进入 **浏览 → 插件**，逐个打开 Mangabz、ManHuaGui、Zaimanhua 的信任提示并点击“信任”，再确认 **浏览 → 图源 → 中文** 出现三个源。

“安装 APK”“添加商店”“信任插件”“图源可见”是不同状态，不能用其中一项代替全部验收。漫画柜在本次索引被标记为混合内容源；若它不可见，检查内容可见性设置和插件信任状态。

## 再漫画解析错误与 AliDNS 修复

本次再漫画最初报错：`Unable to resolve host "v4api.zaimanhua.com": No address associated with hostname`。这是此次网络下的域名解析错误；热门列表空白应先等待加载，再读取错误文本。

进入 **更多 → 设置 → 高级 → DNS over HTTPS (DoH)**，选择 **AliDNS**。确认设置摘要已显示 AliDNS，再重启 Mihon，重新打开再漫画。

```powershell
& $taskAdbPath -s $taskDeviceSerial shell am force-stop app.mihon
& $taskAdbPath -s $taskDeviceSerial shell am start -n app.mihon/eu.kanade.tachiyomi.ui.main.MainActivity
```

本次重启后再漫画热门列表出现“大理寺日志”等中文作品；随后 Mangabz、漫画柜列表也加载成功。改动仅为 Mihon 应用内 DoH 设置，不涉及全手机 DNS、系统 hosts、root 或修改扩展域名。

这次实际顺序是先完成漫画柜试读，再修复再漫画的 DNS，最后复查三个热门列表。下次修改网络设置后，同样复查原本可用的源；若结果变差，恢复原来的 DoH 选项并重启应用。

## 按实际界面操作并保留必要证据

Android UI 自动化使用当前界面节点树，不把本次屏幕坐标作为下次脚本。每次导航后重新 dump；依据 text、content-desc、enabled、clickable 和 bounds 定位目标，必要时寻找它的可点击父节点。

```powershell
$taskUiPath = Join-Path $taskWorkPath 'mihon-window.xml'
$taskScreenPath = Join-Path $taskWorkPath 'mihon-screen.png'
& $taskAdbPath -s $taskDeviceSerial shell uiautomator dump /sdcard/mihon-window.xml
& $taskAdbPath -s $taskDeviceSerial pull /sdcard/mihon-window.xml $taskUiPath
[xml]$taskUiDocument = Get-Content -LiteralPath $taskUiPath -Raw
$taskUiDocument.SelectNodes('//node') | Where-Object { $_.text -ne '' -or $_.'content-desc' -ne '' } | Select-Object text, content-desc, bounds, clickable, enabled
& $taskAdbPath -s $taskDeviceSerial shell screencap -p /sdcard/mihon-screen.png
& $taskAdbPath -s $taskDeviceSerial pull /sdcard/mihon-screen.png $taskScreenPath
```

文本有重复时先看各节点的上下文，再选择对应条目；不能默认第一个匹配就是目标。出现“找不到浏览”时检查 `dumpsys window` 的前台焦点；本次重启后一度回到桌面，显式启动 Mihon Activity 后继续。

阅读页的文字树可能只包含页码。要确认图片已显示，应查看当前截图；截图仅保存在运行工作目录，知识库保留验收结论与方法即可。

## 验收清单与本次验证范围

| 验收项 | 本次结果及范围 |
| --- | --- |
| 应用 | 安装成功，手机包信息确认为 Mihon 0.20.4 |
| 中文界面与目录 | 中文首次引导；选择器返回 `/storage/emulated/0/Mihon` |
| 插件与仓库 | 三插件安装并手动信任；Keiyoushi 商店添加成功 |
| 三源连通性 | Mangabz、漫画柜、再漫画热门列表均加载成功 |
| 详情和中文阅读 | 漫画柜《鬼灭之刃》详情显示 235 章；第 23 卷第一页成功显示，页码 `1 / 230` |
| 最终入口 | 停在“浏览 → 图源”，可选中文源继续搜索；书架为空 |

阅读验证覆盖漫画柜第 23 卷第一页，三源列表成功不代表所有作品和章节均可读。离线下载、备份创建与恢复、自动更新另行按需要验收；目录配置成功不能代替这些运行验证。

## 常见故障处理

| 现象 | 检查和处理 |
| --- | --- |
| 手机能传文件但 ADB 无设备 | 检查 USB 调试、调试授权、数据线与 ADB 驱动；以 `devices -l` 为准 |
| APK 下载慢或中断 | 保留 partial，续传；采用 Range 时校验各段长度、总大小与官方 SHA-256 |
| ADB 安装长时间无输出 | 看手机是否等待“继续安装”；处理后再检查退出码和包版本 |
| 文件夹已创建但引导未完成 | 回到系统选择器进入 Mihon 文件夹，完成“使用此文件夹”并确认已选路径 |
| 深链打开 Chrome 或未添加仓库 | 查看当前界面，必要时强制停止 Mihon，再用限定 `-p app.mihon` 的深链 |
| 插件安装后找不到中文图源 | 检查浏览中的插件状态，逐个信任；必要时检查内容可见性 |
| 再漫画无法解析域名 | 记录错误主机名，尝试应用内 DoH=AliDNS，重启后复测实际列表 |
| 自动化找不到目标文本 | 更新 UI XML，检查前台 App、重复文本和加载状态，不继续盲点坐标 |
| 列表成功但阅读页空白 | 分别验证详情、章节和页面图片；观察错误或截图后再决定修复路径 |

## 给 Codex 的复用提示词

> 手机已连接电脑，请通过 ADB 部署 Mihon 中文漫画阅读环境。工作目录使用 D:\Work\Mihon。先检查目标设备状态和现有 Mihon，保留原数据；从 Mihon 官方 Release 和 Keiyoushi 社区发布下载 APK，核对 API digest、大小及 SHA-256。安装 Mihon 和 Mangabz、漫画柜、再漫画，完成中文界面、Mihon 专用目录选择、安装权限、通知及后台运行设置，关闭崩溃日志与数据分析。添加 index.pb 仓库并检查各插件信任状态。按当前 UI XML 与截图操作，不复用固定坐标。如再漫画出现域名解析错误，尝试 Mihon 内 AliDNS 并重启复测。分别验收版本、目录、三源列表及至少一个中文阅读页，记录实际版本与测试范围；不修改系统 DNS、不 root、不清除数据，不把设备序列号或截图写入知识库。

## 官方与社区来源

- [Mihon 官方下载页](https://mihon.app/download/) 与 [v0.20.4 发布页](https://github.com/mihonapp/mihon/releases/tag/v0.20.4)：应用安装包及版本。
- [Mihon v0.20.4 Release API](https://api.github.com/repos/mihonapp/mihon/releases/tags/v0.20.4)：资源 URL、大小与 SHA-256 digest。
- [Android 官方 ADB 文档](https://developer.android.com/tools/adb) 与 [Platform Tools](https://developer.android.com/tools/releases/platform-tools)：设备连接和安装命令。
- [Keiyoushi 安装指南](https://keiyoushi.github.io/docs/guides/getting-started) 与 [仓库索引](https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.json)：社区商店入口、插件包及图源元数据。
- [扩展发布 4c8cda7 API](https://api.github.com/repos/keiyoushi/extensions/releases/tags/4c8cda7) 与 [24bc6c2 API](https://api.github.com/repos/keiyoushi/extensions/releases/tags/24bc6c2)：本次三个扩展的资源元数据。
- [Mihon 常见故障指南](https://mihon.app/docs/guides/troubleshooting/common-issues) 与 [v0.20.4 DoH 提供商实现](https://raw.githubusercontent.com/mihonapp/mihon/v0.20.4/core/common/src/main/kotlin/eu/kanade/tachiyomi/network/DohProviders.kt)：应用内加密 DNS 的故障处理与 AliDNS 配置。
- [Mangabz 中文源配置](https://github.com/keiyoushi/extensions-source/blob/main/src/zh/mangabz/build.gradle.kts)、[漫画柜中文源配置](https://github.com/keiyoushi/extensions-source/blob/main/src/zh/manhuagui/build.gradle.kts)、[再漫画中文源配置](https://github.com/keiyoushi/extensions-source/blob/main/src/zh/zaimanhua/build.gradle.kts)：名称、语言与网站来源。

相关链接：[[70_LLM_Wiki 知识库/AI_Programming_Product/Mihon 中文漫画阅读环境部署经验]] · [[30_MOC 内容地图/AI 编程与产品 MOC]]
