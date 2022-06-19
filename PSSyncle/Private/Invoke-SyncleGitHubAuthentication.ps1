#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function PSSyncle::Invoke-GitHubAuthentication {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({
            if ($_ -is [string]) {
                return $true
            } elseif (-not $_.Login) {
                throw [System.ArgumentNullException]::new("Login")
            } elseif (-not $_.Token) {
                throw [System.ArgumentNullException]::new("Token")
            }
            return $true
        })]
        [object]
        $Parameter
    )

    # if (Test-GitHubAuthenticationConfigured -ErrorAction SilentlyContinue) {
    #     return
    # }

    if ($Parameter -is [string]) {
        if ($Parameter.StartsWith("@")) {
            $File = $Parameter.TrimStart("@")
            if (-not (Test-Path $File -PathType Leaf)) {
                throw [System.IO.FileNotFoundException]::new(
                    "Unable to find GitHub reference file.",
                    $File
                )
            }
            $LoginName, $TokenString = (Get-Content $File).Trim() -split ":", 2
        } else {
            $LoginName, $TokenString = $Parameter -split ":", 2
        }
    } else {
        $LoginName = $Parameter.Login
        if ($LoginName.StartsWith("@")) {
            $File = $LoginName.TrimStart("@")
            if (-not (Test-Path $File -PathType Leaf)) {
                throw [System.IO.FileNotFoundException]::new(
                    "Unable to find GitHub username reference file.",
                    $File
                )
            }
            $LoginName = (Get-Content $File).Trim()
        }
        $TokenString = $Parameter.Token
        if ($TokenString.StartsWith("@")) {
            $File = $TokenString.TrimStart("@")
            if (-not (Test-Path $File -PathType Leaf)) {
                throw [System.IO.FileNotFoundException]::new(
                    "Unable to find GitHub token reference file.",
                    $File
                )
            }
            $TokenString = (Get-Content $File).Trim()
        }
    }

    try {
        $SecureString = ($TokenString | ConvertTo-SecureString -AsPlainText -Force)
        $Credential = New-Object $LoginName, $SecureString `
            -TypeName System.Management.Automation.PSCredential
        Set-GitHubAuthentication `
            -Credential $Credential `
            -SessionOnly
    } finally {
        $TokenString = $null
        $SecureString = $null
        $Credential = $null
    }
}
