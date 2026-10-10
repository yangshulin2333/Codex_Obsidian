param(
    [Parameter(Mandatory=$true)]
    [string]$InputPath,

    [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"

function Strip-StudioPrefix {
    param([string]$Line)
    $lineText = $Line -replace '^\s*\d{2}:\d{2}:\d{2}\.\d+\s+', ''
    if ($Line -match '^\s*\d{2}:\d{2}:\d{2}\.\d+\s+') {
        $lineText = $lineText -replace '\s+-\s+[^-]*$', ''
    }
    return $lineText
}

function Add-Line {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Text = ""
    )
    [void]$Lines.Add($Text)
}

function To-ShortJson {
    param($Value)
    if ($null -eq $Value) {
        return ""
    }
    if ($Value -is [string] -or $Value -is [bool] -or $Value -is [int] -or $Value -is [double]) {
        return [string]$Value
    }
    return ($Value | ConvertTo-Json -Compress -Depth 20)
}

$resolvedInput = (Resolve-Path -Path $InputPath).Path
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Split-Path -Parent $resolvedInput
}
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$lines = Get-Content -Path $resolvedInput -Encoding UTF8
$segments = New-Object System.Collections.Generic.List[object]
$currentName = $null
$chunks = $null

foreach ($rawLine in $lines) {
    $line = Strip-StudioPrefix $rawLine

    if ($line -match '^## BEGIN_ROBLOX_GUI_SNAPSHOT_JSON\s+(.+?)\s*$') {
        $currentName = $Matches[1]
        $chunks = New-Object System.Collections.Generic.List[string]
        continue
    }

    if ($line -match '^## END_ROBLOX_GUI_SNAPSHOT_JSON\s+(.+?)\s*$') {
        if ($null -eq $currentName) {
            continue
        }
        $jsonText = ($chunks -join "")
        $data = $jsonText | ConvertFrom-Json
        [void]$segments.Add([pscustomobject]@{
            Name = $currentName
            Data = $data
        })
        $currentName = $null
        $chunks = $null
        continue
    }

    if ($null -ne $chunks) {
        if ($line -notmatch '^## ') {
            [void]$chunks.Add($line)
        }
    }
}

if ($null -ne $currentName) {
    throw "Snapshot segment '$currentName' has BEGIN marker but no END marker. Studio Output is probably truncated."
}

if ($segments.Count -eq 0) {
    $allText = $lines -join [Environment]::NewLine
    if ($allText -match '\[trimmed\]') {
        throw "No complete segment was found and Studio Output contains [trimmed]. Use HTTP export mode or re-run with only one small target."
    }
    throw "No chunked GUI snapshot segment was found."
}

$allNodes = @()
foreach ($segment in $segments) {
    $allNodes += @($segment.Data.nodes)
}

$summary = New-Object System.Collections.Generic.List[string]
Add-Line $summary "# Chunked GUI Snapshot Summary"
Add-Line $summary ""
Add-Line $summary "Input: ``$resolvedInput``"
Add-Line $summary "SegmentCount: $($segments.Count)"
Add-Line $summary "TotalNodes: $($allNodes.Count)"
Add-Line $summary ""

Add-Line $summary "## Segments"
foreach ($segment in $segments) {
    $data = $segment.Data
    Add-Line $summary "- $($segment.Name): path=$($data.targetPath); nodes=$($data.nodeCount); trimmed=$($data.trimmed); depthLimited=$($data.depthLimited)"
}
Add-Line $summary ""

Add-Line $summary "## Class Counts"
$allNodes | Group-Object className | Sort-Object Count -Descending | ForEach-Object {
    Add-Line $summary "- $($_.Name): $($_.Count)"
}
Add-Line $summary ""

Add-Line $summary "## Visible Windows And Pages"
$allNodes |
    Where-Object { $_.name -match 'Page$|Window$|Panel$|Scroll$|Template$' } |
    Sort-Object path |
    ForEach-Object {
        Add-Line $summary "- $($_.path): class=$($_.className); visible=$(To-ShortJson $_.props.Visible); z=$(To-ShortJson $_.props.ZIndex)"
    }
Add-Line $summary ""

Add-Line $summary "## Image Asset Usage"
$allNodes |
    Where-Object { $null -ne $_.props.Image -and $_.props.Image -ne "" } |
    Sort-Object path |
    ForEach-Object {
        Add-Line $summary "- $($_.path): SourceAsset=$(To-ShortJson $_.attributes.SourceAsset); Image=$(To-ShortJson $_.props.Image); ScaleType=$(To-ShortJson $_.props.ScaleType); ImageRectOffset=$(To-ShortJson $_.props.ImageRectOffset); ImageRectSize=$(To-ShortJson $_.props.ImageRectSize); SliceCenter=$(To-ShortJson $_.props.SliceCenter)"
    }
Add-Line $summary ""

Add-Line $summary "## Text Usage"
$allNodes |
    Where-Object { $null -ne $_.props.Text -and $_.props.Text -ne "" } |
    Sort-Object path |
    ForEach-Object {
        Add-Line $summary "- $($_.path): Text=$(To-ShortJson $_.props.Text); TextScaled=$(To-ShortJson $_.props.TextScaled); Color=$(To-ShortJson $_.props.TextColor3)"
    }

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedInput)
$summaryPath = Join-Path $OutputDir ($baseName + ".chunked.summary.md")
$jsonPath = Join-Path $OutputDir ($baseName + ".chunked.combined.json")

$summary | Set-Content -Path $summaryPath -Encoding UTF8
@{
    segmentCount = $segments.Count
    totalNodes = $allNodes.Count
    segments = @($segments | ForEach-Object { $_.Data })
} | ConvertTo-Json -Depth 100 | Set-Content -Path $jsonPath -Encoding UTF8

Write-Host "Wrote summary: $summaryPath"
Write-Host "Wrote combined json: $jsonPath"
