param(
    [Parameter(Mandatory=$true)]
    [string]$InputPath,

    [string]$OutputDir = ""
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
        $allText = $lines -join [Environment]::NewLine
        if ($allText -match '\[trimmed\]') {
            throw "Cannot find GUI snapshot end marker in $Path. The Studio Output is truncated (`[trimmed`] was found). Re-run Tools/RobloxStudio_GuiSnapshotExporter.luau with a smaller TARGET_PATHS subtree, for example MainPage/HudLayer/TaskPanel or MainPage/HudLayer/KeyTipPanel."
        }
        throw "Cannot find GUI snapshot end marker in $Path. The export is incomplete. Make sure the copied Output includes ## END_ROBLOX_GUI_SNAPSHOT_JSON."
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

function Add-Line {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Text = ""
    )
    [void]$Lines.Add($Text)
}

function Get-NodePathTail {
    param([string]$Path)
    if ($Path.Length -le 120) {
        return $Path
    }
    return "..." + $Path.Substring($Path.Length - 117)
}

function Format-Udim2 {
    param($Value)
    if ($null -eq $Value) {
        return ""
    }
    return ("x=({0},{1}) y=({2},{3})" -f $Value.x.scale, $Value.x.offset, $Value.y.scale, $Value.y.offset)
}

function Format-Vector2 {
    param($Value)
    if ($null -eq $Value) {
        return ""
    }
    return ("({0},{1})" -f $Value.x, $Value.y)
}

function Get-DirectChildren {
    param(
        [array]$Nodes,
        [string]$ParentPath
    )
    $prefix = $ParentPath + "/"
    return @($Nodes | Where-Object {
        $_.path.StartsWith($prefix) -and ($_.path.Substring($prefix.Length) -notmatch "/")
    } | Sort-Object path)
}

$resolvedInput = (Resolve-Path -Path $InputPath).Path
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Split-Path -Parent $resolvedInput
}
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$jsonText = Get-SnapshotJsonText -Path $resolvedInput
$data = $jsonText | ConvertFrom-Json

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedInput)
$jsonPath = Join-Path $OutputDir ($baseName + ".json")
$summaryPath = Join-Path $OutputDir ($baseName + ".summary.md")

Set-Content -Path $jsonPath -Value $jsonText -Encoding UTF8

$nodes = @($data.nodes)
$lines = New-Object System.Collections.Generic.List[string]

Add-Line $lines "# Roblox GUI Snapshot Summary"
Add-Line $lines ""
Add-Line $lines "- Source: $resolvedInput"
Add-Line $lines "- ExportedAt: $($data.exportedAt)"
Add-Line $lines "- NodeCount: $($data.nodeCount)"
$targetText = (@($data.targetPaths) -join ', ')
if ([string]::IsNullOrWhiteSpace($targetText) -and $data.target) {
    $targetText = [string]$data.target
}
Add-Line $lines "- TargetPaths: $targetText"
Add-Line $lines ""

Add-Line $lines "## ScreenGui / Root Attributes"
foreach ($node in $nodes | Where-Object { $_.className -eq "ScreenGui" }) {
    Add-Line $lines "- $($node.path)"
    Add-Line $lines "  - attributes: $(To-ShortJson $node.attributes)"
    Add-Line $lines "  - props: Enabled=$(To-ShortJson $node.props.Enabled); DisplayOrder=$(To-ShortJson $node.props.DisplayOrder); IgnoreGuiInset=$(To-ShortJson $node.props.IgnoreGuiInset)"
}
Add-Line $lines ""

Add-Line $lines "## Visible / Page State"
$stateNodes = $nodes | Where-Object {
    ($_.attributes.IsAttrContent -eq $true) -or
    ($_.attributes.IsPage -eq $true) -or
    ($_.name -match "Page|Content|Window|Panel|Popup")
}
foreach ($node in $stateNodes | Sort-Object path) {
    if ($null -ne $node.props.Visible) {
        Add-Line $lines "- $(Get-NodePathTail $node.path): Visible=$($node.props.Visible)"
    }
}
Add-Line $lines ""

Add-Line $lines "## Buttons And Tab Targets"
$buttonNodes = $nodes | Where-Object { $_.className -eq "ImageButton" -or $_.className -eq "TextButton" }
foreach ($node in $buttonNodes | Sort-Object path) {
    $target = $node.attributes.TargetAttrContent
    $normal = $node.attributes.NormalImage
    $selected = $node.attributes.SelectedImage
    Add-Line $lines "- $(Get-NodePathTail $node.path): Target=$target; Image=$(To-ShortJson $node.props.Image); Normal=$normal; Selected=$selected"
}
Add-Line $lines ""

