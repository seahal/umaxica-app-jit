# 0-Series FK Normalization: Phase 1 Mapping

Created: 2026-03-29

This document is Step 2 for issue `#571`.
It records the current `NOTHING` value, the likely target mapping, and the current reference-column
default for Phase 1 models only.

## Mapping Rule for Phase 1

- target rule: `NOTHING = 0`
- if the reference column already defaults to `0`, the main work is model/seed/data consistency
- if the reference column defaults to the old `NOTHING` value, the migration must move data first
  and switch the model constant/default last

## Phase 1 Table

| Model | Kind | Current `NOTHING` | Target | Reference column default now | Notes |
| --- | --- | ---: | ---: | ---: | --- |
| `AppPreferenceStatus` | status | 2 | 0 | `app_preferences.status_id = 2` | `DELETED = 1`, `DEFAULTS = [1,2]`, has `ensure_defaults!` |
| `AppPreferenceDbscStatus` | dbsc_status | 0 | 0 | `app_preferences.dbsc_status_id = 0` | Already normalized for `NOTHING`; separate `#572` may later reorder `PENDING/ACTIVE` |
| `UserTelephoneStatus` | status | 5 | 0 | `user_telephones.user_identity_telephone_status_id = 1` | default is `UNVERIFIED`, not `NOTHING`; needs per-flow review |
| `UserTokenDbscStatus` | dbsc_status | 0 | 0 | `user_tokens.user_token_dbsc_status_id = 0` | Already normalized for `NOTHING`; separate `#572` may later reorder success IDs |
| `ComDocumentStatus` | status | 6 | 0 | `com_documents.status_id = 0` | DB already defaults to `0`; model constant is inconsistent |
| `WorkspaceStatus` | status | 1 | 0 | `organizations.workspace_status_id = 0` | blocked: current FK points to `organization_statuses`, so this needs schema/association review before normalization |
| `ZipOccurrenceStatus` | status | 2 | 0 | `zip_occurrences.status_id = 2` | model default currently follows old `NOTHING = 2` |
| `ComPreferenceStatus` | status | 2 | 0 | `com_preferences.status_id = 2` | same shape as `AppPreferenceStatus` |
| `OrgPreferenceStatus` | status | 2 | 0 | `org_preferences.status_id = 2` | same shape as `AppPreferenceStatus` |
| `CustomerStatus` | status | 2 | 0 | `customers.status_id = 2` | `ACTIVE = 1`, `RESERVED = 3` |
| `StaffStatus` | status | 2 | 0 | `staffs.status_id = 2` | `ACTIVE = 1`, `RESERVED = 3` |
| `EmailOccurrenceStatus` | status | 2 | 0 | `email_occurrences.status_id = 2` | occurrence pattern |
| `TelephoneOccurrenceStatus` | status | 2 | 0 | `telephone_occurrences.status_id = 2` | occurrence pattern |
| `IpOccurrenceStatus` | status | 2 | 0 | `ip_occurrences.status_id = 2` | occurrence pattern |
| `AreaOccurrenceStatus` | status | 2 | 0 | `area_occurrences.status_id = 2` | occurrence pattern |
| `DomainOccurrenceStatus` | status | 4 | 0 | `domain_occurrences.status_id = 4` | `ACTIVE=1`, `DELETED=2`, `INACTIVE=3`, `PENDING=5` |
| `UserOccurrenceStatus` | status | 1 | 0 | `user_occurrences.status_id = 1` | `ACTIVE = 2` today |
| `JwtOccurrenceStatus` | status | 1 | 0 | `jwt_occurrences.status_id = 1` | `ACTIVE = 2` today |

## Initial Buckets

### A. Already normalized for `NOTHING = 0`

These stay in Phase 1 review, but they do not need `NOTHING -> 0` data migration:

- `AppPreferenceDbscStatus`
- `UserTokenDbscStatus`

### B. DB default already uses `0`, but model constant is still non-zero

These are the safest first implementation targets because the database is already pointing at `0`:

- `ComDocumentStatus`

Main work:

- ensure `id = 0` seed exists
- change model constant to `NOTHING = 0`
- check callers that currently assume old fixed IDs

### C. DB default still points at the old `NOTHING` value

These require a real staged migration:

- `AppPreferenceStatus`
- `ComPreferenceStatus`
- `OrgPreferenceStatus`
- `CustomerStatus`
- `StaffStatus`
- `ZipOccurrenceStatus`
- `EmailOccurrenceStatus`
- `TelephoneOccurrenceStatus`
- `IpOccurrenceStatus`
- `AreaOccurrenceStatus`
- `DomainOccurrenceStatus`
- `UserOccurrenceStatus`
- `JwtOccurrenceStatus`

### D. Special review cases inside Phase 1

- `UserTelephoneStatus`

Reason:

- this model has `NOTHING = 5`, but new records default to `UNVERIFIED = 1`
- it should still be normalized eventually, but it is not the safest first migration because
  `NOTHING` is not the normal creation default

## Step 2 Decision

The first actual implementation slice for `#571` should start with Bucket B:

- `ComDocumentStatus`
- `WorkspaceStatus` is blocked for now because `organizations.workspace_status_id` currently points to `organization_statuses`, not `workspace_statuses`

Reason:

- `ComDocumentStatus` already has `default: 0` on the reference side
- it clearly carries a FIXME saying `NOTHING` should become `0`
- it avoids the wider migration risk of changing active runtime defaults first
- `WorkspaceStatus` looked similar at first, but the actual FK/association wiring is inconsistent and must be split into a separate cleanup track

## Deferred to Step 3

Step 3 should define the exact migration order for Bucket B first, then Bucket C.
