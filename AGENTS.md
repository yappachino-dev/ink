# AGENTS.md

Instructions for AI coding agents working on this repository (Ink — an E2EE
notes monorepo: Flutter client in `client/`, Go backend in `services/core`,
protobuf contracts in `proto/`).

## Documentation maintenance (mandatory)

All `*.md` files under `docs/` are agent-owned living documentation. Whenever
your changes affect something a doc describes, **update the relevant doc in the
same task** — do not leave docs stale.

| Area touched | Docs to update |
| --- | --- |
| `proto/**`, gRPC API, auth/vault/sync behavior | `docs/backend.md`, possibly `docs/security.md` |
| `services/core/**` (packages, DB schema, config, queries) | `docs/backend.md`; schema/crypto-adjacent changes → `docs/security.md` |
| Crypto, session, key slots, token handling | `docs/security.md` |
| `client/lib/**` (features, sync engine, state, stack) | `docs/client.md` |
| Repo structure, build files (`Makefile`, compose, `buf*`, `go.work`) | `docs/architecture.md`, `docs/development.md` |
| CI/CD, k8s, deployment | `docs/development.md`, `docs/architecture.md` |
| Any merged work worth narrating | append to the timeline/phases in `docs/history.md` |

Rules:

1. **New PRs/commits get history entries.** When you land a change on `main`,
   add a row to the table in `docs/history.md` and, if it represents a new
   phase or convention, extend that document's prose.
2. **Docs describe reality, not intentions.** Don't document planned features
   as if implemented; note open items explicitly (e.g., "Known hardening items").
3. **Keep cross-links valid.** If you rename/move documented files, fix references.
4. **Don't commit docs.** `docs/` is gitignored by design; it serves the human
   and agents working locally.

## Project conventions

- Commit style: Conventional Commits with scope prefixes — `feat(se/core):`,
  `refactor(cl/<feature>):`, `client:` / bare for cross-cutting; `!` for breaking
  changes. Squash-merge PRs; keep one concern per PR.
- API changes start in `proto/**`; run `buf generate` and update both sides.
- Client codegen: `dart run build_runner build --delete-conflicting-outputs`
  after editing annotated Dart; never hand-edit generated files
  (`*.g.dart`, `*.freezed.dart`, `grpc/gen/**`, `strings*.g.dart`).
- Backend SQL: edit `db/queries/*.sql` + regenerate with sqlc; migrations live
  in `db/migrations/`.
- Errors: sealed failure classes + `Result<T, Failure>` on the client; sentinel
  errors in Go services.

## GitHub PR lifecycle (explicit opt-in)

Do not push a branch, create a watch, or merge a pull request during ordinary
implementation. Keep completed work local and report the branch, commit, and
verification results. Push or run the full GitHub CLI lifecycle only when the
owner explicitly asks. When the owner explicitly asks for the full GitHub CLI
lifecycle, use
`scripts/ship-pr.sh` rather than reconstructing `gh` commands manually:

```bash
./scripts/ship-pr.sh 'chore(scope): summarize the complete change'
# The PR description is independent of the commit count, so it may be added to
# any PR — one commit or several — whenever the change deserves explanation:
./scripts/ship-pr.sh --pr-body 'Short explanation of the core design.' \
  'chore(scope): summarize the complete change'
```

The script derives the default branch from `origin/HEAD`, fetches it, and
counts commits relative to that branch. Two bodies are involved and the commit
count governs only one of them:

- **PR description** — empty unless `--pr-body` is passed. Independent of the
  commit count: add it to a one-commit PR whenever the change warrants it, and
  omit it from a multi-commit PR whose title list already says everything.
- **Squash-commit body**, i.e. the message left in `main` history — this is
  where the count applies. A one-commit PR takes the exact commit subject with an
  empty body; a multi-commit PR takes the supplied title with a single-spaced
  bullet list of commit titles, oldest to newest.

Multi-commit PRs must be given a high-level title argument. On a one-commit PR
that argument is ignored: the commit subject is used verbatim, so the commit
message and PR title cannot diverge by accident.

The script pushes the branch, creates the PR, watches CI with
`--fail-fast`, and squash merges only after checks pass. It never bypasses
branch protection or uses `--admin`. The agent must not run this script unless
the owner explicitly requests the lifecycle.
