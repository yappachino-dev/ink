# Flutter Client (`client/`)

Mobile app (Android target present) implementing the E2EE notes experience.
Package name: `ink`, SDK `^3.10.0`, linting via `very_good_analysis`.

## Tech stack

| Concern | Choice |
| --- | --- |
| State management / DI | Riverpod 3 with codegen (`@riverpod` / `@Riverpod(keepAlive: true)`) |
| Models | Freezed (sealed classes) + json_serializable |
| Local DB | Drift over SQLite (`sqlite3_flutter_libs`), background native connection, custom DAOs |
| Networking | gRPC (`grpc` + protobuf), `connectivity_plus` for network state; all RPCs carry a `networkSecondsTimeout` deadline |
| Navigation | go_router with type-safe route builders (`go_router_builder`), per-feature routes and shell navigators |
| Editor | flutter_quill (+ extensions) — content stored as Quill Delta JSON inside the encrypted payload |
| i18n | slang (`i18n/strings.g.dart`, locale notifier) |
| Theming | flex_color_scheme, bundled Inter assets, semantic `InkColors` extension, accessible palette roles, light/dark via `ThemeNotifier` |
| Crypto | `cryptography` package (Argon2id, AES-GCM), bip39 for recovery phrases |
| Result type | fpdart-style `Result<Success, Failure>` pattern in `core/domain/result.dart` |

## Directory map

```
lib/
├── main.dart                 # bootstrap: prefs init → ProviderScope → translations → MaterialApp.router
├── app/
│   ├── init.dart             # global settings initialization
│   ├── database/             # Drift AppDatabase (KeySlots, Notes, NoteConflicts, Projects tables)
│   ├── navigation/           # root router, auth shell navigator
│   └── presentation/         # splash & welcome screens
├── core/
│   ├── config/               # app/env/user config providers
│   ├── domain/               # CoreFailure hierarchy, Result type
│   ├── infrastructure/
│   │   ├── crypto/           # RandomService, Argon2Service, AesGcmService, exceptions
│   │   ├── grpc/             # channel/connection providers, gen stubs, auth interceptor
│   │   ├── storage/          # secure storage, shared prefs
│   │   ├── network/          # connectivity state provider
│   │   ├── auth/             # JWT decoding, token refresher (auto-refresh)
│   │   └── serialization/    # JSON helpers
│   ├── services/
│   │   ├── session/          # SessionManager (auth + crypto session), repository, states
│   │   └── sync/             # SyncOrchestrator, SyncClient, Syncable contract, cursor storage
│   └── presentation/         # theme, design tokens (app_sizes, app_animations), shared widgets
├── features/
│   ├── auth/                 # login/register/email verification; unified repo over gRPC
│   ├── vault/                # key slots, setup & unlock flows (PIN/pattern/recovery)
│   ├── notes/                # notes & projects: encrypted CRUD, sync engines, calendar/home UI
  │   └── profile/              # settings + account actions (appearance, registration, data reset)
└── i18n/                     # slang-generated strings
```

## Key flows

### Session startup (`core/services/session`)

`SessionManager` is a Riverpod `Notifier` whose `build()` must return
synchronously, so persisted tokens are read in a deferred microtask. The load
is deliberately non-throwing: a secure-storage failure marks the session loaded
with `loadError` set rather than leaving the app on splash forever.

Both token reads must succeed before either token is published. A partial read
(access token read, then a failing refresh-token read) nulls both tokens
alongside `loadError`, because `hasAccessToken` reporting a session the backend
cannot accept is worse than reporting none.

Startup gating is owned by `VaultNotifier`, which maps session state to
`VaultState`:

| Session state | Vault state | Effect |
| --- | --- | --- |
| `!isLoaded` | `VaultInitializing` | router forces `/splash` |
| `isLoaded && hasLoadError` | `VaultSessionLoadFailed` | router holds `/splash`; splash shows a retry button |
| `isLoaded && hasMasterKey` | `VaultUnlocked` | proceed to notes |
| otherwise | see `_checkInitalizationState` | welcome / setup / unlock / error |

