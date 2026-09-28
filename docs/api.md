# API

## Available endpoints

### `GET /health`

Returns `200 OK` when the Express process is available. It requires neither database nor Redis
connectivity.

```json
{
  "service": "ridetogether-api",
  "status": "ok",
  "timestamp": "2026-09-16T00:00:00.000Z"
}
```

Unknown paths return a JSON `404` response. Unexpected request failures are logged and return a
generic JSON `500` response without exposing internal details.

## Authentication

All authentication responses return a public user object (`id`, `name`, `email`, `createdAt`) and
an access token where applicable. Passwords and hashes are never returned.

### `POST /auth/register`

Accepts `name`, `email`, and `password`; returns `201 Created` with `{ "user": ..., "token": "..." }`.
Email is trimmed and lowercased. Names require 2–80 characters; passwords require at least 12
characters including a letter and number. Duplicate emails return `409`.

### `POST /auth/login`

Accepts `email` and `password`; returns `200 OK` with `{ "user": ..., "token": "..." }`. Invalid
credentials return `401` without revealing which value was incorrect.

### `GET /auth/me`

Requires `Authorization: Bearer <token>` and returns `{ "user": ... }`. Missing, invalid, expired,
or revoked credentials return `401`.

### `POST /auth/logout`

Requires `Authorization: Bearer <token>`. It revokes that server-side session and returns `204 No
Content`, so the presented token can no longer access authenticated endpoints.

## Planned API

Trip creation, joining, memberships, routes, quick statuses, emergency alerts, chat, family
sharing, recommendations, and real-time events are intentionally not implemented in Phase 2.
Their contracts should be designed and versioned before implementation, preferably in
`packages/api-contracts` when multiple applications need the same definitions.
