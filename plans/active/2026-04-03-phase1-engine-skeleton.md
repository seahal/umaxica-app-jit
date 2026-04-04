# Phase 1: Local Engine Skeleton — Implementation Specification

**GitHub Issue:** #553 **Parent design:** `docs/architecture/engine.md` **Goal:** Create a minimal,
loadable Rails mountable engine at `engines/local/` and the `Jit::Deployment` gate module. No
controllers, models, or routes are moved in this phase. The engine loads, the app boots, and all
existing tests pass.

---

## Prerequisites

- Ruby 4.0.2, Rails 8.1 (main branch)
- All existing tests pass before starting: `bundle exec rails test`
- Docker services running: `docker compose up -d`

---

## Step 1: Create `Jit::Deployment` Module

This module gates which engines are loaded based on `DEPLOY_MODE` env var.

### Create `/home/jit/workspace/lib/jit/deployment.rb`

```ruby
# typed: false
# frozen_string_literal: true

module Jit
  module Deployment
    MODES = %w[global local development].freeze

    def self.mode
      ENV.fetch("DEPLOY_MODE", "development")
    end

    def self.global?
      mode.in?(%w[global development])
    end

    def self.local?
      mode.in?(%w[local development])
    end
  end
end
```

### Verify

```bash
bundle exec ruby -e "require_relative 'lib/jit/deployment'; puts Jit::Deployment.mode"
# Expected output: development
```

---

## Step 2: Create Engine Directory Structure

### Create the following directories

```bash
mkdir -p engines/local/app/controllers
mkdir -p engines/local/app/models
mkdir -p engines/local/app/views
mkdir -p engines/local/app/helpers
mkdir -p engines/local/app/assets/stylesheets
mkdir -p engines/local/config
mkdir -p engines/local/db
mkdir -p engines/local/lib/jit/local
mkdir -p engines/local/test
```

---

## Step 3: Create Engine Files

### 3A: Create `/home/jit/workspace/engines/local/lib/jit/local.rb`

```ruby
# typed: false
# frozen_string_literal: true

require_relative "local/engine"

module Jit
  module Local
  end
end
```

### 3B: Create `/home/jit/workspace/engines/local/lib/jit/local/engine.rb`

```ruby
# typed: false
# frozen_string_literal: true

module Jit
  module Local
    class Engine < ::Rails::Engine
      # NOTE: Do NOT use isolate_namespace yet. It will be introduced in a future
      # phase after controllers are moved and stabilised. For now, the engine
      # shares the host app's namespace so that existing controller class names
      # (Core::App::RootsController etc.) work without renaming.

      engine_name "jit_local"

      initializer "jit_local.autoload_host_concerns" do |app|
        # Let engine controllers resolve concerns defined in the host app.
        # This is a no-op when host app already autoloads these paths, but
        # makes the dependency explicit.
        engine_concerns = root.join("app", "controllers", "concerns")
        app.config.autoload_paths << engine_concerns.to_s if engine_concerns.exist?
      end
    end
  end
end
```

### 3C: Create `/home/jit/workspace/engines/local/jit-local.gemspec`

```ruby
# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name        = "jit-local"
  spec.version     = "0.1.0"
  spec.authors     = ["seahal"]
  spec.summary     = "Jit Local Engine — per-region deployment unit (core, docs, news, help)"

  spec.required_ruby_version = ">= 4.0.0"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile"]
  end

  spec.add_dependency "rails", ">= 8.1"
end
```

### 3D: Create `/home/jit/workspace/engines/local/Rakefile`

```ruby
# frozen_string_literal: true

require "bundler/setup"
require "rails/all"
```

### 3E: Create `/home/jit/workspace/engines/local/config/routes.rb`

This is an empty route file. Routes will be moved here in Phase 2.

```ruby
# typed: false
# frozen_string_literal: true

# Local engine routes — placeholder.
# Phase 2 will move core, docs, news, help routes here.
```

---

## Step 4: Register Engine in Gemfile

### Edit `/home/jit/workspace/Gemfile`

