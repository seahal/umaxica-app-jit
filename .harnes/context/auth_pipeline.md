# Authentication & Authorization Pipeline

## Order (STRICT)

The pipeline MUST follow this order:

1. RateLimit
2. Preference
3. Authentication (AuthN)
4. StepUp (Verification)
5. Authorization (AuthZ)
6. Finisher

Order MUST NOT be changed.

---

## Responsibilities

### RateLimit

- Prevent abuse
- MUST run first

### Preference

- Load user preferences

### Authentication

- Identify user or staff
- MUST NOT be skipped

### StepUp

- Additional verification
- MUST enforce when required

### Authorization

- Enforce access control (Pundit)

### Finisher

- Cleanup / logging

---

## Forbidden

DO NOT:

- Skip authentication
- Skip authorization
- Reorder pipeline
- Inline authorization checks (e.g. `if current_user.admin?`)

---

## Enforcement

All controllers MUST include the full pipeline.
