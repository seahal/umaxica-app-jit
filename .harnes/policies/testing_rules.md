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
- For model-layer Minitest:
  - Test cases MUST include boundary value analysis and equivalence partitioning
  - Applies when validations, ranges, limits, formats, or categorizable inputs are involved

When tests or TDD apply, use the same implementation policy for Minitest and Vitest. Identify input
and output patterns with attention to abnormal values, false negatives, false positives, boundary
values, and state transitions. Do not add hollow coverage through meaningless mocks. Avoid
host-environment side effects and destructive changes. Make tests idempotent and independent of
execution time and external state.

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
