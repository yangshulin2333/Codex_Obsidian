[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$FolderPath
)

$resolvedFolder = (Resolve-Path -LiteralPath $FolderPath -ErrorAction Stop).Path
if (-not (Test-Path -LiteralPath $resolvedFolder -PathType Container)) {
    throw "FINAL_DELIVERY_FOLDER_NOT_FOUND: $FolderPath"
}

$expectedNames = [string[]]@(
    'front.png'
    'back.png'
    'left.png'
    'right.png'
)

$files = @(Get-ChildItem -LiteralPath $resolvedFolder -File)
$directories = @(Get-ChildItem -LiteralPath $resolvedFolder -Directory)
$actualNames = [string[]]@($files.Name)
$missing = @($expectedNames | Where-Object { $_ -notin $actualNames })
$extraFiles = @($actualNames | Where-Object { $_ -notin $expectedNames })

if ($missing.Count -gt 0 -or $extraFiles.Count -gt 0 -or $directories.Count -gt 0) {
    $missingText = if ($missing.Count -gt 0) { $missing -join ', ' } else { 'none' }
    $extraText = if ($extraFiles.Count -gt 0) { $extraFiles -join ', ' } else { 'none' }
    $directoryText = if ($directories.Count -gt 0) { $directories.Name -join ', ' } else { 'none' }
    throw "FINAL_DELIVERY_FOLDER_DIRTY: missing=[$missingText]; extra_files=[$extraText]; directories=[$directoryText]"
}

Add-Type -AssemblyName System.Drawing
$expectedWidth = $null
$expectedHeight = $null

foreach ($name in $expectedNames) {
    $imagePath = Join-Path $resolvedFolder $name
    $image = [System.Drawing.Image]::FromFile($imagePath)
    try {
        if ($image.Width -lt 1 -or $image.Height -lt 1) {
            throw "FINAL_DELIVERY_IMAGE_INVALID: $imagePath"
        }

        if ($null -eq $expectedWidth) {
            $expectedWidth = $image.Width
            $expectedHeight = $image.Height
        }
        elseif ($image.Width -ne $expectedWidth -or $image.Height -ne $expectedHeight) {
            throw "FINAL_DELIVERY_DIMENSION_MISMATCH: $name is $($image.Width)x$($image.Height); expected ${expectedWidth}x${expectedHeight}"
        }
    }
    finally {
        $image.Dispose()
    }
}

$folderLeaf = [IO.Path]::GetFileName($resolvedFolder.TrimEnd([IO.Path]::DirectorySeparatorChar))
Start-Process -FilePath explorer.exe -ArgumentList @("`"$resolvedFolder`"")

$deadline = (Get-Date).AddSeconds(6)
$window = $null
do {
    Start-Sleep -Milliseconds 250
    $window = Get-Process explorer -ErrorAction SilentlyContinue |
        Where-Object {
            $_.MainWindowHandle -ne 0 -and
            $_.MainWindowTitle -like "$folderLeaf*"
        } |
        Sort-Object StartTime -Descending |
        Select-Object -First 1
} while ($null -eq $window -and (Get-Date) -lt $deadline)

if ($null -eq $window) {
    throw "FINAL_DELIVERY_FOLDER_NOT_OPENED: $resolvedFolder"
}

$shell = New-Object -ComObject WScript.Shell
$activated = $shell.AppActivate($window.Id)
if (-not $activated) {
    throw "FINAL_DELIVERY_WINDOW_NOT_FOREGROUND: $($window.MainWindowTitle)"
}

[pscustomobject]@{
    Status = 'FINAL_DELIVERY_FOLDER_OPENED'
    Path = $resolvedFolder
    FileCount = $files.Count
    Files = $expectedNames -join ', '
    Dimensions = "${expectedWidth}x${expectedHeight}"
    WindowTitle = $window.MainWindowTitle
    ForegroundActivated = $activated
}
