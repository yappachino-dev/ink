#!/usr/bin/env bash
# Create, validate, and squash-merge a pull request non-interactively.
# This is an opt-in owner-requested lifecycle; it is not run during normal
# implementation or verification.
set -euo pipefail

wait_for_ci_checks() {
  local pr_num=$1
  local output

  # GitHub can accept the PR before the workflow run is registered. Retry that
  # narrow startup state instead of treating it as a failed CI check.
  for _ in {1..60}; do
    if output=$(gh pr checks "$pr_num" --repo "$REPO" 2>&1); then
      printf '%s\n' "$output"
    elif [[ "$output" == *"no checks reported"* ]]; then
      sleep 2
      continue
    else
      printf '%s\n' "$output"
    fi

    gh pr checks "$pr_num" --repo "$REPO" --watch --fail-fast
    return
  done

  echo "error: timed out waiting for CI checks on PR #$pr_num" >&2
  return 1
}

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

# Every gh call is pinned to origin. Without it gh picks the base repository,
# which prefers an `upstream` remote over origin, so a fork setup would read
# and edit pull requests in the wrong repository. Note --repo takes
# OWNER/REPO, not a remote name.
REPO=$(
  git remote get-url origin |
    sed -E 's#^(git@|ssh://git@)github\.com[:/]#github.com/#; s#^https?://github\.com/#github.com/#; s#\.git$##'
)
if [[ -z "$REPO" || "$REPO" == origin* ]]; then
  echo "error: could not derive a GitHub repo from the origin remote" >&2
  exit 1
fi

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

if [[ -z "$HEAD_BRANCH" ]]; then
  echo "error: HEAD is detached; check out a feature branch first" >&2
  exit 1
fi

# Refuse to run on the base branch. The push below is
# `git push --set-upstream origin HEAD`, which writes to a remote branch of the
# same name - so on the base branch it publishes straight to main, and only
# `gh pr create` notices afterwards, once the commit is already up. Undoing that
# needs a force-push to main, which rewrites published history.
#
# This matters more than it looks: the repository has no branch protection to
# fall back on. The protection API returns 403 on the current plan, so nothing
# on the remote refuses a direct push to main. This check is the only thing
# between a local commit and an unreviewed merge, so it runs before the push.
if [[ "$HEAD_BRANCH" == "$BASE_BRANCH" ]]; then
  echo "error: refusing to ship from the base branch ($BASE_BRANCH)." >&2
  echo "       this would push directly to origin/$BASE_BRANCH and bypass the PR." >&2
  echo "       move the commit to a feature branch first:" >&2
  echo "         git switch -c fix/short-description" >&2
  exit 1
fi

if [[ "$COMMIT_COUNT" -eq 0 ]]; then
  echo "error: branch has no commits relative to origin/$BASE_BRANCH" >&2
  exit 1
fi

# Checked here rather than after the merge: uncommitted work must not survive a
# ship, and the post-merge step moves the working tree onto the base branch.
if [[ -n "$(git status --porcelain)" ]]; then
  echo "error: working tree is dirty; commit or stash before shipping" >&2
  git status --short >&2
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

printf 'Pushing %s to origin/%s (%s commit(s))...\n' \
  "$HEAD_BRANCH" "$BASE_BRANCH" "$COMMIT_COUNT"
git push --set-upstream origin HEAD

# A retry after a CI failure reuses the open PR instead of failing on
# "a pull request ... already exists", which would strand the push.
# Only an open PR counts: gh also resolves a branch's merged PR, and editing
# one would send the merge step at a PR that is already closed.
PR_NUM=$(
  gh pr view "$HEAD_BRANCH" --repo "$REPO" --json number,state --jq \
    'select(.state == "OPEN") | .number' 2>/dev/null || true
)
if [[ -n "$PR_NUM" ]]; then
  printf 'Updating existing PR #%s...\n' "$PR_NUM"
  gh pr edit "$PR_NUM" --repo "$REPO" --title "$TITLE" --body "$PR_BODY"
else
  # A branch carries one PR at a time, so a previous one that was closed
  # unmerged blocks gh pr create. Say so instead of surfacing a bare GraphQL
  # error. A MERGED previous PR does not block, so it is not caught here.
  PREVIOUS=$(gh pr view "$HEAD_BRANCH" --repo "$REPO" --json number,state \
    --jq 'select(.state == "CLOSED") | .number' 2>/dev/null || true)
  if [[ -n "$PREVIOUS" ]]; then
    printf 'PR #%s on %s was closed without merging and blocks a new one.\n' \
      "$PREVIOUS" "$HEAD_BRANCH" >&2
    printf '  gh pr reopen %s --repo %s\n' "$PREVIOUS" "$REPO" >&2
    exit 1
  fi

  printf 'Creating PR for %s against origin/%s...\n' "$HEAD_BRANCH" "$BASE_BRANCH"
  gh pr create \
    --repo "$REPO" \
    --base "$BASE_BRANCH" \
    --head "$HEAD_BRANCH" \
    --title "$TITLE" \
    --body "$PR_BODY"

  PR_NUM=$(gh pr view "$HEAD_BRANCH" --repo "$REPO" --json number --jq '.number')
fi

printf 'Waiting for CI checks on PR #%s...\n' "$PR_NUM"
wait_for_ci_checks "$PR_NUM"

printf 'Squash-merging PR #%s...\n' "$PR_NUM"
gh pr merge "$PR_NUM" \
  --repo "$REPO" \
  --squash \
  --delete-branch \
  --subject "$TITLE (#$PR_NUM)" \
  --body "$MERGE_BODY"

# The merge is already done at this point, so nothing below may abort the run.
# `gh pr merge --delete-branch` removes the remote branch but can leave the
# local one checked out, and leaves the base branch where it was. A stale base
# is how the next ship starts from the wrong place, so sync it here.
printf 'Syncing local state...\n'
git fetch origin --prune

if git checkout -q "$BASE_BRANCH" &&
  git merge --ff-only "origin/$BASE_BRANCH"; then
  git branch -D "$HEAD_BRANCH" >/dev/null 2>&1 || true
  printf 'On %s at %s.\n' "$BASE_BRANCH" "$(git rev-parse --short HEAD)"
else
  echo "warning: PR #$PR_NUM is merged but the local sync did not complete." >&2
  echo "         finish with: git checkout $BASE_BRANCH && git pull --ff-only" >&2
fi
