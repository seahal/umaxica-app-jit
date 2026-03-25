# Concern Side Effects Refactoring Plan

Created: 2026-03-25
Based on: Analysis of 109+ Rails Concerns with automatic side effects

## Problem Statement

Many Rails Concerns use `included do ... end` blocks to automatically:
- Add `before_action` / `after_action` callbacks
- Register `rescue_from` handlers
- Modify global state or class attributes
- Perform database writes on every request

This violates the principle that **including a module should not surprise the developer**. Side effects should be explicit and opt-in.

---

## High Priority: Explicit Activation Required

### 1. Rate Limiting (`RateLimit` concern)

**Current Behavior:**
```ruby
included do
  rate_limit to: 300, within: 1.minute, by: -> { request.remote_ip }
  rate_limit to: 600, within: 1.minute, by: -> { request.remote_ip }, only: [:create]
end
```

**Issues:**
- Automatically applies rate limits to all actions
- Uses global Redis store
- No way to disable per-controller

**Recommended Approach:**
```ruby
# Opt-in activation
class ApplicationController < ActionController::Base
  include RateLimit                    # No side effects yet
  rate_limit_config default: { to: 300, within: 1.minute }
  
  # Only specific controllers opt-in
  rate_limit_actions :create, :update
end
```

Or use explicit subclass:
```ruby
class RateLimitedController < ApplicationController
  include RateLimit::Enforced  # This is the one with side effects
end
```

---

### 2. Minimum Response Budget (`MinimumResponseBudget` concern)

**Current Behavior:**
```ruby
included do
  before_action :start_timing
  after_action :enforce_minimum_budget
end

def enforce_minimum_budget
  elapsed = Time.current - @start_time
  sleep([MIN_TIME - elapsed, MAX_SLEEP_TIME].min) if elapsed < MIN_TIME
end
```

**Issues:**
- `sleep()` adds 150-250ms artificial latency to EVERY request
- Cannot be disabled per-controller
- Impacts performance unexpectedly

**Recommended Approach:**
```ruby
# Use a dedicated base class instead of auto-application
class SecureApiController < ApplicationController
  include MinimumResponseBudget          # Safe: only methods, no callbacks
  enable_timing_protection!              # Explicit activation
end

class MyController < ApplicationController
  # No timing protection by default - must explicitly inherit
end
```

---

### 3. Preference Management (`Preference::Base`, `Preference::Core`)

**Current Behavior:**
```ruby
included do
  before_action :set_preferences_cookie
  helper_method :preferences_token, :preference_for
end

def set_preferences_cookie
  # Creates DB records if missing
  # Writes cookies on every request
  # Complex token rotation logic
end
```

**Issues:**
- Database writes on every request
- Cookie modifications on every request
- Cannot opt-out of automatic behavior

**Recommended Approach:**
```ruby
included do
  # No automatic callbacks - just method definitions
  helper_method :preferences_token, :preference_for
end

# Controllers opt-in explicitly
class MyController < ApplicationController
  include Preference::Base
  before_action :set_preferences_cookie  # Explicit opt-in
end

# Or use a concern that requires explicit configuration
class MyController < ApplicationController
  include Preference::Base
  enable_preference_tracking!            # Makes intent clear
end
```

---

### 4. Restricted Session Guard (`RestrictedSessionGuard`)

**Current Behavior:**
```ruby
included do
  before_action :enforce_restricted_session_guard!
end
```

**Issues:**
- Can return 423/403 automatically
- No opt-out mechanism

**Recommended Approach:**
```ruby
# Change to a mixin that only provides the method
included do
  # No callbacks - just the check method
end

# Controllers call it explicitly where needed
class MyController < ApplicationController
  include RestrictedSessionGuard
  before_action :enforce_restricted_session_guard!, if: :sensitive_action?
end
```

---

### 5. CSRF Protection for APIs (`ApiCsrfProtection`)

**Current Behavior:**
```ruby
included do
  before_action :check_csrf_origin
end
```

**Issues:**
- Blocks cross-origin requests automatically
- Can break API clients unexpectedly

