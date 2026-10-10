---
type: concept
domain: finance-life
status: summarized
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# 钱包链与 Gas 基础

## 一句话说明

多链钱包里要分清三个概念：链、Token、Gas。名字相同的 USDT，在不同链上不是同一笔可直接互通的钱。

## 三个核心概念

| 概念 | 含义 |
|---|---|
| Chain | 链，不同链像不同银行系统 |
| Token | 代币，例如 USDT |
| Gas | 链上手续费，通常用该链原生币支付 |

## 常见链和路费

| 链 | 常见网络名 | Gas |
|---|---|---|
| TRON | TRC20 | TRX |
| Arbitrum | Arbitrum One | ETH |
| Ethereum | ERC20 | ETH |

如果只有 USDT，没有该链的 Gas，转账可能无法发起。

## 最容易错的点

- `0x...` 地址通常是 Ethereum 系列地址，不是 TRON 地址。
- `T...` 地址通常是 TRON 地址。
- 选错网络可能导致资金难以找回。
- 交易所跨链提币前要确认币种、网络、地址三者匹配。
- 旧笔记里的手续费和网络支持可能已经变化。

## 记录原则

- 不在 Wiki 扩散完整地址和账号。
- 具体地址保留在原始私密记录中。
- 每次大额操作前重新核验网络和手续费。
- 小额测试优先于一次性大额操作。

## 来源

- `20_Areas 领域/钱包/教程.md`
- `20_Areas 领域/钱包/买币流程.md`
- `20_Areas 领域/钱包/ChatGPT Plus 充值流程笔记：Fiat24 + 欧易 + Arbitrum.md`

## 相关链接

- [[高风险金融内容核验清单]]
- [[跨境账户与订阅付款流程记录]]
