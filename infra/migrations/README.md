# Database migrations

PostgreSQL migrations are stored here in numeric order. The Phase 1 migration establishes only the
dedicated `ridetogether` schema; it does not create product tables. A migration runner will be
selected before durable product data is introduced.

With PostgreSQL available and `DATABASE_URL` configured, the initial migration can be applied with:

```powershell
psql $env:DATABASE_URL -f 0001_database_foundation.sql
```
