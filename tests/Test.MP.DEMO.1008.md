A demo long-running test, showing what a pack that runs a tool for a long time should do.

- **Live progress.** While it runs, the console shows its log in a box with a header: the three stages, a bar
  of the items done, the items running and finished with their times, and an error. While its checks run, the
  dashboard's Results panel and result blocks count the checks' results, and the checks' areas are listed
  where the products usually are.
- **Its own report.** It adds an HTML report to the Maester report: open **Demo pack insights** under
  **Reports** in the left menu. Rather than list the checks again, it shows what pass and fail cannot:
  stat tiles with a trend, a doughnut, a line, a histogram, stacked bars, a bubble chart, a radar, a heatmap
  and a ranked list, each with a note on when to use it. The data is made up. A report is optional: a pack does
  not have to include one.

It runs with `Invoke-Maester -Pack DEMO`, or with `-IncludeLongRunning`. Set its `ItemMilliseconds` parameter
in `maester-config.json` to make it quicker or slower.

<!--- Results --->
%TestResult%
