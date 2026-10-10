[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AssetDir,

    [ValidateSet('Eight', 'Six')]
    [string]$ViewMode = 'Eight',

    [int]$ExpectedWidth = 0,
    [int]$ExpectedHeight = 0,

    [switch]$RequireSquare,

    [string]$ReviewManifestPath,

    [switch]$RequireSemanticAttestation
)

$ErrorActionPreference = 'Stop'

$viewSets = @{
    Eight = @(
        'front.png',
        'back.png',
        'left.png',
        'right.png',
        'top.png',
        'bottom.png',
        'left45.png',
        'right45.png'
    )
    Six = @(
        'front.png',
        'back.png',
        'left.png',
        'right.png',
        'left45.png',
        'right45.png'
    )
}

$expectedNames = $viewSets[$ViewMode]
$errors = [System.Collections.Generic.List[string]]::new()
$rows = [System.Collections.Generic.List[object]]::new()

if (-not (Test-Path -LiteralPath $AssetDir -PathType Container)) {
    Write-Error "Asset directory does not exist: $AssetDir"
    exit 1
}

$resolvedDir = (Resolve-Path -LiteralPath $AssetDir).Path
$allFiles = @(Get-ChildItem -LiteralPath $resolvedDir -File -Force)
$childDirs = @(Get-ChildItem -LiteralPath $resolvedDir -Directory -Force)

if ($childDirs.Count -gt 0) {
    $errors.Add("Upload directory contains subdirectories: $($childDirs.Name -join ', ')")
}

if ($allFiles.Count -ne $expectedNames.Count) {
    $errors.Add("$ViewMode-view upload directory must contain exactly $($expectedNames.Count) files; found $($allFiles.Count).")
}

$actualNames = @($allFiles.Name)
$missing = @($expectedNames | Where-Object { $_ -notin $actualNames })
$extra = @($actualNames | Where-Object { $_ -notin $expectedNames })

if ($missing.Count -gt 0) {
    $errors.Add("Missing files: $($missing -join ', ')")
}

if ($extra.Count -gt 0) {
    $errors.Add("Unexpected files: $($extra -join ', ')")
}

try {
    Add-Type -AssemblyName System.Drawing
}
catch {
    Write-Error "Cannot load System.Drawing for image validation: $($_.Exception.Message)"
    exit 1
}

foreach ($name in $expectedNames) {
    $path = Join-Path $resolvedDir $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        continue
    }

    $image = $null
    try {
        $image = [System.Drawing.Image]::FromFile($path)
        $width = $image.Width
        $height = $image.Height

        if ($RequireSquare -and $width -ne $height) {
            $errors.Add("$name is not square: ${width}x${height}.")
        }

        if ($ExpectedWidth -gt 0 -and $width -ne $ExpectedWidth) {
            $errors.Add("$name width is $width; expected $ExpectedWidth.")
        }

        if ($ExpectedHeight -gt 0 -and $height -ne $ExpectedHeight) {
            $errors.Add("$name height is $height; expected $ExpectedHeight.")
        }

        $rows.Add([pscustomobject]@{
            File = $name
            Width = $width
            Height = $height
            Bytes = (Get-Item -LiteralPath $path).Length
        })
    }
    catch {
        $errors.Add("$name cannot be decoded as an image: $($_.Exception.Message)")
    }
    finally {
        if ($null -ne $image) {
            $image.Dispose()
        }
    }
}

$dimensionGroups = @(
    $rows |
        Group-Object -Property { "$($_.Width)x$($_.Height)" }
)

if ($dimensionGroups.Count -gt 1) {
    $summary = $dimensionGroups | ForEach-Object { "$($_.Name)=$($_.Count)" }
    $errors.Add("Image dimensions are inconsistent: $($summary -join ', ')")
}

