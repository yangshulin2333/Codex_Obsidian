[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RunDir,

    [ValidateSet('Four', 'Six', 'Eight')]
    [string]$ViewSet = 'Six',

    [int]$CanvasWidth = 1536,
    [int]$CanvasHeight = 1024,

    [ValidatePattern('^#[0-9A-Fa-f]{6}$')]
    [string]$BackgroundColor = '#D7D7D7',

    [string]$BatchRoot,
    [string]$NormalizationConfigPath,

    [Alias('SymmetricPairs')]
    [switch]$ApprovedMirrorPairs,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Assert-ChildPath {
    param(
        [Parameter(Mandatory = $true)][string]$Parent,
        [Parameter(Mandatory = $true)][string]$Child
    )

    $parentFull = [System.IO.Path]::GetFullPath($Parent).TrimEnd('\') + '\'
    $childFull = [System.IO.Path]::GetFullPath($Child)
    if (-not $childFull.StartsWith($parentFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside run directory: $childFull"
    }
}

function Invoke-Magick {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)

    & $script:Magick @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "ImageMagick failed with exit code $LASTEXITCODE. Arguments: $($Arguments -join ' ')"
    }
}

function Test-ContainsChinese {
    param([Parameter(Mandatory = $true)][string]$Name)

    return $Name -match '[\u4e00-\u9fff]'
}

function Get-ViewFileName {
    param(
        [Parameter(Mandatory = $true)][string]$View,
        [Parameter(Mandatory = $true)][bool]$LegacyLayout
    )

    if ($LegacyLayout) {
        return "$View.png"
    }

    $fileName = switch ($View) {
        'front' { '正视图_front.png' }
        'back' { '背视图_back.png' }
        'left' { '左视图_left.png' }
        'right' { '右视图_right.png' }
        'left45' { '左45度_left45.png' }
        'right45' { '右45度_right45.png' }
        'top' { '顶视图_top.png' }
        'bottom' { '底视图_bottom.png' }
        default { throw "Unsupported view semantic: $View" }
    }
    return $fileName
}

function Get-ImageDimensions {
    param([Parameter(Mandatory = $true)][string]$Path)

    $raw = (& $script:Magick 'identify' '-format' '%w,%h' $Path | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $raw -notmatch '^(?<Width>\d+),(?<Height>\d+)$') {
        throw "IMAGE_DIMENSIONS_UNREADABLE: $Path ($raw)"
    }

    return [pscustomobject]@{
        Width = [int]$Matches.Width
        Height = [int]$Matches.Height
    }
}

function Get-SubjectGeometry {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][double]$FuzzPercent
    )

    $dimensions = Get-ImageDimensions -Path $Path
    $raw = (& $script:Magick $Path '-fuzz' "${FuzzPercent}%" '-trim' '-format' '%wx%h%X%Y' 'info:' | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $raw -notmatch '^(?<Width>\d+)x(?<Height>\d+)(?<X>[+-]\d+)(?<Y>[+-]\d+)$') {
        throw "SUBJECT_BOUNDS_UNREADABLE: $Path ($raw)"
    }

    $width = [int]$Matches.Width
    $height = [int]$Matches.Height
    $x = [int]$Matches.X
    $y = [int]$Matches.Y
    $right = $x + $width
    $bottom = $y + $height

    if ($x -le 0 -or $y -le 0 -or $right -ge $dimensions.Width -or $bottom -ge $dimensions.Height) {
        throw "SUBJECT_BOUNDS_UNRELIABLE: Subject/background separation touches a canvas edge. Use a flat background with padding and no ground shadow. Path=$Path Geometry=$raw Canvas=$($dimensions.Width)x$($dimensions.Height)"
    }

    return [pscustomobject]@{
        Width = $width
        Height = $height
        X = $x
        Y = $y
        Baseline = $bottom - 1
        CanvasWidth = $dimensions.Width
        CanvasHeight = $dimensions.Height
    }
}

function Get-RequiredProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value -or [string]::IsNullOrWhiteSpace([string]$property.Value)) {
        throw "NORMALIZATION_CONFIG_INVALID: Missing property '$Name'."
    }
    return $property.Value
}

