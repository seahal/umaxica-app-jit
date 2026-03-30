# Testing Rules

## Requirements

All changes MUST include tests appropriate to the code being changed.

---

## Required Coverage

- Success path
- Failure path
- Authorization checks
- Edge cases

---

## Forbidden

DO NOT:

- write `assert true`
- skip tests
- use TODO as placeholder
- mock core logic

---

## Quality

Tests MUST:

- Be deterministic
- Be meaningful
- Validate behavior, not implementation

---

## Structure

- Use Minitest for Ruby code
- Use `vp test` (Vitest) for JavaScript code
- If a change spans Ruby and JavaScript, include coverage for both where behavior changes on both
  sides
- Follow existing patterns
- Keep tests readable

---

## Summary

A change without proper tests is invalid.
