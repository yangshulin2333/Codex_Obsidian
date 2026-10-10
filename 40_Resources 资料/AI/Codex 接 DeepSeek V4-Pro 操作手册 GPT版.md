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

# Codex 接 DeepSeek V4-Pro 操作手册（GPT 版）

> 整理备注：这是从 Inbox 归档的生成资料，未在当前环境验证。内容涉及 API Key、本地代理、模型路由和计费；执行前必须重新核验官方文档和安全边界。不要把任何 API Key 写入仓库或笔记。

下面这份不是逐字视频稿。我当前无法可靠读取该 YouTube 视频字幕，所以不会假装已经逐字看完。下面手册按你给的视频目标，结合 **DeepSeek 官方 Codex 集成文档、OpenAI Codex 官方文档、Moon Bridge 项目说明**整理，重点是：**让 Codex CLI 通过本地协议转换层自主接入 DeepSeek V4-Pro**。

---

# Codex 接入 DeepSeek V4-Pro 操作手册

## 0. 核心结论

**Codex 不能像 Claude Code 那样直接改 `ANTHROPIC_BASE_URL` 就接入 DeepSeek。**

原因是：

- **Codex CLI 主要通过 OpenAI Responses API 工作**。
    
- DeepSeek 官方提供的是 **OpenAI Chat Completions API** 和 **Anthropic API** 兼容能力。
    
- 所以 Codex 接 DeepSeek V4-Pro，需要一个中间层，把 Codex 的 **OpenAI Responses API 请求**转换成 DeepSeek 能理解的上游协议。
    
- DeepSeek 官方 Codex 集成文档推荐使用 **Moon Bridge** 做这个转发/转换层。Codex 请求本地 `Moon Bridge`，Moon Bridge 再转发到 DeepSeek V4-Pro。([GitHub](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md "awesome-deepseek-agent/docs/codex.md at main · deepseek-ai/awesome-deepseek-agent · GitHub"))
    

整体结构是：

```text
Codex CLI
  ↓ OpenAI Responses API
http://127.0.0.1:38440/v1/responses
  ↓
Moon Bridge 本地代理
  ↓ Anthropic-compatible API
DeepSeek API
  ↓
deepseek-v4-pro
```

---

## 1. 这个方案解决什么问题

你的问题是：**Codex 额度不够了，但还想继续让 coding agent 帮你改项目。**

这个方案解决的是：

|问题|解决方式|
|---|---|
|Codex 默认消耗 OpenAI/ChatGPT Codex 额度|让 Codex CLI 的模型请求转发到 DeepSeek|
|DeepSeek 不是原生 Codex Responses API|用 Moon Bridge 做协议转换|
|仍想保留 Codex 的终端操作体验|继续使用 Codex CLI，只换后端模型|
|想用更便宜的大模型跑代码任务|使用 `deepseek-v4-pro`|

需要注意：这不是“免费无限 Codex”。这是**用 Codex CLI 作为本地 coding agent 壳子，用 DeepSeek API 作为模型后端**。DeepSeek API 仍然需要 API Key 和余额。

---

## 2. DeepSeek V4-Pro 简要背景

DeepSeek 官方在 2026 年 4 月 24 日发布 DeepSeek-V4 Preview，包含：

|模型|定位|官方描述|
|---|---|---|
|`deepseek-v4-pro`|主力高能力模型|1.6T total / 49B active params，面向强推理、数学、编程、Agent 任务|
|`deepseek-v4-flash`|快速低成本模型|284B total / 13B active params，适合更快、更便宜的常规任务|