if ($RequireSemanticAttestation) {
    if ([string]::IsNullOrWhiteSpace($ReviewManifestPath)) {
        $errors.Add('RequireSemanticAttestation requires -ReviewManifestPath.')
    }
    elseif (-not (Test-Path -LiteralPath $ReviewManifestPath -PathType Leaf)) {
        $errors.Add("Review manifest does not exist: $ReviewManifestPath")
    }
    else {
        try {
            $manifest = Get-Content -LiteralPath $ReviewManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

            if ([int]$manifest.schemaVersion -ne 1) {
                $errors.Add('Review manifest schemaVersion must be 1.')
            }

            if ([string]$manifest.uploadViewMode -ne $ViewMode) {
                $errors.Add("Review manifest uploadViewMode is '$($manifest.uploadViewMode)'; expected '$ViewMode'.")
            }

            if ([string]::IsNullOrWhiteSpace([string]$manifest.axial.reviewer)) {
                $errors.Add('axial.reviewer must identify the person or review role that completed the full-resolution check.')
            }

            if ([string]::IsNullOrWhiteSpace([string]$manifest.axial.reviewedAt)) {
                $errors.Add('axial.reviewedAt must record when the full-resolution check was completed.')
            }

            if ($ViewMode -eq 'Eight') {
                $axial = $manifest.axial
                $allowedSourceModes = @('same_asset_ai', 'proxy_render')

                if ($null -eq $axial) {
                    $errors.Add('Eight-view review manifest must contain an axial object.')
                }
                else {
                    if ([string]$axial.sourceMode -notin $allowedSourceModes) {
                        $errors.Add("axial.sourceMode must be one of: $($allowedSourceModes -join ', ').")
                    }

                    $requiredTrue = @(
                        'sameAssetSourcesOnly',
                        'topVisualApproved',
                        'bottomVisualApproved',
                        'surfaceOwnershipApproved',
                        'pairConsistencyApproved'
                    )
                    foreach ($field in $requiredTrue) {
                        if ($axial.$field -ne $true) {
                            $errors.Add("axial.$field must be true for Eight-view release.")
                        }
                    }

                    $requiredFalse = @(
                        'crossAssetAxialReferenceUsed',
                        'failedCandidateUsedAsReference'
                    )
                    foreach ($field in $requiredFalse) {
                        if ($axial.$field -ne $false) {
                            $errors.Add("axial.$field must be false for Eight-view release.")
                        }
                    }

                    if ([string]$axial.sourceMode -eq 'same_asset_ai') {
                        $allowedReferences = @('front.png', 'left.png', 'right.png')
                        foreach ($field in @('topReferenceImages', 'bottomReferenceImages')) {
                            $references = @($axial.$field)
                            if ('front.png' -notin $references) {
                                $errors.Add("axial.$field must include front.png for same_asset_ai.")
                            }
                            if ('left.png' -notin $references -and 'right.png' -notin $references) {
                                $errors.Add("axial.$field must include one strict side view for same_asset_ai.")
                            }
                            $disallowed = @($references | Where-Object { $_ -notin $allowedReferences })
                            if ($disallowed.Count -gt 0) {
                                $errors.Add("axial.$field contains disallowed image references: $($disallowed -join ', ').")
                            }
                        }

                        foreach ($field in @('topAttempts', 'bottomAttempts')) {
                            $attempts = [int]$axial.$field
                            if ($attempts -lt 1 -or $attempts -gt 2) {
                                $errors.Add("axial.$field must be 1 or 2 for same_asset_ai. After two failed attempts, use proxy_render or Six-view mode.")
                            }
                        }
                    }
                    elseif ([string]$axial.sourceMode -eq 'proxy_render' -and [string]::IsNullOrWhiteSpace([string]$axial.proxyEvidence)) {
                        $errors.Add('axial.proxyEvidence is required for proxy_render.')
                    }
                }
            }
            elseif ([string]$manifest.axial.sourceMode -ne 'not_included') {
                $errors.Add("Six-view review manifest requires axial.sourceMode='not_included'.")
            }
        }
        catch {
            $errors.Add("Review manifest is not valid JSON: $($_.Exception.Message)")
        }
    }
}

Write-Host ''
Write-Host "$ViewMode-view file validation"
Write-Host "Directory: $resolvedDir"
Write-Host ''
$rows | Format-Table -AutoSize

if ($errors.Count -gt 0) {
    Write-Host 'VALIDATION_FAILED' -ForegroundColor Red
    foreach ($message in $errors) {
        Write-Host "- $message" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'VALIDATION_PASSED' -ForegroundColor Green
Write-Host "The directory contains the expected $ViewMode-view decodable PNG set with matching dimensions."
if ($RequireSemanticAttestation) {
    Write-Host 'The required human semantic-review attestation is present and internally consistent.'
}
else {
    Write-Host 'No semantic-review attestation was required. Visual camera and geometry checks are still mandatory before release.'
}
exit 0
