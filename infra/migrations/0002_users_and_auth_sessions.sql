CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE ridetogether.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name VARCHAR(80) NOT NULL,
  email VARCHAR(254) NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT users_email_unique UNIQUE (email)
);

CREATE OR REPLACE FUNCTION ridetogether.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_set_updated_at
BEFORE UPDATE ON ridetogether.users
FOR EACH ROW EXECUTE FUNCTION ridetogether.set_updated_at();

-- Sessions make server-side logout invalidation possible while JWTs remain stateless credentials.
CREATE TABLE ridetogether.auth_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES ridetogether.users(id) ON DELETE CASCADE,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX auth_sessions_active_user_idx
  ON ridetogether.auth_sessions (user_id, expires_at)
  WHERE revoked_at IS NULL;
