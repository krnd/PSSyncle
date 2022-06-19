@{
    Module = "PSSyncle"

    Command = "Invoke-Syncle"
    Parameters = @{
        File = (Join-Path $ScriptRoot "syncle.json")
        PassThru = $true
    }

    Output = "output"

    Formatter = {
        $SavedLocation = (Get-Location)
        try {
            Set-Location $OutputPath
            $Input.Items | Select-Object {
                $Path = (Resolve-Path $_.FullName -Relative) -replace "\\", "/"
                if ($Path.StartsWith("./")) {
                    $Path.Substring(2)
                } else {
                    $Path
                }
            } | Format-Table -HideTableHeaders
        } finally {
            Set-Location $SavedLocation
        }
    }
}