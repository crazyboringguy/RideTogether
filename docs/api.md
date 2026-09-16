# API

## Phase 1 endpoint

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

## Planned API

Trip creation, joining, memberships, routes, quick statuses, emergency alerts, chat, family
sharing, recommendations, and real-time events are intentionally not implemented in Phase 1.
Their contracts should be designed and versioned before implementation, preferably in
`packages/api-contracts` when multiple applications need the same definitions.
