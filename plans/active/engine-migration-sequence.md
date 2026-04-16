# Engine Migration Sequence

## Summary

Migrate from 4 extracted engines (signature/world/station/press) without `isolate_namespace` to 3
consolidated engines (Identity/Global/Regional) with `isolate_namespace`, generated via
`bin/rails plugin new --mountable`.

Models remain centralized in `app/models/` throughout the migration.

## Current State

- 4 engines: `Jit::Signature`, `Jit::World`, `Jit::Station`, `Jit::Press`
- No `isolate_namespace` (avoided to prevent mass-renaming)
- Controllers use legacy module names (`Sign::*`, `Apex::*`, `Core::*`, `Docs::*`)
- ENV uses legacy prefixes (`SIGN_*`, `APEX_*`, `CORE_*`/`MAIN_*`, `DOCS_*`)

## Target State

- 3 engines: `Jit::Identity`, `Jit::Global`, `Jit::Regional`
- `isolate_namespace` enabled on all engines
- ENV uses canonical naming (`IDENTITY_SIGN_APP_URL`, `GLOBAL_APEX_COM_URL`, etc.)
- Generated via `bin/rails plugin new --mountable`

## Step 1: Model Organization

> **Open decision (2026-04-16):** Models may move into engine directories (`engines/*/app/models/`)
> instead of staying in `app/models/`. This would align with `isolate_namespace` conventions and
> remove cross-engine model references. Cross-engine data access would use API (`/userinfo` etc.)
> instead of direct DB/association references. Deciding by 2026-04-17.

Verify that all models inherit from the correct base record for their engine's DB group.

Note: "Activity", "Journal", "Chronicle" are conceptual DB group names from
`docs/architecture/engine.md`. No `JournalRecord` or `ChronicleRecord` class exists in code. The
actual base records are listed below.

### Identity engine (Activity DB group)

| Base record        | Database   | Representative models                                   |
| ------------------ | ---------- | ------------------------------------------------------- |
| `PrincipalRecord`  | principal  | User, Staff, Customer, Member, Organization, Workspace  |
| `OperatorRecord`   | operator   | Operator, Department, Division                          |
| `TokenRecord`      | token      | UserToken, StaffToken, CustomerToken, AuthorizationCode |
| `SettingRecord`    | preference | SettingPreference, UserPreference, StaffPreference      |
| `GuestRecord`      | guest      | AppContact, ComContact, OrgContact                      |
| `ActivityRecord`   | activity   | UserActivity, StaffActivity, ScavengerGlobal            |
| `OccurrenceRecord` | occurrence | IpOccurrence, EmailOccurrence, JwtOccurrence            |

### Global engine (Journal DB group)

| Base record          | Database     | Representative models                        |
| -------------------- | ------------ | -------------------------------------------- |
| `NotificationRecord` | notification | UserNotification, StaffNotification, Banners |
| `AvatarRecord`       | avatar       | Avatar, Handle, AvatarFollow, AvatarBlock    |

### Regional engine (Chronicle DB group)

| Base record         | Database    | Representative models                               |
| ------------------- | ----------- | --------------------------------------------------- |
| `PublicationRecord` | publication | AppDocument, ComTimeline, Post, PostVersion, tags   |
| `BehaviorRecord`    | behavior    | ContactBehavior, DocumentBehavior, TimelineBehavior |
| `MessageRecord`     | message     | UserMessage, StaffMessage, OperatorMessage          |
| `SearchRecord`      | search      | SearchBehavior                                      |
| `BillingRecord`     | billing     | BillingBehavior                                     |
| `CommerceRecord`    | commerce    | (future — currently misused by com*preference*\*)   |

### Known misplacements (to fix in this step)

- `com_preference_*` models inherit `CommerceRecord` (commerce DB) but are preference data. Must
  change to `SettingRecord` (preference DB, Identity engine).

## Step 2: Engine Generation and DB Configuration

Generate 3 new mountable engines:

```bash
bin/rails plugin new engines/identity --mountable
bin/rails plugin new engines/global --mountable
bin/rails plugin new engines/regional --mountable
```

Configure each engine:

1. Set `isolate_namespace` to `Jit::Identity`, `Jit::Global`, `Jit::Regional`
2. Set `engine_name` (`jit_identity`, `jit_global`, `jit_regional`)
3. Configure DB connections per engine in `database.yml` and engine initializers
4. Set up migration directories per engine

The old engines (signature/world/station/press) remain in place during migration. New and old
engines coexist until Step 6.

## Step 3: Routing Migration

Move route definitions from current engines into new engines. Update host constraints to canonical
ENV naming.

