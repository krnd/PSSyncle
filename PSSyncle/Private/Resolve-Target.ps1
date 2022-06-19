#Requires -Version 5.1


function PSSyncle::Resolve-Target {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Synclet,
        [Parameter(Position = 1, Mandatory = $true)]
        [object[]]
        $Items,
        [Parameter(Mandatory = $true)]
        [string]
        $Here,
        [Parameter()]
        [scriptblock]
        $IsDirectory
    )

    $Path = $Synclet.Target
    if ($Path.StartsWith("@")) {
        $Path = (Join-Path $Here $Path.TrimStart("@"))
    }

    if (
        (
            ($Items.Count -and $Items.Count -ne 1) `
                -or (?Invoke $IsDirectory $false) `
                -or $Path.EndsWith("/") `
                -or $Path.EndsWith("\") `
                -or (Test-Path $Path -PathType Container)
        ) -or -not (
            $Path.EndsWith(".") `
                -or ($Path -like "*?.?*")
        )
    ) {
        $Path = $Path.TrimEnd("/\")
        if ($Path -ne "." -and -not $Path.EndsWith("..")) {
            $Path = $Path.TrimEnd(".")
        }
        $Filename = $null
    } else {
        $Path = $Path.TrimEnd(".")
        $Filename = (Split-Path $Path -Leaf)
        $Path = (Split-Path $Path)
    }

    return @{
        Path = $Path
        File = $Filename
    }
}
