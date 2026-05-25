# Install Spritegen

One install. Works best on Windows, and gives other AI coding agents a simple rule file or skill folder they can discover.

## One-Liner

After this repo is pushed to GitHub:

```powershell
irm https://raw.githubusercontent.com/usexless/Spritegen/main/install.ps1 | iex
```

Local clone:

```powershell
pwsh .\install.ps1
```

Via npx (Node 18+):

```powershell
npx -y github:usexless/Spritegen
npx -y github:usexless/Spritegen -- --dry-run
```

Preview first:

```powershell
pwsh .\install.ps1 --dry-run
```

## What It Does

- Installs the full Spritegen skill into detected global skill folders for Codex, Claude Code, and Gemini-style setups.
- Adds a tiny marker-fenced Spritegen rule block to Claude/Gemini memory files so those agents know when to use it.
- With `--with-init`, also writes repo-local rules for Cursor, Windsurf, Cline, Copilot, and generic `AGENTS.md`.
- Skips agents that are not detected.
- Safe to re-run. Existing Spritegen marker blocks are replaced, not duplicated.

## Useful Flags

```powershell
pwsh .\install.ps1 --list
pwsh .\install.ps1 --only codex
pwsh .\install.ps1 --only claude --only gemini
pwsh .\install.ps1 --with-init
pwsh .\install.ps1 --uninstall
pwsh .\install.ps1 --dry-run
```

## Providers

| Provider | Install target |
| --- | --- |
| Codex | `%CODEX_HOME%\skills\spritegen` or `~\.codex\skills\spritegen`, plus `~\.codex\AGENTS.md` rule block |
| Claude Code | `%CLAUDE_CONFIG_DIR%\skills\spritegen` or `~\.claude\skills\spritegen`, plus `CLAUDE.md` rule block |
| Gemini | `~\.gemini\skills\spritegen`, plus `GEMINI.md` rule block |
| Cursor | `.cursor\rules\spritegen.mdc` with `--with-init` |
| Windsurf | `.windsurf\rules\spritegen.md` with `--with-init` |
| Cline | `.clinerules\spritegen.md` with `--with-init` |
| Copilot | `.github\copilot-instructions.md` with `--with-init` |
| Generic agents | `AGENTS.md` with `--with-init` |

## Manual Install

Copy `skills/spritegen` into the agent's global skill directory, or tell the agent:

> Read `skills/spritegen/SKILL.md` and use it whenever I ask for generic 2D pixel-art sprites, icons, props, tilesets, VFX sheets, or animation strips.

## Uninstall

```powershell
pwsh .\install.ps1 --uninstall
```

This removes Spritegen-owned skill folders and marker-fenced rule blocks. It does not remove unrelated files or user-written content.
