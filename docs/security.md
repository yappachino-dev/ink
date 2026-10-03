# Security & E2EE Design

Ink's threat model treats the server as untrusted: it stores and relays ciphertext
but never possesses keys or plaintext. All cryptography lives in the Flutter
client (`client/lib/core/infrastructure/crypto/`).

## Key hierarchy

```
PIN / Pattern / Recovery phrase          (user secrets, never sent anywhere)
        │  Argon2id (salt, 32-byte KEK)      [Argon2Service]
        ▼
KEK (Key Encryption Key)
        │  AES-256-GCM                       [AesGcmService]
        ▼
Wrapped Master Key  ── stored server-side as opaque blob in key slot
        │  unwrap locally after successful unlock
        ▼
Master Key (256-bit random, generated on device at vault creation)
        │  AES-256-GCM per field
        ▼
Encrypted note titles / note content / project content  ── synced to server
```

## Vault lifecycle

Implemented by `SecureVaultService` (`features/vault/data/secure_vault_service.dart`):

1. **Setup** — a fresh 32-byte master key is generated with a CSPRNG
   (`RandomService`). The mandatory recovery phrase is a 12-word BIP-39
   mnemonic generated from 128 bits of that CSPRNG entropy. For every unlock
   method chosen during setup (PIN, pattern, and the recovery phrase):
   - a random 16-byte salt is generated,
   - the secret is NFC-normalized, UTF-8 encoded, and run through Argon2id → KEK,
   - the master key is AES-GCM encrypted with the KEK → `wrapped_master_key`.
2. **Storage** — key slots `(type, salt, wrapped_master_key, updated_at)` are
   persisted locally (Drift `key_slots` table) and mirrored to the server via
   `VaultService.SaveKeySlots`. The server sees only salt + wrapped key.
3. **Unlock** — the user's secret derives the KEK with the slot's salt; a
   successful AES-GCM authentication reveals the master key, which is placed
   into the in-memory session. A background key-slot re-sync follows.
4. **Recovery** — the recovery phrase is a full alternative unlock method; setup
   flow verifies it by asking for 3 random word indices. The phrase is never
   sent to the server directly; it is used only as a local secret for deriving
   and unwrapping the vault key.

### Parameters

| Parameter | Value |
| --- | --- |
| KDF | Argon2id, hashLength 32 |
| Argon2 memory / iterations | release: 64 MiB × 3; debug: 1 MiB × 1 (fast dev cycles) |
| Salt | 16 random bytes per slot |
| Master key | 32 random bytes |
| Content cipher | AES-256-GCM (12-byte nonce, 16-byte MAC, concatenated format) |
| PIN length | exactly 4 digits (`maxPinLength`) |
| Pattern length | ≥ 4 nodes (`minPatternLength`) |
| Recovery phrase | BIP-39, 12 words |

Argon2id derivation runs in a background isolate (`compute`) to keep the UI responsive.

## Session management

`SessionManager` (`core/services/session/`) is the single keeper of sensitive
runtime state, exposed through three narrow interfaces:

- `AuthSession` — access/refresh token accessors (tokens persisted via
  `flutter_secure_storage`)
- `CryptoSession` — `masterKey` accessor; throws `SessionLockedException`
  when the vault is locked; returns a defensive clone so consumers can never
  retain or mutate the live key buffer
- `SessionController` — set/clear operations; clearing the master key **zeroes
  the byte array in place** before nulling the reference

Derived read-only providers (`isMasterKeyPresent`, `isAccessTokenPresent`,
`isSessionLoaded`) drive routing between locked/unlocked/authenticated app areas.

### Refresh-token reuse detection

`AuthService.Refresh` revokes every session of a user when a refresh token is
replayed: either the token is already revoked, or an atomic rotate lost a race
and matched zero rows. Both indicate the token leaked, so the victim's other
sessions are killed rather than only the one that was presented.

That revocation runs on `context.WithoutCancel` with a 2s timeout, **not** on
the request context. It executes after the request has already been answered -
`ByHash` returned, or `Rotate` reported the lost race - so the client may
already be gone, and a cancelled context would abort the UPDATE and leave the
stolen family alive. A mobile client on a flaky network dropping mid-refresh is
the likeliest trigger, and it is also the moment a replay is most plausible.

A revocation failure is logged via `slog.Error` and **not** returned. The caller
is denied either way, since the token they presented is already revoked, so
surfacing an infrastructure error would tell a caller holding a stolen
credential more about our internals without protecting anything. The trade-off
is deliberate: ops visibility instead of client visibility.