**Recommended Approach:**
```ruby
# Move to ApplicationController with conditional activation
class ApiController < ApplicationController
  include ApiCsrfProtection  # Safe version with just methods
  
  # Explicit enable
  protect_from_csrf_origin!  # or skip_protect_from_csrf_origin!
end
```

---

### 6. Exception Handling Modifiers

**Concerns affected:**
- `AuthorizationAudit` - adds `rescue_from Pundit::NotAuthorizedError`
- `SocialAuthConcern` - adds `rescue_from SocialAuth::BaseError`

**Issues:**
- Changes global exception handling
- Can mask other errors
- Hard to override

**Recommended Approach:**
```ruby
# Don't use rescue_from in concerns
# Provide handler methods that controllers can call

included do
  # No rescue_from here
end

def self.included(base)
  base.class_eval do
    # Document this as providing helpers, not auto-handling
    # Controllers can do:
    # rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized
  end
end
```

Or provide a separate mixin:
```ruby
class MyController < ApplicationController
  include AuthorizationAudit               # Just methods
  include AuthorizationAudit::AutoHandle   # Explicit: includes rescue_from
end
```

---

## Medium Priority: Callback Safety

### 7. Current Support (`CurrentSupport`)

**Current Behavior:**
```ruby
included do
  after_action :_reset_current_state
end
```

**Issues:**
- Implicit state reset order could conflict with other after_actions

**Recommended Approach:**
```ruby
# Ensure explicit ordering or use prepend
included do
  after_action :_reset_current_state, prepend: true  # Ensure it runs last
end

# Or document the order expectation clearly
```

---

### 8. Auth Base (`Auth::Base`)

**Current Behavior:**
```ruby
included do
  include Sign::ErrorResponses
  include SessionLimitGate
  
  rescue_from LoginCooldownError, with: :handle_login_cooldown
end
```

**Issues:**
- Heavyweight automatic inclusion
- Multiple nested concerns
- Exception handler registration

**Recommended Approach:**
```ruby
# Split into concerns that 
# 1. Provide methods only  
# 2. Require explicit activation

module Auth::Base
  extend ActiveSupport::Concern
  
  include Auth::Base::Methods           # Safe: just method definitions
  include Auth::Base::ErrorHandling     # Safe: just handler methods
  # NO rescue_from here
end

# Controllers do:
class MyController < ApplicationController
  include Auth::Base
  
  rescue_from LoginCooldownError, with: :handle_login_cooldown  # Explicit
  before_action :setup_session_limits, if: :session_limiting_enabled?
end
```

---

## Low Priority: skip_before_action Cleanup

### 9. Health / Sitemap Concerns

**Current Behavior:**
```ruby
included do
  skip_before_action :canonicalize_query_params, raise: false
  public_strict!
end
```

**Issues:**
- Uses `raise: false` which catches ArgumentError silently
- May mask configuration errors

**Recommended Approach:**
```ruby
included do
  # Check if callback exists first
  if _process_action_callbacks.any? { |cb| cb.filter == :canonicalize_query_params }
    skip_before_action :canonicalize_query_params
  end
  
  public_strict!
end
```

Or better yet, don't include this concern in controllers that don't have the callback:
```ruby
class HealthController < ActionController::Base  # Not ApplicationController
  # Doesn't inherit canonicalization, so no need to skip
  include Health
end
```

---

## Recommended Architectural Patterns

### Pattern 1: Method-Only Concerns (Safe)

```ruby
module SafeConcern
  extend ActiveSupport::Concern
  
  # No included block with callbacks
  # Just method definitions
  
  class_methods do
    def some_class_method
    end
  end
  
  def some_instance_method
  end
end

# Usage: 
class MyController < ApplicationController
  include SafeConcern  # Zero side effects
  
  # Developer explicitly enables features
  before_action :some_instance_method
end
```

### Pattern 2: Configurable Concerns (Require Explicit Activation)

