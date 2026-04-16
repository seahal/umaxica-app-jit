# Detailed Design Specification

## 1. Purpose

This document translates the high-level boundary model into implementation guidance.

## 2. System Context

The Rails monolith is split into three engines:

- `Identity`
- `Global`
- `Regional`

## 3. Module Design

### 3.1 Routing

- Each engine owns its own route file.
- Each engine uses `isolate_namespace`.
- Cross-engine links use native Rails routing proxies.
- Host app links use `main_app`.

### 3.2 Shared Code

| Layer                 | Ownership                                               |
| --------------------- | ------------------------------------------------------- |
| Controllers and views | Engine-specific                                         |
| Models                | Centralized in `app/models`                             |
| Concerns              | Shared in the host app                                  |
| Services              | Shared in the host app unless a later split is required |
| Helpers               | Shared in the host app                                  |

### 3.3 Boundary Responsibilities

| Engine     | Responsibilities                                                            |
| ---------- | --------------------------------------------------------------------------- |
| `Identity` | Identity, authentication, passkeys, tokens, and audit-sensitive login state |
| `Global`   | Public `sign` entry surface, global preferences, and coordination flows     |
| `Regional` | `core`, `docs`, `help`, and `news` business and content flows               |

## 4. Data Design

### 4.1 Database ownership

| Database group                                                                    | Owner                 |
| --------------------------------------------------------------------------------- | --------------------- |
| `principal`, `operator`, `token`, `preference`, `guest`, `activity`, `occurrence` | Activity              |
| `journal`, `notification`, `avatar`                                               | Journal               |
| `publication`, `chronicle`, `message`, `search`, `billing`, `commerce`            | Chronicle             |
| `queue`, `cache`, `storage`, `cable`                                              | Shared infrastructure |

### 4.2 Model policy

- Keep a single model definition when several engines use the same table family.
- Use base records to express database ownership.
- Move a model into an engine only when the boundary truly requires it.

## 5. Key Flows

- Sign-in and token flow happen in `Identity`.
- Public sign entry and shared preference navigation happen in `Global`.
- Content, support, and regional operations happen in `Regional`.

## 6. Verification

- Route tests confirm host isolation.
- Model tests confirm database ownership.
- Integration tests confirm cross-boundary navigation.
- Security tests confirm auth, redirect, and audit rules.
