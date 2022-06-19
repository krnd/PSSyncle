#Requires -Version 5.1


function PSSyncle::Invoke-SyncletTemplateEngine {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]
        $Synclet,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $File
    )

    $Parameters = @{}
    $Synclet.Template.PSObject.Properties | ForEach-Object {
        if ($_.Name.StartsWith("$")) {
            return
        }
        $Parameters[$_.Name] = $_.Value
    }

    (ConvertTo-PoshstacheTemplate `
        -InputFile $File `
        -ParametersObject $Parameters `
        -HashTable
    ) | Out-File $File
}
