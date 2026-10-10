---
type: workflow
domain: ai-programming-product
status: evergreen
owner: mixed
source: self
created: 2026-07-01
updated: 2026-07-01
---

# v2rayN 路由规则参考

## 关键文件

便携版 v2rayN v7 通常使用以下结构：

```text
<v2rayN-root>/
  v2rayN.exe
  guiConfigs/
    guiNConfig.json
    guiNDB.db
    backups/
  binConfigs/
    configPre.json
    config.json
```

含义：

- `guiNDB.db`: v2rayN GUI 的长期配置数据库，`RoutingItem` 表保存路由模板。
- `guiNConfig.json`: 保存当前路由 ID 等 GUI 配置。
- `binConfigs/configPre.json`: v2rayN 生成给 sing-box 的路由配置，重启服务后刷新。
- `binConfigs/config.json`: xray 的实际代理出站配置，不负责 TUN 的应用分流。

## RoutingItem 字段

常用字段：

| 字段 | 说明 |
|---|---|
| `Id` | 路由 ID |
| `Remarks` | 路由显示名 |
| `RuleSet` | JSON 字符串，保存路由规则 |
| `RuleNum` | 规则数量 |
| `Sort` | 显示排序 |
| `IsActive` | 当前活动路由 |

本次成功路径是直接修改 `RoutingItem.RuleSet`，并把 `guiNConfig.json` 里的 `RoutingBasicItem.RoutingIndexId` 指向目标路由。

## v2rayN 规则到 sing-box 的映射

`RoutingItem.RuleSet` 中：

```json
{
  "OutboundTag": "direct",
  "Process": ["Weixin.exe"],
  "Enabled": true,
  "Remarks": "WeChat process direct"
}
```

会在 `configPre.json` 中生成类似：

```json
{
  "outbound": "direct",
  "process_name": ["Weixin.exe"]
}
```

域名规则：

```json
{
  "OutboundTag": "direct",
  "Domain": ["domain:qq.com"]
}
```

会生成：

```json
{
  "outbound": "direct",
  "domain_suffix": ["qq.com"]
}
```

IP 规则：

```json
{
  "OutboundTag": "direct",
  "Ip": ["218.93.129.146"]
}
```

会生成：

```json
{
  "outbound": "direct",
  "ip_cidr": ["218.93.129.146"]
}
```

## 判断是否命中

v2rayN 日志里如果看到：

```text
accepted tcp:<domain-or-ip>:443 [proxy-relay-ss -> proxy]
```

说明仍走代理。

如果看到目标应用可以登录，通常说明进程或 IP 直连已命中；v2rayN 默认日志不一定直接显示 `direct` 的所有连接。

更可靠的方式是查 sing-box Clash API：

```powershell
$config = Get-Content -LiteralPath "<v2rayN-root>\binConfigs\configPre.json" -Raw -Encoding UTF8 | ConvertFrom-Json
$api = $config.experimental.clash_api.external_controller
Invoke-RestMethod "http://$api/configs"
Invoke-RestMethod "http://$api/connections" |
  Select-Object -ExpandProperty connections |
  Where-Object { $_.metadata.processPath -match '<应用关键词>' } |
  Select-Object @{n='chain';e={$_.chains -join '>'}}, @{n='process';e={$_.metadata.processPath}}, @{n='host';e={$_.metadata.host}}, @{n='ip';e={$_.metadata.destinationIP}}, @{n='port';e={$_.metadata.destinationPort}}, rule
```

`configs.mode` 应为 `Rule`。如果目标应用相关连接的 `chain` 是 `direct`，说明路由命中；其他无关应用显示 `proxy` 是正常的。

## QQ 登录失败的关键线索

只加域名不一定够。QQ 登录可能直接访问裸 IP 和 8080/8081 端口，例如：

```text
218.93.129.146:8081
101.32.104.104:8080
43.130.30.240:8080
43.130.30.185:80
```

这类情况需要同时加：

- 进程名直连；
- 域名直连；
- 登录失败日志中出现的 IP 直连。

## Store / UWP 应用注意

不要默认放行：

```text
ApplicationFrameHost.exe
RuntimeBroker.exe
```

这两个进程范围太宽，会影响很多 Store / UWP 应用。优先找具体包进程、域名或 IP。

## WeGame / 英雄联盟注意

不要写死 WeGame 或英雄联盟的安装盘符。换设备时优先运行：

```powershell
Push-Location "<本Skill目录>"
$targets = py -3 .\scripts\discover_wegame_lol_targets.py --format json | ConvertFrom-Json
$targets.discovered_roots
$targets.found_process_names
```

脚本会通过卸载项、快捷方式、运行进程和候选安装根目录发现目标。然后把 `$targets.processes` 和 `$targets.domains` 传给 `scripts\update_v2rayn_app_direct_route.py`。

关键经验：

- WeGame / 英雄联盟首页和网络质量评估可能由 `browser.exe` 承载。
- 英雄联盟反作弊和反馈链路可能由 `SGuard64.exe`、`SGuardSvc64.exe`、`SGuardUpdate64.exe`、`FeedBack.exe` 承载。
- 英雄联盟网络辅助/迅游链路可能由 `yxqxunyou.exe`、`XY_YXQ_Nethelper.exe` 承载；如果网络质量评估回到 600ms+，优先查这两个进程是否仍在 `proxy`。
- WeGame/LOL 相关 UDP 裸 IP 显示 `direct` 即为规则命中；如果显示 `proxy`，先查对应 `processPath`，再补进程名。
- `test.wegame.gtimg.com ... outbound/direct ... i/o timeout` 表示已经直连，但本地网络到腾讯测试点超时。
- 不要用 `geoip:cn` 作为默认修复；这会让全中国流量直连，破坏“全局代理但指定应用直连”的目标。

## 回滚

修改前备份会放在：

```text
<v2rayN-root>/guiConfigs/backups/
```

回滚方式：

1. 退出 v2rayN。
2. 用备份的 `guiNDB.db` 覆盖 `guiConfigs/guiNDB.db`。
3. 用备份的 `guiNConfig.json` 覆盖 `guiConfigs/guiNConfig.json`。
4. 重新打开 v2rayN。
