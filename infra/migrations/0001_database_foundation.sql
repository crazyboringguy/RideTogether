-- Phase 1 establishes an isolated namespace only. Product tables arrive with their owning feature.
CREATE SCHEMA IF NOT EXISTS ridetogether;

COMMENT ON SCHEMA ridetogether IS
  'RideTogether application data. Created in Phase 1; no product entities exist yet.';
