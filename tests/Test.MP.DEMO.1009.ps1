function Get-DemoSampleApp {
    <#
    .SYNOPSIS
    Instance source of MP.DEMO.1009: one instance per app, so each app gets its own result row.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    # Made-up data: a real instance source reads the objects from the service, once for the whole family.
    $apps = @(
        @{ Id = 'app-one'; Name = 'Contoso app one'; Owner = 'Adele Vance' }
        @{ Id = 'app-two'; Name = 'Contoso app two'; Owner = $null }
        @{ Id = 'app-three'; Name = 'Contoso app three'; Owner = 'Lee Gu' }
    )
    foreach ($app in $apps) {
        [pscustomobject]@{
            Id    = $app.Id                                  # required: becomes MP.DEMO.1009.<Id>
            Title = "Demo: '$($app.Name)' has an owner"      # optional: the title of this instance's row
            Data  = $app                                     # optional: whatever the test needs
        }
    }
}

function Test-DemoSampleAppOwner {
    <#
    .SYNOPSIS
    A family: one result per app that the instance source returns.
    #>
    [MaesterTest(
        Id             = 'MP.DEMO.1009',
        Title          = 'Demo: every app has an owner',
        Severity       = 'Medium',
        Product        = 'Demo',
        Feature        = 'apps',
        Area           = 'governance',
        ResourceType   = 'Application',
        InstanceSource = 'Get-DemoSampleApp'
    )]
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # The app to check, supplied by the engine.
        $Instance
    )

    $owner = $Instance.Data.Owner
    $passed = -not [string]::IsNullOrWhiteSpace($owner)
    Add-MtTestResultDetail -Result $(if ($passed) { "Well done. The owner is $owner." } else { 'This app has no owner. Assign one so someone is responsible for it.' })
    $passed
}
