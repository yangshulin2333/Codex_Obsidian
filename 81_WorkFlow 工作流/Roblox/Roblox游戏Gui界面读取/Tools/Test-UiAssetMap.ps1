param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath,

    [string]$AssetRoot = "",

    [string]$OutPath = "",

    [string[]]$FocusRelPath = @(),

    [switch]$OpenCsv
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-FullPath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Normalize-AssetId {
    param([AllowNull()][string]$Value)

    $raw = ""
    if ($null -ne $Value) {
        $raw = $Value.Trim()
    }

    if ($raw -eq "") {
        return [pscustomobject]@{
            Raw        = $raw
            Normalized = ""
            State      = "empty"
            Format     = "empty"
        }
    }

    if ($raw -match '^rbxassetid://(\d+)$') {
        return [pscustomobject]@{
            Raw        = $raw
            Normalized = "rbxassetid://$($Matches[1])"
            State      = "ok"
            Format     = "prefixed"
        }
    }

    if ($raw -match '^\d+$') {
        return [pscustomobject]@{
            Raw        = $raw
            Normalized = "rbxassetid://$raw"
            State      = "ok"
            Format     = "numeric"
        }
    }

    if ($raw -match '[?&]id=(\d+)') {
        return [pscustomobject]@{
            Raw        = $raw
            Normalized = "rbxassetid://$($Matches[1])"
            State      = "ok"
            Format     = "url"
        }
    }

    return [pscustomobject]@{
        Raw        = $raw
        Normalized = ""
        State      = "bad"
        Format     = "unknown"
    }
}

function To-MarkdownCell {
    param([AllowNull()][string]$Value)

    if ($null -eq $Value -or $Value -eq "") {
        return ""
    }

    return ($Value -replace '\|', '\|')
}

$csvFullPath = Resolve-FullPath $CsvPath
if (-not (Test-Path -LiteralPath $csvFullPath)) {
    throw "CSV not found: $csvFullPath"
}

$assetRootFullPath = ""
if ($AssetRoot -ne "") {
    $assetRootFullPath = Resolve-FullPath $AssetRoot
}

if ($OutPath -eq "") {
    $OutPath = [System.IO.Path]::ChangeExtension($csvFullPath, ".asset_check.md")
}
$outFullPath = Resolve-FullPath $OutPath

$focusSet = @{}
$expandedFocusRelPath = New-Object System.Collections.Generic.List[string]
foreach ($path in $FocusRelPath) {
    foreach ($part in ([string]$path -split ',')) {
        $trimmed = $part.Trim()
        if ($trimmed -ne "") {
            $expandedFocusRelPath.Add($trimmed)
        }
    }
}
$FocusRelPath = $expandedFocusRelPath.ToArray()

