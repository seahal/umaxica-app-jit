# Test Specification

## Scope

This document defines how the Rails platform is verified across the current boundary model:

- `Identity` for identity and authentication
- `Global` for the shared shell and coordination surface
- `Regional` for `core`, `docs`, `help`, and `news`

## References

- `docs/spec/srs.md`
- `docs/architecture/hld.md`
- `docs/architecture/dds.md`
- `docs/tasks/checklist.md`

## Test Approach

- Ruby tests cover controllers, models, services, and boundary-specific routing.
- JS tests cover surface scripts and UI helpers.
- Integration tests cover cross-boundary redirects, host constraints, and public versus staff flows.
- Security tests cover auth, redirect safety, encryption, and request throttling.
- Performance checks focus on health endpoints, sign-in paths, and contact flows.

## Boundary Matrix

| Boundary   | Primary hosts                          | Coverage focus                                               |
| ---------- | -------------------------------------- | ------------------------------------------------------------ |
| `Identity` | `sign.*`                               | Auth, passkeys, token flows, audit writes                    |
| `Global`   | `sign.*`                               | cross-surface coordination, shared preferences, host routing |
| `Regional` | `base.*`, `docs.*`, `help.*`, `news.*` | content, support, business operations                        |

## Core Cases

- host mismatch returns 404
- redirect targets stay on the allow-list
- sign-in and passkey flows write the expected cookies and tokens
- regional contact and content flows validate input and persist encrypted data
- cross-boundary helpers use native engine routing proxies
- database ownership matches the engine assigned to the record class

## Non-Functional Checks

- health endpoints stay fast
- lint and test suites remain green
- audit and security checks run before release
- docs and plans stay synchronized with the current boundary model
