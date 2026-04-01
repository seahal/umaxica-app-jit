# Task: Implement Controller

## Steps

1. Define route (RESTful)
2. Create controller
3. Include pipeline concerns
4. Implement action logic
5. Apply authentication
6. Apply authorization (Pundit)
7. Handle errors properly
8. Add tests

---

## Requirements

- Must respect pipeline order
- Must not bypass auth
- Must not include business logic

---

## Testing

Must include:

- authorized case
- unauthorized case
- invalid input

---

## Forbidden

DO NOT:

- skip pipeline
- hardcode URLs
- use permit! blindly
