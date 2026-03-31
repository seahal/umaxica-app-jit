# Application Controller Pipeline Unification

## Goal

Make `app`, `com`, and `org` follow the same application-controller pipeline contract as much as
possible.

`com` has historically diverged from `app` and `org`, but now that `com` also has login-oriented
behavior, it should be treated as a first-class authenticated surface rather than a special case.

## Target Actor Types

- `app` => `user`
- `com` => `customer`
- `org` => `staff`
- unauthenticated state => `unauthenticated`

## Target Pipeline Order

1. RateLimit
2. Preference
3. Authentication
4. StepUp
5. Authorization
6. Current
7. Finisher

## Design Direction

- Keep the application-controller skeleton aligned across all three surfaces.
- Push surface-specific differences into actor-specific concerns rather than into controller-level
  branching.
- Prefer surface-specific adapters such as:
  - `Authentication::User`
  - `Authentication::Customer`
  - `Authentication::Staff`
  - `Verification::User`
  - `Verification::Customer`
  - `Verification::Staff`
  - `Authorization::User`
  - `Authorization::Customer`
  - `Authorization::Staff`
- Avoid keeping `com` as a historical exception once the login-based surface model exists.

## Intended Result

- `app`, `com`, and `org` have nearly identical `ApplicationController` structure.
- The main differences between surfaces are actor type, host/routing namespace, and narrow policy
  differences.
- Authentication determines the actor.
- StepUp determines whether the actor has sufficient verification strength.
- Authorization decides whether the actor may access the target action/resource.
- `Current` is populated only after the above gates are satisfied.

## Notes

- `StepUp` should come before `Authorization`.
- The objective is to unify the pipeline contract, not to erase all domain differences.
- Surface-specific behavior should be isolated behind concerns and hooks wherever possible.
