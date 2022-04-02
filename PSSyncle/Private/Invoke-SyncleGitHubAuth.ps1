#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Invoke-SyncleGitHubAuth {
    [CmdletBinding(PositionalBinding = $False)]
    param (
        [Parameter(Position = 0, Mandatory = $True)]
        [string]
        $UserName,
        [Parameter(Mandatory = $True)]
        [string]
        $TokenFile
    )
    $SecureString = $(Get-Content -Path $TokenFile) | ConvertTo-SecureString -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential $UserName, $SecureString

    Set-GitHubAuthentication -Credential $Credential -SessionOnly

    $SecureString = $null
    $Credential = $null
}
