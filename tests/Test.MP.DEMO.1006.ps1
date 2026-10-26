function Test-DemoSampleMfaRequired {
    <#
    .SYNOPSIS
    Checks that the demo sample service requires MFA. Needs Connect-Maester -Service DEMO.Sample.
    #>
    [MaesterTest(
        Id           = 'MP.DEMO.1006',
        Title        = 'Demo: the sample service requires MFA',
        Severity     = 'High',
        Product      = 'Demo sample service',
        Feature      = 'authentication',
        Area         = 'authentication',
        ResourceType = 'Tenant',
        Service      = 'DEMO.Sample'
    )]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $settings = Get-DemoSampleSetting
    $passed = [bool]$settings.MfaRequired
    Add-MtTestResultDetail -Result $(if ($passed) { 'Well done. The sample service requires MFA.' } else { 'The sample service does not require MFA.' })
    $passed
}
