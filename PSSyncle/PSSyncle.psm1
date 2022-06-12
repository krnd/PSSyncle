#Requires -Version 5.1


# ################################ PRIVATE #################################

Get-ChildItem `
    -Path (Join-Path $PSScriptRoot "Private") `
    -Filter "*.ps1" `
    -Recurse `
| ForEach-Object {

    . $_.FullName

}


# ################################ PUBLIC #################################

Get-ChildItem `
    -Path (Join-Path $PSScriptRoot "Public") `
    -Filter "*.ps1" `
    -Recurse `
| ForEach-Object {

    . $_.FullName

    Export-ModuleMember `
        -Function $_.BaseName
}
