# Ink
![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)
![Go](https://img.shields.io/badge/Go-1.24%2B-00ADD8?logo=go&logoColor=white)
![Transport](https://img.shields.io/badge/Transport-gRPC-4285F4?logo=grpc&logoColor=white)
![Database](https://img.shields.io/badge/Database-PostgreSQL_18-4169E1?logo=postgresql&logoColor=white)
![Flutter](https://img.shields.io/badge/Client-Flutter-02569B?logo=flutter&logoColor=white)

**A local-first, end-to-end encrypted (E2EE) notes and journaling system.**

Ink is a full-stack monorepo featuring a Flutter mobile client and a Go gRPC backend. The architecture treats the backend as an untrusted storage and coordination layer: every note, title, notebook, and task attribute is encrypted on-device using AES-256-GCM before touching local SQLite storage or traversing the wire. The server routes, versions, and sequences opaque ciphertext blobs without ever possessing keys or plaintext.

---

## Architecture Overview

```text
+-----------------------------------+         gRPC :50051 (TLS + SPKI Pin)        +----------------------------------+
|          Flutter Client           | <-----------------------------------------> |         Go Core Service          |
|                                   |         auth.v1 / vault.v1 / sync.v1        |                                  |
|  - Argon2id KDF (Isolate)         |                                             |  - HS256 JWT + Token Rotation    |
|  - AES-256-GCM Content Cipher     |         HTTP :8080 (/ping, /healthz)        |  - Advisory Lock Key-Slot Guard  |
|  - Drift (SQLite) + Metadata Cache| <-----------------------------------------> |  - Transactional Delta Sync      |
|  - Version-Vector Conflict Engine |                                             |  - Bounded In-Memory Rate Limits |
+-----------------------------------+                                             +-----------------+----------------+
                                                                                                    |
                                                                                                    | pgxpool + sqlc
                                                                                                    v
                                                                                  +----------------------------------+
                                                                                  |           PostgreSQL 18          |
                                                                                  |     (Ciphertext & Sequences)     |
                                                                                  +----------------------------------+
```

### Repository Structure

```text
ink/
├── proto/                  # Protobuf API contracts (auth.v1, vault.v1, sync.v1)
├── gen/go/                 # Standalone Go module for generated protobuf/gRPC stubs
├── services/core/          # Go backend service (gRPC API, HTTP health, Embedded Goose migrations)
├── client/                 # Flutter application (Clean Architecture, Riverpod 3, Drift, Quill)
├── k8s/                    # Historical/experimental Kustomize manifests
├── docs/                   # Architectural reference, threat model, and design documentation
├── buf.yaml / buf.gen.yaml # Buf linter, breaking-change detector, and codegen config
└── docker-compose.yaml     # Local development stack (Backend + Postgres 18)
```

---

## Key Engineering Highlights

### 1. Zero-Knowledge Cryptographic Key Hierarchy
All cryptographic operations execute on the client (`client/lib/core/infrastructure/crypto/`):
- **Master Key Generation:** At vault creation, a 256-bit random Master Key is generated via CSPRNG alongside a 12-word BIP-39 recovery phrase (128 bits of entropy).
- **Multi-Slot Key Wrapping:** For each enabled unlock method (PIN, Pattern, and Recovery Phrase), the user's secret is NFC-normalized, salted with 16 random bytes, and passed through **Argon2id** (64 MiB memory, 3 iterations in release builds, offloaded to a background Dart `Isolate` via `compute`) to derive a 256-bit Key Encryption Key (KEK).
- **Envelope Encryption:** The Master Key is wrapped with each KEK using **AES-256-GCM** (12-byte nonce, 16-byte MAC) and stored as an independent `KeySlot`. Unlocking any single slot reveals the Master Key in memory.
- **Memory Hygiene:** `SessionManager` exposes the Master Key only through defensive byte-array clones (`Uint8List.fromList`). Locking the vault or logging out zeroes the underlying key buffer in place before nulling the reference.
- **Transport Hardening:** Beyond standard TLS, the gRPC client supports X.509 **SubjectPublicKeyInfo (SPKI) certificate pinning** (`PinnedGrpcClientChannel`), parsing raw ASN.1 DER structures to verify `sha256/<base64>` public key fingerprints during the TLS handshake.

### 2. Cursor-Based Bidirectional Sync & Conflict Resolution
Synchronization happens over a single unary `SyncService.Sync` RPC that exchanges local pushes and remote pulls in one database transaction:
- **Lock-Minimized Concurrency:** On the backend, pull-only sync requests read `sync_cursor` without locking. Only push transactions acquire a `SELECT ... FOR UPDATE` row lock on the user's cursor, preventing read-heavy syncs from serializing behind writes.
- **Batch Validation & Offline Referential Integrity:** Before advancing the cursor, the backend validates the entire push batch for duplicate UUIDs (`InvalidArgument`), cross-account ownership collisions (`AlreadyExists`), and unauthorized notebook references (`FailedPrecondition`). Validation resolves note-to-notebook references against both the database and the incoming batch itself, allowing users to create a notebook and add notes to it while completely offline and push both in a single atomic batch.
- **Deterministic Delta Resolution:** The client resolves incoming deltas using version counters rather than error-prone wall-clock Last-Write-Wins (`resolveSyncDelta`). If a note was modified both locally (`localVersion > lastSyncedVersion`) and remotely (`incomingVersion > lastSyncedVersion`), the local row is marked `SyncStatus.conflicted` and the server's payload is preserved in dedicated `note_conflicts` / `notebook_conflicts` tables so user data is never silently overwritten.
- **Tombstone Lifecycle:** Deletions mark entities as `SyncStatus.deleted` with a `deletedAt` timestamp so the tombstone is queued for push. Rows are physically deleted from SQLite only after the server acknowledges the push.

### 3. Encrypted Payload vs. Local SQL Queryability
Because the server is zero-knowledge and all note metadata (Quill Delta JSON body, due dates, priority, completion status) is serialized inside the encrypted blob, naive list views would have to decrypt the entire database on every read.
- **Derived Plaintext Cache:** The local SQLite `notes` table maintains non-synced, locally derived columns (`title_preview`, `body_preview`, `due_date_day`, `metadata_version`).
- **Locked-Vault Sync Resilience:** When remote notes arrive via background sync while the vault is locked, `RemoteNoteMetadataEnricher` persists the valid ciphertext immediately with a `deferredNoteMetadata` tag (`version: 0`) so sync never stalls on a locked session. On the first read after unlock, `SecureNotesService` runs an indexed backfill pass to decrypt and populate the local cache without bumping `localVersion` or triggering a false sync push.
- **Untrusted Delta Sanitization:** Synced Quill JSON deltas are treated as untrusted input. A pure-Dart parser (`quill_delta.dart`) strips malformed operations and guarantees trailing newline invariants before `flutter_quill` touches the data. If a note contains unreadable operations from a newer/corrupt peer, the editor displays a warning banner and requires explicit confirmation before a save overwrites the raw payload.

### 4. Multi-Device Vault Lockout Prevention
If a user sets up a vault on Device A and accidentally runs fresh setup on Device B under the same account, Device B generates a different Master Key. A naive `ON CONFLICT (user_id, key_type) DO UPDATE` would overwrite Device A's key slots and permanently lock the account out of its existing notes.
- **Serialized Divergence Check:** `VaultService.SaveKeySlots` acquires a transaction-scoped PostgreSQL advisory lock (`pg_advisory_xact_lock(78511, user_id)`) before reading existing slots.
- Why an advisory lock? Under PostgreSQL's default `READ COMMITTED` isolation, two concurrent initial pushes would both read an empty table, pass validation, and silently overwrite each other. Using a namespaced advisory lock serializes key-slot mutations per account without contending with `SyncService`'s `FOR UPDATE` lock on the `users` table. Byte-identical retries are accepted idempotently; divergent key material is rejected across the entire batch with `codes.AlreadyExists`.

### 5. Hardened Authentication & Session Lifecycle
- **Atomic Refresh Token Rotation:** Refresh tokens (32 random bytes, stored as SHA-256 hashes) rotate on every use via a single CTE query (`WITH revoked AS (UPDATE ... RETURNING user_id) INSERT ... SELECT FROM revoked`). If inserting the replacement fails, the transaction rolls back and leaves the current token active.
- **Context-Detached Reuse Detection:** Presenting an already-revoked refresh token—or losing an atomic rotation race—triggers full session family revocation (`RevokeAllByUserID`). This revocation executes on a detached `context.WithoutCancel` context with a 2-second timeout: if an attacker or flaky mobile client drops the connection mid-request after the token lookup completes, the security revocation still commits.
- **Timing-Oracle & Brute-Force Mitigations:** `Login` verifies passwords against a precomputed bcrypt dummy hash when an email does not exist, equalizing response times to prevent account enumeration. Public gRPC endpoints are protected by a bounded (10,000-bucket max, LRU/TTL-evicted) fixed-window rate limiter keyed by peer IP (with ephemeral ports stripped) and SHA-256 email hashes.

---

## Tech Stack

### Client (`client/`)
- **Framework:** Flutter (Dart SDK `^3.10.0`), Material 3 with custom semantic `InkColors` theme extension
- **State & DI:** Riverpod 3 (`riverpod_annotation`) with clean domain/port inversion wired at the composition root (`app/init.dart`)
- **Database:** Drift (SQLite) running on a background native isolate, with schema migration verification
- **Cryptography:** `cryptography` (Argon2id, AES-256-GCM), `bip39` (mnemonic generation), `pointycastle` (ASN.1 SPKI parsing)
- **Networking:** `grpc` & `protobuf`, `connectivity_plus`
- **Rich Text & UI:** `flutter_quill`, `table_calendar`, `flex_color_scheme`, `go_router` (`go_router_builder`), `slang` (i18n)

### Backend (`services/core/`)
- **Language:** Go
- **Transport:** `google.golang.org/grpc` (:50051), Gin HTTP health server (:8080), `go-grpc-middleware/v2`
- **Database:** PostgreSQL 18, `jackc/pgx/v5` (`pgxpool`), `sqlc` (type-safe SQL codegen), `pressly/goose/v3` (embedded SQL migrations)
- **Auth & Crypto:** `golang-jwt/jwt/v5` (pinned strictly to `HS256`), `golang.org/x/crypto/bcrypt`
- **Testing:** `testcontainers-go` (real ephemeral PostgreSQL 18 containers for repository and concurrency integration tests)

---

## Getting Started

### Prerequisites
- **Docker & Docker Compose** (for local PostgreSQL and container builds)
- **Go** (matching `services/core/go.mod`)
- **Flutter SDK** (`3.47.5`)
- **Buf CLI** (only required if modifying `.proto` contracts)

### 1. Environment Configuration
Create a `.env` file in the repository root for Docker Compose and local migration targets:

```env
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=ink
DATABASE_URL=postgres://postgres:postgres@db:5432/ink?sslmode=disable
JWT_SECRET_KEY=replace-with-a-strong-256-bit-secret
APP_ENV=development
```

> **Note:** In `development` mode, the backend uses `LogCodeSender` to print 6-digit registration verification codes to stdout. `APP_ENV=production` fails closed on startup until a production email provider is wired to `auth.CodeSender`.

### 2. Start the Backend & Database
Spin up PostgreSQL 18 and the Go core service using Docker Compose (migrations are embedded in the binary and run automatically on boot):

```bash
make build
# Or run Postgres in Docker and the Go server directly on the host:
docker compose up -d db
cd services/core && DATABASE_URL="postgres://postgres:postgres@localhost:5432/ink?sslmode=disable" go run ./cmd/api
```

Useful database Make targets:
```bash
make migrate-status   # Check Goose migration version
make reset-db         # Drop schema and re-run all migrations
```

### 3. Run the Flutter Client
```bash
cd client
flutter pub get
flutter run \
  --dart-define=ENV_NAME=development \
  --dart-define=GRPC_HOST=10.0.2.2 \
  --dart-define=GRPC_PORT=50051
```
*(Use `10.0.2.2` for the Android emulator or `127.0.0.1` for desktop/iOS simulator).*

---

## Testing & Verification Guardrails

This project enforces strict automated checks across both halves of the monorepo (see `.github/workflows/ci.yml`):

### Backend Verification
Runs unit tests (auth hardening, timing floors, rate-limit bucket eviction, graceful shutdown escalation) and `testcontainers-go` integration tests (atomic token rotation, sync batch validation, advisory lock contention):

```bash
cd services/core
go build ./...
go vet ./...
go test ./...
```

### Client Verification
Runs unit/widget tests, Drift schema migration tests, WCAG AA contrast ratio assertions across all 4 color palettes in both light and dark modes, paired visual golden tests, and custom architectural boundary linters:

```bash
cd client
flutter analyze
dart run tool/check_architecture.dart
flutter test
```

### Code Generation Commands
Generated artifacts (`*.g.dart`, `*.freezed.dart`, `*.sql.go`, protobuf stubs) are committed and never hand-edited:

| Layer | Command |
| :--- | :--- |
| **Protobuf (Go + Dart)** | `buf lint && buf generate` |
| **Go SQL (`sqlc`)** | `cd services/core && go tool sqlc generate` |
| **Client Codegen (Riverpod / Freezed / Drift)** | `cd client && dart run build_runner build --delete-conflicting-outputs` |
| **Client Drift Schema Snapshots** | `make schema-dump && make schema-generate` |

---

## Documentation

Detailed architectural and operational documentation lives in [`docs/`](docs/README.md):
- [`docs/architecture.md`](docs/architecture.md) - System boundaries, module layout, and communication model
- [`docs/security.md`](docs/security.md) - Threat model, key hierarchy, KDF/cipher parameters, and auth hardening
- [`docs/backend.md`](docs/backend.md) - Go service internals, sync validation rules, and database schema
- [`docs/client.md`](docs/client.md) - Flutter Clean Architecture layers, sync resolution, and metadata backfill
- [`docs/theming.md`](docs/theming.md) - Design tokens, dark-first palette derivation, and WCAG AA contrast guardrails

---

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPLv3) - see the [LICENSE](LICENSE) file for details.
