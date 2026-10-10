---
type: workflow
domain: ai-programming-product
status: active
owner: mixed
source: mixed
created: 2026-08-05
updated: 2026-08-05
---

# DMIT 服务器：3x-ui / Xray 运维操作手册

## 一句话说明

这是当前 DMIT Ubuntu 服务器的可复用操作手册，覆盖密钥 SSH 登录、检查流量额度、升级 3x-ui 与 Xray、创建和管理入站/客户端、设置 30GB 月度配额，以及 VLESS + TCP + REALITY 升级后的兼容性排障。

> [!warning] 适用边界
> 本文针对原生 systemd 安装的 3x-ui：服务名为 x-ui，程序目录为 /usr/local/x-ui/，数据库为 /etc/x-ui/x-ui.db。
>
> [[3XUI搭建]] 是另一种 Docker 部署方案，不能把其中的 docker compose 命令用于当前服务器。

## 当前实例快照（2026-08-05）

| 项目 | 已核验状态 |
|---|---|
| 系统 | Ubuntu 22.04.5 LTS |
| 3x-ui | 3.6.0 |
| Xray | 26.7.28 |
| 服务 | x-ui.service 已启用且运行中 |
| 入站总数 | 16 个，其中 13 个启用 |
| REALITY 兼容字段 | 16 个均为 minClientVer = "0.0.0" |
| 30GB/月配额 | 15 个入站：30GB、每月 1 日重置 |
| 例外 | Backup-01 当前为不限流量、永不自动重置；如要统一策略，需要单独改为 30GB/月 |
| 外部客户端验收 | 修复后仍需在 v2rayN 实测；不要把“服务已启动”当作“节点已可用” |

不要把以下内容写进普通笔记、聊天记录或公开截图：

- 私钥文件本体、私钥内容、面板密码；
- 当前服务器公网 IP、面板随机路径、UUID、Reality 私钥；
- 包含完整订阅链接或完整二维码的截图。

下文统一使用占位符：

~~~text
SERVER_IP       服务器 IPv4
KEY_PATH        本地 .pem 私钥路径
PANEL_URL       3x-ui 面板完整地址
PORT            入站端口
~~~

## 0. 先理解三个概念

| 名称 | 是什么 | 什么时候新建 |
|---|---|---|
| 入站（Inbound） | 一个监听端口、协议和传输/安全配置的入口 | 要隔离端口、协议或整条入站策略时 |
| 客户端（Client） | 挂在入站下的一份用户凭据，例如 UUID、流量和到期规则 | 新设备或新使用者通常先新增它 |
| 节点/订阅项 | v2rayN 中能导入、连接并测试的一条连接配置 | 通常来自“入站 + 客户端”的组合 |

因此：新增一个人或设备不一定要新建入站。若协议、端口和策略都相同，优先在现有入站中新增客户端；只有需要独立端口或独立策略时，再新建入站。

## 1. 登录前检查：先判断是否是流量耗尽

DMIT 流量用尽时，服务器通常不会关机，但线路会被限速或无法正常使用，症状很像节点故障。

1. 登录 DMIT 控制台，查看本周期可用流量、已用流量和下次重置时间。
2. 如果可用流量接近 0，优先购买/重置流量或等待套餐周期重置。
3. 流量恢复后，再测试任意既有节点；不要一开始就重建全部入站。

本次故障的第一层原因是月流量耗尽；后续的“全部节点无法连接”才是升级后的 REALITY 兼容性问题，两者要分开判断。

## 2. 使用 PuTTY 通过密钥登录

DMIT 不是“不用 SSH”，而是通常不用 SSH 密码，改用 SSH 私钥认证。

### 2.1 PuTTY 图形界面

1. 打开 PuTTY，在 Session 中填写：
   - Host Name：SERVER_IP
   - Port：22
   - Connection type：SSH
2. 进入 Connection → Data，在 Auto-login username 填 root；也可以留空，连接后再输入。
3. 进入 Connection → SSH → Auth → Credentials。
4. 在 Private key file for authentication 选择 DMIT 下载的私钥文件：
   - 若 PuTTY 不接受 .pem，使用 PuTTYgen 转换为 .ppk 后再选择；
   - 不要把私钥上传到云盘、聊天群或面板。
5. 返回 Session，可先保存会话配置，再点击 Open。
6. 首次连接会显示服务器主机指纹确认窗口；确认来源是自己的 DMIT 实例后再接受。

成功时应看到：

~~~text
Authenticating with public key
Welcome to Ubuntu ...
root@<hostname>:~#
~~~

