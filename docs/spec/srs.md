# Software Requirements Specification

## 1. Purpose

This specification defines the target Rails architecture for the platform. The system uses three
engines:

- `Identity` for identity and authentication internals
- `Global` for the public sign shell and global coordination
- `Regional` for regional business, content, and support

Host labels and engine names are separate. Host labels are entry points. Engine names are
responsibility boundaries.

## 2. Scope

- `Identity` owns sign-in, passkeys, tokens, and identity state.
- `Global` owns the public `sign` entry surface, shared coordination, and shared preferences.
- `Regional` owns `core`, `docs`, `help`, and `news`.
- Models stay centralized in `app/models`, while database ownership is assigned by engine.
- Shared concerns, services, helpers, and layouts remain in the host app.

## 3. External Surfaces

| Boundary | Typical entry labels                   | Main purpose                              |
| -------- | -------------------------------------- | ----------------------------------------- |
| Identity | internal boundary                      | Authentication and identity internals     |
| Global   | `sign.*`                               | Shared coordination and public sign entry |
| Regional | `base.*`, `docs.*`, `help.*`, `news.*` | Business, content, and support flows      |

## 4. Functional Requirements

- Each boundary must enforce host constraints at the route layer.
- Identity flows must support registration, authentication, passkeys, and token lifecycle.
- Global flows must support shared preferences and cross-surface navigation.
- Regional flows must support core operations, content publication, support contacts, and news.
- Database ownership must match the assigned engine boundary.
- Cross-boundary routing must use native Rails routing proxies and `main_app` for host app links.
- Security-sensitive writes must continue to use encryption, audit logging, and structured errors.

## 5. Data and Boundary Rules

| Database group                                                                    | Owner                 |
| --------------------------------------------------------------------------------- | --------------------- |
| `principal`, `operator`, `token`, `preference`, `guest`, `activity`, `occurrence` | Activity              |
| `journal`, `notification`, `avatar`                                               | Journal               |
| `publication`, `chronicle`, `message`, `search`, `billing`, `commerce`            | Chronicle             |
| `queue`, `cache`, `storage`, `cable`                                              | Shared infrastructure |

## 6. Non-Functional Requirements

- Keep host mismatch behavior strict.
- Keep security and audit behavior explicit.
- Keep health endpoints fast.
- Keep docs and plans synchronized with the current boundary model.
- Keep shared model definitions stable unless a boundary change requires relocation.

## 7. Verification

- Route tests must confirm that each boundary resolves only its own hosts.
- Model and database tests must confirm that each base record uses the assigned database group.
- Security tests must confirm that auth, redirect, and audit rules still hold.
- Integration tests must confirm that `core`, `docs`, `help`, and `news` remain regional labels.
