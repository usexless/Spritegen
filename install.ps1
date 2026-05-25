# Spritegen installer for Windows PowerShell 5.1+.
#
# One-line install after the repo is pushed:
#   irm https://raw.githubusercontent.com/usexless/Spritegen/main/install.ps1 | iex
#
# Local clone:
#   pwsh .\install.ps1 --dry-run

[CmdletBinding()]
param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$CliArgs
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
  Write-Host "[spritegen] $Message"
}

function Get-HomeDir {
  if ($HOME) { return $HOME }
  return [Environment]::GetFolderPath("UserProfile")
}

function Expand-Home([string]$Path) {
  $homeDir = Get-HomeDir
  if ($Path.StartsWith("~")) {
    return Join-Path $homeDir $Path.Substring(1).TrimStart("\", "/")
  }
  return $Path
}

function Parse-Args([string[]]$RawArgs) {
  $state = [ordered]@{
    DryRun = $false
    Uninstall = $false
    Force = $false
    WithInit = $false
    List = $false
    Only = New-Object System.Collections.Generic.List[string]
    Source = $null
  }

  for ($i = 0; $i -lt $RawArgs.Count; $i++) {
    switch ($RawArgs[$i]) {
      "--dry-run" { $state.DryRun = $true; continue }
      "--uninstall" { $state.Uninstall = $true; continue }
      "--force" { $state.Force = $true; continue }
      "--with-init" { $state.WithInit = $true; continue }
      "--list" { $state.List = $true; continue }
      "--only" {
        if ($i + 1 -ge $RawArgs.Count) { throw "--only needs a provider name" }
        $i++
        $state.Only.Add($RawArgs[$i].ToLowerInvariant())
        continue
      }
      "--source" {
        if ($i + 1 -ge $RawArgs.Count) { throw "--source needs a path" }
        $i++
        $state.Source = (Resolve-Path (Expand-Home $RawArgs[$i])).Path
        continue
      }
      default { throw "Unknown flag: $($RawArgs[$i])" }
    }
  }

  return $state
}

function Get-SourceRoot($Options) {
  if ($Options.Source) { return $Options.Source }

  $here = if ($MyInvocation.ScriptName) { Split-Path -Parent $MyInvocation.ScriptName } else { $null }
  if ($here -and (Test-Path (Join-Path $here "skills\spritegen\SKILL.md"))) {
    return $here
  }

  $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("spritegen-" + [System.Guid]::NewGuid().ToString("N"))
  New-Item -ItemType Directory -Path $temp | Out-Null
  $zip = Join-Path $temp "spritegen.zip"
  $url = "https://github.com/usexless/Spritegen/archive/refs/heads/main.zip"
  Write-Step "downloading $url"
  Invoke-WebRequest -Uri $url -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath $temp
  $root = Get-ChildItem -Path $temp -Directory | Where-Object { Test-Path (Join-Path $_.FullName "skills\spritegen\SKILL.md") } | Select-Object -First 1
  if (-not $root) { throw "Downloaded archive did not contain skills\spritegen\SKILL.md" }
  return $root.FullName
}

function Copy-Tree($Source, $Destination, [bool]$DryRun) {
  if ($DryRun) {
    Write-Step "would copy $Source -> $Destination"
    return
  }
  if (Test-Path $Destination) {
    Remove-Item -LiteralPath $Destination -Recurse -Force
  }
  New-Item -ItemType Directory -Path (Split-Path -Parent $Destination) -Force | Out-Null
  Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
}

function Remove-Tree($Destination, [bool]$DryRun) {
  if ($DryRun) {
    Write-Step "would remove $Destination"
    return
  }
  if (Test-Path $Destination) {
    Remove-Item -LiteralPath $Destination -Recurse -Force
  }
}

function Upsert-MarkerBlock($Path, $Begin, $End, $Body, [bool]$DryRun) {
  $resolved = Expand-Home $Path
  $block = "$Begin`r`n$Body`r`n$End"
  if ($DryRun) {
    Write-Step "would update marker block in $resolved"
    return
  }
  $parent = Split-Path -Parent $resolved
  if ($parent) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  $text = ""
  if (Test-Path $resolved) {
    $text = Get-Content -Raw -LiteralPath $resolved
  }
  $pattern = [regex]::Escape($Begin) + "(?s).*?" + [regex]::Escape($End)
  if ([regex]::IsMatch($text, $pattern)) {
    $text = [regex]::Replace($text, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block })
  } else {
    if ($text.Trim().Length -gt 0) { $text = $text.TrimEnd() + "`r`n`r`n" }
    $text += $block + "`r`n"
  }
  Set-Content -LiteralPath $resolved -Value $text -Encoding UTF8
}

function Remove-MarkerBlock($Path, $Begin, $End, [bool]$DryRun) {
  $resolved = Expand-Home $Path
  if ($DryRun) {
    Write-Step "would remove marker block from $resolved"
    return
  }
  if (-not (Test-Path $resolved)) { return }
  $text = Get-Content -Raw -LiteralPath $resolved
  $pattern = "\r?\n?" + [regex]::Escape($Begin) + "(?s).*?" + [regex]::Escape($End) + "\r?\n?"
  $text = [regex]::Replace($text, $pattern, "`r`n")
  Set-Content -LiteralPath $resolved -Value $text.TrimStart() -Encoding UTF8
}

