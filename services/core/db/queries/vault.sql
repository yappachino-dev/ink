-- name: UpsertKeySlot :exec
INSERT INTO user_keys (user_id, key_type, salt, wrapped_master_key, updated_at)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (user_id, key_type) DO UPDATE SET
    salt = EXCLUDED.salt,
    wrapped_master_key = EXCLUDED.wrapped_master_key,
    updated_at = EXCLUDED.updated_at;

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
