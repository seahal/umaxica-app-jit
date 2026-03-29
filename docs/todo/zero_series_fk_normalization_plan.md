# 0-Series FK Sentinel Normalization Plan

Created: 2026-03-29

## Goal of Step 1

This document fixes the initial classification for GitHub issue `#571`.
The purpose of this step is not to rewrite every fixed-ID master immediately.
The purpose is to decide which kinds of models belong to the early phases and which must wait.

## Classification Rules

### 1. `status` / `dbsc_status`

These are the highest-priority targets for `#571`.

Reason:

- many reference columns already use `default: 0`
- these models often encode `NOTHING` explicitly
- the business meaning of `0 = unset / none / null-like sentinel` is usually clearer here than in
  category/tag trees

Initial target set:

- `app/models/app_preference_status.rb`
- `app/models/app_preference_dbsc_status.rb`
- `app/models/user_telephone_status.rb`
- `app/models/user_token_dbsc_status.rb`
- `app/models/com_document_status.rb`
- `app/models/workspace_status.rb`
- `app/models/zip_occurrence_status.rb`

Additional likely Phase 1 candidates discovered in code:

- `app/models/com_preference_status.rb`
- `app/models/org_preference_status.rb`
- `app/models/customer_status.rb`
- `app/models/staff_status.rb`
- `app/models/email_occurrence_status.rb`
- `app/models/telephone_occurrence_status.rb`
- `app/models/ip_occurrence_status.rb`
- `app/models/area_occurrence_status.rb`
- `app/models/domain_occurrence_status.rb`
- `app/models/user_occurrence_status.rb`
- `app/models/jwt_occurrence_status.rb`

### 2. `option`

These are Phase 2 candidates.

Reason:

- some option tables are effectively reference defaults
- but many are not null-like sentinels and should not be normalized mechanically

Rule for this phase:

- only include an option model if `NOTHING`/`NONE` truly means “unset”
- do not move ordinary default choices into `0`

### 3. `category_master` / `tag_master`

These are Phase 3 candidates.

Reason:

- several already have `parent_id` or tree structure concerns
- `NOTHING` here often behaves more like a root or placeholder node than a true null sentinel
- these tables need per-model review before any `0` normalization

Examples explicitly deferred:

- `app/models/app_document_category_master.rb`
- `app/models/app_document_tag_master.rb`
- `app/models/com_document_category_master.rb`
- `app/models/com_document_tag_master.rb`
- timeline category/tag masters

### 4. `behavior_level` / `behavior_event`

These are Phase 4 candidates.

Reason:

- they are numerous
- they are often activity/audit taxonomy rather than user-facing state
- their `NOTHING` values may be legacy placeholders, not null-equivalents

Examples explicitly deferred:

- `app/models/app_contact_behavior_event.rb`
- `app/models/app_contact_behavior_level.rb`
- `app/models/app_timeline_behavior_event.rb`
- `app/models/app_timeline_behavior_level.rb`
- `app/models/com_contact_behavior_event.rb`
- `app/models/com_contact_behavior_level.rb`

## Step 1 Decision

`#571` will start with `status` and `dbsc_status` only.

That means:

- Step 2 will create the per-model old-to-new mapping table only for `status` / `dbsc_status`
- `option`, `category_master`, `tag_master`, and `behavior_*` remain explicitly out of scope until
  the first mapping pass is complete

## Why this split is safe

- It matches the issue’s stated phase order.
- It avoids changing tree-like master tables before their semantics are understood.
- It reduces the risk of breaking foreign keys that currently depend on non-zero placeholder IDs.
- It gives a smaller set where `id = 0` can be introduced, seeded, and tested deterministically.

## Exit Criteria for Step 1

Step 1 is complete when:

- the target classes are grouped into the four buckets above
- Phase 1 is explicitly limited to `status` / `dbsc_status`
- deferred categories are written down so later changes do not accidentally widen scope
