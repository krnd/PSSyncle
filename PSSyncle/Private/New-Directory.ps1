#Requires -Version 5.1


function PSSyncle::New-Directory {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Position = 0)]
        [string]
        $Path
    )
    if ($Path) {
        New-Item `
            -Path $Path `
            -ItemType Directory `
            -ErrorAction SilentlyContinue `
            -Force | Out-Null
    }
}
