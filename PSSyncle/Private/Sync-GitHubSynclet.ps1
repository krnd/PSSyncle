#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Sync-GitHubSynclet {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({
            if ($_.Source -notlike "*?/?*") {
                throw [System.ArgumentOutOfRangeException]::new(
                    "Source",
                    $_.Source,
                    "Source not of form '<OwnerName>/<RepositoryName>'."
                )
            } elseif (-not $_.Filter -and $_.Source -notlike "*?/?*?/?*") {
                throw [System.ArgumentNullException]::new("Filter")
            }
            return $true
        })]
        [PSCustomObject]
        $Synclet,
        [Parameter(Mandatory = $true)]
        [string]
        $Here
    )

    $OwnerName, $RepositoryName, $Filter = ((PSSyncle::Split-Source $Synclet) -split "/", 3)
    $:Repo = @{
        OwnerName      = $OwnerName
        RepositoryName = $RepositoryName
    }

    try {
        $RepoInfo = Get-GitHubRepository @:Repo
    } catch {
        throw [System.ArgumentException]::new(
            "Unable to determine GitHub repository '$OwnerName/$RepositoryName'.",
            "Source",
            $_
        )
    }

    if ($Filter -and $Synclet.Filter) {
        $Filter = $Synclet.Filter | ForEach-Object {
            $Filter + "/" + $_
        }
    } else {
        $Filter = (?? $Filter $Synclet.Filter)
    }

    $Cache = @{}
    $RemoteItems = @()
    $Filter | ForEach-Object {
        $RemoteItems += (PSSyncle::Search-GitHubItems $:Repo $_ -Cache $Cache)
    }

    $Target = PSSyncle::Resolve-Target $Synclet $RemoteItems -Here $Here

    $FileList = @()
    $RemoteItems | ForEach-Object {
        $Item, $BasePath = $_.Item1, $_.Item2

        $SubPath = (Split-Path $Item.Path)
        if ($BasePath) {
            $SubPath = $SubPath.Substring($BasePath.Length).TrimStart("/")
        }

        $TargetPath = (Join-Path $Target.Path $SubPath)
        if ($Target.File) {
            $OutFile = (Join-Path $TargetPath $Target.File)
        } else {
            $OutFile = (Join-Path $TargetPath $Item.Name)
        }

        PSSyncle::New-Directory (Split-Path $OutFile)

        PSSyncle::Out-GitHubFile $Item.Download_URL $OutFile

        $FileList += (Get-Item $OutFile)
    }

    return $FileList
}
