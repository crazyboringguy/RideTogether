# RideTogether

RideTogether is a group-travel safety and coordination platform for road trips, convoys, trekking
groups, and multi-day journeys. Its core aim is to help a group stay connected and coordinated
without trying to replace established mapping and navigation products.

## Current status

Phase 1 establishes the repository and application foundations only. The mobile app and family
web app display their initial branded screens, and the API exposes a health endpoint. There is no
authentication, trip creation, map, GPS tracking, Socket.IO, chat, family sharing, recommendation,
or database-backed product functionality yet.

## Technology stack

- Flutter and Dart for the mobile app.
- Node.js, Express, and strict TypeScript for the API.
- Next.js and TypeScript for the future family viewer.
- PostgreSQL is prepared through an initial migration; Redis, Firebase, maps, routing, and FCM are
  planned integrations.

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

Copy `.env.example` to `.env` and set only the variables needed for your local work. The Phase 1
health endpoint needs no secrets and no database. Never commit `.env` files or service keys.

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

Run the mobile application after Flutter is installed. The first command generates the native
Android/iOS runners if they are not already present:

```powershell
Set-Location apps/mobile
flutter create --platforms=android,ios .
flutter pub get
flutter analyze
flutter test
flutter run
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

After the foundation is reviewed, the MVP will add Firebase-backed authentication, trip creation
and joining, explicit location-sharing controls, a shared map through an established mapping SDK,
quick coordination statuses, a conservative separation indicator, and secure read-only family
links. Navigation, chat, multi-day planning, trekking, gamification, recommendations, weather,
and AI remain later-phase work.
