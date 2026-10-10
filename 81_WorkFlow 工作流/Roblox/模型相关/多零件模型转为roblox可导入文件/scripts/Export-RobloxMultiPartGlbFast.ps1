[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BlendPath,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9_-]*$')]
    [string]$AssetName,

    [string]$OutputRoot,
    [string[]]$Parts,
    [switch]$AllowUntextured,
    [switch]$Overwrite
)

$ErrorActionPreference = 'Stop'

$resolvedBlend = (Resolve-Path -LiteralPath $BlendPath).Path
$pythonScript = Join-Path $PSScriptRoot 'export_multi_part_glb_fast.py'
if (-not (Test-Path -LiteralPath $pythonScript -PathType Leaf)) {
    throw "Missing Blender helper: $pythonScript"
}

$preferredBlender = 'C:\Program Files\Blender Foundation\Blender 5.1\blender.exe'
if (Test-Path -LiteralPath $preferredBlender -PathType Leaf) {
    $blenderPath = $preferredBlender
}
else {
    $blenderPath = Get-ChildItem -LiteralPath 'C:\Program Files\Blender Foundation' -Filter 'blender.exe' -Recurse -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Select-Object -First 1 -ExpandProperty FullName
}
if (-not $blenderPath) {
    throw 'Blender executable not found under C:\Program Files\Blender Foundation'
}

$blenderArgs = @(
    '-b',
    $resolvedBlend,
    '--python-exit-code', '2',
    '--python', $pythonScript,
    '--',
    '--asset-name', $AssetName
)
if ($OutputRoot) {
    $blenderArgs += @('--output-root', $OutputRoot)
}
if ($Parts -and $Parts.Count -gt 0) {
    $blenderArgs += @('--parts', ($Parts -join ','))
}
if ($AllowUntextured) {
    $blenderArgs += '--allow-untextured'
}
if ($Overwrite) {
    $blenderArgs += '--overwrite'
}

& $blenderPath @blenderArgs
if ($LASTEXITCODE -ne 0) {
    throw "GLB fast export failed with Blender exit code $LASTEXITCODE"
}

Write-Output 'ROBLOX_MULTI_PART_GLB_FAST_COMMAND_OK'
