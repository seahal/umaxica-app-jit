# Engine Boundary Plan

## Summary

The engine architecture follows a consolidated 3-engine model:

- `Identity`
- `Global`
- `Regional`

Each engine acts as a boundary of responsibility, mapping to a specific set of domain databases and
its own isolated infrastructure instances.

## Engine Boundaries

| Engine       | Namespace       | Host Labels / Entry Points             | Domain Database Group |
| ------------ | --------------- | -------------------------------------- | --------------------- |
| **Identity** | `Jit::Identity` | `sign.{app,com,org}.*`                 | `Activity`            |
| **Global**   | `Jit::Global`   | `www.{app,com,org}.*` (apex)           | `Journal`             |
| **Regional** | `Jit::Regional` | `base.*`, `docs.*`, `help.*`, `news.*` | `Chronicle`           |

### Migration Mapping

- **`signature`** -> **Identity**
- **`world`** -> **Global**
- **`station`** + **`press`** -> **Regional**

### Boundary Rules

- **Shared Models**: Centralized in `app/models/` for unified domain definitions.
- **Database Connectivity**: Managed via Abstract Base Classes and `DEPLOY_MODE` in `database.yml`.
- **Routing Isolation**: Engines use `isolate_namespace` and native Rails routing proxies for
  cross-engine calls.
- **Cross-Engine Links**: Must be explicit through route proxies `identity.*`, `global.*`, and
  `regional.*`.
- **Host App Links**: Must use `main_app.*`.
- **ENV Naming**: Host and origin variables use `ENGINE_HOSTLABEL_AUDIENCE_URL`.
- **Policy Boundaries**: Business logic should not be leaked into route helpers or layouts.

## Database Ownership Mapping

Ownership is expressed through base records and `connects_to` configurations within each engine's
domain.

### Domain-Specific Groups

| Boundary     | Database Group / Domain Databases                                                               |
| ------------ | ----------------------------------------------------------------------------------------------- |
| **Identity** | **Activity**: `principal`, `operator`, `token`, `preference`, `guest`, `activity`, `occurrence` |
| **Global**   | **Journal**: `journal`, `notification`, `avatar`                                                |
| **Regional** | **Chronicle**: `publication`, `chronicle`, `message`, `search`, `billing`, `commerce`           |

### Shared Infrastructure

Shared infrastructure components (`queue`, `cache`, `storage`, `cable`) are **duplicated for each
engine**. Each engine has its own dedicated instances of these components to ensure total
operational isolation and avoid cross-engine load interference.

| Infrastructure | Status                                          |
| -------------- | ----------------------------------------------- |
| **Queue**      | Per-engine Solid Queue instance and worker pool |
| **Cache**      | Per-engine Solid Cache instance                 |
| **Storage**    | Per-engine Active Storage configuration         |
| **Cable**      | Per-engine Action Cable configuration           |

## Risks To Watch

- **Cross-Engine Data Coupling**: Accidentally referencing a database from a different engine's
  group without an interface.
- **Shared Concern Bloat**: Shared controllers/concerns in the host app growing into a "fourth
  engine."
- **Infrastructure Overhead**: Increased resource usage from running three separate queue/cache
  instances.
- **Redundant Model definitions**: Ensuring we keep only one source of truth in `app/models/`.

## Suggested Next Steps

1. Inventory existing base records and update their `connects_to` based on the new 3-group mapping.
2. Mark and refactor all cross-boundary route helper uses to use the engine proxies.
3. Configure `database.yml` and initializers to support per-engine deployment modes for shared
   infrastructure.
4. Prepare for the code-level migration to consolidate current four engines into these three.

## Related Analyses

- `adr/three-engine-consolidation.md`
- `plans/active/three-engine-reframe.md`
