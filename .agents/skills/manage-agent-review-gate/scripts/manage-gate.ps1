[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)]
	[ValidateSet("install", "status", "update", "uninstall")]
	[string]$Action,

	[Parameter(Mandatory = $true)]
	[string]$Repository,

	[switch]$Force
)

$ErrorActionPreference = "Stop"
$managedMarker = "managed-by: agent-instruction-gate"
$skillRoot = Split-Path -Parent $PSScriptRoot
$assetDir = Join-Path $skillRoot "assets\hook"
$sourceManifestPath = Join-Path $assetDir "manifest.json"

function Get-FileHashValue {
	param([Parameter(Mandatory = $true)][string]$Path)
	return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-ManagedPaths {
	param(
		[Parameter(Mandatory = $true)][string]$HooksPath,
		[Parameter(Mandatory = $true)]$Manifest
	)

	$gateDir = Join-Path $HooksPath "agent-instruction-gate"
	$result = [ordered]@{}
	foreach ($file in $Manifest.files) {
		$result[$file] = if ($file -eq "pre-commit") {
			Join-Path $HooksPath $file
		} else {
			Join-Path $gateDir $file
		}
	}
	return $result
}

function Get-SourcePath {
	param([Parameter(Mandatory = $true)][string]$Name)
	return Join-Path $assetDir $Name
}

function Read-InstalledManifest {
	param([Parameter(Mandatory = $true)][string]$GateDir)
	$path = Join-Path $GateDir "install-manifest.json"
	if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
		return $null
	}
	return Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
}

function Test-ManagedHook {
	param([Parameter(Mandatory = $true)][string]$Path)
	if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
		return $false
	}
	return (Get-Content -Raw -LiteralPath $Path).Contains($managedMarker)
}

function Get-LocalChanges {
	param(
		[Parameter(Mandatory = $true)]$InstalledManifest,
		[Parameter(Mandatory = $true)]$ManagedPaths
	)

	$changes = @()
	foreach ($property in $InstalledManifest.hashes.PSObject.Properties) {
		$name = $property.Name
		$path = $ManagedPaths[$name]
		if (-not $path -or -not (Test-Path -LiteralPath $path -PathType Leaf)) {
			$changes += "$name (missing)"
			continue
		}
		if ((Get-FileHashValue -Path $path) -ne [string]$property.Value) {
			$changes += "$name (modified)"
		}
	}
	return $changes
}

function Write-InstalledManifest {
	param(
		[Parameter(Mandatory = $true)][string]$GateDir,
		[Parameter(Mandatory = $true)]$SourceManifest,
		[Parameter(Mandatory = $true)]$ManagedPaths
	)

	$hashes = [ordered]@{}
	foreach ($name in $SourceManifest.files) {
		$hashes[$name] = Get-FileHashValue -Path $ManagedPaths[$name]
	}

	$installedManifest = [ordered]@{
		name = $SourceManifest.name
		version = $SourceManifest.version
		installedAt = [DateTimeOffset]::Now.ToString("o")
		hashes = $hashes
	}
	$installedManifest |
		ConvertTo-Json -Depth 5 |
		Set-Content -LiteralPath (Join-Path $GateDir "install-manifest.json") -Encoding UTF8
}

function Copy-ManagedFiles {
	param(
		[Parameter(Mandatory = $true)]$SourceManifest,
		[Parameter(Mandatory = $true)]$ManagedPaths
	)

	foreach ($name in $SourceManifest.files) {
		Copy-Item -LiteralPath (Get-SourcePath -Name $name) -Destination $ManagedPaths[$name] -Force
	}

	if ($env:OS -ne "Windows_NT") {
		& chmod +x $ManagedPaths["pre-commit"] $ManagedPaths["gate.sh"]
		if ($LASTEXITCODE -ne 0) {
			throw "Failed to set executable permissions on hook scripts."
		}
	}
}

if (-not (Test-Path -LiteralPath $sourceManifestPath -PathType Leaf)) {
	throw "Skill manifest not found: $sourceManifestPath"
}

$sourceManifest = Get-Content -Raw -LiteralPath $sourceManifestPath | ConvertFrom-Json
foreach ($name in $sourceManifest.files) {
	$sourcePath = Get-SourcePath -Name $name
	if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
		throw "Skill asset not found: $sourcePath"
	}
}

$repositoryPath = [System.IO.Path]::GetFullPath($Repository)
if (-not (Test-Path -LiteralPath $repositoryPath -PathType Container)) {
	throw "Repository directory not found: $repositoryPath"
}

& git -C $repositoryPath rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
	throw "Not a Git working tree: $repositoryPath"
}

$hooksResult = & git -C $repositoryPath rev-parse --git-path hooks
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($hooksResult)) {
	throw "Failed to resolve the active Git hooks path."
}

$hooksPath = if ([System.IO.Path]::IsPathRooted($hooksResult.Trim())) {
	[System.IO.Path]::GetFullPath($hooksResult.Trim())
} else {
	[System.IO.Path]::GetFullPath((Join-Path $repositoryPath $hooksResult.Trim()))
}

