param([Parameter(Mandatory=$true)][string]$InputPath,[Parameter(Mandatory=$true)][string]$OutputPath)
$ErrorActionPreference='Stop'
$application=$null
$document=$null
$openedCount=0
$originalAlerts=$null
try {
    $application=New-Object -ComObject Word.Application
    $openedCount=[int]$application.Documents.Count
    $originalAlerts=$application.DisplayAlerts
    $application.DisplayAlerts=0
    $document=$application.Documents.Open($InputPath,$false,$true,$false)
    $document.ExportAsFixedFormat($OutputPath,17)
    if(-not (Test-Path -LiteralPath $OutputPath)){throw 'No PDF produced'}
    if((Get-Item -LiteralPath $OutputPath).Length -lt 1000){throw 'PDF is empty'}
    Write-Output "DOCX_PDF_OK $OutputPath"
} finally {
    if($null -ne $document){$document.Close(0)|Out-Null}
    if($null -ne $application){
        if($null -ne $originalAlerts){$application.DisplayAlerts=$originalAlerts}
        if($openedCount -eq 0){$application.Quit()|Out-Null}
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($application)
    }
}
