#Requires -Version 5.1


function Sync-Synclet {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({
            if (-not $_.Source) {
                throw [System.ArgumentNullException]::new("Source")
            } elseif (-not $_.Target) {
                throw [System.ArgumentNullException]::new("Target")
            }
            return $true
        })]
        [PSCustomObject]
        $Synclet,
        [Parameter()]
        [string]
        $Here,
        [Parameter()]
        [switch]
        $PassThru
    )

    $SyncerName = (PSSyncle::Split-Source $Synclet -Syncer)
    $CommandName = "Sync-$($SyncerName)Synclet"
    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        throw [System.ArgumentOutOfRangeException]::new(
            "Source", $_.Source,
            "The term '$CommandName' is not recognized as the name of a cmdlet, function, script file, or operable program."
        )
    }

    $FileList = (& $CommandName $Synclet -Here $Here)

    if ($Synclet.Template) {
        $FileList | ForEach-Object {
            Invoke-SyncletTemplateEngine $Synclet $_
        }
    }

    if ($PassThru) {
        $Synclet | Add-Member `
            -MemberType NoteProperty `
            -Name Items `
            -Value $FileList
        return $Synclet
    }
}
