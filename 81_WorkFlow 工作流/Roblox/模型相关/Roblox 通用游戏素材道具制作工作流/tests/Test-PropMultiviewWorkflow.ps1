[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$workflowRoot = Split-Path -Parent $PSScriptRoot
$finalizeScript = Join-Path $workflowRoot 'scripts\Finalize-PropMultiview.ps1'
$approveScript = Join-Path $workflowRoot 'scripts\Approve-PropMultiview.ps1'
$magick = (Get-Command magick -ErrorAction Stop).Source
$background = '#D7D7D7'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("CodexPropMultiviewTests_" + [guid]::NewGuid().ToString('N'))
$tempRootFull = [System.IO.Path]::GetFullPath($tempRoot)
$systemTempFull = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\') + '\'

if (-not $tempRootFull.StartsWith($systemTempFull, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Unsafe test root: $tempRootFull"
}

function Assert-True {
    param(
        [Parameter(Mandatory = $true)][bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if (-not $Condition) {
        throw "ASSERT_TRUE_FAILED: $Message"
    }
}

function Assert-ThrowsCode {
    param(
        [Parameter(Mandatory = $true)][scriptblock]$Action,
        [Parameter(Mandatory = $true)][string]$ExpectedCode
    )

    try {
        & $Action
    }
    catch {
        if ($_.Exception.Message -notmatch [regex]::Escape($ExpectedCode)) {
            throw "ASSERT_THROW_CODE_FAILED: expected '$ExpectedCode', got '$($_.Exception.Message)'"
        }
        return
    }

    throw "ASSERT_THROW_CODE_FAILED: expected '$ExpectedCode', but no exception was thrown."
}

function Invoke-TestMagick {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)

    & $magick @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "ImageMagick test fixture failed: $($Arguments -join ' ')"
    }
}

function New-SyntheticView {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][int]$SubjectHeight,
        [int]$SubjectWidth = 120,
        [int]$CanvasWidth = 400,
        [int]$CanvasHeight = 300,
        [int]$BaselineY = 270,
        [switch]$DirtyBackground
    )

    $left = [int](($CanvasWidth - $SubjectWidth) / 2)
    $right = $left + $SubjectWidth - 1
    $top = $BaselineY - $SubjectHeight + 1
    $base = if ($DirtyBackground) { 'gradient:#D7D7D7-#AAB8C8' } else { "xc:$background" }
    Invoke-TestMagick '-size' "${CanvasWidth}x${CanvasHeight}" $base '-fill' '#245DDB' '-draw' "rectangle $left,$top $right,$BaselineY" $Path
}

function New-RunFixture {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [int]$FrontHeight = 180,
        [int]$BackHeight = 176,
        [int]$LeftHeight = 168,
        [int]$Left45Height = 174,
        [switch]$OmitAssetLock,
        [switch]$UseLegacyLockDocs,
        [string]$ConfigVersion = '1.3',
        [switch]$OmitMirroredAccepted,
        [switch]$DirtyLeftBackground,
        [string]$ParentRoot = $tempRootFull
    )

    $runDir = Join-Path $ParentRoot $Name
    $accepted = Join-Path $runDir '01_已通过视图_Accepted_Views'
    $docs = Join-Path $runDir '_文档_Docs'
    foreach ($path in @(
            $accepted,
            $docs,
            (Join-Path $runDir '_检查_Checks'),
            (Join-Path $runDir '_源图_Source'),
            (Join-Path $runDir '_候选图_Candidates')
        )) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }

    $requiredDocs = @('运行状态_RUN_STATE.md')
    if ($UseLegacyLockDocs) {
        $requiredDocs += @(
            '资产简报_ASSET_BRIEF.md',
            '物品一致性锁_IDENTITY_LOCK.md',
            '结构与深度锁_STRUCTURE_AND_DEPTH_LOCK.md'
        )
    }
    elseif (-not $OmitAssetLock) {
        $requiredDocs += '资产锁_ASSET_LOCK.md'
    }
    foreach ($name in $requiredDocs) {
        Set-Content -LiteralPath (Join-Path $docs $name) -Value "# test fixture`n" -Encoding UTF8
    }

    $config = [ordered]@{
        version = $ConfigVersion
        profile = 'grounded-yaw'
        referenceView = 'front'
        referenceAxis = 'vertical'
        targetOccupancyPercent = 60.0
        groundDatumPercent = 90.0
        backgroundFuzzPercent = 6.0
        scaleTolerancePercent = 3.0
        maxAutoScalePercent = 10.0
        autoNormalizeWithinLimit = $true
        normalizationViews = @('front', 'back', 'left', 'right', 'left45', 'right45')
        manualReviewViews = @('top', 'bottom')
    }
    $config | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $docs '归一化配置_NORMALIZATION_CONFIG.json') -Encoding UTF8

    New-SyntheticView -Path (Join-Path $accepted '正视图_front.png') -SubjectHeight $FrontHeight
    New-SyntheticView -Path (Join-Path $accepted '背视图_back.png') -SubjectHeight $BackHeight
    New-SyntheticView -Path (Join-Path $accepted '左视图_left.png') -SubjectHeight $LeftHeight -DirtyBackground:$DirtyLeftBackground
    New-SyntheticView -Path (Join-Path $accepted '左45度_left45.png') -SubjectHeight $Left45Height
    if (-not $OmitMirroredAccepted) {
        Invoke-TestMagick (Join-Path $accepted '左视图_left.png') '-flop' (Join-Path $accepted '右视图_right.png')
        Invoke-TestMagick (Join-Path $accepted '左45度_left45.png') '-flop' (Join-Path $accepted '右45度_right45.png')
    }

    return $runDir
}

