function Get-DemoSampleSetting {
    <#
    .SYNOPSIS
    Returns the settings the demo sample service was connected with.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $state = Get-MtConnectionState -Service DEMO.Sample
    if ($state) { $state.Settings } else { $null }
}
