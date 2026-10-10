param(
	[string]$TargetRoot = (Get-Location).Path,
	[string]$SourceToolsDir = $PSScriptRoot,
	[switch]$CopyExporters
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $TargetRoot)) {
	New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
}

$resolvedTarget = (Resolve-Path -LiteralPath $TargetRoot).Path
$analysisDir = Join-Path $resolvedTarget "Project_Analysis_Package"
$toolsDir = Join-Path $resolvedTarget "Tools"

New-Item -ItemType Directory -Force -Path $analysisDir | Out-Null
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

$analysisFiles = @(
	"Startup_Record.md",
	"STATUS.md",
	"Audit_Quick_Focused_Output.md",
	"Audit_Project_Assets_Output.md",
	"Audit_Animation_Sound_Output.md",
	"Audit_SourceAssetSearch_Output.md",
	"Audit_TargetSource_Output.md",
	"Audit_TargetSource_Pass2_Output.md",
	"Audit_TargetSource_Pass3_Output.md",
	"Audit_TargetExplorer_Output.md",
	"Audit_TargetExplorer_Compact_Output.md",
	"Audit_Raw_Output.md",
	"Explorer_Tree.md",
	"Script_Index.md",
	"RemoteEvent_Map.md",
	"Asset_Audit.md",
	"Animation_Sound_Index.md",
	"Source_Asset_Search_Index.md",
	"Target_Source_Index.md",
	"Gameplay_Flow.md",
	"Replacement_Plan.md",
	"Project_Understanding_Report.md",
	"Next_Steps.md",
	"Project_Takeover_Final_Report.md",
	"Replica_Demo_Report.md"
)

foreach ($fileName in $analysisFiles) {
	$filePath = Join-Path $analysisDir $fileName
	if (-not (Test-Path -LiteralPath $filePath)) {
		New-Item -ItemType File -Path $filePath | Out-Null
	}
}

$exporterFiles = @(
	"RobloxStudio_QuickFocusedAuditExporter.luau",
	"RobloxStudio_ProjectOnlyAssetExporter.luau",
	"RobloxStudio_AnimationSoundExporter.luau",
	"RobloxStudio_SourceAssetSearchExporter.luau",
	"RobloxStudio_TargetSourceExporter.luau",
	"RobloxStudio_TargetExplorerExporter.luau",
	"RobloxStudio_TargetExplorerCompactExporter.luau",
	"RobloxStudio_AuditExporter.luau"
)

if ($CopyExporters) {
	foreach ($fileName in $exporterFiles) {
		$sourcePath = Join-Path $SourceToolsDir $fileName
		if (Test-Path -LiteralPath $sourcePath) {
			Copy-Item -LiteralPath $sourcePath -Destination (Join-Path $toolsDir $fileName) -Force
		}
	}
}

Write-Output "Roblox project audit workspace prepared:"
Write-Output "TargetRoot: $resolvedTarget"
Write-Output "AnalysisDir: $analysisDir"
Write-Output "ToolsDir: $toolsDir"
Write-Output ("StatusFile: " + (Join-Path $analysisDir "STATUS.md"))
if ($CopyExporters) {
	Write-Output "Exporter scripts copied from: $SourceToolsDir"
} else {
	Write-Output "Exporter scripts not copied. Add -CopyExporters to copy them."
}
