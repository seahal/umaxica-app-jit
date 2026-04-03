# Implementation Notes

## OIDC Callback Integration Tests

The current Apex OIDC callback coverage is too shallow. Route existence and `oidc_client_id` checks
exist, but the callback endpoint behavior itself is not adequately verified.

### Goal

Add request/integration tests for:

- `Apex::App::Auth::CallbacksController`
- `Apex::Org::Auth::CallbacksController`
- `Apex::Com::Auth::CallbacksController`

The same callback concern is shared more broadly, so the test structure should be reusable for:

- `Core::*::Auth::CallbacksController`
- `Docs::*::Auth::CallbacksController`

### What Must Be Verified

#### Success path

- a valid `state` is accepted
- `Oidc::TokenExchangeService.call(...)` is invoked with:
  - `grant_type: "authorization_code"`
  - `code`
  - `redirect_uri`
  - `client_id`
  - `client_secret`
  - `code_verifier`
- auth cookies are written from the token response
- `session[:oidc_code_verifier]`, `session[:oidc_state]`, and `session[:oidc_return_to]` are cleared
- redirect goes to `session[:oidc_return_to]` when present
- fallback redirect goes to `/` when `oidc_return_to` is absent

#### Failure path

- token exchange failure redirects to `/`
- failure sets the expected alert
- failure emits `oidc.callback.failed`

#### State validation

- mismatched `state` raises or is handled as `ActionController::InvalidAuthenticityToken`
- blank expected/actual state pair is accepted only when both are blank
- session state is consumed on validation

#### Cookie behavior

- access token cookie is written
- refresh token cookie is written
- cookie expiry is based on `Authentication::Base::ACCESS_TOKEN_TTL` and
  `Authentication::Base::REFRESH_TOKEN_TTL`

#### Redirect URI construction

- callback uses the correct host
- non-default ports are preserved in `redirect_uri`
- default ports do not add an unnecessary suffix

### Suggested Test Shape

- keep controller-specific tests under:
  - `test/controllers/apex/app/auth/callbacks_controller_test.rb`
  - `test/controllers/apex/org/auth/callbacks_controller_test.rb`
  - `test/controllers/apex/com/auth/callbacks_controller_test.rb`
- add shared helpers in `test/support/` if duplication becomes noisy
- prefer request/integration-style tests over isolated controller stubs

### Stubbing Guidance

- stub `Oidc::TokenExchangeService.call`
- use a small fake result object responding to:
  - `success?`
  - `token_response`
  - `error`
  - `error_description`
- avoid mocking Rails internals when request assertions can prove behavior directly

### Important Context

This OIDC flow is not just local callback plumbing. It is part of the required SSO path between RP
surfaces and `sign.umaxica.{app,org,com}`. Follow-up implementation should align with OAuth 2.1
direction and continue using Authorization Code + PKCE.

Reference:

- <https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1>

### Out of Scope For This Test Task

- redesigning the full SSO architecture
- replacing token transport format
- changing cookie semantics without a separate design decision
