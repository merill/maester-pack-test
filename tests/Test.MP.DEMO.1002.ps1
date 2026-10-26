function Test-DemoAlwaysFails {
    <#
    .SYNOPSIS
    A test that fails with a table of findings, and a threshold users can change in their config.
    #>
    [MaesterTest(
        Id           = 'MP.DEMO.1002',
        Title        = 'Demo: a test that fails, with a setting',
        Severity     = 'High',
        Product      = 'Demo',
        Feature      = 'results',
        Area         = 'examples',
        ResourceType = 'Tenant'
    )]
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # The lowest score an app may have. Set it to 70 in maester-config.json to see this test pass.
        [ValidateRange(0, 100)]
        [int] $MinimumScore = 80
    )

    # Made-up data: a real test reads it from the service.
    $apps = @(
        [pscustomobject]@{ Name = 'Contoso app one'; Score = 92 }
        [pscustomobject]@{ Name = 'Contoso app two'; Score = 74 }
        [pscustomobject]@{ Name = 'Contoso app three'; Score = 71 }
    )
    $failing = @($apps | Where-Object { $_.Score -lt $MinimumScore })
    $passed = $failing.Count -eq 0

    # Start with one sentence that says what was found, then the detail as a table.
    $rows = foreach ($app in $apps) {
        $mark = if ($app.Score -lt $MinimumScore) { '❌ Below' } else { '✅ Meets' }
        "| $($app.Name) | $($app.Score) | $mark |"
    }
    $summary = if ($passed) { "Well done. Every app scores at least $MinimumScore." } else { "$($failing.Count) of $($apps.Count) apps score below $MinimumScore." }
    $result = "$summary`n`n| App | Score | Minimum $MinimumScore |`n| --- | --- | --- |`n" + ($rows -join "`n")
    Add-MtTestResultDetail -Result $result
    $passed
}
