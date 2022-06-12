#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Sync-GitHubSynclet {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({
            if (-not $_.Repo) {
                throw "Error 'Synclet[GitHub].Repo': $($Synclet.Repo) ($($Synclet.Target))"
            } elseif (-not $_.Path) {
                throw "Error 'Synclet[GitHub].Path': $($Synclet.Path) ($($Synclet.Target))"
            }
            return $true
        })]
        [PSCustomObject]
        $Synclet,
        [Parameter(Mandatory = $true)]
        [PSCustomObject]
        $Config
    )

    $ItemPath = $Synclet.Path
    if ($ItemPath.EndsWith("/*") -or $ItemPath.EndsWith("\*")) {
        $ItemPath = $ItemPath.TrimEnd("/\*")
        $FolderContentOnly = $true
    } else {
        $FolderContentOnly = $false
    }

    $OwnerName, $RepositoryName = $Synclet.Repo -split "/"
    $RemoteItem = Get-GitHubContent `
        -OwnerName $OwnerName `
        -RepositoryName $RepositoryName `
        -Path $ItemPath

    $RequestList = @()
    if ($RemoteItem.Type -eq "dir") {
        $BasePath = $RemoteItem.Path
        $DirectoryQueue = [System.Collections.Queue]@($RemoteItem)
        while ($DirectoryQueue.Count) {
            $DirectoryQueue.Dequeue().Entries | ForEach-Object {
                if ($_.Type -eq "dir") {
                    $DirEntry = Get-GitHubContent `
                        -OwnerName $OwnerName `
                        -RepositoryName $RepositoryName `
                        -Path $_.Path
                    $DirectoryQueue.Enqueue($DirEntry)
                } else {
                    $RequestList += $_
                }
            }
        }
    } else {
        $BasePath = $null
        $RequestList += $RemoteItem
    }

    $Target = $Synclet.Target
    if (
        $Target.EndsWith("/") `
        -or $Target.EndsWith("\") `
        -or (Test-Path $Target -PathType Container)
    ) {
        $IsTargetFolder = $true
    } elseif (
        $Target.EndsWith(".") `
            -or ($Target -like "*?.?*")
    ) {
        $IsTargetFolder = $false
        $Target = $Target.TrimEnd(".")
    } else {
        $IsTargetFolder = $true
    }

    if ($IsTargetFolder -and -not $FolderContentOnly) {
        $Target = (Join-Path $Target $RemoteItem.Name)
    }

    $FileList = @()
    $RequestList | ForEach-Object {
        $SubPath = (Split-Path $_.Path)
        if ($SubPath -and $BasePath) {
            $SubPath = $SubPath.Substring($BasePath.Length).TrimEnd("/")
        }

        $OutFile = $Target
        if ($IsTargetFolder) {
            if ($SubPath) {
                $OutFile = (Join-Path $OutFile $SubPath)
            }
            $OutFile = (Join-Path $OutFile $_.Name)
        }

        $OutFilePath = (Split-Path $OutFile)
        if ($OutFilePath) {
            New-Item `
                -Path $OutFilePath `
                -ItemType Directory `
                -ErrorAction SilentlyContinue `
                -Force | Out-Null
        }

        Invoke-WebRequest `
            -Uri $_.Download_URL `
            -OutFile $OutFile `
            -UseBasicParsing
        $FileList += (Get-Item $OutFile)
    }

    return $FileList
}
