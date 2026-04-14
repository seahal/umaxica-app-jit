# Four-Engine Rename Plan

## Context

The four-engine split (Signature, World, Station, Press) was completed with legacy module names
inherited from the monolith era (`sign`, `apex`, `core`, `docs`). The TODO comments in route files
signal the intent to align module names, env var prefixes, and subdomains with the engine identity.

This plan renames three of the four engines' internal module namespaces and aligns all env var
prefixes and subdomains. World/Apex is already consistent and needs no rename.

## Rename Map

| Engine    | Old module | New module | Old env prefix  | New env prefix | Old subdomain | New subdomain |
| --------- | ---------- | ---------- | --------------- | -------------- | ------------- | ------------- |
| Signature | `sign`     | `visa`     | `SIGN_`         | `VISA_`        | `sign.*`      | `visa.*`      |
| World     | `apex`     | `apex`     | `APEX_`         | `APEX_`        | `app/org/com` | (no change)   |
| Station   | `core`     | `base`     | `CORE_`/`MAIN_` | `BASE_`        | `www.*`       | `base.*`      |
| Press     | `docs`     | `copy`     | `DOCS_`         | `COPY_`        | `docs.*`      | `copy.*`      |

Route alias (`as:`) also changes to match the new module name:

- Station: `as: :main` → `as: :base` (helpers: `main_*` → `base_*`)
- Press: `as: :docs` → `as: :copy` (helpers: `docs_*` → `copy_*`)
- Signature: `as: :sign` → `as: :visa` (helpers: `sign_*` → `visa_*`)

## Estimated Scope

| Engine    | Controllers | Views | Tests | Route helpers | Total est. |
| --------- | ----------- | ----- | ----- | ------------- | ---------- |
| Station   | 54          | 25    | 46    | ~100          | ~300       |
| Press     | 42          | 42    | 31    | ~80           | ~200       |
| Signature | 163         | 175   | 132   | ~2,100        | ~2,500     |
| Cross-cut | —           | —     | —     | —             | ~80        |
| **Total** |             |       |       |               | **~3,100** |

## Execution Order

Process one engine at a time, smallest first, to validate the pattern before the largest rename.

### Phase 1: Station — `core` → `base` (~300 files)

1. **Directories** — rename under `engines/station/`:
   - `app/controllers/core/` → `app/controllers/base/`
   - `app/views/core/` → `app/views/base/`
   - `test/controllers/core/` → `test/controllers/base/`

2. **Module namespaces** — in all renamed files:
   - `module Core` → `module Base`
   - `Core::App::*` → `Base::App::*`
   - `Core::Com::*` → `Base::Com::*`
   - `Core::Org::*` → `Base::Org::*`

3. **Routes** — `engines/station/config/routes.rb`:
   - `scope module: :core, as: :main` → `scope module: :base, as: :base`
   - Remove the TODO comment

4. **Engine comment** — `engines/station/lib/jit/station/engine.rb`:
   - Update `(Core::App::*Controller etc.)` → `(Base::App::*Controller etc.)`

5. **Env vars** — rename `CORE_*` / `MAIN_*` → `BASE_*`:
   - `CORE_CORPORATE_URL` / `MAIN_CORPORATE_URL` → `BASE_CORPORATE_URL`
   - `CORE_SERVICE_URL` / `MAIN_SERVICE_URL` → `BASE_SERVICE_URL`
   - `CORE_STAFF_URL` / `MAIN_STAFF_URL` → `BASE_STAFF_URL`
   - `CORE_APP_TRUSTED_ORIGINS` → `BASE_APP_TRUSTED_ORIGINS`
   - Files: `docker/core/env`, `config/environments/production.rb`, `test/test_helper.rb`,
     `.github/workflows/integration.yml`, route constraints, CSRF config

6. **Host app references**:
   - `app/views/layouts/core/` → `app/views/layouts/base/`
   - `app/assets/stylesheets/core/` → `app/assets/stylesheets/base/`
   - Test files referencing `Core::` classes (~20 files)
   - Route helpers: `main_app_*` → `base_app_*`, `main_com_*` → `base_com_*`, `main_org_*` →
     `base_org_*`

7. **Cross-engine helpers** — `lib/cross_engine_url_helpers.rb`:
   - HOST_MAP: `/main_app/` → `/base_app/`, env key → `BASE_SERVICE_URL`
   - ROUTE*PREFIX: `"main*"`or`"core*"`→`"base*"`→`:station`

8. **OIDC client registry** — `app/config/oidc/client_registry.rb`:
   - `"core_app"` → `"base_app"`, `"core_org"` → `"base_org"`, `"core_com"` → `"base_com"`

9. **Subdomain** — `www.*` → `base.*`:
   - Default values in `test/test_helper.rb`, docker env, CI workflow

### Phase 2: Press — `docs` → `copy` (~200 files)

1. **Directories** — rename under `engines/press/`:
   - `app/controllers/docs/` → `app/controllers/copy/`
   - `app/views/docs/` → `app/views/copy/`
   - `test/controllers/docs/` → `test/controllers/copy/`

2. **Module namespaces**:
   - `module Docs` → `module Copy`
   - `Docs::App::*` → `Copy::App::*`
   - `Docs::Com::*` → `Copy::Com::*`
   - `Docs::Org::*` → `Copy::Org::*`

3. **Routes** — `engines/press/config/routes.rb`:
   - `scope module: :docs, as: :docs` → `scope module: :copy, as: :copy`
   - Remove the TODO comment

4. **Engine comment** — `engines/press/lib/jit/press/engine.rb`:
   - Update `(Docs::App::*Controller etc.)` → `(Copy::App::*Controller etc.)`

