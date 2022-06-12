#Requires -Version 5.1


function Invoke-Syncle {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0)]
        [string]
        $File
    )

    if (-not $File) {
        foreach ($SearchPath in @(
            ".",
            ".config",
            ".syncle"
        )) {
            $File = (Join-Path $SearchPath "syncle.json")
            if (Test-Path $File -PathType Leaf) {
                break
            } else {
                $File = $null
            }
        }
    }
    if (-not $File -or -not (Test-Path $File -PathType Leaf)) {
        throw "Cannot find syncle file."
    }

    $Config = (Get-Content $File -Raw | ConvertFrom-Json)

    if ($Config.GitHub) {
        Invoke-SyncleGitHubSetup $Config.GitHub
    }

    foreach ($Synclet in $Config.Synclets) {
        Sync-Synclet $Synclet `
            -Config $Config
    }
}