Both properties are pinned by tests in `internal/auth/service_test.go` -
`TestRefresh_ReuseRevokesAllSessionsAfterClientDisconnect` and
`TestRefresh_ReuseRevokeFailureStillDenies`. The test fake's
`RevokeAllByUserID` respects context cancellation and can be made to fail,
because while it returned nil unconditionally the discarded error could not
reproduce and the bug was invisible.

## Data-at-rest encryption

Notes and projects are encrypted field-by-field before touching Drift:

- Note title → encrypted string.
- Note body → Quill Delta JSON serialized into `NotePayload` (due date/time,
  priority, reminder, completion state all live inside the encrypted payload),
  then encrypted. Metadata such as due dates never appears in plaintext.
- Project name/content → encrypted blob.

The server-side schema has no plaintext columns for any of this — only
`BYTEA` blobs, versions, and timestamps.

## Transport & API security

- gRPC with JWT bearer auth enforced by the standard
  `go-grpc-middleware/v2` auth interceptor; Ink's `AuthFunc` pins HS256,
  validates the token, and injects the user ID. Auth RPCs (`Login`, `Register`,
  `VerifyEmail`, `RefreshToken`, `Logout`) are exempt.
- Access tokens: HS256 JWT, 15-minute TTL, `user_id` claim.
- Refresh tokens: 32 random bytes, base64url; only the SHA-256 hash is stored
  server-side; 7-day TTL; revocation supported (single token and all-sessions).
- Passwords hashed with bcrypt (`auth/password.go`); email verification codes
  stored as hashes too.
- Public auth rate limits use a bounded in-memory fixed-window limiter; shared
  multi-replica enforcement remains a deployment concern.
- The client gRPC channel uses TLS in release and every non-development
  environment. Local debug builds may opt into plaintext only when
  `ENV_NAME=development`. Production can additionally pin the certificate's
  SubjectPublicKeyInfo (SPKI) with one or more
  `GRPC_CERT_PIN=sha256/<base64-sha256>` values. Pinned connections first run
  normal chain/hostname validation, then enforce the SPKI pin; valid
  certificates from the system trust store are not allowed to bypass pinning.

## Sync security

Sync payloads contain only IDs, ciphertext blobs, versions, and timestamps —
nothing to leak beyond traffic analysis. Conflict handling is based on version
counters rather than wall clocks; concurrent remote/local changes preserve the
local row and save the rejected server copy in the client's conflict table, so
no user data is silently destroyed.

## Implemented hardening guarantees

Implemented and verified:
- JWT signing algorithm is pinned to HS256 in `grpc_middleware.go`, not to the
  HMAC family: HS384 and HS512 verify against the same secret, so accepting the
  family makes algorithm downgrade a one-flag change.
- `Login` spends the bcrypt cost even when the account does not exist, by
  verifying against a dummy hash, so response time does not enumerate
  registered addresses.
- `Register` rejects malformed addresses before anything downstream, including
  the verification-code path. `net/mail` alone is not enough: it accepts
  `a@b` and `Bob <a@b.com>`, so the bare-address and dotted-domain checks are
  load-bearing. The dot must be in the domain - checking the whole string lets
  `user.name@b` pass on the strength of the local part.
- Refresh-token reuse now revokes all of the user's sessions (`AuthService.Refresh`).
- Refresh rotation atomically revokes the presented active token and inserts its replacement, so a failed replacement cannot strand the current session.
- `SaveKeySlots` persists all slots atomically via the transactor.
- `SessionManager.masterKey` returns an immutable clone of the key buffer.
- `JWT_SECRET_KEY` is required non-empty at config load.

Verification-code delivery uses a pluggable `auth.CodeSender`:
`APP_ENV=production` sends real SMTP email, while development logs the code for
manual testing (**codes are bearer secrets — never run production with the log
sender**). Authentication RPCs are protected by per-peer-IP fixed-window limits,
and verification also has a per-email cap and attempt lockout.

Certificate pins must be rotated before the pinned key expires. Pass multiple
comma-separated pins during an overlap window, then remove the retired pin.
Malformed pin configuration is logged and fails closed at connection time; it
does not throw while the Riverpod provider is being created.

Kubernetes is an experimental deployment path rather than a current product
priority; it remains deferred until Ink adopts Kubernetes as a supported
deployment target.
