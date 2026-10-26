# Ideas for a pack's report

This guide is optional. A pack does not need a report of its own: its results already go into the Maester
report. Add one when your pack collects data that says more than pass and fail.

MP.DEMO.1008 adds **Demo pack insights** to the Maester report (under **Reports** in its left menu). It is a
gallery of ideas, with made-up data, that you can copy from.

## Show what the results cannot

The Maester report already lists every check and its result, so a report that lists them again adds nothing.
Use yours for:

| Insight | Example in the demo | Chart |
| --- | --- | --- |
| One number that matters, and its direction | Accounts, guests, stale accounts, phishing-resistant MFA, standing admin roles | Stat tile with a sparkline of the last runs |
| Part of a whole | The strongest sign-in method each member has | Doughnut (six slices or fewer) |
| Change over time | MFA over twelve weeks | Line |
| How values are spread, and what is close to a threshold | Accounts by last sign-in, stale buckets picked out | Histogram (bar) |
| Shares across groups of different sizes | Device compliance by operating system | 100% stacked bar |
| Outliers in two dimensions | Apps by permissions and users, sized by sign-ins | Bubble |
| A profile across areas | Score by area, now and three months ago | Radar |
| Patterns in time | Admin sign-ins by day and hour | Heatmap (CSS grid, no library) |
| A ranked list | Groups with the most guests | List with inline bars (CSS, no library) |
| The run itself | Time to collect each kind of data, and what failed | Horizontal bar |

Each card leads with one sentence that says what the chart shows ("57 accounts have not signed in for three
months or more"), computed from the data, and has a **Show the data** table under it for screen readers and
for anyone who wants the exact numbers.

## How the demo's report is built

| File | What it does |
| --- | --- |
| `helpers/Get-DemoInsightData.ps1` | Builds the data for the charts. A real pack computes it from what it collected. |
| `assets/insights-report.html` | The page: styles, layout and the script that draws the charts from JSON. It holds sample data, so you can open it in a browser while you design it. |
| `assets/chart.js/` | Chart.js 4.5.1 (`chart.umd.min.js`) and its MIT licence. |
| `helpers/Get-DemoReportHtml.ps1` | Puts Chart.js inline in place of the page's `<script src>`, swaps the sample data for the run's data, and returns one HTML file. |
| `tests/Test.MP.DEMO.1008.ps1` | Calls both helpers and adds the page with `Add-MtReportAttachment`. |

To change the report, edit `assets/insights-report.html` and reload it in the browser. To try it with the data
of a run, run the test and open the report from the Maester report.

## Rules for a report attachment

- **One file.** The report opens in a sandboxed frame inside the Maester report, which may be opened from a
  file with no network. Put styles, scripts, fonts and images inline; do not load anything from a CDN.
- **No markup from data.** Pass data as JSON in a `<script type="application/json">` block, escape `<`, `>` and
  `&` in it, and write text with `textContent`, never `innerHTML`. A display name from a tenant can hold
  anything.
- **Light and dark.** The frame follows the viewer's colour scheme. Define colours as CSS variables, set them
  again under `prefers-color-scheme: dark`, and read them when you draw the charts (the demo draws them again
  when the scheme changes).
- **Small enough.** Attachments are stored compressed in the report. A chart library of a few hundred KB is
  fine; tens of MB of data is not.
- **Colour with care.** Give each series a fixed colour, use green and red only when they mean good and bad,
  name every colour in a legend, and do not rely on colour alone.

## Choosing a chart library

Any library that ships as one JavaScript file works. Sizes are of the minified file, roughly.

| Library | Licence | Size | Good for |
| --- | --- | --- | --- |
| [Chart.js](https://www.chartjs.org/) (used here) | MIT | about 200 KB | The common charts (bar, line, doughnut, radar, bubble, scatter) with tooltips and legends, and little code. A good default. |
| [Apache ECharts](https://echarts.apache.org/) | Apache 2.0 | about 1 MB (smaller custom builds) | Many more kinds: heatmaps, treemaps, sunbursts, Sankey diagrams, graphs, gauges and maps. |
| [uPlot](https://github.com/leeoniya/uPlot) | MIT | about 50 KB | Fast time series with many points. Lines and bars only. |
| [Frappe Charts](https://frappe.io/charts) | MIT | under 100 KB | Simple SVG charts and a GitHub-style calendar heatmap. |
| [D3](https://d3js.org/) | ISC | about 280 KB | Anything, drawn yourself. More code for each chart. |
| [Plotly.js](https://plotly.com/javascript/) | MIT | 1 MB to 4 MB | Scientific and statistical charts, zoom and pan. Large. |
| [ApexCharts](https://apexcharts.com/) | Its own licence | about 500 KB | Polished defaults. Read its licence before you ship it in a pack. |
| No library | | 0 KB | Stat tiles, bars, progress rings, heatmap grids and sparklines in HTML, CSS or inline SVG. |

Whichever you pick, put the file and its licence in the pack (as `assets/chart.js/` does) rather than
fetching it when the test runs, so the pack works offline and its content checks see exactly what it ships.
