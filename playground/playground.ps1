#Requires -Version 5.1


Write-Host ""
Write-Host "======================[ START ]============================="
Write-Host ""


$ProjectPath = (Resolve-Path .).Path
$PlaygroundPath = (Join-Path $ProjectPath "playground")

$ModuleName = "PSSyncle"
$ModulePath = Join-Path $ProjectPath $ModuleName


Import-Module Poshstache
Import-Module PowerShellForGitHub
Import-Module $ModulePath -Force


Invoke-Syncle (Join-Path $PlaygroundPath "syncle.json")


Write-Host ""
Write-Host "======================[ FINISH ]============================"
Write-Host ""
