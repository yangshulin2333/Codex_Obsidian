[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [string]$OutputRoot = "",

    [string]$Name = "",

    [int]$TextureSize = 512,

    [ValidateSet("jpg", "png")]
    [string]$TextureFormat = "jpg",

    [string]$BlenderExe = "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
)

$ErrorActionPreference = "Stop"

# Keep one canonical exporter for all Roblox props. Avoid a Chinese path
# literal here because Windows PowerShell 5.1 can misread UTF-8 without BOM.
$modelWorkflowRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..")).Path
$selfPath = (Resolve-Path -LiteralPath $PSCommandPath).Path
$canonicalScript = Get-ChildItem -LiteralPath $modelWorkflowRoot -Recurse -File -Filter "Prepare-RobloxWeaponImport.ps1" |
    Where-Object {
        $_.FullName -ne $selfPath -and
        $_.FullName -notmatch "[\\/]deprecated[\\/]"
    } |
    Sort-Object Length -Descending |
    Select-Object -First 1 -ExpandProperty FullName

if ([string]::IsNullOrWhiteSpace($canonicalScript)) {
    throw "Canonical Roblox import exporter was not found under: $modelWorkflowRoot"
}

$forward = @{
    InputPath = $InputPath
    TextureSize = $TextureSize
    TextureFormat = $TextureFormat
    BlenderExe = $BlenderExe
}

if (-not [string]::IsNullOrWhiteSpace($OutputRoot)) {
    $forward.OutputRoot = $OutputRoot
}

if (-not [string]::IsNullOrWhiteSpace($Name)) {
    $forward.Name = $Name
}

& $canonicalScript @forward
exit $LASTEXITCODE
