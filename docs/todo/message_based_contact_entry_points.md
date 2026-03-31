# Message-Based Contact Entry Points

## Context

Outward-facing Rails routes and controllers may still use `contact`, but the internal domain concept
is `message`.

This means:

- `contact` is a kind of `message`
- controller/routing semantics may expose `contact`
- model/storage semantics should converge on `message`
- `message` owns lifecycle and state
- this is not a public API yet
- legacy guest verification compatibility is not required

## Current Direction

- Keep `contact` as an external-facing term where URL and controller semantics need it.
- Use `message` as the internal domain concept and future persistence center.
- Allow controller/model duality intentionally instead of forcing premature naming unification.
- Treat both anonymous-style logged-in actors and richer identified actors as future users of the
  same message domain.
- Keep the Rails implementation skeletal until message attributes and authNZ policy shape are ready.

## Ideal End State

- Rails entry points make it clear that `contact` and `message` are two views of the same domain.
- The internal model layer centers on `message`, not legacy guest-contact verification concepts.
- `message` is the unit that owns state.
- The same domain can back both contact-like communication and direct-message-like communication.
- Future Next.js integration can target Rails-side entry points without depending on legacy flow
  semantics.

## Not Decided Yet

- Final message attribute schema
- Final authNZ policy design
- Final actor-specific authorization boundaries
- Exact surface-specific differences between `com` and `app`