A failed read deliberately does **not** fall through to welcome or auth: that
would treat a transient keystore error as "logged out" and discard a session
that is still valid. `SessionManager.retrySessionLoad` re-reads storage; the
splash retry button calls it. The retry is a no-op unless the session is loaded
*and* carries a `loadError`, so a double tap cannot start two concurrent reads
against secure storage. The only consumer of the read result is the vault
gating path, so `isSessionLoaded`/`isAccessTokenPresent`/`isMasterKeyPresent`
selectors are currently unused.

Persistence is awaited at every call site: `setAuthTokens` and the token clears
return `Future<void>`, the gRPC metadata provider awaits the post-refresh write,
and `VaultRecovery.reset` awaits both clears before returning.

### Vault setup (`features/vault`)

`VaultSetupNotifier` orchestrates a multi-screen flow:
setup method → PIN or pattern entry → 12-word BIP-39 recovery phrase
generation/display → verification of 3 random word indices → commit. The
phrase is generated from 128 bits of `RandomService` entropy. Commit calls
`SecureVaultService.intializeNewVault`, which generates the master key, wraps it
once per secret (PIN, pattern, recovery phrase), saves all slots locally +
remotely, and stores the master key in the session. See [security.md](security.md).

### Unlock

`VaultUnlockNotifier` → `SecureVaultService.unlock(type, secret)` derives the KEK,
unwraps the master key, and promotes the session to "unlocked". Wrong secrets
surface as `InvalidSecret` (GCM authentication failure maps through
`CryptoDecryptionException`).

### Encryption pipeline (`features/notes/data/secure_notes_service.dart`)

Every note/project mutation:

1. Reads `masterKey` from `CryptoSession` (throws if vault locked).
2. Builds a `NotePayload` (Quill delta + due date/time, priority, reminder,
   completion) and JSON-encodes it.
3. Encrypts title and payload with AES-256-GCM.
4. Persists ciphertext through `UnifiedNotesRepository` (Drift).
5. After successful persistence, fires-and-forgets `SyncOrchestrator.performSync()`.
6. Decrypts back for the returned domain entity.

Reading is symmetric: DAO returns ciphertext → decrypt → map Freezed entities.

### Parsing note content

The Quill delta is the note body's domain representation, and it arrives
**untrusted**. The server is zero-knowledge and never inspects a payload, so
whatever a peer client wrote reaches `Note.content` verbatim. Two Quill rules
make that dangerous:

- `loadDocument` throws `ArgumentError` on an empty delta
- it *asserts* the final insert op ends with `\n` (fires in debug **and**
  profile; mis-renders the final block in release)

Both are reachable from a plain sync. Because the parse happened while building
cards, one bad note took down every list that rendered it.

The concern is split in two, on the axis of what actually needs the editor
library. Reading and repairing the delta is pure Dart over JSON, so it lives in
the domain; constructing a widget's document is not the domain's business, so it
does not.

**`features/notes/domain/quill_delta.dart`** — pure Dart, imports no editor:

- `usableNoteOps(content)` — yields the operations Quill can load and skips the
  rest. Skipping rather than condemning is deliberate: collapsing the whole
  document would open a 50-paragraph note as an empty editor, where one save
  overwrites all of it.
- `normalizeNoteDelta(content)` — repairs a delta for the editor: substitutes
  the empty document only when *no* operation is usable, and appends the newline
  insert Quill requires. Copies every op entry so per-op `attributes` survive.
- `notePreviewText(content, {maxLength = 300})` — capped display text read
  straight from the ops, so a long note costs a string scan rather than a full
  AST of leaf, block, and line nodes per card. Never throws.
- `hasNoteContent(content)` — the uncapped emptiness question. Exists because a
  capped preview cannot answer it: a note may open with more whitespace than the
  cap, and would preview as blank.
- `emptyNoteDelta` — the canonical empty delta.

**`features/notes/presentation/quill_document.dart`** — the only
`flutter_quill` import in the feature:

- `parseQuillDocument(content)` — never throws; builds a `Document` from a
  normalized delta, falling back to empty as a last resort.

### Two rules that follow from this

1. **A preview is not the note.** `notePreviewText` is lossy by design. Never
   use it to decide whether a note changed — the details sheet compares
   `content` with `listEquals` for exactly this reason. (It previously compared
   subtitles, which would have missed any edit past the cap *and* any
   formatting-only change, since both yield identical text.)