### 2.2 Windows OpenSSH（PowerShell）

~~~powershell
$Server = 'SERVER_IP'
$Key = 'KEY_PATH'
ssh -i $Key root@$Server
~~~

如果 Windows OpenSSH 报“私钥权限过宽/Permissions are too open”，在 PowerShell 执行：

~~~powershell
$Key = 'KEY_PATH'
$Principal = "$env:USERNAME" + ':(F)'
icacls $Key /inheritance:r
icacls $Key /grant:r $Principal
~~~

这会收紧本机私钥 ACL。完成后重新连接。

### 2.3 登录后的最小核验

~~~bash
whoami
hostnamectl
systemctl is-active x-ui
~~~

预期：用户是 root，且 x-ui 输出 active。

## 3. 日常健康检查

在服务器执行：

~~~bash
systemctl is-active x-ui
systemctl status x-ui --no-pager
/usr/local/x-ui/x-ui -v
/usr/local/x-ui/bin/xray-linux-amd64 version | head -n 1
ss -lntp | grep -E 'x-ui|xray'
journalctl -u x-ui -n 100 --no-pager
~~~

判断方式：

- active：服务进程已运行，但还不代表每条节点都可连；
- ss 能看到所需入站端口被 Xray 监听：说明服务端口已启动；
- 日志有配置错误、端口占用或 REALITY 警告：继续处理日志，不要直接重建节点。

面板打不开时，先执行：

~~~bash
systemctl restart x-ui
systemctl is-active x-ui
journalctl -u x-ui -n 100 --no-pager
~~~

然后再检查 DMIT 网络策略、面板 URL 和本地网络；不要为了排错而把面板公开到所有来源。

## 4. 升级 3x-ui 与 Xray

### 4.1 升级前

1. 在面板中停止编辑入站，避免网页保存和数据库修改同时发生。
2. 记录当前版本和服务状态：

~~~bash
/usr/local/x-ui/x-ui -v
/usr/local/x-ui/bin/xray-linux-amd64 version | head -n 1
systemctl is-active x-ui
~~~

3. 生产环境建议备份数据库：

~~~bash
install -d -m 700 /root/x-ui-backups
cp -a /etc/x-ui/x-ui.db "/root/x-ui-backups/x-ui.db.$(date +%F-%H%M%S)"
~~~

> [!note] 本次实际操作
> 用户明确选择“不备份，直接升级”。这是一次可接受的用户决策记录，不应当成为以后升级的默认做法。

### 4.2 执行升级

当前原生安装使用官方维护脚本入口：

~~~bash
x-ui update
~~~

升级过程中 SSH 可能短暂没有输出。不要重复运行更新命令，也不要因为本地终端等待就立刻强制重启服务器。

### 4.3 升级后验收

~~~bash
systemctl is-active x-ui
/usr/local/x-ui/x-ui -v
/usr/local/x-ui/bin/xray-linux-amd64 version | head -n 1
journalctl -u x-ui -n 150 --no-pager
~~~

然后执行两类测试：

1. 访问面板，确认入站和客户端列表仍在；
2. 在 v2rayN 测试一条旧节点，再打开一个实际网站验证流量。

若“面板正常但全部节点失效”，先看第 7 节；不要直接删除全部入站。

## 5. 创建与维护节点

### 5.1 先决定“新增客户端”还是“新增入站”

优先新增客户端的场景：

- 新手机、新电脑或新用户；
- 继续复用既有协议、端口和 REALITY 配置；
- 只需要单独 UUID、备注、到期时间或流量限制。

需要新增入站的场景：

- 要使用不同端口；
- 要用不同协议/传输方式；
- 需要独立故障隔离或独立整条入站的流量政策。

### 5.2 新增入站的安全流程

1. 在入站列表中选择“添加入站”。
2. 协议、网络和 REALITY 参数优先对照一个已验证可用的标准入站；不要凭感觉混合不同节点的公钥、短 ID、SNI 或端口。
3. 选择一个未占用端口，先检查：

~~~bash
ss -lntp | grep -E ':PORT\b'
~~~

无输出通常表示该端口未被本机监听；还需要确认 DMIT 网络侧允许该端口。

4. 保存后，先在面板确认入站已启用。
5. 为该入站新增客户端，填写清晰备注。
6. 从客户端条目导出订阅/二维码，导入 v2rayN。
7. 在 v2rayN 先做延迟测试，再做实际网页访问测试。

> [!warning] 不要复制错误的身份参数
> REALITY 私钥、公钥、短 ID、SNI 与客户端 UUID 必须是一组匹配关系。新建时优先让面板生成，再通过同一客户端条目导出；不要从多条旧节点分别复制字段拼凑。

