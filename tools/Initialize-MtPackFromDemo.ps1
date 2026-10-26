function Initialize-MtPackFromDemo {
    <#
    .SYNOPSIS
    Turns a copy of the Maester demo pack into a pack of your own: its ID, code, names, links and a new GUID.

    .DESCRIPTION
    Run it once, in your copy (made with GitHub's "Use this template" button or a clone), before you change
    anything else:

        . ./tools/Initialize-MtPackFromDemo.ps1
        Initialize-MtPackFromDemo -Id contoso.google-workspace -Code CNT -Name 'Contoso Google Workspace checks'

    It sets the manifest's Id, Publisher, Name, Guid (a new one), Version (0.1.0), Code, Homepage, Support and
    SecurityContact; renames the tests from MP.DEMO.<n> to MP.<Code>.<n>, the suite and the DEMO.Sample service
    to your code, and the functions from Verb-Demo... to Verb-<Code>...; and points the links at your
    repository.

    Every .ps1 file of a pack may hold only functions, and only the folders the manifest names are loaded, so
    this file is a function in a folder the pack never loads. Delete the folder once you have run it.

    .PARAMETER Id
    Your pack's ID, '<publisher>.<name>' in lower case. The publisher is the GitHub user or organisation that
    owns the repository.

    .PARAMETER Code
    Your pack's code, which starts every test ID: CNT gives MP.CNT.1001. Two to ten letters or digits, starting
    with a letter, and up to three parts separated by dots.

    .PARAMETER Name
    Your pack's display name.

    .PARAMETER Repository
    Your repository's name on GitHub. By default the name of the pack's folder.

    .EXAMPLE
    Initialize-MtPackFromDemo -Id contoso.google-workspace -Code CNT -Name 'Contoso Google Workspace checks'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-z0-9]([a-z0-9-]{0,38}[a-z0-9])?\.[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$')]
        [string] $Id,

        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z][A-Za-z0-9]{1,9}(\.[A-Za-z][A-Za-z0-9]{1,9}){0,2}$')]
        [string] $Code,

        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter()]
        [string] $Repository
    )

    $root = Split-Path -Path $PSScriptRoot -Parent
    if (-not $Repository) { $Repository = Split-Path -Path $root -Leaf }
    $Code = $Code.ToUpperInvariant()
    $publisher = $Id.Split('.')[0]
    # Function names take the code without its dots: CNT.GWS gives Get-CntGws<Name>.
    $prefix = ($Code.Split('.') | ForEach-Object { $_.Substring(0, 1) + $_.Substring(1).ToLowerInvariant() }) -join ''
    $envCode = $Code.Replace('.', '_')
    $repositoryUrl = "https://github.com/$publisher/$Repository"

    $manifestPath = Join-Path $root 'maester-pack.json'
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -AsHashtable
    if ($manifest.Id -ne 'maester365.demo') { throw "This copy has already been set up as $($manifest.Id)." }

    # The text files of the pack: the demo's code, service, functions and links become yours.
    $files = Get-ChildItem -LiteralPath $root -Recurse -File -Include '*.ps1', '*.md', '*.json', '*.yml' |
        Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' -and $_.FullName -ne $PSCommandPath }
    foreach ($file in $files) {
        $text = Get-Content -LiteralPath $file.FullName -Raw
        $new = $text -creplace '\bMP\.DEMO\.', "MP.$Code." -creplace '\bDEMO\.', "$Code." -creplace 'MAESTER_DEMO_', "MAESTER_$($envCode)_" `
            -creplace '-Pack DEMO\b', "-Pack $Code" -creplace '\b([A-Z][a-z]+)-Demo(?=[A-Z])', "`$1-$prefix" `
            -creplace 'maester365/maester-pack-demo', "$publisher/$Repository"
        if ($new -cne $text -and $PSCmdlet.ShouldProcess($file.FullName, 'Rename the demo pack')) {
            # Keep the byte order mark: PSScriptAnalyzer wants one in a .ps1 file with non-ASCII characters.
            $bom = ([System.IO.File]::ReadAllBytes($file.FullName)[0..2] -join ',') -eq '239,187,191'
            [System.IO.File]::WriteAllText($file.FullName, $new, [System.Text.UTF8Encoding]::new($bom))
        }
    }
    foreach ($file in Get-ChildItem -LiteralPath (Join-Path $root 'tests') -File -Filter 'Test.MP.DEMO.*') {
        $target = $file.Name -creplace '^Test\.MP\.DEMO\.', "Test.MP.$Code."
        if ($PSCmdlet.ShouldProcess($file.FullName, "Rename to $target")) { Rename-Item -LiteralPath $file.FullName -NewName $target }
    }
    foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File -Filter '*-Demo*.ps1' | Where-Object { $_.FullName -ne $PSCommandPath }) {
        $target = $file.Name -creplace '-Demo', "-$prefix"
        if ($PSCmdlet.ShouldProcess($file.FullName, "Rename to $target")) { Rename-Item -LiteralPath $file.FullName -NewName $target }
    }

    # The manifest, read again now that its code and service names are replaced.
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -AsHashtable
    $manifest.Id = $Id
    $manifest.Guid = [guid]::NewGuid().ToString()
    $manifest.Name = $Name
    $manifest.Description = "Checks for $Name."
    $manifest.Version = '0.1.0'
    $manifest.Publisher = $publisher
    $manifest.Code = $Code
    $manifest.Homepage = $repositoryUrl
    $manifest.Support = "$repositoryUrl/issues"
    $manifest.SecurityContact = "$repositoryUrl/security/advisories/new"
    $manifest.Categories = @()
    $ordered = [ordered]@{}
    foreach ($key in '$schema', 'Id', 'Guid', 'Name', 'Description', 'Version', 'Publisher', 'License', 'Homepage', 'Support',
        'SecurityContact', 'RequiresMaester', 'Code', 'Suites', 'Helpers', 'Connectors', 'Uses', 'Categories', 'Banner') {
        if ($manifest.Contains($key)) { $ordered[$key] = $manifest[$key] }
    }
    foreach ($key in $manifest.Keys) { if (-not $ordered.Contains($key)) { $ordered[$key] = $manifest[$key] } }
    if ($PSCmdlet.ShouldProcess($manifestPath, "Set the pack to $Id")) {
        Set-Content -LiteralPath $manifestPath -Value ($ordered | ConvertTo-Json -Depth 10) -Encoding utf8NoBOM
    }

    $suitePath = Join-Path $root 'tests' -AdditionalChildPath 'suite.json'
    $suite = Get-Content -LiteralPath $suitePath -Raw | ConvertFrom-Json -AsHashtable
    $suite.Name = $Name
    if ($PSCmdlet.ShouldProcess($suitePath, 'Name the suite')) { Set-Content -LiteralPath $suitePath -Value ($suite | ConvertTo-Json -Depth 5) -Encoding utf8NoBOM }

    Write-Information "Your pack is now $Id, with tests MP.$Code.<n>. Next: replace the made-up tests and README.md, replace assets/banner.png, run Test-MtPack . and Invoke-MtTest -Path ., and delete the tools folder." -InformationAction Continue
}