2. **Writes need no guard.** Our editor writes `toDelta().toJson()`, which is
   always well-formed, so bad content can only arrive by sync. Reads are the
   untrusted boundary; write-side normalization would be guarding an impossible
   path.

Unreadable bytes are left untouched in storage; saving from the editor rewrites
the body as valid content. That is the only recovery route for a note that was
already partly unreadable — see the open item on warning the user before an
overwrite.

This does **not** remove the per-card read; it makes it a capped string scan
instead of an AST build. Removing it entirely is step 3a's job, via a stored
`bodyPreview` column — and that column inherits rule 1 above: it is a lossy
display value, never a source of truth for the note body.

### Built-in lenses

`domain/constants.dart` holds two sentinels, `allProjectsId` and
`todayProjectId`. They are lens ids, not project rows, so nothing in the database
carries them and there is nothing to rename or delete.

A third sentinel, `inboxProjectId`, was removed in #68. It was never an inbox:
its filter was `dueDate != null || dueTime != null`, which is "has a deadline" —
already answered by Today. Its long-press menu existed only to open
`CreateProjectSheet(colorOnly: true)`, a mode that dereferenced a null
`initialProject` and so crashed on confirm. Removing Inbox left `colorOnly` with
no callers, and the mode was deleted with it.

### View state

The notes surface renders one `NotesViewState`: loading, empty, empty-by-filter,
error, or content. `notesViewStateProvider` derives it; `NotesView` switches on
it. Do not reintroduce a `isNotEmpty` ternary — that is what made a failed load
and an empty vault look identical.

Two traps, both of which cost real debugging time:

- A failed load is an `AsyncLoading` **carrying an error**. Check `hasError`
  before `when`, or `when(loading: ...)` matches and the skeleton never stops.
- Unreferenced async providers are auto-disposed mid-build. A one-shot
  `container.read(...)` is not enough to observe a settled state; hold a
  subscription, or the provider reports loading forever.

Offline is deliberately **not** part of the sealed set: it composes with
content instead of replacing it, so it is a banner. The notes are on disk.

Key any `AnimatedSwitcher` on `NotesViewState.switcherKey`, never the instance.
`NotesViewState` has no `==`, and `projectNotesProvider` returns a fresh list on
every rebuild, so an identity key tears the list down and resets scroll on every
edit and every sync. Goldens cannot catch this: they render one frame, where
"rebuilt" and "unchanged" look identical.

### Reaching infrastructure from presentation

`check_architecture.dart` forbids `features/*/presentation/` (in `lib/` *and*
`test/`) from importing `core/infrastructure/`, `core/services/`, `app/database/`,
or another feature's presentation layer. App-wide state that presentation needs
— connectivity, sync activity — is adapted in
`core/presentation/providers/status_providers.dart` and consumed as a plain
value. `core/` may not import `features/`, which is why a note-derived
indicator cannot live there.

### Lenses

`SelectedProjectId` is one provider serving two roles: on Home it is the
notebook lens, on the calendar it is the notebook filter. `allProjectsId` means
"everything" in both. `SelectedProjectId` is not persisted, so it resets to
`allProjectsId` — the landing view — on every launch.

`isContentForwardLens(id)` (in `domain/constants.dart`) is the single definition
of the content-forward/task-forward split. Content-forward (All notes) renders
flat: no completion checkbox, no completed section, no priority flag.
Task-forward (Today, a notebook) keeps task-shaped rows. Use the predicate
rather than comparing against `allProjectsId` inline; the raw comparison
appeared in eight places and is what made the two roles easy to conflate.

Do not wrap a control in `if (isFilterActive)`. An affordance that disappears
when nothing is selected is unreachable, and doing exactly that to the
calendar's notebook filter sat latent until All notes became the default. `ProjectItem.onLongPress` is optional and nullable, which
it always was in type; it only looked required because Inbox was the sole caller
passing `null`.

### The injected clock

`currentDateProvider` (`notifiers/ui_state.dart`) is the single seam for "what
day is it" in presentation. It is a plain `Provider<DateTime>` defaulting to
`DateTime.now()`, and it exists to be overridden in tests.

