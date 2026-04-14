# Engine Boundary Plan For A Global SNS

## Agent Brief

Use this file with one dedicated AI agent.

Agent role:

- challenge the current engine split
- identify coupling and boundary leaks
- suggest safer dependency direction

Expected output from the agent:

- concrete boundary problems
- engine or subsystem alternatives
- migration sequencing ideas
- risks from cross-engine helpers and cross-database sync

Out of scope for this agent:

- global audit taxonomy
- legal rollout sequencing
- full product capability policy design

## Summary

This note reviews the current Rails engine split and records the boundary changes that should be
considered before the platform grows into a global SNS with strict legal and operational controls.

The current four-engine layout is a good deployment start, but it still groups behavior mainly by
hosted surface. It does not yet cleanly isolate legal policy, trust and safety workflows, audit
evidence, or data movement.

## Problem Statement

An engine split only helps if the boundaries match ownership and failure domains.

Today, the platform is split into:

- `signature`: sign and identity flows
- `world`: apex and dashboard flows
- `station`: main service and regional operations
- `press`: docs and content delivery

That split helps routing and deployment, but it does not fully contain data movement or policy
decisions. Several helpers and concerns still cross the intended boundaries.

## Current Repo Findings

- `config/routes.rb` mounts the four engines by deployment mode.
- `CrossEngineUrlHelpers` exposes cross-engine route dispatch from shared code.
- `Preference::Adoption` synchronizes values across databases and model families after login and
  token rotation.
- Several application controllers still compose many shared concerns directly, including
  authentication, verification, preference, current state, and cross-cutting helpers.
- `Core::Surface` detects app/com/org from host labels, which is useful for presentation but not
  sufficient for policy ownership.

Primary references:

- `/home/jit/workspace/config/routes.rb`
- `/home/jit/workspace/lib/cross_engine_url_helpers.rb`
- `/home/jit/workspace/app/controllers/concerns/preference/adoption.rb`
- `/home/jit/workspace/engines/signature/app/controllers/sign/app/application_controller.rb`
- `/home/jit/workspace/engines/station/app/controllers/core/app/application_controller.rb`

## Risks If Unchanged

- Engine boundaries may look strict in deployment diagrams but remain loosely coupled in runtime
  behavior.
- Cross-engine route helper usage may hide accidental boundary violations.
- Cross-database synchronization may create data copies without a clear owner or policy gate.
- Later legal and moderation features may be forced into the wrong engine because the current split
  is optimized for UI surfaces, not responsibility domains.

## Target Direction

Keep the existing four engines as a deployment shape for now, but treat them as transitional.

The longer-term boundary model should move toward responsibility-based subsystems:

- Identity and authentication
- Core product interaction
- Trust and safety
- Privacy and rights handling
- Documentation and public notices
- Shared audit and policy infrastructure

This does not require an immediate engine explosion. It does require stricter rules:

- cross-engine calls must go through named interfaces
- implicit synchronization must move behind explicit services
- policy decisions must not live in route helpers or preference concerns
- data movement across databases must become observable and reviewable

## Boundary Leaks To Track

- Cross-engine URL helper dispatch
- Preference adoption and cross-database copying
- Shared controller concerns that decide too much at request level
- Environment-variable host mapping that mixes deployment wiring with business routing assumptions

## Open Questions

- Which boundaries must become separate engines, and which should remain shared libraries?
- Should trust and safety be its own engine or a protected internal subsystem first?
- Which current cross-engine helper calls are only convenience, and which are structural needs?
- Where should policy contracts live so every engine can depend on them without circular coupling?

## Suggested Next Implementation Steps

1. Inventory all current cross-engine helper usage and categorize it by necessity.
2. Mark preference adoption and other cross-database sync paths as explicit boundary crossings.
3. Introduce service interfaces for policy, audit, and residency decisions before further engine
   extraction.
4. Keep the current four engines, but stop adding new cross-engine convenience paths.
5. Open targeted refactor issues for URL helper isolation and synchronization ownership.

## Questions To Ask The Agent

- Which current engine boundaries are false boundaries?
- Which shared concerns should move behind services first?
- What should remain an engine boundary versus a library boundary?
- Which current cross-engine flows are unacceptable for a global SNS?

## Session Recap

The latest boundary and naming discussion changed the working frame in a material way.

Current working assumptions:

- `database boundary` is the parent design axis
- `Rails engine` names should be decided after the DB split is clear
- `subdomain` names should be treated as entry labels, not as the primary architecture boundary
- `subdomain` names are external-facing, memorable, and fixed at 4 letters
- FQDN stability requirements, especially around passkey-related flows, are a valid reason to keep
  multiple subdomains inside one engine

Important current conclusions:

- the previous 4-engine split may no longer be the right long-term shape
- a 2-way engine model aligned to `global / regional` is now a serious candidate
- however, `regional` is still unresolved because public/editable and non-public/readonly concerns
  may deserve separate engines if model and DB boundaries also split later
- the regional readonly content side is not an independent business root today because content is
  still edited from the regional editable side

This means the key question for follow-up is no longer only “which 4 engine names are best?” but
also “should engine count collapse to 2, or should regional later split again for model ownership?”

## Related Analyses

- [Redesign Direction](./redesign-direction.md)
- [Audit And Evidence Plan](./audit-and-evidence-plan.md)
- [Jurisdiction Rollout Plan](./jurisdiction-rollout-plan.md)
