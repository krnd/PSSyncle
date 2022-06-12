#Requires -Version 5.1


Write-Host ""
Write-Host "======================[ START ]============================="
Write-Host ""


$ProjectPath = (Resolve-Path .).Path
$OutputPath = "output"

$ModuleName = "PSSyncle"
$ModulePath = Join-Path $ProjectPath $ModuleName


Remove-Item `
    -Path $OutputPath `
    -ErrorAction SilentlyContinue `
    -Recurse `
    -Force


Import-Module Poshstache
Import-Module PowerShellForGitHub
Import-Module $ModulePath -Force


Invoke-Syncle (Join-Path $PSScriptRoot "syncle.json")


Write-Host ""
Write-Host "======================[ FINISH ]============================"
Write-Host ""
