# RideTogether

RideTogether is a group-travel safety and coordination platform for road trips, convoys, trekking
groups, and multi-day journeys. Its core aim is to help a group stay connected and coordinated
without trying to replace established mapping and navigation products.

## Current status

Phase 2 adds user authentication. The mobile app has login, registration, an authenticated profile
screen, and logout. The API persists users and revocable sessions in PostgreSQL and exposes
authentication endpoints. Trips, maps, GPS tracking, Socket.IO, chat, family sharing,
recommendations, and other travel features are not implemented.

The PostgreSQL integration is covered by migrations and repository code but has not been exercised
against a local running PostgreSQL instance in this workspace. Apply the migrations below before
using authentication endpoints outside API tests.

## Technology stack

- Flutter and Dart for the mobile app.
- Node.js, Express, and strict TypeScript for the API.
- Next.js and TypeScript for the future family viewer.
- PostgreSQL persists users and authentication sessions. Redis, Firebase, maps, routing, and FCM
  remain planned integrations.

## Repository structure

```text
apps/mobile/       Flutter application source
apps/api/          Express API
apps/family-web/   Next.js family viewer foundation
packages/          Reserved API contracts, domain, and shared configuration areas
infra/migrations/  PostgreSQL migrations
docs/              Architecture, API, privacy, and decision documentation
```

## Prerequisites

- Node.js 22 or later and pnpm 11 or later.
- Flutter and Dart for the mobile application.
- PostgreSQL only when applying migrations or adding database-backed functionality.

## Environment configuration

Copy `.env.example` to `.env`. The health endpoint needs no secrets or database. Authentication
requires `DATABASE_URL` and a unique `AUTH_JWT_SECRET` of at least 32 characters. Never commit
`.env` files or service keys.

Apply migrations in order before using authentication endpoints:

```powershell
psql $env:DATABASE_URL -f infra/migrations/0001_database_foundation.sql
psql $env:DATABASE_URL -f infra/migrations/0002_users_and_auth_sessions.sql
```

## Local development

Install JavaScript dependencies from the repository root:

```powershell
pnpm install
```

Run the API:

```powershell
pnpm api:dev
# GET http://localhost:3000/health
```

Run the family web application:

```powershell
pnpm web:dev
# Open http://localhost:3000
```

Run the mobile application after Flutter is installed. Configure the local API address for the
target device with `API_BASE_URL`; Android emulators can use `http://10.0.2.2:3000`.

```powershell
Set-Location apps/mobile
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Run JavaScript checks from the repository root:

```powershell
pnpm lint
pnpm test
pnpm api:build
pnpm web:build
pnpm format:check
```

## Planned MVP capabilities

The next MVP phases will add trip creation and joining, explicit location-sharing controls, a shared
map through an established mapping SDK,
quick coordination statuses, a conservative separation indicator, and secure read-only family
links. Navigation, chat, multi-day planning, trekking, gamification, recommendations, weather,
and AI remain later-phase work.
