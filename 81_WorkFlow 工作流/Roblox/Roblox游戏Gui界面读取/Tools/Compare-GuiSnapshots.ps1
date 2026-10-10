param(
    [Parameter(Mandatory=$true)]
    [string]$Before,

    [Parameter(Mandatory=$true)]
    [string]$After,

    [string]$OutputPath = "",

    [string]$BeforeRoot = "",

    [string]$AfterRoot = ""
)

$ErrorActionPreference = "Stop"

function Get-SnapshotJsonText {
    param([string]$Path)

    $lines = Get-Content -Path $Path -Encoding UTF8
    $beginPatterns = @(
        "## BEGIN_ROBLOX_GUI_SNAPSHOT_JSON",
        "## BEGIN_MAIN_GUI_UI_SNAPSHOT_JSON"
    )
    $endPatterns = @(
        "## END_ROBLOX_GUI_SNAPSHOT_JSON",
        "## END_MAIN_GUI_UI_SNAPSHOT_JSON"
    )

    $beginLine = $null
    foreach ($pattern in $beginPatterns) {
        $match = $lines | Select-String -Pattern ([regex]::Escape($pattern)) | Select-Object -Last 1
        if ($match) {
            $beginLine = $match.LineNumber
            break
        }
    }
    if (-not $beginLine) {
        throw "Cannot find GUI snapshot begin marker in $Path"
    }

    $endLine = $null
    foreach ($pattern in $endPatterns) {
        $match = $lines | Select-String -Pattern ([regex]::Escape($pattern)) | Where-Object { $_.LineNumber -gt $beginLine } | Select-Object -First 1
        if ($match) {
            $endLine = $match.LineNumber
            break
        }
    }
    if (-not $endLine) {
        throw "Cannot find GUI snapshot end marker in $Path"
    }

    $chunks = New-Object System.Collections.Generic.List[string]
    for ($i = $beginLine; $i -le $endLine; $i++) {
        $line = $lines[$i - 1]
        $hadStudioPrefix = $line -match '^\s*\d{2}:\d{2}:\d{2}\.\d+\s+'
        $line = $line -replace '^\s*\d{2}:\d{2}:\d{2}\.\d+\s+', ''
        if ($hadStudioPrefix) {
            $line = $line -replace '\s+-\s+[^-]*$', ''
        }
        if ($line -match '## BEGIN_.*GUI.*SNAPSHOT_JSON') {
            continue
        }
        if ($line -match '## END_.*GUI.*SNAPSHOT_JSON') {
            continue
        }
        [void]$chunks.Add($line)
    }

    return ($chunks -join "")
}

function Test-Prop {
    param(
        $Object,
        [string]$Name
    )
    return $null -ne $Object -and $null -ne $Object.PSObject.Properties[$Name]
}

function Normalize-SnapshotData {
    param(
        $Data,
        [string]$SourcePath
    )

    if (Test-Prop $Data "nodes") {
        return $Data
    }

    if (Test-Prop $Data "snapshot") {
        return Normalize-SnapshotData -Data $Data.snapshot -SourcePath $SourcePath
    }

    if (Test-Prop $Data "segments") {
        $allNodes = New-Object System.Collections.Generic.List[object]
        $segmentNames = New-Object System.Collections.Generic.List[string]
        $segmentValue = $Data.segments

        if ($segmentValue -is [System.Array]) {
            foreach ($segment in @($segmentValue)) {
                $segmentName = $segment.name
                if ([string]::IsNullOrWhiteSpace($segmentName)) {
                    $segmentName = $segment.jobName
                }
                if ([string]::IsNullOrWhiteSpace($segmentName)) {
                    $segmentName = "Segment$($segmentNames.Count + 1)"
                }
                [void]$segmentNames.Add($segmentName)

                $snapshot = $segment
                if (Test-Prop $segment "snapshot") {
                    $snapshot = $segment.snapshot
                }
                foreach ($node in @($snapshot.nodes)) {
                    [void]$allNodes.Add($node)
                }
            }
        } else {
            foreach ($prop in @($segmentValue.PSObject.Properties)) {
                $segmentName = $prop.Name
                [void]$segmentNames.Add($segmentName)

                $segment = $prop.Value
                $snapshot = $segment
                if (Test-Prop $segment "snapshot") {
                    $snapshot = $segment.snapshot
                }
                foreach ($node in @($snapshot.nodes)) {
                    [void]$allNodes.Add($node)
                }
            }
        }

        return [pscustomobject]@{
            exportedAt = $Data.exportedAt
            nodeCount = $allNodes.Count
            nodes = $allNodes.ToArray()
            targetPaths = $segmentNames.ToArray()
            sourceKind = "http-combined"
        }
    }

    throw "Cannot find GUI snapshot nodes in $SourcePath. Expected Output markdown, segment JSON, or HTTP combined JSON."
}

