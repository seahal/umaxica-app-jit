# Task: Add Migration

## Steps

1. Generate migration
2. Define safe schema changes
3. Avoid destructive changes
4. Ensure reversibility
5. Review impact
6. Write tests if needed

---

## Rules

- No direct data mutation inside migration
- No unsafe operations

---

## Validation

- Migration must run cleanly
- Rollback must work
