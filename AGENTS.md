# Repository Guidelines

## Primary Directive
- Think in English, interact with the user in Japanese.

## Project Structure & Module Organization
- app/: Rails MVC, components, jobs, mailers. Frontend entry at `app/javascript/` (bundled to `app/assets/builds/`).
- config/: Rails/env config, credentials, routes. db/: migrations, seeds.
- test/: Minitest suites plus fixtures; `test/javascript/` holds Bun JS/TS tests.
- lib/: shared utilities. public/: static assets. bin/: project scripts. docs/ and .github/: docs, CI, security.

## Build, Test, and Development Commands
- Setup: `bundle install` and `bun install` (or `bun i`).
- Database: `bin/rails db:prepare` (creates, migrates, seeds as needed).
- Build assets: `bun run build` (watch: `bun run build --watch`).
- Run locally: `foreman start -f Procfile.dev` (web, Karafka; add JS/CSS watchers as needed) or `bin/rails s -p 3000 -b 0.0.0.0`.
- Tests (Ruby): `bin/rails test` (parallelized; coverage via SimpleCov).
- Tests (JS/TS): `bun test` (looks under `test/javascript/`).
- Hooks (pre-commit): RuboCop, ERB Lint, Brakeman, Bundler Audit, Biome format/lint, TS typecheck, Importmap audit/outdated (see `lefthook.yml`).

## Coding Style & Naming Conventions
- Ruby: 2-space indent, Omakase Rails via RuboCop (`.rubocop.yml`). Files `snake_case.rb`, classes `CamelCase`. Prefer small, focused controllers/services; avoid N+1 (Bullet is enabled).
- Views: ERB linted; keep partials in `app/views/**/_*.html.erb`.
- JS/TS: Format/lint with Biome (`bun run format` / `bun run lint`). Typecheck with `bun run typecheck`. Place Stimulus-like controllers in `app/javascript/controllers/` (e.g., `passkey.js`).

## Testing Guidelines
- Ruby: Minitest under `test/` with fixtures. Name as `*_test.rb` (e.g., `user_test.rb`). Aim to keep branch coverage green (SimpleCov setup in `test/test_helper.rb`).
- JS/TS: Place tests in `test/javascript/` as `*.test.js|ts`.

## Commit & Pull Request Guidelines
- Commits: Use short, imperative messages; optional bracketed tags reflect repo history (e.g., `[update] implement passkeys endpoint`, `[misc] cleanup services`).
- PRs: Describe intent and scope; link issues; call out DB migrations; include screenshots/logs for UI/API changes; ensure `bin/rails test` and `bun test` pass; note any feature flags or env vars.

## Security & Configuration Tips
- Never commit secrets. Use `.env.example` as reference; load dev vars via dotenv. Prefer Rails credentials where applicable.
- Run `bundle exec brakeman` and `bundle exec bundle audit` regularly. Use `./bin/importmap audit` to check browser dependencies.
