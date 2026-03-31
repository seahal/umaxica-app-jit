# Surface Pipeline Alignment

## Goal

Reduce structural drift between `app`, `com`, and `org` by aligning their authenticated request
pipeline.

## Direction

- Keep the same high-level pipeline contract across all three surfaces.
- Prefer differences to live in actor-specific concerns, not controller-level branching.
- Align around this order:
  1. RateLimit
  2. Preference
  3. Authentication
  4. StepUp
  5. Authorization
  6. Current
  7. Finisher
- Treat `com` as a first-class authenticated surface now that it has login-oriented behavior.

## Execution Strategy

- First align actor vocabulary.
- Then align `Current` and `CurrentSupport`.
- Then normalize `Authentication::*`, `Verification::*`, and `Authorization::*` concern sets.
- Finally align `ApplicationController` structure.

## Intended Result

- `app`, `com`, and `org` share a nearly identical pipeline skeleton.
- Surface differences are narrow and intentional.
- New features such as message/contact can rely on a stable authNZ contract across surfaces.
