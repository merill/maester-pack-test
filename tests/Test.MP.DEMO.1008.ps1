function Test-DemoLongRunning {
    <#
    .SYNOPSIS
    A long-running test that shows its progress live in the Maester console and adds its own report to the
    Maester HTML report.

    .DESCRIPTION
    Runs for about half a minute through three made-up stages: it collects six kinds of data, runs twelve
    checks of its own, and writes an HTML report.

    - Write-MtTestOutput opens a box in the dashboard and writes the log into it.
    - Write-MtTestProgress fills the top of the box: the stages as a track, a bar of the items done, the items
      running and finished with their times, and the errors. While the checks run, -Results and -Groups make
      the dashboard's Results panel, result blocks and product list show the checks' results by area, and
      the times of the finished items go into the Pace graph and the Slowest panel.
    - Add-MtReportAttachment adds the HTML report to the Maester report, under Reports in its left menu. The
      report is a gallery of chart ideas (Chart.js, inline) for insights that pass and fail cannot show.

    A tool that runs in another process does the same by writing ##maester[progress] lines to its output, which
    is piped to Write-MtTestOutput.

    Run it with Invoke-Maester -Pack DEMO, which runs a named pack's long-running tests, or -IncludeLongRunning.
    #>
    [MaesterTest(
        Id           = 'MP.DEMO.1008',
        Title        = 'Demo: a long-running test with live progress and a report',
        Severity     = 'Info',
        Product      = 'Demo',
        Feature      = 'long-running',
        Area         = 'examples',
        ResourceType = 'Tenant',
        LongRunning  = $true
    )]
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # How long each made-up item takes, in milliseconds. Lower it to make the demo quicker.
        [ValidateRange(0, 10000)]
        [int] $ItemMilliseconds = 900
    )

    $stages = 'Collect', 'Check', 'Report'
    $finished = [System.Collections.Generic.List[object]]::new()
    $errors = 0
    Write-MtTestOutput -Title 'Demo pack: long-running test'

    # Stage 1: collect the data, one item at a time. Each finished item is listed with its result and time.
    $kinds = 'Users', 'Groups', 'Devices', 'Applications', 'Policies', 'Sites'
    $counts = @{ Users = 1284; Groups = 214; Devices = 0; Applications = 9; Policies = 37; Sites = 58 }
    $collection = [System.Collections.Generic.List[object]]::new()
    for ($i = 0; $i -lt $kinds.Count; $i++) {
        $kind = $kinds[$i]
        $running = @{ Id = $kind; Title = "Collecting $kind"; Status = 'Running'; Detail = 'Reading page 1'; Seconds = 0 }
        Write-MtTestProgress -Stages $stages -StageNumber 1 -Stage 'Collecting data' -Completed ($i - $errors) -Failed $errors -Total $kinds.Count -Running 1 -Items (@($running) + $finished)
        Write-MtTestOutput "Collecting ${kind}..."
        $clock = [System.Diagnostics.Stopwatch]::StartNew()
        Start-Sleep -Milliseconds ($ItemMilliseconds * (1 + ($i % 3)))
        if ($kind -eq 'Devices') {
            # A failure the tool reports: shown in red in the box, and counted on it.
            $errors++
            Write-MtTestProgress -ErrorMessage 'Collecting Devices failed: this demo error is on purpose.'
            $finished.Insert(0, @{ Id = $kind; Title = "Collecting $kind"; Status = 'Failed'; Detail = 'Demo error'; Seconds = $clock.Elapsed.TotalSeconds })
        } else {
            Write-MtTestOutput "Collected ${kind}."
            $finished.Insert(0, @{ Id = $kind; Title = "Collecting $kind"; Status = 'Passed'; Seconds = $clock.Elapsed.TotalSeconds })
        }
        $collection.Add([pscustomobject]@{ Name = $kind; Items = $counts[$kind]; Seconds = $clock.Elapsed.TotalSeconds; Status = $finished[0].Status })
    }

    # Stage 2: run the tool's own checks, and show their results by area in the dashboard.
    $checks = foreach ($n in 1..12) {
        [pscustomobject]@{
            Id     = "C$n"
            Title  = "Check $n"
            Area   = @('Identity', 'Devices', 'Data')[($n - 1) % 3]
            Result = if ($n % 5 -eq 0) { 'Failed' } elseif ($n % 7 -eq 0) { 'Investigate' } else { 'Passed' }
        }
    }
    $finished.Clear()
    $done = [System.Collections.Generic.List[object]]::new()
    foreach ($check in $checks) {
        $all = @{ Name = 'Demo checks'; Total = $checks.Count; Running = 1 }
        $groups = foreach ($area in 'Identity', 'Devices', 'Data') {
            $mine = @($done | Where-Object Area -EQ $area)
            @{
                Name        = $area
                Total       = @($checks | Where-Object Area -EQ $area).Count
                Passed      = @($mine | Where-Object Result -EQ 'Passed').Count
                Failed      = @($mine | Where-Object Result -EQ 'Failed').Count
                Investigate = @($mine | Where-Object Result -EQ 'Investigate').Count
                Running     = [int]($check.Area -eq $area)
            }
        }
        foreach ($result in 'Passed', 'Failed', 'Investigate') { $all[$result] = @($done | Where-Object Result -EQ $result).Count }
        $running = @{ Id = $check.Id; Title = $check.Title; Status = 'Running'; Detail = "Checking $($check.Area)"; Seconds = 0 }
        Write-MtTestProgress -Stages $stages -StageNumber 2 -Stage 'Running checks' -Completed $done.Count -Total $checks.Count -Running 1 `
            -Items (@($running) + $finished) -Results $all -Groups $groups -GroupLabel 'Areas'
        $clock = [System.Diagnostics.Stopwatch]::StartNew()
        Start-Sleep -Milliseconds ([int]($ItemMilliseconds * (0.5 + ($done.Count % 4) / 2)))
        $done.Add($check)
        $status = if ($check.Result -eq 'Investigate') { 'Passed' } else { $check.Result }
        $finished.Insert(0, @{ Id = $check.Id; Title = $check.Title; Status = $status; Seconds = $clock.Elapsed.TotalSeconds })
        Write-MtTestOutput "$($check.Title): $($check.Result)"
    }

    # Stage 3: write the tool's report and add it to the Maester report. The report shows what the results
    # cannot (spread, trends, outliers, the run itself), not the checks again: see assets/insights-report.html.
    Write-MtTestProgress -Stages $stages -StageNumber 3 -Stage 'Writing the report' -Completed 0 -Total 1 -Running 1
    Write-MtTestOutput 'Writing the HTML report'
    $insights = Get-DemoInsightData -Collection $collection
    Add-MtReportAttachment -Name 'Demo pack insights' -Content (Get-DemoReportHtml -Data $insights)
    Write-MtTestOutput -Complete

    $failed = @($checks | Where-Object Result -EQ 'Failed').Count
    Add-MtTestResultDetail -Result "Collected $($kinds.Count) kinds of data (one failed on purpose) and ran $($checks.Count) checks: $failed failed. Open **Demo pack insights** under **Reports** in the left menu of this report."
    $true
}
