# Spritegen

Spritegen is a Codex plugin and reusable AI-agent workflow for generic 2D pixel-art assets.

It is intentionally not pet-specific. Use it for sprites, icons, props, tilesets, VFX sheets, item sheets, and simple animation strips. Visual art is generated with an image model; Python scripts handle deterministic setup, slicing, validation, contact sheets, previews, and packaging.

## Install

One line on Windows PowerShell after this repo is on GitHub:

```powershell
irm https://raw.githubusercontent.com/usexless/Spritegen/main/install.ps1 | iex
```

Local clone:

```powershell
pwsh .\install.ps1
```

Dry run:

```powershell
pwsh .\install.ps1 --dry-run
```

NPM/GitHub path:

```powershell
npx -y github:usexless/Spritegen -- --dry-run
```

Full guide: [INSTALL.md](INSTALL.md)

Plugin entry: `.codex-plugin/plugin.json`

Skill entry: `skills/spritegen/SKILL.md`
