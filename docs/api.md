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

## Trips

All trip endpoints require `Authorization: Bearer <token>`. The authenticated user comes only from
the verified access token; no user ID is accepted in trip requests.

### `POST /trips`

Accepts `name`, `source`, and `destination` and returns `201 Created` with `{ "trip": ... }`.
The server creates a unique, eight-character join code and adds the creator as the `host` member.

### `POST /trips/join`

Accepts `{ "joinCode": "..." }` and returns the joined trip. Unknown codes return `404`; an
existing membership returns `409`.

### `GET /trips`

Returns `{ "trips": [...] }` for the authenticated user only. Each item includes that user's
`role` (`host` or `member`).

### `GET /trips/:id`

Returns `{ "trip": ... }` only when the authenticated user is a member. Non-members receive
`404` to avoid exposing trip information.

### `GET /trips/:id/members`

Returns `{ "members": [...] }` only to trip members. Each member includes public profile details,
role, and join time; no authentication or password data is returned.

## Planned API

Routes, quick statuses, emergency alerts, chat, family sharing, recommendations, and real-time
events remain intentionally unimplemented. Their contracts should be designed and versioned before
implementation, preferably in `packages/api-contracts` when multiple applications need them.
