# Redesign Direction

## Summary

The platform is now organized around three engines:

- `Identity`
- `Global`
- `Regional`

Engine names are responsibility boundaries. Host labels are separate entry labels.

## Current Direction

- `Identity` owns identity, authentication, tokens, and audit-sensitive login state.
- `Global` owns the public `sign` entry surface and shared coordination.
- `Regional` owns `core`, `docs`, `help`, and `news`.
- Models stay centralized in `app/models`.
- Database ownership is expressed through base records and `connects_to`.

## Boundary Rules

- Keep authorization and audit-sensitive writes explicit.
- Keep shared preferences as UX state, not as policy state.
- Keep cross-boundary routing visible through native Rails routing proxies.
- Keep host app routes explicit through `main_app`.
- Keep per-boundary database ownership stable before introducing new splits.

## Database Draft

| Boundary              | Database groups                                                                   |
| --------------------- | --------------------------------------------------------------------------------- |
| Activity              | `principal`, `operator`, `token`, `preference`, `guest`, `activity`, `occurrence` |
| Journal               | `journal`, `notification`, `avatar`                                               |
| Chronicle             | `publication`, `chronicle`, `message`, `search`, `billing`, `commerce`            |
| Shared infrastructure | `queue`, `cache`, `storage`, `cable`                                              |

## Open Questions

- Which shared services should remain in the host app?
- Which boundary should own future policy services?
- Which new data types belong in Regional instead of Global?

## Related Analyses

- [Engine Boundary Plan](./engine-boundary-plan.md)
- [Audit And Evidence Plan](./audit-and-evidence-plan.md)
- [Jurisdiction Rollout Plan](./jurisdiction-rollout-plan.md)
