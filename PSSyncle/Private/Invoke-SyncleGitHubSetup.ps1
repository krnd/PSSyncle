#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Invoke-SyncleGitHubSetup {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Setup
    )

    if (-not $Setup.Login)
    { throw "Error 'GitHub.Login': $($Setup.Login)" }
    if (-not $Setup.Token -or -not (Test-Path $Setup.Token -PathType Leaf))
    { throw "Error 'GitHub.Token': $($Setup.Token)" }

    if ($Setup.Login.StartsWith("@")) {
        $LoginName = $Setup.Login.TrimStart("@")
    } else {
        $LoginName = (Get-Content $Setup.Login).Trim()
    }
    $SecureString = (Get-Content $Setup.Token) |
        ConvertTo-SecureString -AsPlainText -Force
    $Credential = New-Object $LoginName, $SecureString `
        -TypeName System.Management.Automation.PSCredential

    Set-GitHubAuthentication `
        -Credential $Credential `
        -SessionOnly

    $SecureString = $null
    $Credential = $null
}
