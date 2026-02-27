param(
  [string]$IJKFrameworkPath,
  [string]$TXFrameworkPath,
  [string]$OutputDir = "$PSScriptRoot\\..\\VendorFrameworks"
)
$ErrorActionPreference = "Stop"
function Ensure-Dir([string]$p){ if(!(Test-Path $p)){ New-Item -ItemType Directory -Path $p | Out-Null } }
function Zip-Framework([string]$src,[string]$zipName){
  if(!(Test-Path $src)){ throw "Missing: $src" }
  $zipPath = Join-Path $OutputDir $zipName
  if(Test-Path $zipPath){ Remove-Item -Force $zipPath }
  Ensure-Dir $OutputDir
  Compress-Archive -Path (Get-Item $src).FullName -DestinationPath $zipPath -Force
  Write-Host $zipPath
}
if($IJKFrameworkPath){ Zip-Framework $IJKFrameworkPath "IJKMediaFramework.framework.zip" }
if($TXFrameworkPath){ Zip-Framework $TXFrameworkPath "TXLiteAVSDK_Professional.framework.zip" }