function Read-SnapshotData {
    param([string]$Path)

    $ext = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
    if ($ext -eq ".json") {
        $raw = Get-Content -Raw -Path $Path -Encoding UTF8
        return Normalize-SnapshotData -Data ($raw | ConvertFrom-Json) -SourcePath $Path
    }

    return Normalize-SnapshotData -Data ((Get-SnapshotJsonText -Path $Path) | ConvertFrom-Json) -SourcePath $Path
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

function Get-ValueByPath {
    param(
        $Object,
        [string]$Path
    )

    $current = $Object
    foreach ($part in $Path.Split(".")) {
        if ($null -eq $current) {
            return $null
        }
        $prop = $current.PSObject.Properties[$part]
        if ($null -eq $prop) {
            return $null
        }
        $current = $prop.Value
    }
    return $current
}

function Normalize-NodePath {
    param(
        [string]$Path,
        [string]$Root
    )

    if ([string]::IsNullOrWhiteSpace($Root)) {
        return $Path
    }

    $cleanRoot = $Root.TrimEnd("/")
    if ($Path -eq $cleanRoot) {
        return ""
    }
    if ($Path.StartsWith($cleanRoot + "/")) {
        return $Path.Substring($cleanRoot.Length + 1)
    }
    return $Path
}

function Get-NodeMap {
    param(
        $Data,
        [string]$Root = ""
    )
    $map = @{}
    foreach ($node in @($Data.nodes)) {
        $map[(Normalize-NodePath -Path $node.path -Root $Root)] = $node
    }
    return $map
}

$beforePath = (Resolve-Path -Path $Before).Path
$afterPath = (Resolve-Path -Path $After).Path

$beforeData = Read-SnapshotData -Path $beforePath
$afterData = Read-SnapshotData -Path $afterPath

$beforeMap = Get-NodeMap -Data $beforeData -Root $BeforeRoot
$afterMap = Get-NodeMap -Data $afterData -Root $AfterRoot

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $beforeBase = [System.IO.Path]::GetFileNameWithoutExtension($beforePath)
    $afterBase = [System.IO.Path]::GetFileNameWithoutExtension($afterPath)
    $outName = "${beforeBase}_vs_${afterBase}.diff.md"
    $OutputPath = Join-Path (Split-Path -Parent $afterPath) $outName
}

$keyPaths = @(
    "className",
    "attributes.SourceAsset",
    "attributes.NormalImage",
    "attributes.SelectedImage",
    "attributes.TargetAttrContent",
    "attributes.CurrentAttrContent",
    "attributes.IsTemplate",
    "attributes.IsWindow",
    "attributes.IsPage",
    "attributes.CenteredItemGapPx",
    "attributes.DesignW",
    "attributes.DesignH",
    "props.Visible",
    "props.AnchorPoint",
    "props.Position",
    "props.Size",
    "props.Rotation",
    "props.ZIndex",
    "props.LayoutOrder",
    "props.ClipsDescendants",
    "props.BackgroundColor3",
    "props.BackgroundTransparency",
    "props.Image",
    "props.ImageColor3",
    "props.ImageTransparency",
    "props.ScaleType",
    "props.SliceCenter",
    "props.SliceScale",
    "props.Text",
    "props.Font",
    "props.TextScaled",
    "props.TextSize",
    "props.TextWrapped",
    "props.TextColor3",
    "props.TextTransparency",
    "props.TextStrokeColor3",
    "props.TextStrokeTransparency",
    "props.TextXAlignment",
    "props.TextYAlignment",
    "props.RichText",
    "props.CanvasSize",
    "props.AutomaticCanvasSize",
    "props.ScrollingDirection",
    "props.ScrollBarThickness",
    "props.Padding",
    "props.PaddingTop",
    "props.PaddingBottom",
    "props.PaddingLeft",
    "props.PaddingRight",
    "props.CellPadding",
    "props.CellSize",
    "props.FillDirection",
    "props.HorizontalAlignment",
    "props.VerticalAlignment",
    "props.SortOrder"
)

