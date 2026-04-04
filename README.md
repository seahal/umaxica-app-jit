[![CI](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml/badge.svg?branch=main)](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/seahal/umaxica-app-jit/main)

# Umaxica App (JIT)

## Routing

- `app`: for end user
- `org`: controller panel
- `com`: brand page

Multi-domain Rails application for three audience surfaces. Routing is host-constrained, so domain
and subdomain matter in both development and production.

## Repository Documentation

- `docs/`: current documentation and operational reference
- `plans/`: proposals, migration plans, phased work, and future changes
- `adr/`: accepted architecture and design decision records

## Stack

- Ruby `3.4.9`
- Rails edge (pin the version explicitly once the project moves to beta)
- PostgreSQL
  - Solid Queue
- Valkey/Redis
- Importmap + Stimulus + Turbo
  - Tailwind CSS via `tailwindcss-rails`
- Propshaft
- `vp` for JavaScript/frontend tooling, with Vite+ wrapping pnpm, Vitest, Oxlint, and Oxfmt

## Frontend and Assets

This repository does not use a JavaScript bundler.

- JavaScript is served through `importmap-rails`
- Stimulus controllers live in `app/javascript/controllers`
- CSS is built by `tailwindcss-rails`
- Static assets are served by Propshaft

Useful commands:

```bash
bin/rails tailwindcss:watch     # Tailwind watch mode
bin/rails assets:precompile     # Production asset build
bin/rails assets:clobber        # Remove compiled assets
bin/importmap audit             # Audit pinned JS packages
```

## Local Setup

- Docker and Docker Compose
- Ruby `3.4.9`
- Bundler
- Node.js `20+`
- `pnpm@10.27.0`

Start the local stack, install dependencies, and boot the app:

```bash
docker compose up
bundle install
vp install
TRUSTED_ORIGINS=http://sign.app.localhost:3000,http://sign.org.localhost:3000 bin/setup
```

`TRUSTED_ORIGINS` is required for boot because WebAuthn origin validation fails fast when it is
missing.

`docker/core/env` defaults `TRUSTED_ORIGINS` to production sign domains, so override it locally in
your shell or dev env file, for example:

```bash
TRUSTED_ORIGINS=http://sign.app.localhost:3000,http://sign.org.localhost:3000
```

`bin/setup` installs Ruby gems, runs `bin/rails db:prepare`, clears logs and temp files, then starts
`bin/dev`. It does not install JavaScript packages, so run `vp install` first.

If dependencies are already installed, you can start development directly:

```bash
TRUSTED_ORIGINS=http://sign.app.localhost:3000,http://sign.org.localhost:3000 bin/dev
```

`bin/dev` runs `bin/rails db:prepare` unless `SKIP_DB_PREPARE=1`, then starts:

- `web`: Rails server on port `3000`
- `css`: `bin/rails tailwindcss:watch`
- `job`: `bin/jobs start`

## Development URLs

Modern browsers resolve `*.localhost` to `127.0.0.1`, so extra `/etc/hosts` entries are usually not
needed.

| Surface | URL                                        |
| :------ | :----------------------------------------- |
| Apex    | `http://{app,com,org}.localhost:3000`      |
| Sign    | `http://sign.{org,com,app}.localhost:3000` |
| core    | `http://www.{app,com,org}.localhost:3000`  |
| Docs    | `http://docs.{app,com,org}.localhost:3000` |

## Checks

```bash
bundle exec rubocop
bundle exec rubocop -a
bundle exec erb_lint .
bundle exec erb_lint -a .
vp check
vp check --fix
bundle exec rails test
COVERAGE=true bundle exec rails test
vp test
vp test --watch                            # Watch mode
bundle exec brakeman --no-pager
bundle exec bundler-audit check --update
bundle exec database_consistency
bin/importmap audit
vp pm audit
```

Use `rubocop -a`, `erb_lint -a .`, and `vp check --fix` to apply auto-fixes where available.
JavaScript tests are located in `test/javascript/` and use Vitest with Vite Plus.

## Logging

Application logging is structured. Prefer event-style logging over ad hoc `Rails.logger` calls when
adding domain events or operational signals.

```ruby
Rails.event.record("user.created", user_id: user.id)
Rails.event.tagged("auth") { Rails.event.record("login.success", user_id: user.id) }
```

## Troubleshooting

| Problem                                  | Fix                                                                                                                            |
| :--------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------- |
| Tailwind changes are not reflected       | Run `bin/rails assets:clobber` and restart `bin/dev` or `bin/rails tailwindcss:watch`                                          |
| Tests fail because databases are missing | Run `bin/rails db:prepare`                                                                                                     |
| `bin/dev` stops during boot              | Check `TRUSTED_ORIGINS` and database availability                                                                              |
| Git operations fail around hooks         | Git hook ownership is still TBC, so do not assume Vite+ hooks or Lefthook are active unless the current Git config confirms it |
| Credentials cannot be decrypted          | Use the shared Rails credentials key for this environment                                                                      |

## Acknowledgement

- Secrets must stay in Rails credentials; do not commit plaintext secrets.
- WebAuthn origins are controlled by `TRUSTED_ORIGINS`.
- Public availability of this repository is not guaranteed permanently.
