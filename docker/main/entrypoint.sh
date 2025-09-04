#!/bin/bash
set -e

# Check if running in CI environment
if [ "$CI" = "true" ]; then
  echo "=== Running in CI mode ==="
  
  # Install dependencies
  echo "=== Installing dependencies ==="
  bundle install --jobs $(nproc)
  bun install --frozen-lockfile
  
  # Build assets
  echo "=== Building assets ==="
  bun run build
  
  # JavaScript linting and type checking
  echo "=== JS Lint & Typecheck ==="
  bun run lint
  bun run typecheck
  
  # Database setup (no seeding in CI)
  echo "=== Setting up databases ==="
  bin/rails db:create
  bin/rails db:migrate
  
  # Security checks
  echo "=== Running security checks ==="
  bundle exec brakeman -z -q
  bundle exec bundle audit check --update
  
  # Code quality checks
  echo "=== Running code quality checks ==="
  bundle exec rubocop --fail-fast
  bundle exec erb_lint --lint-all
  
  # JavaScript tests
  echo "=== Running JS tests ==="
  bun test --no-color || exit 1
  
  # Rails tests
  echo "=== Running Rails tests ==="
  bin/rails test
  
  echo "=== CI Pipeline Complete ==="
  exit 0
else
  echo "=== Running in development mode ==="
  
  # package install
  bundle install
  bun install

  # open up
  bin/rails tmp:clear

  # for Database setup
  bin/rails db:create
  bin/rails db:migrate
  bin/rails db:seed

  # for Karafka
  bundle exec karafka-web migrate

  # run servers
  bin/dev

  exec $$
fi