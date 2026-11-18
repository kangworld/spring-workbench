#Requires -Version 7.0
[CmdletBinding()]
param(
    [switch] $PackageOnly,
    [string] $CodexExecutable
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$marketplaceName = 'backend-guidance'
$pluginId = "backend-agent-docs@$marketplaceName"
$package = Join-Path $repoRoot 'plugins/backend-agent-docs'
$manifestPath = '.codex-plugin/plugin.json'
$local = (New-Item -ItemType Directory -Path (Join-Path $repoRoot '.local') -Force).FullName
$scratch = Join-Path $local "plugin-update-$([guid]::NewGuid())"
$candidate = Join-Path $scratch 'package'
$previous = Join-Path $scratch 'previous'
$skillPath = 'skills/spring-backend-guidance'
$references = Join-Path $candidate "$skillPath/references"
$standards = @(
    'architecture.md'
    'client-contracts.md'
    'coding-conventions.md'
    'configuration.md'
    'domain-implementation.md'
    'module-integration.md'
    'persistence.md'
    'testing.md'
)

function Get-PackageFiles([string] $Root) {
    Get-ChildItem -LiteralPath $Root -Recurse -Force -File | ForEach-Object {
        $relative = [IO.Path]::GetRelativePath($Root, $_.FullName)
        "$relative $((Get-FileHash -LiteralPath $_.FullName).Hash)"
    }
}

$lock = [IO.File]::Open((Join-Path $local 'codex-plugin-update.lock'), 'OpenOrCreate', 'Write', 'None')
try {
    $manifest = Get-Content -LiteralPath (Join-Path $package $manifestPath) -Raw | ConvertFrom-Json
    New-Item -ItemType Directory -Path (Join-Path $candidate '.codex-plugin'),
        (Join-Path $references 'docs/standards'), (Join-Path $references 'docs/templates') | Out-Null
    Copy-Item -LiteralPath (Join-Path $package $manifestPath) -Destination (Join-Path $candidate $manifestPath)
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'codex-plugin/SKILL.md') -Destination (Join-Path $candidate $skillPath)
    foreach ($standard in $standards) {
        Copy-Item -LiteralPath (Join-Path $repoRoot "docs/standards/$standard") -Destination (Join-Path $references 'docs/standards')
    }
    Copy-Item -LiteralPath (Join-Path $repoRoot 'docs/templates/schema-template.sql') -Destination (Join-Path $references 'docs/templates')

    if (Compare-Object @(Get-PackageFiles $package) @(Get-PackageFiles $candidate)) {
        $version = [version] $manifest.version
        $manifest.version = "$($version.Major).$($version.Minor).$($version.Build + 1)"
        $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $candidate $manifestPath) -Encoding utf8NoBOM
        $packagePath = (Resolve-Path -LiteralPath $package).ProviderPath
        if ($packagePath -ne $package) { throw "Unexpected package path: $packagePath" }
        Move-Item -LiteralPath $packagePath -Destination $previous
        try {
            Move-Item -LiteralPath $candidate -Destination $packagePath
        } catch {
            Move-Item -LiteralPath $previous -Destination $packagePath
            throw
        }
    }
    "Package: $pluginId $($manifest.version)"
    if ($PackageOnly) { return }

    if (-not $CodexExecutable) {
        $CodexExecutable = $env:CODEX_APP_RUNTIME_CLI_PATH
    }
    if (-not $CodexExecutable) {
        $CodexExecutable = (Get-Command codex -ErrorAction Stop).Source
    }

    function Invoke-CodexPlugin {
        $output = & $CodexExecutable plugin @args --json
        if ($LASTEXITCODE -ne 0) { throw "Codex plugin command failed: $($args -join ' ')" }
        $output | ConvertFrom-Json
    }

    Push-Location -LiteralPath $repoRoot
    try {
        $marketplace = (Invoke-CodexPlugin marketplace list).marketplaces |
            Where-Object name -eq $marketplaceName
        if ($marketplace -and $marketplace.root -ne $repoRoot) {
            $oldRoot = Join-Path $repoRoot '.local/backend-guidance-marketplace'
            if ($marketplace.root -ne $oldRoot) { throw "Marketplace name is already used at $($marketplace.root)" }
            Invoke-CodexPlugin marketplace remove $marketplaceName | Out-Null
            try {
                Invoke-CodexPlugin marketplace add $repoRoot | Out-Null
            } catch {
                Invoke-CodexPlugin marketplace add $oldRoot | Out-Null
                throw
            }
        } elseif (-not $marketplace) {
            Invoke-CodexPlugin marketplace add $repoRoot | Out-Null
        }

        $installation = Invoke-CodexPlugin add $pluginId
        $installed = (Invoke-CodexPlugin list --marketplace $marketplaceName).installed |
            Where-Object pluginId -eq $pluginId
        if ($installed.version -ne $manifest.version -or -not $installed.enabled) {
            throw "Expected an enabled installation of $pluginId $($manifest.version)"
        }
        if (Compare-Object @(Get-PackageFiles $package) @(Get-PackageFiles $installation.installedPath)) {
            throw "Installed files differ from the package: $($installation.installedPath)"
        }
        "Installed and verified: $pluginId $($installed.version)"
    } finally {
        Pop-Location
    }
} finally {
    try {
        if ((Test-Path -LiteralPath $scratch) -and (Test-Path -LiteralPath $package -PathType Container)) {
            $scratchPath = (Resolve-Path -LiteralPath $scratch).ProviderPath
            if ((Split-Path -Parent $scratchPath) -ne $local) { throw "Unexpected scratch path: $scratchPath" }
            Remove-Item -LiteralPath $scratchPath -Recurse -Force
        }
    } finally {
        $lock.Dispose()
    }
}
