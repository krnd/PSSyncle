# cspell:ignore psrepo, psrepository

TASK .
TASK setup              setup:psrepository, setup:dependencies
TASK publish            publish:module
TASK psrepo             show:psrepository


$PSRepository = "PSLocal"
$PSModuleName = "PSSyncle"


# ################################ setup #######################################

TASK setup:dependencies {
    foreach ($ModuleName in @(
        # PowerShell wrapper for GitHub API
        #   https://github.com/microsoft/PowerShellForGitHub
        "PowerShellForGitHub",
        # A Powershell implementation of Mustache based on Stubble
        #   https://github.com/baldator/Poshstache
        "Poshstache"
    )) {
        Install-Module -Name $ModuleName -Scope CurrentUser
        Update-Module -Name $ModuleName -Force
    }

    Set-GitHubConfiguration `
        -DisableTelemetry `
        -SuppressTelemetryReminder
}


# ################################ publish #####################################

TASK publish:module {
    Publish-Module `
        -Path (Join-Path "." $PSModuleName) `
        -Repository $PSRepository `
        -Force
}


# ################################ show ########################################

TASK show:psrepository {
    explorer (Get-PSRepository -Name $PSRepository).SourceLocation
}