```ruby
module ConfigurableConcern
  extend ActiveSupport::Concern
  
  included do
    class_attribute :concern_enabled, default: false
  end
  
  class_methods do
    def enable_concern!
      self.concern_enabled = true
      before_action :concern_callback
    end
  end
  
  def concern_callback
    return unless self.class.concern_enabled
    # actual logic
  end
end

# Usage:
class MyController < ApplicationController
  include ConfigurableConcern  # No side effects yet
  enable_concern!              # Activates behavior
end
```

### Pattern 3: Dedicated Base Controllers (Explicit Inheritance)

```ruby
# Instead of including a concern with callbacks everywhere
class SecureController < ApplicationController
  include RateLimit::Enforced
  include MinimumResponseBudget::Enforced
  include ApiCsrfProtection::Enforced
end

class RegularController < ApplicationController
  # None of the above
end

class MyController < SecureController
  # Intentionally secures all actions
end
```

### Pattern 4: DSL with Configuration Block

```ruby
module DSLConcern
  extend ActiveSupport::Concern
  
  class_methods do
    def configure_concern(&block)
      @concern_config = DSLConfig.new
      @concern_config.instance_eval(&block)
      apply_concern_config(@concern_config)
    end
  end
end

# Usage:
class MyController < ApplicationController
  include DSLConcern
  
  configure_concern do
    enable_rate_limiting to: 300, within: 1.minute
    disable_for :index, :show
  end
end
```

---

## Migration Strategy (Zero Breaking Changes)

### Phase 1: Document Current Behavior
- [ ] Add comments to all concerns explaining automatic callbacks
- [ ] Create a directory listing all concerns with side effects
- [ ] Warn developers in PR template about including these concerns

### Phase 2: Introduce Safe Versions
- [ ] Create `RateLimit::Methods` (no callbacks)
- [ ] Create `MinimumResponseBudget::Methods` (no automatic timing)
- [ ] Create `Preference::Base::Methods` (no automatic DB writes)
- [ ] Keep original concerns for backward compatibility

### Phase 3: Add Explicit Activation
- [ ] Add `enable_*!` methods to concerns
- [ ] Add deprecation warnings when callbacks auto-apply
- [ ] Update all internal usages to use explicit activation

### Phase 4: Deprecate Auto-Behavior
- [ ] Flip default: auto-callbacks disabled by default
- [ ] Add `auto_enable_callbacks: true` for backward compatibility
- [ ] Update migration guide

### Phase 5: Remove Auto-Behavior
- [ ] Remove automatic callback registration
- [ ] Concerns become method-only by default
- [ ] Clean up deprecation code

---

## Files to Refactor (Priority Order)

### Immediate (High Risk)
1. `app/controllers/concerns/rate_limit.rb`
2. `app/controllers/concerns/minimum_response_budget.rb`
3. `app/controllers/concerns/preference/base.rb`
4. `app/controllers/concerns/restricted_session_guard.rb`
5. `app/controllers/concerns/api_csrf_protection.rb`
6. `app/controllers/concerns/authorization_audit.rb`
7. `app/controllers/concerns/social_auth_concern.rb`

### Near-term (Medium Risk)
8. `app/controllers/concerns/auth/base.rb`
9. `app/controllers/concerns/current_support.rb`
10. `app/controllers/concerns/social_callback_guard.rb`

### Later (Low Risk)
11. `app/controllers/concerns/health.rb`
12. `app/controllers/concerns/sitemap.rb`

### Model Concerns (Lower Priority)
13. `app/models/concerns/telephone.rb` (validations)
14. `app/models/concerns/email.rb` (validations)
15. `app/models/concerns/secret.rb` (has_secure_password)

---

## Testing Requirements

For each refactor:
- [ ] Existing tests must pass unchanged (backward compatibility)
- [ ] Add tests for explicit activation methods
- [ ] Add tests ensuring no callbacks when not activated
- [ ] Add integration tests for opt-in/opt-out scenarios
- [ ] Document breaking changes in CHANGELOG

---

## References

- Inspired by "`included` blocks that surprise the developer"
- Related to: ISO/IEC 25010 Maintainability - Modifiability
- Rails anti-pattern: Magic behavior through module inclusion
