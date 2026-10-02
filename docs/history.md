# Current History

The current baseline and the merged PR timeline. Load it only when project
history or design rationale is relevant; earlier rationale lives in `git log`
and the merged PRs.

## Current baseline

As of PR #73:

- Client presentation consumes feature-facing domain/provider contracts; concrete persistence is wired at the app root.
- Drift DAOs, generated mappings, and local adapters live under `app/database`; features depend on local-store ports.
- Notes domain values are independent of Flutter, Quill, and presentation types.
- The client has WCAG AA contrast tests and paired light/dark goldens with bundled Inter fonts.
- gRPC auth uses maintained interceptor middleware while retaining Ink's HS256 and public-route policy.
- The in-memory auth rate limiter has bounded storage; refresh-token rotation is atomic.
- Pull-only sync does not take the user-row write lock; push cursor allocation and writes remain serialized.
- CI is path-filtered with component jobs and an always-running aggregate gate.
- The calendar is a journal of written days, keyed on `createdAt` rather than `dueDate`.
- Note content is parsed as untrusted sync input, split into a pure-Dart domain
  module and the single presentation module that needs the editor library.
- Notes carry locally derived plaintext columns (title/body preview, task flag,
  day-level due date) so lists can filter in SQL without decrypting everything.
- Kubernetes and mail-template polish are explicitly deferred.
- Generated Go protobuf code is isolated in `gen/go`, with explicit backend and Docker wiring.
- The client uses Flutter 3.47.5, the latest resolvable dependency set, a committed `pubspec.lock`, and fail-closed Android release signing.
- The opt-in `scripts/ship-pr.sh` workflow creates, validates, and squash-merges multi-commit PRs non-interactively.

## Recent timeline

| Date | PR | Commit | Summary |
| --- | --- | --- | --- |
| 2026-09-24 | #36 | `883f1a7` | Add gRPC TLS certificate pinning |
| 2026-09-24 | #37 | `24df088` | Cover auth notifier state transitions |
| 2026-09-24 | #38 | `e0685e3` | Cover vault setup presentation |
| 2026-09-24 | #39 | `e4e73f0` | Invert auth and notes providers |
| 2026-09-24 | #40 | `4dc5fc7` | Enforce presentation architecture boundaries |
| 2026-09-24 | #41 | `d6b9c05` | Move auth token types to core domain |
| 2026-09-24 | #42 | `71cbfb1` | Move sync status to core domain |
| 2026-09-24 | #43 | `78f38a2` | Move notes serialization payloads to data |
| 2026-09-24 | #44 | `803a16b` | Remove UI types from notes domain |
| 2026-09-24 | #45 | `1532031` | Isolate feature persistence from Drift |
| 2026-09-24 | #46 | `8ef1b38` | Add theme contrast and golden guardrails |
| 2026-09-24 | #47 | `35b3e38` | Make refresh-token rotation atomic |
| 2026-09-24 | #48 | `0e27735` | Skip unaffected CI component jobs |
| 2026-09-25 | #49 | `8b29203` | Bound rate limiting and adopt gRPC auth middleware |
| 2026-09-25 | #50 | `eacfdf5` | Limit sync cursor locks to push transactions |
| 2026-09-25 | #54 | `3d7a753` | Add opt-in non-interactive PR shipping workflow |
| 2026-09-25 | #51 | `4e16642` | Move generated Go code into the standalone `gen/go` module |
| 2026-09-25 | #53 | `4335c90` | Upgrade to the latest resolvable client dependencies |
| 2026-09-25 | #57 | `fb136c1` | Configure Android production signing for release builds |
| 2026-09-25 | #58 | `08b5df4` | Make the local-first workflow explicit |
| 2026-09-25 | #59 | `a9588d7` | Correct sync acknowledgement and persistence ordering |
| 2026-09-25 | #60 | `9bcb125` | Wait for GitHub check registration before watching CI |
| 2026-09-26 | #61 | `994af5e` | Preserve gRPC failure details and map auth failures per operation |
| 2026-09-26 | #62 | `1d1bbd7` | Handle session load failures without hanging |
| 2026-09-26 | #63 | `6273921` | Reject invalid sync push batches before writing |
| 2026-09-26 | #64 | `936260c` | Drop dead assets, vectorize the logo, gate destructive reset behind `kDebugMode` |
| 2026-09-26 | #65 | `4195794` | Make the calendar a journal of written days |
| 2026-09-26 | #66 | `ce68f9c` | Treat synced note content as untrusted input |
| 2026-09-26 | #67 | `fe07490` | Cache derived note metadata for local filtering |
| 2026-09-26 | #68 | `1410d87` | Remove the Inbox view |
| 2026-09-27 | #69 | `89c6408` | Read the injected clock in the Today filter |
| 2026-09-27 | #70 | `c424a5b` | Make All notes the default landing view |
| 2026-09-27 | #71 | `549c97e` | Cover the notes surface with real state (steps 4 + 5) |
| 2026-09-27 | #72 | `92598f8` | State the encryption thesis on the welcome screen (step 2b) |
| 2026-09-27 | #73 | `4f18a3d` | Full-screen editor route and first-line title (step 6) |
| 2026-09-27 | #73 | `9846954` | Cached previews and a card meta row (step 7) |

`#63` rejects a push batch in full — before the cursor moves — when it contains
duplicate IDs, IDs owned by another account, or note references to projects the
account cannot use. This replaces a silent no-op: the
`WHERE user_id = EXCLUDED.user_id` upsert guard made a cross-user ID match the
conflict, update zero rows, and report success, so the client advanced its
cursor while nothing was stored. Projects created in the same batch count as
valid references, keeping the offline create-project-and-note workflow working
in a single push.

## Working conventions

- Trunk-based development with one focused branch and one owner-managed squash merge per task.
- Conventional Commits with side-specific scopes.
- Generated artifacts are regenerated, not hand-edited.
- Failure mapping lives in the data layer: `DataSourceRunner` converts transport
  statuses into core failures, feature mappers convert core failures into domain
  failures, and presentation only reads domain failures plus localized strings.
- Error-message matching is a temporary contract with the current backend; it is
  replaced by structured gRPC error details when the API contract grows them.
- Reject a write batch in full rather than partially applying it. Partial
  application leaves the client cursor and the stored rows permanently
  disagreeing, which no later repair can fix.
- Validate push input server-side before mutating state, and return specific
  gRPC codes for client-fault failures instead of `Internal`.
- Validation must treat entities created in the same batch as already present;
  checking the database alone breaks the primary offline workflow.
- Bound anything derived from client input that reaches an error message or a
  log line, so a hostile batch cannot inflate either.
- Integration tests run against a real container; a fake repository cannot catch
  a wrong query or a constraint that does not exist.
- The complete agent/owner handoff is defined in [workflow.md](workflow.md).
