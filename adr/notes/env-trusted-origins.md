# ENV-based trusted_origins for CSRF protection

GitHub: plan from `plans/active/env-trusted-origins.md`

The apex, core, and docs surface application controllers now read `trusted_origins` from environment
variables instead of hard-coded localhost arrays.

Implemented mapping:

- `APEX_APP_TRUSTED_ORIGINS`
- `APEX_COM_TRUSTED_ORIGINS`
- `APEX_ORG_TRUSTED_ORIGINS`
- `CORE_APP_TRUSTED_ORIGINS`
- `CORE_COM_TRUSTED_ORIGINS`
- `CORE_ORG_TRUSTED_ORIGINS`
- `DOCS_APP_TRUSTED_ORIGINS`
- `DOCS_COM_TRUSTED_ORIGINS`
- `DOCS_ORG_TRUSTED_ORIGINS`

The fallback value for each key keeps the current localhost origins available in development and
test. A small shared concern parses the comma-separated ENV value and strips whitespace.

Regression coverage now includes:

- a unit test for the shared parser
- a controller test that checks the nine touched controllers expose the expected default origins
