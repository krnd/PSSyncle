#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Sync-GitHubSynclet {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
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

    if ($Synclet.Target.EndsWith("\") `
            -or $Synclet.Target.EndsWith("/") `
            -or (Test-Path $Synclet.Target -PathType Container)) {
        $TargetPath = $Synclet.Target
        $TargetFile = (Join-Path $Synclet.Target $RemoteFile.name)
    } else {
        $TargetPath = (Split-Path $Synclet.Target)
        $TargetFile = $Synclet.Target
    }

    if ($TargetPath) {
        (New-Item `
            -Path $TargetPath `
            -ItemType Directory `
            -Force
        ) | Out-Null
    }
    Invoke-WebRequest `
        -Uri $RemoteFile.download_url `
        -OutFile $TargetFile

    return $TargetFile
}
