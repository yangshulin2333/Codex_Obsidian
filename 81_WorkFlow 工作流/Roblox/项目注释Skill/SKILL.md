---
name: learning-architecture-comments
description: 为新项目或已有项目添加学习型架构注释、功能掌握卡和便于后期维护迭代的代码结构。Use when the user asks for "学习型注释", "架构注释", "功能掌握卡", "新项目方便后期迭代", wants AI-generated code to be easier to understand later, or wants comments that explain module responsibilities, data flow, Remote/API boundaries, security risks, and safe modification points.
---

# Learning Architecture Comments

这个 skill 用来让 Codex 写出“方便学习、方便接管、方便以后迭代”的代码。重点不是多写注释，而是在关键位置写有价值的架构注释。

## 核心原则

注释要解释这些问题：

```text
这个模块负责什么？
这个模块不负责什么？
数据从哪里来？
数据在哪里被修改？
哪一侧拥有裁判权？
以后改这里要注意什么风险？
```

不要写只是重复代码的注释：

```text
不要：设置按钮文字
不要：如果 ready 是 true
不要：遍历列表
```

## 新项目工作流

当用户新建项目，并希望代码方便学习和后期迭代时，除非用户明确只要代码，否则同时创建：

```text
PROJECT_WORKFLOW.md       项目结构、模块边界、AI 协作规则
FEATURE_CARD_TEMPLATE.md  功能掌握卡模板
```

每个主要功能都用这张功能掌握卡描述：

```text
功能名：
用户/玩家看到什么：
Client/UI 入口：
Server/Backend 入口：
请求通道：
返回通道：
会修改哪些数据：
配置/真实数据来源：
安全或风险边界：
测试方式：
下一个安全改动：
```

## 注释应该写在哪里

优先在这些位置写注释：

```text
模块/文件顶部：说明职责和边界
主要 public function 前：说明它在功能链路中的职责
Remote/API/Event 边界：说明谁调用谁、谁负责校验
数据修改点：说明为什么这里有权修改数据
DataStore / Payment / Auth：说明失败模式和安全注意点
异步 / 定时 / 防连点 / 重试逻辑：说明为什么需要 delay、debounce、retry
```

避免在这些位置写注释：

```text
简单赋值
明显的 if 判断
普通 UI 文案设置
普通循环
函数名已经说清楚的代码
```

## 注释风格

优先一句话说清楚。用户中文项目优先用中文注释；技术名词保留英文，例如：

```text
RemoteEvent
DataStore
Controller
Service
Feature Card
Client
Server
```

好的注释示例：

```lua
-- RewardController 只负责客户端奖励 UI 状态；真实奖励校验和发放由服务端 RewardService 负责。
local RewardController = {}
```

```lua
-- 客户端只发送“领取奖励”的意图，不传奖励数量，避免玩家伪造奖励数据。
rewardClaimEvent:FireServer()
```

```lua
-- 服务端冷却是安全边界；客户端冷却只用于提升 UI 响应，不能作为发奖依据。
function RewardService.ClaimReward(player)
```

```ts
// AccountService owns persisted account state; UI callers must request changes through validated methods.
export class AccountService {}
```

不好的注释示例：

```lua
-- 设置文字为奖励
button.Text = "奖励"

-- 如果 ready 为 true
if ready then
```

## 生成代码时的规则

写新功能时按这个顺序：

```text
1. 先写功能掌握卡
2. 找到最小可运行功能链路
3. 明确 Client / Server 或 UI / Service 的职责边界
4. 只在职责、数据流、异步、安全边界处加注释
5. 最后说明以后要改这个功能应该从哪里入手
```

Client / Server 项目必须遵守：

```text
Client 只表达意图
Server / Backend 负责校验
Server / Backend 修改可信数据
Client 只展示结果
```

普通应用项目可以转换成：

```text
UI / Controller 收集输入
Domain / Service 校验意图
Repository / Store 修改数据
UI / View 显示结果
```

## 修改已有项目时

先不要盲目加大量注释。按这个顺序处理：

```text
1. 识别主要模块
2. 给每个主要模块顶部补一条职责注释
3. 给主要功能链路补功能掌握卡
4. 只在 Remote/API/DataStore/Payment/数据修改点补边界注释
5. 删除或避免重复代码含义的废话注释
```

## 最终检查

完成后检查：

```text
每个主要模块是否有职责说明？
每个主要功能是否有 Feature Card 或短链路说明？
Remote/API 边界是否说明了谁负责校验？
数据修改点是否说明了权责？
DataStore / Payment / Auth 是否说明风险？
有没有把未完成或占位功能写成已上线？
有没有废话注释污染代码？
```

## 回复用户时

不要把每条注释都列出来。简洁说明：

```text
已按学习型架构注释规范处理：在模块边界、请求/返回边界、数据修改点和风险位置加入了注释，并补充了功能掌握卡。
```

如果某个功能只是占位、原型或评审层，必须明确写出来。
