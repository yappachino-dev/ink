-- name: UpsertKeySlots :batchexec
INSERT INTO user_keys (user_id, key_type, salt, wrapped_master_key, updated_at)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (user_id, key_type) DO UPDATE SET
    salt = EXCLUDED.salt,
    wrapped_master_key = EXCLUDED.wrapped_master_key,
    updated_at = EXCLUDED.updated_at;

-- name: GetKeySlotsByUserID :many
SELECT key_type, salt, wrapped_master_key, updated_at
FROM user_keys WHERE user_id = $1;

-- name: LockKeySlotsForUpdate :exec
-- Serializes SaveKeySlots for one account.
--
-- The divergence check reads the existing slots and then upserts. Under the
-- default READ COMMITTED isolation level each statement takes a fresh snapshot,
-- so two concurrent pushes can both read an empty vault, both pass the check,
-- and the second ON CONFLICT DO UPDATE overwrites the first. Only device A's
-- slots would be lost, with no error on either side.
--
-- An advisory transaction lock is used rather than locking the users row: this
-- would otherwise contend with the sync path, which holds
-- `SELECT sync_cursor FROM users ... FOR UPDATE` for its whole transaction.
-- The lock releases automatically on commit or rollback, including on panic.
--
-- The first argument namespaces the lock so it cannot collide with another
-- advisory lock taken elsewhere in the system.
-- 78511 is an arbitrary namespace tag; it only has to be stable and unlikely
-- to collide with another advisory lock in this database.
SELECT pg_advisory_xact_lock(78511::int, @user_id::int);
