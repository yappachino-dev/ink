#!/usr/bin/env bash
# Create, validate, and squash-merge a pull request non-interactively.
# This is an opt-in owner-requested lifecycle; it is not run during normal
# implementation or verification.
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "error: GitHub CLI (gh) is required" >&2
  exit 1
fi

BASE_BRANCH=$(
  git symbolic-ref --quiet --short refs/remotes/origin/HEAD |
    sed 's@^origin/@@'
)
if [[ -z "$BASE_BRANCH" ]]; then
  echo "error: origin/HEAD is not configured; fetch the remote first" >&2
  exit 1
fi

git fetch origin "$BASE_BRANCH"
COMMIT_COUNT=$(git rev-list --count "origin/$BASE_BRANCH..HEAD")
HEAD_BRANCH=$(git branch --show-current)

if [[ "$COMMIT_COUNT" -eq 0 ]]; then
  echo "error: branch has no commits relative to origin/$BASE_BRANCH" >&2
  exit 1
fi

if [[ "$COMMIT_COUNT" -eq 1 ]]; then
  TITLE=$(git log -1 --format="%s")
  BODY=""
else
  if [[ $# -lt 1 || -z "${1:-}" ]]; then
    echo "error: multi-commit PRs require a high-level title argument" >&2
    echo "usage: $0 'chore(scope): summarize the complete change'" >&2
    exit 1
  fi
  TITLE=$1
  BODY=$(git log --reverse "origin/$BASE_BRANCH..HEAD" --format="* %s")
fi

printf 'Creating PR for %s against origin/%s (%s commit(s))...\n' \
  "$HEAD_BRANCH" "$BASE_BRANCH" "$COMMIT_COUNT"
git push --set-upstream origin HEAD
gh pr create \
  --base "$BASE_BRANCH" \
  --head "$HEAD_BRANCH" \
  --title "$TITLE" \
  --body "$BODY"

PR_NUM=$(gh pr view "$HEAD_BRANCH" --json number --jq '.number')
printf 'Waiting for CI checks on PR #%s...\n' "$PR_NUM"
gh pr checks "$PR_NUM" --watch --fail-fast

printf 'Squash-merging PR #%s...\n' "$PR_NUM"
gh pr merge "$PR_NUM" \
  --squash \
  --delete-branch \
  --subject "$TITLE (#$PR_NUM)" \
  --body "$BODY"
