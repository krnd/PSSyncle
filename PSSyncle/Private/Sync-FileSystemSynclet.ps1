#Requires -Version 5.1


function Sync-FileSystemSynclet {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({
            if (-not $_.Path) {
                throw "Error 'Synclet[FileSystem].Path': <missing> ($($_.Target))"
            } elseif (-not (Test-Path $_.Path)) {
                throw "Error 'Synclet[FileSystem].Path': ($($_.Path)) ($($_.Target))"
            }
            return $true
        })]
        [PSCustomObject]
        $Synclet,
        [Parameter(Mandatory = $true)]
        [PSCustomObject]
        $Config
    )

    $Items = Get-Item `
        -Path $Synclet.Path

    $Target = $Synclet.Target
    if (
        ($Items.Count -ne 1) `
        -or (($Items.Attributes -band [IO.FileAttributes]::Directory) `
            -eq [IO.FileAttributes]::Directory) `
        -or $Target.EndsWith("/") `
        -or $Target.EndsWith("\")
    ) {
        $TargetPath = $Synclet.Target
    } elseif ($Target.EndsWith(".")) {
        $Target = $Target.TrimEnd(".")
        $TargetPath = (Split-Path $Target)
    } elseif ($Target -like "*?.?*") {
        $TargetPath = (Split-Path $Target)
    } else {
        $TargetPath = $Synclet.Target
    }

    if ($TargetPath) {
        New-Item `
            -Path $TargetPath `
            -ItemType Directory `
            -ErrorAction SilentlyContinue `
            -Force | Out-Null
    }

    $FileList = @()
    $FileList += (
        Copy-Item `
            -Path $Items `
            -Destination $Target `
            -Recurse `
            -Force `
            -PassThru
    ) | Where-Object {
        ($_.Attributes -band [IO.FileAttributes]::Directory) `
            -ne [IO.FileAttributes]::Directory
    }

    return $FileList
}
