# Repository Guidelines

## Agent Instruction Priority

You MUST follow instructions in this order:

1. This file (`AGENTS.md`)
2. `.harnes/policies/*`
3. `.harnes/context/*`
4. `.harnes/tasks/*`

If there is any conflict, follow the higher priority.

## Mandatory Behavior

You MUST:

- Read relevant files in `.harnes/` before making changes
- Follow all rules in `.harnes/policies/`
- Follow architecture defined in `.harnes/context/`
- Follow task procedures in `.harnes/tasks/`

## Execution Rules

Before submitting any change, you MUST:

1. Ensure no forbidden patterns are used
2. Ensure code follows routing and architecture rules
3. Ensure authentication and authorization pipeline is respected
4. Ensure tests are included and meaningful

## Excluded Directories

The following directories contain third-party libraries and MUST be excluded from all operations
(reading, searching, editing, and analysis):

- `vendor/`
- `node_modules/`

## Forbidden Actions

You MUST NOT:

- Ignore `.harnes/policies/*`
- Skip authentication or authorization
- Introduce unsafe migrations
- Add meaningless or weak tests
- Bypass safety constraints
- Read, modify, or search within `vendor/` or `node_modules/`

## Error Handling

If a rule cannot be satisfied:

- Stop
- Explain the issue
- Propose a safe alternative

Do not proceed with unsafe implementation.

## Quality Standard

Your output MUST be:

- Safe
- Deterministic
- Aligned with project architecture
- Fully test-covered

## Agent Summary

You are not allowed to improvise outside defined rules.

When in doubt:

- Follow `.harnes/policies/`
- Prefer safety over speed

## Project Structure & Module Organization

This is a Rails 8 app with domain-separated surfaces (`app`, `com`, `org`) implemented across
controllers, views, and routes.

- Application code: `app/` (`models/`, `controllers/`, `services/`, `policies/`, `jobs/`, `views/`).
- Frontend JS: `app/javascript/` (Stimulus/importmap, checked with Biome).
- Tests: `test/` (`controllers/`, `models/`, `services/`, `integration/`, `fixtures/`, `support/`).
- Database: `db/` plus domain migration folders (for example `db/operators_migrate/`,
  `db/avatars_migrate/`).
- Ops/docs: `docker/`, `compose.yml`, `docs/`, `qa/`.

## Build, Test, and Development Commands

- `bin/setup`: install dependencies and prepare databases.
- `bin/dev`: start local dev stack via Foreman (`Procfile.dev`), including DB prepare.
- `bundle exec rails test`: run the test suite.
- `COVERAGE=true bundle exec rails test`: run tests with SimpleCov enabled.
- `bundle exec rubocop`: Ruby linting/style checks.
- `bundle exec erb_lint --lint-all`: ERB lint and autocorrect.
- `pnpm run check`: Biome check/format pass for `app/javascript`.
- `bundle exec brakeman --no-pager`: static security scan.

## Coding Style & Naming Conventions

- Ruby: follow RuboCop (`.rubocop.yml`), 2-space indentation, snake_case methods/files, CamelCase
  classes/modules.
- Views/partials: use descriptive, scoped names (example: `app/views/sign/app/...`).
- JavaScript: use Biome formatting/linting defaults; keep modules under `app/javascript`.
- Keep domain boundaries explicit in paths and constants (`App`, `Com`, `Org`, `Sign`, `Core`,
  `Docs`, `News`, `Help`, `Apex`).

## Testing Guidelines

- Framework: Minitest (`test/test_helper.rb`) with fixtures.
- Respect t_wada-style testing practices when designing and writing tests.
- Prefer tests that avoid mocks and stubs whenever reasonably possible.
- Name tests with `_test.rb` and mirror source structure (example: `app/services/auth/foo.rb` ->
  `test/services/auth/foo_test.rb`).
- Run migrations before tests when schema changes are involved:
  `bundle exec rails db:migrate && bundle exec rails test`.

## Quality Guidelines

- Consider ISO/IEC 25010 quality characteristics when designing, implementing, and reviewing
  changes, especially functional suitability, performance efficiency, compatibility, usability,
  reliability, security, maintainability, and portability.
- When making tradeoffs, document the affected quality characteristics in PRs, issues, or review
  notes when they materially influence scope, design, or testing.

## Commit & Pull Request Guidelines

- Recent history uses short type-prefixed subjects (`[feat]`, `[update]`, `[refactor]`,
  `[checkpoint]`).
- Preferred commit style: imperative, scoped, and concise (example:
  `[feat] add org passkey verification flow`).
- PRs should include:
  - Clear summary and motivation.
  - Linked issue/ticket.
  - Test evidence (commands run and results).
  - UI screenshots for view changes.

## Security & Configuration Tips

