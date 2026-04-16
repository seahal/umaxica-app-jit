# Analysis Agent Brief Index

## Purpose

This directory is split so each topic can be discussed with a separate AI agent.

Each Markdown file is a standalone handoff brief. A human can open one file, start a fresh agent
conversation, and ask the agent to focus only on that brief.

## Recommended Agent Split

1. [Redesign Direction](./redesign-direction.md)
   - Use for architecture direction, boundary naming, and responsibility splits.
2. [Engine Boundary Plan](./engine-boundary-plan.md)
   - Use for engine ownership, database boundaries, and isolation strategy.
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

## Notes

- The four briefs are related, but each should remain independently discussable.
- If one agent finds a blocker that belongs to another topic, record it as a dependency instead of
  expanding scope.

## Session Recap

The current boundary model is:

- `Identity`
- `Global`
- `Regional`

Current discussion focus for follow-up:

1. which engine owns which database group
2. how host labels map onto the three engines
3. which shared resources remain in the host app
