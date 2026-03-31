# Preference Surface Unification

## Goal

Make the preference experience across `app`, `com`, and `org` feel structurally consistent.

## Direction

- Keep outward-facing preference routes and pages per surface.
- Reduce unnecessary controller-level drift between surfaces.
- Push update logic into shared preference concerns wherever possible.
- Keep surface-specific differences limited to prefix, actor/resource mapping, and narrow UI needs.

## Intended Result

- `app`, `com`, and `org` preference controllers follow the same shape.
- Region, language, timezone, theme, cookie, and reset flows behave consistently across surfaces.
- Future `customer` preference integration in `com` does not feel like a one-off exception.
