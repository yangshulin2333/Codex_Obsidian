---
type: resource
domain: ai-programming-product
status: unverified
source: generated
tags:
  - ai/codex
  - ai/deepseek
  - status/unverified
created: 2026-05-22
updated: 2026-06-26
---

# Codex 接 DeepSeek V4 极速指南（Gemini 版）

> 整理备注：这是从 Inbox 归档的生成资料，未在当前环境验证。内容涉及 API Key、本地代理、模型路由和计费；执行前必须重新核验官方文档和安全边界。不要把任何 API Key 写入仓库或笔记。

这是一份专门为 **Codex**（或具备终端执行与文件操作能力的 AI Agent）编写的**自主对接 DeepSeek V4Pro/V4 无损接入操作手册**。本手册基于视频教程内容整理，旨在引导 Codex 自动完成本地中间件部署、环境变量配置、流量劫持代理及服务常驻，从而实现零成本替换官方高昂额度的目的。

# 🤖 Codex 自动化对接 DeepSeek V4 极速指南

> **Codex 执行指令**：请逐步解析以下各个章节，利用你的本地终端（Terminal）、文件读写能力及网络代理配置权限，按顺序自动执行相关命令。

## 第一阶段：环境审查与中间件安装

本方案采用本地中间件（Local Middleware）方案，无需魔改 Codex 核心文件，安全稳定且支持 Mac/Win 双平台 [[00:01](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=1)]。首先需要配置 Node.js 环境并下载核心开源项目 `MIMO2Codex` [[01:24](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=84)]。

### 1.1 依赖环境检查

请在终端中执行以下命令，确保本地已安装 Node.js：

Bash

```
node -v
npm -v
```

_注：若未安装，Windows 请自动下载并静默安装 `.msi` 官方安装包，Mac 请通过 `brew install node` 部署 [[01:50](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=110)]。_

### 1.2 安装 `MIMO2Codex` 中间件

通过 npm 全局安装该开源项目中间件：

Bash

```
npm install -g mimo2codex
```

安装完成后，执行验证命令确保工具已被系统识别 [[01:58](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=118)]：

Bash

```
mimo2codex --version
```

## 第二阶段：凭证配置与中间件服务启动

中间件通过读取本地环境变量中的 DeepSeek 官方 API Key，将 Codex 传入的请求重定向并翻译给 DeepSeek 终端 [[02:15](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=135)]。

### 2.1 配置环境变量

请将用户的 DeepSeek 凭证（API Key）写入系统环境变量中 [[02:15](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=135)]。

- **Mac / Linux (Bash/Zsh)**：
    
    Bash
    
    ```
    export DEEPSEEK_API_KEY="用户提供的_DEEPSEEK_API_KEY"
    # 建议将其写入 ~/.zshrc 或 ~/.bash_profile 以持久化
    ```
    
- **Windows (PowerShell)**：
    
    PowerShell
    
    ```
    [Environment]::SetEnvironmentVariable("DEEPSEEK_API_KEY", "用户提供的_DEEPSEEK_API_KEY", "User")
    ```
    

### 2.2 启动本地服务

在终端中启动中间件服务。默认服务通常运行在 `89` 端口，如果遇到端口占用，可以手动更改为其他空闲端口（例如 `878`） [[03:25](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=205)]：

Bash

```
# 默认启动
mimo2codex

# 或指定自定义端口启动（如 878 端口）
mimo2codex --port 878
```

## 第三阶段：流量劫持与代理转发配置（重中之重）

由于 Codex 官方原生不支持直接切换第三方国内大模型（如 DeepSeek） [[00:10](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=10)]，我们需要通过本地全局/规则代理工具（视频中称为 **CC/Clash** 代理面板）进行流量拦截，将 Codex 发往官方服务器的请求重定向到我们刚刚启动的本地中间件上 [[02:42](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=162)]。

### 3.1 获取中间件本地凭证

