# OIDC AuthN Hardening and Acceptance Spec

## Status

Accepted as the current implementation handoff memo for follow-up work by another AI or engineer.

This document is intentionally implementation-oriented. It is meant to be used together with:

- [`docs/spec/terms.md`](/home/jit/workspace/docs/spec/terms.md)
- [`adr/notes/oidc-session-model.md`](/home/jit/workspace/adr/notes/oidc-session-model.md)
- [`adr/notes/oidc-claims-model.md`](/home/jit/workspace/adr/notes/oidc-claims-model.md)
- [`adr/oidc-claims-decision.md`](/home/jit/workspace/adr/oidc-claims-decision.md)
- [`plans/active/oidc-callback-integration-tests.md`](/home/jit/workspace/plans/active/oidc-callback-integration-tests.md)

## Scope

This spec covers:

- authentication hardening
- OIDC claim alignment
- `Current.actor` fail-fast tightening
- acceptance test planning

This spec does not yet cover:

- full Pundit authorization redesign
- `Current.permission`
- final `sid` redesign
- hard revoke / real-time revoke

Those remain separate follow-up work.

## Current Problems

### 1. `Current.actor` is too permissive

The current implementation allows effectively arbitrary values to be assigned into `Current.actor`
and `Current.actor_type`.

That is too weak for a security-sensitive authentication pipeline.

### 2. OIDC claim decisions are not fully reflected in implementation

The repository already has partial JWT/session foundations, but the final agreed OIDC claim contract
is not consistently implemented yet.

Known gaps include:

- no final `subject_type` rollout
- no final `id_token` contract rollout
- no final `acr` / `amr` normalization everywhere
- no final acceptance coverage for step-up downgrade and replay-oriented paths

### 3. Authentication and authorization responsibilities are still mixed

Some policy logic still reads raw token claims too directly.

For now, this spec avoids a full authorization redesign, but the implementation should avoid making
that coupling worse.

### 4. Acceptance coverage is too shallow for attacker-oriented scenarios

Existing tests cover important JWT rejection paths, but the next pass must add broader acceptance
coverage for:

- state replay
- code replay
- `nonce` mismatch
- actor/type mismatch
- step-up expiry
- refresh replay
- revoke-sensitive flows

## Accepted Decisions

## `Current.actor` contract

Allowed values for `Current.actor`:

- `User`
- `Staff`
- `Customer`
- `Unauthenticated.instance`

Allowed values for `Current.actor_type`:

- `:user`
- `:staff`
- `:customer`
- `:unauthenticated`

Any other value must fail fast.

### Implementation rule

Do not use Active Record-style validations here.

Use explicit guard logic in the `Current.actor=` and `Current.actor_type=` setters.

### Failure mode

For this pass:

- raise immediately on invalid assignment
- do not add controller-level rescue yet
- do not add forced logout handling yet

Add `# TODO:` comments noting that a later pass may replace generic exceptions with dedicated
exception classes and may introduce controller-level `rescue_from` handling.

## Claim contract

Use the claim decisions from
[`adr/oidc-claims-decision.md`](/home/jit/workspace/adr/oidc-claims-decision.md).

### `id_token` must claims

- `iss`
- `sub`
- `subject_type`
- `aud`
- `exp`
- `iat`
- `auth_time`
- `sid`
- `nonce`
- `acr`
- `amr`

### `id_token` should claims

- `jti`

### `subject_type`

Allowed values:

- `user`
- `staff`
- `customer`

### `acr`

Allowed values:

- `aal1`
- `aal2`

Rules:

- all post-login flows start at `aal1`
- `passkey` login still starts at `aal1`
- `aal2` is granted only after explicit verification / step-up
- refreshed access tokens downgrade back to `aal1`

### `amr`

Allowed values:

- `email_otp`
- `passkey`
- `apple`
- `google`
- `recovery_code`
- `totp`

Rules:

- `amr` lists methods actually used
- `amr` does not list all available methods
- order should be primary sign-in first, later verification methods after that

## Security assumptions that remain valid

Current auth JWT and preference JWT implementations already reject weak or invalid algorithms.

The codebase already has rejection coverage for:

- `alg: none`
- `HS256` substitution
- unknown `kid`
- missing required claims

Reference implementations and tests:

- auth JWT:
  - [`app/services/auth/token_service.rb`](/home/jit/workspace/app/services/auth/token_service.rb)
  - [`test/controllers/concerns/auth/base_token_test.rb`](/home/jit/workspace/test/controllers/concerns/auth/base_token_test.rb)
- preference JWT:
  - [`app/controllers/concerns/preference/base.rb`](/home/jit/workspace/app/controllers/concerns/preference/base.rb)
  - [`test/models/preference_token_test.rb`](/home/jit/workspace/test/models/preference_token_test.rb)