$lines = New-Object System.Collections.Generic.List[string]

Add-Line $lines "# Roblox GUI Snapshot Diff"
Add-Line $lines ""
Add-Line $lines "- Before: $beforePath"
Add-Line $lines "- After: $afterPath"
if (-not [string]::IsNullOrWhiteSpace($BeforeRoot)) {
    Add-Line $lines "- BeforeRoot: $BeforeRoot"
}
if (-not [string]::IsNullOrWhiteSpace($AfterRoot)) {
    Add-Line $lines "- AfterRoot: $AfterRoot"
}
Add-Line $lines "- Before ExportedAt: $($beforeData.exportedAt)"
Add-Line $lines "- After ExportedAt: $($afterData.exportedAt)"
Add-Line $lines "- Before NodeCount: $($beforeData.nodeCount)"
Add-Line $lines "- After NodeCount: $($afterData.nodeCount)"
Add-Line $lines ""

$beforePaths = @($beforeMap.Keys | Sort-Object)
$afterPaths = @($afterMap.Keys | Sort-Object)
$beforeSet = @{}
$afterSet = @{}
foreach ($path in $beforePaths) { $beforeSet[$path] = $true }
foreach ($path in $afterPaths) { $afterSet[$path] = $true }

$added = @($afterPaths | Where-Object { -not $beforeSet.ContainsKey($_) })
$removed = @($beforePaths | Where-Object { -not $afterSet.ContainsKey($_) })
$common = @($afterPaths | Where-Object { $beforeSet.ContainsKey($_) })

Add-Line $lines "## Added Nodes"
if ($added.Count -eq 0) {
    Add-Line $lines "- none"
} else {
    foreach ($path in $added) {
        $node = $afterMap[$path]
        Add-Line $lines "- $path [$($node.className)]"
    }
}
Add-Line $lines ""

Add-Line $lines "## Removed Nodes"
if ($removed.Count -eq 0) {
    Add-Line $lines "- none"
} else {
    foreach ($path in $removed) {
        $node = $beforeMap[$path]
        Add-Line $lines "- $path [$($node.className)]"
    }
}
Add-Line $lines ""

Add-Line $lines "## Changed Nodes"
$changedCount = 0
foreach ($path in $common) {
    $beforeNode = $beforeMap[$path]
    $afterNode = $afterMap[$path]
    $nodeChanges = New-Object System.Collections.Generic.List[string]

    foreach ($keyPath in $keyPaths) {
        $beforeValue = To-ShortJson (Get-ValueByPath $beforeNode $keyPath)
        $afterValue = To-ShortJson (Get-ValueByPath $afterNode $keyPath)
        if ($beforeValue -ne $afterValue) {
            [void]$nodeChanges.Add(('  - {0}: `{1}` -> `{2}`' -f $keyPath, $beforeValue, $afterValue))
        }
    }

    if ($nodeChanges.Count -gt 0) {
        $changedCount += 1
        Add-Line $lines "- $path [$($afterNode.className)]"
        foreach ($line in $nodeChanges) {
            Add-Line $lines $line
        }
    }
}

if ($changedCount -eq 0) {
    Add-Line $lines "- none"
}

Set-Content -Path $OutputPath -Value $lines -Encoding UTF8

Write-Output "Compared GUI snapshots:"
Write-Output "  Diff: $OutputPath"
