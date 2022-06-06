#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Sync-GistSynclet {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Synclet
    )

    if (-not $Synclet.Gist)
    { throw "Error 'Synclet[Gist].Gist': $($Synclet.Gist) ($($Synclet.Target))" }

    $TempPath = New-Item `
        -Path (Join-Path $env:TEMP (New-Guid).Guid) `
        -ItemType Directory
    Get-GitHubGist `
        -Gist $Synclet.Gist `
        -Path $TempPath.FullName `
        -Force

    if (-not $Synclet.File) {
        $TargetFile = $null

        (New-Item `
            -Path $Synclet.Target `
            -ItemType Directory `
            -Force
        ) | Out-Null
        (Get-ChildItem `
            -Path $TempPath.FullName
        ) | Move-Item `
            -Destination $Synclet.Target `
            -Force

    } else {
        $FilePath = (Join-Path $TempPath.FullName $Synclet.File)
        if (-not (Test-Path $FilePath -PathType Leaf))
        { throw "Error 'Synclet[Gist].File': $($Synclet.File) ($($Synclet.Target))" }

        if ($Synclet.Target.EndsWith("\")  `
                -or $Synclet.Target.EndsWith("/") `
                -or (Test-Path $Synclet.Target -PathType Container)) {
            $TargetPath = $Synclet.Target
            $TargetFile = (Join-Path $Synclet.Target (Split-Path $FilePath -Leaf))
        } else {
            $TargetPath = (Split-Path $Synclet.Target)
            $TargetFile = $Synclet.Target
        }

        if ($TargetPath) {
            (New-Item `
                -Path $TargetPath `
                -ItemType Directory `
                -Force
            ) | Out-Null
        }
        Move-Item `
            -Path $FilePath `
            -Destination $TargetFile `
            -Force
    }

    Remove-Item `
        -Path $TempPath.FullName `
        -Recurse `
        -Force
    return $TargetFile
}
