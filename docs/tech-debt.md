# Active Backlog

This is the small actionable queue for the next implementation tasks. Completed findings live in `git log` and the merged PRs.

## Priority backlog

1. **Repair client error contracts**
   - Make session persistence awaitable and define rollback/error behavior.
     _Lens selection persistence is done; token persistence is not._

2. **Define vault key-slot conflict behavior**
   - `UpsertKeySlots` resolves collisions with `ON CONFLICT (user_id, key_type)
     DO UPDATE`, so a push silently overwrites the other device's slot.
     Notebook and note pushes already reject these cases; vault does not.

3. **Enforce the client architecture rule**
   - No `package:ink/app/` import exists under `client/lib/features/`, but
     `check_architecture.dart` only forbids `app/database/`, so the rest of the
     layer can creep back in without failing the check.

4. **Ship a production verification-code sender**
   - No `CodeSender` implementation ships. `APP_ENV=production` refuses to
     start, so this blocks deployment rather than degrading it.
   - Needs request-context propagation, explicit timeouts, and structured errors.

5. **Improve repository onboarding**
   - Add a tracked root README with prerequisites, architecture, setup, and verification commands.
   - Replace template package metadata and define dependency/security update checks.

## Not scheduled

| Item | Trigger to revisit |
| --- | --- |
| Shared/distributed auth rate limiting | The backend is deployed with multiple replicas or multiple enforcing gateways. |
| Client schema migration tooling | A released client schema requires an upgrade path. |
| Calendar clock/provider seam | Re-evaluate during a deliberate Riverpod upgrade or when introducing a shared clock abstraction. |
| PointyCastle 4 / `bip39` constraint | Revisit when `bip39` publishes a PointyCastle 4-compatible release. |
| Unused `CalendarViewMode` granularity | `month`/`twoWeeks`/`week` set the grid format; `day` swaps the grid for `DayHeader`, which has its own previous/next steppers. All four are reachable and distinct. Reconsider only if a mode is ever hidden from the picker. |
| Very Good Analysis 11 async-style migration | Remove the scoped `async_return_with_no_await` suppression after the Future adapters are migrated. |
| Kubernetes hardening | Ink adopts Kubernetes as a supported deployment target. |

## Verification baseline

- Backend: `go build ./...`, `go vet ./...`, and `go test ./...`; PostgreSQL integration tests require Docker.
- Client: `flutter analyze`, `flutter test`, and the architecture checker.
- Protobuf: `buf lint` and breaking checks against `main`.

For current design details, use the reference documents linked from [README.md](README.md). Load archived documents only when historical rationale is needed.
