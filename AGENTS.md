# Repository Guidelines

## Project Status and Scope

RideTogether is a group-travel safety and coordination platform for road trips, motorcycle
convoys, trekking groups, and multi-day journeys. **Phase 1 — Foundation is complete.** Develop
incrementally by phase; do not implement a future phase unless it is explicitly requested.

Phase 1 provides only a Flutter branded application shell and test, an Express `GET /health`
endpoint and test, a Next.js family-viewer foundation and test, a PostgreSQL schema-foundation
migration, workspace/repository configuration, documentation, and an environment template.

Authentication, user accounts, trip creation or joining, database-backed trip data, GPS/location
sharing, Socket.IO, live maps, quick statuses, chat, separation detection, emergency flows, family
live-sharing links, trip completion/history, recommendations, hotels, trekking or multi-day
features, Fun Mode, and AI are not implemented.

## Project Structure

This repository is a monorepo:

- `apps/mobile/`: Flutter/Dart mobile application.
- `apps/api/`: Node.js, Express, and strict TypeScript backend.
- `apps/family-web/`: Next.js/TypeScript family trip viewer foundation.
- `packages/`: reserved shared API-contract, domain, and configuration placeholders.
- `infra/`: database migration and future infrastructure foundation.
- `docs/`: architecture, API, privacy/safety, and decision documentation.

Keep the three applications independent. Add shared runtime code only when it serves a proven
cross-application need. Preserve the documented architecture and keep modules focused.

## Development and Quality

Before substantial work, inspect the relevant code and documentation. Avoid unnecessary
dependencies. Add or update real tests for changed behavior, then run the relevant validation:

```powershell
pnpm lint
pnpm test
pnpm api:build
pnpm web:build
pnpm format:check
Set-Location apps/mobile; flutter analyze; flutter test
```

Follow the configured formatter and linter. Use descriptive names and small, cohesive modules.
Update `README.md` and `docs/` when a change alters documented behavior or architecture.

## Safety, Privacy, and Configuration

Never commit secrets, credentials, API keys, or production configuration. Use `.env` locally and
document safe placeholders in `.env.example`.

RideTogether will handle sensitive location data in future phases. Location sharing must require
explicit user consent, be visible and easy to stop, and use appropriate access controls. Preserve
the privacy and safety principles in `docs/privacy-and-safety.md` when adding related features.

## Git Practices

Keep commits focused and use short imperative messages when asked to commit. Never commit or push
unless explicitly instructed.
