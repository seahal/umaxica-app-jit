# Routing Rules

## General Rules

- Routes MUST be RESTful
- HTTP methods MUST reflect intent
- Path helpers MUST be used

---

## Host Constraints

- Each surface MUST enforce host constraints
- Never assume a default host
- Cross-surface routing is forbidden

---

## Forbidden Patterns

DO NOT:

- Use `match ... via: :all`
- Use GET for destructive actions
- Hardcode URLs (http:// or https://)
- Expose internal routes publicly

---

## Naming

- Use resourceful routing
- Avoid custom actions unless necessary

---

## Safety

- All state-changing routes MUST be protected by CSRF
- JSON endpoints MUST be explicitly defined
