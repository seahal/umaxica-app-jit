# Repository Guidelines

## Project Structure & Module Organization
This is a Rails 8 app with domain-separated surfaces (`app`, `com`, `org`) implemented across controllers, views, and routes.
- Application code: `app/` (`models/`, `controllers/`, `services/`, `policies/`, `jobs/`, `views/`).
- Frontend JS: `app/javascript/` (Stimulus/importmap, checked with Biome).
- Tests: `test/` (`controllers/`, `models/`, `services/`, `integration/`, `fixtures/`, `support/`).
- Database: `db/` plus domain migration folders (for example `db/operators_migrate/`, `db/avatars_migrate/`).
- Ops/docs: `docker/`, `compose.yml`, `docs/`, `qa/`.

## Build, Test, and Development Commands
- `bin/setup`: install dependencies and prepare databases.
- `bin/dev`: start local dev stack via Foreman (`Procfile.dev`), including DB prepare.
- `bundle exec rails test`: run the test suite.
- `COVERAGE=true bundle exec rails test`: run tests with SimpleCov enabled.
- `bundle exec rubocop`: Ruby linting/style checks.
- `bundle exec erb_lint --lint-all`: ERB lint and autocorrect.
- `pnpm run check`: Biome check/format pass for `app/javascript`.
- `bundle exec brakeman --no-pager`: static security scan.

## Coding Style & Naming Conventions
- Ruby: follow RuboCop (`.rubocop.yml`), 2-space indentation, snake_case methods/files, CamelCase classes/modules.
- Views/partials: use descriptive, scoped names (example: `app/views/sign/app/...`).
- JavaScript: use Biome formatting/linting defaults; keep modules under `app/javascript`.
- Keep domain boundaries explicit in paths and constants (`App`, `Com`, `Org`, `Sign`, `Core`, `Docs`, `News`, `Help`, `Apex`).

## Testing Guidelines
- Framework: Minitest (`test/test_helper.rb`) with fixtures.
- Name tests with `_test.rb` and mirror source structure (example: `app/services/auth/foo.rb` -> `test/services/auth/foo_test.rb`).
- Run migrations before tests when schema changes are involved: `bundle exec rails db:migrate && bundle exec rails test`.

## Commit & Pull Request Guidelines
- Recent history uses short type-prefixed subjects (`[feat]`, `[update]`, `[refactor]`, `[checkpoint]`).
- Preferred commit style: imperative, scoped, and concise (example: `[feat] add org passkey verification flow`).
- PRs should include:
  - Clear summary and motivation.
  - Linked issue/ticket.
  - Test evidence (commands run and results).
  - UI screenshots for view changes.

## Security & Configuration Tips
- Secret management: Rails credentials; never commit plaintext secrets.
- WebAuthn commands require `TRUSTED_ORIGINS` set in environment.
- Run hooks before push: `lefthook run pre-commit` (audit, lint, Brakeman, tests).
