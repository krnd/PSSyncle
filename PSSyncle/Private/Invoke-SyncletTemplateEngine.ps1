#Requires -Version 5.1


function Invoke-SyncletTemplateEngine {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({
            if (-not $_.Template) {
                throw "Error 'Synclet.Template': <missing>"
            }
            return $true
        })]
        [PSCustomObject]
        $Synclet,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $File
    )

    $TemplateParameter = @{}
    $Synclet.Template.PSObject.Properties | ForEach-Object {
        if ($_.Name.StartsWith("$")) {
            return
        }
        $TemplateParameter[$_.Name] = $_.Value
    }

    (ConvertTo-PoshstacheTemplate `
        -InputFile $File `
        -ParametersObject $TemplateParameter `
        -HashTable
    ) | Out-File $File
}
