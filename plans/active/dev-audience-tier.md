# Add `dev` Audience Tier

## Summary

Add a fourth audience tier (`dev`) to the Identity, Global, and Regional engines. The `dev` tier
provides a dedicated boundary for developer and operational tooling such as SolidQueue dashboards,
cache inspection, and future admin interfaces.

This plan also includes renaming the Regional engine subdomain from `ww` / `core` to `base`.

## Scope

### In scope

- Add `dev` host constraint blocks to Identity (Signature), Global (World), and Regional (Station)
  engine routes
- Rename Regional subdomain from `ww` to `base` and ENV prefix from `CORE_` / `MAIN_` to `BASE_`
- Move `MissionControl::Jobs` from the `org` tier to the `dev` tier in Station
- Add `SignHostEnv.developer_url` and `validate!` update
- Add ENV variables for CI
- Create minimal `dev` controllers (application, root, health, robots) per engine
- Update `docs/reference/subdomains.md` and `docs/architecture/engine.md`

### Out of scope

- Authentication and authorization for the `dev` tier (deferred)
- Controller module directory restructuring (deferred until engine extraction completes)
- Press engine `dev` tier

## Target Hostnames

| Engine   | Host label | `dev` hostname       | ENV variable         |
| -------- | ---------- | -------------------- | -------------------- |
| Identity | `sign`     | `sign.dev.localhost` | `SIGN_DEVELOPER_URL` |
| Global   | (apex)     | `dev.localhost`      | `APEX_DEVELOPER_URL` |
| Regional | `base`     | `base.dev.localhost` | `BASE_DEVELOPER_URL` |

### Regional subdomain rename (all tiers)

| Tier  | Before             | After                | ENV before           | ENV after            |
| ----- | ------------------ | -------------------- | -------------------- | -------------------- |
| `com` | `ww.com.localhost` | `base.com.localhost` | `CORE_CORPORATE_URL` | `BASE_CORPORATE_URL` |
| `app` | `ww.app.localhost` | `base.app.localhost` | `CORE_SERVICE_URL`   | `BASE_SERVICE_URL`   |
| `org` | `ww.org.localhost` | `base.org.localhost` | `CORE_STAFF_URL`     | `BASE_STAFF_URL`     |
| `dev` | (new)              | `base.dev.localhost` | (new)                | `BASE_DEVELOPER_URL` |

The `MAIN_*` / `CORE_*` ENV fallbacks in Station routes should remain temporarily for backward
compatibility during migration, then be removed.

## Implementation Phases

### Phase 1: Regional subdomain rename

1. Add `BASE_*` ENV variables alongside existing `CORE_*` / `MAIN_*` in CI and local config
2. Update Station routes to check `BASE_*` first, with `CORE_*` / `MAIN_*` fallback
3. Update documentation references

### Phase 2: Add `dev` tier infrastructure

1. Add `SignHostEnv.developer_url` method and update `validate!`
2. Add `*_DEVELOPER_URL` ENV variables to CI
3. Add `sign.dev.localhost` to `TRUSTED_ORIGINS`

### Phase 3: Create `dev` controllers

Each engine gets four minimal controllers under a `dev/` module:

- `application_controller.rb` — rate limiting only, no auth (auth is deferred)
- `roots_controller.rb` — landing page
- `healths_controller.rb` — health check endpoint
- `robots_controller.rb` — robots.txt (disallow all)

Plus a root view template per engine.

### Phase 4: Wire `dev` routes

1. Add `dev` host constraint blocks to each engine route file
2. Move `MissionControl::Jobs::Engine` mount from Station `org` block to Station `dev` block

### Phase 5: Tests and verification

1. Add health check tests for each `dev` host
2. Verify `MissionControl::Jobs` is accessible on `base.dev.localhost/jobs`
3. Verify `MissionControl::Jobs` is no longer routed on `base.org.localhost/jobs`
4. Run full test suite and linters

## Files to Modify

| File                                 | Action                                                               |
| ------------------------------------ | -------------------------------------------------------------------- |
| `lib/sign_host_env.rb`               | Add `developer_url`, update `validate!`                              |
| `.github/workflows/integration.yml`  | Add `BASE_*` and `*_DEVELOPER_URL` ENV vars                          |
| `engines/signature/config/routes.rb` | Add `dev` constraint block                                           |
| `engines/world/config/routes.rb`     | Add `dev` constraint block                                           |
| `engines/station/config/routes.rb`   | Rename `CORE`/`MAIN` to `BASE`, add `dev` block, move MissionControl |
| `docs/reference/subdomains.md`       | Update with `base` and `dev` tier                                    |
| `docs/architecture/engine.md`        | Update host labels                                                   |
| 15 new controller/view files         | See Phase 3                                                          |

## Related

- `adr/three-engine-consolidation.md`
- `docs/reference/subdomains.md`
- `docs/architecture/engine.md`
