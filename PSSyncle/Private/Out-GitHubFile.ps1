#Requires -Version 5.1


function PSSyncle::Out-GitHubFile {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs", "")]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Uri,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $OutFile
    )

    try {
        $Response = Invoke-WebRequest `
            -Uri $Uri `
            -OutFile $OutFile `
            -UseBasicParsing `
            -PassThru
    } catch {
        throw [System.Net.WebException]::new(
            "Unable to request remote GitHub item at '$Uri'.",
            $_
        )
    }

    if ($Response.StatusCode -ne 200) {
        throw [System.Net.WebException]::new(
            "Unsuccessful request to remote GitHub item at '$Uri'.",
            [System.Net.WebException]::new(
                "Request did not respond with status code '200'."
            ),
            [System.Net.WebExceptionStatus]::Success,
            $Response
        )
    }
}