This follow-up should preserve that behavior and expand coverage rather than weakening it.

## Implementation Guidance

## Phase 1: tighten `Current`

### Required changes

- add explicit guard logic to `Current.actor=`
- add explicit guard logic to `Current.actor_type=`
- reject invalid values with immediate exceptions

### Constraints

- do not add rescue handling in this pass
- do not silently coerce invalid values
- do not mutate invalid values into `Unauthenticated.instance`

### TODO markers

Leave short TODOs for:

- dedicated exception class
- possible future controller-level `rescue_from`
- possible future forced logout / cookie cleanup for malicious input

## Phase 2: align OIDC/auth claim handling

### Required changes

- introduce or align `subject_type`
- normalize `acr`
- normalize `amr`
- ensure `nonce` is part of the final OIDC contract where required

### Constraints

- do not introduce business authorization details into identity claims
- do not add profile or preference data to `id_token`
- keep `sid` redesign out of scope for this pass

## Phase 3: verification and step-up alignment

Existing verification / step-up code already exists and should be reused, not replaced casually.

Relevant areas include:

- [`app/controllers/concerns/verification/base.rb`](/home/jit/workspace/app/controllers/concerns/verification/base.rb)
- [`app/controllers/concerns/sign/verification_timing.rb`](/home/jit/workspace/app/controllers/concerns/sign/verification_timing.rb)
- [`app/controllers/concerns/sign/verification_entry.rb`](/home/jit/workspace/app/controllers/concerns/sign/verification_entry.rb)
- [`app/services/step_up/available_methods.rb`](/home/jit/workspace/app/services/step_up/available_methods.rb)
- [`app/services/step_up/configured_methods.rb`](/home/jit/workspace/app/services/step_up/configured_methods.rb)

The goal is to align them with:

- `aal1` by default
- `aal2` only after explicit verification
- downgrade back to `aal1` on refresh

## Acceptance Test Plan

The acceptance test strategy should combine:

- equivalence partitioning
- boundary value analysis
- attacker-oriented abuse cases

## A. `Current` fail-fast tests

### Positive cases

- assigning `User` succeeds
- assigning `Staff` succeeds
- assigning `Customer` succeeds
- assigning `Unauthenticated.instance` succeeds
- assigning valid actor types succeeds

### Negative cases

- assigning string actor raises
- assigning symbol actor raises
- assigning arbitrary object actor raises
- assigning invalid actor type raises
- assigning nil actor type raises unless explicitly allowed by contract

## B. OIDC callback and token exchange tests

### Positive cases

- valid `state` is accepted
- valid `nonce` is accepted
- valid authorization code and PKCE exchange succeeds
- correct cache headers are present

### Negative cases

- reused authorization code is rejected
- mismatched `redirect_uri` is rejected
- invalid `code_verifier` is rejected
- mismatched `state` is rejected
- mismatched `nonce` is rejected

## C. Claim contract tests

### Positive cases

- `id_token` includes all must claims
- `subject_type` is one of the allowed values
- `acr` is `aal1` after normal login
- `amr` contains the methods actually used

### Negative cases

- invalid `subject_type` is rejected
- invalid `acr` is rejected
- invalid `amr` member is rejected
- missing must claims are rejected

## D. Verification / step-up tests

### Positive cases

- explicit verification upgrades current context to `aal2`
- valid scope and fresh timing pass

### Boundary cases

- `STEP_UP_TTL` just before expiry passes
- `STEP_UP_TTL` at or beyond expiry fails

### Negative cases

- wrong scope fails
- expired verification fails

## E. Refresh / revoke tests

### Positive cases

- refresh rotation succeeds
- old refresh token becomes unusable
- refreshed access token downgrades to `aal1`

### Negative cases

- replayed refresh token is rejected
- revoked session cannot refresh
- device/binding mismatch is rejected

## F. Attacker-oriented tests

At minimum include:

- `alg:none` token substitution
- `HS256` substitution against auth JWT
- `HS256` substitution against preference JWT
- actor/type mismatch
- forged `subject_type`
- callback replay using reused `state`
- refresh replay
- revoked session attempting state-sensitive access

## Out of Scope For This Pass

- full `sid` redesign
- `Current.permission`
- broad Pundit refactor
- hard revoke / Redis-backed immediate invalidation
- controller-level rescue policy for invalid current actor assignments

## Handoff Notes For Implementers

- prefer small, mechanically clear changes
- preserve existing JWT algorithm rejection behavior
- do not improvise a new authorization model in this pass
- keep authentication hardening separate from later Pundit redesign
- add meaningful tests only; do not add shallow assertion-only scaffolding
