#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Sync-GistSynclet {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Synclet,
        [Parameter(Mandatory = $true)]
        [string]
        $Here
    )

    $Source, $Filter = ((PSSyncle::Split-Source $Synclet) -split "/", 2)
    try {
        $GistInfo = Get-GitHubGist `
            -Gist $Source
    } catch {
        throw [System.ArgumentException]::new(
            "Unable to determine Gist '$Source'.",
            "Source",
            $_
        )
    }

    $Filter = (?? $Filter $Synclet.Filter)
    $RemoteItems = $GistInfo.Files.PSObject.Properties.Value
    if ($Filter) {
        $RemoteItems = $RemoteItems | Where-Object {
            foreach ($Pattern in $Filter) {
                if ($_.Filename -like $Pattern) {
                    return $true
                }
            }
            return $false
        }
    }

    if (-not $RemoteItems) {
        Write-Warning "Source does not match any items."
    }

    $Target = PSSyncle::Resolve-Target $Synclet $RemoteItems -Here $Here

    PSSyncle::New-Directory $Target.Path

    $FileList = @()
    $RemoteItems | ForEach-Object {
        $OutFile = (Join-Path $Target.Path (?? $Target.File $_.Filename))

        if ($_.Truncated) {
            PSSyncle::Out-GitHubFile $_.Raw_URL $OutFile
        } else {
            $_.Content | Out-File $OutFile
        }

        $FileList += (Get-Item $OutFile)
    }

    return $FileList
}
