#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/reset-experiment.sh [baseline]
# Optionally set BASELINE env var instead of [baseline].

# Move to repo root
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Determine baseline: arg > BASELINE env > default main HEAD
if [ "${1-}" != "" ]; then
  BL_REF="$1"
elif [ "${BASELINE-}" != "" ]; then
  BL_REF="$BASELINE"
else
  if git show-ref --verify --quiet refs/remotes/origin/main; then
    BL_REF="origin/main"
  else
    BL_REF="main"
  fi
fi

BL_COMMIT="$(git rev-parse --verify "$BL_REF^{commit}")"

# Hard reset current branch to baseline and clean untracked files
git reset --hard "$BL_COMMIT"
# Clean untracked files and directories but keep ignored files intact
git clean -fd

echo "Reset current branch to $BL_COMMIT and cleaned untracked files."
