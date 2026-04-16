# ADR: Adopt isolate_namespace for Rails Engines

**Status:** Accepted (2026-04-14)

**Supersedes:** The "No isolate_namespace" decision in `adr/four-engine-split.md` (2026-04-09)

## Context

When the 4-engine split was implemented (2026-04-09), `isolate_namespace` was deliberately skipped
to avoid mass-renaming controllers and test files. Each engine was mounted at `/` with host
constraints, and a custom `CrossEngineUrlHelpers` module handled cross-engine route dispatch.

After operating with this design, the following problems became clear:

1. **CrossEngineUrlHelpers is complex and fragile.** It manually dispatches route helpers to
   per-engine proxy instances because Rails engine `url_helpers` modules conflict when included
   together. This is a workaround for a problem that `isolate_namespace` solves natively.

2. **Engine boundaries are not enforced at the code level.** Without `isolate_namespace`, any engine
   can accidentally reference host app or other engine internals without explicit qualification.
   This undermines the Global/Regional database separation goal.

3. **The Rails documentation strongly recommends `isolate_namespace` for mountable engines.**
   Skipping it means losing native routing proxies, namespace collision protection, and
   engine-scoped view resolution.

4. **Models stay in the host app.** The original concern about `isolate_namespace` adding table name
   prefixes does not apply because models are shared through the host app, not owned by engines.
   This removes the largest practical objection to `isolate_namespace`.

## Decision

Adopt `isolate_namespace` for all four engines:

| Engine     | Namespace         | Module | isolate_namespace target |
| ---------- | ----------------- | ------ | ------------------------ |
| Signature  | `Jit::Signature`  | `sign` | `Jit::Signature`         |
| Zenith     | `Jit::Zenith`     | `apex` | `Jit::Zenith`            |
| Foundation | `Jit::Foundation` | `base` | `Jit::Foundation`        |
| Publisher  | `Jit::Publisher`  | `post` | `Jit::Publisher`         |

### Key design points

- **Models remain in the host app.** `isolate_namespace` isolates controllers, routes, and views.
  Models and database connections stay centralized in `app/models/`.
- **Engine routing proxies replace `CrossEngineUrlHelpers`.** Cross-engine links use
  `signature.sign_app_sessions_path`, `foundation.base_app_contacts_path`, etc.
- **`main_app` prefix required for host app routes from within engines.** This makes boundary
  crossings visible in code.
- **Each engine defines its own `ApplicationController` inheriting from `::ApplicationController`.**
  This allows shared concerns to flow from the host while keeping engine controllers namespaced.

### Engine definition example

```ruby
# engines/signature/lib/jit/signature/engine.rb
module Jit
  module Signature
    class Engine < ::Rails::Engine
      isolate_namespace Jit::Signature

      engine_name "signature"
    end
  end
end
```

### Mount example

```ruby
# config/routes.rb
Rails.application.routes.draw do
  if Jit::Deployment.signature?
    mount Jit::Signature::Engine => "/", as: :signature
  end

  if Jit::Deployment.zenith?
    mount Jit::Zenith::Engine => "/", as: :zenith
  end

  if Jit::Deployment.foundation?
    mount Jit::Foundation::Engine => "/", as: :foundation
  end

  if Jit::Deployment.publisher?
    mount Jit::Publisher::Engine => "/", as: :publisher
  end
end
```

## Consequences

### Positive

- **Native routing proxies**: `signature.*_path`, `foundation.*_path` etc. replace custom dispatch
- **Enforced boundaries**: Accidental cross-engine dependencies become visible as `main_app.` calls
- **Standard Rails pattern**: New contributors understand the architecture without learning custom
  helpers
- **`CrossEngineUrlHelpers` can be retired**: Removes a fragile custom abstraction
- **Engine-scoped view resolution**: Each engine's views are isolated, overridable from the host

### Negative

- **FQCN changes**: Controller fully-qualified class names gain the engine prefix (e.g.,
  `Jit::Signature::Sign::App::SessionsController`), though internal `module Sign` remains unchanged
- **All cross-engine route references must be updated**: Every call to another engine's routes needs
  the engine proxy prefix
- **Larger rename scope**: This should be combined with the engine rename (#725) to avoid doing the
  work twice

### Migration notes

- Combine this change with the engine rename work (#725) to minimize churn
- Update `CrossEngineUrlHelpers` references to use native engine proxies
- After migration, remove `lib/cross_engine_url_helpers.rb` and
  `config/initializers/cross_engine_urls.rb`

## Related

- `adr/four-engine-split.md` (original decision, partially superseded)
- `plans/active/four-engine-rename.md` (execution plan)
- `lib/cross_engine_url_helpers.rb` (to be retired)
- GitHub #725 (parent rename issue)
