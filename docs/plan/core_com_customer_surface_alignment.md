# Core::Com Customer Surface Alignment

## Context

`Sign::Com` has been moved closer to the intended customer-first authentication and verification
shape. `Current` now recognizes `customer` and `unauthenticated`, and `com` preference updates now
dual-write into `CustomerPreference`.

`Core::Com` is still not aligned with that direction. It continues to use `Authentication::User`,
`Authorization::User`, and `Verification::User`, and still behaves like an exception surface rather
than a first-class customer surface.

## Ideal End State

- `Core::Com` is treated as a real customer-facing surface.
- `Core::Com::ApplicationController` no longer depends on `User` concerns for its primary auth
  pipeline.
- The controller pipeline order matches the agreed contract:
  - `RateLimit`
  - `Preference`
  - `Authentication`
  - `StepUp`
  - `Authorization`
  - `Current`
  - `Finisher`
- `customer` is the first-class authenticated actor for `com` flows.
- `Current.actor_type` resolves naturally to `:customer` on authenticated `com` requests.
- Tests for `Core::Com` validate customer-oriented behavior rather than user-oriented legacy
  assumptions.

## Guidance

- Prefer structural alignment over surface-specific exceptions.
- Remove `User`-centric assumptions from `Core::Com` only when the surrounding route and auth
  expectations are ready.
- Keep outward behavior safe while converging the internal actor model.
- Treat this as a follow-up alignment step, not as part of the already completed Phase 3 work.
