---
name: v2rayn-app-direct-routing
description: 给 Windows v2rayN v7 全局路由或 TUN 模式添加指定应用直连规则。Use when the user says QQ、微信、TIM、WeGame、英雄联盟、LOL、网络质量评估、游戏延迟、反作弊 SGuard、某个 .exe 在 v2rayN 全局/TUN VPN 下登录失败、聊天异常、游戏高延迟、需要某个应用直连但其他流量仍走全局代理，或需要把应用进程名、域名、IP 写入 v2rayN RoutingItem / sing-box route 规则。
---

# v2rayN 全局代理应用直连

## 目标

在不关闭 v2rayN 全局路由和 TUN 的前提下，把指定应用直连，其他流量仍走代理。

典型场景：

- QQ / TIM 登录失败，但要求 v2rayN 全局仍开启。
- 微信可登录但消息、插件、小程序连接异常。
- 某个 Windows `.exe` 被全局代理影响，需要按进程名、域名或 IP 直连。

## 操作原则

1. 先确认 v2rayN 路径和版本，不猜配置目录。
2. 修改前备份 `guiConfigs/guiNDB.db` 和 `guiConfigs/guiNConfig.json`。
3. 优先添加进程级直连规则，再补域名和 IP。
4. 不把 `geoip:cn` 作为默认方案；那会把全中国直连，不再是严格全局。
5. 不要轻易把 `ApplicationFrameHost.exe`、`RuntimeBroker.exe` 放行；这会影响大量 Microsoft Store / UWP 应用。
6. 修改后必须重启 v2rayN 服务，让 `binConfigs/configPre.json` 重新生成。

## 快速流程

1. 定位 v2rayN 根目录，例如：

```powershell
D:\VPS\v2rayN-windows-64\v2rayN-windows-64
```

2. 确认当前路由和备份：

```powershell
py -3 "...\scripts\update_v2rayn_app_direct_route.py" `
  --v2rayn-root "D:\VPS\v2rayN-windows-64\v2rayN-windows-64" `
  --label "QQ TIM" `
  --process QQ.exe QQNT.exe TIM.exe `
  --domain qq.com imqq.com tencent.com gtimg.cn qpic.cn qlogo.cn mobileqq.com `
  --ip 218.93.129.146 101.32.104.104 `
  --dry-run
```

3. 实际写入：

```powershell
py -3 "...\scripts\update_v2rayn_app_direct_route.py" `
  --v2rayn-root "D:\VPS\v2rayN-windows-64\v2rayN-windows-64" `
  --label "QQ TIM" `
  --process QQ.exe QQNT.exe TIM.exe QQProtect.exe QQExternal.exe `
  --domain qq.com imqq.com tencent.com gtimg.cn gtimg.com qpic.cn qlogo.cn myqcloud.com qqmail.com mobileqq.com `
  --ip 218.93.129.146 101.32.104.104 43.130.30.240 43.130.30.185
```

4. 重启 v2rayN 服务：

- 优先点 v2rayN 顶部的 `重启服务`。
- 不要默认强杀 `v2rayN.exe`，尤其它以管理员权限运行时。

5. 验证：

```powershell
py -3 "...\scripts\update_v2rayn_app_direct_route.py" `
  --v2rayn-root "D:\VPS\v2rayN-windows-64\v2rayN-windows-64" `
  --show-routes
```

检查 `binConfigs/configPre.json` 是否出现：

- `process_name`: 包含目标 `.exe`
- `domain_suffix`: 包含目标域名
- `ip_cidr`: 包含目标 IP
- `final`: 仍为 `proxy`

## 通用应用模板

下次不是 QQ/微信时，按这个模板替换：

```powershell
py -3 "...\scripts\update_v2rayn_app_direct_route.py" `
  --v2rayn-root "<v2rayN根目录>" `
  --label "<应用名>" `
  --process "<应用进程.exe>" "<辅助进程.exe>" `
  --domain "<应用域名1>" "<应用域名2>" `
  --ip "<登录失败日志里出现的IP>"
```

如果不知道 `.exe` 名：

