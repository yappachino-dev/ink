# Ink Contribution Workflow

This repository uses small, atomic changes delivered through a branch and a
squash merge. The normal workflow is local-first: the agent implements,
verifies, and commits each task locally, then stops for owner review. The owner
may later request a push, PR creation, and merge. When the owner explicitly
requests the full GitHub CLI lifecycle, the agent may use the tracked
`scripts/ship-pr.sh` helper instead.

## Roles and boundaries

### Repository owner

- Reviews the task scope and decides whether to use the normal owner-managed PR
  flow or explicitly opt into the agent-managed `gh` lifecycle.
- Uses squash merge so one task becomes one commit on `main` when managing the
  PR manually.
- Tells the agent when an owner-managed PR has been merged.
- Does not expect the agent to push directly to `main`.

### Agent

- Evaluates one scheduled task at a time.
- Starts from the latest `main`.
- Creates one focused branch for that task.
- Implements, tests, documents, and commits the branch locally.
- Does not push a branch, create a PR, watch CI, or merge unless the owner
  explicitly asks.
- When the full lifecycle is requested, uses `scripts/ship-pr.sh`; otherwise
  stops after the local commit and presents the next scheduled task.
- After the owner confirms the merge, pulls `main` and begins the next task.

## Atomicity rules

A task is one self-contained concern with one clear outcome. Examples:

- Fix one state-management bug and add its regression tests.
- Add certificate pinning and its focused tests.
- Add one notifier test suite and only the production fixes it proves are needed.
- Update one migration or generated contract path end to end.

Do not combine unrelated bug fixes, cleanup, refactors, or multiple feature areas
in one branch/commit. If implementation reveals a separate concern, finish the
current atomic task first, then schedule the other concern separately.

Every task should leave the repository in a coherent, verified state. Avoid
drive-by formatting, dependency upgrades, and unrelated edits.

## Branch workflow

Start from synchronized `main`:

```bash
git fetch origin
git switch main
git pull --ff-only origin main
git status --short --branch
```

Create one descriptive branch:

```bash
git switch -c fix/descriptive-task-name
```

Recommended branch names:

- `fix/<task>`
- `feat/<task>`
- `refactor/<task>`
- `test/<task>`
- `chore/<task>`

The branch name describes the complete task. A branch contains one logical
change and may use multiple focused commits when the owner requests that
format.

## Implementation and verification

Before editing:

1. Read `AGENTS.md` and the relevant `docs/` files.
2. Trace the affected implementation, generated code, and existing tests.
3. Define the expected behavior as a focused test when production code changes.
4. For bugs, first reproduce the bug with a failing regression test where
   practical.

While implementing:

1. Change only files required by the current task.
2. Follow the repository's code generation rules; never hand-edit generated
   files.
3. Update relevant documentation in `docs/` in the same task, and commit it with
   the change it describes.
4. Never stage credentials, `.env` files, or unrelated local changes.

Before committing, run the relevant checks. Client-only tasks normally require:

```bash
cd client
flutter analyze
flutter test
```

Backend-only tasks normally require:

```bash
cd services/core
go build ./...
go vet ./...
go test ./...
```

Schema/API changes must also run the repository's migration and code-generation
workflows. Use the relevant project verification commands from
[development.md](development.md) and finish with `git diff --check`.

Review the task before committing:

```bash
git status --short
git diff
git diff --check
```

## Commit locally

Use a Conventional Commit matching the change:

```bash
git add <task-files>
git commit -m "fix(client): resolve concise task description"
```

Commit rules:

- Stage intentional files only; avoid `git add .` when unrelated changes exist.
- Keep one coherent commit per branch under the normal workflow.
- Commit `docs/` updates alongside the code they describe; docs are tracked.
  Scratch that does not outlive the task belongs in `.agent/`, which is ignored.
- Never commit directly to `main`.
- Do not push the branch unless the owner explicitly requests it.
- Never merge the branch yourself unless explicitly requested.

After the local commit, verify that the branch is clean and report its state:

```bash
git status --short --branch
git log -1 --oneline
```

## GitHub CLI PR lifecycle (explicit opt-in)

The repository includes `scripts/ship-pr.sh` for an explicitly requested,
non-interactive PR lifecycle. It is preferable to copying the commands into a
session because it centralizes branch discovery, commit counting, title/body
formatting, CI waiting, and squash-merge arguments.

