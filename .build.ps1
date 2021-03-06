#Requires -Version 5.1

# cspell:ignore buildscripts, invokebuild


# ################################ VARIABLES ###################################

$script:InvokeBuildPaths = @(
    ".",
    ".invoke",
    ".invokebuild",
    "invoke",
    "invoke-build",
    "invokebuild"
)

$script:__InvokeBuild_SetupScripts = @()


# ################################ FUNCTIONS ###################################

function __InvokeBuild_SETUP {
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = "script")]
    param (
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "script")]
        [scriptblock]
        $Script,
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "execute")]
        [switch]
        $ExecuteAll

    )
    if ($ExecuteAll) {
        foreach ($Script in $script:__InvokeBuild_SetupScripts) {
            & $Script
        }
        $script:__InvokeBuild_SetupScripts = @()
    } else {
        $script:__InvokeBuild_SetupScripts += $Script
    }
}

Set-Alias INVOKEBUILD:SETUP __InvokeBuild_SETUP


# ################################ PLUGINS #####################################

foreach ($SearchPath in $script:InvokeBuildPaths) {
    if (Test-Path $SearchPath -PathType Container) {
        Get-ChildItem $SearchPath -Filter "*.plugin.ps1" | ForEach-Object {
            . $_.FullName
        }
    }
}

INVOKEBUILD:SETUP -ExecuteAll


# ################################ BUILDSCRIPTS ################################

foreach ($SearchPath in $script:InvokeBuildPaths) {
    if (Test-Path $SearchPath -PathType Container) {
        Get-ChildItem $SearchPath -Filter "*.build.ps1" | ForEach-Object {
            if ($_.FullName -eq $MyInvocation.MyCommand.Definition) {
                return
            }
            . $_.FullName
        }
    }
}

INVOKEBUILD:SETUP -ExecuteAll
