
## 这次实际用的路线

不是 TRON/TRC20，也不是 imToken 付款。

这次成功路线是：

**欧易交易所 -> 欧易 Web3 钱包 -> Fiat24 -> ChatGPT Plus 扣款**

核心网络：

**Arbitrum One**

核心地址：

`0x85542b09bf9f6644d3b9ac6cf4d420de81e3a75d`

---

## 关键判断

如果地址是：

`0x...`

说明是 **Arbitrum / Ethereum 系列地址**，不是 TRON。

如果是 TRON，地址通常是：

`T...`

这次 Fiat24 用的是：

- 网络：`Arbitrum One`
- 稳定币：`USDT / USD₮0`
- 手续费币：`ETH`
- 不是：`TRX`

---

## 最简流程

### 1. 在欧易买够 USDT

进入欧易交易所，买 USDT。

建议不要刚好买 20 USDT，至少买：

`30 USDT`

因为 Fiat24 兑换会有汇率差，Plus 扣款是 `$20`。

---

### 2. 把 USDT 提到欧易 Web3 钱包

在欧易交易所：

`资产 -> 提币 -> 提取数字货币`

选择：

- 币种：`USDT`
- 网络：`Arbitrum One`
- 地址：欧易 Web3 钱包地址  
  `0x85542b09bf9f6644d3b9ac6cf4d420de81e3a75d`

提交后等待到账。

---

### 3. 准备 Arbitrum ETH 手续费

Fiat24 转换 USDT 时需要 Arbitrum 上的 ETH 当矿工费。

如果签名时提示：

> ETH 不足，无法支付转账所需矿工费

就去欧易交易所提一点 ETH 到同一个钱包地址。

路径：

`资产 -> 提币 -> 提取数字货币`

选择：

- 币种：`ETH`
- 网络：`Arbitrum One`
- 地址：`0x85542b09bf9f6644d3b9ac6cf4d420de81e3a75d`

注意：

**不要选 Ethereum。一定选 Arbitrum One。**

---

### 4. 在 Fiat24 里充值 USD

打开：

`app.fiat24.com`

点首页余额卡片下面的：

`Add`

然后选择：

`Crypto`

Token 选择：

`Tether / USDT`

确认网络是：

`Arbitrum`

输入金额，例如：

`30 USDT`

页面会显示类似：

`Get 29.68 $`

保持：

`Unlimited USDT approval`

关闭即可，不要打开。

然后点：

`Get xx $`

会弹欧易 Web3 钱包签名，确认即可。

可能需要确认 1-2 次：

1. 授权 USDT
2. 兑换/充值到 Fiat24 USD 余额

成功后 Fiat24 余额会增加。

本次成功结果：

- 原余额：`$8.96`
- 充值：`30 USDT`
- 到账：约 `$29.67`
- 最终余额：`$38.63`

---

### 5. 回 ChatGPT 补付账单

打开 ChatGPT：

`设置 -> 账单 / Billing`

找到未支付的 Plus 账单：

`2026年5月19日 US$20.00`

点击：

`查看 / Pay / Retry payment / 更新付款方式`

使用 Fiat24 的 MasterCard 付款。

本次成功结果：

- 商户：`OpenAI OpCo, LLC`
- 金额：`US$20.00`
- 付款日期：`2026年5月22日`
- 支付方式：`MasterCard •••• 2256`
- 状态：`账单已付`

---

## 最容易错的地方

### 不要选 TRON

这次不是 TRON 流程。

不要用：

- `TRON`
- `TRC20`
- `TRX`

TRX 对 Fiat24 / Arbitrum 付款没用。

---

### 提 ETH 时不要选 Ethereum

虽然币种是 ETH，但网络必须是：

`Arbitrum One`

如果选了 `Ethereum`，ETH 会到同一个 `0x` 地址，但在 Ethereum 主网上，Fiat24 的 Arbitrum 交易用不了。

---

### Fiat24 里要点 Add，不是 Send

- `Add`：把链上 USDT 转成 Fiat24 USD 余额
- `Send`：把 Fiat24 余额发出去
- `Forex`：USD/EUR 等法币兑换

充值 Fiat24 余额时，点：

`Add -> Crypto`

不要点：

`Send -> Forex`

---

## 一句话记忆

**买 USDT，Arbitrum One 提到 0x 钱包，补一点 Arbitrum ETH 当路费，Fiat24 点 Add -> Crypto -> USDT，换成 USD 后再付 ChatGPT。**
