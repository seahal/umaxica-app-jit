# Regional Help Surface Plan

## Status

Active draft (2026-04-16)

## Summary

Keep `help` as a reserved `Regional` surface while `docs/news` are implemented first.

Fixed constraints:

- `help` is separate from `docs/news`
- inquiry/contact is owned by `base`
- `help` has no v1 homepage requirement
- `help` has no immediate content implementation requirement
- future `help` editing belongs only to the `org` staff CMS surface
- future `help` content should be document-like
- `help` remains inside the same `Regional` content database group as `docs/news`

## Current Position

For the current phase, `help` should remain available as a boundary and route namespace, but should
not drive feature work.

What to preserve now:

- keep the `help` route namespace and host boundary intact
- keep `help` out of inquiry/contact controller work
- keep `help` independent from `docs/news` controller implementation

What not to build now:

- no homepage requirement
- no public FAQ API requirement
- no taxonomy requirement
- no staff CMS controller implementation requirement

## Future Implementation Rules

When `help` becomes an active implementation target:

- editing must happen only from the `org` staff CMS surface
- content should follow a document-like editorial flow
- document-like means:
  - entry
  - draft/history record
  - public snapshot record
- the public contract may be smaller than `docs/news` at first, but it must remain extensible toward
  the same editorial shape

This keeps `help` compatible with future FAQ or support-article expansion without tying it to
inquiry workflows.

## Deferred Decisions

These decisions are intentionally deferred to the later `help` implementation track:

- whether `help` reuses the exact `Document` family or introduces a dedicated document-like family
- whether public read starts with homepage, FAQ list/show, or broader article delivery
- whether taxonomy is needed for `help`
- whether FAQ is the only content type or whether guides/articles are included from day one

## Test Plan

Current phase:

- `help` route and host ownership remain intact
- `help` is not used by inquiry/contact work
- `docs/news` work does not introduce accidental coupling to `help`

Future `help` phase:

- editing is restricted to `org`
- document-like draft/publish behavior is enforced
- `help` stays separate from `base` inquiry/contact behavior

## Assumptions

- leaving `help` inactive for now is acceptable
- the current need is to preserve a safe direction, not to ship a `help` feature immediately
- future `help` work should keep the same expansion path as `docs/news`, even if the first public
  feature set is smaller
