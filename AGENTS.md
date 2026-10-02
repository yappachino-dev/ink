# AGENTS.md

Ink - an E2EE notes monorepo. Flutter client in `client/`, Go backend in
`services/core`, protobuf contracts in `proto/`. The backend stores opaque
encrypted blobs; encryption and decryption happen on-device.

`docs/` holds verified, persisted information and is committed alongside the
code. Read `docs/README.md` for the map of which doc covers what. Scratch work
belongs in `.agent/`, which is gitignored and deleted when the task ends. The
line is simple: if it will still be useful to someone who was not in this
conversation, it is documentation; otherwise it is scratch.

## Default mode is local

Implement, verify, commit locally. Then stop and report the branch, the commit,
and the verification results. Do not push, open a PR, or merge unless the owner
explicitly asks for it.

## Never push to `main`

This repository has no branch protection - the protection API returns 403 on the
current plan - so nothing server-side refuses a direct push.

- **Always be on a feature branch before committing.** `ship-pr.sh` finishes on
  `main`; committing there is how a direct push happened this session.
- Branch from `origin/main`, not stale local `main`.
- `.githooks/pre-push` refuses the base branch. Enable once per clone:
  `make install-hooks`.
- When the owner asks for the lifecycle, run `./scripts/ship-pr.sh`. Never
  reconstruct it with `git push` plus `gh` calls. It merges only after checks
  pass, never with `--admin`; `--no-merge` stops after CI and leaves the PR open
  for review.

## Atomicity

One concern per branch and per commit. No drive-by formatting, dependency
bumps, or unrelated edits. If implementation surfaces a second concern, finish
the first and schedule the other separately.

## Verification

```bash
cd client && flutter analyze && flutter test
cd ../services/core && go build ./... && go vet ./...
cd .. && git diff --check
```

- `make check-architecture` and `make check-spacing` run the import and token
  verifiers. `check-spacing` is a **diff-based migration guard**, not a
  codebase-wide linter.
- Go integration tests need Docker. A missing socket is environmental, not a
  regression.
- Re-record only the goldens your change affects, then look at them. A
  goldens-only pass is not verification.
- A guardrail is untested until you break it deliberately and watch the check
  fail. Do that before claiming it catches anything.
- Never `git reset --hard` while uncommitted work exists. Back up files instead
  of restoring from git.

## Generated code

Never hand-edit: `*.g.dart`, `*.freezed.dart`, `grpc/gen/**`,
`strings*.g.dart`, Drift output, or sqlc output.

| Change | Command |
| --- | --- |
| protobuf | `buf generate` - the only path - then update both sides |
| annotated Dart | `dart run build_runner build --delete-conflicting-outputs` |
| SQL | edit `db/queries/*.sql` (migrations in `db/migrations/`), then `go tool sqlc` - not a global binary |
| Drift schema | `make schema-dump` then `make schema-generate` |

## Client conventions

- Spacing, radii, sizes, and durations come from `tokens.dart`
  (`AppSpacing`, `AppRadius`, `AppSize`, `AppDurations`). No raw numbers.
- Errors are sealed failure classes carrying `Result<T, Failure>`.
- Anchor tokens used as negative-match filters exactly: `^project$`, never
  `^project`. The loose form silently swallows `projection` and corrupts the
  sweep.

Before UI work, read `docs/workflow.md` under "Code quality gates" and
`docs/theming.md`. That is where the specific traps live and they are not
restated here: decoration versus clipping, semantics merging and
`excludeSemantics`, padding around versus for a scroll view, why a one-item
golden cannot catch an overflow, and theme contrast.

## Commenting

Comment the *why* when the code cannot state it: a constraint, a trade-off, a
trap, a deliberate absence. Not the signature, not a narration of the next line,
not PR history - that belongs in `docs/`.

If deleting a comment cannot make someone misunderstand the code, delete it. A
comment longer than the code it describes usually means the code wants
restructuring. `notes/domain/constants.dart` once ran 82% comment lines; that
is the failure mode.

## Reviews

- **Verify the claim before acting.** Reported bugs are sometimes false
  positives. Prove it and say so rather than "fixing" it.
- A `difference` between two `DateTime`s can itself be the bug; calendar-day
  arithmetic is not 24-hour arithmetic.
- Confirm semantics by rendering the tree, not by reasoning about node merging.
- Padding *around* a scroll view shrinks its viewport; padding *for* one goes
  on the content. A golden with a single item cannot see the difference.
- A new test that passes against the old code is not a regression test. Say so
  instead of claiming the coverage.

## Commits and PRs

- Conventional Commits with scope: `feat(se/core):`, `refactor(cl/notes):`.
  Subject only, empty body. `!` marks a breaking change.
- PR descriptions stay short - what and why, no test transcripts. Use a plain
  hyphen `-`, never an em dash.
- Squash-merge; `ship-pr.sh` owns the merge. One-commit PRs take the commit
  subject verbatim; multi-commit PRs take the supplied title plus a bullet list
  of commit subjects.

## Documentation

`docs/` holds verified, persisted information and nothing else. Update it in the
same task and commit it with the change, describe reality rather than intention,
and keep cross-links valid when renaming documented files. If a document
describes shipped work or a completed plan, it has outlived its use - fold
anything still true into a live document and delete the rest.

| Touched | Update |
| --- | --- |
| `proto/**`, gRPC API, auth/vault/sync behavior | `docs/backend.md`, maybe `docs/security.md` |
| `services/core/**` (packages, schema, config, queries) | `docs/backend.md` |
| Crypto, sessions, key slots, token handling | `docs/security.md` |
| `client/lib/**` (features, sync, state, stack) | `docs/client.md` |
| Client UI or theme work | `docs/theming.md`, and `docs/workflow.md` "Code quality gates" |
| Build files, `Makefile`, compose, `buf*`, `go.work`, CI | `docs/development.md`, `docs/architecture.md` |
| Merged work worth narrating | a row in `docs/history.md` |

## Known blockers

- `http2 3.1.0` unavailable: `grpc 5.1.0` requires `http2 ^2.3.1`.
- `pointycastle 4.0.0` unavailable: `bip39 1.0.6` requires PointyCastle 3.x.

Recheck both before planning around them.
