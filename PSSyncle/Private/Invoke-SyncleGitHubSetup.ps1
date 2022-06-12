#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Invoke-SyncleGitHubSetup {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({
            if (-not $_.Login) {
                throw "Error 'GitHub.Login': <missing>"
            } elseif (-not $_.Token) {
                throw "Error 'GitHub.Token': <missing>"
            }
            return $true
        })]
        [PSCustomObject]
        $Setup
    )

    if ($Setup.Login.StartsWith("@")) {
        $File = $Setup.Login.TrimStart("@")
        if (-not (Test-Path $File -PathType Leaf)) {
            throw "Error 'GitHub.Login': $($Setup.Login)"
        } else {
            $LoginName = (Get-Content $File).Trim()
        }
    } else {
        $LoginName = $Setup.Login
    }
    if ($Setup.Token.StartsWith("@")) {
        $File = $Setup.Token.TrimStart("@")
        if (-not (Test-Path $File -PathType Leaf)) {
            throw "Error 'GitHub.Token': $($Setup.Token)"
        } else {
            $TokenString = (Get-Content $File).Trim()
        }
    } else {
        $TokenString = $Setup.Token
    }

    $SecureString = $TokenString |
        ConvertTo-SecureString -AsPlainText -Force
    $Credential = New-Object $LoginName, $SecureString `
        -TypeName System.Management.Automation.PSCredential

    try {
        Set-GitHubAuthentication `
            -Credential $Credential `
            -SessionOnly
    } finally {
        $TokenString = $null
        $SecureString = $null
        $Credential = $null
    }
}
