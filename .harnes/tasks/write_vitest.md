# Task: Write Vitest

## Purpose

Write Vitest that verifies real frontend behavior.

Tests are required for all meaningful frontend changes. A change without adequate tests is
incomplete.

---

## Core Rules

You MUST:

- use Vitest for JavaScript and frontend code
- follow existing project test structure and naming
- test behavior, not implementation trivia
- cover both success and failure paths
- include authorization and authentication cases when relevant
- include edge cases when input validation, routing, cookies, sessions, tokens, or policies are
  involved
- identify input and output patterns with attention to abnormal values, false negatives, false
  positives, boundary values, and state transitions
- avoid hollow coverage through meaningless mocks
- avoid host-environment side effects and destructive changes
- keep tests idempotent and independent of execution time and external state

You MUST NOT:

- write placeholder tests
- write meaningless assertions
- skip tests to make the suite pass
- mock the code under test so heavily that the test no longer verifies behavior
- add tests that merely restate implementation details without validating outcomes

---

## Required Coverage

For any non-trivial change, tests MUST cover all relevant cases below.

### 1. Success path

Verify the intended behavior works.

Examples:

- valid input renders expected state
- event handler updates the UI correctly
- response body contains expected data
- navigation goes to the expected internal path

### 2. Failure path

Verify invalid or rejected behavior fails safely.

Examples:

- invalid input shows the expected error state
- unauthorized access is denied
- unauthenticated access is redirected or rejected
- forbidden operation does not mutate state

### 3. Authorization

When controller, policy, role, or staff/user context is involved, test authorization explicitly.

Examples:

- authorized actor can access action
- unauthorized actor is denied
- wrong surface or wrong role is rejected

### 4. Edge cases

Add edge-case coverage when behavior depends on:

- empty values
- nil values
- invalid format
- expired token
- wrong host
- wrong route
- missing cookie
- restricted session
- verification not completed
- already-existing record
- idempotent re-entry

---

## Test Design Rules

### Prefer component and integration tests for UI behavior

When testing frontend behavior, prefer tests that verify:

- visible UI state
- emitted events
- navigation
- persisted client state when relevant

Do not primarily test implementation internals.

### Test observable outcomes

Assert on:

- rendered output
- user-visible state
- events
- network request payloads when relevant
- navigation target

Avoid asserting on:

- private functions
- internal temporary variables
- incidental implementation details

### Keep tests deterministic

Tests MUST:

- be order-independent
- not rely on wall-clock timing unless time is explicitly controlled
- not depend on external network access
- not depend on leaked global state
- cleanly isolate setup and assertions

---

## Preferred Structure

Use clear arrange / act / assert flow.

Example:

```ts
test("shows an error for invalid input", () => {
  // arrange
  const input = ""

  // act
  render(<Form defaultValue={input} />)

  // assert
  expect(screen.getByText("Invalid input")).toBeInTheDocument()
})
```
