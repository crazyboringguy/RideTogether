CREATE TABLE ridetogether.trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  host_user_id UUID NOT NULL REFERENCES ridetogether.users(id) ON DELETE RESTRICT,
  name VARCHAR(120) NOT NULL,
  source VARCHAR(160) NOT NULL,
  destination VARCHAR(160) NOT NULL,
  join_code VARCHAR(8) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT trips_join_code_unique UNIQUE (join_code)
);

CREATE TRIGGER trips_set_updated_at
BEFORE UPDATE ON ridetogether.trips
FOR EACH ROW EXECUTE FUNCTION ridetogether.set_updated_at();

CREATE INDEX trips_host_user_id_idx ON ridetogether.trips (host_user_id);

CREATE TABLE ridetogether.trip_members (
  trip_id UUID NOT NULL REFERENCES ridetogether.trips(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES ridetogether.users(id) ON DELETE CASCADE,
  role VARCHAR(10) NOT NULL,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (trip_id, user_id),
  CONSTRAINT trip_members_role_check CHECK (role IN ('host', 'member'))
);

CREATE INDEX trip_members_user_id_idx ON ridetogether.trip_members (user_id);
