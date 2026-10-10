[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RunDir,

    [Parameter(Mandatory = $true)]
    [ValidateSet('CONTACT_SHEET_APPROVED')]
    [string]$Decision,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedBy,

    [string]$ApprovalNote = ''
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

$runFull = [System.IO.Path]::GetFullPath($RunDir)
if (-not (Test-Path -LiteralPath $runFull -PathType Container)) {
    throw "Run directory does not exist: $runFull"
}

$preferred = [ordered]@{
    Staged = '00_待审核上传_Staged_Upload'
    Final = '00_正式上传_Hunyuan_Tripo'
    Checks = '_检查_Checks'
    Docs = '_文档_Docs'
    Sheet = '多视图联系表_multiview_contact_sheet.png'
    Audit = '复制审计_COPY_AUDIT.md'
    Report = '归一化报告_NORMALIZATION_REPORT.md'
    Manifest = '待审核清单_STAGED_MANIFEST.json'
    Approval = '人工审核记录_HUMAN_APPROVAL.md'
}
$legacy = [ordered]@{
    Staged = '00_staged_hunyuan_tripo_upload'
    Final = '00_final_hunyuan_tripo_upload'
    Checks = '_checks'
    Docs = '_docs'
    Sheet = 'multiview_contact_sheet.png'
    Audit = 'COPY_AUDIT.md'
    Report = 'NORMALIZATION_REPORT.md'
    Manifest = 'STAGED_MANIFEST.json'
    Approval = 'HUMAN_APPROVAL.md'
}

$preferredStaged = Join-Path $runFull $preferred.Staged
$legacyStaged = Join-Path $runFull $legacy.Staged
$layout = if (Test-Path -LiteralPath $preferredStaged -PathType Container) {
    $preferred
}
elseif (Test-Path -LiteralPath $legacyStaged -PathType Container) {
    $legacy
}
else {
    throw 'STAGED_OUTPUT_MISSING: No staged upload directory is ready for approval.'
}

$stagedDir = Join-Path $runFull $layout.Staged
$finalDir = Join-Path $runFull $layout.Final
$checksDir = Join-Path $runFull $layout.Checks
$docsDir = Join-Path $runFull $layout.Docs
$sheet = Join-Path $checksDir $layout.Sheet
$audit = Join-Path $docsDir $layout.Audit
$report = Join-Path $docsDir $layout.Report
$manifestPath = Join-Path $docsDir $layout.Manifest
$approvalRecord = Join-Path $docsDir $layout.Approval
foreach ($path in @($stagedDir, $finalDir, $checksDir, $docsDir, $sheet, $audit, $report, $manifestPath, $approvalRecord)) {
    Assert-ChildPath -Parent $runFull -Child $path
}

if (Test-Path -LiteralPath $finalDir) {
    throw "APPROVED_FINAL_EXISTS: $finalDir"
}
foreach ($required in @($sheet, $audit, $report, $manifestPath)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "APPROVAL_EVIDENCE_MISSING: $required"
    }
}
if ((Get-Content -LiteralPath $audit -Raw -Encoding UTF8) -notmatch 'Mechanical status: FILES_READY') {
    throw "MECHANICAL_STATUS_INVALID: Copy audit does not contain FILES_READY: $audit"
}
if (Test-Path -LiteralPath $approvalRecord) {
    throw "APPROVAL_RECORD_EXISTS: $approvalRecord"
}

$stagedItems = @(Get-ChildItem -LiteralPath $stagedDir -Force)
if (@($stagedItems | Where-Object { $_.PSIsContainer -or $_.Extension -ne '.png' }).Count -gt 0) {
    throw 'STAGED_FOLDER_DIRTY: Staged upload must contain PNG files only and no subdirectories.'
}

try {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
catch {
    throw "STAGED_MANIFEST_INVALID: $manifestPath. $($_.Exception.Message)"
}
$manifestFiles = @($manifest.files)
if ([string]$manifest.status -ne 'FILES_READY' -or $manifestFiles.Count -notin @(4, 6, 8) -or $manifestFiles.Count -ne $stagedItems.Count) {
    throw 'STAGED_MANIFEST_MISMATCH: Manifest status or file count does not match staged output.'
}
foreach ($entry in $manifestFiles) {
    $fileName = [string]$entry.fileName
    $expectedHash = [string]$entry.sha256
    $stagedFile = Join-Path $stagedDir $fileName
    Assert-ChildPath -Parent $stagedDir -Child $stagedFile
    if (-not (Test-Path -LiteralPath $stagedFile -PathType Leaf)) {
        throw "STAGED_MANIFEST_MISMATCH: Missing file $fileName."
    }
    $actualHash = (Get-FileHash -LiteralPath $stagedFile -Algorithm SHA256).Hash
    if (-not $actualHash.Equals($expectedHash, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "STAGED_MANIFEST_MISMATCH: SHA256 changed for $fileName."
    }
}

$tempApproval = Join-Path $docsDir ("._approval_" + [guid]::NewGuid().ToString('N') + '.md')
Assert-ChildPath -Parent $runFull -Child $tempApproval
$approvalLines = @(
    '# 人工审核记录 / Human Approval Record',
    '',
    "- Decision: $Decision",
    "- Approved by: $ApprovedBy",
    "- Approved at: $([DateTimeOffset]::Now.ToString('yyyy-MM-dd HH:mm:ss zzz'))",
    "- Run directory: $runFull",
    "- Contact sheet: $sheet",
    "- Normalization report: $report",
    "- Approval note: $ApprovalNote",
    '- Status: CONTACT_SHEET_APPROVED',
    '- 3D result review: PENDING'
)
Set-Content -LiteralPath $tempApproval -Value $approvalLines -Encoding UTF8

try {
    Move-Item -LiteralPath $stagedDir -Destination $finalDir
    Move-Item -LiteralPath $tempApproval -Destination $approvalRecord
}
catch {
    if ((Test-Path -LiteralPath $finalDir -PathType Container) -and -not (Test-Path -LiteralPath $stagedDir)) {
        Move-Item -LiteralPath $finalDir -Destination $stagedDir
    }
    if (Test-Path -LiteralPath $tempApproval -PathType Leaf) {
        Remove-Item -LiteralPath $tempApproval -Force
    }
    throw
}

[pscustomobject]@{
    Status = 'CONTACT_SHEET_APPROVED'
    RunDirectory = $runFull
    FinalDirectory = $finalDir
    ContactSheet = $sheet
    ApprovalRecord = $approvalRecord
    ThreeDResultReview = 'PENDING'
}