Add the following line **after** the `gem "rails"` line (around line 18):

```ruby
# Local engine (per-region deployment: core, docs, news, help)
gem "jit-local", path: "engines/local"
```

### Run

```bash
bundle install
```

**Expected:** Bundle resolves successfully. `jit-local` appears in `Gemfile.lock`.

---

## Step 5: Gate Route Loading with `Jit::Deployment`

### Edit `/home/jit/workspace/config/routes.rb`

Replace the current content:

```ruby
# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # CSP violation reporting endpoint (host-agnostic, all domains)
  post "/csp-violation-report", to: "csp_violations#create"

  draw :apex
  # sign in / up
  draw :sign
  # regional
  ## back end of edge endpoints
  draw :core
  # endpoints for help
  draw :help
  # endpoints for docs
  draw :docs
  # endpoints for news
  draw :news
end
```

With:

```ruby
# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # CSP violation reporting endpoint (host-agnostic, all domains)
  post "/csp-violation-report", to: "csp_violations#create"

  # Global routes (sign, apex) — loaded when DEPLOY_MODE is global or development
  if Jit::Deployment.global?
    draw :apex
    draw :sign
  end

  # Local routes (core, docs, news, help) — loaded when DEPLOY_MODE is local or development
  if Jit::Deployment.local?
    draw :core
    draw :help
    draw :docs
    draw :news
  end
end
```

**Note:** In `development` mode (default), both blocks execute, preserving current behaviour.

---

## Step 6: Verify Boot and Tests

### 6A: Verify app boots in default (development) mode

```bash
TRUSTED_ORIGINS="http://localhost:3000" bundle exec rails runner "puts Jit::Deployment.mode; puts 'Boot OK'"
# Expected: "development" then "Boot OK"
```

### 6B: Verify engine is loaded

```bash
TRUSTED_ORIGINS="http://localhost:3000" bundle exec rails runner "puts Jit::Local::Engine.engine_name"
# Expected: "jit_local"
```

### 6C: Verify DEPLOY_MODE=global skips local routes

```bash
DEPLOY_MODE=global TRUSTED_ORIGINS="http://localhost:3000" bundle exec rails runner "
  routes = Rails.application.routes.routes.map { |r| r.defaults[:controller] }.compact.uniq
  has_core = routes.any? { |c| c.start_with?('core/') }
  has_sign = routes.any? { |c| c.start_with?('sign/') }
  puts \"core routes present: #{has_core}\"
  puts \"sign routes present: #{has_sign}\"
"
# Expected:
#   core routes present: false
#   sign routes present: true
```

### 6D: Verify DEPLOY_MODE=local skips global routes

```bash
DEPLOY_MODE=local TRUSTED_ORIGINS="http://localhost:3000" bundle exec rails runner "
  routes = Rails.application.routes.routes.map { |r| r.defaults[:controller] }.compact.uniq
  has_core = routes.any? { |c| c.start_with?('core/') }
  has_sign = routes.any? { |c| c.start_with?('sign/') }
  puts \"core routes present: #{has_core}\"
  puts \"sign routes present: #{has_sign}\"
"
# Expected:
#   core routes present: true
#   sign routes present: false
```

### 6E: Run full test suite

```bash
bundle exec rails test
```

**Expected:** All tests that passed before Phase 1 continue to pass. The default `DEPLOY_MODE` is
`development`, which loads both Global and Local routes, so nothing changes for tests.

---

## Step 7: Create Unit Test for `Jit::Deployment`

### Create `/home/jit/workspace/test/unit/jit/deployment_test.rb`