$gateDir = [System.IO.Path]::GetFullPath((Join-Path $hooksPath "agent-instruction-gate"))
if (-not $gateDir.StartsWith($hooksPath + [System.IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
	throw "Unsafe gate directory: $gateDir"
}

$managedPaths = Get-ManagedPaths -HooksPath $hooksPath -Manifest $sourceManifest
$preCommitPath = $managedPaths["pre-commit"]
$originalHookPath = Join-Path $hooksPath "pre-commit.agent-instruction-gate.original"
$installedManifest = Read-InstalledManifest -GateDir $gateDir

switch ($Action) {
	"install" {
		if (-not (Get-Command codex.cmd -ErrorAction SilentlyContinue) -and
			-not (Get-Command codex -ErrorAction SilentlyContinue)) {
			throw "Codex CLI was not found. Install and authenticate Codex CLI before installing the gate."
		}
		if (Test-ManagedHook -Path $preCommitPath) {
			throw "The review gate is already installed. Use status or update."
		}
		if (Test-Path -LiteralPath $originalHookPath) {
			throw "Reserved backup hook already exists: $originalHookPath"
		}

		New-Item -ItemType Directory -Path $hooksPath -Force | Out-Null
		New-Item -ItemType Directory -Path $gateDir -Force | Out-Null

		$originalMoved = $false
		try {
			if (Test-Path -LiteralPath $preCommitPath -PathType Leaf) {
				Move-Item -LiteralPath $preCommitPath -Destination $originalHookPath
				$originalMoved = $true
			}
			Copy-ManagedFiles -SourceManifest $sourceManifest -ManagedPaths $managedPaths
			Write-InstalledManifest -GateDir $gateDir -SourceManifest $sourceManifest -ManagedPaths $managedPaths
		} catch {
			if (Test-Path -LiteralPath $preCommitPath) {
				Remove-Item -LiteralPath $preCommitPath -Force
			}
			if ($originalMoved -and (Test-Path -LiteralPath $originalHookPath)) {
				Move-Item -LiteralPath $originalHookPath -Destination $preCommitPath
			}
			if (Test-Path -LiteralPath $gateDir -PathType Container) {
				Remove-Item -LiteralPath $gateDir -Recurse -Force
			}
			throw
		}

		Write-Host "INSTALLED: agent review gate $($sourceManifest.version)"
		Write-Host "Repository: $repositoryPath"
		Write-Host "Hooks: $hooksPath"
	}

	"status" {
		if (-not (Test-ManagedHook -Path $preCommitPath) -or -not $installedManifest) {
			Write-Host "NOT_INSTALLED: $repositoryPath"
			exit 2
		}

		$localChanges = @(Get-LocalChanges -InstalledManifest $installedManifest -ManagedPaths $managedPaths)
		$versionState = if ($installedManifest.version -eq $sourceManifest.version) { "CURRENT" } else { "UPDATE_AVAILABLE" }
		$fileState = if ($localChanges.Count -eq 0) { "CLEAN" } else { "MODIFIED" }

		Write-Host "INSTALLED: $($installedManifest.version)"
		Write-Host "Template: $($sourceManifest.version)"
		Write-Host "Version status: $versionState"
		Write-Host "File status: $fileState"
		Write-Host "Hooks: $hooksPath"
		foreach ($change in $localChanges) {
			Write-Host " - $change"
		}

		if ($localChanges.Count -gt 0) { exit 4 }
		if ($versionState -eq "UPDATE_AVAILABLE") { exit 3 }
	}

	"update" {
		if (-not (Test-ManagedHook -Path $preCommitPath) -or -not $installedManifest) {
			throw "The review gate is not installed."
		}

		$localChanges = @(Get-LocalChanges -InstalledManifest $installedManifest -ManagedPaths $managedPaths)
		if ($localChanges.Count -gt 0 -and -not $Force) {
			throw "Managed files were modified after installation: $($localChanges -join ', '). Re-run with -Force only when overwriting them is intended."
		}

		Copy-ManagedFiles -SourceManifest $sourceManifest -ManagedPaths $managedPaths
		Write-InstalledManifest -GateDir $gateDir -SourceManifest $sourceManifest -ManagedPaths $managedPaths
		Write-Host "UPDATED: agent review gate $($sourceManifest.version)"
		Write-Host "Repository: $repositoryPath"
	}

	"uninstall" {
		if (-not (Test-ManagedHook -Path $preCommitPath) -or -not $installedManifest) {
			throw "The review gate is not installed or is not managed by this skill."
		}

		$localChanges = @(Get-LocalChanges -InstalledManifest $installedManifest -ManagedPaths $managedPaths)
		if ($localChanges.Count -gt 0 -and -not $Force) {
			throw "Managed files were modified after installation: $($localChanges -join ', '). Re-run with -Force only when removing them is intended."
		}

		Remove-Item -LiteralPath $preCommitPath -Force
		if (Test-Path -LiteralPath $originalHookPath -PathType Leaf) {
			Move-Item -LiteralPath $originalHookPath -Destination $preCommitPath
		}
		if (Test-Path -LiteralPath $gateDir -PathType Container) {
			Remove-Item -LiteralPath $gateDir -Recurse -Force
		}

		Write-Host "UNINSTALLED: agent review gate"
		Write-Host "Repository: $repositoryPath"
	}
}
