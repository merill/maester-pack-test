function Test-DemoError {
    <#
    .SYNOPSIS
    A test that throws, to show an Error result.
    #>
    [MaesterTest(
        Id           = 'MP.DEMO.1005',
        Title        = 'Demo: a test that errors',
        Severity     = 'Low',
        Product      = 'Demo',
        Feature      = 'results',
        Area         = 'examples',
        ResourceType = 'Tenant'
    )]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    throw 'This demo test throws on purpose, to show an Error result.'
}
