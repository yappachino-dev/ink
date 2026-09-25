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
TITLE=""
PR_BODY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pr-body)
      if [[ $# -lt 2 ]]; then
        echo "error: --pr-body requires text" >&2
        exit 1
      fi
      PR_BODY=$2
      shift 2
      ;;
    --help|-h)
      echo "usage: $0 [--pr-body 'short optional context'] ['high-level title']"
      exit 0
      ;;
    --*)
      echo "error: unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -n "$TITLE" ]]; then
        echo "error: provide only one high-level title" >&2
        exit 1
      fi
      TITLE=$1
      shift
      ;;
  esac
done

if [[ "$COMMIT_COUNT" -eq 0 ]]; then
  echo "error: branch has no commits relative to origin/$BASE_BRANCH" >&2
  exit 1
fi

if [[ "$COMMIT_COUNT" -eq 1 ]]; then
  TITLE=$(git log -1 --format="%s")
else
  if [[ -z "$TITLE" ]]; then
    echo "error: multi-commit PRs require a high-level title argument" >&2
    echo "usage: $0 'chore(scope): summarize the complete change'" >&2
    exit 1
  fi
fi

# The PR description is optional. Only multi-commit squash merges get a
# chronological list of commit titles in the merge commit body.
if [[ "$COMMIT_COUNT" -gt 1 ]]; then
  MERGE_BODY=$(git log --reverse "origin/$BASE_BRANCH..HEAD" --format="* %s")
else
  MERGE_BODY=""
fi

printf 'Creating PR for %s against origin/%s (%s commit(s))...\n' \
  "$HEAD_BRANCH" "$BASE_BRANCH" "$COMMIT_COUNT"
git push --set-upstream origin HEAD
gh pr create \
  --base "$BASE_BRANCH" \
  --head "$HEAD_BRANCH" \
  --title "$TITLE" \
  --body "$PR_BODY"

PR_NUM=$(gh pr view "$HEAD_BRANCH" --json number --jq '.number')
printf 'Waiting for CI checks on PR #%s...\n' "$PR_NUM"
gh pr checks "$PR_NUM" --watch --fail-fast

printf 'Squash-merging PR #%s...\n' "$PR_NUM"
gh pr merge "$PR_NUM" \
  --squash \
  --delete-branch \
  --subject "$TITLE (#$PR_NUM)" \
  --body "$MERGE_BODY"
