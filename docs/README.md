# Ink Documentation

Ink is an end-to-end encrypted notes monorepo with a Flutter client and Go backend. The backend stores opaque encrypted blobs; encryption and decryption happen on-device.

This directory is committed. Every document here describes the current, verified system.

Agent behavior and documentation-maintenance rules live in [`/AGENTS.md`](../AGENTS.md).

## Start here

Read only the documents relevant to the task:

| Task | Read |
| --- | --- |
| Implement or prepare a PR | [workflow.md](workflow.md) |
| Understand the system | [architecture.md](architecture.md) |
| Change the Flutter client | [client.md](client.md), [theming.md](theming.md) for UI work |
| Change the Go backend or API | [backend.md](backend.md), [security.md](security.md) for auth/crypto changes |
| Change tooling, CI, Docker, or deployment | [development.md](development.md) |
| Select the next task | [tech-debt.md](tech-debt.md) |
| Understand recent decisions | [history.md](history.md) |

## Current reference

- [architecture.md](architecture.md) — current repository and system boundaries
- [client.md](client.md) — current Flutter architecture and key flows
- [backend.md](backend.md) — current Go service, API, and database design
- [security.md](security.md) — E2EE, key, token, and transport guarantees
- [theming.md](theming.md) — implemented theme architecture and test guardrails
- [development.md](development.md) — setup, generation, tests, CI, and deployment
- [workflow.md](workflow.md) — branch, commit, verification, and merge workflow

## Planning and history

- [tech-debt.md](tech-debt.md) — small actionable backlog only
- [history.md](history.md) — current baseline and the merged PR timeline

Everything here describes the current system. Earlier rationale lives in `git log`
and the merged PRs, not in this directory.

## Not documentation

Scratch work belongs in `.agent/` (gitignored): task checklists, intermediate
diffs, command output, working memory. It is transient by design. If a fact
matters after the task ends, it belongs in one of the documents above.

## Quick facts

- **Client:** Flutter, Riverpod, Drift/SQLite, go_router, gRPC, slang, flutter_quill
- **Backend:** Go gRPC service with PostgreSQL and sqlc-generated queries
- **Contracts:** Protobuf in `proto/`, generated for Go and Dart with Buf
- **Crypto:** Per-user random master key; Argon2id-derived KEKs; AES-256-GCM content encryption
- **Sync:** Cursor-based push/pull over one `Sync` RPC with client-side conflict resolution
