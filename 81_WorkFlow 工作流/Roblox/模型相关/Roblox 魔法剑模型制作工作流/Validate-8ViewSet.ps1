[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AssetDir,

    [int]$ExpectedWidth = 0,
    [int]$ExpectedHeight = 0,

    [switch]$RequireSquare,

    [string]$ReviewManifestPath,

    [switch]$RequireSemanticAttestation
)

$validator = Join-Path $PSScriptRoot 'Validate-ViewSet.ps1'
if (-not (Test-Path -LiteralPath $validator -PathType Leaf)) {
    Write-Error "Generic validator does not exist: $validator"
    exit 1
}

$arguments = @{
    AssetDir = $AssetDir
    ViewMode = 'Eight'
    ExpectedWidth = $ExpectedWidth
    ExpectedHeight = $ExpectedHeight
    RequireSquare = $RequireSquare
    RequireSemanticAttestation = $RequireSemanticAttestation
}

if (-not [string]::IsNullOrWhiteSpace($ReviewManifestPath)) {
    $arguments.ReviewManifestPath = $ReviewManifestPath
}

& $validator @arguments
exit $LASTEXITCODE