foreach ($path in $FocusRelPath) {
    if ($path -ne "") {
        $focusSet[$path.Replace('\', '/').ToLowerInvariant()] = $true
    }
}
$hasFocus = $focusSet.Count -gt 0

$rows = Import-Csv -LiteralPath $csvFullPath -Encoding UTF8
$checkedRows = New-Object System.Collections.Generic.List[object]

foreach ($row in $rows) {
    if (-not ($row.PSObject.Properties.Name -contains "rel_path")) {
        throw "CSV must contain column: rel_path"
    }
    if (-not ($row.PSObject.Properties.Name -contains "asset_id")) {
        throw "CSV must contain column: asset_id"
    }

    $relPath = [string]$row.rel_path
    $relKey = $relPath.Replace('\', '/').ToLowerInvariant()
    if ($hasFocus -and -not $focusSet.ContainsKey($relKey)) {
        continue
    }

    $usageHint = ""
    if ($row.PSObject.Properties.Name -contains "usage_hint") {
        $usageHint = [string]$row.usage_hint
    }

    $isReferenceOnly = $usageHint -like "*reference_only_layout_screenshot*" -or $usageHint -like "*no_asset_id_needed*"
    $asset = Normalize-AssetId ([string]$row.asset_id)

    $localPath = ""
    $localExists = $false
    if ($assetRootFullPath -ne "" -and $relPath -ne "") {
        $localPath = Join-Path $assetRootFullPath ($relPath -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        $localExists = Test-Path -LiteralPath $localPath
    }

    $status = "ready"
    if ($isReferenceOnly) {
        $status = "reference_only"
    } elseif ($asset.State -eq "bad") {
        $status = "bad_asset_id"
    } elseif ($asset.State -eq "empty") {
        $status = "missing_asset_id"
    } elseif ($assetRootFullPath -ne "" -and -not $localExists) {
        $status = "local_missing"
    }

    $checkedRows.Add([pscustomobject]@{
        Category     = $row.category
        RelPath      = $relPath
        AssetIdRaw   = $asset.Raw
        AssetId      = $asset.Normalized
        Format       = $asset.Format
        Status       = $status
        LocalExists  = $localExists
        LocalPath    = $localPath
        UsageHint    = $usageHint
    })
}

$statusCounts = $checkedRows | Group-Object Status | Sort-Object Name

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# UI AssetId Map Check")
$lines.Add("")
$lines.Add("GeneratedAt: $(Get-Date -Format s)")
$lines.Add("")
$lines.Add("CsvPath: ``$csvFullPath``")
if ($assetRootFullPath -ne "") {
    $lines.Add("AssetRoot: ``$assetRootFullPath``")
}
if ($hasFocus) {
    $lines.Add("FocusRelPath: ``$($FocusRelPath -join ', ')``")
}
$lines.Add("")
$lines.Add("## Summary")
$lines.Add("")
foreach ($group in $statusCounts) {
    $lines.Add("- $($group.Name): $($group.Count)")
}
$lines.Add("")
$lines.Add("## Rows Needing Confirmation")
$lines.Add("")
$needConfirm = $checkedRows | Where-Object { $_.Status -in @("missing_asset_id", "bad_asset_id", "local_missing") }
if (-not $needConfirm) {
    $lines.Add("None.")
} else {
    $lines.Add("| status | rel_path | asset_id_raw | normalized_asset_id | local_exists |")
    $lines.Add("|---|---|---|---|---|")
    foreach ($item in $needConfirm) {
        $lines.Add("| $(To-MarkdownCell $item.Status) | $(To-MarkdownCell $item.RelPath) | $(To-MarkdownCell $item.AssetIdRaw) | $(To-MarkdownCell $item.AssetId) | $($item.LocalExists) |")
    }
}
$lines.Add("")
$lines.Add("## Checked Rows")
$lines.Add("")
$lines.Add("| status | rel_path | asset_id_raw | normalized_asset_id | format | local_exists |")
$lines.Add("|---|---|---|---|---|---|")
foreach ($item in $checkedRows) {
    $lines.Add("| $(To-MarkdownCell $item.Status) | $(To-MarkdownCell $item.RelPath) | $(To-MarkdownCell $item.AssetIdRaw) | $(To-MarkdownCell $item.AssetId) | $(To-MarkdownCell $item.Format) | $($item.LocalExists) |")
}
$lines.Add("")
$lines.Add("## Codex Rule")
$lines.Add("")
$lines.Add('- `asset_id` can be `123456`, `rbxassetid://123456`, or a Roblox URL containing `id=123456`.')
$lines.Add('- Empty `asset_id` means the row still needs confirmation unless `usage_hint` says `reference_only_layout_screenshot` or `no_asset_id_needed`.')
$lines.Add("- If the user's spreadsheet shows an ID but this report shows empty, ask the user to save the spreadsheet, then rerun this tool before changing UI scripts.")

$outDir = Split-Path -Parent $outFullPath
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}
$lines | Set-Content -LiteralPath $outFullPath -Encoding UTF8

if ($OpenCsv) {
    Start-Process -FilePath $csvFullPath
}

Write-Output "Wrote asset map check: $outFullPath"
foreach ($group in $statusCounts) {
    Write-Output "$($group.Name): $($group.Count)"
}