function Get-TrimGeometry {
    param([Parameter(Mandatory = $true)][string]$Path)

    $raw = (& $magick $Path '-fuzz' '6%' '-trim' '-format' '%wx%h%X%Y' 'info:' | Out-String).Trim()
    if ($raw -notmatch '^(?<Width>\d+)x(?<Height>\d+)\+(?<X>\d+)\+(?<Y>\d+)$') {
        throw "Could not parse trim geometry: $raw"
    }
    return [pscustomobject]@{
        Width = [int]$Matches.Width
        Height = [int]$Matches.Height
        X = [int]$Matches.X
        Y = [int]$Matches.Y
        Baseline = [int]$Matches.Y + [int]$Matches.Height - 1
    }
}

New-Item -ItemType Directory -Path $tempRootFull -Force | Out-Null

try {
    Write-Output 'TEST 1: grounded subject normalization, staged publication, mirror audit, and approval'
    $happyRun = New-RunFixture -Name '测试RPG药水瓶_多视图'
    $result = & $finalizeScript -RunDir $happyRun -ViewSet Six -CanvasWidth 400 -CanvasHeight 300 -BackgroundColor $background -ApprovedMirrorPairs
    Assert-True ($result.Status -eq 'FILES_READY') 'Mechanical finalization must stop at FILES_READY.'
    Assert-True ($result.RunDocumentProfile -eq 'compact-v1.3') 'New runs must use the compact v1.3 document profile.'
    Assert-True (Test-Path -LiteralPath $result.StagedDirectory -PathType Container) 'Staged directory was not published.'
    Assert-True (-not (Test-Path -LiteralPath $result.FinalDirectory)) 'Final directory must not exist before human approval.'
    Assert-True ((Get-ChildItem -LiteralPath $result.StagedDirectory -File).Count -eq 6) 'Staged directory must contain six PNG files.'
    Assert-True (Test-Path -LiteralPath $result.NormalizationReport -PathType Leaf) 'Normalization report is missing.'
    Assert-True (Test-Path -LiteralPath $result.StagedManifest -PathType Leaf) 'Staged manifest is missing.'
    Assert-True ((Get-Content -LiteralPath $result.CopyAudit -Raw -Encoding UTF8) -match 'FILES_READY') 'Copy audit must use FILES_READY.'

    $geometries = Get-ChildItem -LiteralPath $result.StagedDirectory -File -Filter '*.png' | ForEach-Object { Get-TrimGeometry -Path $_.FullName }
    $heightSpread = ($geometries.Height | Measure-Object -Maximum).Maximum - ($geometries.Height | Measure-Object -Minimum).Minimum
    $baselineSpread = ($geometries.Baseline | Measure-Object -Maximum).Maximum - ($geometries.Baseline | Measure-Object -Minimum).Minimum
    Assert-True ($heightSpread -le 1) "Normalized subject height spread was $heightSpread px."
    Assert-True ($baselineSpread -le 1) "Normalized ground baseline spread was $baselineSpread px."

    $approval = & $approveScript -RunDir $happyRun -Decision CONTACT_SHEET_APPROVED -ApprovedBy 'integration-test' -ApprovalNote 'synthetic fixture'
    Assert-True ($approval.Status -eq 'CONTACT_SHEET_APPROVED') 'Approval status mismatch.'
    Assert-True (Test-Path -LiteralPath $approval.FinalDirectory -PathType Container) 'Final directory was not published after approval.'
    Assert-True (-not (Test-Path -LiteralPath $result.StagedDirectory)) 'Staged directory must be renamed away after approval.'
    Assert-True (Test-Path -LiteralPath $approval.ApprovalRecord -PathType Leaf) 'Approval record is missing.'

    Write-Output 'TEST 2: excessive subject scale drift is blocked before publication'
    $driftRun = New-RunFixture -Name '测试RPG宝箱_比例漂移' -LeftHeight 120
    Assert-ThrowsCode -ExpectedCode 'SUBJECT_SCALE_DRIFT' -Action {
        & $finalizeScript -RunDir $driftRun -ViewSet Six -CanvasWidth 400 -CanvasHeight 300 -BackgroundColor $background -ApprovedMirrorPairs | Out-Null
    }
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $driftRun '00_待审核上传_Staged_Upload'))) 'Scale failure left a staged directory.'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $driftRun '00_正式上传_Hunyuan_Tripo'))) 'Scale failure left a final directory.'

    Write-Output 'TEST 3: required compact asset-lock gate'
    $docsRun = New-RunFixture -Name '测试RPG头盔_缺资产锁' -OmitAssetLock
    Assert-ThrowsCode -ExpectedCode 'RUN_DOCUMENT_MISSING' -Action {
        & $finalizeScript -RunDir $docsRun -ViewSet Six -CanvasWidth 400 -CanvasHeight 300 -BackgroundColor $background -ApprovedMirrorPairs | Out-Null
    }

    Write-Output 'TEST 4: unreliable foreground bounds are rejected'
    $backgroundRun = New-RunFixture -Name '测试RPG卷轴_背景异常' -DirtyLeftBackground
    Assert-ThrowsCode -ExpectedCode 'SUBJECT_BOUNDS_UNRELIABLE' -Action {
        & $finalizeScript -RunDir $backgroundRun -ViewSet Six -CanvasWidth 400 -CanvasHeight 300 -BackgroundColor $background -ApprovedMirrorPairs | Out-Null
    }

    Write-Output 'TEST 5: batch root requires a delivery index'
    $batchRoot = Join-Path $tempRootFull 'RPG道具批次_测试'
    New-Item -ItemType Directory -Path $batchRoot -Force | Out-Null
    $batchRun = New-RunFixture -Name '01_测试RPG法杖' -ParentRoot $batchRoot
    Assert-ThrowsCode -ExpectedCode 'BATCH_INDEX_MISSING' -Action {
        & $finalizeScript -RunDir $batchRun -BatchRoot $batchRoot -ViewSet Six -CanvasWidth 400 -CanvasHeight 300 -BackgroundColor $background -ApprovedMirrorPairs | Out-Null
    }

    Write-Output 'TEST 6: staged-file tampering is blocked by SHA256 manifest'
    $tamperRun = New-RunFixture -Name '测试RPG盾牌_待审核篡改'
    $tamperResult = & $finalizeScript -RunDir $tamperRun -ViewSet Six -CanvasWidth 400 -CanvasHeight 300 -BackgroundColor $background -ApprovedMirrorPairs
    $tamperedFile = Join-Path $tamperResult.StagedDirectory '正视图_front.png'
    Invoke-TestMagick $tamperedFile '-fill' '#FFFFFF' '-draw' 'point 1,1' $tamperedFile
    Assert-ThrowsCode -ExpectedCode 'STAGED_MANIFEST_MISMATCH' -Action {
        & $approveScript -RunDir $tamperRun -Decision CONTACT_SHEET_APPROVED -ApprovedBy 'integration-test' -ApprovalNote 'must fail' | Out-Null
    }
    Assert-True (Test-Path -LiteralPath $tamperResult.StagedDirectory -PathType Container) 'Tamper failure must preserve the staged directory for investigation.'
    Assert-True (-not (Test-Path -LiteralPath $tamperResult.FinalDirectory)) 'Tamper failure must not publish a final directory.'

    Write-Output 'TEST 7: accepted directory must visibly contain the complete selected view set'
    $incompleteRun = New-RunFixture -Name '测试RPG法器_已通过目录缺图' -OmitMirroredAccepted
    Assert-ThrowsCode -ExpectedCode 'ACCEPTED_VIEW_SET_INCOMPLETE' -Action {
        & $finalizeScript -RunDir $incompleteRun -ViewSet Six -CanvasWidth 400 -CanvasHeight 300 -BackgroundColor $background -ApprovedMirrorPairs | Out-Null
    }
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $incompleteRun '00_待审核上传_Staged_Upload'))) 'Incomplete accepted set must not publish a staged directory.'

    Write-Output 'TEST 8: v1.2 detailed lock documents remain backward compatible'
    $legacyDocsRun = New-RunFixture -Name '测试RPG旧文档兼容' -UseLegacyLockDocs -ConfigVersion '1.2'
    $legacyResult = & $finalizeScript -RunDir $legacyDocsRun -ViewSet Six -CanvasWidth 400 -CanvasHeight 300 -BackgroundColor $background -SymmetricPairs
    Assert-True ($legacyResult.Status -eq 'FILES_READY') 'Legacy detailed documents must still finalize.'
    Assert-True ($legacyResult.RunDocumentProfile -eq 'detailed-v1.2') 'Legacy document profile was not detected.'

    Write-Output 'ALL_TESTS_PASSED'
}
finally {
    if (Test-Path -LiteralPath $tempRootFull) {
        $resolved = [System.IO.Path]::GetFullPath($tempRootFull)
        if (-not $resolved.StartsWith($systemTempFull, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to clean unsafe test path: $resolved"
        }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
