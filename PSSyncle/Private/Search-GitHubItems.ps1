#Requires -Version 5.1


function PSSyncle::Search-GitHubItems {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [hashtable]
        $:Repo,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $Filter,
        [Parameter()]
        [hashtable]
        $Cache
    )
    $Cache = (?? $Cache @{})
    $FilterSteps = ($Filter -split "/")

    $RootItem = (PSSyncle::Get-GitHubItem $:Repo $FilterSteps[0] -Cache $Cache)
    if ($RootItem.Type -eq "file") {
        if ($RootItem.Path -like $Filter) {
            return @([Tuple]::Create($RootItem, (Split-Path $RootItem.Path)))
        } else {
            return @()
        }
    }

    $RemoteItems = @()
    $BasePath = $RootItem.Path
    $ItemList = @($RootItem)
    foreach ($Step in ($FilterSteps | Select-Object -Skip 1)) {
        $StepItems, $ItemList = $ItemList, @()

        $StepItems | ForEach-Object {
            if ($_.Name -eq $Step) {
                $BasePath = $_.Path
            }

            if (-not $_.Entries) {
                $_ = (PSSyncle::Get-GitHubItem $:Repo $_.Path -Cache $Cache)
            }

            $ItemList += $_.Entries | Where-Object {
                if ($_.Type -eq "file") {
                    if ($_.Path -like $Filter) {
                        $RemoteItems += [Tuple]::Create($_, $BasePath)
                    }
                    return $false
                }
                $_.Name -like $Step
            }
        }

        if (-not $ItemList) {
            return $RemoteItems
        }
    }

    if ($ItemList) {
        $ItemList | ForEach-Object {
            $BasePath = (Split-Path $_.Path)
            $Items = PSSyncle::Get-GitHubItem $:Repo `
                -Path $_.Path `
                -Cache $Cache `
                -Recurse
            $Items | ForEach-Object {
                $RemoteItems += [Tuple]::Create($_, $BasePath)
            }
        }
    }

    return $RemoteItems
}
