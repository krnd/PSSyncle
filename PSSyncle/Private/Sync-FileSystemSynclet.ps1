#Requires -Version 5.1


function Sync-FileSystemSynclet {
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
        $Path,
        [Parameter(ParameterSetName = "Synclet")]
        [switch]
        $Cache
    )
    if ($Synclet) {
        if (-not $Synclet.file) { throw "Missing synclet parameter: 'file'"}
        $File = $Synclet.file
        if (-not $Synclet.path) { throw "Missing synclet parameter: 'path'"}
        $Path = $Synclet.path
    }
    if ($Cache) {
        $FileBase = Split-Path $File
        $FileName = Split-Path $File -Leaf
        $File = Join-Path $FileBase "syncle~$FileName"
    }

    if (Split-Path $File) {
        New-Item `
            -Path (Split-Path $File) `
            -ItemType Directory `
            -Force `
        | Out-Null
    }
    Copy-Item `
        -Path $Path `
        -Destination $File `
        -Force

    return $File
}
