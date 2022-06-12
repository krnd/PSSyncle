#Requires -Version 5.1
#Requires -Modules PowerShellForGitHub


function Sync-GistSynclet {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({
            if (-not $_.Gist) {
                throw "Error 'Synclet[Gist].Gist': $($Synclet.Gist) ($($Synclet.Target))"
            }
            return $true
        })]
        [PSCustomObject]
        $Synclet,
        [Parameter(Mandatory = $true)]
        [PSCustomObject]
        $Config
    )

    $TempPath = New-Item `
        -Path (Join-Path $env:TEMP (New-Guid).Guid) `
        -ItemType Directory
    Get-GitHubGist `
        -Gist $Synclet.Gist `
        -Path $TempPath.FullName `
        -Force

    if ($Synclet.Path) {
        $Path = $Synclet.Path
    } else {
        $Path = "*"
    }
    $Items = Get-Item `
        -Path (Join-Path $TempPath $Path)

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

    Remove-Item `
        -Path $TempPath.FullName `
        -Recurse `
        -Force
    return $FileList
}
