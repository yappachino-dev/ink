-- name: CreateUser :one
INSERT INTO users (email, password_hash, created_at, updated_at)
VALUES ($1, $2, NOW(), NOW())
RETURNING id, created_at, updated_at;

-- name: GetUserByEmail :one
SELECT id, email, password_hash, created_at, updated_at, sync_cursor
FROM users WHERE email = $1;

-- name: GetUserByID :one
SELECT id, email, password_hash, created_at, updated_at, sync_cursor
FROM users WHERE id = $1;

-- name: CreateRefreshToken :one
INSERT INTO refresh_tokens (user_id, token_hash, expires_at, created_at, revoked_at)
VALUES ($1, $2, $3, NOW(), NULL)
RETURNING id, created_at, revoked_at;

-- name: GetRefreshTokenByHash :one
SELECT id, user_id, token_hash, expires_at, created_at, revoked_at
FROM refresh_tokens
WHERE token_hash = $1;

-- name: RevokeRefreshTokenByHash :exec
UPDATE refresh_tokens
SET revoked_at = $1
WHERE token_hash = $2;

-- name: UpdateRefreshToken :exec
UPDATE refresh_tokens
SET token_hash = $1,
    expires_at = $2,
    revoked_at = $3
WHERE id = $4;

-- name: RevokeAllRefreshTokensByUserID :exec
UPDATE refresh_tokens
SET revoked_at = NOW()
WHERE user_id = $1 AND revoked_at IS NULL;

-- name: CreateEmailVerification :exec
INSERT INTO email_verifications (email, code_hash, expires_at)
VALUES ($1, $2, NOW() + INTERVAL '10 minutes');

-- name: GetLatestEmailVerification :one
SELECT id, email, code_hash, expires_at, used_at, created_at
FROM email_verifications
WHERE email = $1
ORDER BY created_at DESC
LIMIT 1;

-- name: MarkEmailVerificationAsUsed :exec
UPDATE email_verifications
SET used_at = NOW()
WHERE id = $1;

-- name: MarkAllEmailVerificationsAsUsedByEmail :exec
UPDATE email_verifications
SET used_at = NOW()
WHERE email = $1 AND used_at IS NULL;
