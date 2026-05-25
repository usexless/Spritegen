# Spritegen

> **AI-agent workflow for production-ready 2D pixel-art assets.**  
> Sprites · Icons · Tilesets · VFX Strips · Animation Sheets

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Codex](https://img.shields.io/badge/agent-Codex-black?logo=openai)](https://openai.com/codex)
[![Claude Code](https://img.shields.io/badge/agent-Claude%20Code-orange?logo=anthropic)](https://claude.ai/code)
[![Gemini CLI](https://img.shields.io/badge/agent-Gemini%20CLI-blue?logo=google)](https://github.com/google-gemini/gemini-cli)

---

## Install

**One line. Auto-detects your agent.**

```powershell
irm https://raw.githubusercontent.com/usexless/Spritegen/main/install.ps1 | iex
```

```powershell
npx -y github:usexless/Spritegen          # via Node
pwsh .\install.ps1 --dry-run              # preview first
pwsh .\install.ps1 --uninstall            # clean removal
```

Installs into **Codex · Claude Code · Gemini CLI · Cursor · Windsurf · Cline · Copilot · AGENTS.md** — whichever is detected.  
→ Full flag reference: [INSTALL.md](INSTALL.md)

---

## Generic Agent Prompt

No installer? Paste this into any AI agent:

```
Look at the GitHub repo https://github.com/usexless/Spritegen, install the skill
from skills/spritegen into the correct location for this agent, and update SKILL.md
so all script paths point to where you installed them.
```

---

## How It Works

```
concept + references
         │
         ▼
 prepare_sprite_run.py   →  run folder + generation prompt
         │
         ▼
  agent image generator  →  you point your agent at the prompt
         │
         ▼
 record_sprite_result.py →  source image locked into run
         │
         ▼
  slice_asset_sheet.py   →  chroma removal + grid slicing
         │
         ▼
 validate + contact sheet + GIF/MP4 preview + package/
```

**Rule:** image model makes the art. Scripts enforce the pipeline. Nothing is faked locally.

---

## Image Generation

| Agent | Method |
|---|---|
| **Codex** | `$imagegen` — built-in, zero config |
| **Antigravity** | Built-in — zero config |
| **Gemini CLI** | [Nano Banana](https://github.com/gemini-cli-extensions/nanobanana) extension |
| **Claude Code** | Image-gen MCP — [Pixa](https://pixa.ai) · [image-gen-mcp](https://github.com/lansespirit/image-gen-mcp) |
| **Other** | Any available image generation tool |

If no image tool is found, Spritegen **pauses and tells you** — it never fabricates art with local scripts.

---

## Output

Every run produces a self-contained, game-ready package:

```
run/
├── sprite_request.json        metadata + provenance
├── prompts/generation-prompt.txt
├── source/source.png          original generated image
├── slices/cell-r00-c00.png    individual cells, transparent PNG
├── final/sheet.png            cleaned full sheet
├── final/manifest.json
├── qa/contact-sheet.png       visual QA grid
├── qa/review.json             geometry + alpha report
├── preview/preview.gif
├── preview/preview.mp4
└── package/                   ready-to-ship bundle
```

---

## Requirements

| Requirement | Notes |
|---|---|
| PowerShell 5.1+ or 7+ | For the installer |
| Python 3.10+ | For the pipeline scripts |
| Pillow | `pip install -r requirements.txt` |
| ffmpeg | Optional — MP4 previews only (GIF works without it) |

The installer warns automatically if Python or Pillow is missing.
