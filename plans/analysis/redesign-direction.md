# Redesign Direction For Global SNS Foundations

## Agent Brief

Use this file with one dedicated AI agent.

Agent role:

- challenge the architecture direction
- identify missing policy boundaries
- suggest a better responsibility split

Expected output from the agent:

- weak assumptions
- missing system capabilities
- safer boundary definitions
- a sharper target architecture

Out of scope for this agent:

- detailed audit schema design
- detailed engine extraction steps
- rollout sequencing by jurisdiction

## Summary

This note records the redesign direction for a global SNS platform that must support JP, US, and EU
launch conditions.

The current repository already supports multiple surfaces, multiple hosts, multiple databases, and
multiple Rails engines. However, the main system split is still based on UI surface and deployment
shape, not on legal jurisdiction, trust and safety ownership, data residency, or audit evidence.

The next architecture step should move critical decisions away from `global` versus `regional`
preference handling and toward explicit policy boundaries.

## Problem Statement

The current codebase has a useful multi-surface structure, but it does not yet model the legal and
operational controls that a global SNS needs.

The most important gap is that region preference is currently treated as presentation context, not
as a legal and operational decision boundary.

## Current Repo Findings

- `Preference::Global` and `Preference::Regional` manage `ri`, `lx`, `tz`, and `ct`, but they do not
  decide legal jurisdiction, service availability, age treatment, or cross-border restrictions.
- `ActivityRecord` states that one global activity database serves all regions.
- `config/initializers/locale.rb` uses `REGION_CODE` as a deploy-time locale selector, which is a
  different concern from user-level jurisdiction handling.
- Default region and timezone values are still strongly Japan-oriented in several preference and
  input paths.
- Cross-database preference adoption copies settings between browser-facing preference records and
  identity-linked preference records without a formal policy layer.

Primary references:

- `/home/jit/workspace/app/controllers/concerns/preference/global.rb`
- `/home/jit/workspace/app/controllers/concerns/preference/regional.rb`
- `/home/jit/workspace/app/models/activity_record.rb`
- `/home/jit/workspace/config/initializers/locale.rb`
- `/home/jit/workspace/app/controllers/concerns/preference/adoption.rb`

## Risks If Unchanged

- Legal rules may be applied from UI preference values instead of validated jurisdiction facts.
- Data residency and transfer decisions may happen too late or not at all.
- The same account flow may behave incorrectly for EU, US, and JP users even when the UI appears
  localized.
- Product teams may assume the platform is jurisdiction-aware when it is only locale-aware.
- Later engine refactors may lock in the wrong boundary model and increase migration cost.

## Target Direction

Introduce a policy-centered architecture that treats the following as separate concerns:

- `Surface`: app, com, org presentation boundary
- `Jurisdiction`: which legal rule set applies
- `Identity`: who the actor is and what proof level exists
- `Trust and safety`: moderation, abuse handling, reporting, and appeals
- `Data residency`: where data may be stored, replicated, or exported
- `Audit evidence`: what proof is required for security, moderation, and privacy actions

The preference layer should remain responsible for user experience defaults. It should not be the
main place that decides legal behavior.

The recommended service additions are:

- `JurisdictionResolver`
- `CapabilityPolicy`
- `DataResidencyRouter`
- `AuditRecorder` or equivalent shared evidence writer
- `TrustSafetyCase` management flow

## Open Questions

- Which user facts are allowed to determine jurisdiction: declared residence, current IP, billing
  country, account type, or a combination?
- Which product features must be gated by jurisdiction from day one?
- Which data stores must be residency-aware at launch, and which can remain global for now?
- How strict should the system be when jurisdiction signals conflict?

## Suggested Next Implementation Steps

1. Define a single jurisdiction resolution contract and its inputs.
2. Create a capability matrix for JP, US, and EU launch behavior.
3. Mark which existing flows must call the new policy layer before write operations.
4. Separate preference UX state from legal and operational policy state in naming and code paths.
5. Create follow-up issues for residency routing, trust and safety cases, and privacy rights flows.

## Questions To Ask The Agent

- Which boundary in this redesign is still too vague to implement safely?
- Which responsibilities are still mixed together?
- What should become a policy service, and what should stay in controllers or concerns?
- Which current abstractions will block the redesign if left untouched?

## Session Recap

Recent discussion added these working assumptions:

- naming should be layered as `database boundary > Rails engine > subdomain > TLD > region code`
- `database boundary` is the parent concept
- `subdomain` naming is external-facing and should not be used as the main internal architecture key
- `subdomain` labels may stay more memorable and user-oriented than engine names
- the strongest current architectural candidate is still a `global / regional` split

This note should now be read together with the engine-boundary discussion, because the redesign is
shifting from network-topology-first naming toward boundary-first naming.

## Current Working Boundary Draft

The latest discussion produced a stronger working draft for how the system should be split at the
database-boundary level.

### Global domain

These are the current candidates for the global side:

- `principal`
- `operator`
- `token`
- `occurrence`
- `guest`
- `activity`
- `notification`
- `avatar`
- `preference`

Working intent:

- global holds actor roots, auth roots, account state roots, canonical audit roots, and shared
  notification state
- global should stay free-first by design
- monetization logic should not be a driver for global architecture

### Regional domain

These are the current candidates for the regional side:

- `document`
- `news`
- `message`
- `search`
- `billing`
- `behavior`

Working intent:

- regional holds content, interaction, market execution, and detailed local behavior
- billing stays regional because tax and market rules are region-dependent
- message stays regional because communication regulation may differ by country
- search stays regional; global natural-language search is currently considered a bad fit

### Boundary-local infrastructure

The latest discussion suggests a third category that is not a business domain boundary, but a
runtime boundary-local infrastructure layer:

- `storage`
- `cache`
- `cable`
- `queue`

Working intent:

- each boundary may need its own runtime support services
- these should not be forced into only global or only regional
- Rails and Solid-based implementation details make dual placement practical and desirable

### Activity And Behavior Split

`activity` and `behavior` have similar observation goals, but they are not the same layer.

- `activity` is the current candidate for the global canonical event layer
- `behavior` is the current candidate for the regional detailed behavior layer

This split should remain explicit in later redesign work.

### Design Consequences

If this draft holds, the redesign direction becomes much clearer:

- global is the home of canonical actor and account state
- regional is the home of content, interaction, and monetization
- infrastructure support may exist on both sides
- cross-boundary workflows must stay explicit and must not rely on loose Rails coupling

### Still Open

The following points are still open even under this draft:

- whether Rails engines should collapse to `global / regional` directly
- whether regional public and non-public responsibilities later deserve separate engines
- how global state should project into regional UI and BFF flows without recreating hidden coupling

## Related Analyses

- [Engine Boundary Plan](./engine-boundary-plan.md)
- [Audit And Evidence Plan](./audit-and-evidence-plan.md)
- [Jurisdiction Rollout Plan](./jurisdiction-rollout-plan.md)