5. **Env vars** — `DOCS_*` → `COPY_*`:
   - `DOCS_CORPORATE_URL` → `COPY_CORPORATE_URL`
   - `DOCS_SERVICE_URL` → `COPY_SERVICE_URL`
   - `DOCS_STAFF_URL` → `COPY_STAFF_URL`

6. **Station cross-reference** — `engines/station/config/routes.rb` lines 138-154:
   - `namespace :docs` → `namespace :copy` (staff content management)
   - Rename station controllers: `core/org/docs/` → `base/org/copy/` (6 controllers + 6 tests)
   - Module: `Core::Org::Docs::*` → `Base::Org::Copy::*`
   - Note: If Phase 1 is done first, directory is already `base/org/docs/` at this point.

7. **Host app references**:
   - Help layouts referencing `docs_*_root_url` → `copy_*_root_url` (3 files)
   - Integration tests referencing `Docs::` classes
   - Route helpers: `docs_app_*` → `copy_app_*` etc.

8. **Cross-engine helpers** — `lib/cross_engine_url_helpers.rb`:
   - HOST_MAP: `/docs_app/` → `/copy_app/`, env → `COPY_SERVICE_URL`
   - ROUTE*PREFIX: `"docs*"`→`"copy\_"`→`:press`

9. **OIDC client registry**: `"docs_app"` → `"copy_app"` etc.

10. **Subdomain** — `docs.*` → `copy.*`

### Phase 3: Signature — `sign` → `visa` (~2,500 files)

This is the largest rename. Same pattern as above, scaled up.

1. **Directories** — rename under `engines/signature/`:
   - `app/controllers/sign/` → `app/controllers/visa/`
   - `app/views/sign/` → `app/views/visa/`
   - `test/controllers/sign/` → `test/controllers/visa/`

2. **Module namespaces** (~273 files):
   - `module Sign` → `module Visa`
   - `Sign::App::*` → `Visa::App::*`
   - `Sign::Com::*` → `Visa::Com::*`
   - `Sign::Org::*` → `Visa::Org::*`

3. **Routes** — `engines/signature/config/routes.rb`:
   - `scope module: :sign, as: :sign` → `scope module: :visa, as: :visa`

4. **SignHostEnv** — rename class and files:
   - `lib/sign_host_env.rb` → `lib/visa_host_env.rb`
   - `engines/signature/lib/sign_host_env.rb` → same
   - `config/initializers/sign_host_env.rb` → `config/initializers/visa_host_env.rb`
   - `SignHostEnv` → `VisaHostEnv` (13 files)

5. **Env vars** — `SIGN_*` → `VISA_*`:
   - `SIGN_SERVICE_URL` → `VISA_SERVICE_URL`
   - `SIGN_CORPORATE_URL` → `VISA_CORPORATE_URL`
   - `SIGN_STAFF_URL` → `VISA_STAFF_URL`

6. **Route helpers** (~2,100 references):
   - `sign_app_*` → `visa_app_*`
   - `sign_com_*` → `visa_com_*`
   - `sign_org_*` → `visa_org_*`

7. **Host app references** (~12 files):
   - `app/helpers/sign/` → `app/helpers/visa/`
   - `app/services/sign/` → `app/services/visa/`
   - `app/lib/sign/` → `app/lib/visa/`
   - `app/views/layouts/sign/` → `app/views/layouts/visa/` (if exists)
   - Test files: `test/unit/sign/`, service tests

8. **Cross-engine helpers**: `sign_` → `visa_` mappings
9. **Subdomain** — `sign.*` → `visa.*`

### Phase 4: Cross-Cutting Cleanup (~80 files)

1. **`lib/cross_engine_url_helpers.rb`** — verify all HOST_MAP and ROUTE_PREFIX entries
2. **`app/config/oidc/client_registry.rb`** — verify all client IDs and redirect URIs
3. **`config/environments/production.rb`** — update allowed env var list
4. **`docker/core/env`** — update all env var names and default subdomain values
5. **`.github/workflows/integration.yml`** — update CI env vars
6. **`test/test_helper.rb`** — update host defaults, remove old fallback patterns
7. **`config/routes.rb`** — update `Jit::Deployment` comments (cosmetic)
8. **Remove backward-compatibility fallbacks** — e.g., `MAIN_*_URL || CORE_*_URL` patterns
9. **`AGENTS.md`** — update architecture table: route file hosts and env var references

## Files to Verify After Each Phase

### Critical config files

- `engines/*/config/routes.rb`
- `config/routes.rb`
- `lib/cross_engine_url_helpers.rb`
- `app/config/oidc/client_registry.rb`
- `config/environments/production.rb`
- `docker/core/env`
- `.github/workflows/integration.yml`
- `test/test_helper.rb`

## Verification

After each phase:

1. `bundle exec rails routes` — confirm route helpers match new names
2. `bundle exec rails test` — run full test suite
3. `bundle exec rubocop` — check for style violations
4. `bundle exec erb_lint .` — check ERB templates
5. `vp check` — check JS/TS
6. `grep -r` for leftover old names (`core_`, `docs_`, `sign_`, `CORE_`, `DOCS_`, `SIGN_`, `main_`)

## Risks

- **Route helper references in JS/Stimulus** — search `app/javascript/` for hardcoded paths
- **Cloudflare tunnel config** — subdomain changes need DNS/tunnel updates (outside repo)
- **OIDC client ID changes** — may need coordinated deployment if external IdP references old IDs
- **Session cookies** — domain-scoped cookies may break if subdomain changes without transition
- **Env var transition** — production deployment needs coordinated env var update

## Not in Scope

- World/Apex engine (already consistent)
- Database names, table names, migration directories
- Model class names (User, Staff, etc.)
- Production DNS/Cloudflare configuration (handled separately)
