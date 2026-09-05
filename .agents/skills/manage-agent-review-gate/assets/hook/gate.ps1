$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$reviewSchema = if ($env:INSTRUCTION_REVIEW_SCHEMA) {
	$env:INSTRUCTION_REVIEW_SCHEMA
} else {
	Join-Path $scriptDir "review-schema.json"
}
$reviewPromptFile = Join-Path $scriptDir "review-prompt.md"

$gitRoot = (& git rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($gitRoot)) {
	Write-Error "BLOCK: not inside a Git repository."
	exit 1
}

Set-Location $gitRoot

& git diff --cached --quiet --exit-code
if ($LASTEXITCODE -eq 0) {
	exit 0
}

$codexCommand = if ($env:CODEX_BIN) {
	Get-Command $env:CODEX_BIN -ErrorAction SilentlyContinue
} else {
	Get-Command codex.cmd -ErrorAction SilentlyContinue
}

if (-not $codexCommand) {
	$codexCommand = Get-Command codex -ErrorAction SilentlyContinue
}

if (-not $codexCommand) {
	Write-Error "BLOCK: Codex CLI was not found. Install and authenticate Codex CLI, or set CODEX_BIN."
	exit 1
}

if (-not (Test-Path -LiteralPath $reviewSchema -PathType Leaf)) {
	Write-Error "BLOCK: review schema was not found: $reviewSchema"
	exit 1
}

if (-not (Test-Path -LiteralPath $reviewPromptFile -PathType Leaf)) {
	Write-Error "BLOCK: review prompt was not found: $reviewPromptFile"
	exit 1
}

$gitDir = (& git rev-parse --absolute-git-dir)
if ($LASTEXITCODE -ne 0) {
	Write-Error "BLOCK: failed to resolve the Git directory."
	exit 1
}

$resultFile = Join-Path $gitDir ("agent-instruction-review-{0}.json" -f [guid]::NewGuid())
$reviewPrompt = Get-Content -Raw -LiteralPath $reviewPromptFile

try {
	Write-Host "Running Codex pre-commit instruction review..."

	& $codexCommand.Source exec `
		--ephemeral `
		--sandbox read-only `
		--color never `
		--output-schema $reviewSchema `
		--output-last-message $resultFile `
		$reviewPrompt

	if ($LASTEXITCODE -ne 0) {
		Write-Error "BLOCK: Codex CLI review failed. Check CLI installation, authentication, network access, and configuration."
		exit 1
	}

	if (-not (Test-Path -LiteralPath $resultFile -PathType Leaf)) {
		Write-Error "BLOCK: Codex CLI returned no review result."
		exit 1
	}

	$resultText = Get-Content -Raw -LiteralPath $resultFile
	Write-Host ""
	Write-Host $resultText
	Write-Host ""

	try {
		$result = $resultText | ConvertFrom-Json
	} catch {
		Write-Error "BLOCK: Codex CLI returned an invalid JSON review result."
		exit 1
	}

	if ($result.verdict -eq "PASS") {
		Write-Host "PASS: staged changes comply with the applicable instructions."
		exit 0
	}

	Write-Error "BLOCK: staged changes do not satisfy the applicable instructions. Fix the reported violations, stage the changes, and commit again."
	exit 1
} finally {
	if (Test-Path -LiteralPath $resultFile) {
		Remove-Item -LiteralPath $resultFile -Force
	}
}
