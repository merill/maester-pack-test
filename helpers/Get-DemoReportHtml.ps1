function Get-DemoReportHtml {
    <#
    .SYNOPSIS
    Returns the HTML report of MP.DEMO.1008: assets/insights-report.html with its data and Chart.js inline.

    .DESCRIPTION
    A report added with Add-MtReportAttachment opens inside the Maester report, in a sandboxed frame: its
    scripts run in an origin of their own, so they cannot read or change the Maester report, and it cannot
    count on the network. So the report is one file:

    - the page is assets/insights-report.html, which you can open in a browser while you design it: it loads
      Chart.js from assets/chart.js and shows the sample data written into it;
    - this function puts Chart.js inline in place of that script tag, and replaces the sample data with the
      data of this run, as JSON.

    The page draws everything from the JSON and writes text with textContent, never innerHTML, so a value
    from the tenant cannot add markup. The JSON escapes <, > and &, so a value cannot end the script block.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The data the charts draw, from Get-DemoInsightData.
        [Parameter(Mandatory)]
        [hashtable] $Data
    )

    $assets = Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'assets'
    $page = Get-Content -LiteralPath (Join-Path $assets 'insights-report.html') -Raw
    $chartJs = Get-Content -LiteralPath (Join-Path $assets 'chart.js/chart.umd.min.js') -Raw

    $json = $Data | ConvertTo-Json -Depth 8 -Compress
    # Write <, > and & as JSON escapes (backslash, u and four hex digits), so no value can close the script block.
    $json = [regex]::Replace($json, '[<>&]', { param($match) '\' + 'u' + ([int][char]$match.Value).ToString('x4') })

    $libraryTag = '<script src="chart.js/chart.umd.min.js"></script>'
    if (-not $page.Contains($libraryTag)) { throw "assets/insights-report.html no longer loads Chart.js with $libraryTag." }
    $page = $page.Replace($libraryTag, "<script>`n$chartJs`n</script>")
    # The sample data sits between these two markers.
    $start = $page.IndexOf('<script id="report-data" type="application/json">')
    $end = if ($start -ge 0) { $page.IndexOf('</script>', $start) }
    if ($start -lt 0 -or $end -lt 0) { throw 'assets/insights-report.html has no <script id="report-data" type="application/json"> block.' }
    $open = '<script id="report-data" type="application/json">'
    $page.Substring(0, $start) + $open + $json + $page.Substring($end)
}
