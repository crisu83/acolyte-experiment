#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPTS_JSON="$ROOT_DIR/evidence/prompts.json"
VERIFY_LEDGER="$ROOT_DIR/evidence/verify.md"
RUN_LEDGER="$ROOT_DIR/evidence/runs.md"

# Usage: scripts/run-experiment.sh <run-id> [baseline] [model]
# Optionally set BASELINE env var instead of [baseline].

if ! command -v acolyte >/dev/null 2>&1; then
  echo "acolyte CLI is not available in PATH."
  echo "Link or install it first, then rerun."
  exit 1
fi

if ! command -v bun >/dev/null 2>&1; then
  echo "bun is required to read evidence/prompts.json."
  exit 1
fi

if [ ! -f "$PROMPTS_JSON" ]; then
  echo "Missing prompt source: $PROMPTS_JSON"
  exit 1
fi

if [ "$#" -lt 1 ]; then
  echo "Usage: scripts/run-experiment.sh <run-id> [baseline] [model]" >&2
  echo "Optionally set BASELINE env var instead of [baseline]." >&2
  exit 1
fi

RUN_ID="$1"
BRANCH="run/$RUN_ID"

# Resolve baseline ref: arg > BASELINE env > default main HEAD
if [ "${2-}" != "" ]; then
  BL_REF="$2"
elif [ "${BASELINE-}" != "" ]; then
  BL_REF="$BASELINE"
else
  if git show-ref --verify --quiet refs/remotes/origin/main; then
    BL_REF="origin/main"
  else
    BL_REF="main"
  fi
fi

# Resolve to commit hash for logging/branch creation
BL_COMMIT="$(git rev-parse --verify "$BL_REF^{commit}")"

# Resolve model: arg > configured model
if [ "${3-}" != "" ]; then
  MODEL="$3"
else
  MODEL="$(acolyte config list 2>/dev/null | awk -F: '/^model:[[:space:]]*/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2; exit}')"
fi

if [ -z "$MODEL" ]; then
  echo "Error: model is not set. Run 'acolyte config set model <model>' or pass [model]." >&2
  exit 1
fi

if [ "${3-}" != "" ]; then
  acolyte config set model "$MODEL" >/dev/null
fi

# Ensure clean working tree (no unstaged, staged, or untracked changes)
if [ -n "$(git status --porcelain)" ]; then
  echo "Error: working tree is not clean; commit or stash changes before running an experiment." >&2
  exit 1
fi

SLICE_LINES="$(bun -e '
  const fs = require("node:fs");
  const path = process.argv[1];
  const raw = fs.readFileSync(path, "utf8");
  const data = JSON.parse(raw);
  if (!Array.isArray(data.slices) || data.slices.length === 0) {
    console.error("prompts.json must contain a non-empty slices array");
    process.exit(1);
  }
  for (const slice of data.slices) {
    if (typeof slice.id !== "string" || !slice.id.trim()) {
      console.error("each slice requires a non-empty id");
      process.exit(1);
    }
    if (typeof slice.prompt !== "string" || !slice.prompt.trim()) {
      console.error(`slice ${slice.id} requires a non-empty prompt`);
      process.exit(1);
    }
    process.stdout.write(`${slice.id}\t${slice.prompt}\n`);
  }
' "$PROMPTS_JSON")"

cd "$ROOT_DIR"

# Create or switch run branch
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git checkout "$BRANCH"
else
  git checkout -b "$BRANCH" "$BL_COMMIT"
fi

# Log run metadata
TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
ACOLYTE_VERSION="$(acolyte --version 2>/dev/null || true)"
if [ -z "$ACOLYTE_VERSION" ]; then
  ACOLYTE_VERSION="unknown"
fi
mkdir -p "$(dirname "$RUN_LEDGER")"
RUN_LEDGER_LINE="$TS | $RUN_ID | $BRANCH | $BL_COMMIT | $MODEL | $ACOLYTE_VERSION"
echo "Run started: id=$RUN_ID branch=$BRANCH baseline=$BL_COMMIT model=$MODEL acolyte=$ACOLYTE_VERSION at $TS"
echo "Run ledger entry will be appended after run completion."

while IFS=$'\t' read -r slice_id prompt; do
  [ -n "${slice_id}" ] || continue
  started_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  pre_commit="$(git rev-parse HEAD)"
  echo "==> Running ${slice_id}"
  if ! acolyte run --workspace "$ROOT_DIR" "$prompt"; then
    echo "$RUN_LEDGER_LINE" >> "$RUN_LEDGER"
    echo "Slice ${slice_id} failed: acolyte run returned non-zero status." >&2
    exit 1
  fi
  post_commit="$(git rev-parse HEAD)"
  if [ "$post_commit" = "$pre_commit" ]; then
    echo "$RUN_LEDGER_LINE" >> "$RUN_LEDGER"
    echo "Slice ${slice_id} failed: no new commit was created." >&2
    exit 1
  fi
  commit_hash="$(git rev-parse --short "$post_commit")"
  {
    echo
    echo '```text'
    echo "date: ${started_at}"
    echo "slice: ${slice_id}"
    echo "command: acolyte run --workspace ${ROOT_DIR} \"<slice-prompt>\""
    echo "result: pass"
    echo "commit: ${commit_hash}"
    echo '```'
  } >> "$VERIFY_LEDGER"
  echo "==> Completed ${slice_id}"
  echo
done <<EOF
$SLICE_LINES
EOF

echo "$RUN_LEDGER_LINE" >> "$RUN_LEDGER"
