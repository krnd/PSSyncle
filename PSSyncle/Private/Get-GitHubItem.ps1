#Requires -Version 5.1


function PSSyncle::Get-GitHubItem {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [hashtable]
        $:Repo,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $Path,
        [Parameter()]
        [hashtable]
        $Cache,
        [Parameter()]
        [switch]
        $Recurse
    )

    if ($Cache -and $Cache.ContainsKey($Path)) {
        $Content = $Cache[$Path]
    } else {
        $Content = Get-GitHubContent @:Repo `
            -Path $Path
        if ($Cache) {
            $Cache[$Path] = $Content
        }
    }

    if (-not $Recurse) {
        return $Content
    } elseif ($Content.Type -eq "file") {
        return @($Content)
    }

    $FileList = $()
    $DirList = @($Content)
    while ($DirList) {
        $ForEachList, $DirList = $DirList, @()
        $ForEachList | ForEach-Object {
            if (-not $_.Entries) {
                $_ = Get-GitHubContent @:Repo `
                    -Path $_.Path
            }
            $_.Entries | ForEach-Object {
                if ($_.Type -eq "file") {
                    $FileList += $_
                } else {
                    $DirList += $_
                }
            }
        }
    }

    return $FileList
}
