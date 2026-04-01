# Contact / Auth Integration TODO

This document captures the priority order for rebuilding the contact flow around the existing auth
system.

## 1. Define the shared auth contract

- Decide the canonical inquiry identity model for all surfaces.
- `com`: always `guest`.
- `app`: `guest`, `anonymous_member`, `identified_member`.
- `org`: `guest`, `identified_member`.
- Make the contract read-only from the contact flow side.

## 2. Introduce a third auth subject for `com`

- Add a `client`-class subject so `com` has the same auth shape as `user` and `staff`.
- Keep the surface-specific databases separate if needed, but make the auth interface uniform.
- Align JWT claims so the contact flow can consume the same shape regardless of subject type.

## 3. Map auth state to contact requirements

- Keep `email` and `telephone` checks mandatory for guest contact flows.
- Reuse the existing verification semantics instead of creating a second state machine.
- Clarify which fields are auto-filled from auth and which stay user-entered.

## 4. Rebuild the contact flow as a thin auth consumer

- Move contact UI and controller logic to depend on auth-derived context.
- Avoid introducing new contact-local session state unless it is strictly necessary.
- Treat the JWT as the projection of auth DB state, not as a separate source of truth.

## 5. Preserve existing behavior during migration

- Keep current `app`, `org`, and `com` routes stable until the new contract is ready.
- Preserve the current email/telephone verification flow where possible.
- Add compatibility shims before removing legacy branches.

## 6. Split sign-up paths only where necessary

- `app` already has multiple sign-up paths; identify which paths produce `identified_member`.
- Keep `org` login-only behavior explicit.
- Avoid letting contact logic branch directly on sign-up implementation details.

## 7. Verify cookie and domain behavior

- Confirm the auth cookie scope for `app`, `org`, and `com`.
- Ensure the `com` subject can participate without breaking existing cookie isolation rules.
- Recheck SameSite, secure, and domain settings before changing the auth boundary.

## 8. Decide on rollout order

- Start with the shared auth contract.
- Then add `client`.
- Then adapt contact flows to the shared contract.
- Only after that, remove the old contact-specific assumptions.

## Open questions

- Should `anonymous_member` be allowed to submit contact requests without identifying data?
- Should `guest` on `app` and `org` use exactly the same verification flow as `com`?
- Which auth fields are mandatory for contact submission versus optional metadata?
- Do we keep the legacy contact controllers during the transition, or wrap them behind a new facade?
