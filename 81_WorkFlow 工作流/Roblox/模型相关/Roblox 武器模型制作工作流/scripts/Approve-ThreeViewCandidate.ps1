param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$ExpectedRunDir,

    [Parameter(Mandatory = $true)]
    [string]$OutputDir,

    [Parameter(Mandatory = $true)]
    [string]$WeaponName,

    [Parameter(Mandatory = $true)]
    [ValidateSet("front", "side", "back")]
    [string]$View,

    [switch]$ApprovedByVisualCheck
)

$ErrorActionPreference = "Stop"

function Resolve-FullPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolved = Resolve-Path -Path $Path
    return $resolved.Path
}

if (-not $ApprovedByVisualCheck) {
    throw "Refusing to copy: run view_image / manual visual check first, then pass -ApprovedByVisualCheck."
}

$sourceFull = Resolve-FullPath -Path $SourcePath
$expectedFull = Resolve-FullPath -Path $ExpectedRunDir

if (-not (Test-Path -Path $sourceFull -PathType Leaf)) {
    throw "SourcePath is not a file: $sourceFull"
}

if (-not (Test-Path -Path $expectedFull -PathType Container)) {
    throw "ExpectedRunDir is not a directory: $expectedFull"
}

$sourceExt = [System.IO.Path]::GetExtension($sourceFull).ToLowerInvariant()
if ($sourceExt -ne ".png") {
    throw "Only PNG candidates are approved for three-view delivery. Source: $sourceFull"
}

$sourceParent = [System.IO.Path]::GetDirectoryName($sourceFull)
$expectedWithSlash = $expectedFull.TrimEnd("\") + "\"
if (-not ($sourceFull.StartsWith($expectedWithSlash, [System.StringComparison]::OrdinalIgnoreCase))) {
    throw "SourcePath must be inside ExpectedRunDir. Do not copy from global latest PNG. Source: $sourceFull ExpectedRunDir: $expectedFull"
}

$globalGeneratedRoot = "C:\Users\14176\.codex\generated_images"
if ($expectedFull.TrimEnd("\").Equals($globalGeneratedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "ExpectedRunDir cannot be the global generated_images root. Use the exact per-run folder, or a local controlled output directory."
}

$scriptDir = Split-Path -Parent $PSCommandPath
$workflowRoot = Split-Path -Parent $scriptDir
$deliveryRoot = Join-Path -Path $workflowRoot -ChildPath "generated_views"
if (-not (Test-Path -Path $OutputDir -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}

$outputFull = Resolve-FullPath -Path $OutputDir
$deliveryWithSlash = $deliveryRoot.TrimEnd("\") + "\"
if (-not ($outputFull.StartsWith($deliveryWithSlash, [System.StringComparison]::OrdinalIgnoreCase))) {
    throw "OutputDir must be under generated_views. OutputDir: $outputFull"
}

Add-Type -AssemblyName System.Drawing
$image = [System.Drawing.Image]::FromFile($sourceFull)
try {
    $width = $image.Width
    $height = $image.Height
}
finally {
    $image.Dispose()
}

if ($width -lt 512 -or $height -lt 512) {
    throw "Image is too small for delivery: ${width}x${height}. Source: $sourceFull"
}

$targetName = "${WeaponName}_${View}_view.png"
$targetFull = Join-Path -Path $outputFull -ChildPath $targetName
Copy-Item -Path $sourceFull -Destination $targetFull -Force

$auditPath = Join-Path -Path $outputFull -ChildPath "COPY_AUDIT.txt"
$stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$auditLine = "$stamp`tview=$View`twidth=$width`theight=$height`tsource=$sourceFull`ttarget=$targetFull"
Add-Content -Path $auditPath -Value $auditLine -Encoding UTF8

[PSCustomObject]@{
    View = $View
    Width = $width
    Height = $height
    Source = $sourceFull
    Target = $targetFull
    Audit = $auditPath
}
