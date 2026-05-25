#!/usr/bin/env node
const { spawnSync } = require("node:child_process");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const script = path.join(root, "install.ps1");
const candidates = process.platform === "win32" ? ["pwsh", "powershell"] : ["pwsh"];
let result = null;

for (const shell of candidates) {
  result = spawnSync(shell, [
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    script,
    ...process.argv.slice(2),
  ], { stdio: "inherit" });

  if (result.error && result.error.code === "ENOENT") {
    continue;
  }
  process.exit(result.status ?? 1);
}

console.error("spritegen: PowerShell is required. Install PowerShell 7+ or use Windows PowerShell 5.1+.");
process.exit(1);
