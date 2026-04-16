# Identity / Global / Regional Implementation Plan

## Status

Active draft (2026-04-16)

## Summary

This plan defines the next implementation sequence after the Rails engine split work.

Implementation order:

1. Finish `Identity` as the OAuth 2.1 aligned IDP.
2. Finish `Global` as the RP that auto-provisions local account state on first successful login.
3. Start `Regional` with a thin Next.js-facing bootstrap API, then build the inquiry/contact flow on
   top of that contract.

Current engine mapping in this repository:

- `signature` = `Identity`
- `world` = `Global`
- `station` = `Regional`

Canonical subject names:

- `user`
- `staff`
- `customer`

Do not introduce `client` as a parallel subject name in code, claims, tests, or documentation.

## Identity

### Goal

Use `sign.*` as the canonical IDP and complete the current OIDC flow in an OAuth 2.1 aligned way.

### Scope

- Keep Authorization Code Flow + PKCE (`S256`) as the browser flow.
- Treat `authorize`, `token`, and `jwks` as the stable IDP contract.
- Keep `sign.*` responsible for:
  - primary authentication
  - verification and step-up
  - session lineage
  - token issuance
  - refresh-token validation
  - login-critical identity state

### Implementation changes

- Tighten `authorize` validation:
  - require known `client_id`
  - require exact registered `redirect_uri`
  - require `response_type=code`
  - require `code_challenge`
  - require `code_challenge_method=S256`
- Tighten `token` validation:
  - allow only `grant_type=authorization_code`
  - require client authentication through `Oidc::ClientRegistry`
  - require PKCE verification
  - enforce one-time authorization code consumption
- Keep `jwks` as the public key publication endpoint for RP-side verification.
- Keep claims explicit and stable:
  - `iss`
  - `sub`
  - `aud`
  - `exp`
  - `iat`
  - `auth_time`
  - `sid`
  - `acr`
  - `amr`
  - `jti`
  - explicit subject type

### Acceptance criteria

- Invalid client, redirect URI, grant type, or verifier is rejected with a protocol-appropriate
  error.
- Authorization codes expire and cannot be reused.
- `customer` works through the same OIDC contract as `user` and `staff`.
- `jwks` exposes the active signing key.

## Global

### Goal

Use `world` as an RP that creates local account state after successful OIDC callback completion.

### Provisioning policy

- `user -> Member`
- `staff -> Operator`
- `customer -> no extra local account model for now`

For `customer`, use the identity subject itself as the local subject until a dedicated business
requirement appears.

### Implementation changes

- Keep the current callback structure:
  - validate `state`
  - exchange `code`
  - establish RP auth cookie/session state
- Add a post-exchange provisioning step that is idempotent:
  - find-or-create `Member` for `user`
  - find-or-create `Operator` for `staff`
  - no-op for `customer`
- Implement provisioning in a service object, not in the callback controller.
- Make the provisioning step safe for repeated callback completion and concurrent first logins.
- Fail closed on provisioning errors and log structured events.

### Acceptance criteria

- First successful login for `user` creates exactly one `Member`.
- First successful login for `staff` creates exactly one `Operator`.
- First successful login for `customer` creates no new account model.
- Repeated callbacks do not create duplicates.

## Regional

### Goal

Start `station` with a thin bootstrap API for Next.js before implementing the first business flow.

### Phase 1: thin bootstrap API

Initial API scope:

- `GET /edge/v0/health`
- `GET /edge/v0/preference`
- `GET /edge/v0/session` or `GET /edge/v0/me`

Bootstrap payload should expose only the minimum needed by Next.js:

- whether the session is authenticated
- subject type
- local account summary when one exists
- preference summary for layout/bootstrap needs

### API rules

- JSON-only contract
- strict host constraints per surface
- no cross-surface cookie sharing assumptions
- keep the current auth pipeline order:
  1. RateLimit
  2. Preference
  3. Authentication
  4. StepUp
  5. Authorization
  6. Finisher

### Phase 2: inquiry/contact workflow

After bootstrap API stability:

- add inquiry/contact entry bootstrap for Next.js
- implement submission endpoint
- implement follow-up read endpoint
- keep write orchestration in a service object
- keep controller ownership in `Regional`
- use shared auth helpers and claims, not route-prefix inference

### Non-goals for Phase 1

- Do not treat the current `messages` stub endpoints as the first business contract.
- Do not start with a broad CRUD surface for unrelated business resources.

### Acceptance criteria

- Next.js can determine whether the current visitor is authenticated.
- Next.js can determine the current subject type and basic account summary.
- The bootstrap API works without introducing cross-surface auth coupling.
- Inquiry/contact can be layered on top without changing the bootstrap contract.

## Test Plan

### Identity

- authorization endpoint success and failure cases
- token endpoint success and failure cases
- single-use authorization code enforcement
- PKCE verification
- `customer` coverage
- `jwks` coverage

### Global

- `user` first-login auto-provision
- `staff` first-login auto-provision
- `customer` no-op provisioning
- repeated login idempotency
- provisioning failure behavior

### Regional

- bootstrap endpoint returns JSON-only responses
- authenticated and unauthenticated bootstrap cases
- surface-specific host behavior
- inquiry/contact follow-up tests after the bootstrap contract is stable

## Notes

- Keep this plan in `plans/` because it is future-facing implementation work.
- When the implementation is complete, move current-state behavior explanations into `docs/` as
  needed.