function Get-Providers {
  $homeDir = Get-HomeDir
  $codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $homeDir ".codex" }
  $claudeHome = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $homeDir ".claude" }
  return @(
    @{ Name = "codex"; Detected = (Test-Path $codexHome); SkillPath = (Join-Path $codexHome "skills\spritegen"); RulePath = (Join-Path $codexHome "AGENTS.md") },
    @{ Name = "claude"; Detected = [bool]((Get-Command claude -ErrorAction SilentlyContinue) -or (Test-Path $claudeHome)); SkillPath = (Join-Path $claudeHome "skills\spritegen"); RulePath = (Join-Path $claudeHome "CLAUDE.md") },
    @{ Name = "gemini"; Detected = [bool]((Get-Command gemini -ErrorAction SilentlyContinue) -or (Test-Path (Join-Path $homeDir ".gemini"))); SkillPath = (Join-Path $homeDir ".gemini\skills\spritegen"); RulePath = (Join-Path $homeDir ".gemini\GEMINI.md") },
    @{ Name = "cursor"; Detected = (Test-Path ".cursor"); SkillPath = $null; RulePath = ".cursor\rules\spritegen.mdc" },
    @{ Name = "windsurf"; Detected = (Test-Path ".windsurf"); SkillPath = $null; RulePath = ".windsurf\rules\spritegen.md" },
    @{ Name = "cline"; Detected = (Test-Path ".clinerules"); SkillPath = $null; RulePath = ".clinerules\spritegen.md" },
    @{ Name = "copilot"; Detected = (Test-Path ".github\copilot-instructions.md"); SkillPath = $null; RulePath = ".github\copilot-instructions.md" },
    @{ Name = "agents"; Detected = (Test-Path "AGENTS.md"); SkillPath = $null; RulePath = "AGENTS.md" }
  )
}

function Rule-Body {
  return @"
Use Spritegen when asked to create, repair, validate, preview, slice, or package generic 2D pixel-art assets: sprites, props, icons, tilesets, VFX sheets, item sheets, or animation strips.

Load the Spritegen skill if available. Keep visual generation in the image model. Use deterministic scripts only for setup, recording generated sources, slicing, validation, contact sheets, previews, and packaging. Do not use the Codex pet workflow unless the user explicitly asks for a Codex pet.
"@
}

$options = Parse-Args $CliArgs
$providers = Get-Providers

if ($options.List) {
  foreach ($provider in $providers) {
    $mark = if ($provider.Detected) { "detected" } else { "not detected" }
    Write-Host ("{0,-8} {1}" -f $provider.Name, $mark)
  }
  exit 0
}

$selected = @()
if ($options.Only.Count -gt 0) {
  foreach ($name in $options.Only) {
    $match = $providers | Where-Object { $_.Name -eq $name } | Select-Object -First 1
    if (-not $match) { throw "Unknown provider '$name'. Use --list." }
    $selected += $match
  }
} else {
  $selected = $providers | Where-Object { $_.Detected }
  if (-not $selected) {
    $selected = $providers | Where-Object { $_.Name -in @("codex", "claude", "gemini") }
  }
}

$sourceRoot = $null
if (-not $options.Uninstall) {
  $sourceRoot = Get-SourceRoot $options
  Write-Step "source: $sourceRoot"
}

$skillSource = if ($sourceRoot) { Join-Path $sourceRoot "skills\spritegen" } else { $null }
$ruleBegin = "<!-- spritegen-begin -->"
$ruleEnd = "<!-- spritegen-end -->"

foreach ($provider in $selected) {
  $verb = if ($options.Uninstall) { "uninstalling" } else { "installing" }
  Write-Step "$verb $($provider.Name)"
  if ($provider.SkillPath) {
    if ($options.Uninstall) {
      Remove-Tree $provider.SkillPath $options.DryRun
    } else {
      Copy-Tree $skillSource $provider.SkillPath $options.DryRun
    }
  }
  if ($provider.RulePath -and ($options.WithInit -or $provider.Name -in @("claude", "codex", "gemini"))) {
    if ($options.Uninstall) {
      Remove-MarkerBlock $provider.RulePath $ruleBegin $ruleEnd $options.DryRun
    } else {
      Upsert-MarkerBlock $provider.RulePath $ruleBegin $ruleEnd (Rule-Body) $options.DryRun
    }
  }
}

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command python3 -ErrorAction SilentlyContinue }
if (-not $python) {
  Write-Host "[spritegen] warning: python not found - install Python 3.10+ and run: pip install Pillow"
} else {
  $previousPreference = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  $null = & $python.Source -c "import PIL" 2>&1
  $pillowExit = $LASTEXITCODE
  $ErrorActionPreference = $previousPreference
  if ($pillowExit -ne 0) {
    Write-Host "[spritegen] warning: Pillow not installed - run: pip install Pillow"
  }
}

Write-Step "done"
