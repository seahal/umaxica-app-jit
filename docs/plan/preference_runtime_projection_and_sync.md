# Preference Runtime Projection And Sync

## Context

This topic is intentionally deferred.

It covers the runtime-delivery side of preference handling rather than the preference/consent values
themselves.

Examples include:

- preference snapshots embedded into tokens
- cookie projection for runtime use
- `Current.preference` resolution
- request-context reconstruction from params/cookies/tokens
- dual-write and synchronization between surface preference records and actor preference records

## Working Interpretation

This area should likely be treated as application/runtime infrastructure rather than as the core
preference domain itself.

A useful future split may distinguish between:

- `Preference` / `Consent`
- runtime projection / snapshot / resolution
- sync / propagation between records

## Candidate Future Concepts

- `PreferenceSnapshot`
- `PreferenceResolver`
- `PreferenceProjector`
- `PreferenceSyncService`

## Why This Matters

The current preference implementation mixes:

- setting values
- consent values
- runtime distribution concerns
- synchronization concerns

That is workable for now, but likely too coupled for the long term.

## Status

Deferred. This should be revisited later, after nearer-term authNZ and `com/customer` preference
alignment work has settled.
