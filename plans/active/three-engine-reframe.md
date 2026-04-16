# Three-Engine Reframe Plan

## Status

Active (2026-04-16)

## Architecture Model: IDP / RP Split

The application functions as three independent systems managed within a single repository:

- **Identity (IDP)**: Global identity provider. Scaled at 1.
- **Global (RP)**: Shared entry and global summary. Scaled at 1.
- **Regional (RP)**: Business operations. Scaled at **N (multi-regional)**.

### Target Architecture

| Engine       | Role           | Deployment Scale | Domain DB Group |
| ------------ | -------------- | ---------------- | --------------- |
| **Identity** | IDP (Identity) | 1 (Global)       | `Activity`      |
| **Global**   | RP (Shared)    | 1 (Global)       | `Journal`       |
| **Regional** | RP (Business)  | **N (Regional)** | `Chronicle`     |

## Design Decisions

### 1. Zero Database Coupling between IDP and RP

- Engines do not share databases. `Identity` only sees `Activity` DB. `Global` only sees `Journal`
  DB. `Regional` only sees `Chronicle` DB.
- Any cross-engine data needs are fulfilled via secure protocols (OIDC, API), not SQL.

### 2. Independent Application Behavior

- Each engine is deployed as a standalone unit.
- **Shared Infrastructure**: Each deployment mode (Identity, Global, and each Regional instance)
  runs its own dedicated Solid Queue, Solid Cache, and other infrastructure services.

### 3. Centralized Models, Isolated Connections

- **Location**: Models stay in `app/models/` for schema consistency across N regional instances.
- **Connectivity**: Managed via Abstract Base Classes and `DEPLOY_MODE`-driven `database.yml`.
- **Validation**: Attempting to cross a domain boundary at the SQL level results in a connection
  error.

### 4. Controller Hierarchy (Engine x Audience)

- Each engine implements its own base controllers per audience:
  `Jit::[Engine]::[Audience]::ApplicationController`.
- **Subdomains**: `Regional` engine handles `base.*`, `docs.*`, `help.*`, and `news.*` via internal
  routing constraints.

### 5. Native Routing Proxies

- Retire `CrossEngineUrlHelpers` in favor of native Rails routing proxies.
- **Implementation**: Mount each engine with `as: :identity`, `as: :global`, and `as: :regional`.
- **Usage**: Cross-engine links use the mount alias as the route proxy, such as
  `identity.some_path`, `global.some_path`, or `regional.some_path`.

### 6. Canonical ENV Naming

- **Format**: Host and origin variables use `ENGINE_HOSTLABEL_AUDIENCE_URL`.
- **Examples**: `IDENTITY_SIGN_APP_URL`, `GLOBAL_APEX_COM_URL`, `REGIONAL_BASE_ORG_URL`,
  `REGIONAL_DOCS_APP_URL`, `REGIONAL_HELP_COM_URL`, `REGIONAL_NEWS_ORG_URL`.
- **Migration rule**: Existing `SIGN_*`, `APEX_*`, `MAIN_*`, `CORE_*`, and `DOCS_*` names are
  treated as migration-source names only.

## Migration Mapping

Existing engines will be migrated and merged as follows:

- **`signature`** -> **Identity** (`Jit::Identity`)
- **`world`** -> **Global** (`Jit::Global`)
- **`station`** + **`press`** -> **Regional** (`Jit::Regional`)

## Database Ownership Mapping

- **Identity Engine** => **Activity** database group
- **Global Engine** => **Journal** database group
- **Regional Engine** => **Chronicle** database group

### Shared Infrastructure

- Shared infrastructure (`queue`, `cache`, `storage`, `cable`) will be set up **separately for each
  engine**.
- Each engine should have its own dedicated Solid Queue instances and background worker
  configurations.

## Boundary Rules

- **`isolate_namespace`**: Enabled for all three engines to ensure Ruby-level isolation.
- **`main_app`**: Links to the host application must be explicit.
- **Routing Proxies**: Cross-engine links must use native Rails routing proxies (`identity.*`,
  `global.*`, `regional.*`).
- **ENV Naming**: Host and origin variables must use `ENGINE_HOSTLABEL_AUDIENCE_URL`.
- **Host Constraints**: Subdomain-specific entry points are handled via routing constraints within
  the engine's `routes.rb`.

## Migration Notes

1. **Update routes**: Consolidate current `signature`, `world`, `station`, and `press` mounts into
   the new `Identity`, `Global`, and `Regional` engines.
2. **Rename namespaces**: Align current engine classes and modules with the new namespaces
   (`Jit::Identity`, `Jit::Global`, `Jit::Regional`).
3. **Infrastructure Configuration**: Ensure the `database.yml` and Solid Queue configs support
   independent instances for each engine mode.
4. **Remove Old Code**: Decommission old engine directory names and leftover host labels only after
   the new model is verified.

## Verification

- `bundle exec rails routes`
- `bundle exec rails test`
- Search for leftover references to `four-engine-split`, `Signature`, `Zenith`, `Foundation`,
  `Publisher`.
- Verify each engine mode loads the correct subset of routes and databases.

## Related

- `adr/three-engine-consolidation.md`
- `docs/architecture/engine.md`
