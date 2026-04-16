# ADR: Consolidate to Three Rails Engines (Identity, Global, Regional)

**Status:** Accepted (2026-04-16)

**Supersedes:** `adr/four-engine-split.md` (2026-04-09)

## Context

The platform is architected as a distributed system consisting of an **Identity Provider (IDP)** and
multiple **Relying Parties (RPs)**. To simplify development while maintaining operational isolation,
these are implemented as separate Rails engines within a single repository.

## Decision

We will consolidate the application into **three independent Rails engines** that function as
separate applications with zero database-level coupling between the IDP and RPs.

### Engine Roles and Scaling

| Engine       | Role           | Deployment Scale | Host Labels / Entry Points             | Domain DB   |
| ------------ | -------------- | ---------------- | -------------------------------------- | ----------- |
| **Identity** | IDP (Identity) | 1 (Global)       | `sign.{app,com,org}.*`                 | `Activity`  |
| **Global**   | RP (Shared)    | 1 (Global)       | `www.{app,com,org}.*` (apex)           | `Journal`   |
| **Regional** | RP (Business)  | **N (Regional)** | `base.*`, `docs.*`, `help.*`, `news.*` | `Chronicle` |

### IDP / RP Separation

- **No Shared Databases**: There is no direct database-level coupling between the `Identity` (IDP)
  and the `Global`/`Regional` (RP) engines. Communication between them is handled exclusively via
  secure protocols (e.g., OIDC, API calls).
- **Independent Applications**: Each engine is treated as a standalone application. When deployed in
  a specific mode (e.g., `DEPLOY_MODE=regional`), it only has access to its own domain database and
  isolated infrastructure instances.

### Database Ownership and Models

While models remain centralized in `app/models/` for unified domain definitions (ensuring schema
consistency across regional instances), database connectivity is strictly partitioned:

- **Abstract Base Classes**: Models are mapped to database groups via domain-specific base classes
  (e.g., `ActivityRecord`, `JournalRecord`, `ChronicleRecord`) using Rails' `connects_to`.
- **Operational Partitioning**: The `database.yml` and initialization logic use the `DEPLOY_MODE`
  environment variable to establish connections _only_ for the database group owned by the active
  engine.
- **Regional Multi-tenancy**: Since there are `N` regional instances, each `Regional` deployment
  connects to its specific regional instance of the `Chronicle` database.
- **Strict Isolation**: Accessing a model whose database is not owned by the active engine will
  result in a connection error, ensuring zero cross-domain leakage.

### Shared Infrastructure

Shared infrastructure databases (`queue`, `cache`, `storage`, `cable`) are **duplicated per engine
instance**.

- Each engine (and each regional instance of the Regional engine) has its own dedicated Solid Queue,
  Solid Cache, and storage configurations.
- This ensures that a failure or heavy load in one engine's infrastructure does not impact the
  others.

### Key Design Points

- **`isolate_namespace`**: Each engine uses its own Ruby namespace (`Jit::Identity`, `Jit::Global`,
  `Jit::Regional`).
- **Native route proxies**: Cross-engine route calls use mount aliases `identity.*`, `global.*`, and
  `regional.*`.
- **Canonical ENV naming**: Host and origin variables use `ENGINE_HOSTLABEL_AUDIENCE_URL` (examples:
  `IDENTITY_SIGN_APP_URL`, `GLOBAL_APEX_COM_URL`, `REGIONAL_BASE_ORG_URL`).
- **Migration Path**: Existing extracted engines will be consolidated as follows: `signature` ->
  `Identity`, `world` -> `Global`, and `station` + `press` -> `Regional`.

## Consequences

### Positive

- **Reduced Complexity**: Eliminated the need for Cloudflare VPC tunnel and a fourth deployment
  unit.
- **Improved Maintainability**: Fewer engines to manage and deploy.
- **Operational Isolation**: Independent infrastructure (queues, etc.) for each engine prevents
  cross-engine resource contention.

### Negative

- **Regional Engine Scope**: The `Regional` engine now has a broader scope, handling both business
  logic and content delivery.
- **Migration Effort**: Existing code extracted to the `press` (Publisher) engine must be merged
  into the `Regional` engine.

## Related

- `adr/four-engine-split.md` (superseded)
- `docs/architecture/engine.md` (updated architecture doc)
- `plans/active/three-engine-reframe.md` (execution plan)
