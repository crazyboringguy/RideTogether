# Architecture

## Phase 2 implementation

RideTogether is a monorepo with three independent applications:

- `apps/mobile`: Flutter/Dart mobile application shell.
- `apps/api`: Node.js, Express, and TypeScript API with a `GET /health` endpoint.
- `apps/family-web`: Next.js and TypeScript static foundation for the future read-only viewer.

The API runs without PostgreSQL or Redis for its health check, so deployment diagnostics remain
available during local setup. Authentication endpoints use PostgreSQL through a focused repository
layer. The database has `users` for account records and `auth_sessions` for server-side session
revocation; no trip or location schema exists.

The PostgreSQL integration requires a configured, running database with migrations applied. It is
not exercised by the in-memory API test suite in this workspace.

Passwords are hashed with Argon2id and never returned or logged. The API issues short-lived signed
JWT access tokens containing a user ID and session ID. Auth middleware verifies both the token and
the active PostgreSQL session, making logout immediately invalidate the token. The Flutter client
stores the access token only through platform-backed secure storage and centralizes API calls.

## Planned architecture

```text
Flutter mobile app ── REST API ── Node.js / Express
                         │              │
                         │              ├─ PostgreSQL (durable trip data)
                         │              └─ Redis (future temporary live state)
Family web dashboard ── read-only API ── secure, expiring share tokens
```

Firebase, Firebase Cloud Messaging, maps, routing, real-time Socket.IO, location tracking, chat,
trips, and family sharing remain planned capabilities, not Phase 2 functionality.
