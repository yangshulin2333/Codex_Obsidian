param(
    [string]$OutDir = "",
    [string]$Name = "GuiSnapshot_Http",
    [string]$HostName = "127.0.0.1",
    [int]$Port = 18765,
    [string]$Python = "python"
)

$ErrorActionPreference = "Stop"

$toolDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$receiver = Join-Path $toolDir "Receive-GuiSnapshotHttp.py"

if (-not (Test-Path -LiteralPath $receiver)) {
    throw "Cannot find receiver script: $receiver"
}

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $OutDir = Join-Path (Get-Location) "Project_Analysis_Package\GuiSnapshots"
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Output "Starting Roblox GUI snapshot receiver..."
Write-Output "  Url: http://$HostName`:$Port/gui-snapshot"
Write-Output "  OutDir: $OutDir"
Write-Output "  Name: $Name"

& $Python $receiver --host $HostName --port $Port --out-dir $OutDir --name $Name
exit $LASTEXITCODE
