#Requires -Version 5.1
#Requires -Modules Poshstache


function Invoke-Syncle {
    [CmdletBinding(PositionalBinding = $False)]
    param (
        [Parameter(Position = 0)]
        [string]
        $File
    )

    if (-not $File) {
        foreach ($SearchPath in @(
                ".",
                ".syncle",
                ".config"
            )) {
            $File = (Join-Path $SearchPath "syncle.json")
            if (Test-Path $File)
            { break }
            $File = $null
        }
    }
    if (-not $File -or -not (Test-Path $File))
    { throw "Syncle file not found." }

    $config = Get-Content -Path $File | ConvertFrom-Json

    if ($config.github) {
        Invoke-SyncleGitHubAuth `
            -UserName $config.github.user `
            -TokenFile $config.github.token
    }

    foreach ($synclet in $config.synclets) {
        $OutFile = $synclet.file
        $CacheFile = & "Sync-$($synclet.source)Synclet" $synclet -Cache

        if (-not $synclet.template) {
            Move-Item `
                -Path $CacheFile `
                -Destination $OutFile `
                -Force

            continue
        }

        $TemplateParameter = @{}
        $synclet.template.PSObject.Properties | ForEach-Object {
            $TemplateParameter[$_.Name] = $_.Value
        }

        ConvertTo-PoshstacheTemplate -InputFile $CacheFile -ParametersObject $TemplateParameter -HashTable | Out-File $OutFile
        Remove-Item `
            -Path $CacheFile `
            -Force
    }
}
