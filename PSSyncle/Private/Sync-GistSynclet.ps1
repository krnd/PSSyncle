#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Sync-GistSynclet {
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
        $Gist,
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
        if (-not $Synclet.gist) { throw "Missing synclet parameter: 'gist'"}
        $Gist = $Synclet.gist
        $Path = if ($Synclet.cherry) { $Synclet.cherry } else { Split-Path $File -Leaf }
    }
    if ($Cache) {
        $FileBase = Split-Path $File
        $FileName = Split-Path $File -Leaf
        $File = Join-Path $FileBase "syncle~$FileName"
    }

    $TempPath = New-Item `
        -Path (Join-Path $env:TEMP (New-Guid).Guid) `
        -ItemType Directory
    Get-GitHubGist `
        -Gist $Gist `
        -Path $TempPath.FullName `
        -Force

    if (Split-Path $File) {
        New-Item `
            -Path (Split-Path $File) `
            -ItemType Directory `
            -Force `
        | Out-Null
    }
    Copy-Item `
        -Path (Join-Path $TempPath.FullName $Path) `
        -Destination $File `
        -Force

    Remove-Item `
        -Path $TempPath `
        -Recurse `
        -Force

    return $File
}
