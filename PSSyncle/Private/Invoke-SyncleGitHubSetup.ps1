#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Invoke-SyncleGitHubSetup {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Setup
    )

    if (-not $Setup.User)
    { throw "Error 'GitHub.User': $($Setup.User)" }
    if (-not $Setup.Token -or -not (Test-Path $Setup.Token -PathType Leaf))
    { throw "Error 'GitHub.Token': $($Setup.Token)" }

    $SecureString = Get-Content $Setup.Token |
        ConvertTo-SecureString -AsPlainText -Force
    $Credential = New-Object $Setup.User, $SecureString `
        -TypeName System.Management.Automation.PSCredential

    Set-GitHubAuthentication `
        -Credential $Credential `
        -SessionOnly

    $SecureString = $null
    $Credential = $null
}
