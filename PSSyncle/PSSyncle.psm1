#Requires -Version 5.1


Get-ChildItem (Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) "Private") -Filter "*.ps1" -Recurse | ForEach-Object {
    . $_.FullName
}
Get-ChildItem (Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) "Public") -Filter "*.ps1" -Recurse | ForEach-Object {
    . $_.FullName
}