```powershell
Get-Process | Where-Object {
  $_.MainWindowTitle -match '应用窗口标题关键词' -or $_.ProcessName -match '应用关键词'
} | Select-Object Id,ProcessName,Path,MainWindowTitle
```

如果不知道 IP：

```powershell
Get-NetTCPConnection -State Established,TimeWait,CloseWait |
  Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess
```

也可以看 v2rayN 底部日志。若登录失败时出现 `accepted tcp:<ip>:8080 [proxy-relay-ss -> proxy]`，说明该 IP 需要补直连。

## WeGame / 英雄联盟换设备流程

从本 Skill 目录执行命令，不要假设 WeGame / 英雄联盟安装在固定盘符。

1. 定位 v2rayN 根目录。根目录应包含：

```text
v2rayN.exe
guiConfigs/
binConfigs/
```

2. 自动发现 WeGame / 英雄联盟进程和域名：

```powershell
Push-Location "<本Skill目录>"
$targets = py -3 .\scripts\discover_wegame_lol_targets.py --format json | ConvertFrom-Json
$targets.discovered_roots
$targets.found_process_names
```

发现脚本会从以下来源找安装根和进程，不写死路径：

- Windows 卸载项注册表；
- 开始菜单 / 桌面快捷方式；
- 当前运行中的 WeGame / 英雄联盟 / Riot / 反作弊进程；
- 已发现安装根目录下的 `.exe`。

3. 干跑确认：

```powershell
py -3 .\scripts\update_v2rayn_app_direct_route.py `
  --v2rayn-root "<v2rayN根目录>" `
  --label "WeGame LOL" `
  --process $targets.processes `
  --domain $targets.domains `
  --dry-run
```

4. 正式写入：

```powershell
py -3 .\scripts\update_v2rayn_app_direct_route.py `
  --v2rayn-root "<v2rayN根目录>" `
  --label "WeGame LOL" `
  --process $targets.processes `
  --domain $targets.domains
```

5. 重启 v2rayN 服务。优先点 v2rayN 顶部 `重启服务`。如果 v2rayN 以管理员权限运行，自动化点击可能失败，需要用户手动点。

6. 验证是否真直连：

```powershell
$config = Get-Content -LiteralPath "<v2rayN根目录>\binConfigs\configPre.json" -Raw -Encoding UTF8 | ConvertFrom-Json
$api = $config.experimental.clash_api.external_controller
Invoke-RestMethod "http://$api/configs"
Invoke-RestMethod "http://$api/connections" |
  Select-Object -ExpandProperty connections |
  Where-Object { $_.metadata.processPath -match 'WeGame|League|Riot|AntiCheat|SGuard|TASLogin|pallas|browser|icreate|FeedBack|xunyou|yxq|NetworkAssist' } |
  Select-Object @{n='chain';e={$_.chains -join '>'}}, @{n='process';e={$_.metadata.processPath}}, @{n='host';e={$_.metadata.host}}, @{n='ip';e={$_.metadata.destinationIP}}, @{n='port';e={$_.metadata.destinationPort}}, rule
