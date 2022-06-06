#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Sync-GitHubSynclet {
    [CmdletBinding(PositionalBinding = $False)]
    param (
        [Parameter(Position = 0, Mandatory = $True)]
        [PSCustomObject]
        $Synclet
    )

    if (-not $Synclet.Repo -or $Synclet.Repo -notlike "*?/?*")
    { throw "Error 'Synclet[GitHub].Repo': $($Synclet.Repo) ($($Synclet.Target))" }
    if (-not $Synclet.File)
    { throw "Error 'Synclet[GitHub].File': $($Synclet.File) ($($Synclet.Target))" }

    $OwnerName, $RepositoryName = $Synclet.Repo -split "/"
    $RemoteFile = Get-GitHubContent `
        -OwnerName $OwnerName `
        -RepositoryName $RepositoryName `
        -Path $Synclet.File

    if ($Synclet.Target.EndsWith("\") -or $Synclet.Target.EndsWith("/")) {
        $TargetFile = (Join-Path $Synclet.Target $RemoteFile.name)
    }

    (New-Item `
        -Path (Split-Path $TargetFile) `
        -ItemType Directory `
        -Force
    ) | Out-Null
    Invoke-WebRequest `
        -Uri $RemoteFile.download_url `
        -OutFile $TargetFile

    return $TargetFile
}