function Read-NormalizationConfig {
    param([Parameter(Mandatory = $true)][string]$Path)

    try {
        $config = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
        throw "NORMALIZATION_CONFIG_INVALID: Could not parse JSON at $Path. $($_.Exception.Message)"
    }

    $version = [string](Get-RequiredProperty -Object $config -Name 'version')
    $profile = [string](Get-RequiredProperty -Object $config -Name 'profile')
    $referenceView = [string](Get-RequiredProperty -Object $config -Name 'referenceView')
    $referenceAxis = [string](Get-RequiredProperty -Object $config -Name 'referenceAxis')
    $targetOccupancyPercent = [double](Get-RequiredProperty -Object $config -Name 'targetOccupancyPercent')
    $groundDatumPercent = [double](Get-RequiredProperty -Object $config -Name 'groundDatumPercent')
    $backgroundFuzzPercent = [double](Get-RequiredProperty -Object $config -Name 'backgroundFuzzPercent')
    $scaleTolerancePercent = [double](Get-RequiredProperty -Object $config -Name 'scaleTolerancePercent')
    $maxAutoScalePercent = [double](Get-RequiredProperty -Object $config -Name 'maxAutoScalePercent')
    $autoNormalizeWithinLimit = [bool](Get-RequiredProperty -Object $config -Name 'autoNormalizeWithinLimit')
    $normalizationViews = @($config.normalizationViews | ForEach-Object { [string]$_ })
    $manualReviewViews = @($config.manualReviewViews | ForEach-Object { [string]$_ })

    if ($version -notin @('1.2', '1.3')) {
        throw "NORMALIZATION_CONFIG_INVALID: Expected version 1.2 or 1.3, got '$version'."
    }
    if ($profile -notin @('grounded-yaw', 'centered-yaw', 'measure-only')) {
        throw "NORMALIZATION_CONFIG_INVALID: Unsupported profile '$profile'."
    }
    if ($referenceAxis -notin @('vertical', 'horizontal')) {
        throw "NORMALIZATION_CONFIG_INVALID: referenceAxis must be vertical or horizontal."
    }
    if ($targetOccupancyPercent -lt 20 -or $targetOccupancyPercent -gt 90) {
        throw 'NORMALIZATION_CONFIG_INVALID: targetOccupancyPercent must be between 20 and 90.'
    }
    if ($groundDatumPercent -lt 50 -or $groundDatumPercent -gt 98) {
        throw 'NORMALIZATION_CONFIG_INVALID: groundDatumPercent must be between 50 and 98.'
    }
    if ($backgroundFuzzPercent -lt 0 -or $backgroundFuzzPercent -gt 20) {
        throw 'NORMALIZATION_CONFIG_INVALID: backgroundFuzzPercent must be between 0 and 20.'
    }
    if ($scaleTolerancePercent -lt 0 -or $scaleTolerancePercent -gt 20) {
        throw 'NORMALIZATION_CONFIG_INVALID: scaleTolerancePercent must be between 0 and 20.'
    }
    if ($maxAutoScalePercent -lt $scaleTolerancePercent -or $maxAutoScalePercent -gt 40) {
        throw 'NORMALIZATION_CONFIG_INVALID: maxAutoScalePercent must be >= scaleTolerancePercent and <= 40.'
    }
    if ($normalizationViews.Count -eq 0 -or $referenceView -notin $normalizationViews) {
        throw 'NORMALIZATION_CONFIG_INVALID: referenceView must be listed in normalizationViews.'
    }

    return [pscustomobject]@{
        Version = $version
        Profile = $profile
        ReferenceView = $referenceView
        ReferenceAxis = $referenceAxis
        TargetOccupancyPercent = $targetOccupancyPercent
        GroundDatumPercent = $groundDatumPercent
        BackgroundFuzzPercent = $backgroundFuzzPercent
        ScaleTolerancePercent = $scaleTolerancePercent
        MaxAutoScalePercent = $maxAutoScalePercent
        AutoNormalizeWithinLimit = $autoNormalizeWithinLimit
        NormalizationViews = $normalizationViews
        ManualReviewViews = $manualReviewViews
    }
}