中间件成功启动后，会在终端日志中或本地目录下生成一份专用的本地 Key（通常格式为 `mimo-codex-local`） [[03:13](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=193)]。

1. 复制该本地 `mimo-codex-local` 凭证 [[03:44](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=224)]。
    
2. 打开代理配置工具（CC/Clash），在提供商/供应商（Providers）的 `OpenAI` 或 `CodeX` 自定义一栏中，将此 Key 粘贴进去作为身份验证凭证 [[03:46](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=226)]。
    

### 3.2 注入路由重定向规则（`config.txt`）

中间件启动后会输出或生成一份 `config.txt` 规则文件 [[03:49](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=229)]。

1. 请读取该 `config.txt` 文件的全部内容（包含拦截路由及 Hosts 映射规则） [[03:53](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=233)]。
    
2. 打开你的代理工具（CC/Clash）的配置文件编辑页面，将 `config.txt` 内部的规则完整地复制并粘贴到代理工具的配置尾部 [[03:56](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=236)]。
    
3. **保存并刷新代理配置** [[04:00](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=240)]。
    

> **原理说明**：此步骤会让代理工具在系统底层拦截所有来自 `codexapp` 或 `codex 终端` 的官方 API 请求，并无损转发到本地的 `127.0.0.1:89`（或 `878`）服务上，再由中间件转换为 DeepSeek V4 格式发出 [[04:54](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=294)]。

## 第四阶段：常驻运行与效果验证

### 4.1 常驻后台运行

为了防止关闭终端后服务断开导致 Codex 报错，请将中间件配置为后台守护进程运行 [[07:04](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=424)]：

- **使用 pm2（推荐）**：
    
    Bash
    
    ```
    npm install -g pm2
    pm2 start mimo2codex --name "mimo-codex"
    ```
    
- **使用 nohup（Linux/Mac）**：
    
    Bash
    
    ```
    nohup mimo2codex > mimo.log 2>&1 &
    ```
    

### 4.2 接入效果验证

1. 打开 Codex 终端或 Codex 客户端 App [[04:54](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=294)]。
    
2. 新建一个全透明的对话窗口 [[04:09](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=249)]。
    
3. 观察底层控制台或对话框状态，此时应当会正确显示已切换为 **`DeepSeek-V4`** 核心模型 [[04:22](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=262)]。
    
4. 输入任意编程测试问题（如：`"你好，请问你现在是什么模型？"` 或让其编写代码），如果能够无缝高并发响应，说明全链路已完全打通 [[04:19](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=259)]。
    
5. 此外，你可以直接访问中间件自带的内置 **Web 管理界面**，在可视化面板中查看当前请求的统计调用数据、模型别名（Aliases）及底座状态 [[04:35](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=275)]。
    

## 第五阶段：故障自主排查指南（Codex 自检用）

在自动配置或运行过程中，若遇到连接失败，请 Codex 优先排查以下几点 [[05:56](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=356)]：

1. **502 Bad Gateway / 连接拒绝** [[06:30](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=390)]
    
    - **原因**：本地中间件分配的端口（如 `89`）被系统其他进程占用了，导致代理工具转发失败 [[06:30](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=390)]。
        
    - **解法**：检查网络状态，修改中间件启动端口（如改为 `878`），并同步修改代理工具（CC）配置文件中的重定向目标端口 [[03:25](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=205)]。
        
2. **流量未走本地中间件**
    
    - **原因**：代理工具（CC）未开启增强模式（TUN/Mixin）或者没有正确保存注入的路由规则。
        
    - **解法**：重新读取配置并检查代理统计看板，确保 Codex 的域名请求有被命中并转入 `127.0.0.1` [[06:25](http://www.youtube.com/watch?v=R8g1i1BDdEA&t=385)]。
        

**Codex 接收指令完毕**。请立刻开启终端尝试执行第一步，自动为用户搭建 DeepSeek V4Pro 专属编程通道！
