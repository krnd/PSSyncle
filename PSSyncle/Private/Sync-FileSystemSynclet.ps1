#Requires -Version 5.1


function Sync-FileSystemSynclet {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Synclet,
        [Parameter(Mandatory = $true)]
        [string]
        $Here
    )

    $Source = (PSSyncle::Split-Source $Synclet)
    try {
        $Items = Get-Item `
            -Path $Source
    } catch {
        throw [System.ArgumentException]::new(
            "Unable to determine items from '$Source'.",
            "Source",
            $_
        )
    }

    if (-not $Items) {
        Write-Warning "Source does not match any items."
    }

    $Target = PSSyncle::Resolve-Target $Synclet $Items -Here $Here `
        -IsDirectory { $_.Attributes -band [IO.FileAttributes]::Directory }

    PSSyncle::New-Directory $Target.Path

    $FileList = @()
    try {
        $FileList += (
            Copy-Item `
                -Path $Items `
                -Destination (Join-Path $Target.Path $Target.File) `
                -Recurse `
                -Force `
                -PassThru
        ) | Where-Object {
            -not ($_.Attributes -band [IO.FileAttributes]::Directory)
        }
    } catch {
        $Destination = (Join-Path $Target.Path $Target.File)
        throw [System.ArgumentException]::new(
            "Unable to copy source items to destination '$Destination'.",
            "Target",
            $_
        )
    }

    return $FileList
}
