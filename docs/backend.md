# Go Backend (`services/core`)

A single "core" service exposing:

- **gRPC on :50051** — the real API (`auth.v1`, `vault.v1`, `sync.v1`) plus standard gRPC health service (with a `readiness` status fed by DB pings).
- **HTTP on :8080** — Gin-based `/ping` and `/healthz` endpoints for simple probes.

Module path: `github.com/yappachino-dev/ink/services/core`. It consumes the
separate generated module `github.com/yappachino-dev/ink/gen/go` through a local
module replacement; a Go workspace is optional for local development.

## Package layout

```
internal/
├── app/          # App wiring: pool, repos, services, gRPC + HTTP servers, health loop
├── appctx/       # Request context helpers
├── auth/         # Users, JWT, refresh tokens, email verification, bcrypt, gRPC server + auth middleware
├── config/       # Env loading (.env via godotenv)
├── database/     # pgx pool connect, transactor (WithinTransaction)
├── store/        # sqlc-generated code from db/queries/*.sql
├── sync/         # Cursor-based delta sync: service, repo, grpc server/adapter
├── vault/        # Key slot persistence: service, repo, grpc server/adapter
```

Each domain keeps the same shape: `models.go`, `service.go` (logic),
`postgres_*.go` (sqlc-backed repository), `grpc_server.go` (+ `grpc_adapter.go`
where proto/domain mapping is non-trivial).

## gRPC API summary

### auth.v1 — AuthService
Rate limiting: public RPCs are capped per peer IP (Login 10/min, Register 5/min,
VerifyEmail 3/h, RefreshToken 30/min, Logout 10/min) plus a per-email cap on
verification codes; confirmation attempts lock out after 5 failures. The peer
key strips the ephemeral port, so reconnects cannot reset the window.
Password policy is enforced server-side (6–72 bytes — bcrypt truncates beyond
72); registration rejects already-registered emails *before* consuming the
single-use verification code, and the users.email UNIQUE constraint maps to
`AlreadyExists` as a race backstop.
| RPC | Notes |
| --- | --- |
| `VerifyEmail` | Generates a verification code and hands it to the configured `CodeSender`. Only `LogCodeSender` ships, so production refuses to start |
| `Register` | Email + password + code → creates user (bcrypt hash), returns token pair |
| `Login` | Credential check → token pair |
| `RefreshToken` | Atomically rotates the active refresh token (replacement insert and old-token revoke), new access token |
| `Logout` | Revokes the presented refresh token |

Tokens: HS256 JWT access token (15 min, `user_id` claim); refresh token is 32
random bytes stored as SHA-256 hash with 7-day TTL. Refresh rotation uses one
conditional SQL operation so replacement failure leaves the current token
usable; reuse of a revoked token still revokes all sessions for the user.
Errors are sentinel errors (`ErrInvalidCredentials`, `ErrExpiredRefreshToken`, …).

The `UnaryAuthInterceptor` delegates metadata extraction and interceptor
execution to `go-grpc-middleware/v2`, while Ink's `AuthFunc` pins HS256,
validates the JWT, and injects the user ID into context; auth RPCs remain
public. The logging interceptor is also provided by
`go-grpc-middleware/v2`. Public auth rate limits use the bounded in-memory
keyed limiter until the service needs shared multi-replica enforcement.

### vault.v1 — VaultService
- `GetKeySlots` / `SaveKeySlots` — plain storage of `(key_type, salt,
  wrapped_master_key, updated_at)` per user. The server cannot interpret these
  blobs; semantics live entirely client-side.

### sync.v1 — SyncService
- Single `Sync(SyncRequest) → SyncResponse` RPC carrying both push and pull in
  one transactional round trip:
  1. Read the user's current `sync_cursor`; only push requests take the
     user-row `FOR UPDATE` lock.
  2. If the client pushed changes, **validate the batch** (see below).
  3. Increment the cursor and upsert pushed projects/notes stamped with the new
     sequence.
  4. Return all rows with `sync_sequence > client_cursor`.
  5. Respond with `next_cursor`.

Pull-only requests therefore do not serialize behind concurrent pushes or
other pulls. Push transactions retain the lock through cursor allocation,
validation, upserts, and change reads so a returned sequence remains consistent.

#### Push validation

A push is rejected in full, before the cursor moves, when any of these hold.
Rejecting the whole batch matters: a partially applied push would leave the
client's cursor and the stored rows permanently disagreeing.

| Condition | Error type | gRPC code |
| --- | --- | --- |
| The same project or note ID appears twice in one batch | `DuplicateEntityIDsError` | `InvalidArgument` |
| A pushed notebook/note ID already belongs to another account | `OwnershipConflictError` | `AlreadyExists` |
| A note references a notebook the account cannot use | `NotebookReferenceError` | `FailedPrecondition` |