Run it only after the owner explicitly asks the agent to create and merge the
PR:

```bash
./scripts/ship-pr.sh 'chore(scope): summarize the complete change'
# The PR description is independent of the commit count, so it may be added to
# any PR that deserves an explanation:
./scripts/ship-pr.sh --pr-body 'Short explanation of the core design.' \
  'chore(scope): summarize the complete change'
```

Behavior:

1. Derive the default branch from `origin/HEAD` and fetch it.
2. Count commits relative to `origin/<default-branch>`.
3. The PR description and the squash-commit body are separate things, and the
   commit count only governs the second one.
4. The PR description is empty unless `--pr-body` is supplied. It is never
   derived from the commits, and is not tied to the commit count: supply it for
   a single-commit PR whose change needs explaining, or omit it from a
   multi-commit PR whose commit list already does.
5. The squash commit is what the count shapes. One commit takes the exact commit
   subject with an empty body. Multiple commits take the supplied title — which
   is then required — with a single-spaced `* <commit title>` bullet list in
   oldest-to-newest order as the body.
6. On a one-commit PR the title argument is ignored in favour of the commit
   subject, so the two cannot drift apart.
7. Push the branch, create the PR, wait for GitHub to register its checks,
   watch them with `--fail-fast`, and squash-merge only after checks pass.
8. Never bypass branch protection or use `--admin`.

This is opt-in because automatic merging is a repository-owner decision. Normal
implementation and verification must not invoke the script. The agent should
report the PR URL and wait for the owner when using the manual workflow.

## Waiting for owner direction

After the local commit, the task is not complete on `main`. The agent must:

1. Stop changing the task branch.
2. Report the branch, commit, verification results, and local diff summary.
3. Wait for the owner to request a push/PR lifecycle or further corrections.
4. Do not begin the next implementation while the current task is unresolved.

If the owner later requests the remote lifecycle, use the opt-in GitHub CLI
workflow and then wait for the merge confirmation as described below.

## Pulling after merge

Once the owner reports that the PR is merged:

```bash
git fetch origin
git switch main
git pull --ff-only origin main
git branch -d <merged-local-branch>
```

The pull will normally apply the squash commit created by GitHub, so its commit
hash will differ from the local task commit. That is expected.

Before starting the next task, confirm:

```bash
git status --short --branch
git log -3 --oneline
```

Then create a fresh branch for that next task.

## Corrections before merge

If the owner requests a correction before merging, stay on the same task branch:

1. Make the smallest focused correction.
2. Re-run relevant verification.
3. Amend the existing task commit when preserving one commit is desired:

```bash
git add <corrected-files>
git commit --amend --no-edit
```

If the branch was already pushed, reconcile with the remote before rewriting
it and use `git push --force-with-lease`, never an unconditional force push.

If the correction is substantial or introduces another concern, do not hide it
inside the current task. Create or schedule a separate atomic task.

## End-of-task report format

After a successful local commit, report:

```text
Task completed:
- What problem it solved
- What changed
- Focused and full verification results
- Local branch
- Local commit
- PR creation/merge URL only if the owner requested the remote lifecycle

Next task:
- What it solves
- How it will be implemented
```

Do not claim that the task has landed on `main` until the owner confirms the
remote squash merge and the agent has pulled it successfully.

## PR description style

Keep it short. Two or three short paragraphs at most, or a handful of bullets.

- Explain the what and the why. Do not recap the test output, and do not
  reference plan documents - the diff is the record, the description is the
  argument for it.
- Use a plain hyphen `-`, not an em dash `—`. It is the key that is actually on
  the keyboard, and the text is easier to type and to search.

## Code quality gates

The UI revamp ended with a QA sweep for magic values. What it found is worth
keeping as rules, because every one of these was invisible to the analyzer:

- **Spacing, radii, icon sizes and durations come from `tokens.dart`.** There
  is one scale each for `AppSpacing`, `AppRadius`, `AppSize` and
  `AppDurations`. Off-scale values snap to the nearest step, and a value that
  genuinely needs its own step gets a token and a comment saying why.
