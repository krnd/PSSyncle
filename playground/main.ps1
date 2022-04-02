#Requires -Version 5.1


$ProjectPath = (Resolve-Path .).Path
$ModuleName = "PSSyncle"
$ModulePath = Join-Path $ProjectPath $ModuleName

Import-Module Poshstache, PowerShellForGitHub
Import-Module $ModulePath -Force


Invoke-Syncle "playground/syncle.json"


Write-Host
Write-Host "...done!"
