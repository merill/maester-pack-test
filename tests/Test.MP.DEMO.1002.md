Every app should score at least the minimum. The minimum is a test parameter, so each tenant can set its own
in `maester-config.json`:

```json
{
  "TestSettings": [
    { "Id": "MP.DEMO.1002", "Parameters": { "MinimumScore": 70 } }
  ]
}
```

With the default of 80 the test fails; with 70 it passes.

#### Remediation action

Raise the score of each app listed below, or lower `MinimumScore` if your organisation accepts it.

<!--- Results --->
%TestResult%