function New-NormalizedSubjectImage {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$WorkingSubject,
        [Parameter(Mandatory = $true)]$Config,
        [Parameter(Mandatory = $true)][int]$OutputWidth,
        [Parameter(Mandatory = $true)][int]$OutputHeight,
        [Parameter(Mandatory = $true)][string]$OutputBackground
    )

    Invoke-Magick $Source '-fuzz' "$($Config.BackgroundFuzzPercent)%" '-trim' '+repage' '-strip' $WorkingSubject

    $targetAxisPixels = if ($Config.ReferenceAxis -eq 'vertical') {
        [int][Math]::Round($OutputHeight * $Config.TargetOccupancyPercent / 100.0)
    }
    else {
        [int][Math]::Round($OutputWidth * $Config.TargetOccupancyPercent / 100.0)
    }
    $resizeGeometry = if ($Config.ReferenceAxis -eq 'vertical') { "x$targetAxisPixels" } else { "${targetAxisPixels}x" }
    Invoke-Magick $WorkingSubject '-resize' $resizeGeometry '-strip' $WorkingSubject

    $subjectDimensions = Get-ImageDimensions -Path $WorkingSubject
    $x = [int][Math]::Floor(($OutputWidth - $subjectDimensions.Width) / 2.0)
    $y = if ($Config.Profile -eq 'grounded-yaw') {
        $targetBaseline = [int][Math]::Round($OutputHeight * $Config.GroundDatumPercent / 100.0)
        $targetBaseline - $subjectDimensions.Height + 1
    }
    else {
        [int][Math]::Floor(($OutputHeight - $subjectDimensions.Height) / 2.0)
    }

    if ($x -lt 0 -or $y -lt 0 -or ($x + $subjectDimensions.Width) -gt $OutputWidth -or ($y + $subjectDimensions.Height) -gt $OutputHeight) {
        throw "SUBJECT_NORMALIZATION_OVERFLOW: Subject does not fit target canvas after normalization. Size=$($subjectDimensions.Width)x$($subjectDimensions.Height) Offset=$x,$y Canvas=${OutputWidth}x${OutputHeight}"
    }

    Invoke-Magick '-size' "${OutputWidth}x${OutputHeight}" "xc:$OutputBackground" $WorkingSubject '-geometry' "+$x+$y" '-composite' '-strip' $Target
}

$magickCommand = Get-Command magick -ErrorAction SilentlyContinue
if ($null -eq $magickCommand) {
    throw 'ImageMagick (magick) is required but was not found in PATH.'
}
$script:Magick = $magickCommand.Source

if ($CanvasWidth -le 0 -or $CanvasHeight -le 0) {
    throw 'CanvasWidth and CanvasHeight must be positive integers.'
}

$runFull = [System.IO.Path]::GetFullPath($RunDir)
if (-not (Test-Path -LiteralPath $runFull -PathType Container)) {
    throw "Run directory does not exist: $runFull"
}

$preferredNames = [ordered]@{
    Accepted = '01_已通过视图_Accepted_Views'
    Staged = '00_待审核上传_Staged_Upload'
    Final = '00_正式上传_Hunyuan_Tripo'
    Checks = '_检查_Checks'
    Docs = '_文档_Docs'
}
$legacyNames = [ordered]@{
    Accepted = '01_accepted_views'
    Staged = '00_staged_hunyuan_tripo_upload'
    Final = '00_final_hunyuan_tripo_upload'
    Checks = '_checks'
    Docs = '_docs'
}

$preferredExists = @($preferredNames.Values | Where-Object { Test-Path -LiteralPath (Join-Path $runFull $_) }).Count -gt 0
$legacyExists = @($legacyNames.Values | Where-Object { Test-Path -LiteralPath (Join-Path $runFull $_) }).Count -gt 0
if ($preferredExists -and $legacyExists) {
    throw 'MIXED_LAYOUT: The run directory contains both v1.2 bilingual folders and v1.0 legacy English folders.'
}

$useLegacyLayout = $legacyExists
$layoutNames = if ($useLegacyLayout) { $legacyNames } else { $preferredNames }
if (-not $useLegacyLayout -and -not (Test-ContainsChinese -Name (Split-Path -Leaf $runFull))) {
    throw "PURE_ENGLISH_OUTPUT_NAME: New run directory must contain Chinese: $runFull"
}

$acceptedDir = Join-Path $runFull $layoutNames.Accepted
$stagedDir = Join-Path $runFull $layoutNames.Staged
$finalDir = Join-Path $runFull $layoutNames.Final
$checksDir = Join-Path $runFull $layoutNames.Checks
$docsDir = Join-Path $runFull $layoutNames.Docs
foreach ($path in @($acceptedDir, $stagedDir, $finalDir, $checksDir, $docsDir)) {
    Assert-ChildPath -Parent $runFull -Child $path
}

