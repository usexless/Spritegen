---
name: spritegen
description: Create, repair, validate, preview, slice, and package generic 2D pixel-art assets from text concepts, screenshots, generated images, or visual references. Use when Codex needs to generate game-ready or UI-ready pixel-style sprites, props, icons, tile sets, character sprites, object sheets, VFX frames, simple animation strips, contact sheets, GIF/MP4 previews, or transparent PNG/WebP assets without using the Codex pet-specific atlas contract.
---

# Spritegen

## Overview

Create generic 2D pixel-art assets with an image model, then use deterministic scripts for the mechanical parts: run setup, prompt manifests, source recording, slicing, alpha/chroma cleanup, contact sheets, validation, previews, and packaging.

This is not the pet-generation workflow. Do not use pet row names, pet manifests, `pet.json`, or the fixed Codex pet `8x9` atlas unless the user explicitly asks for a Codex pet. Use `hatch-pet` for pets.

## Core Rule

Use `$imagegen` for visual generation. Use this skill's Python scripts only for deterministic asset operations.

Do not draw, invent, or fake final asset art with Python, SVG, HTML canvas, CSS, or local image transforms as a substitute for model-generated visuals. Local scripts may crop, slice, validate, compose contact sheets, render previews, convert formats, and package files.

## Default Workflow

1. Clarify or infer the asset target: `single`, `sheet`, `tileset`, `icons`, or `animation`.
2. Create a run folder and generation manifest:

```bash
SKILL_DIR="/path/to/spritegen/skills/spritegen"
python "$SKILL_DIR/scripts/prepare_sprite_run.py" \
  --name "<asset-name>" \
  --kind sheet \
  --concept "<what to make>" \
  --output-dir /absolute/path/to/run \
  --grid 4x4 \
  --cell-size 64x64 \
  --force
```

3. Read `prompts/generation-prompt.txt` and call `$imagegen` with that prompt plus any user references. If references exist, attach them with clear role labels.
4. Record the selected original generated image:

```bash
python "$SKILL_DIR/scripts/record_sprite_result.py" \
  --run-dir /absolute/path/to/run \
  --source /absolute/path/to/generated-output.png
```

5. Slice and QA the source:

```bash
python "$SKILL_DIR/scripts/slice_asset_sheet.py" --run-dir /absolute/path/to/run
python "$SKILL_DIR/scripts/validate_sprite_assets.py" --run-dir /absolute/path/to/run
python "$SKILL_DIR/scripts/make_asset_contact_sheet.py" --run-dir /absolute/path/to/run
```

6. For animation strips, render previews:

```bash
python "$SKILL_DIR/scripts/render_asset_preview.py" \
  --run-dir /absolute/path/to/run \
  --fps 8
```

7. Package final outputs:

```bash
python "$SKILL_DIR/scripts/package_sprite_assets.py" --run-dir /absolute/path/to/run
```

## Asset Types

- `single`: one transparent asset, icon, prop, item, pickup, UI badge, character, or object.
- `sheet`: multiple related sprites in a uniform grid.
- `tileset`: grid-aligned terrain, walls, floors, platforms, edges, corners, or decorative map tiles.
- `icons`: readable item or UI icons with shared perspective and palette.
- `animation`: frame strip or grid for a small loop such as walk, slash, sparkle, flame, explosion, bounce, idle, or interact.

## Pixel-Art Style

Default to clean pixel-art-adjacent 2D game assets: chunky readable silhouette, hard edges, limited palette, strong shape language, flat cel-like shading, consistent pixel scale, minimal antialiasing, and transparent or clean chroma-key background.

Avoid painterly rendering, realistic material textures, glossy app-icon lighting, soft gradients, complex tiny details, text labels, UI mockups, backgrounds, cast shadows, loose noise, blurry edges, and inconsistent perspective.

For detailed visual rules, read `references/pixel-style.md`.

## Layout Rules

- Prefer transparent PNG output when the image model supports it. Otherwise use the run's chroma-key background and remove it during slicing.
- Keep one asset or one frame per grid cell. No overlap across cell boundaries.
- Use stable cell sizes: common defaults are `32x32`, `48x48`, `64x64`, `96x96`, and `128x128`.
- Keep all assets in a sheet visually related: same camera angle, outline weight, palette, lighting logic, and pixel scale.
- Do not accept a sheet where assets are cropped from a larger illustration, repeated transforms of one frame, or blended into a background.
- For tilesets, ensure tile edges connect cleanly and avoid non-grid scenery.

For output contracts and packaging shape, read `references/asset-contract.md`.

## QA Rules

Before calling work complete, inspect:

- `qa/contact-sheet.png`
- `qa/review.json`
- `final/manifest.json`
- `preview/` files when animation previews are requested

Block acceptance when:

- requested cells are empty or mostly empty
- assets are clipped, slot-crossing, or joined together
- background cleanup removed meaningful pixels
- chroma-key color remains around edges
- style drifts into illustration, 3D, realism, or glossy icons
- animation frames are static copies rather than meaningful frame variants
- tiles do not align to the requested grid

For detailed checks, read `references/qa-rubric.md`.

## Repair Workflow

Repair the smallest failing scope:

1. Regenerate only the source image if the whole sheet is wrong.
2. Regenerate only a row, region, or individual asset when the model/tooling supports it.
3. Re-run `record_sprite_result.py`, slicing, validation, contact sheet, and previews.

Do not patch broken art locally unless the user explicitly asks for manual pixel editing. Deterministic scripts may fix alpha, crop, scale, and packaging only.

## Script Summary

- `prepare_sprite_run.py`: create request metadata, generation prompt, layout guide, and run folders.
- `record_sprite_result.py`: copy a selected generated source into the run and record provenance.
- `slice_asset_sheet.py`: remove chroma background if configured, slice grid cells, trim/pad, and write `slices/`.
- `validate_sprite_assets.py`: inspect geometry, alpha, empty cells, edge pixels, and size consistency.
- `make_asset_contact_sheet.py`: build a visual QA sheet with transparent checkerboard.
- `render_asset_preview.py`: render GIF and MP4 previews for animation frames.
- `package_sprite_assets.py`: copy final usable files into `package/` with a manifest.
