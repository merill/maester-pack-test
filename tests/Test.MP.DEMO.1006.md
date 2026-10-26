The pack's own connector, for a made-up service. Connect it with
`Connect-Maester -Service DEMO.Sample`; without that the test is skipped. Pass
`-ServiceSetting @{ MfaRequired = $false }` to see it fail.

#### Remediation action

Connect with `MfaRequired = $true`.

<!--- Results --->
%TestResult%
