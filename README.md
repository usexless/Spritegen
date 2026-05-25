# Spritegen

**AI-agent workflow for clean 2D pixel-art assets.**

Works with Codex, Claude Code, Gemini CLI, Antigravity, Cursor, Windsurf, Cline, GitHub Copilot, and generic `AGENTS.md` agents.

Use it for:

- item icons
- props and pickups
- tilesets
- object sheets
- simple character sprites
- VFX frame strips
- animation previews
- contact sheets and QA packages

Visual art comes from the image generator built into or connected to your agent. Spritegen's scripts handle the deterministic parts: prompts, source recording, grid slicing, alpha/chroma cleanup, validation, contact sheets, GIF/MP4 previews, and packaging.

## Install

**Windows — one-liner:**

```powershell
irm https://raw.githubusercontent.com/usexless/Spritegen/main/install.ps1 | iex
```

**Local clone:**

```powershell
pwsh .\install.ps1
```

**Preview before installing:**

```powershell
pwsh .\install.ps1 --dry-run
```

**Via npx (Node 18+):**

```powershell
npx -y github:usexless/Spritegen -- --dry-run
npx -y github:usexless/Spritegen
```

Full install guide: [INSTALL.md](INSTALL.md)

## What Installs

Spritegen auto-detects supported agent locations and installs only what fits your machine.

| Agent | Skill folder | Rule file |
| --- | --- | --- |
| Codex | `~/.codex/skills/spritegen` | `~/.codex/AGENTS.md` |
| Claude Code | `~/.claude/skills/spritegen` | `~/.claude/CLAUDE.md` |
| Gemini CLI | `~/.gemini/skills/spritegen` | `~/.gemini/GEMINI.md` |
| Cursor | — | `.cursor/rules/spritegen.mdc` with `--with-init` |
| Windsurf | — | `.windsurf/rules/spritegen.md` with `--with-init` |
| Cline | — | `.clinerules/spritegen.md` with `--with-init` |
| Copilot | — | `.github/copilot-instructions.md` with `--with-init` |
| Generic agents | — | `AGENTS.md` with `--with-init` |

Useful commands:

```powershell
pwsh .\install.ps1 --list                       # see what's detected
pwsh .\install.ps1 --dry-run                    # preview without writing
pwsh .\install.ps1 --only codex                 # single target
pwsh .\install.ps1 --only claude --only gemini  # two targets
pwsh .\install.ps1 --with-init                  # also write repo-local rules
pwsh .\install.ps1 --uninstall                  # remove everything Spritegen wrote
```

Safe to re-run. Spritegen marker blocks are replaced, not duplicated.

## Image Generation Support

Spritegen works with whichever image generator your agent has. It reads the generation prompt from `prompts/generation-prompt.txt` and passes it to the tool — it never fabricates art locally.

| Agent | Image generation |
| --- | --- |
| **Codex** | `$imagegen` built-in — works out of the box |
| **Antigravity** | Built-in image generation — works out of the box |
| **Gemini CLI** | [Nano Banana extension](https://github.com/gemini-cli-extensions/nanobanana): `gemini extension install nanobanana`, then `/generate` |
| **Claude Code** | Any image-gen MCP: [Pixa](https://pixa.ai), [image-gen-mcp](https://github.com/lansespirit/image-gen-mcp), or similar. Install one and Claude will find it. |
| **Other agents** | Use whatever image generation tool is available in the agent |

If no image tool is found, Spritegen pauses and tells you what is missing instead of making something up.

## How It Works

```text
concept / references
        |
        v
prepare_sprite_run.py   ← creates run folder + generation prompt
        |
        v
agent image generator   ← you or your agent calls this
        |
        v
record_sprite_result.py ← copies generated image into run
        |
        v
slice_asset_sheet.py    ← removes chroma key, slices grid cells
        |
        v
validate_sprite_assets.py
        |
        v
contact sheet + preview GIF/MP4 + package
```

The important split:

- Image model creates the art.
- Python scripts enforce the asset pipeline.
- Scripts do not fake or locally draw final art.

## Example

Prepare a 4-frame pixel VFX strip (replace `$skill` with your agent's skill path):

```powershell
# Codex
$skill = "$HOME\.codex\skills\spritegen"

# Claude Code
$skill = "$HOME\.claude\skills\spritegen"

# Gemini CLI
$skill = "$HOME\.gemini\skills\spritegen"
```

```powershell
$run = "$PWD\runs\coin-sparkle"

python "$skill\scripts\prepare_sprite_run.py" `
  --name "Coin Sparkle" `
  --kind animation `
  --concept "four-frame golden coin sparkle loop for a 2D platformer" `
  --output-dir "$run" `
  --grid 4x1 `
  --cell-size 32x32 `
  --force
```

Then pass the generated prompt to your agent's image generator:

```text
runs/coin-sparkle/prompts/generation-prompt.txt
```

Record and process:

```powershell
python "$skill\scripts\record_sprite_result.py" --run-dir "$run" --source "path\to\generated.png"
python "$skill\scripts\slice_asset_sheet.py"    --run-dir "$run"
python "$skill\scripts\validate_sprite_assets.py" --run-dir "$run"
python "$skill\scripts\make_asset_contact_sheet.py" --run-dir "$run"
python "$skill\scripts\render_asset_preview.py" --run-dir "$run" --fps 8
python "$skill\scripts\package_sprite_assets.py" --run-dir "$run"
```

## Output

A finished run looks like:

```text
run/
  sprite_request.json
  prompts/generation-prompt.txt
  references/layout-guide.png
  source/source.png
  slices/*.png
  final/sheet.png
  final/manifest.json
  qa/contact-sheet.png
  qa/review.json
  preview/preview.gif
  preview/preview.mp4
  package/
```

## Style Target

Spritegen defaults to:

- readable 2D pixel-art-adjacent assets
- chunky silhouettes
- hard edges
- limited palettes
- flat cel-like shading
- consistent pixel scale
- transparent or chroma-key-clean backgrounds

Avoid:

- painterly illustration
- 3D renders
- glossy app icons
- soft gradients
- noisy texture
- text labels
- scenery backgrounds
- clipped or overlapping grid cells

## Requirements

- Windows PowerShell 5.1+ or PowerShell 7+
- Python 3.10+
- Pillow:

```powershell
pip install -r requirements.txt
```

The installer warns if Python or Pillow is missing.

For MP4 previews, install `ffmpeg`. GIF previews work without it.

## Repo Layout

```text
.codex-plugin/plugin.json
skills/spritegen/SKILL.md
skills/spritegen/scripts/
skills/spritegen/references/
bin/install.js
install.ps1
package.json
INSTALL.md
requirements.txt
```

## Not Pets

Spritegen is for generic 2D assets. It does not create Codex pets, `pet.json`, or the fixed Codex pet `8x9` atlas. Use a pet-specific workflow for that.

## Troubleshooting

Check detected agents:

```powershell
pwsh .\install.ps1 --list
```

Preview changes without writing:

```powershell
pwsh .\install.ps1 --dry-run
```

Install one target only:

```powershell
pwsh .\install.ps1 --only codex
pwsh .\install.ps1 --only claude
pwsh .\install.ps1 --only gemini
```

Remove everything Spritegen wrote:

```powershell
pwsh .\install.ps1 --uninstall
```

If image processing fails:

```powershell
pip install Pillow
```

If MP4 preview fails, install `ffmpeg`. The script still writes `preview.gif` without it.
