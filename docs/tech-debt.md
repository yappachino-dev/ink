# Active Backlog

This is the small actionable queue for the next implementation tasks. Completed findings live in `git log` and the merged PRs.

## Priority backlog

1. **Repair client error contracts**
   - Make session persistence awaitable and define rollback/error behavior.

2. **Harden sync data integrity**
   - Reject duplicate IDs and cross-user notebook references.
   - Surface ownership conflicts instead of silently accepting a no-op upsert.
   - Return vault local-persistence failures and define vault conflict behavior.

3. **Make client architecture and visual tests deterministic**
   - Remove feature-to-app navigation imports and enforce the rule in the architecture checker.
   - Inject dates into the calendar golden test instead of using the wall clock.
   - Expand presentation tests around the resulting user-visible error behavior.

4. **Close backend lifecycle and security gaps**
   - Own and close the pgx pool, stop readiness polling, and unify shutdown paths.
   - Enforce exact HS256, SMTP timeouts/input validation, and timing-equivalent login.

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
| `__all__` / `__today__` as pseudo-notebook ids (pending) | See the refactor row; still open. |
| Calendar as a peer tab vs a Notes view mode | Decide whether the month grid is worth a second top-level destination. Its journal list and notebook filter are both duplicated by Notes; only the date index is not. |
| Shared vs per-screen notebook filter | Only meaningful while Calendar is a separate tab. It disappears if the journal moves into Notes. |
| `__all__` / `__today__` as pseudo-notebook ids (refactor) | Refactor that makes the two pseudo-ids first-class. `__all__` should be `null`; `__today__` is a lens, not a notebook. Unblocks the two rows above. |
| Leftover "task" language on a journal screen | Calendar's FAB is still `_openAddTaskSheet`. Same family as the removed `hasUncompletedTasks`. |
| Unused `CalendarViewMode` granularity | `month`/`twoWeeks`/`week` select calendar chrome; only `day` is meaningful for a journal. |
| Very Good Analysis 11 async-style migration | Remove the scoped `async_return_with_no_await` suppression after the Future adapters are migrated. |
| SMTP library/template polish | Production deliverability or localization requirements justify it. |
| Kubernetes hardening | Ink adopts Kubernetes as a supported deployment target. |

## Verification baseline

- Backend: `go build ./...`, `go vet ./...`, and `go test ./...`; PostgreSQL integration tests require Docker.
- Client: `flutter analyze`, `flutter test`, and the architecture checker.
- Protobuf: `buf lint` and breaking checks against `main`.

For current design details, use the reference documents linked from [README.md](README.md). Load archived documents only when historical rationale is needed.
