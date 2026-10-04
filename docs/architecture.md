# Architecture

## Repository layout

```
ink/
├── proto/                  # Protobuf API contracts (single source of truth)
│   ├── auth/v1/auth.proto      # AuthService: login, register, email verification, tokens
│   ├── vault/v1/vault.proto    # VaultService: encrypted key slot storage
│   └── sync/v1/sync.proto      # SyncService: cursor-based delta sync
├── gen/
│   └── go/                 # Generated Go protobuf/gRPC module (not a service)
├── services/
│   └── core/               # Go backend (the only service)
├── client/                 # Flutter mobile app
│   └── lib/
│       ├── core/           # Shared infrastructure, domain, presentation
│       ├── features/       # Feature-first modules (auth, vault, notes, profile)
│       ├── app/            # App bootstrap, router, Drift database
│       └── i18n/           # slang-generated translations
├── k8s/                    # Kustomize manifests (postgres, core-service, ingress)
├── docker-compose.yaml     # Local dev: backend + postgres 18
├── buf.yaml / buf.gen.yaml # Buf config; generates Go + Dart code
├── go.work                 # Optional local Go workspace (core + gen/go)
└── Makefile                # Dev workflow entry points
```

## System overview

```
┌─────────────────────┐         gRPC :50051 (TLS via ingress)        ┌──────────────────┐
│  Flutter client     │ ◄──────────────────────────────────────────► │  Go core service │
│                     │   auth.v1 / vault.v1 / sync.v1               │                  │
│  - Argon2id KDF     │                                              │  - JWT auth      │
│  - AES-256-GCM      │         HTTP :8080 (/ping, /healthz)          │  - blob storage  │
│  - Master key never │ ◄──────────────────────────────────────────► │  - sync cursors  │
│    leaves device    │                                              │                  │
└─────────────────────┘                                              └────────┬─────────┘
                                                                              │
                                                                     ┌────────▼─────────┐
                                                                     │   PostgreSQL     │
                                                                     │  ciphertext only │
                                                                     └──────────────────┘
```

### Core principle

The backend is an **untrusted storage and coordination layer**:

- Notes/projects are stored as `encrypted_title` / `encrypted_content` byte blobs.
- Vault key slots store only a salt + wrapped master key per unlock method.
- The server can route, version, and sequence data but cannot read it.

## Communication model

1. **Contracts first.** All RPCs are defined in `proto/` and linted/breaking-checked by Buf.
2. **Codegen for both sides.** `buf generate` emits Go stubs into the separate `gen/go` module and Dart stubs into `client/lib/core/infrastructure/grpc/gen`.
3. **Auth.** Access token (JWT HS256, 15 min) is attached by a gRPC interceptor on the server and a client-side auth interceptor; refresh token (random 32 bytes, SHA-256 hashed at rest, 7 day TTL) rotates via `RefreshToken`.
4. **Sync.** A single unary `SyncService.Sync` call exchanges both directions of changes with a monotonic per-user cursor.

## Client architecture

Clean Architecture + DDD, feature-first modularization:

- `features/<name>/domain` — entities (Freezed), repository/service interfaces, failures (sealed classes)
- `features/<name>/data` — remote/local adapters, mappers, and "unified" repositories that merge local and remote data through feature-facing ports
- `features/<name>/presentation` — screens, widgets, Riverpod notifiers, and type-safe routes; presentation consumes feature domain contracts and provider interfaces only
- `app/database` — aggregate `AppDatabase`, generated Drift DAOs/rows, mappers, and concrete feature local adapters
- `app/init.dart` — composition root wiring concrete data implementations and core infrastructure into domain-facing providers

Cross-cutting concerns live in `client/lib/core`: crypto services, session management, the sync engine, gRPC plumbing, secure/shared storage, theme, and design-system primitives.

Auth, notes, vault presentation, shared navigation, shared auth/sync types,
notes domain values, and feature persistence are behind domain/app-level
contracts. CI runs an import checker for presentation, feature-data, and
core-to-feature boundaries. Pull requests use path-aware CI component jobs with
an always-running aggregate gate.

## Backend architecture

Classic Go layering inside `services/core/internal`:

```
cmd/api/main.go → internal/app/app.go (wiring)
                    ├── config       env loading (.env)
                    ├── database     pgx pool + transactor
                    ├── store        sqlc-generated queries
                    ├── auth         users, tokens, verification + gRPC server/middleware
                    ├── vault        key slot CRUD + gRPC server
                    ├── sync         delta sync + gRPC server
                    └── appctx       request context helpers
```

Each domain follows the pattern: `service.go` (business logic) → `postgres_repository.go` (sqlc-backed) → `grpc_server.go` / `grpc_adapter.go` (proto mapping).

Generated Go stubs live in the separate `gen/go` Go module under
`gen/go/pb/*`. `services/core` declares the module through a local `replace`, so
standalone core builds and Docker builds do not depend on an ignored workspace
file. A local `go.work` remains optional for development convenience.

## Deployment

- **Local dev:** `docker compose up` (backend image built from `services/core/Dockerfile`, Postgres 18 with named volume).
- **Kubernetes (experimental/deferred):** `k8s/` Kustomize base — postgres StatefulSet/Service, core-service Deployment with gRPC liveness/readiness probes, ingress routing HTTP and gRPC. This is not a supported deployment path and remains dead last unless Ink adopts Kubernetes.