if (-not (Test-Path -LiteralPath $acceptedDir -PathType Container)) {
    throw "Accepted views directory is missing: $acceptedDir"
}
if (-not (Test-Path -LiteralPath $docsDir -PathType Container)) {
    throw "RUN_DOCUMENT_MISSING: Documents directory is missing: $docsDir"
}
if (-not (Test-Path -LiteralPath $checksDir -PathType Container)) {
    New-Item -ItemType Directory -Path $checksDir | Out-Null
}
if (Test-Path -LiteralPath $finalDir) {
    throw "APPROVED_FINAL_EXISTS: The approved final directory already exists and will not be overwritten: $finalDir"
}
if (Test-Path -LiteralPath $stagedDir) {
    throw "STAGED_OUTPUT_EXISTS: Review or archive the existing staged output before rerunning: $stagedDir"
}

$batchFull = $null
if (-not [string]::IsNullOrWhiteSpace($BatchRoot)) {
    $batchFull = [System.IO.Path]::GetFullPath($BatchRoot)
    if (-not (Test-Path -LiteralPath $batchFull -PathType Container)) {
        throw "BATCH_ROOT_MISSING: Batch root does not exist: $batchFull"
    }
    if (-not (Test-ContainsChinese -Name (Split-Path -Leaf $batchFull))) {
        throw "PURE_ENGLISH_OUTPUT_NAME: Batch root must contain Chinese: $batchFull"
    }
    $runParent = [System.IO.Directory]::GetParent($runFull).FullName.TrimEnd('\')
    if (-not $runParent.Equals($batchFull.TrimEnd('\'), [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "BATCH_ROOT_MISSING: Run directory must be a direct child of batch root. BatchRoot=$batchFull RunDir=$runFull"
    }
    $batchIndex = Join-Path $batchFull '批次交付索引_Batch_Delivery_Index.md'
    if (-not (Test-Path -LiteralPath $batchIndex -PathType Leaf)) {
        throw "BATCH_INDEX_MISSING: Required batch delivery index is missing: $batchIndex"
    }
}

$views = switch ($ViewSet) {
    'Four' { @('front', 'back', 'left', 'right') }
    'Six' { @('front', 'back', 'left', 'right', 'left45', 'right45') }
    'Eight' { @('front', 'back', 'left', 'right', 'top', 'bottom', 'left45', 'right45') }
}
$viewFileNames = [ordered]@{}
foreach ($view in $views) {
    $viewFileNames[$view] = Get-ViewFileName -View $view -LegacyLayout $useLegacyLayout
}
$expectedNames = @($views | ForEach-Object { $viewFileNames[$_] })

$requiredSourceViews = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($view in $views) {
    $sourceView = $view
    if ($ApprovedMirrorPairs -and $view -eq 'right') { $sourceView = 'left' }
    if ($ApprovedMirrorPairs -and $view -eq 'right45') { $sourceView = 'left45' }
    [void]$requiredSourceViews.Add($sourceView)
}
foreach ($sourceView in $requiredSourceViews) {
    $sourcePath = Join-Path $acceptedDir (Get-ViewFileName -View $sourceView -LegacyLayout $useLegacyLayout)
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
        throw "ACCEPTED_VIEW_MISSING: Required accepted source is missing for ${sourceView}: $sourcePath"
    }
}

$acceptedItems = @(Get-ChildItem -LiteralPath $acceptedDir -Force)
$unexpectedAccepted = @($acceptedItems | Where-Object { $_.PSIsContainer -or $_.Name -notin $expectedNames })
if ($unexpectedAccepted.Count -gt 0) {
    throw "ACCEPTED_FOLDER_DIRTY: Accepted directory contains unexpected items: $($unexpectedAccepted.Name -join ', ')"
}
$acceptedFileNames = @($acceptedItems | Where-Object { -not $_.PSIsContainer } | ForEach-Object { $_.Name })
$missingAccepted = @($expectedNames | Where-Object { $_ -notin $acceptedFileNames })
if ($missingAccepted.Count -gt 0) {
    throw "ACCEPTED_VIEW_SET_INCOMPLETE: Accepted directory must visibly contain the complete $ViewSet view set before finalization. Missing: $($missingAccepted -join ', ')"
}

$config = $null
$runDocumentProfile = if ($useLegacyLayout) { 'legacy-v1.0' } else { $null }
if (-not $useLegacyLayout) {
    $sharedRequiredDocs = @(
        '运行状态_RUN_STATE.md',
        '归一化配置_NORMALIZATION_CONFIG.json'
    )
    foreach ($requiredDoc in $sharedRequiredDocs) {
        $requiredPath = Join-Path $docsDir $requiredDoc
        if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
            throw "RUN_DOCUMENT_MISSING: Required run document is missing: $requiredPath"
        }
    }

    $compactLock = Join-Path $docsDir '资产锁_ASSET_LOCK.md'
    $legacyLockNames = @(
        '资产简报_ASSET_BRIEF.md',
        '物品一致性锁_IDENTITY_LOCK.md',
        '结构与深度锁_STRUCTURE_AND_DEPTH_LOCK.md'
    )
    $legacyLockPaths = @($legacyLockNames | ForEach-Object { Join-Path $docsDir $_ })
    $legacyLocksComplete = @($legacyLockPaths | Where-Object { -not (Test-Path -LiteralPath $_ -PathType Leaf) }).Count -eq 0
    if (Test-Path -LiteralPath $compactLock -PathType Leaf) {
        $runDocumentProfile = 'compact-v1.3'
    }
    elseif ($legacyLocksComplete) {
        $runDocumentProfile = 'detailed-v1.2'
    }
    else {
        throw "RUN_DOCUMENT_MISSING: Add 资产锁_ASSET_LOCK.md, or keep the complete v1.2 trio: $($legacyLockNames -join ', ')."
    }

    $configPath = if ([string]::IsNullOrWhiteSpace($NormalizationConfigPath)) {
        Join-Path $docsDir '归一化配置_NORMALIZATION_CONFIG.json'
    }
    else {
        [System.IO.Path]::GetFullPath($NormalizationConfigPath)
    }
    Assert-ChildPath -Parent $runFull -Child $configPath
    $config = Read-NormalizationConfig -Path $configPath
    if ($config.ReferenceView -notin $views) {
        throw "NORMALIZATION_CONFIG_INVALID: referenceView '$($config.ReferenceView)' is not part of ViewSet $ViewSet."
    }
}

$rawMetrics = [ordered]@{}
if ($null -ne $config) {
    foreach ($sourceView in $requiredSourceViews) {
        $sourcePath = Join-Path $acceptedDir (Get-ViewFileName -View $sourceView -LegacyLayout $useLegacyLayout)
        $geometry = Get-SubjectGeometry -Path $sourcePath -FuzzPercent $config.BackgroundFuzzPercent
        $axisPixels = if ($config.ReferenceAxis -eq 'vertical') { $geometry.Height } else { $geometry.Width }
        $canvasAxisPixels = if ($config.ReferenceAxis -eq 'vertical') { $geometry.CanvasHeight } else { $geometry.CanvasWidth }
        $rawMetrics[$sourceView] = [pscustomobject]@{
            SourcePath = $sourcePath
            Geometry = $geometry
            OccupancyPercent = 100.0 * $axisPixels / $canvasAxisPixels
        }
    }

    $referenceSource = $config.ReferenceView
    if ($ApprovedMirrorPairs -and $referenceSource -eq 'right') { $referenceSource = 'left' }
    if ($ApprovedMirrorPairs -and $referenceSource -eq 'right45') { $referenceSource = 'left45' }
    $referenceOccupancy = [double]$rawMetrics[$referenceSource].OccupancyPercent

    foreach ($view in $views) {
        if ($view -notin $config.NormalizationViews) { continue }
        $sourceView = $view
        if ($ApprovedMirrorPairs -and $view -eq 'right') { $sourceView = 'left' }
        if ($ApprovedMirrorPairs -and $view -eq 'right45') { $sourceView = 'left45' }
        $occupancy = [double]$rawMetrics[$sourceView].OccupancyPercent
        $correctionPercent = [Math]::Abs(($referenceOccupancy / $occupancy) - 1.0) * 100.0
        if ($correctionPercent -gt $config.MaxAutoScalePercent) {
            throw ("SUBJECT_SCALE_DRIFT: View {0} differs from reference occupancy by {1:N2}%, above maxAutoScalePercent {2:N2}%. Regenerate or manually review this view instead of hiding the drift with normalization." -f $view, $correctionPercent, $config.MaxAutoScalePercent)
        }
        if ($correctionPercent -gt $config.ScaleTolerancePercent -and -not $config.AutoNormalizeWithinLimit) {
            throw ("SUBJECT_SCALE_REVIEW_REQUIRED: View {0} differs by {1:N2}%, above scaleTolerancePercent {2:N2}%." -f $view, $correctionPercent, $config.ScaleTolerancePercent)
        }
    }
}

$sheetName = if ($useLegacyLayout) { 'multiview_contact_sheet.png' } else { '多视图联系表_multiview_contact_sheet.png' }
$auditName = if ($useLegacyLayout) { 'COPY_AUDIT.md' } else { '复制审计_COPY_AUDIT.md' }
$reportName = if ($useLegacyLayout) { 'NORMALIZATION_REPORT.md' } else { '归一化报告_NORMALIZATION_REPORT.md' }
$manifestName = if ($useLegacyLayout) { 'STAGED_MANIFEST.json' } else { '待审核清单_STAGED_MANIFEST.json' }
$sheet = Join-Path $checksDir $sheetName
$auditPath = Join-Path $docsDir $auditName
$reportPath = Join-Path $docsDir $reportName
$manifestPath = Join-Path $docsDir $manifestName
foreach ($generatedArtifact in @($sheet, $auditPath, $reportPath, $manifestPath)) {
    Assert-ChildPath -Parent $runFull -Child $generatedArtifact
    if ((Test-Path -LiteralPath $generatedArtifact) -and -not $Force) {
        throw "GENERATED_ARTIFACT_EXISTS: Use -Force only after confirming replacement: $generatedArtifact"
    }
}

$workDir = Join-Path $checksDir ("._finalize_" + [guid]::NewGuid().ToString('N'))
$workStagedDir = Join-Path $workDir 'staged'
$workSheet = Join-Path $workDir $sheetName
$workAudit = Join-Path $workDir $auditName
$workReport = Join-Path $workDir $reportName
$workManifest = Join-Path $workDir $manifestName
Assert-ChildPath -Parent $runFull -Child $workDir
New-Item -ItemType Directory -Path $workStagedDir -Force | Out-Null

$outputMetrics = [System.Collections.Generic.List[object]]::new()

try {
    foreach ($view in $views) {
        $target = Join-Path $workStagedDir $viewFileNames[$view]
        Assert-ChildPath -Parent $runFull -Child $target

        $mirrorSourceView = $null
        if ($ApprovedMirrorPairs -and $view -eq 'right') { $mirrorSourceView = 'left' }
        if ($ApprovedMirrorPairs -and $view -eq 'right45') { $mirrorSourceView = 'left45' }

        if ($null -ne $mirrorSourceView) {
            $mirrorSource = Join-Path $workStagedDir $viewFileNames[$mirrorSourceView]
            if (-not (Test-Path -LiteralPath $mirrorSource -PathType Leaf)) {
                throw "MIRROR_SOURCE_NOT_READY: $mirrorSource"
            }
            Invoke-Magick $mirrorSource '-flop' '-strip' $target
            $sourceView = $mirrorSourceView
            $mode = "mirror_of_$mirrorSourceView"
        }
        else {
            $sourceView = $view
            $source = Join-Path $acceptedDir (Get-ViewFileName -View $sourceView -LegacyLayout $useLegacyLayout)
            if ($null -ne $config -and $view -in $config.NormalizationViews -and $config.Profile -ne 'measure-only') {
                $workingSubject = Join-Path $workDir ("_subject_${view}.png")
                New-NormalizedSubjectImage -Source $source -Target $target -WorkingSubject $workingSubject -Config $config -OutputWidth $CanvasWidth -OutputHeight $CanvasHeight -OutputBackground $BackgroundColor
                $mode = $config.Profile
            }
            else {
                Invoke-Magick $source '-resize' "${CanvasWidth}x${CanvasHeight}" '-gravity' 'center' '-background' $BackgroundColor '-extent' "${CanvasWidth}x${CanvasHeight}" '-strip' $target
                $mode = 'canvas-only-manual-review'
            }
        }

        $outputDimensions = Get-ImageDimensions -Path $target
        if ($outputDimensions.Width -ne $CanvasWidth -or $outputDimensions.Height -ne $CanvasHeight) {
            throw "CANVAS_MISMATCH: $target is $($outputDimensions.Width)x$($outputDimensions.Height)."
        }

        $outputGeometry = if ($null -ne $config) { Get-SubjectGeometry -Path $target -FuzzPercent $config.BackgroundFuzzPercent } else { $null }
        $rawMetric = if ($null -ne $config) { $rawMetrics[$sourceView] } else { $null }
        $outputMetrics.Add([pscustomobject]@{
                View = $view
                SourceView = $sourceView
                Mode = $mode
                FileName = $viewFileNames[$view]
                RawOccupancyPercent = if ($null -ne $rawMetric) { [double]$rawMetric.OccupancyPercent } else { $null }
                OutputGeometry = $outputGeometry
                Hash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
            })
    }

    $mirrorAudit = [ordered]@{}
    if ($ApprovedMirrorPairs) {
        $pairs = @(,@('left', 'right'))
        if ($ViewSet -in @('Six', 'Eight')) {
            $pairs += ,@('left45', 'right45')
        }
        foreach ($pair in $pairs) {
            $leftName = $pair[0]
            $rightName = $pair[1]
            $roundtrip = Join-Path $workDir "_tmp_${rightName}_roundtrip.png"
            Invoke-Magick (Join-Path $workStagedDir $viewFileNames[$rightName]) '-flop' $roundtrip
            $mean = (& $script:Magick (Join-Path $workStagedDir $viewFileNames[$leftName]) $roundtrip '-compose' 'difference' '-composite' '-format' '%[fx:mean]' 'info:' | Out-String).Trim()
            if ($LASTEXITCODE -ne 0) {
                throw "Mirror difference check failed for $leftName/$rightName."
            }
            if ([double]::Parse($mean, [System.Globalization.CultureInfo]::InvariantCulture) -ne 0.0) {
                throw "Mirror validation failed for $leftName/$rightName. Mean difference: $mean"
            }
            $mirrorAudit["${leftName}_${rightName}_mean_difference"] = $mean
        }
    }

    $ordered = switch ($ViewSet) {
        'Four' { @('front', 'back', 'left', 'right') }
        'Six' { @('front', 'back', 'left45', 'right45', 'left', 'right') }
        'Eight' { @('front', 'back', 'top', 'bottom', 'left45', 'right45', 'left', 'right') }
    }
    $sheetInputs = @($ordered | ForEach-Object { Join-Path $workStagedDir $viewFileNames[$_] })
    $tile = switch ($ViewSet) {
        'Four' { '2x2' }
        'Six' { '3x2' }
        'Eight' { '4x2' }
    }
    Invoke-Magick 'montage' @sheetInputs '-thumbnail' '512x341' '-tile' $tile '-geometry' '+12+12' '-background' '#C9CDD2' $workSheet

    $actualStaged = @(Get-ChildItem -LiteralPath $workStagedDir -File | Sort-Object Name)
    if ($actualStaged.Count -ne $expectedNames.Count) {
        throw "STAGED_FILE_COUNT_MISMATCH: Expected $($expectedNames.Count), got $($actualStaged.Count)."
    }
    $missing = @($expectedNames | Where-Object { $_ -notin $actualStaged.Name })
    if ($missing.Count -gt 0) {
        throw "STAGED_FILES_MISSING: $($missing -join ', ')"
    }

    $reportLines = @(
        '# 主体归一化报告 / Subject Normalization Report',
        '',
        "- Run directory: $runFull",
        "- Profile: $(if ($null -ne $config) { $config.Profile } else { 'legacy-canvas-only' })",
        "- Reference view: $(if ($null -ne $config) { $config.ReferenceView } else { 'not configured' })",
        "- Reference axis: $(if ($null -ne $config) { $config.ReferenceAxis } else { 'not configured' })",
        "- Target occupancy: $(if ($null -ne $config) { $config.TargetOccupancyPercent } else { 'not configured' })%",
        "- Ground datum: $(if ($null -ne $config) { $config.GroundDatumPercent } else { 'not configured' })%",
        '',
        '| View | Source | Mode | Raw occupancy | Output bounds | Baseline | SHA256 |',
        '|---|---|---|---:|---|---:|---|'
    )
    foreach ($metric in $outputMetrics) {
        $rawOccupancyText = if ($null -eq $metric.RawOccupancyPercent) { 'n/a' } else { '{0:N2}%' -f $metric.RawOccupancyPercent }
        $boundsText = if ($null -eq $metric.OutputGeometry) { 'manual review' } else { "$($metric.OutputGeometry.Width)x$($metric.OutputGeometry.Height)+$($metric.OutputGeometry.X)+$($metric.OutputGeometry.Y)" }
        $baselineText = if ($null -eq $metric.OutputGeometry) { 'n/a' } else { [string]$metric.OutputGeometry.Baseline }
        $reportLines += "| $($metric.View) | $($metric.SourceView) | $($metric.Mode) | $rawOccupancyText | $boundsText | $baselineText | $($metric.Hash) |"
    }
    $reportLines += @('', '- Mechanical status: `FILES_READY`', '- Human contact-sheet review: `PENDING`')
    Set-Content -LiteralPath $workReport -Value $reportLines -Encoding UTF8

    $manifest = [ordered]@{
        version = '1.3'
        status = 'FILES_READY'
        runDirectory = $runFull
        runDocumentProfile = $runDocumentProfile
        viewSet = $ViewSet
        canvas = "${CanvasWidth}x${CanvasHeight}"
        files = @($outputMetrics | ForEach-Object {
                [ordered]@{
                    view = $_.View
                    fileName = $_.FileName
                    sha256 = $_.Hash
                }
            })
    }
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $workManifest -Encoding UTF8

    $mirrorLines = if ($mirrorAudit.Count -eq 0) {
        '- Mirror audit: not requested.'
    }
    else {
        @($mirrorAudit.GetEnumerator() | ForEach-Object { "- $($_.Key): $($_.Value)" })
    }
    $auditLines = @(
        '# 多视图复制审计 / Multiview Copy Audit',
        '',
        "- Batch root: $batchFull",
        "- Run directory: $runFull",
        "- Run document profile: $runDocumentProfile",
        "- View set: $ViewSet",
        "- Staged directory: $stagedDir",
        "- Planned final directory: $finalDir",
        "- Canvas: ${CanvasWidth}x${CanvasHeight}",
        '- Normalization: subject-axis normalization when configured; no non-uniform stretching.',
        "- User-approved mirror pairs: $($ApprovedMirrorPairs.IsPresent)",
        "- Contact sheet: $sheet",
        "- Normalization report: $reportPath",
        "- Staged manifest: $manifestPath",
        '',
        '## Mirror Audit',
        '',
        $mirrorLines,
        '',
        '## Human Gates',
        '',
        '- Identity check: PENDING',
        '- Proportion check: PENDING',
        '- Camera-angle check: PENDING',
        '- Material-zone check: PENDING',
        '- Contact-sheet approval: PENDING',
        '',
        '## Result',
        '',
        '- Mechanical status: FILES_READY',
        '- Delivery status: NOT_APPROVED'
    )
    Set-Content -LiteralPath $workAudit -Value $auditLines -Encoding UTF8

    Move-Item -LiteralPath $workSheet -Destination $sheet -Force:$Force
    Move-Item -LiteralPath $workReport -Destination $reportPath -Force:$Force
    Move-Item -LiteralPath $workManifest -Destination $manifestPath -Force:$Force
    Move-Item -LiteralPath $workAudit -Destination $auditPath -Force:$Force
    Move-Item -LiteralPath $workStagedDir -Destination $stagedDir

    [pscustomobject]@{
        Status = 'FILES_READY'
        BatchRoot = $batchFull
        RunDirectory = $runFull
        ViewSet = $ViewSet
        RunDocumentProfile = $runDocumentProfile
        StagedDirectory = $stagedDir
        FinalDirectory = $finalDir
        StagedFileCount = $actualStaged.Count
        Canvas = "${CanvasWidth}x${CanvasHeight}"
        ContactSheet = $sheet
        CopyAudit = $auditPath
        NormalizationReport = $reportPath
        StagedManifest = $manifestPath
        HumanReviewRequired = $true
        DirectoryReportingRequired = $true
    }
}
finally {
    if (Test-Path -LiteralPath $workDir -PathType Container) {
        Assert-ChildPath -Parent $runFull -Child $workDir
        Remove-Item -LiteralPath $workDir -Recurse -Force
    }
}
