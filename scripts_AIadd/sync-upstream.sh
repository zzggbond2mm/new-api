#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/sync-upstream.sh
# Purpose: fetch upstream main into sync/upstream-main safely.

UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-main}"
SYNC_BRANCH="${SYNC_BRANCH:-sync/upstream-main}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: current directory is not a git repository."
  exit 1
fi

echo "==> Fetching remotes..."
git fetch --all --prune

echo "==> Ensuring sync branch exists: ${SYNC_BRANCH}"
if git show-ref --verify --quiet "refs/heads/${SYNC_BRANCH}"; then
  git checkout "${SYNC_BRANCH}"
else
  git checkout -b "${SYNC_BRANCH}"
fi

echo "==> Rebasing ${SYNC_BRANCH} onto ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"
git rebase "${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}" || {
  echo
  echo "Rebase conflict detected."
  echo "Resolve conflicts, then run: git rebase --continue"
  echo "If needed, abort with: git rebase --abort"
  exit 2
}

echo "==> Sync completed. Next steps:"
echo "1) Run tests/build on ${SYNC_BRANCH}"
echo "2) Merge into develop after validation"
