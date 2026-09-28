# Database migrations

PostgreSQL migrations are stored here in numeric order. `0001` establishes the `ridetogether`
schema. `0002` adds the Phase 2 `users` and `auth_sessions` tables for account persistence and
server-side logout invalidation. No trip, location, chat, or sharing tables exist yet.

With PostgreSQL available and `DATABASE_URL` configured, the initial migration can be applied with:

```powershell
psql $env:DATABASE_URL -f 0001_database_foundation.sql
psql $env:DATABASE_URL -f 0002_users_and_auth_sessions.sql
```