Anything that decides *what a view contains* must watch it rather than call
`DateTime.now()`. The Today filter in `projectNotes` did not, which made the
view wall-clock dependent and left the Home golden rendering an empty list on any
day that did not match the fixture's due date — it passed by accident of when CI
ran.

The rule is not yet enforced mechanically. Three call sites in the editor
(`note_form_notifier.initWithExisting`, and `note_editor_sheet` twice) still read
`DateTime.now()` directly; they are input defaults and a picker window rather
than view computation, so they belong to F-17 and to the editor rework. A lint
that banned `DateTime.now()` under `presentation/` would close the gap for good,
but it needs the remaining sites resolved first.

### Derived note metadata (`features/notes/domain/entities/note_metadata.dart`)

Four plaintext columns on `notes`, all locally derived and **never synced**:
`title_preview`, `body_preview`, `has_uncompleted_tasks`, `due_date_day`, plus
`metadata_version` to tag staleness.

They exist because the server is zero-knowledge and cannot sort or filter on
anything inside a note, and because on the client the same fields live inside
the encrypted payload rather than in a column. Before this, every list view
called `getAllNotes()` and decrypted the whole database (F-03/F-03b).

**They are a cache, never a source of truth.** `body_preview` is capped at 300
characters and lossy. Nothing that needs the real note may read it in place of
the delta — the details sheet compares `content` with `listEquals` for exactly
this reason.

**Derivation, `NoteMetadataDerivation.derive({title, content, dueDate})`:**

- `titlePreview` — the title, trimmed
- `bodyPreview` — `notePreviewText`, capped
- `hasUncompletedTasks` — any op whose `attributes.list` is `'unchecked'`
- `dueDateDay` — `DateTime(y, m, d)` from the stored value's own fields, never
  `.toLocal()`-ed, matching the journal calendar's rule

**Three write paths, all covered:**

| Path | Where metadata is derived |
| --- | --- |
| Local create/save | `Note.toEncrypted`, where plaintext and ciphertext coexist |
| Remote apply (sync) | `RemoteNoteMetadataEnricher`, in front of the repository |
| Rows predating the columns | `_backfillMetadata`, lazily inside `getAllNotes()` |

The sync path is the awkward one: it carries only `EncryptedNote`, so there is
no plaintext moment. `RemoteNoteMetadataEnricher` reads the key once per batch
and fills the cache before handing off. It sits **in front of** the repository
rather than inside the local store, because `app/database` has no key and must
not be handed one to fill a cache. A note that cannot be decrypted still lands,
with empty metadata — dropping it would make it vanish from the user's view.

`NoteDecryptor` was extracted from `SecureNotesService` so the read path and the
sync path cannot drift on how a `NotePayload` maps back onto a note.

**Backfill.** Rows migrate in with the columns empty and `metadata_version` 0.
`getAllNotes()` checks for stale rows and repairs them before returning. It
reuses the rows already loaded for that read, so the only extra cost is one
indexed lookup, and it is a no-op once every row is current. Unreadable rows are
marked current too, or every later read would retry them forever.

**`writeNoteMetadata` updates only the derived columns** — never ciphertext,
versions, or `sync_status`. A repair that bumped `localVersion` or flipped
`sync_status` would queue every repaired note for push, turning a cache fix into
a sync storm. Pinned by a DAO test.

**Known limitation.** `hasUncompletedTasks` is always false for current data:
the editor has no checklist support, so no body can yet contain an unchecked
list item. The column follows the D-1 decision and becomes meaningful when the
editor supports checklists. It must not be read as `!isCompleted`, which is a
different question and is not stored.

**A locked vault does not block a sync.** `CryptoSession` exposes `hasKey`
alongside `masterKey`, which throws when locked. The enricher asks `hasKey`
rather than probing and catching — using an exception to ask a yes/no question
turns ordinary control flow into error handling. When locked it still stores the
ciphertext, tagged with `deferredNoteMetadata` (version 0), and
`_backfillMetadata` derives the columns on the first read after unlock.

This matters because throwing would stall the *entire* sync, projects and the
cursor included, for as long as the vault stayed closed. The orchestrator
catches `on Object`, so nothing crashes — the batch is simply never applied, and
the cursor is not advanced.

