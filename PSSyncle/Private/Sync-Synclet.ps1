#Requires -Version 5.1


function Sync-Synclet {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({
            if (-not $_.Target) {
                throw "Error 'Synclet.Target': <missing>"
            } elseif (-not $_.Source) {
                throw "Error 'Synclet.Source': <missing> ($($_.Target))"
            }
            return $true
        })]
        [PSCustomObject]
        $Synclet,
        [Parameter(Mandatory = $true)]
        [PSCustomObject]
        $Config
    )

    $Synchronizer = "Sync-$($Synclet.Source)Synclet"
    if (-not (Get-Command $Synchronizer -ErrorAction SilentlyContinue)) {
        throw "Error 'Synclet.Source': $($Synclet.Source) ($($Synclet.Target))"
    }

    $FileList = (& $Synchronizer $Synclet -Config $Config)
}
