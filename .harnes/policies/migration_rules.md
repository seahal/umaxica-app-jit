# Migration Rules

## Safety First

Migrations MUST:

- Be reversible
- Avoid long locks
- Be backward-compatible

---

## Forbidden

DO NOT:

- drop_table without approval
- remove_column without migration plan
- run large data updates inside migrations
- use application models inside migrations

---

## Required Practices

- Use separate migrations for schema and data
- Add indexes carefully
- Consider production impact

---

## Data Changes

- Use background jobs for large updates
- Avoid blocking operations

---

## Validation

Before applying:

- Ensure rollback is possible
- Ensure no data loss
