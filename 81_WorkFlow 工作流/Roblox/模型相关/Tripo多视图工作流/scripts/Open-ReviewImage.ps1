[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ImagePath,

    [switch]$OpenImage
)

$resolvedPath = (Resolve-Path -LiteralPath $ImagePath -ErrorAction Stop).Path
if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
    throw "REVIEW_IMAGE_NOT_FOUND: $ImagePath"
}

$allowedExtensions = '.png', '.jpg', '.jpeg', '.webp'
if ([IO.Path]::GetExtension($resolvedPath).ToLowerInvariant() -notin $allowedExtensions) {
    throw "REVIEW_IMAGE_UNSUPPORTED_EXTENSION: $resolvedPath"
}

Add-Type -AssemblyName System.Drawing
$image = [System.Drawing.Image]::FromFile($resolvedPath)
try {
    if ($image.Width -lt 1 -or $image.Height -lt 1) {
        throw "REVIEW_IMAGE_INVALID_DIMENSIONS: $resolvedPath"
    }

    $directory = [IO.Path]::GetDirectoryName($resolvedPath)
    Start-Process explorer.exe -ArgumentList "`"$directory`""
    if ($OpenImage) {
        Start-Process -FilePath $resolvedPath
    }

    [pscustomobject]@{
        Status = 'REVIEW_IMAGE_OPENED'
        Path = $resolvedPath
        Width = $image.Width
        Height = $image.Height
        Bytes = (Get-Item -LiteralPath $resolvedPath).Length
    }
}
finally {
    $image.Dispose()
}
