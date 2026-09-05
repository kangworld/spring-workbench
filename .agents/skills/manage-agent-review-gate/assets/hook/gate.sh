#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
review_schema="${INSTRUCTION_REVIEW_SCHEMA:-$script_dir/review-schema.json}"
review_prompt_file="$script_dir/review-prompt.md"
codex_bin="${CODEX_BIN:-}"

if ! git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
	echo "BLOCK: not inside a Git repository."
	exit 1
fi

cd "$git_root"

if git diff --cached --quiet --exit-code; then
	exit 0
fi

if [ -z "$codex_bin" ]; then
	if command -v codex.cmd >/dev/null 2>&1; then
		codex_bin="codex.cmd"
	elif [ -n "${APPDATA:-}" ] && command -v cygpath >/dev/null 2>&1; then
		appdata_dir="$(cygpath -u "$APPDATA")"
		if [ -f "$appdata_dir/npm/codex.cmd" ]; then
			codex_bin="$appdata_dir/npm/codex.cmd"
		else
			codex_bin="codex"
		fi
	else
		codex_bin="codex"
	fi
fi

if [[ "$codex_bin" == */* ]]; then
	codex_available=false
	[ -f "$codex_bin" ] && codex_available=true
else
	codex_available=false
	command -v "$codex_bin" >/dev/null 2>&1 && codex_available=true
fi

if [ "$codex_available" != true ]; then
	echo "BLOCK: Codex CLI was not found: $codex_bin"
	echo "Install and authenticate Codex CLI, or set CODEX_BIN."
	exit 1
fi

if [ ! -f "$review_schema" ]; then
	echo "BLOCK: review schema was not found: $review_schema"
	exit 1
fi

if [ ! -f "$review_prompt_file" ]; then
	echo "BLOCK: review prompt was not found: $review_prompt_file"
	exit 1
fi

git_dir="$(git rev-parse --git-dir)"
case "$git_dir" in
	/*) ;;
	*) git_dir="$git_root/$git_dir" ;;
esac

result_file="$(mktemp "$git_dir/agent-instruction-review.XXXXXX")"
trap 'rm -f "$result_file"' EXIT
review_prompt="$(cat "$review_prompt_file")"

echo "Running Codex pre-commit instruction review..."

if ! "$codex_bin" exec \
	--ephemeral \
	--sandbox read-only \
	--color never \
	--output-schema "$review_schema" \
	--output-last-message "$result_file" \
	"$review_prompt"; then
	echo
	echo "BLOCK: Codex CLI review failed."
	echo "Check CLI installation, authentication, network access, and configuration."
	exit 1
fi

if [ ! -s "$result_file" ]; then
	echo "BLOCK: Codex CLI returned no review result."
	exit 1
fi

echo
cat "$result_file"
echo

if grep -Eq '"verdict"[[:space:]]*:[[:space:]]*"PASS"' "$result_file"; then
	echo "PASS: staged changes comply with the applicable instructions."
	exit 0
fi

echo "BLOCK: staged changes do not satisfy the applicable instructions."
echo "Fix the reported violations, stage the changes, and commit again."
exit 1
