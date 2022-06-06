#Requires -Version 5.1


function Sync-FileSystemSynclet {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Synclet
    )

    if (-not $Synclet.Path -or -not (Test-Path $Synclet.Path))
    { throw "Error 'Synclet[FileSystem].Path': $($Synclet.Path) ($($Synclet.Target))" }


    if (-not (Test-Path $Synclet.Path -PathType Leaf)) {
        $TargetFile = $null

        (New-Item `
            -Path $Synclet.Target `
            -ItemType Directory `
            -Force
        ) | Out-Null
        (Get-ChildItem `
            -Path $Synclet.Path
        ) | Copy-Item `
            -Destination $Synclet.Target `
            -Recurse `
            -Force

    } else {
        if ($Synclet.Target.EndsWith("\") -or $Synclet.Target.EndsWith("/")) {
            $TargetFile = (Join-Path $Synclet.Target (Split-Path $Synclet.Path -Leaf))
        } else {
            $TargetFile = $Synclet.Target
        }

        (New-Item `
            -Path (Split-Path $TargetFile) `
            -ItemType Directory `
            -Force
        ) | Out-Null
        Copy-Item `
            -Path $Synclet.Path `
            -Destination $TargetFile `
            -Recurse `
            -Force
    }

    return $TargetFile
}
