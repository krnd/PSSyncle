#Requires -Version 5.1


function PSSyncle::Split-Source {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Synclet,
        [Parameter()]
        [switch]
        $Syncer
    )
    $SourceInfo = ($Synclet.Source -split ":", 2)
    if ($Syncer) {
        return (?: ($SourceInfo.Count -lt 2) "FileSystem" $SourceInfo[0])
    } else {
        return $SourceInfo[-1]
    }
}