```ruby
# typed: false
# frozen_string_literal: true

require "test_helper"

module Jit
  class DeploymentTest < ActiveSupport::TestCase
    test "default mode is development" do
      ClimateControl.modify(DEPLOY_MODE: nil) do
        assert_equal "development", Deployment.mode
      end
    end

    test "global? is true in global mode" do
      ClimateControl.modify(DEPLOY_MODE: "global") do
        assert Deployment.global?
        refute Deployment.local?
      end
    end

    test "local? is true in local mode" do
      ClimateControl.modify(DEPLOY_MODE: "local") do
        assert Deployment.local?
        refute Deployment.global?
      end
    end

    test "both are true in development mode" do
      ClimateControl.modify(DEPLOY_MODE: "development") do
        assert Deployment.global?
        assert Deployment.local?
      end
    end
  end
end
```

**Note:** If `climate_control` gem is not available, use this alternative pattern instead:

```ruby
# typed: false
# frozen_string_literal: true

require "test_helper"

module Jit
  class DeploymentTest < ActiveSupport::TestCase
    setup do
      @original_mode = ENV["DEPLOY_MODE"]
    end

    teardown do
      if @original_mode.nil?
        ENV.delete("DEPLOY_MODE")
      else
        ENV["DEPLOY_MODE"] = @original_mode
      end
    end

    test "default mode is development" do
      ENV.delete("DEPLOY_MODE")
      assert_equal "development", Deployment.mode
    end

    test "global? is true in global mode" do
      ENV["DEPLOY_MODE"] = "global"
      assert Deployment.global?
      refute Deployment.local?
    end

    test "local? is true in local mode" do
      ENV["DEPLOY_MODE"] = "local"
      assert Deployment.local?
      refute Deployment.global?
    end

    test "both are true in development mode" do
      ENV["DEPLOY_MODE"] = "development"
      assert Deployment.global?
      assert Deployment.local?
    end
  end
end
```

### Run

```bash
SKIP_DB=1 bundle exec rails test test/unit/jit/deployment_test.rb
```

---

## Step 8: Update `docs/architecture/engine.md` DB Classification

The DB classification in `docs/architecture/engine.md` (lines 32-48) has two errors. Apply these
corrections:

### Move `guest` and `finder` from Local to Global

In the **Local** table (line 37-45), remove the rows for `guest`/`GuestRecord` and
`finder`/`FinderRecord`.

Add them to the **Global** table (lines 19-30):

```
| `guest`        | `GuestRecord`        | Guest contacts         |
| `finder`       | `FinderRecord`       | Search (finder)        |
```

### Move `search` stays in Local — no change needed

The corrected classification:

**Global:** principal, operator, token, preference, occurrence, avatar, activity, notification,
guest, finder

**Local:** document, message, behavior, billing, publication, search

---

## Files Created (Summary)

| File                                    | Purpose                              |
| --------------------------------------- | ------------------------------------ |
| `lib/jit/deployment.rb`                 | Deployment mode gate (`DEPLOY_MODE`) |
| `engines/local/lib/jit/local.rb`        | Engine module entrypoint             |
| `engines/local/lib/jit/local/engine.rb` | Engine class definition              |
| `engines/local/jit-local.gemspec`       | Gem specification                    |
| `engines/local/Rakefile`                | Rake support                         |
| `engines/local/config/routes.rb`        | Empty route placeholder              |
| `test/unit/jit/deployment_test.rb`      | Unit tests for Deployment module     |

## Files Modified (Summary)

| File                          | Change                                                       |
| ----------------------------- | ------------------------------------------------------------ |
| `Gemfile`                     | Add `gem "jit-local", path: "engines/local"`                 |
| `config/routes.rb`            | Wrap route groups with `Jit::Deployment.global?` / `.local?` |
| `docs/architecture/engine.md` | Fix DB classification (guest/finder → Global)                |

## Completion Criteria

- [ ] `bundle install` succeeds
- [ ] App boots with `DEPLOY_MODE` unset (default = development)
- [ ] `Jit::Local::Engine` is loaded and returns `engine_name "jit_local"`
- [ ] `DEPLOY_MODE=global` excludes Local routes (core, docs, news, help)
- [ ] `DEPLOY_MODE=local` excludes Global routes (sign, apex)
- [ ] All existing tests pass
- [ ] `test/unit/jit/deployment_test.rb` passes
- [ ] No code is committed (user decides when to commit)
