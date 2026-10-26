function Connect-DemoSample {
    <#
    .SYNOPSIS
    Connects to the demo sample service, which is not a real service: it keeps the settings it is given.

    .DESCRIPTION
    Connect-Maester -Service DEMO.Sample calls it. Its parameters come from -ServiceSetting, from
    Connections.DEMO.Sample in maester-config.json, or from MAESTER_DEMO_SAMPLE_<NAME> environment variables,
    for example: Connect-Maester -Service DEMO.Sample -ServiceSetting @{ Tenant = 'contoso'; MfaRequired = $false }
    #>
    [CmdletBinding()]
    param(
        [string] $Tenant = 'contoso',

        [bool] $MfaRequired = $true
    )

    Set-MtConnectionState -Value @{ Tenant = $Tenant; Settings = @{ MfaRequired = $MfaRequired } } -Tenant $Tenant -Account "admin@$Tenant.example"
}

function Test-DemoSample {
    <#
    .SYNOPSIS
    Returns $true when Connect-DemoSample has run in this session. Tests that need DEMO.Sample are skipped otherwise.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    [bool](Get-MtConnectionState)
}

function Disconnect-DemoSample {
    <#
    .SYNOPSIS
    Forgets the demo sample connection.
    #>
    [CmdletBinding()]
    param()

    Clear-MtConnectionState
}
