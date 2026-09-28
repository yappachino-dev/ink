-- Convert all naive TIMESTAMP columns to TIMESTAMPTZ.
-- Existing values are interpreted as UTC (the server has always written UTC).

-- +goose Up
ALTER TABLE users
    ALTER COLUMN created_at TYPE timestamptz USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN updated_at TYPE timestamptz USING updated_at AT TIME ZONE 'UTC';

ALTER TABLE user_keys
    ALTER COLUMN updated_at TYPE timestamptz USING updated_at AT TIME ZONE 'UTC';

ALTER TABLE notebooks
    ALTER COLUMN created_at TYPE timestamptz USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN updated_at TYPE timestamptz USING updated_at AT TIME ZONE 'UTC',
    ALTER COLUMN deleted_at TYPE timestamptz USING deleted_at AT TIME ZONE 'UTC';

ALTER TABLE notes
    ALTER COLUMN created_at TYPE timestamptz USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN updated_at TYPE timestamptz USING updated_at AT TIME ZONE 'UTC',
    ALTER COLUMN deleted_at TYPE timestamptz USING deleted_at AT TIME ZONE 'UTC';

ALTER TABLE refresh_tokens
    ALTER COLUMN expires_at TYPE timestamptz USING expires_at AT TIME ZONE 'UTC',
    ALTER COLUMN created_at TYPE timestamptz USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN revoked_at TYPE timestamptz USING revoked_at AT TIME ZONE 'UTC';

ALTER TABLE email_verifications
    ALTER COLUMN expires_at TYPE timestamptz USING expires_at AT TIME ZONE 'UTC',
    ALTER COLUMN used_at TYPE timestamptz USING used_at AT TIME ZONE 'UTC',
    ALTER COLUMN created_at TYPE timestamptz USING created_at AT TIME ZONE 'UTC';

-- +goose Down
ALTER TABLE users
    ALTER COLUMN created_at TYPE timestamp USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN updated_at TYPE timestamp USING updated_at AT TIME ZONE 'UTC';

ALTER TABLE user_keys
    ALTER COLUMN updated_at TYPE timestamp USING updated_at AT TIME ZONE 'UTC';

ALTER TABLE notebooks
    ALTER COLUMN created_at TYPE timestamp USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN updated_at TYPE timestamp USING updated_at AT TIME ZONE 'UTC',
    ALTER COLUMN deleted_at TYPE timestamp USING deleted_at AT TIME ZONE 'UTC';

ALTER TABLE notes
    ALTER COLUMN created_at TYPE timestamp USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN updated_at TYPE timestamp USING updated_at AT TIME ZONE 'UTC',
    ALTER COLUMN deleted_at TYPE timestamp USING deleted_at AT TIME ZONE 'UTC';

ALTER TABLE refresh_tokens
    ALTER COLUMN expires_at TYPE timestamp USING expires_at AT TIME ZONE 'UTC',
    ALTER COLUMN created_at TYPE timestamp USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN revoked_at TYPE timestamp USING revoked_at AT TIME ZONE 'UTC';

ALTER TABLE email_verifications
    ALTER COLUMN expires_at TYPE timestamp USING expires_at AT TIME ZONE 'UTC',
    ALTER COLUMN used_at TYPE timestamp USING used_at AT TIME ZONE 'UTC',
    ALTER COLUMN created_at TYPE timestamp USING created_at AT TIME ZONE 'UTC';
