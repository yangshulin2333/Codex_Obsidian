---
name: roblox-rojo-project-init
description: Initialize a Roblox Rojo development workflow or explain how to set up a fresh Roblox + Rojo project environment. Use when the user asks to scaffold, initialize, or teach a Roblox Rojo workflow with default.project.json, VS Code recommendations, Rojo serve tasks, Luau starter entry files, Wally/Stylua files, and Comment Translate hover-translation setup. This skill is for development-environment setup, not for creating a default gameplay loop unless the user explicitly asks.
---

# Roblox Rojo Project Init

## Purpose

Use this skill to create a practical Roblox + Rojo development workflow skeleton. The default output should prove that Rojo, VS Code, Luau files, and Studio sync are wired correctly; it should not assume the user's game genre or generate gameplay systems by default.

## Workflow

1. Confirm or infer the project name and target folder.
2. Inspect the target path before writing files.
3. Resolve the skill directory from the current `SKILL.md`, then run `scripts/New-RobloxRojoProject.ps1` from that directory. Do not hardcode a user-specific path such as `C:\Users\...\`.
4. Explain the generated structure in environment-setup order:
   - `default.project.json` maps local files into Roblox Studio.
   - `ReplicatedStorage/Shared` holds shared workflow/config modules.
   - `ServerScriptService/Main.server.luau` verifies server-side Rojo sync.
   - `StarterPlayerScripts/Main.client.luau` verifies client-side Rojo sync.
   - `.vscode` recommends Roblox/Rojo/Luau development extensions and task shortcuts.
5. Do not add a default UI button, reward loop, RemoteEvent loop, DataStore schema, monetization, UGC, Skin, Aura, or real asset pipeline unless the user explicitly asks for that next layer.

## Script

Run the bundled script by resolving it relative to this skill folder:

```powershell
$skillDir = "<path-to-this-skill-folder>"
powershell -ExecutionPolicy Bypass -File "$skillDir\scripts\New-RobloxRojoProject.ps1" -ProjectName "MyGame" -OutputPath "<parent-folder-for-new-projects>"
```

If the user asks from a completely fresh environment, explain that the skill files must exist in that Codex environment before invocation. Create the project in the user-chosen folder, not in a hardcoded path.

Required tools for a fresh Windows Roblox setup:

```text
Roblox Studio
VS Code
Git
Rojo CLI
Rojo Studio plugin
StyLua
```

The script creates:

```text
MyGame/
  default.project.json
  README.md
  .gitignore
  wally.toml
  stylua.toml
  selene.toml
  .vscode/
    extensions.json
    settings.json
    tasks.json
    comment-translate-usage.md
  src/
    ReplicatedStorage/
      Shared/
        GameConfig.luau
        InstanceUtil.luau
    ServerScriptService/
      Main.server.luau
      Services/
    StarterPlayer/
      StarterPlayerScripts/
        Main.client.luau
        ClientModules/
```

## Teaching Rules

- Explain that this scaffold is only for Rojo workflow setup. Gameplay comes after the user chooses a game type.
- Explain `.server.luau`, `.client.luau`, and plain `.luau` whenever the user is learning the generated skeleton.
- Treat `rojo serve` as a local development session that must be restarted after reboot or terminal close.
- Explain the generated VS Code recommendations:
  - `evaera.vscode-rojo`: Rojo project workflow support.
  - `JohnnyMorganz.luau-lsp`: Luau language server for completion and diagnostics.
  - `JohnnyMorganz.stylua`: format Luau/Lua code.
  - `tamasfe.even-better-toml`: edit `wally.toml` cleanly.
  - `ms-vscode.PowerShell`: edit/run helper scripts on Windows.
  - `intellsmi.comment-translate`: translate selected words, comments, strings, and error logs through hover.
- Configure Comment Translate defaults in `.vscode/settings.json`:
  - target language: `zh-CN`
  - hover translation: enabled
  - concise hover mode: disabled, so selection + hover works directly
  - string and hover-content translation: enabled
- Generate `.vscode/comment-translate-usage.md` explaining selection + hover usage and terminal-error workflow.
- Explain the generated VS Code tasks:
  - `Rojo: serve`: start the local Studio sync server.
  - `Rojo: sourcemap`: generate sourcemap for tooling.
  - `StyLua: check src`: verify code formatting.
- Recommend this startup command from the generated project root:

```powershell
rojo serve default.project.json --address 127.0.0.1 --port 34872
```

## Validation

After creating a project, run checks when tools are available:

```powershell
rojo sourcemap default.project.json --output sourcemap.json
stylua --check src
```

If `rojo` or `stylua` is missing, report that clearly and still explain the generated files.

## Optional Reference

If the user asks why the skeleton is shaped this way, read `references/structure-decisions.md`.
