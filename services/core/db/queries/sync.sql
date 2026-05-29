-- name: GetUserCursor :one
SELECT sync_cursor FROM users WHERE id = $1;

-- name: UpdateUserCursor :exec
UPDATE users SET sync_cursor = $1 WHERE id = $2;

-- name: UpsertProject :exec
INSERT INTO projects (id, user_id, encrypted_content, version, sync_sequence, created_at, updated_at, deleted_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
ON CONFLICT (id) DO UPDATE SET
    encrypted_content = EXCLUDED.encrypted_content,
    version = EXCLUDED.version,
    sync_sequence = EXCLUDED.sync_sequence,
    updated_at = EXCLUDED.updated_at,
    deleted_at = EXCLUDED.deleted_at;

-- name: GetProjectChanges :many
SELECT id, encrypted_content, version, sync_sequence, created_at, updated_at, deleted_at
FROM projects WHERE user_id = $1 AND sync_sequence > $2;

-- name: UpsertNote :exec
INSERT INTO notes (id, user_id, project_id, encrypted_title, encrypted_content, version, sync_sequence, created_at, updated_at, deleted_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
ON CONFLICT (id) DO UPDATE SET
    project_id = EXCLUDED.project_id,
    encrypted_title = EXCLUDED.encrypted_title,
    encrypted_content = EXCLUDED.encrypted_content,
    version = EXCLUDED.version,
    sync_sequence = EXCLUDED.sync_sequence,
    updated_at = EXCLUDED.updated_at,
    deleted_at = EXCLUDED.deleted_at;

-- name: GetNoteChanges :many
SELECT id, project_id, encrypted_title, encrypted_content, version, sync_sequence, created_at, updated_at, deleted_at
FROM notes WHERE user_id = $1 AND sync_sequence > $2;
