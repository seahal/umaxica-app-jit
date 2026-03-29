# 1-Series Success ID Normalization Plan

Created: 2026-03-29

This document is Step 1 for issue `#572`.
It defines where the `1 = primary success state` rule should be applied first, and where it should
be deferred or excluded.

## Step 1 Decision

Apply the rule in phases instead of trying to normalize every fixed-id master at once.

## Phase Buckets

### Phase 1: Strongly apply `1 = primary success state`

Start here:

- `status`
- `dbsc_status`

Reason:

- these models already encode lifecycle-like meaning
- they are the clearest places to separate `0 = null-like sentinel` from `1 = normal primary state`
- they are the highest-value targets for later default / predicate / transition cleanup

### Phase 2: Apply after Phase 1 stabilizes

Defer to the next wave:

- `binding_method`

Reason:

- they often behave like operational state masters, but they are not always lifecycle state in the
  same sense as `status`
- they should be normalized only after the Phase 1 rule is concrete

### Phase 3: Conditional / case-by-case

Do not normalize mechanically:

- `option`

Reason:

- some `option` masters behave like defaults or preferences, not success/failure state
- forcing `1 = success` onto every option table would blur domain meaning

### Phase 4: Excluded by default

Do not apply the rule unless a separate issue proves the semantics match:

- `category_master`
- `tag_master`
- `behavior_event`

Reason:

- these are classification vocabularies, not lifecycle state machines
- they should not inherit status semantics by numeric convention alone

## Initial Scope Inside Phase 1

The first review set for `#572` should stay narrow:

- `AppPreferenceStatus`
- `AppPreferenceDbscStatus`
- `UserTelephoneStatus`
- `UserTokenDbscStatus`
- `ComDocumentStatus`
- `UserVisibility`
- `ZipOccurrenceStatus`

Hold back for separate cleanup before including:

- `WorkspaceStatus`

Reason:

- its current FK / association wiring is inconsistent and should not be mixed into the 1-series
  renumbering plan

## Deferred to Step 2

Step 2 should define, for each Phase 1 model:

- what the primary success state actually is
- whether `1` should mean `ACTIVE`, `VERIFIED`, `DEFAULT`, `VISIBLE`, or another domain-specific
  normal state
- which models should remain outside the first implementation slice even if they are technically in
  scope
