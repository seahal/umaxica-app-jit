# Activity, Journal, and Chronicle Naming

Status: accepted

## Context

The repository uses Rails engine names to define routing, host labels, and responsibility
boundaries. Those names already have deployment meaning:

- `Identity`
- `Global`
- `Regional`

At the same time, the persistence layer needs different names for the new database families and the
model classes that sit on top of them.

## Decision

Keep the Rails engine names as `Identity`, `Global`, and `Regional`.

Use `Activity`, `Journal`, and `Chronicle` for the new database and model naming family.

Recommended mapping:

- `Activity` for identity and audit evidence
- `Journal` for shared global history and summary records
- `Chronicle` for regional detailed records

## Consequences

- Route and host documentation keeps the engine names unchanged.
- Database ownership documentation uses `Activity`, `Journal`, and `Chronicle`.
- Model names should follow the database family names when new models are introduced.
- Future persistence changes can evolve without forcing another engine rename.
- Reviewers should treat engine naming and data naming as separate concerns.

## Notes

- Existing code and documentation that talk about engine boundaries should keep using `Identity`,
  `Global`, and `Regional`.
- New tables, base records, and model families should use the `Activity`, `Journal`, and `Chronicle`
  naming axis.