## 6. 统一设置 30GB、每月 1 日重置

### 6.1 少量节点：优先使用面板

逐条编辑入站，设置：

| 项目 | 值 |
|---|---|
| 总流量 | 30 GB |
| 流量重置 | 每月 |
| 重置日期 | 1 日 |
| 启用状态 | 按实际需要 |

保存后，刷新入站列表，确认流量列显示 0 B / 30.00 GB（或已有用量 / 30.00 GB）。

### 6.2 批量节点：数据库方式（高级，仅在确认需求后使用）

> [!danger] 数据库修改边界
> 下面命令会把所有入站改为 30GB/月/每月 1 日，并不区分是否启用。执行前关闭面板编辑、备份数据库，并确认没有要保留的不限量节点。

~~~bash
install -d -m 700 /root/x-ui-backups
cp -a /etc/x-ui/x-ui.db "/root/x-ui-backups/x-ui.db.$(date +%F-%H%M%S)"

python3 - <<'PY'
import sqlite3

db = '/etc/x-ui/x-ui.db'
limit = 30 * 1024**3
con = sqlite3.connect(db, timeout=15)
con.execute('PRAGMA busy_timeout=15000')
try:
    con.execute('BEGIN IMMEDIATE')
    con.execute(
        "UPDATE inbounds "
        "SET total=?, traffic_reset='monthly', traffic_reset_day=1",
        (limit,),
    )
    con.commit()
finally:
    con.close()
PY

systemctl restart x-ui
systemctl is-active x-ui
~~~

验收：

~~~bash
python3 - <<'PY'
import sqlite3
con = sqlite3.connect('/etc/x-ui/x-ui.db')
for row in con.execute("""
    SELECT COUNT(*), total, traffic_reset, traffic_reset_day
    FROM inbounds
    GROUP BY total, traffic_reset, traffic_reset_day
    ORDER BY total, traffic_reset, traffic_reset_day
"""):
    print(row)
con.close()
PY
~~~

预期每一组都应是：

~~~text
(入站数量, 32212254720, 'monthly', 1)
~~~

32212254720 是 30 GiB 的字节数。输出中若看到 total=0 和 traffic_reset=never，代表该入站仍然不限流量且不重置。

## 7. 升级后全部 REALITY 节点不能用

### 7.1 典型症状

升级 3x-ui/Xray 后，v2rayN 的节点测试全部为 -1，日志重复出现：

~~~text
transport/internet/reality: REALITY: received real certificate
~~~

这通常不是 30GB 流量配额耗尽，也不代表服务器一定宕机。REALITY 验证失败时，服务端可能回落到目标站点的真实证书，所以客户端会看到这个提示。

### 7.2 本次确认的原因

本次升级后的 Xray 26.7.28 在日志中提示：

~~~text
REALITY: The default minimal client version is Xray-core v26.3.27,
other clients may be refused to connect
~~~

而所有入站在数据库中的 realitySettings.minClientVer 都是空字符串。新版把空值按较新的最低客户端版本处理；旧版 v2rayN 所带的 Xray 核心可能因此无法完成 REALITY 验证。

这是本次基于服务器日志、运行配置和客户端报错的高置信判断；外部客户端仍要通过实际测试确认。

### 7.3 推荐顺序

1. 优先升级 v2rayN 的 Xray-core，让客户端满足新最低版本；
2. 若有旧设备必须兼容，再使用临时兼容配置 minClientVer = "0.0.0"；
3. 不要为了处理一个旧客户端而盲目回滚整个服务器；
4. 当全部客户端都升级后，重新评估是否收紧最低版本。

> [!warning] 兼容模式风险
> Xray 会提示：显式降低 REALITY 的 minClientVer 可能增加 IP 被封锁风险。这是为旧客户端保留兼容性的折中，不是默认安全设置。

### 7.4 只读检查

检查升级后是否触发了默认最低版本：

~~~bash
journalctl -u x-ui --since '30 minutes ago' --no-pager \
  | grep -F 'default minimal client version'
~~~

检查数据库中所有 REALITY 入站的值：

~~~bash
python3 - <<'PY'
import collections
import json
import sqlite3

con = sqlite3.connect('/etc/x-ui/x-ui.db')
values = collections.Counter()
for (raw,) in con.execute('SELECT stream_settings FROM inbounds'):
    setting = json.loads(raw or '{}')
    if setting.get('security') == 'reality':
        value = (setting.get('realitySettings') or {}).get('minClientVer')
        values[value] += 1
