#Requires -Version 5.1
#Requires -Modules Poshstache


function Invoke-Syncle {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0)]
        [ValidateScript({
                if (-not $_)
                { return $true }
                elseif (-not (Test-Path $_))
                { throw "Path '$_' does not exist." }
                elseif (-not (Test-Path $_ -PathType Leaf))
                { throw "Path '$_' is no file." }
                return $true
            })]
        [System.IO.FileInfo]
        $File
    )

    if (-not $File) {
        foreach ($SearchPath in @(
                ".",
                ".syncle",
                ".config"
            )) {
            $File = (Join-Path $SearchPath "syncle.json")
            if (Test-Path $File -PathType Leaf)
            { break }
            $File = $null
        }
    }
    if (-not $File -or -not (Test-Path $File -PathType Leaf))
    { throw "Cannot find synchronization file." }

    $Config = Get-Content $File | ConvertFrom-Json

    if ($Config.GitHub) {
        Invoke-SyncleGitHubSetup $Config.GitHub
    }

    foreach ($Synclet in $Config.Synclets) {
        if (-not $Synclet.Target)
        { throw "Error 'Synclet.Target': <invalid>" }

        $Cmdlet = "Sync-$($Synclet.Source)Synclet"
        if (-not (Get-Command $Cmdlet -ErrorAction SilentlyContinue))
        { throw "Error 'Synclet.Source': $($Synclet.Source) ($($Synclet.Target))" }

        $TargetFile = & $Cmdlet $Synclet

        if (-not $TargetFile -or -not $Synclet.Template)
        { continue }

        $TemplateParameter = @{}
        $Synclet.Template.PSObject.Properties | ForEach-Object {
            if ($_.Name.StartsWith("$"))
            { return }
            $TemplateParameter[$_.Name] = $_.Value
        }

        (ConvertTo-PoshstacheTemplate `
            -InputFile $TargetFile `
            -ParametersObject $TemplateParameter `
            -HashTable
        ) | Out-File $TargetFile
    }
}