- **Never write `.rstrip('.0')` to trim a numeric suffix.** It takes a
  *character set*, so `'20'` becomes `'2'`. A migration script using it
  silently mapped half the spacing scale to the wrong token. Use
  `removesuffix`.
- **Padding *around* a scroll view is not padding *for* it.** Wrapping a
  `ListView` in `Padding(bottom: 24)` shrinks the viewport by 24px; it does
  not give the last card 24px of room. The list then stops short of the
  navigation bar, the last card is clipped against it, and the leftover strip
  renders as a band of bare background. To give a scrolling surface clearance
  from the bar or a FAB, put the padding on the *content*. `AppSpacing
  .screenBottom` existed only for the wrong version of this and was deleted.
- **A golden with one item cannot see a bottom-of-list defect.** The theme
  goldens render a single note, so the list never overflows and the end of the
  surface is never exercised. Overflow-dependent layout needs a fixture long
  enough to scroll: see `notes_bottom_clearance_test.dart`.
- **Check that generated code interpolates, not just that it compiles.** A
  translation authored as `"{n} minutes"` compiles perfectly and renders
  `"{n} minutes"`: slang interpolates with `$n`, and the braces are literal.
  The `one`/`other` branches are only exercised by a plural resolver, so a
  golden or a smoke test that never opens the picker cannot see it. Assert on
  the rendered string, including the absence of `{` and `$n`.
- **A widget that a dependency builds still needs the app's theme.** Anything
  rendered from stock `package:flutter/material.dart` inside a
  `material_ui`-themed app resolves Flutter's *default* light theme unless a
  stock `Theme` is handed down explicitly. `flutter_quill`'s toolbar measured
  1.0-1.2:1 on the dark surface until it got one. This is the same class of
  defect as the logo reading the wrong theme, reached through a dependency
  rather than an import.
- **`excludeSemantics: true` drops descendant *actions*, not just labels.** A
  chip whose wrapper excluded its children kept a label but silently lost the
  tap action, so it announced as a button that did nothing. Declare `onTap` on
  the node that carries the label. Two actions in one control must be two
  sibling nodes, not one node excluding the other.
- **`Container` insets its child by the decoration's border width;
  `DecoratedBox` does not.** Swapping one for the other to "simplify" made the
  toolbar paint straight over its own 1px top border, fusing the meta row and
  the toolbar into one block. When a border has to stay visible, keep the
  `Container` or add the inset by hand.
- **A bottom inset belongs to the bar that owns it, and the bar's background
  paints *outside* its `SafeArea`.** Applying `SafeArea` around a whole column
  reserved a strip under the pinned toolbar showing a different theme role than
  the toolbar itself. Same colour in light, two colours in dark, so it only
  ever showed up in the one theme nobody checks.
- **A tint that cannot be seen is not a tint - assert a number.** When a
  surface is introduced to mark a boundary, assert its separation from the
  surface it sits against. `chrome` vs `surface` at 1.06:1 minimum catches
  `surfaceContainerLow` (1.035:1), which is close enough to the near-identical
  greys that read as a rendering fault. A golden records the mistake as the new
  baseline, so it cannot be the guard.
- **A refactor script is a change, so it needs a verifier.** Compare the
  normalised old and new values per call site and print the ones that moved.
  Regex cannot check a *visual* result; a golden or a rendered-pixel sample
  can.
- **Run `make check-spacing` after any spacing change.** It
  exists because the sweep shipped a real corruption first time: `rstrip('.0')`
  turned `40` into `4`, so 40px gaps became `AppSpacing.xs` and five layouts
  collapsed while the analyzer stayed green. The verifier compares each token
  against the literal it replaced, and reports files it cannot pair under
  "unchecked" rather than guessing. Those do not fail the run; only real
  corruption does.

- **Write tools in the language of the layer they check.** A verifier for
  client Dart belongs in `client/tool/*.dart` next to
  `check_architecture.dart`, not in a one-off script in another language. A
  tool in a language nothing else uses is unreviewed by the analyzer, absent
  from `flutter analyze`, and has no obvious way to be run - so the rule that
  depends on it quietly stops being followed.
- **A goldens-only pass is not verification.** A change that is "just spacing"
  still has to be re-recorded and looked at.
- **Format only what you changed.** `dart format lib` rewrites the tree; in this
  session it did so four separate times. `dart format <changed files>`.
