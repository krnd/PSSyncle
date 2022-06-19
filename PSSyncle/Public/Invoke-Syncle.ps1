#Requires -Version 5.1


function Invoke-Syncle {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0)]
        [string]
        $File,
        [Parameter()]
        [switch]
        $PassThru
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
        throw [System.IO.FileNotFoundException]::new(
            "Unable to find syncle configuration file.",
            $File
        )
    }

    $Config = (Get-Content $File -Raw | ConvertFrom-Json)

    if ($Config.GitHub) {
        try {
            PSSyncle::Invoke-GitHubAuthentication $Config.GitHub
        } catch [ArgumentException] {
            throw [System.ArgumentException]::new(
                "GitHub.$($_.ParamName)",
                $_
            )
        }
    }

    if ($PassThru) {
        $SyncList = [System.Collections.ArrayList]@()
    }

    foreach ($Synclet in $Config.Synclets) {
        try {

            $Result = Sync-Synclet $Synclet `
                -Here "." `
                -PassThru:$PassThru

            if ($PassThru) {
                [void]$SyncList.Add($Result)
            }

        } catch [ArgumentException] {
            $Syncer = (?: $Synclet.Source (PSSyncle::Split-Source $Synclet -Syncer) "??")
            throw [System.ArgumentException]::new(
                "Synclets[$Syncer].$($_.ParamName)",
                $_
            )
        }
    }

    foreach ($File in $Config.Files) {
        $FileEntry = $File

        if (Test-Path $File -PathType Container) {
            $File = (Join-Path $File "synclets.json")
        }

        try {
            $SyncletList = (Get-Content $File -Raw | ConvertFrom-Json)
        } catch [System.IO.FileNotFoundException] {

        }

        foreach ($Synclet in $SyncletList) {
            try {

                $Result = Sync-Synclet $Synclet `
                    -Here (Split-Path $File) `
                    -PassThru:$PassThru

                if ($PassThru) {
                    [void]$SyncList.Add($Result)
                }

            } catch [ArgumentException] {
                $Syncer = (?: $Synclet.Source (PSSyncle::Split-Source $Synclet -Syncer) "??")
                throw [System.ArgumentException]::new(
                    "Files[$($FileEntry):$Syncer].$($_.ParamName)",
                    $_
                )
            }
        }
    }

    if ($PassThru) {
        return $SyncList
    }
}
