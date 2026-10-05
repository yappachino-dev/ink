# Active Backlog

This is the small actionable queue for the next implementation tasks. Completed findings live in `git log` and the merged PRs.

## Priority backlog

1. **Repair client error contracts**
   - Make session persistence awaitable and define rollback/error behavior.
     _Lens selection persistence is done; token persistence is not._

2. **Enforce the client architecture rule**
   - No `package:ink/app/` import exists under `client/lib/features/`, but
     `check_architecture.dart` only forbids `app/database/`, so the rest of the
     layer can creep back in without failing the check.

3. **Ship a production verification-code sender**
   - No `CodeSender` implementation ships. `APP_ENV=production` refuses to
     start, so this blocks deployment rather than degrading it.
   - Needs request-context propagation, explicit timeouts, and structured errors.

4. **Back the profile actions with real endpoints**
   - Change name, change password and change encryption now refuse explicitly
     instead of swallowing the tap, but there is no endpoint for any of them.
   - "Delete all data" is device-scoped. There is no delete-account RPC, so a
     synced copy survives it. The wording says so; the endpoint does not exist.

5. **Unify the onboarding chrome**
   - `SetupProgress` renders as body content below `BackAppBar`; it belongs in
     the app bar so the top of the flow reads as one unit. `BackAppBar` is
     already a `PreferredSizeWidget` but hardcodes `kToolbarHeight`.
   - Its segment `AnimatedContainer` never interpolates. Each step is a separate
     route, so a fresh widget is built at its final value and there is no prior
     state to animate from. `AppDurations.slow` is documented as "progress
     reveals" and currently serves nothing.
   - Relocating the bar alone moves inert chrome. Advancing it needs one
     `SetupProgress` kept alive across steps, or a shared step value.

6. **Close the raw spacing default**
   - `SpacedScaffold.spacing` defaults to `24.0` rather than `AppSpacing`.
     `verify_spacing_tokens.dart` is diff-based and does not catch defaults.
     `SpacedScaffold` also cannot host a scrolling child: its
     `SliverFillRemaining` cannot measure a viewport.

7. **Improve repository onboarding**
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
