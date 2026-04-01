# Forbidden Patterns

## Database

DO NOT USE:

- drop_table
- remove_column
- change_column
- delete_all
- destroy_all
- update_all
- execute(...)

Reason: destructive and unsafe.

---

## Authentication / Authorization

DO NOT USE:

- skip_before_action
- skip_authorization
- skip_forgery_protection
- permit!

Reason: bypasses security.

---

## Security

DO NOT USE:

- html_safe
- raw(...)
- VERIFY_NONE

Reason: XSS / SSL vulnerabilities.

---

## Exception Handling

DO NOT:

- rescue and ignore errors
- use `rescue nil`

Reason: hides failures.

---

## Global State

DO NOT USE:

- @@variables
- Thread.current
- global variables

Reason: unsafe in concurrent environments.

---

## Logging

DO NOT LOG:

- tokens
- cookies
- authorization headers
- full params

---

## Summary

If a change introduces risk or bypasses safeguards, it is forbidden.
