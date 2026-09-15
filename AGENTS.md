# Repository Guidelines

## Project Structure & Module Organization

RideTogether is currently a starter repository containing only `README.md`; no application, build system, or test framework has been committed yet. Keep the root for repository-wide configuration and documentation. As the application is introduced, use this layout:

- `src/` for production source code, organized by feature or domain.
- `tests/` for automated tests, mirroring paths under `src/` where practical.
- `assets/` for checked-in static resources such as icons, images, or fixtures.
- `docs/` for design notes and operational documentation.

Do not commit generated output, local secrets, or editor-specific files; add them to `.gitignore`.

## Build, Test, and Development Commands

There are no runnable build, development, lint, or test commands at present. When adding tooling, record canonical commands in `README.md` and keep them reproducible from a clean checkout. For example, a JavaScript project should expose `npm run dev`, `npm test`, `npm run lint`, and `npm run build` through `package.json`.

## Coding Style & Naming Conventions

Follow the configured formatter and linter; do not hand-format around automated tools. Until one is established, use consistent indentation and small, focused modules. Use descriptive names: `ride-request.ts`, `RideRequest`, and `createRideRequest` are preferable to abbreviations. Keep test names explicit about the expected behavior.

## Testing Guidelines

Add tests for every behavior change once a framework is selected. Place them in `tests/` or next to modules only if documented. Use names such as `ride-request.test.ts` and test observable outcomes, including invalid input and failure paths. Run the full suite and linting before opening a pull request; add coverage expectations when the runner is introduced.

## Commit & Pull Request Guidelines

The available history contains only `Initial commit`, so no convention exists. Use short imperative summaries, optionally scoped: `feat: add ride request validation` or `docs: clarify local setup`. Keep commits focused. Pull requests should explain the change and validation performed, link the relevant issue when one exists, and include screenshots for visual changes.

## Configuration & Security

Never commit credentials, API keys, or production configuration. Provide sanitized examples such as `.env.example`, document required variables, and use environment variables or a secrets manager for real values.
