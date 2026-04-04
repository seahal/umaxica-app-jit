# Repository Guidelines

## Short Operational Guide

Read this section first. It is the default operating contract for AI agents.

### Instruction Priority

Follow instructions in this order:

1. This file (`AGENTS.md`)
2. `.harnes/policies/*`
3. `.harnes/context/*`
4. `.harnes/tasks/*`

If there is any conflict, follow the higher priority. If `.harnes/` does not exist or a priority
level is empty, skip that level silently and continue with the next.

### Default Rules

1. Read only the relevant files in `.harnes/` before editing code, and never edit `.harnes/`.
2. Use implementation code, config, routes, schema, and tests as the primary source of truth.
3. Treat narrative documentation as secondary to implementation code and tests. Use `docs/` for
   current stable documents, `plans/` for future-facing work, and `adr/` for accepted decision
   history.
4. Use `vp` as the entrypoint for JavaScript and frontend tooling. See
   [Vite+ Commands](#vite-commands).
5. Follow the [Delivery Flow](#delivery-flow) for implementation work.
6. Run [Validation Commands](#validation-commands) and report any blocked or skipped command
   explicitly.

### Working Modes

#### Mode Selection

- If the user explicitly states a mode, use it.
- If the user asks to implement, fix, or change code or configuration, use Build Mode.
- If the user asks to investigate, plan, review, or compare options, use Plan Mode.
- If unclear, ask the user.

#### Build Mode

Build mode means implementation, editing, and validation work on code or configuration.

- Do not read narrative documentation unless the user explicitly asks or no higher-trust source
  exists and the need is stated.
- Prefer implementation code, configuration, routes, schema, and tests over `docs/`, `plans/`, and
  `adr/`.
- Add or update regression-detecting tests before changing implementation code when the behavior can
  be specified first.

#### Plan Mode

Plan mode means investigation, planning, design review, or requirements clarification before
implementation.

- `docs/` may be read as current background documentation.
- `plans/` may be read as future-facing or in-progress planning material.
- `adr/` may be read for accepted decision history and rationale.
- Prefer implementation code, configuration, and tests when narrative documents conflict with the
  system behavior.

### Source Priority

When determining how the system actually works, prefer sources in this order:

1. Running behavior and test results
2. Implementation code and configuration
3. Schema, routes, and framework wiring
4. `.harnes/` policy, context, and task instructions
5. `docs/`, `plans/`, `adr/`, and other narrative materials

If high-trust sources conflict, stop and ask the user instead of resolving the contradiction alone.

### Required Checks

Before submitting any change, ensure:

1. No forbidden patterns (defined in `.harnes/policies/forbidden_patterns.md`) were introduced.
2. Routing and architecture rules were followed.
3. Authentication and authorization were respected.
4. Tests were added or updated when needed.
5. [Validation Commands](#validation-commands) were run, or blocked commands were reported
   explicitly.

### Routine Exclusions

Exclude from routine operations (reading, searching, editing, and analysis):

- `tmp/`, `log/` -- tend to waste tokens or contain irrelevant output.
- `vendor/`, `node_modules/` -- third-party libraries. Access only when strictly required for the
  task and the user has explicitly confirmed.

### Hard Prohibitions

These are unconditional. You MUST NOT:

- Ignore `.harnes/policies/*`
- Write, edit, create, rename, or delete files under `.harnes/`
- Skip authentication or authorization
- Introduce unsafe migrations
- Add meaningless or weak tests
- Bypass safety constraints
- Treat `docs/` as authoritative over code, config, routes, schema, or tests
- Read, modify, or search within `vendor/` or `node_modules/` without strict necessity and explicit
  user confirmation

### Documentation Layout

Repository documents are separated by purpose.

- `docs/` contains current, stable documentation.
- `plans/` contains proposals, drafts, migration plans, phased work, and other future-facing
  material.
- `adr/` contains accepted architecture and design decisions, with rationale and tradeoffs.

When updating documents:

- Do not place future plans or draft proposals in `docs/`.
- Do not place current operational or explanatory documentation in `plans/`.
- Prefer `adr/` for important accepted decisions that need historical traceability.
- When a plan is implemented, update `docs/` to reflect the current behavior.

### Git Commit Policy

Never run `git add` or `git commit` automatically.

Only stage files or create commits after the human explicitly approves that action.

By default, complete the requested changes, report what was done, and stop without staging or
committing. Let the user decide when to stage and commit.

### Human Review Required Files

Avoid editing high-risk governance or environment-defining files unless the change is necessary for
the task.

Before editing such files, request human confirmation or review first unless the user has already
asked for that exact file to be changed.

This applies in particular to:

- agent instruction files such as `AGENTS.md`, `CLAUDE.md`, and similar control documents
- repository policy, workflow, and automation files
- CI configuration and Git hook configuration
- dependency and toolchain configuration
- representative examples include `Gemfile`, `Gemfile.lock`, `.rubocop.yml`, `.erb_lint.yml`,
  `vite.config.ts`, `package.json`, lockfiles, and configuration for Vite+, Vitest, Oxlint, and
  Oxfmt
- Docker, deployment, and environment configuration
- security-sensitive initializers, authentication wiring, and credential-related files
- database migration files and schema-management files
- test harness and shared test bootstrapping files such as `test/test_helper.rb` and similar global
  test support entrypoints

If one of these files must change, explain why the change is necessary, keep the scope narrow, and
ask the human to review the result explicitly.

### Delivery Flow

Unless the user explicitly asks for planning-only work, use this sequence:

1. Read the relevant `.harnes/` files.
2. Inspect the real implementation and tests.
3. Confirm the current behavior from primary sources.
4. If the confirmed behavior contradicts the task assumptions, pause and clarify with the user
   before proceeding. Switch to Plan Mode if the scope needs re-evaluation.
5. Add or update regression-detecting tests first when the behavior can be expressed before the fix
   or feature change.
6. Implement the smallest correct change.
7. Add or update any remaining meaningful tests.
8. Run [Validation Commands](#validation-commands).
9. Report results, including blocked or skipped validation.

### Failure Handling

If a rule cannot be satisfied:

- Stop
- Explain the issue
- Propose a safe alternative

Do not proceed with unsafe implementation.

### Validation Commands

Run these after implementation unless a command is not applicable or the environment blocks it:

- `bundle exec rubocop`
- `bundle exec erb_lint .`
- `vp check`
- `vp test`
- `bundle exec rails test`

Report blocked or skipped commands explicitly.

### Quality Standard

Output MUST be:

- Safe
- Reproducible (same input should produce equivalent output)
- Aligned with project architecture
- Covered by meaningful tests

### Repository Language Standard

Use Simplified Technical English for all repository-internal artifacts (code, comments, tests,
fixtures, commit messages, issue text, and documentation). Use English for identifiers. See
[Repository Language Standard (Full Rules)](#repository-language-standard-full-rules) for details.

### Default Tie-Breaker

When in doubt, follow `.harnes/policies/` and prefer safety over speed.

---

## Detailed Reference

The sections below provide background context for the rules in the Short Operational Guide. Where a
topic appears in both places, the Short Operational Guide is the normative definition.

### Project Structure and Module Organization

This is a Rails 8 app with domain-separated surfaces (`app`, `com`, `org`) implemented across
controllers, views, and routes.

- Application code: `app/` (`models/`, `controllers/`, `services/`, `policies/`, `jobs/`, `views/`).
- Frontend JS: `app/javascript/` (Stimulus/importmap, checked with Biome).
- Tests: `test/` (`controllers/`, `models/`, `services/`, `integration/`, `fixtures/`, `support/`).
- Database: `db/` plus domain migration folders (for example `db/operators_migrate/`,
  `db/avatars_migrate/`).
- Ops/docs: `docker/`, `compose.yml`, `docs/`, `plans/`, `adr/`, `qa/`.

### Architecture

#### Application Module: `Jit::Application`

Ruby 3.4.9 / Rails edge (from `rails/rails` main branch). When the project moves to a beta release,
the Rails version should be pinned explicitly. PostgreSQL 18+ is required for native `uuidv7()`.

#### Multi-Domain, Multi-Audience Structure

The app serves multiple domains, each split into three audience tiers: **app** (end users), **org**
(staff), **com** (corporate/public). Routes are host-constrained and modularized.

The following table lists representative route files. It is not exhaustive; check `config/routes/`
for the current state.

| Route file              | Domain purpose                                     | Hosts (dev)                                                   |
| ----------------------- | -------------------------------------------------- | ------------------------------------------------------------- |
| `config/routes/sign.rb` | Authentication (sign-in/up, MFA, passkeys, social) | `sign.app.localhost`, `sign.org.localhost`                    |
| `config/routes/apex.rb` | Dashboard shell and preferences                    | `app.localhost`, `org.localhost`, `com.localhost`             |
| `config/routes/core.rb` | Main app backend (contacts, content management)    | `www.app.localhost`, `www.org.localhost`, `www.com.localhost` |
| `config/routes/docs.rb` | Documentation delivery                             | `docs.{app,com,org}.localhost`                                |
| `config/routes/news.rb` | News/blog delivery                                 | news domains                                                  |
| `config/routes/help.rb` | Help system                                        | help domains                                                  |

Controllers mirror this: `app/controllers/sign/app/`, `app/controllers/sign/org/`,
`app/controllers/apex/com/`, etc.

#### Multi-Database Architecture

Each database has a write (pub) and read replica (sub) connection. The following table lists key
databases. It is not exhaustive; check `config/database.yml` for the current state.

| Database     | Migration dir            | Purpose                      |
| ------------ | ------------------------ | ---------------------------- |
| `principal`  | `db/principals_migrate`  | Users and staff identity     |
| `operator`   | `db/operators_migrate`   | Staff/operator management    |
| `token`      | `db/tokens_migrate`      | Auth tokens (access/refresh) |
| `preference` | `db/preferences_migrate` | User/staff preferences       |
| `guest`      | `db/guests_migrate`      | Guest contacts               |
| `document`   | `db/documents_migrate`   | CMS documents                |
| `news`       | `db/news_migrate`        | News posts                   |
| `activity`   | `db/activity_migrate`    | Audit logs                   |
| `occurrence` | `db/occurrences_migrate` | Rate-limiting events         |
| `avatar`     | `db/avatars_migrate`     | Avatar/social profiles       |
| `queue`      | `db/queues_migrate`      | SolidQueue jobs              |
| `cache`      | `db/caches_migrate`      | SolidCache                   |

Schema files: `db/<name>_schema.rb` (e.g., `db/principal_schema.rb`). The root `db/schema.rb` also
exists.

#### Authentication and Security

- **WebAuthn/FIDO2** for passkeys (requires `TRUSTED_ORIGINS` env var for all Rails commands)
- **OmniAuth** for social login (Apple, Google)
- **Cloudflare Turnstile** for bot protection (standard + stealth modes) via `TurnstileConfig` /
  `TurnstileVerifier`
- **Pundit** for authorization policies
- **ActiveRecord Encryption** for sensitive data (keys in Rails credentials)
- **Argon2 + bcrypt** for password hashing

Auth concerns: `Auth::User` (user sessions), `Auth::Staff` (staff sessions), `Auth::Passkey`,
`Auth::StepUp`.

#### Frontend

- **Hotwire** (Turbo + Stimulus) with **Importmap** (no bundler)
- **Propshaft** asset pipeline (not Sprockets)
- **Tailwind CSS** via `tailwindcss-rails` gem
- **Biome** for JS linting/formatting
- Stimulus controllers in `app/javascript/controllers/`
- Do not use `pnpm` or `vp build` to build browser assets for the Rails app
- Do not install frontend runtime packages for app delivery through `pnpm` package workflows
- For browser-side runtime dependencies, prefer Importmap-managed packages and Rails-native asset
  delivery

#### Preferred Status Modeling

Status/state values should usually be modeled with a normalized lookup table and a foreign key
constraint, not with Rails enum.

Preferred shape:

- `0` = null-like / undecided / untouched
- `1` = canonical success / completed
- `2+` = non-success states

This convention is preferred because it keeps broad controller branching simple.

#### Preferred Database Modeling

Prefer explicit database modeling.

- Use reference tables and foreign keys for status catalogs
- Avoid boolean columns for domain categories or states that may later require more than two values
- Prefer `null: false` when a column should always have a meaningful value
- Avoid using SQL NULL when the application can represent the state explicitly
- If NULL is allowed, do not make NULL itself carry business meaning
- Add indexes where the column is used for lookup, filtering, joins, uniqueness, or sort order

These are preferred patterns, not absolute rules. Exceptions are acceptable when the domain model or
database behavior requires them.

#### Key Patterns

- **Structured logging**: Use `Rails.event.record("event.name", payload)` instead of `Rails.logger`
- **Public IDs**: Models use `PublicId` concern for URL-safe Nanoid identifiers
- **Frozen string literals**: Required in all Ruby files
- **Sorbet**: Runtime type checking via `sorbet-runtime`
- **i18n default locale**: Japanese (`:ja`)

#### Docker Compose Services

PostgreSQL 18 (primary + replica with WAL streaming), Valkey (port 56379), Kafka + Zookeeper,
SeaweedFS (S3-compatible storage), Grafana + Loki + Tempo (observability), Cloudflare Tunnel.

#### CI Pipeline (`.github/workflows/integration.yml`)

Runs on push to develop/main and PRs. Jobs: actionlint, hadolint, Brakeman + bundler-audit,
gitleaks, Semgrep, RuboCop + erb_lint, Rails test suite (with Postgres 18 + Valkey + Kafka), Biome +
package audit, container image scanning (Trivy + Grype).

### Build and Run Commands

```bash
# Setup (requires Docker running first)
docker compose up -d              # Start PostgreSQL 18+, Valkey, Kafka, etc.
bundle install                    # Install Ruby gems
vp install                        # Install JS dependencies through Vite+
bin/rails db:prepare             # Create, migrate, seed all databases
bin/dev                          # Start dev server (web + Tailwind watcher + SolidQueue jobs)

# Testing
bundle exec rails test                                    # Full test suite
bundle exec rails test test/models/user_test.rb           # Single file
bundle exec rails test test/models/user_test.rb -n test_validation  # Single test method
SKIP_DB=1 bundle exec rails test test/unit/               # Unit tests without DB
COVERAGE=true bin/rails test                              # With coverage report

# Linting
bundle exec rubocop              # Ruby style
bundle exec rubocop -a           # Ruby auto-fix
bundle exec erb_lint .           # ERB templates
vp check                         # JS/TS formatting, linting, and type checks

# Security
bundle exec brakeman --no-pager
bundle exec bundler-audit check --update
vp pm audit
vp outdated

# Utilities
rake uuid:pk:report              # Audit UUIDv7 primary key configs
bin/rails notes                  # Show TODO/FIXME annotations
```

### Coding Style and Naming Conventions

- Ruby: follow RuboCop (`.rubocop.yml`), 2-space indentation, snake_case methods/files, CamelCase
  classes/modules.
- Views/partials: use descriptive, scoped names (example: `app/views/sign/app/...`).
- JavaScript: use Biome formatting/linting defaults; keep modules under `app/javascript`.
- Keep domain boundaries explicit in paths and constants (`App`, `Com`, `Org`, `Sign`, `Core`,
  `Docs`, `News`, `Help`, `Apex`).

### Testing Guidelines

- Framework: Minitest (`test/test_helper.rb`) with fixtures.
- Respect t_wada-style testing practices when designing and writing tests.
- Prefer tests that avoid mocks and stubs whenever reasonably possible.
- Name tests with `_test.rb` and mirror source structure (example: `app/services/auth/foo.rb` ->
  `test/services/auth/foo_test.rb`).
- Run migrations before tests when schema changes are involved:
  `bundle exec rails db:migrate && bundle exec rails test`.

#### Test Organization

- `test/unit/` -- Unit tests (no DB required, runnable with `SKIP_DB=1`)
- `test/models/` -- Model tests (require DB)
- `test/controllers/` -- Controller tests (require DB, mirror controller namespaces)
- `test/integration/` -- Integration tests (full request stack)
- `test/services/`, `test/jobs/`, `test/mailers/`, `test/policies/` -- Domain-specific tests
- `test/support/` -- Shared helpers (auth bypass via `X-TEST-CURRENT-USER` / `X-TEST-CURRENT-STAFF`
  headers)
- Test fixtures loaded selectively in `test/test_helper.rb` (not `fixtures :all`)

### Quality Guidelines

- Consider ISO/IEC 25010 quality characteristics when designing, implementing, and reviewing
  changes, especially functional suitability, performance efficiency, compatibility, usability,
  reliability, security, maintainability, and portability.
- When making tradeoffs, document the affected quality characteristics in PRs, issues, or review
  notes when they materially influence scope, design, or testing.

### Design Principles

- Prefer SOLID design when shaping code and reviews.
- Keep responsibilities small and focused.
- Prefer stable abstractions and explicit dependencies over tight coupling.
- Favor composition and clear interfaces over clever or deeply nested implementations.

### Requirements Analysis Best Practices

#### Verify with multiple sources

Always verify initial understanding against primary sources. Never proceed on assumptions alone.

1. **Hypothesis**: Recognize intuitive understanding as a hypothesis.
2. **Primary sources**: Check implementation code (highest trust) > prototypes > specs.
3. **Contradictions**: If sources contradict each other, do NOT resolve independently -- report to
   user for decision.
4. **Confirm**: State the confirmed sources and current understanding before implementing when the
   task is ambiguous, high-risk, or likely to have conflicting interpretations.

### Commit and Pull Request Guidelines

- Prefer short type-prefixed commit subjects.
- Recommended commit types:
  - `[feat]`
  - `[fix]`
  - `[refactor]`
  - `[test]`
  - `[docs]`
  - `[chore]`
  - `[perf]`
  - `[security]`
- Prefer imperative, concise commit subjects (example: `[feat] add org passkey verification flow`).
- Prefer one clear intention per commit.
- Prefer explicit meaning over broad labels such as `[update]`.
- PRs should include:
  - Clear summary and motivation.
  - Linked issue/ticket.
  - Test evidence (commands run and results).
  - UI screenshots for view changes.

### Security and Configuration Tips

- Secret management: Rails credentials; never commit plaintext secrets.
- WebAuthn commands require `TRUSTED_ORIGINS` set in environment.
- Git hook ownership is currently undecided. Do not assume Vite+ hooks or Lefthook are active unless
  the repository's current Git configuration confirms it.

### Logging

- Use structured logging through `Rails.event` for application logs.
- For new application logging, prefer `Rails.event.record(...)` for normal events and
  `Rails.event.error(...)` for failures.
- Treat `Rails.event.notify(...)` as a compatibility alias, not the preferred API for new code.
- Do not add new application logging with `Rails.logger.*` when structured logging is available.

### Vite+ Commands

- Use `vp` for JavaScript and frontend tooling commands.
- Typical commands in this repository:
  - `vp install`
  - `vp check`
  - `vp test`
  - `vp pm audit`
  - `vp outdated`
- Do not use `pnpm`, `npm`, or `yarn` directly for routine work.
- Do not use `vp build` to produce Rails browser assets for this application.
- Rails browser assets are delivered through Importmap and the Rails asset pipeline.

### Repository Language Standard (Full Rules)

- Do not restrict the language used by the user in conversation.
- For repository-internal artifacts, use Simplified Technical English by default.
- This applies to code, comments, tests, fixtures, commit messages, issue text, and repository
  documentation unless a more specific project rule overrides it.
- Technical terms, framework terms, protocol names, standardized vocabulary, external contract
  fields, and established product names may remain in their standard form.
- User-facing copy, localization content, legal text, and quoted external material may use the
  language required by their purpose.
- Prefer clear, precise, and professional wording. Avoid language that is frivolous, distracting,
  sensational, degrading, or needlessly informal.
- Use English consistently for identifiers such as classes, modules, methods, variables, constants,
  database names, and file names unless compatibility, an external contract, or an established
  standard requires otherwise.
- Prefer explicit names over shorthand when clarity improves materially.
- Do not choose identifier wording by copying shortened file-extension forms or similar shorthand
  when a clearer full term is practical.
- Avoid placeholder-style naming, throwaway wording, joke terms, or unclear temporary wording in
  production code, tests, fixtures, and documentation.
- Avoid discriminatory, insulting, abusive, or otherwise inappropriate language in all repository
  content.
- Avoid unexplained abbreviations when a clear full term is practical and does not reduce
  readability.
- Avoid unexplained magic numbers. Name values when doing so improves clarity, maintainability, or
  reviewability.

### Review Checklist for Agents

- [ ] Run `vp install` after pulling remote changes and before getting started.
- [ ] Add or update regression-detecting tests before implementation when the behavior can be
      specified first.
- [ ] Run the [Validation Commands](#validation-commands) after implementation unless a command is
      not applicable or is blocked by the local environment.
- [ ] If high-risk files were edited, request or explicitly note required human review.
- [ ] Report skipped or blocked validation commands explicitly.