for value, count in sorted(values.items(), key=lambda item: str(item[0])):
    print(f'minClientVer={value!r} count={count}')
con.close()
PY
~~~

### 7.5 兼容性修复：先测试，再写数据库

先生成临时配置并让 Xray 校验；这一步不会修改运行中的服务：

~~~bash
python3 - <<'PY'
import json

src = '/usr/local/x-ui/bin/config.json'
dst = '/tmp/xui-reality-compat-test.json'
with open(src, encoding='utf-8') as f:
    config = json.load(f)

changed = 0
for inbound in config.get('inbounds', []):
    stream = inbound.get('streamSettings') or {}
    if stream.get('security') == 'reality':
        reality = stream.setdefault('realitySettings', {})
        reality['minClientVer'] = '0.0.0'
        changed += 1

with open(dst, 'w', encoding='utf-8') as f:
    json.dump(config, f, separators=(',', ':'))
print(f'temporary_config_reality_inbounds={changed}')
PY

/usr/local/x-ui/bin/xray-linux-amd64 run -test -c /tmp/xui-reality-compat-test.json
rm -f /tmp/xui-reality-compat-test.json
~~~

只有看到 Configuration OK. 后，才执行持久化修复：

~~~bash
install -d -m 700 /root/x-ui-backups
cp -a /etc/x-ui/x-ui.db "/root/x-ui-backups/x-ui.db.$(date +%F-%H%M%S)"

python3 - <<'PY'
import json
import sqlite3

db = '/etc/x-ui/x-ui.db'
con = sqlite3.connect(db, timeout=15)
con.execute('PRAGMA busy_timeout=15000')
try:
    con.execute('BEGIN IMMEDIATE')
    changed = []
    for inbound_id, raw in con.execute(
        'SELECT id, stream_settings FROM inbounds ORDER BY id'
    ).fetchall():
        setting = json.loads(raw or '{}')
        if setting.get('security') != 'reality':
            continue
        reality = setting.setdefault('realitySettings', {})
        reality['minClientVer'] = '0.0.0'
        con.execute(
            'UPDATE inbounds SET stream_settings=? WHERE id=?',
            (json.dumps(setting, ensure_ascii=False, separators=(',', ':')), inbound_id),
        )
        changed.append(inbound_id)
    con.commit()
    print('updated_reality_inbound_ids=', changed)
except Exception:
    con.rollback()
    raise
finally:
    con.close()
PY

systemctl restart x-ui
systemctl is-active x-ui
~~~

最后重新运行第 7.4 节的检查，并在 v2rayN 测试一条原有、未重新导入的节点。若仍然失败，保留 v2rayN 测试后的最新日志，再继续分析，不要再次批量修改参数。

## 8. 故障排查顺序

| 现象 | 优先检查 | 不要急着做 |
|---|---|---|
| 所有节点突然很慢 | DMIT 可用流量、套餐重置时间 | 立刻重建节点 |
| 面板打不开 | x-ui 服务状态、日志、面板 URL | 反复改端口或公开面板 |
| 单条节点失效 | 入站启用状态、端口监听、该客户端凭据/到期/流量 | 删除其他正常节点 |
| 全部 REALITY 节点在升级后失效 | Xray 最低客户端版本提示、v2rayN 内核版本 | 直接回滚服务器 |
| 流量不按月重置 | 入站总流量、重置类型、重置日 | 仅看 v2rayN 的本地统计 |

## 9. 当前待办

- [ ] 用 v2rayN 实测一条已有 REALITY 节点，确认兼容性修复是否真正恢复连接。
- [ ] 决定 Backup-01 是否也要改为 30GB、每月 1 日重置。
- [ ] 在所有常用客户端升级 Xray-core 后，评估是否取消 minClientVer = "0.0.0" 的兼容模式。
- [ ] 将面板密码与私钥保存到密码管理器或离线安全位置，不放入本笔记。

## 来源与关联

- 本次服务器只读核验与实际操作记录：2026-08-05。
- [MHSanaei/3x-ui 官方仓库](https://github.com/MHSanaei/3x-ui)
- [3x-ui v3.6.0 发布说明](https://github.com/MHSanaei/3x-ui/releases/tag/v3.6.0)
- [Project X REALITY 配置说明](https://xtls.github.io/en/config/transports/reality.html)
- 旧 Docker 部署参考：[[3XUI搭建]]
- 客户端分流相关流程：81_WorkFlow 工作流/VPS/v2rayN 全局代理应用直连 Skill/