Projects carried in the same batch count as available references: they have
already cleared the ownership check and are written immediately after. This is
what makes the core offline workflow work — creating a project and a note that
references it while disconnected, then pushing both at once. Only references
*not* in the batch are looked up, which also skips the round trip entirely when
a batch is self-contained.

Error messages list at most 5 IDs and then report the remainder as
`(and N more)`, so a malformed or hostile batch cannot inflate the response
body or every log line that records the rejection.

The ownership checks exist because the upsert guards
(`WHERE user_id = EXCLUDED.user_id`) turn a cross-user ID into a **successful
no-op**: the statement matched, updated zero rows, and reported no error, so
the client advanced its cursor believing the write had landed. The
`FindProjectIDsOwnedByOtherUsers` / `FindNoteIDsOwnedByOtherUsers` queries turn
that into an explicit rejection.

The `notes.project_id` foreign key checks `projects(id)` only, not ownership,
so cross-user project references are *not* prevented by the schema.
`FindProjectIDsAvailableToUser` enforces ownership in the service, and missing
and foreign-owned projects produce the same error text so the response cannot
be used to discover which project IDs exist.

Note: the schema still permits a cross-user `project_id` for any writer that
bypasses `SyncService`. A composite foreign key on `(project_id, user_id)` would
close that at the database level, but it needs `ON DELETE SET NULL (project_id)`
(PostgreSQL 15+ column-list syntax) and a migration; it is tracked as optional
hardening rather than done here.

Rows use UUID PKs, soft delete (`deleted_at`), and integer `version` counters.
Upserts bump versions server-side; conflict policy (last-writer-wins) is
resolved on the client.

## Database

PostgreSQL, versioned goose-annotated SQL migrations in `db/migrations/*.sql`
(embedded via `db/migrations/embed.go`, applied automatically on boot; CLI:
`cmd/migrate`), queries in `db/queries/*.sql`.

All timestamp columns are `timestamptz` (migration `00002`; values written as
UTC). `sqlc.yaml` overrides map them to `time.Time` / `*time.Time` in generated
code; optional columns bridge to the domain's zero-time-means-absent convention
via `database.FromNullTime` / `ToNullTime`.
compiled to Go by sqlc (`sqlc.yaml`). Tables:

| Table | Purpose |
| --- | --- |
| `users` | id, email (unique), password_hash, per-user `sync_cursor` |
| `user_keys` | key slots: (user_id, key_type) PK, salt, wrapped_master_key |
| `projects` | UUID id, encrypted_content blob, version, sync_sequence, soft delete |
| `notes` | UUID id, optional project FK (SET NULL, **not ownership-checked**), encrypted_title/content blobs, version, sync_sequence, soft delete |
| `refresh_tokens` | hashed tokens, expiry, revocation tracking |
| `email_verifications` | hashed codes with expiry/used flags |

Indexes support the sync hot path: `idx_projects_sync(user_id, sync_sequence)`
and `idx_notes_sync(user_id, sync_sequence)`.

## Configuration

Loaded from environment (optionally `.env`):

| Variable | Required | Purpose |
| --- | --- | --- |
| `DATABASE_URL` | yes | Postgres connection string |
| `JWT_SECRET_KEY` | yes (in practice) | HS256 signing secret |
| `APP_ENV` | no (default `development`) | `development` logs verification codes; `production` refuses to start, because no `CodeSender` ships |

Verification-code delivery is chosen at boot. Only `auth.LogCodeSender` ships,
so `APP_ENV=production` returns an error instead of starting; any other
environment logs the code. The interface is the delivery seam: a provider such
as Resend slots in behind `auth.CodeSender` without touching the auth services.
Verification codes are bearer secrets, which is why production fails closed
rather than writing them to the log.

## Observability & lifecycle

- Structured logging via `slog` + tint handler; gRPC calls logged through the
  `grpc-ecosystem` logging interceptor (start/finish events).
- Background goroutine pings the DB every 5s and flips the gRPC `readiness`
  health status accordingly; k8s probes consume it. The status is set once
  synchronously before the goroutine starts, so it is never briefly unknown.
  `App` owns the probe: `shutdown` cancels it and waits before closing the
  database, which is the only thing covering a crash exit where no signal
  cancelled anything.
- Teardown runs on every exit path, not only on a signal: `App.serve` defers
  `shutdown`, so a failing server releases resources too. Shutdown stops the
  readiness probe, then closes HTTP (bounded `Shutdown`), then gRPC
  `GracefulStop` escalating to `Stop` after 5s, then the `*sql.DB`, then the
  pgx pool. That order matters: the `*sql.DB` borrows the pool, so closing it
  does not close the pool.
- Each connect attempt is bounded by a 3s timeout. The DSN's `connect_timeout`
  covers the dial only, not the postgres startup handshake.