Add-Line $lines "## ScrollingFrame"
$scrollNodes = $nodes | Where-Object { $_.className -eq "ScrollingFrame" }
foreach ($node in $scrollNodes | Sort-Object path) {
    Add-Line $lines "- $(Get-NodePathTail $node.path)"
    Add-Line $lines "  - AutomaticCanvasSize=$(To-ShortJson $node.props.AutomaticCanvasSize); CanvasSize=$(To-ShortJson $node.props.CanvasSize); ScrollingDirection=$(To-ShortJson $node.props.ScrollingDirection); ScrollBarThickness=$(To-ShortJson $node.props.ScrollBarThickness)"
}
Add-Line $lines ""

Add-Line $lines "## Template Nodes"
$templateNodes = $nodes | Where-Object {
    $_.attributes.IsTemplate -eq $true -or $_.name -match "Template$"
}
if (@($templateNodes).Count -eq 0) {
    Add-Line $lines "- none"
} else {
    foreach ($node in $templateNodes | Sort-Object path) {
        Add-Line $lines "- $(Get-NodePathTail $node.path) [$($node.className)]"
        Add-Line $lines "  - Visible=$(To-ShortJson $node.props.Visible); Anchor=$(Format-Vector2 $node.props.AnchorPoint); Position=$(Format-Udim2 $node.props.Position); Size=$(Format-Udim2 $node.props.Size); ZIndex=$(To-ShortJson $node.props.ZIndex)"
        Add-Line $lines "  - attributes: $(To-ShortJson $node.attributes)"

        $children = Get-DirectChildren -Nodes $nodes -ParentPath $node.path
        foreach ($child in $children) {
            $text = To-ShortJson $child.props.Text
            $image = To-ShortJson $child.props.Image
            Add-Line $lines "  - child $(Get-NodePathTail $child.path) [$($child.className)]: Visible=$(To-ShortJson $child.props.Visible); Position=$(Format-Udim2 $child.props.Position); Size=$(Format-Udim2 $child.props.Size); Text=$text; Image=$image"
        }
    }
}
Add-Line $lines ""

Add-Line $lines "## Slice Images"
$sliceNodes = $nodes | Where-Object {
    ($_.className -eq "ImageLabel" -or $_.className -eq "ImageButton") -and $_.props.ScaleType -eq "Slice"
}
foreach ($node in $sliceNodes | Sort-Object path) {
    Add-Line $lines "- $(Get-NodePathTail $node.path): SourceAsset=$($node.attributes.SourceAsset); Image=$(To-ShortJson $node.props.Image); SliceCenter=$(To-ShortJson $node.props.SliceCenter); SliceScale=$(To-ShortJson $node.props.SliceScale)"
}
Add-Line $lines ""

Add-Line $lines "## TextScaled False Or Missing"
$textNodes = $nodes | Where-Object { $_.className -eq "TextLabel" -or $_.className -eq "TextButton" -or $_.className -eq "TextBox" }
foreach ($node in $textNodes | Where-Object { $_.props.TextScaled -ne $true } | Sort-Object path | Select-Object -First 120) {
    Add-Line $lines "- $(Get-NodePathTail $node.path): Text=$(To-ShortJson $node.props.Text); TextScaled=$(To-ShortJson $node.props.TextScaled); TextSize=$(To-ShortJson $node.props.TextSize)"
}
if (($textNodes | Where-Object { $_.props.TextScaled -ne $true }).Count -eq 0) {
    Add-Line $lines "- none"
}
Add-Line $lines ""

Add-Line $lines "## Constraints"
$constraintClasses = @("UIAspectRatioConstraint", "UIScale", "UISizeConstraint", "UITextSizeConstraint", "UIPadding", "UIListLayout", "UIGridLayout")
foreach ($className in $constraintClasses) {
    $count = @($nodes | Where-Object { $_.className -eq $className }).Count
    Add-Line $lines "- ${className}: $count"
}
Add-Line $lines ""

Add-Line $lines "## Image Asset Usage"
$imageNodes = $nodes | Where-Object { ($_.className -eq "ImageLabel" -or $_.className -eq "ImageButton") -and $_.props.Image }
foreach ($node in $imageNodes | Sort-Object path) {
    Add-Line $lines "- $(Get-NodePathTail $node.path): SourceAsset=$($node.attributes.SourceAsset); Image=$(To-ShortJson $node.props.Image); ScaleType=$(To-ShortJson $node.props.ScaleType)"
}

Set-Content -Path $summaryPath -Value $lines -Encoding UTF8

Write-Output "Parsed GUI snapshot:"
Write-Output "  JSON: $jsonPath"
Write-Output "  Summary: $summaryPath"
