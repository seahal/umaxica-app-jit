# RFC 9068 Access Token Profile

## Status

Accepted (2026-09-10)

## Context

First-party `auth_access` and `preference_access` JWTs used a private header `typ`, duplicated
payload typing, a numeric `sub`, a private `scp` array, optional `client_id`, and a registered
`act` claim whose meaning collided with RFC 8693. Resource-type suffixes were also folded into
`iss`.

UMAXICA needs a stable access-token contract that matches RFC 9068 as closely as possible while
keeping the existing ES384-only key policy.

## Decision

UMAXICA JWT access tokens follow RFC 9068 in token structure, claims, semantics, and validation
requirements. ES384 is the sole supported signing algorithm. UMAXICA intentionally does not
implement the RFC 9068 §2.1 requirement that conforming authorization servers and resource servers
include RS256 among their supported signature algorithms.

This is an RFC 9068 profile with one documented interoperability deviation. ES384 itself is
permitted by RFC 9068; the deviation is the absence of RS256 support. `alg=none` and every
algorithm other than ES384 are rejected. The verifier does not treat the token-provided `alg` as
authorization to select an arbitrary algorithm.

Both `auth_access` and preference access tokens use JOSE:

```json
{ "alg": "ES384", "kid": "...", "typ": "at+jwt" }
```

Required claims: `iss`, `exp`, `aud`, `sub`, `client_id`, `iat`, `jti`.

### Claim semantics

- `iss` identifies the authorization server for that token family and environment. Cookie
  `auth_access` tokens share `AUTH_JWT_ISSUER` (no resource-type suffix). Preference tokens use
  `PREFERENCE_JWT_ISSUER` because they are issued from a distinct keyring. OIDC access tokens keep
  the Acme issuer URL.
- `aud` identifies the resource server. First-party cookie auth uses
  `AUTH_JWT_{CLIENT,OPERATOR,VISITOR}_AUDIENCES` (`umaxica-api-*`). Preference tokens use the
  surface hosts that consume the host-scoped cookie.
- `client_id` identifies the first-party OAuth client that obtained the token
  (`AUTH_JWT_{CLIENT,OPERATOR,VISITOR}_CLIENT_ID`, `PREFERENCE_JWT_CLIENT_ID`). It is not copied
  from `aud`.
- `sub` is a string. For first-party cookie `auth_access` it is the resource owner's durable
  numeric id as a decimal string. For preference tokens it is the preference record `public_id`
  (the preference document identity; guests have no account subject). OIDC access tokens continue
  to use `OidcSubject`.
- `scope` is the RFC 8693 space-delimited string. Actor domain is `domain:client|operator|visitor`
  rather than a registered `act` claim. Preference tokens use `scope=preference`.
- `acr`, `nbf`, `sid`, `authn_ctx`, `amr`, `cnf`, and preference application data remain as
  documented private or optional claims. Application preferences live only in the private
  `preferences` object.

Token families are distinguished by issuer, audience, client identity, and scope. Payload `typ` is
not reintroduced.

### Environment isolation

Development, test, and production use non-overlapping issuer, key, and audience configuration.
Production configuration fails closed: localhost/test audiences are rejected, development/test
kids are not publishable outside local Rails environments, and a production verifier does not
accept another environment's issuer.

## Consequences

- Existing development/test JWTs become invalid after this change. Dual-issuance is not provided.
- Rails consumers read `scope` instead of `scp` and derive actor type from `domain:*`.
- Frontend code does not decode these JWTs for authorization.
