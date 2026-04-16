# Subdomain Map

Subdomain labels are entry points. They are not the same thing as engine boundaries.

## Host Labels

- `sign` -> public sign entry surface owned by Identity
- `base` -> regional operations and management surface (formerly `core` / `ww`)
- `apex` -> global shared entry surface
- `docs` -> regional documentation surface
- `help` -> regional support and contact surface
- `news` -> regional newsroom and timeline surface

## Audience Tiers

Each host label is combined with an audience tier to form the full hostname.

| Tier  | Purpose                             | Example (base)       |
| ----- | ----------------------------------- | -------------------- |
| `com` | Corporate and public-facing content | `base.com.localhost` |
| `app` | End-user service                    | `base.app.localhost` |
| `org` | Staff operations                    | `base.org.localhost` |
| `dev` | Developer and operational tooling   | `base.dev.localhost` |

## Full Hostname Matrix

| Host label | `com`                | `app`                | `org`                | `dev`                |
| ---------- | -------------------- | -------------------- | -------------------- | -------------------- |
| (apex)     | `com.localhost`      | `app.localhost`      | `org.localhost`      | `dev.localhost`      |
| `sign`     | `sign.com.localhost` | `sign.app.localhost` | `sign.org.localhost` | `sign.dev.localhost` |
| `base`     | `base.com.localhost` | `base.app.localhost` | `base.org.localhost` | `base.dev.localhost` |
| `docs`     | `docs.com.localhost` | `docs.app.localhost` | `docs.org.localhost` | —                    |
| `help`     | `help.com.localhost` | `help.app.localhost` | `help.org.localhost` | —                    |
| `news`     | `news.com.localhost` | `news.app.localhost` | `news.org.localhost` | —                    |

The `dev` tier is initially available on Identity (`sign`), Global (apex), and Regional (`base`)
engines only. Regional content host labels (`docs`, `help`, `news`) do not have a `dev` tier.

## Canonical ENV Naming

Host and origin environment variables use this canonical format:

- `ENGINE_HOSTLABEL_AUDIENCE_URL`

Examples:

- `IDENTITY_SIGN_APP_URL`
- `GLOBAL_APEX_ORG_URL`
- `REGIONAL_BASE_COM_URL`
- `REGIONAL_DOCS_APP_URL`
- `REGIONAL_HELP_ORG_URL`
- `REGIONAL_NEWS_COM_URL`
