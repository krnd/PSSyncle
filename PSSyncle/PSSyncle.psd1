@{
    GUID                 = "57233fe7-fb87-4331-acee-2203b84eec32"
    ModuleVersion        = "2.0.0"
    Description          = "PSSyncle"

    CompanyName          = ""
    Author               = "Kilian Kaiping (krnd)"
    Copyright            = "Copyright (c) 2022 Kilian Kaiping (krnd)"

    CompatiblePSEditions = @("Desktop")
    PowerShellVersion    = "5.1"

    RootModule           = "PSSyncle.psm1"
    HelpInfoURI          = "https://github.com/krnd/PSSyncle"

    FunctionsToExport    = @("Invoke-Syncle")
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()

    PrivateData          = @{
        PSData = @{
            ProjectUri                 = "https://github.com/krnd/PSSyncle"
            LicenseUri                 = "https://github.com/krnd/PSSyncle/blob/main/LICENSE"

            Prerelease                 = $null

            ExternalModuleDependencies = @(
                # A Powershell implementation of Mustache based on Stubble
                #   https://github.com/baldator/Poshstache
                "Poshstache",
                # PowerShell wrapper for GitHub API
                #   https://github.com/microsoft/PowerShellForGitHub
                "PowerShellForGitHub"
            )

            Tags                       = @("tool", "sync")
        }
    }
}