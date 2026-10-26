function Get-DemoInsightData {
    <#
    .SYNOPSIS
    Returns the made-up data that the MP.DEMO.1008 report draws its charts from.

    .DESCRIPTION
    A report shows what the results cannot: how much there is, how it is spread, how it changes over time and
    where the outliers are. A real pack computes these from the data it collected; the demo makes them up, the
    same on every run, so the report always looks the same. Only Collection is real: the time each kind of
    data took to collect in this run.

    Each property becomes one chart or card in assets/insights-report.html, which reads them as JSON.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        # What the test collected in this run: each with Name, Items, Seconds and Status.
        [Parameter(Mandatory)]
        [object[]] $Collection
    )

    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    $today = [datetime]::UtcNow.Date
    # The last twelve Mondays, oldest first, for the trend over time.
    $monday = $today.AddDays(-(([int]$today.DayOfWeek + 6) % 7))
    $weeks = foreach ($i in 11..0) { $monday.AddDays(-7 * $i).ToString('MMM d', $culture) }

    # Sign-ins of admins by day and hour: busy in working hours, with a few at night that someone should look at.
    $random = [System.Random]::new(1008)
    $days = 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    $heat = foreach ($d in 0..6) {
        , @(foreach ($h in 0..23) {
                $work = $d -lt 5 -and $h -ge 8 -and $h -le 17
                $edge = $d -lt 5 -and ($h -eq 7 -or $h -eq 18 -or $h -eq 19)
                if ($work) { 14 + $random.Next(0, 18) - [math]::Abs(12 - $h) } elseif ($edge) { 3 + $random.Next(0, 5) } else { [int]($random.Next(0, 10) -eq 0) }
            })
    }
    $heat[5][2] = 9; $heat[1][23] = 6; $heat[6][4] = 4

    @{
        Tenant      = 'Contoso (made-up data)'
        Generated   = [datetime]::UtcNow.ToString('yyyy-MM-dd HH:mm', $culture) + ' UTC'
        # Stat tiles: one number each, with the last eight runs behind it.
        Kpis        = @(
            @{ Label = 'Accounts'; Value = 1284; Unit = ''; History = @(1190, 1201, 1215, 1230, 1242, 1250, 1268, 1284); Good = 'none'; Note = 'members and guests' }
            @{ Label = 'Guests'; Value = 162; Unit = ''; History = @(118, 124, 131, 139, 144, 150, 157, 162); Good = 'down'; Note = '12.6% of accounts' }
            @{ Label = 'Stale accounts'; Value = 57; Unit = ''; History = @(88, 84, 79, 71, 70, 64, 61, 57); Good = 'down'; Note = 'no sign-in for 90 days' }
            @{ Label = 'Phishing-resistant MFA'; Value = 38; Unit = '%'; History = @(19, 22, 24, 27, 30, 33, 35, 38); Good = 'up'; Note = 'of members' }
            @{ Label = 'Standing admin roles'; Value = 9; Unit = ''; History = @(15, 15, 14, 13, 12, 11, 9, 9); Good = 'down'; Note = 'of 23 admin assignments' }
        )
        # Part of a whole: the strongest method each member has registered.
        AuthMethods = @(
            @{ Name = 'Passkey (FIDO2)'; Users = 241 }
            @{ Name = 'Windows Hello'; Users = 246 }
            @{ Name = 'Authenticator app'; Users = 612 }
            @{ Name = 'SMS or voice'; Users = 120 }
            @{ Name = 'None'; Users = 65 }
        )
        # Change over time: two measures on the same scale (per cent of members).
        MfaTrend    = @{
            Weeks  = @($weeks)
            Series = @(
                @{ Name = 'Any MFA'; Values = @(81, 82, 84, 84, 86, 87, 88, 89, 90, 91, 92, 93) }
                @{ Name = 'Phishing-resistant'; Values = @(17, 19, 19, 21, 24, 26, 27, 30, 32, 34, 36, 38) }
            )
        }
        # Composition across groups: compliance by operating system.
        Devices     = @(
            @{ Os = 'Windows'; Compliant = 612; NotCompliant = 48; NotEvaluated = 21 }
            @{ Os = 'iOS'; Compliant = 301; NotCompliant = 12; NotEvaluated = 9 }
            @{ Os = 'Android'; Compliant = 188; NotCompliant = 37; NotEvaluated = 14 }
            @{ Os = 'macOS'; Compliant = 96; NotCompliant = 22; NotEvaluated = 31 }
            @{ Os = 'Linux'; Compliant = 4; NotCompliant = 3; NotEvaluated = 18 }
        )
        # A distribution: accounts by the time since their last sign-in.
        LastSignIn  = @(
            @{ Bucket = 'This week'; Accounts = 902; Stale = $false }
            @{ Bucket = '1-4 weeks'; Accounts = 214; Stale = $false }
            @{ Bucket = '1-3 months'; Accounts = 79; Stale = $false }
            @{ Bucket = '3-6 months'; Accounts = 31; Stale = $true }
            @{ Bucket = '6-12 months'; Accounts = 15; Stale = $true }
            @{ Bucket = 'Over a year'; Accounts = 7; Stale = $true }
            @{ Bucket = 'Never'; Accounts = 4; Stale = $true }
        )
        # Several measures of the same things: a score out of 100 for each area, now and three months ago.
        Maturity    = @{
            Areas  = @('Identity', 'Devices', 'Data', 'Apps', 'Monitoring', 'Collaboration')
            Series = @(
                @{ Name = 'Three months ago'; Values = @(58, 49, 41, 52, 37, 63) }
                @{ Name = 'Now'; Values = @(74, 61, 45, 66, 58, 70) }
            )
        }
        # Outliers in two dimensions: apps by permissions and users, sized by sign-ins.
        Apps        = @(
            @{ Name = 'Contoso HR portal'; Permissions = 4; Users = 1120; SignIns = 9800; HighPrivilege = $false }
            @{ Name = 'Expense tracker'; Permissions = 3; Users = 860; SignIns = 4100; HighPrivilege = $false }
            @{ Name = 'Mail archiver'; Permissions = 11; Users = 3; SignIns = 2900; HighPrivilege = $true }
            @{ Name = 'Sales dashboard'; Permissions = 6; Users = 210; SignIns = 2600; HighPrivilege = $false }
            @{ Name = 'Backup service'; Permissions = 14; Users = 2; SignIns = 7200; HighPrivilege = $true }
            @{ Name = 'Survey tool'; Permissions = 5; Users = 340; SignIns = 600; HighPrivilege = $false }
            @{ Name = 'Old sync script'; Permissions = 9; Users = 1; SignIns = 40; HighPrivilege = $true }
            @{ Name = 'Wiki'; Permissions = 2; Users = 980; SignIns = 5200; HighPrivilege = $false }
            @{ Name = 'Partner portal'; Permissions = 7; Users = 95; SignIns = 1100; HighPrivilege = $true }
        )
        AdminSignIns = @{ Days = $days; Counts = @($heat) }
        # A ranked list: the groups with the most guests.
        GuestGroups = @(
            @{ Name = 'Project Falcon'; Guests = 38; Members = 52 }
            @{ Name = 'Partner network'; Guests = 31; Members = 34 }
            @{ Name = 'Marketing agency'; Guests = 17; Members = 26 }
            @{ Name = 'Board'; Guests = 6; Members = 14 }
            @{ Name = 'All company'; Guests = 4; Members = 1122 }
        )
        Collection  = @($Collection | ForEach-Object { @{ Name = [string]$_.Name; Items = [int]$_.Items; Seconds = [math]::Round([double]$_.Seconds, 2); Status = [string]$_.Status } })
    }
}
