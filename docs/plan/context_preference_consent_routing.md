# Context / Preference / Consent Routing Direction

## Working Domain Interpretation

A useful future interpretation is:

- `Context`
  - `Preference`
  - `Consent`

Where:

- `Preference` covers things like theme, language, timezone, and region
- `Consent` covers things like consent flags, consent timestamps, consent version, and
  cookie-category permissions

## Routing Direction

Do not split top-level routing into `/preference` and `/consent` immediately.

For now, the preferred direction is:

- keep the outward-facing route family centered on `/preference`
- allow consent-related screens and actions to live under the preference area
- if finer separation is needed later, prefer nested paths such as `/preference/consent` rather than
  introducing a fully separate top-level `/consent` area too early

## Rationale

- The current implementation and user flow are already organized around preference routes.
- Internal domain separation and outward-facing route separation do not need to happen at the same
  time.
- Preference and consent may still feel like one settings area to end users even if they are
  distinct concepts internally.
- Premature route splitting would add migration cost before the underlying domain model has settled.

## Status

Planning note only. The immediate goal is conceptual separation, not top-level route reorganization.
