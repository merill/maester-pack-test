function Test-DemoGraphOrganization {
    <#
    .SYNOPSIS
    Reads the tenant's organization from Microsoft Graph and passes when it has a display name.
    #>
    [MaesterTest(
        Id           = 'MP.DEMO.1007',
        Title        = 'Demo: read the tenant from Microsoft Graph',
        Severity     = 'Info',
        Product      = 'entra',
        Feature      = 'tenant',
        Area         = 'configuration',
        ResourceType = 'Tenant',
        Service      = 'Graph'
    )]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $organization = Invoke-MtGraphRequest -RelativeUri 'organization' | Select-Object -First 1
    $passed = -not [string]::IsNullOrWhiteSpace($organization.displayName)
    Add-MtTestResultDetail -Result $(if ($passed) { "Connected to **$($organization.displayName)**." } else { 'The organization has no display name.' })
    $passed
}