Note the trap: `const NoteMetadata()` carries the **current** version, so
writing that for a deferred note would mark it derived and the backfill would
skip it forever, leaving a permanently blank preview. Use the
`deferredNoteMetadata` constant, never a bare `version: 0` at a call site.

Two failure modes, deliberately distinct:

| Situation | Metadata written | Backfill |
| --- | --- | --- |
| Vault locked, ciphertext valid | `deferredNoteMetadata` (stale) | repairs after unlock |
| Vault unlocked, content undecryptable | current, empty | not retried — it could never succeed |

**Indexing.** `notes_metadata_version` exists because
`findStaleMetadataNoteIds` scans the table on every notes read. `dueDateDay` is
deliberately **not** indexed: no query reads it yet, and an index on a column
nothing filters only costs write amplification and storage. Add it with the
Today/Overdue work that first filters on it.

**Migration.** `schemaVersion` 2 → 3 (adds the five columns and the index). Follow the documented checklist in
`test/migrations/migration_test.dart`: dump the schema, generate the test
helper, and add a `vN-1 -> vN` test. Note that the real `MigrationStrategy`
always migrates to the *current* version, so older tests validate against the
newest schema.

### Sync engine (`core/services/sync/`)

- `Syncable` is the pluggable per-entity contract (`collectLocalChanges`,
  `acknowledgePush`, `applyRemoteChanges`, sync priority). Implementations:
  `notes_sync_delegate/engine` and `projects_sync_delegate/engine`.
- `registeredSyncablesProvider` must be overridden at startup with the concrete list.
- `SyncOrchestrator.performSync()` guards against concurrent runs, sorts delegates
  by priority, pushes local changes, acknowledges only the request's changes,
  applies the full response delta, then persists `nextCursor`. States:
  `SyncIdle/Syncing/Success/Error`.
- Each row carries `syncStatus` enum + `localVersion` / `lastSyncedVersion`.
- **Deletions are tombstoned**: `deleteNote` / `deleteProject` mark the row
  `SyncStatus.deleted` (+ `deletedAt`) instead of hard-deleting, so the deletion
  is queued for push; the row is physically removed when the push is acked
  (`acknowledgePushed`). List reads backing the UI (`getAllNotes` / `getAll`)
  exclude tombstones; `getByIds` keeps them for conflict detection.
- Incoming deltas are resolved by the shared pure function
  `resolveSyncDelta()` (`notes/data/sync_delta_resolution.dart`) used for **both**
  notes and projects: missing rows are created (tombstones skipped), clean rows
  follow incoming versions, and any concurrent change resolves to `conflict`
  (local row kept, marked conflicted; server copy stored in the `NoteConflicts` /
  `ProjectConflicts` tables). No wall-clock LWW anywhere.
- Application is batched: one `getByIds` fetch per entity, decisions computed in
  memory, then all writes (upserts / deletes / conflicts) run in a single drift
  batch (`applyRemoteDeltas`) — one transaction instead of N+1.

### Logout

`authService.logout()` revokes the refresh token server-side (best-effort —
local credentials are cleared even when the call fails), zeroes the vault
master key via `clearMasterKey()` and removes stored tokens.

### Vault unlock throttling

Failed unlock attempts (PIN / pattern / recovery phrase) trigger a progressive
lockout: 2s, 4s, 8s … capped at 5 minutes (`unlockLockoutFor`). While locked,
attempts are rejected before reaching the vault and the unlock screens show a
ticking countdown instead of the submit button.

### Token lifecycle

`TokenRefresher` handles access-token expiry transparently; refresh token is
rotated server-side on every use and persisted in secure storage.

## Generated code

`.g.dart`, `.freezed.dart`, and grpc `gen/` files are produced by build_runner /
buf — never edit by hand (see [development.md](development.md)).

## Known quality items

See [tech-debt.md](tech-debt.md) for the active project backlog and
[theming.md](theming.md) for implemented theme guardrails. Current client
follow-up is broader presentation coverage; focused auth and vault setup
notifier tests now cover verification failures, duplicate submission, phrase
generation, secret selection, commit guards, and recovery verification. Theme
contrast tests cover every palette in both brightnesses, and paired light/dark
goldens cover home, calendar, editor, and vault setup using the bundled Inter font. Broad design-token,
failure-mapping, enum-default, scaffold, and master-key items have been
completed.