- Secret management: Rails credentials; never commit plaintext secrets.
- WebAuthn commands require `TRUSTED_ORIGINS` set in environment.
- Run hooks before commit: `lefthook run pre-commit` (audit, lint, Brakeman, tests).

<!--VITE PLUS START-->

# Using Vite+, the Unified Toolchain for the Web

This project is using Vite+, a unified toolchain built on top of Vite, Rolldown, Vitest, tsdown,
Oxlint, Oxfmt, and Vite Task. Vite+ wraps runtime management, package management, and frontend
tooling in a single global CLI called `vp`. Vite+ is distinct from Vite, but it invokes Vite through
`vp dev` and `vp build`.

## Vite+ Workflow

`vp` is a global binary that handles the full development lifecycle. Run `vp help` to print a list
of commands and `vp <command> --help` for information about a specific command.

### Start

- create - Create a new project from a template
- migrate - Migrate an existing project to Vite+
- config - Configure hooks and agent integration
- staged - Run linters on staged files
- install (`i`) - Install dependencies
- env - Manage Node.js versions

### Develop

- dev - Run the development server
- check - Run format, lint, and TypeScript type checks
- lint - Lint code
- fmt - Format code
- test - Run tests

### Execute

- run - Run monorepo tasks
- exec - Execute a command from local `node_modules/.bin`
- dlx - Execute a package binary without installing it as a dependency
- cache - Manage the task cache

### Build

- build - Build for production
- pack - Build libraries
- preview - Preview production build

### Manage Dependencies

Vite+ automatically detects and wraps the underlying package manager such as pnpm, npm, or Yarn
through the `packageManager` field in `package.json` or package manager-specific lockfiles.

- add - Add packages to dependencies
- remove (`rm`, `un`, `uninstall`) - Remove packages from dependencies
- update (`up`) - Update packages to latest versions
- dedupe - Deduplicate dependencies
- outdated - Check for outdated packages
- list (`ls`) - List installed packages
- why (`explain`) - Show why a package is installed
- info (`view`, `show`) - View package information from the registry
- link (`ln`) / unlink - Manage local package links
- pm - Forward a command to the package manager

### Maintain

- upgrade - Update `vp` itself to the latest version

These commands map to their corresponding tools. For example, `vp dev --port 3000` runs Vite's dev
server and works the same as Vite. `vp test` runs JavaScript tests through the bundled Vitest. The
version of all tools can be checked using `vp --version`. This is useful when researching
documentation, features, and bugs.

## Common Pitfalls

- **Using the package manager directly:** Do not use pnpm, npm, or Yarn directly. Vite+ can handle
  all package manager operations.
- **Always use Vite commands to run tools:** Don't attempt to run `vp vitest` or `vp oxlint`. They
  do not exist. Use `vp test` and `vp lint` instead.
- **Running scripts:** Vite+ built-in commands (`vp dev`, `vp build`, `vp test`, etc.) always run
  the Vite+ built-in tool, not any `package.json` script of the same name. To run a custom script
  that shares a name with a built-in command, use `vp run <script>`. For example, if you have a
  custom `dev` script that runs multiple services concurrently, run it with `vp run dev`, not
  `vp dev` (which always starts Vite's dev server).
- **Do not install Vitest, Oxlint, Oxfmt, or tsdown directly:** Vite+ wraps these tools. They must
  not be installed directly. You cannot upgrade these tools by installing their latest versions.
  Always use Vite+ commands.
- **Use Vite+ wrappers for one-off binaries:** Use `vp dlx` instead of package-manager-specific
  `dlx`/`npx` commands.
- **Import JavaScript modules from `vite-plus`:** Instead of importing from `vite` or `vitest`, all
  modules should be imported from the project's `vite-plus` dependency. For example,
  `import { defineConfig } from 'vite-plus';` or
  `import { expect, test, vi } from 'vite-plus/test';`. You must not install `vitest` to import test
  utilities.
- **Type-Aware Linting:** There is no need to install `oxlint-tsgolint`, `vp lint --type-aware`
  works out of the box.

## CI Integration

For GitHub Actions, consider using
[`voidzero-dev/setup-vp`](https://github.com/voidzero-dev/setup-vp) to replace separate
`actions/setup-node`, package-manager setup, cache, and install steps with a single action.

```yaml
- uses: voidzero-dev/setup-vp@v1
  with:
    cache: true
- run: vp check
- run: vp test
```

## Review Checklist for Agents

- [ ] Run `vp install` after pulling remote changes and before getting started.
- [ ] Run `vp check` and `vp test` to validate changes.
<!--VITE PLUS END-->

## Git Commit Policy

Never run `git commit` automatically. Always complete the requested changes, report what was done,
and stop — without committing. Let the user decide when to commit.
