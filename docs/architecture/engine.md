# Engine and Database Boundary Design

## Background

The platform is organized into three Rails engines to enforce operational and code-level isolation:

- `Identity`
- `Global`
- `Regional`

Each engine manages a specific set of domain responsibilities and maps to a dedicated database
group.

## Engine Roles

| Engine       | Namespace       | Host Labels / Entry Points             | Main responsibility                                 | Domain Database Group |
| ------------ | --------------- | -------------------------------------- | --------------------------------------------------- | --------------------- |
| **Identity** | `Jit::Identity` | `sign.{app,com,org,dev}.*`             | Authentication, identity, token lifecycle           | `Activity`            |
| **Global**   | `Jit::Global`   | `{app,com,org,dev}.*` (apex)           | Shared shell, public sign entry, shared preferences | `Journal`             |
| **Regional** | `Jit::Regional` | `base.*`, `docs.*`, `help.*`, `news.*` | Regional business logic, content, and support       | `Chronicle`           |

### Migration Path

The existing extracted engines will be consolidated as follows:

- `signature` -> `Identity`
- `world` -> `Global`
- `station` + `press` -> `Regional`

### Routing and Isolation

- **`isolate_namespace`**: Every engine uses `isolate_namespace` for code-level isolation.
- **Routing Proxies**: Cross-boundary navigation must use native Rails engine routing proxies. The
  mount alias becomes the route proxy (e.g., `identity.*`, `global.*`, `regional.*`).
- **Host App Routes**: Engines must use `main_app.*` to link back to the host application.
- **Host Labels**: Different entry points (like `docs.*` or `base.*`) are handled via host
  constraints in the routing layer of the respective engine.

### Request Context Boundary

Request-scoped current context is also owned by the engine boundary.

- `Identity` uses engine-local current context
- `Global` uses engine-local current context
- `Regional` uses engine-local current context only for `base.*`
- `Regional` `docs.*`, `help.*`, and `news.*` do not use `Current`

If `docs.*`, `help.*`, or `news.*` need request metadata, they should use explicit helpers or small
request-scoped value objects instead of a shared mutable current container.

Engine-local `Current` remains an accepted pattern for request-scoped runtime state. This helps keep
actor, token, preference, and request metadata from leaking across concurrent requests in threaded
app servers such as Puma.

The implementation sequence for this boundary is still **TBC**. Any future `plans/` documents for
this work are temporary and may change.

### Canonical ENV Naming

Host and origin environment variables use this canonical format:

- `ENGINE_HOSTLABEL_AUDIENCE_URL`

Where:

- `ENGINE` is one of `IDENTITY`, `GLOBAL`, `REGIONAL`
- `HOSTLABEL` is one of `SIGN`, `APEX`, `BASE`, `DOCS`, `HELP`, `NEWS`
- `AUDIENCE` is one of `APP`, `COM`, `ORG`

Examples:

- `IDENTITY_SIGN_APP_URL`
- `GLOBAL_APEX_COM_URL`
- `REGIONAL_BASE_ORG_URL`
- `REGIONAL_DOCS_APP_URL`
- `REGIONAL_HELP_COM_URL`
- `REGIONAL_NEWS_ORG_URL`

Legacy names such as `SIGN_*`, `APEX_*`, `MAIN_*`, `CORE_*`, and `DOCS_*` are migration-source names
only. They are not part of the target design.

## Database Ownership

Models are centralized in `app/models/` for shared domain definitions, but each engine is the
operational owner of a specific database group.

### Activity-owned databases (Identity Engine)

- `principal`, `operator`, `token`, `preference`, `guest`, `activity`, `occurrence`

### Journal-owned databases (Global Engine)

- `journal`, `notification`, `avatar`

### Chronicle-owned databases (Regional Engine)

- `publication`, `chronicle`, `message`, `search`, `billing`, `commerce`

### Shared Infrastructure Databases

Infrastructure databases (`queue`, `cache`, `storage`, `cable`) are **duplicated per engine**. Each
of the three engine deployment modes runs its own isolated instance of these services to prevent
cross-engine resource contention.

- **Solid Queue**: Separate job database and worker pool per engine.
- **Solid Cache**: Separate cache database per engine.

## Model and Database Policy

- **Centralized Models**: Shared model definitions stay in `app/models/` to ensure a single source
  of truth for domain logic.
- **Abstract Base Classes**: Database connectivity is partitioned via domain-specific base records
  (e.g., `ActivityRecord`, `JournalRecord`, `ChronicleRecord`) using Rails' `connects_to`.
- **Deployment-Mode Connectivity**: The `database.yml` and initialization logic use the
  `DEPLOY_MODE` environment variable to establish connections _only_ for the database group owned by
  the active engine.
- **Enforced Boundaries**: Attempting to access a model whose database is not owned by the active
  engine will result in a connection error, providing strict operational boundaries while
  maintaining a unified codebase.

## Deployment Modes

| Mode          | Engines mounted            | Infrastructure Mode          |
| ------------- | -------------------------- | ---------------------------- |
| `identity`    | Identity                   | Identity-isolated instances  |
| `global`      | Global                     | Global-isolated instances    |
| `regional`    | Regional                   | Regional-isolated instances  |
| `development` | Identity, Global, Regional | All instances (local config) |

## Related

- `adr/current-context-boundary-by-engine.md`
- `adr/three-engine-consolidation.md`
- `adr/engine-isolate-namespace-adoption.md`
- `docs/architecture/current_context.md`
- `plans/active/three-engine-reframe.md`
- `plans/analysis/engine-boundary-plan.md`
