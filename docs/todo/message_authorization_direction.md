# Message Authorization Direction

## Agreed Direction

- Message models may store authorization-relevant facts.
- Message models must not make authorization decisions.
- Read/write authorization decisions should live outside the message model layer.
- The intended long-term home for message authorization is Pundit.

## What Message May Hold

- state
- type
- owner or actor reference
- surface or domain context
- other facts needed for later authorization checks

## What Message Must Not Hold

- `readable_by?` style final authorization decisions
- role-based decision logic
- request-context authorization rules
- policy orchestration

## Intended Principle

Message stores facts. Pundit decides access.

## Status

This is a planning-direction note only. Implementation is deferred to a later phase.