| Current                       | Target                   |
| ----------------------------- | ------------------------ |
| `SIGN_SERVICE_URL`            | `IDENTITY_SIGN_APP_URL`  |
| `SIGN_CORPORATE_URL`          | `IDENTITY_SIGN_COM_URL`  |
| `SIGN_STAFF_URL`              | `IDENTITY_SIGN_ORG_URL`  |
| `APEX_SERVICE_URL`            | `GLOBAL_APEX_APP_URL`    |
| `APEX_CORPORATE_URL`          | `GLOBAL_APEX_COM_URL`    |
| `APEX_STAFF_URL`              | `GLOBAL_APEX_ORG_URL`    |
| `CORE_SERVICE_URL`/`MAIN_*`   | `REGIONAL_BASE_APP_URL`  |
| `CORE_CORPORATE_URL`/`MAIN_*` | `REGIONAL_BASE_COM_URL`  |
| `CORE_STAFF_URL`/`MAIN_*`     | `REGIONAL_BASE_ORG_URL`  |
| `DOCS_SERVICE_URL`            | `REGIONAL_DOCS_APP_URL`  |
| (new)                         | `*_DEV_URL` for dev tier |

Add legacy ENV fallbacks during migration. Remove in Step 6.

## Step 4: Controller, View, and Helper Migration

Move controllers, views, and helpers from current engine directories into new engines. Rename module
namespaces to match `isolate_namespace`.

Namespace mapping:

| Current        | Target (under isolate_namespace)    |
| -------------- | ----------------------------------- |
| `Sign::App::*` | within `Jit::Identity` engine scope |
| `Sign::Com::*` | within `Jit::Identity` engine scope |
| `Sign::Org::*` | within `Jit::Identity` engine scope |
| `Apex::App::*` | within `Jit::Global` engine scope   |
| `Apex::Com::*` | within `Jit::Global` engine scope   |
| `Apex::Org::*` | within `Jit::Global` engine scope   |
| `Core::App::*` | within `Jit::Regional` engine scope |
| `Core::Com::*` | within `Jit::Regional` engine scope |
| `Core::Org::*` | within `Jit::Regional` engine scope |
| `Docs::App::*` | within `Jit::Regional` engine scope |

The exact class name structure under `isolate_namespace` depends on how host labels are organized
inside each engine. This will be detailed when Step 4 begins.

## Step 5: Test Migration

### Stays in host (`test/`)

| Directory                    | Reason                                  |
| ---------------------------- | --------------------------------------- |
| `test/models/`               | Models are centralized in `app/models/` |
| `test/unit/`                 | Shared utilities, no DB required        |
| `test/controllers/concerns/` | Shared controller concerns              |
| `test/concerns/`             | Shared model concerns                   |
| `test/fixtures/`             | Shared by all engines                   |
| `test/support/`              | Shared test helpers                     |
| `test/config/`               | Configuration tests                     |
| `test/lib/`                  | Library tests                           |
| `test/initializers/`         | Initializer tests                       |

### Moves to engine (`engines/*/test/`)

| Directory           | Target engine (by domain)                        |
| ------------------- | ------------------------------------------------ |
| `test/services/`    | Split by domain: auth/sign/oidc → Identity, etc. |
| `test/policies/`    | Split by domain: user/staff → Identity, etc.     |
| `test/integration/` | Split by domain: sign flows → Identity, etc.     |
| `test/helpers/`     | Split by owning engine                           |
| `test/mailers/`     | Split by owning engine                           |
| `test/jobs/`        | Split by owning engine                           |
| `test/views/`       | Split by owning engine                           |
| `test/forms/`       | Split by owning engine                           |
| `test/validators/`  | Split by owning engine                           |
| `test/subscribers/` | Split by owning engine                           |
| `test/errors/`      | Split or keep in host (evaluate per file)        |

## Step 6: Cleanup

1. Remove old engines (`engines/signature/`, `engines/world/`, `engines/station/`, `engines/press/`)
2. Remove legacy ENV fallbacks (`SIGN_*`, `APEX_*`, `CORE_*`, `MAIN_*`, `DOCS_*`)
3. Update CI (`.github/workflows/integration.yml`)
4. Update documentation (`docs/`, `adr/`)
5. Update `AGENTS.md` and `CLAUDE.md` references

## Dependencies and Risks

- Step 1 must complete before Step 2 (model ownership must be settled first)
- Steps 2-4 can overlap if done engine-by-engine (e.g., complete Identity end-to-end, then Global)
- Old and new engines coexist during Steps 2-5 to allow incremental migration
- `isolate_namespace` changes how route helpers are generated — all cross-engine links must be
  updated
- Test migration in Step 5 depends on engine routing (Step 3) and controllers (Step 4)

## Related

- `docs/architecture/engine.md` — target engine design
- `adr/three-engine-consolidation.md` — consolidation decision
- `adr/engine-isolate-namespace-adoption.md` — isolate_namespace decision
- `plans/active/dev-audience-tier.md` — dev tier addition (parallel work)
