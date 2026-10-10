---
type: concept
domain: roblox
status: evergreen
owner: codex
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# Client Server Remote 请求链路

## 一句话说明

Roblox 的关键交互应该是客户端提出请求，服务端校验并决定结果，再把结果返回给客户端显示。

## 最小链路

```text
Client UI 点击
-> Controller 发起请求
-> NetClient / RemoteFunction / RemoteEvent
-> NetService 接住请求
-> 具体 Service 校验 payload
-> DataService 或世界状态更新
-> NetResult 返回
-> Controller 刷新 UI
```

## FirstLoop 示例

```text
FirstLoopController
-> NetClient.Request("FirstLoop.GrantSmallGear", payload)
-> RemoteFunction:InvokeServer(payload)
-> NetService.OnServerInvoke(player, payload)
-> FirstLoopService:_handleGrantSmallGear(player, payload)
-> 返回 result
-> FirstLoopController 刷新 UI
```

## 安全边界

- `player` 是 Roblox 在服务端自动识别的真实玩家。
- `payload` 是客户端传来的数据，必须校验。
- 客户端不能说“给我 999 个奖励”。
- 奖励数量、冷却、权限、资源上限都应由服务端决定。

## RemoteFunction 和 RemoteEvent 的使用感觉

| 类型 | 适合场景 |
|---|---|
| RemoteFunction | 请求后需要立即拿返回值，如领取奖励、查询快照 |
| RemoteEvent | 事件通知或异步同步，如客户端通知动作、服务端广播状态 |

## UI 刷新规则

客户端不要自己猜结果。

正确方式：

```text
服务端返回确认后的资源数量
-> 客户端读取 result.Data
-> UI 显示服务器确认后的数量和文案
```

错误方式：

```text
客户端本地数量 +1
-> 直接显示为真实结果
```

## 错误文案

服务端可以返回英文技术码：

```text
COOLDOWN
PROFILE_NOT_READY
SERVER_ERROR
```

客户端再映射成玩家能看懂的中文文案：

```text
COOLDOWN -> 操作太快了，请稍等
```

## 来源

- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/FirstLoop/第 3 课 RemoteFunction 怎么从 Client 到 Server]]
- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/FirstLoop/第 6 课：Server 返回后 UI 怎么刷新]]
- [[20_Areas 领域/Roblox/框架/项目框架]]

## 相关链接

- [[Roblox 项目架构职责边界]]
- [[DataService 与 DataSchema 边界]]
- [[Feature Pack 与 Feature Card]]

