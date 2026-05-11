# AutoCAD MCP connector build (Windows)
#
# Used by both the fork's CI (security-and-build.yml) and local dry runs.
# Produces dist/autocad-mcp-win-x64.zip with a bundled Python venv + the
# upstream source tree, ready to be unzipped at the user's machine.
#
# Run from the fork root:
#   .\carpe-fork\build.ps1

[CmdletBinding()]
param(
    [string]$OutputDir = "dist",
    [switch]$SkipLockedSync
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$forkRoot = Split-Path -Parent $PSScriptRoot
Set-Location $forkRoot

Write-Host "[build] Fork root: $forkRoot"
Write-Host "[build] Output dir: $OutputDir"

# 1. Sync deps from uv.lock into a fresh .venv
if (-not $SkipLockedSync) {
    Write-Host "[build] Removing any existing .venv"
    if (Test-Path .venv) { Remove-Item -Recurse -Force .venv }

    # --no-install-project: upstream's pyproject.toml declares hatch as the
    # build backend but doesn't declare packages, so installing the project
    # itself fails. We only need runtime deps. --extra full adds pywin32 +
    # Pillow + matplotlib for COM + PDF export.
    Write-Host "[build] uv sync --locked --no-install-project --extra full"
    & uv sync --locked --no-install-project --extra full
    if ($LASTEXITCODE -ne 0) { throw "uv sync failed (exit $LASTEXITCODE)" }
}

# 2. Stage the bundle
$staging = Join-Path $env:TEMP "autocad-mcp-bundle-$(Get-Random)"
Write-Host "[build] Staging at $staging"
New-Item -ItemType Directory -Path $staging | Out-Null

# Files we ship (upstream source needed at runtime + our launcher)
$shipPaths = @(
    "server.py",
    "config.py",
    "security.py",
    "backends",
    "engineering",
    ".venv",
    "carpe-fork\run.cmd"
)

foreach ($p in $shipPaths) {
    if (-not (Test-Path $p)) {
        throw "Expected path missing from fork tree: $p"
    }
    Write-Host "[build] Copying $p"
    # Copy-Item on a file path puts it at the destination root regardless
    # of the source-side nesting. carpe-fork\run.cmd lands as $staging\run.cmd,
    # which is exactly what connector.json's `${connector_dir}/run.cmd`
    # launch line expects.
    Copy-Item -Recurse -Path $p -Destination $staging
}

# 3. Zip
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}
$zipPath = Join-Path $OutputDir "autocad-mcp-win-x64.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath }

Write-Host "[build] Compressing to $zipPath"
Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $zipPath -CompressionLevel Optimal

# 4. SHA-256
$hash = Get-FileHash -Algorithm SHA256 $zipPath
$hashLine = "$($hash.Hash.ToLower())  $(Split-Path -Leaf $zipPath)"
$hashLine | Set-Content -Path "$zipPath.sha256" -NoNewline

Write-Host "[build] Wrote $zipPath"
Write-Host "[build] SHA-256: $($hash.Hash.ToLower())"

# 5. Cleanup
Remove-Item -Recurse -Force $staging
