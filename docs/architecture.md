# Architecture

## Phase 1 implementation

RideTogether is a monorepo with three independent applications:

- `apps/mobile`: Flutter/Dart mobile application shell.
- `apps/api`: Node.js, Express, and TypeScript API with a `GET /health` endpoint.
- `apps/family-web`: Next.js and TypeScript static foundation for the future read-only viewer.

The API runs without PostgreSQL or Redis so a health check remains usable during local setup and
deployment diagnostics. It has strict TypeScript compilation, request logging, JSON parsing, and
centralized 404/error handling. PostgreSQL has an initial schema-only migration in
`infra/migrations`; no application database connection or product schema is implemented.

## Planned architecture

```text
Flutter mobile app ── REST API ── Node.js / Express
                         │              │
                         │              ├─ PostgreSQL (durable trip data)
                         │              └─ Redis (future temporary live state)
Family web dashboard ── read-only API ── secure, expiring share tokens
```

Firebase Authentication, Firebase Cloud Messaging, maps, routing, real-time Socket.IO, location
tracking, chat, and family sharing are planned capabilities, not Phase 1 functionality.