DeepSeek 官方说明 V4 支持 **1M context**，并支持 **OpenAI ChatCompletions API** 与 **Anthropic API**。这也是为什么 Claude Code 可以直接走 Anthropic 兼容接口，而 Codex 需要 Moon Bridge 适配 Responses API。([DeepSeek API 文档](https://api-docs.deepseek.com/news/news260424 "DeepSeek V4 Preview Release | DeepSeek API Docs"))

---

# Part A：给人的安装手册

## 3. 前置要求

需要先准备：

|工具|用途|要求|
|---|---|---|
|Node.js|安装 Codex CLI|Node.js 18+|
|npm|安装 Codex CLI|跟随 Node.js|
|Go|编译/运行 Moon Bridge|Go 1.25+|
|Git|拉取 Moon Bridge 仓库|任意新版本|
|DeepSeek API Key|调用 DeepSeek V4-Pro|从 DeepSeek Platform 创建|
|Codex CLI|本地 coding agent|`@openai/codex`|

DeepSeek 官方 Codex 集成文档列出的要求是 Node.js 18+、Go 1.25+，并通过 npm 安装 Codex CLI。([GitHub](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md "awesome-deepseek-agent/docs/codex.md at main · deepseek-ai/awesome-deepseek-agent · GitHub"))

---

## 4. 检查本机环境

### macOS / Linux / WSL

```bash
node -v
npm -v
go version
git --version
codex --version
```

如果 `codex --version` 没有结果，安装 Codex CLI：

```bash
npm install -g @openai/codex
```

OpenAI 官方文档也说明 Codex CLI 可以通过 npm 安装，并且 Codex CLI 可以在本地读取、修改、运行所选目录中的代码。([OpenAI 开发者](https://developers.openai.com/codex/cli?utm_source=chatgpt.com "Codex CLI"))

---

### Windows PowerShell

```powershell
node -v
npm -v
go version
git --version
codex --version
```

如果没有 Codex：

```powershell
npm install -g @openai/codex
```

---

## 5. 创建 DeepSeek API Key

操作：

1. 打开 DeepSeek Platform。
    
2. 进入 API Keys。
    
3. 创建一个新的 API Key。
    
4. 复制并保存，格式通常类似：
    

```text
sk-xxxxxxxxxxxxxxxx
```

DeepSeek 官方 Codex 集成文档明确要求先创建 DeepSeek API Key。([GitHub](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md "awesome-deepseek-agent/docs/codex.md at main · deepseek-ai/awesome-deepseek-agent · GitHub"))

安全要求：

```text
不要把 API Key 写进你的项目仓库。
不要 commit 到 GitHub。
不要发给别人。
不要截图发到群里。
```

---

## 6. 拉取 Moon Bridge

在你专门放工具的目录执行：

```bash
git clone https://github.com/ZhiYi-R/moon-bridge.git
cd moon-bridge
```

Moon Bridge 是一个 Go 写的协议转换与模型路由代理，对外暴露 OpenAI Responses API，内部可以转发到 Anthropic Messages、Google Gemini、OpenAI Chat Completions 等协议。它的 README 也写明了可以和 Codex CLI 配合使用。([GitHub](https://github.com/ZhiYi-R/moon-bridge "GitHub - ZhiYi-R/moon-bridge: Moon Bridge 是一个用 Go 编写的协议转换与模型路由代理。对外暴露 OpenAI Responses API（/v1/responses），对内支持 Anthropic Messages、Google Gemini（GenAI）、OpenAI Chat Completions 等多种上游协议。客户端指定不同模型别名时，自动将请求路由到对应上游 Provider 并在协议间自动转换。 · GitHub"))

---

## 7. 创建 `config.yml`

在 `moon-bridge` 目录下创建：

```bash
nano config.yml
```

或者 Windows 用：

```powershell
notepad config.yml
```

填入下面内容，把 `sk-your-deepseek-api-key` 换成你的真实 DeepSeek API Key：

```yaml
mode: "Transform"

server:
  addr: "127.0.0.1:38440"

provider:
  providers:
    deepseek:
      base_url: "https://api.deepseek.com/anthropic"
      api_key: "sk-your-deepseek-api-key"
      models:
        deepseek-v4-pro:
          context_window: 1000000
          max_output_tokens: 384000
          extensions:
            deepseek_v4:
              enabled: true
          default_reasoning_level: "high"
          supported_reasoning_levels:
            - effort: "high"
              description: "High reasoning effort"
            - effort: "xhigh"
              description: "Extra high reasoning effort"
          supports_reasoning_summaries: true
          default_reasoning_summary: "auto"

  routes:
    moonbridge:
      to: "deepseek/deepseek-v4-pro"

  default_model: "moonbridge"
```

这段配置来自 DeepSeek 官方 Codex 集成文档的最小配置逻辑：开启 DeepSeek V4-Pro、设置 1M context、启用 DeepSeek V4 compatibility extension，并把 Codex 使用的模型别名 `moonbridge` 路由到 `deepseek/deepseek-v4-pro`。([GitHub](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md "awesome-deepseek-agent/docs/codex.md at main · deepseek-ai/awesome-deepseek-agent · GitHub"))

---

## 8. 启动 Moon Bridge

在 `moon-bridge` 目录下运行：

```bash
go run ./cmd/moonbridge -config config.yml
```

或者：

```bash
go run ./cmd/moonbridge --config config.yml
```

启动后不要关闭这个终端窗口。

它应该监听：

```text
127.0.0.1:38440
```

并暴露：

```text
http://127.0.0.1:38440/v1/responses
```

DeepSeek 官方文档也说明 Moon Bridge 默认监听 `127.0.0.1:38440`，并提供 OpenAI Responses-compatible endpoint。([GitHub](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md "awesome-deepseek-agent/docs/codex.md at main · deepseek-ai/awesome-deepseek-agent · GitHub"))

---

## 9. 验证 Moon Bridge 是否启动成功

另开一个终端。

执行：

```bash
curl http://127.0.0.1:38440/v1/models
```

再执行一个 Responses 测试：

```bash
curl http://127.0.0.1:38440/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "moonbridge",
    "input": "Say hello in one short sentence.",
    "max_output_tokens": 100
  }'
```

如果正常，应该返回模型响应。DeepSeek 官方文档也给了类似的 `/v1/models` 和 `/v1/responses` 验证方式。([GitHub](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md "awesome-deepseek-agent/docs/codex.md at main · deepseek-ai/awesome-deepseek-agent · GitHub"))

---

## 10. 生成 Codex 配置

Codex 的用户配置默认在：

```text
~/.codex/config.toml
```

OpenAI 官方文档说明 Codex 的用户级配置文件位于 `~/.codex/config.toml`，项目级也可以使用 `.codex/config.toml`。配置优先级依次是 CLI 参数、profile、项目配置、用户配置、系统配置、内置默认值。([OpenAI 开发者](https://developers.openai.com/codex/config-basic "Config basics – Codex | OpenAI Developers"))

在第二个终端中，仍然位于 `moon-bridge` 目录，执行：

```bash
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$CODEX_HOME_DIR"

if [ -f "$CODEX_HOME_DIR/config.toml" ]; then
  cp "$CODEX_HOME_DIR/config.toml" "$CODEX_HOME_DIR/config.toml.backup.$(date +%Y%m%d-%H%M%S)"
fi

MODEL="$(go run ./cmd/moonbridge --config config.yml --print-codex-model)"

go run ./cmd/moonbridge \
  --config config.yml \
  --print-codex-config "$MODEL" \
  --codex-base-url "http://127.0.0.1:38440/v1" \
  --codex-home "$CODEX_HOME_DIR" \
  > "$CODEX_HOME_DIR/config.toml"
```

这个步骤会写入：

```text
~/.codex/config.toml
~/.codex/models_catalog.json
```

DeepSeek 官方文档说明，生成的 `config.toml` 会让 Codex 使用 `wire_api = "responses"`，`models_catalog.json` 则提供模型能力元数据，例如 context window、reasoning levels、tool support。([GitHub](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md "awesome-deepseek-agent/docs/codex.md at main · deepseek-ai/awesome-deepseek-agent · GitHub"))

---

## 11. 启动 Codex

进入你的项目目录：

```bash
cd /path/to/my-project
CODEX_HOME="$CODEX_HOME_DIR" codex --cd "$PWD"
```

如果你已经在项目目录：

```bash
CODEX_HOME="$HOME/.codex" codex --cd "$PWD"
```

DeepSeek 官方文档说明，此时 Codex 会把 OpenAI Responses 请求发送给 Moon Bridge，然后 Moon Bridge 路由到 DeepSeek V4。([GitHub](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md "awesome-deepseek-agent/docs/codex.md at main · deepseek-ai/awesome-deepseek-agent · GitHub"))

---

## 12. 在 Codex 里测试

进入 Codex 后，先让它做非常小的任务：

```text
Please confirm which model backend is configured. Then read the current directory structure only. Do not modify files yet.
```

再让它做一个安全测试：

```text
Create a temporary file named codex_deepseek_test.txt with one line: "Codex is routed through Moon Bridge to DeepSeek V4-Pro." Then show the diff and ask me before committing or deleting anything.
```

观察 Moon Bridge 那个终端窗口，应该能看到类似：

```text
POST /v1/responses
```

DeepSeek 官方文档也把 Moon Bridge 终端中的 `POST /v1/responses` 日志作为验证依据。([GitHub](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md "awesome-deepseek-agent/docs/codex.md at main · deepseek-ai/awesome-deepseek-agent · GitHub"))

---

# Part B：直接给 Codex 看的任务说明

下面这段可以直接复制给 Codex，让它自主检查、安装和配置。

````markdown
# Task: Configure Codex CLI to use DeepSeek V4-Pro through Moon Bridge

## Objective

Configure this machine so that Codex CLI can route model requests to DeepSeek V4-Pro through Moon Bridge.

Codex speaks OpenAI Responses API. DeepSeek V4-Pro does not need to be called directly by Codex. Use Moon Bridge as the local forwarding/conversion layer:

Codex CLI
-> http://127.0.0.1:38440/v1/responses
-> Moon Bridge
-> https://api.deepseek.com/anthropic
-> deepseek-v4-pro

## Hard constraints

1. Do not delete existing Codex config.
2. Before editing `~/.codex/config.toml`, create a timestamped backup.
3. Never print, commit, or expose the DeepSeek API key.
4. Do not write secrets into the user's project repository.
5. Keep Moon Bridge outside the project repository unless the user explicitly says otherwise.
6. Validate each step before moving to the next.
7. If a command fails, stop and explain the exact error and suggested fix.
8. Do not make unrelated changes to the user's codebase.

## Required tools

Check these first:

```bash
node -v
npm -v
go version
git --version
codex --version
````

Requirements:

- Node.js 18+
    
- Go 1.25+
    
- Git
    
- Codex CLI
    
- DeepSeek API Key
    

If Codex CLI is missing:

```bash
npm install -g @openai/codex
```

## Step 1: Ask user for DeepSeek API Key securely

Ask the user to provide the DeepSeek API key only through a secure local input method.

Do not save the key in the project repository.

## Step 2: Clone Moon Bridge

Choose a safe tools directory, for example:

```bash
mkdir -p "$HOME/ai-tools"
cd "$HOME/ai-tools"
git clone https://github.com/ZhiYi-R/moon-bridge.git
cd moon-bridge
```

If the folder already exists:

```bash
cd "$HOME/ai-tools/moon-bridge"
git pull
```

## Step 3: Create Moon Bridge config

Create `config.yml` inside the Moon Bridge directory.

Use this template and replace only the API key placeholder:

```yaml
mode: "Transform"

server:
  addr: "127.0.0.1:38440"

provider:
  providers:
    deepseek:
      base_url: "https://api.deepseek.com/anthropic"
      api_key: "sk-your-deepseek-api-key"
      models:
        deepseek-v4-pro:
          context_window: 1000000
          max_output_tokens: 384000
          extensions:
            deepseek_v4:
              enabled: true
          default_reasoning_level: "high"
          supported_reasoning_levels:
            - effort: "high"
              description: "High reasoning effort"
            - effort: "xhigh"
              description: "Extra high reasoning effort"
          supports_reasoning_summaries: true
          default_reasoning_summary: "auto"

  routes:
    moonbridge:
      to: "deepseek/deepseek-v4-pro"

  default_model: "moonbridge"
```

## Step 4: Start Moon Bridge

Run:

```bash
go run ./cmd/moonbridge -config config.yml
```

Keep this terminal open.

Expected local endpoint:

```text
http://127.0.0.1:38440/v1/responses
```

## Step 5: Verify Moon Bridge

In another terminal:

```bash
curl http://127.0.0.1:38440/v1/models
```

Then:

```bash
curl http://127.0.0.1:38440/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "moonbridge",
    "input": "Say hello in one short sentence.",
    "max_output_tokens": 100
  }'
```

Expected result:

- `/v1/models` returns available model metadata.
    
- `/v1/responses` returns a short model response.
    
- Moon Bridge terminal shows a `POST /v1/responses` request.
    

## Step 6: Generate Codex configuration

Run from the Moon Bridge directory:

```bash
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$CODEX_HOME_DIR"

if [ -f "$CODEX_HOME_DIR/config.toml" ]; then
  cp "$CODEX_HOME_DIR/config.toml" "$CODEX_HOME_DIR/config.toml.backup.$(date +%Y%m%d-%H%M%S)"
fi

MODEL="$(go run ./cmd/moonbridge --config config.yml --print-codex-model)"

go run ./cmd/moonbridge \
  --config config.yml \
  --print-codex-config "$MODEL" \
  --codex-base-url "http://127.0.0.1:38440/v1" \
  --codex-home "$CODEX_HOME_DIR" \
  > "$CODEX_HOME_DIR/config.toml"
```

After this, verify:

```bash
ls -la "$CODEX_HOME_DIR"
cat "$CODEX_HOME_DIR/config.toml"
```

Do not print secrets.

Expected files:

```text
~/.codex/config.toml
~/.codex/models_catalog.json
```

## Step 7: Start Codex against a project

Go to the user's project directory:

```bash
cd /path/to/project
CODEX_HOME="$HOME/.codex" codex --cd "$PWD"
```

Inside Codex, test with:

```text
Confirm that you can read the project directory. Do not modify any files yet. Then explain which configured model/provider you are using.
```

## Step 8: Final verification

Create a safe temporary test file only after user approval:

```text
Create codex_deepseek_test.txt with one line confirming that Codex is routed through Moon Bridge to DeepSeek V4-Pro. Show the diff. Do not commit.
```

Check:

- Codex responds normally.
    
- Moon Bridge terminal logs `POST /v1/responses`.
    
- No OpenAI/Codex quota should be used for model inference if routing is correct.
    
- DeepSeek API usage/balance may change.
    

## Troubleshooting

### Error: connection refused

Likely cause:

- Moon Bridge is not running.
    
- Wrong port.
    
- `config.yml` uses another address.
    

Check:

```bash
curl http://127.0.0.1:38440/v1/models
```

Restart:

```bash
go run ./cmd/moonbridge -config config.yml
```

### Error: Codex cannot see model

Likely cause:

- `models_catalog.json` was not generated.
    
- `config.toml` was not regenerated.
    
- Wrong `CODEX_HOME`.
    

Fix:

```bash
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
MODEL="$(go run ./cmd/moonbridge --config config.yml --print-codex-model)"

go run ./cmd/moonbridge \
  --config config.yml \
  --print-codex-config "$MODEL" \
  --codex-base-url "http://127.0.0.1:38440/v1" \
  --codex-home "$CODEX_HOME_DIR" \
  > "$CODEX_HOME_DIR/config.toml"
```

### Error: 401 authentication error

Likely cause:

- DeepSeek API key is wrong.
    
- API key has hidden spaces.
    
- API key was revoked.
    

Fix:

- Recreate DeepSeek API key.
    
- Update `config.yml`.
    
- Restart Moon Bridge.
    

### Error: 402 payment / insufficient balance

Likely cause:

- DeepSeek account has no balance.
    
- Billing not enabled.
    

Fix:

- Check DeepSeek Platform balance.
    
- Recharge or use another valid key.
    

### Error: port 38440 already in use

macOS/Linux:

```bash
lsof -i :38440
```

Windows PowerShell:

```powershell
netstat -ano | findstr 38440
```

Either stop the process using the port or change:

```yaml
server:
  addr: "127.0.0.1:38441"
```

Then regenerate Codex config with:

```bash
--codex-base-url "http://127.0.0.1:38441/v1"
```

### Error: model output is truncated

Possible causes:

- `max_output_tokens` too low.
    
- Model/provider has output limit.
    
- Task is too large.
    

Fix:

- Split tasks.
    
- Ask Codex to work in checkpoints.
    
- Avoid giving the whole repo when only a few files are needed.
    

### Error: Codex edits unexpected files

Fix:

- Stop the session.
    
- Revert with Git.
    
- Add an `AGENTS.md` with explicit rules.
    
- Use smaller prompts and ask Codex to show a plan before editing.
    

## Completion criteria

The setup is complete only when:

1. `curl http://127.0.0.1:38440/v1/models` works.
    
2. `curl http://127.0.0.1:38440/v1/responses` works.
    
3. `~/.codex/config.toml` points to Moon Bridge.
    
4. `~/.codex/models_catalog.json` exists.
    
5. Codex can start inside a project.
    
6. Moon Bridge logs `POST /v1/responses` when Codex sends a message.
    
7. A safe temporary test file can be created and diffed by Codex.
    

````

---

# Part C：给项目仓库用的 `AGENTS.md`

为了让 Codex 后续别乱改，可以在你的项目根目录放一个 `AGENTS.md`。Codex 会读取项目中的 `AGENTS.md` 作为项目规则；OpenAI 的 Codex agent loop 说明中也提到，Codex 会聚合 `AGENTS.md` / `AGENTS.override.md` 等项目说明进入上下文。:contentReference[oaicite:13]{index=13}

你可以放：

```markdown
# AGENTS.md

## Project rules

1. Do not modify files unrelated to the current task.
2. Before editing, inspect the relevant directory structure.
3. Before large changes, produce a short implementation plan.
4. After editing, show a diff summary.
5. Do not commit unless the user explicitly asks.
6. Do not delete existing code unless the replacement is verified.
7. Do not expose API keys, tokens, secrets, or local config values.
8. Never commit `.env`, `config.yml`, `~/.codex/config.toml`, or DeepSeek API keys.
9. For coding tasks, prefer small checkpoints.
10. For setup tasks, verify each command before continuing.

## DeepSeek / Moon Bridge setup rules

This project may use Codex CLI routed through Moon Bridge to DeepSeek V4-Pro.

Expected route:

Codex CLI
-> http://127.0.0.1:38440/v1/responses
-> Moon Bridge
-> DeepSeek Anthropic-compatible API
-> deepseek-v4-pro

Before assuming the model works, verify:

```bash
curl http://127.0.0.1:38440/v1/models
````

Do not edit Moon Bridge config unless the user asks.  
Do not print the DeepSeek API key.  
Do not place the DeepSeek API key inside this repository.

````

---

# Part D：常见误区

## 误区 1：把 DeepSeek API URL 直接填进 Codex

不建议直接这样做。

Codex 需要的是 Responses API 兼容接口。OpenAI 官方文档说明 Codex 可以指向支持 Chat Completions 或 Responses API 的模型/供应商，但 Chat Completions 支持已被标注为 deprecated，未来会从 Codex 移除。:contentReference[oaicite:14]{index=14}

所以更稳的路线是：

```text
Codex -> Moon Bridge Responses API -> DeepSeek Anthropic API
````

---

## 误区 2：把 Claude Code 教程原样套到 Codex

Claude Code 教程常见配置是：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "sk-xxx",
    "ANTHROPIC_MODEL": "deepseek-v4-pro[1m]"
  }
}
```

这适合 Claude Code，因为 Claude Code 本身使用 Anthropic 协议。但 Codex 的主链路是 Responses API，所以不要直接照搬 Claude Code 的配置。

---

## 误区 3：把 DeepSeek Key 写到项目里

不要这样做：

```text
my-roblox-project/config.yml
my-roblox-project/.env
my-roblox-project/README.md
```

更合理：

```text
~/ai-tools/moon-bridge/config.yml
~/.codex/config.toml
```

并且不要提交这些文件。

---

## 误区 4：认为接入后完全不用花钱

不是。

这个方案只是让模型调用从 OpenAI/Codex 后端转到 DeepSeek API。DeepSeek API 仍然按量计费，并且需要余额。

---

# Part E：最小可执行流程

只看这一段也能跑通：

```bash
# 1. Install Codex CLI if missing
npm install -g @openai/codex

# 2. Clone Moon Bridge
mkdir -p "$HOME/ai-tools"
cd "$HOME/ai-tools"
git clone https://github.com/ZhiYi-R/moon-bridge.git
cd moon-bridge

# 3. Create config.yml manually
nano config.yml

# 4. Start Moon Bridge
go run ./cmd/moonbridge -config config.yml

# 5. Open another terminal and verify
curl http://127.0.0.1:38440/v1/models

# 6. Generate Codex config
cd "$HOME/ai-tools/moon-bridge"

CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$CODEX_HOME_DIR"

if [ -f "$CODEX_HOME_DIR/config.toml" ]; then
  cp "$CODEX_HOME_DIR/config.toml" "$CODEX_HOME_DIR/config.toml.backup.$(date +%Y%m%d-%H%M%S)"
fi

MODEL="$(go run ./cmd/moonbridge --config config.yml --print-codex-model)"

go run ./cmd/moonbridge \
  --config config.yml \
  --print-codex-config "$MODEL" \
  --codex-base-url "http://127.0.0.1:38440/v1" \
  --codex-home "$CODEX_HOME_DIR" \
  > "$CODEX_HOME_DIR/config.toml"

# 7. Start Codex in project
cd /path/to/my-project
CODEX_HOME="$CODEX_HOME_DIR" codex --cd "$PWD"
```

---

# Part F：你现在应该怎么用这份手册

最省额度的做法：

1. 先自己把 **Part A** 跑到 Moon Bridge 成功启动。
    
2. 把 **Part B** 整段复制给 Codex。
    
3. 让 Codex 只做配置验证，不要一上来就改项目。
    
4. 验证 `POST /v1/responses` 出现在 Moon Bridge 终端后，再让 Codex 开始处理 Roblox 项目或其他代码任务。
    

最关键的一句话是：

```text
Codex 接 DeepSeek V4-Pro，不是直接改 ANTHROPIC_BASE_URL，而是用 Moon Bridge 把 Codex 的 Responses API 请求转换后转发给 DeepSeek。
```
