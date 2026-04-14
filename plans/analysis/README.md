# Analysis Agent Brief Index

## Purpose

This directory is split so each topic can be discussed with a separate AI agent.

Each Markdown file is intended to be used as a standalone handoff brief. A human can open one file,
start a fresh agent conversation, and ask the agent to focus only on that brief.

## Recommended Agent Split

1. [Redesign Direction](./redesign-direction.md)
   - Use for architecture direction, policy boundaries, and system responsibility changes.
2. [Engine Boundary Plan](./engine-boundary-plan.md)
   - Use for Rails engine boundaries, dependency direction, and isolation strategy.
3. [Audit And Evidence Plan](./audit-and-evidence-plan.md)
   - Use for audit schema, event semantics, retention, and incident evidence quality.
4. [Jurisdiction Rollout Plan](./jurisdiction-rollout-plan.md)
   - Use for JP, US, and EU rollout order, capability gating, and launch sequence.

## How To Use With Separate Agents

For each topic:

1. Start a fresh agent conversation.
2. Share one file only.
3. Ask the agent to stay inside that file's scope.
4. Ask for:
   - weak points
   - missing decisions
   - better alternatives
   - migration risks
   - concrete next implementation steps

## Recommended Starter Prompt

Use this pattern in a new agent conversation:

```text
Read this brief and challenge it as a senior engineer.
Focus only on the scope in this file.
Identify weak assumptions, missing decisions, likely failure modes, and concrete improvements.
Do not drift into unrelated topics unless they are direct blockers.
```

## Notes

- The four briefs are related, but each should remain independently discussable.
- If one agent finds a blocker that belongs to another topic, record it as a dependency instead of
  expanding scope.

## Session Recap

The latest naming discussion added these working assumptions:

- `database boundary` is the parent naming axis
- `Rails engine` names and `subdomain` names must be designed separately
- `subdomain` names are external-facing labels and should optimize for memorability
- `subdomain` names are not the same thing as internal responsibility boundaries
- `global / regional` remains the main boundary under active review

Current discussion focus for follow-up:

1. whether `global / regional` is sufficient as the primary DB split
2. whether Rails engines should follow that 2-way split or keep a 4-way shape
3. how regional public and non-public responsibilities should relate
