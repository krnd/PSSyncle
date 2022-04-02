#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Sync-GitHubSynclet {
    [CmdletBinding(PositionalBinding = $False, DefaultParameterSetName = "Input")]
    param (
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = "Synclet")]
        [PSCustomObject]
        $Synclet,
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = "Input")]
        [string]
        $File,
        [Parameter(Mandatory = $True, ParameterSetName = "Input")]
        [string]
        $Repository,
        [Parameter(Mandatory = $True, ParameterSetName = "Input")]
        [string]
        $Path,
        [Parameter(ParameterSetName = "Synclet")]
        [switch]
        $Cache
    )
    if ($Synclet) {
        if (-not $Synclet.file) { throw "Missing synclet parameter: 'file'"}
        $File = $Synclet.file
        if (-not $Synclet.repo) { throw "Missing synclet parameter: 'repo'"}
        $Repository = $Synclet.repo
        if (-not $Synclet.cherry) { throw "Missing synclet parameter: 'cherry'"}
        $Path = $Synclet.cherry
    }
    if ($Cache) {
        $FileBase = Split-Path $File
        $FileName = Split-Path $File -Leaf
        $File = Join-Path $FileBase "syncle~$FileName"
    }

    $OwnerName, $RepositoryName = $Repository -split "/"
    $RemoteFile = Get-GitHubContent `
        -OwnerName $OwnerName `
        -RepositoryName $RepositoryName `
        -Path $Path

    Invoke-WebRequest `
        -Uri $RemoteFile.download_url `
        -OutFile $File

    return $File
}
