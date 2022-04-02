@{
    GUID                 = "57233fe7-fb87-4331-acee-2203b84eec32"
    Description          = "PSSyncle"
    ModuleVersion        = "0.0.0"

    CompanyName          = ""
    Author               = "Kilian Kaiping (krnd)"
    Copyright            = "Copyright (c) 2022 Kilian Kaiping (krnd)"

    CompatiblePSEditions = @("Desktop")
    PowerShellVersion    = "5.1"

    FunctionsToExport    = @("Invoke-Syncle")
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()

    RootModule           = "PSSyncle.psm1"
    HelpInfoURI          = ""

    PrivateData          = @{
        PSData = @{
            PreRelease                 = "-pre3"

            ProjectUri                 = "https://github.com/krnd/PSSyncle"
            LicenseUri                 = "https://github.com/krnd/PSSyncle/blob/main/LICENSE"

            ExternalModuleDependencies = @("Poshstache", "PowerShellForGitHub")

            Tags                       = @("sync", "tool")
        }
    }
}