```

合格状态：

- `mode` 是 `Rule`。
- WeGame / 英雄联盟 / Riot / SGuard / FeedBack / TASLogin / pallas / browser / xunyou / yxq 相关连接显示 `direct`。
- 其他软件如 Codex、Chrome、Roblox、Discord、Google 仍可显示 `proxy`，这是正常的。

如果看到 `test.wegame.gtimg.com ... using outbound/direct[direct] ... i/o timeout`，说明规则已经直连，问题是本地网络到腾讯测试点超时，不是还在翻墙。

## QQ / TIM 已验证规则

进程名：

```text
QQ.exe
QQNT.exe
TIM.exe
NTQQ.exe
QQProtect.exe
QQExternal.exe
QQScLauncher.exe
QQApp.exe
```

常见域名：

```text
qq.com
imqq.com
tencent.com
gtimg.cn
gtimg.com
qpic.cn
qlogo.cn
myqcloud.com
qqmail.com
mobileqq.com
ptlogin2.qq.com
captcha.qq.com
```

本次验证过的登录 IP：

```text
218.93.129.146
101.32.104.104
122.193.7.205
222.94.109.78
43.130.30.240
43.130.30.185
117.62.243.221
```

## 微信已验证规则

进程名：

```text
Weixin.exe
WeChat.exe
WeChatAppEx.exe
WeChatBrowser.exe
WeChatPlayer.exe
WeChatWeb.exe
WechatAppHost.exe
WeChatUpdate.exe
WeChatUtility.exe
WeChatOCR.exe
```

常见域名：

```text
wechat.com
weixin.qq.com
weixinbridge.com
wx.qq.com
wx2.qq.com
wechatapp.com
weixin.com
servicewechat.com
mp.weixin.qq.com
mmbiz.qpic.cn
mmstat.com
wxapp.tc.qq.com
```

## WeGame / 英雄联盟已验证规则

进程名：

```text
wegame.exe
browser.exe
client_launcher.exe
client_reporter.exe
tgp_daemon.exe
wegameservice.exe
wegame_env.exe
tcls_core.exe
TenioDL.exe
TinyDL.exe
TinyDL64.exe
CrossProxy.exe
rail.exe
pallas.exe
ACE-Helper.exe
TASLogin.exe
QtsUpdater.exe
yxqxunyou.exe
XY_YXQ_Nethelper.exe
icreateLol.exe
SGuard64.exe
SGuardSvc64.exe
SGuardUpdate64.exe
SGuard.exe
SGuardSvc.exe
SGuardUpdate.exe
FeedBack.exe
League of Legends.exe
LeagueCrashHandler64.exe
LeagueClient.exe
LeagueClientUx.exe
LeagueClientUxRender.exe
RiotClientServices.exe
RiotClientCrashHandler.exe
LolAICoach.exe
launcher.exe
Client.exe
client.exe
```

常见域名：

```text
wegame.com.cn
wegame.qq.com
tgp.qq.com
game.qq.com
lol.qq.com
lolm.qq.com
lpl.qq.com
qq.com
tencent.com
gtimg.cn
gtimg.com
qpic.cn
qlogo.cn
myqcloud.com
qcloud.com
ied.qq.com
ieg.tencent.com
tenpay.com
riotgames.com
riotcdn.net
leagueoflegends.com
```

注意：

- 英雄联盟 WeGame 版客户端首页和网络质量评估可能由 `browser.exe` 承载；如果漏掉它，登录器主进程直连后，页面检测仍可能走代理。
- 英雄联盟反作弊和反馈组件可能由 `SGuard64.exe`、`SGuardSvc64.exe`、`SGuardUpdate64.exe`、`FeedBack.exe` 发起 UDP/TCP 裸 IP 连接；如果这些仍显示 `-> proxy`，需要补进程直连。
- 英雄联盟网络辅助/迅游组件可能由 `yxqxunyou.exe`、`XY_YXQ_Nethelper.exe` 发起 UDP 裸 IP 校测连接；如果网络质量评估回到 600ms+，先查这两个进程是否仍显示 `-> proxy`。
- `browser.exe`、`launcher.exe`、`Client.exe` 是通用进程名，只在确认本机 WeGame / 英雄联盟目录存在这些进程后再加入。
- 运行配置里出现 `clash_mode: Global` 规则不等于当前一定是 Global；先通过 `http://127.0.0.1:<Clash API端口>/configs` 确认 `mode`。目标状态应为 `Rule`。

## 失败处理

如果应用仍失败：

1. 看 v2rayN 底部日志，确认目标连接是否仍显示 `-> proxy`。
2. 如果是域名缺失，补 `--domain`。
3. 如果是裸 IP，补 `--ip`。
4. 如果看不到域名但知道进程，补 `--process`。
5. 如果是 Store/UWP 应用，谨慎处理。不要先放行 `ApplicationFrameHost.exe`，先找实际包进程、域名或 IP。
6. 若必须代理而不能直连，换低风险节点；这不是路由规则能完全解决的问题。

更多结构说明见 `references/v2rayN 路由规则参考.md`。
