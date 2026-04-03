# Engine Extraction Prep - 2026-04-03 Implementation Specification

## Context

This document is a detailed specification for another AI agent to execute. All file paths are
absolute. Code blocks show exact before/after transformations. The work prepares the codebase for
Rails Engine extraction (GitHub #553) by centralizing request context, eliminating hidden side
effects in concerns, improving infrastructure endpoints, and migrating to structured logging.

**Execution order matters.** Follow the phases sequentially. Run `bundle exec rails test` after each
phase.

---

## Phase 1: Expand `Current` Attributes

### Goal

Add `surface`, `realm`, and `request_id` to `Current` so it becomes the canonical request context
holder. Add `boundary_key` for flash boundary tracking (Phase 2).

### 1A: Modify `app/models/current.rb`

**Current file** (53 lines). Add three attributes and one class method.

```ruby
# BEFORE (line 5)
  attribute :actor, :actor_type, :session, :token, :domain, :preference,
            :trace_id, :span_id

# AFTER
  attribute :actor, :actor_type, :session, :token, :domain, :preference,
            :trace_id, :span_id,
            :surface, :realm, :request_id
```

Add `boundary_key` method after `authenticated?` (after line 39):

```ruby
  def self.boundary_key
    "#{realm}:#{surface}".freeze
  end
```

Add defaults for `surface` and `realm` (after the `preference` default, around line 19):

```ruby
  def self.surface
    super || :com
  end

  def self.realm
    super || :www
  end

  def self.request_id
    super || ""
  end
```

### 1B: Modify `app/controllers/concerns/current_support.rb`

**Current file** (153 lines).

#### Step 1: Remove `included do` block (lines 7-9)

```ruby
# BEFORE
  included do
    after_action :_reset_current_state
  end

# AFTER
# (delete the entire included do block)
```

Every controller that `include ::CurrentSupport` must now declare the after_action explicitly. See
the list of 13 controllers in section 1C.

#### Step 2: Expand `set_current` method (lines 13-22)

```ruby
# BEFORE
  def set_current
    Current.domain = resolved_current_domain

    resource = safe_current_resource
    Current.actor = resource.presence || Unauthenticated.instance
    Current.actor_type = resolved_current_actor_type(resource)
    Current.session ||= resolved_current_session
    Current.token ||= resolved_current_token
    Current.preference = resolved_current_preference(resource)
  end

# AFTER
  def set_current
    Current.domain = resolved_current_domain
    Current.surface = resolved_current_surface
    Current.realm = resolved_current_realm
    Current.request_id = request.request_id if respond_to?(:request, true) && request.present?

    resource = safe_current_resource
    Current.actor = resource.presence || Unauthenticated.instance
    Current.actor_type = resolved_current_actor_type(resource)
    Current.session ||= resolved_current_session
    Current.token ||= resolved_current_token
    Current.preference = resolved_current_preference(resource)
  end
```

#### Step 3: Add resolver methods (before `private` section or at end of private methods)

```ruby
  def resolved_current_surface
    return Current.surface if Current.surface.present? && Current.surface != :com
    return unless respond_to?(:request, true) && request.present?

    Core::Surface.current(request)
  end

  def resolved_current_realm
    return Current.realm if Current.realm.present? && Current.realm != :www
    return :www unless respond_to?(:params, true)

    # Derive realm from controller namespace: "sign/app/roots" -> :sign
    controller_path = params[:controller].to_s
    first_segment = controller_path.split("/").first
    case first_segment
    when "sign" then :sign
    when "core" then :core
    when "apex" then :apex
    when "docs" then :docs
    when "news" then :news
    when "help" then :help
    else :www
    end
  end
```

### 1C: Add explicit `after_action` to all controllers that include CurrentSupport

These 13 controllers currently rely on `CurrentSupport`'s `included do` block for
`after_action :_reset_current_state`. After removing the `included do`, each must declare it.

**Note**: Most of these already have `after_action :purge_current` (from Finisher concern). Add
`after_action :_reset_current_state` right after it (or after the last `after_action`).

Files to modify (add `after_action :_reset_current_state` after the last existing `after_action`):

1. `app/controllers/core/app/application_controller.rb` (line 35: `after_action :purge_current`)
2. `app/controllers/core/com/application_controller.rb`
3. `app/controllers/core/org/application_controller.rb`
4. `app/controllers/apex/app/application_controller.rb`
5. `app/controllers/apex/com/application_controller.rb`
6. `app/controllers/apex/org/application_controller.rb`
7. `app/controllers/sign/app/application_controller.rb` (line 42: `after_action :purge_current`)
8. `app/controllers/sign/com/application_controller.rb`
9. `app/controllers/sign/org/application_controller.rb`
10. `app/controllers/docs/app/application_controller.rb`
11. `app/controllers/docs/com/application_controller.rb`
12. `app/controllers/docs/org/application_controller.rb`
13. `app/controllers/sign/org/up/base_controller.rb`

### 1D: Tests

Create `test/unit/models/current_test.rb`:

```ruby
# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  setup do
    Current.reset
  end

  teardown do
    Current.reset
  end

  test "surface defaults to :com" do
    assert_equal :com, Current.surface
  end

  test "realm defaults to :www" do
    assert_equal :www, Current.realm
  end

  test "request_id defaults to empty string" do
    assert_equal "", Current.request_id
  end

  test "boundary_key combines realm and surface" do
    Current.realm = :sign
    Current.surface = :app
    assert_equal "sign:app", Current.boundary_key
  end

  test "boundary_key uses defaults when not set" do
    assert_equal "www:com", Current.boundary_key
  end

  test "boundary_key is frozen" do
    assert Current.boundary_key.frozen?
  end
end
```

---

## Phase 2: Cross-Subdomain Flash Cleanup

### Goal

Implement flash boundary validation in the Session concern. Prevent flash messages from leaking
across subdomain boundaries.

### 2A: Rewrite `app/controllers/concerns/session.rb`

Replace the entire file:

```ruby
# typed: false
# frozen_string_literal: true

# Concern for flash boundary enforcement across subdomains.
#
# Prevents flash messages from leaking when users navigate between
# different surfaces (app/com/org) and realms (sign/core/apex/docs).
#
# Usage:
#   class ApplicationController < ActionController::Base
#     include ::Session
#     before_action :validate_flash_boundary
#   end
module Session
  extend ActiveSupport::Concern

  FLASH_BOUNDARY_SESSION_KEY = :_flash_boundary

  # Allowed transitions where flash carry-over is intentional.
  # Format: "from_realm:from_surface -> to_realm:to_surface"
  ALLOWED_TRANSITIONS = Set[
    "sign:app -> core:app",
    "sign:com -> core:com",
    "sign:org -> core:org",
    "sign:app -> apex:app",
    "sign:com -> apex:com",
    "sign:org -> apex:org",
  ].freeze

  private

  # Call this as a before_action to discard flash on boundary mismatch.
  def validate_flash_boundary
    stored_boundary = session[FLASH_BOUNDARY_SESSION_KEY]

    # No stored boundary means no flash was set from another boundary.
    return if stored_boundary.blank?

    current_boundary = Current.boundary_key

    # Same boundary - flash is valid.
    return if stored_boundary == current_boundary

    # Check allowlist for permitted transitions.
    transition = "#{stored_boundary} -> #{current_boundary}"
    return if ALLOWED_TRANSITIONS.include?(transition)

    # Boundary mismatch - discard flash to prevent leakage.
    flash.discard
    session.delete(FLASH_BOUNDARY_SESSION_KEY)
  end

  # Record the current boundary when flash is written.
  # Call this after setting flash messages, or override flash setters.
  def record_flash_boundary
    session[FLASH_BOUNDARY_SESSION_KEY] = Current.boundary_key
  end

  # Explicitly reset flash and clear the boundary marker.
  def reset_flash
    return unless flash.any?

    flash.discard
    session.delete(FLASH_BOUNDARY_SESSION_KEY)
  end
end
```

### 2B: Update controllers to use validate_flash_boundary

The Session concern is included in 12 application controllers. Each already has
`before_action :reset_flash`. Replace it with `before_action :validate_flash_boundary`:

```ruby
# BEFORE
before_action :reset_flash

# AFTER
before_action :validate_flash_boundary
```

Files to modify:

1. `app/controllers/core/app/application_controller.rb` (line 28)
2. `app/controllers/core/com/application_controller.rb`
3. `app/controllers/core/org/application_controller.rb`
4. `app/controllers/apex/app/application_controller.rb`
5. `app/controllers/apex/com/application_controller.rb`
6. `app/controllers/apex/org/application_controller.rb`
7. `app/controllers/sign/app/application_controller.rb`
8. `app/controllers/sign/com/application_controller.rb`
9. `app/controllers/sign/org/application_controller.rb`
10. `app/controllers/docs/app/application_controller.rb`
11. `app/controllers/docs/com/application_controller.rb`
12. `app/controllers/docs/org/application_controller.rb`

### 2C: Add `record_flash_boundary` calls where flash is set

Search for `flash[:` and `flash.now[:` across controllers. After each flash assignment, call
`record_flash_boundary`. Key locations:

- `app/controllers/concerns/social_auth_concern.rb` (lines 187, 209)
- `app/controllers/concerns/authorization_audit.rb` (line 31)
- `app/controllers/concerns/sign/error_responses.rb` (line 31)
- Any other controller that sets flash

Pattern:

```ruby
# BEFORE
flash[:alert] = error.message
redirect_to(some_path)

# AFTER
flash[:alert] = error.message
record_flash_boundary
redirect_to(some_path)
```

### 2D: Tests

Create `test/unit/controllers/concerns/session_test.rb`:

```ruby
# typed: false
# frozen_string_literal: true

require "test_helper"

class SessionConcernTest < ActiveSupport::TestCase
  include Session

  setup do
    Current.reset
    @session = {}
  end

  # Stub session for testing
  def session
    @session
  end

  # Stub flash
  def flash
    @flash ||= FlashStub.new
  end

  class FlashStub
    attr_reader :discarded

    def initialize
      @data = {}
      @discarded = false
    end

    def [](key) = @data[key]
    def []=(key, value) = @data[key] = value
    def any? = @data.any?
    def discard = @discarded = true
  end

  test "validate_flash_boundary does nothing when no stored boundary" do
    Current.realm = :sign
    Current.surface = :app
    validate_flash_boundary
    refute flash.discarded
  end

  test "validate_flash_boundary does nothing when boundaries match" do
    Current.realm = :sign
    Current.surface = :app
    @session[:_flash_boundary] = "sign:app"
    validate_flash_boundary
    refute flash.discarded
  end

  test "validate_flash_boundary discards flash on mismatch" do
    Current.realm = :core
    Current.surface = :app
    @session[:_flash_boundary] = "apex:org"
    flash[:alert] = "test"
    validate_flash_boundary
    assert flash.discarded
    assert_nil @session[:_flash_boundary]
  end

  test "validate_flash_boundary allows sign->core transition" do
    Current.realm = :core
    Current.surface = :app
    @session[:_flash_boundary] = "sign:app"
    validate_flash_boundary
    refute flash.discarded
  end

  test "record_flash_boundary stores current boundary" do
    Current.realm = :sign
    Current.surface = :app
    record_flash_boundary
    assert_equal "sign:app", @session[:_flash_boundary]
  end

  test "reset_flash discards flash and clears boundary" do
    @session[:_flash_boundary] = "sign:app"
    flash[:alert] = "test"
    reset_flash
    assert flash.discarded
    assert_nil @session[:_flash_boundary]
  end

  teardown do
    Current.reset
  end
end
```

---

## Phase 3: Eliminate `included do` in Controller Concerns

### Strategy

For each concern with `included do`, extract behavioral registrations into a class method named
`activate_<concern_name>`. Keep only pure declarative items in `included do` (if any remain). The
includer then calls the activation method explicitly.

### Batch 1: Authentication Pipeline (HIGHEST RISK)

#### 3.1.1: `app/controllers/concerns/authentication/base.rb`

Lines 861-872:

```ruby
# BEFORE
    included do
      include ::Sign::ErrorResponses
      include ::SessionLimitGate

      if respond_to?(:rescue_from)
        rescue_from LoginCooldownError, with: :render_login_cooldown
      end

      if respond_to?(:helper_method)
        helper_method :current_account, :current_session_public_id, :current_session_restricted?
      end
    end

# AFTER
    class_methods do
      # ... (existing class_methods block already exists at line 877, merge into it)

      def activate_authentication_base
        include ::Sign::ErrorResponses
        include ::SessionLimitGate

        if respond_to?(:rescue_from)
          rescue_from LoginCooldownError, with: :render_login_cooldown
        end

        if respond_to?(:helper_method)
          helper_method :current_account, :current_session_public_id, :current_session_restricted?
        end
      end
    end
```

**Important**: The existing `class_methods do` block starts at line 877. Merge
`activate_authentication_base` into it. Do NOT create a second `class_methods do` block.

Delete the entire `included do` block (lines 861-872).

**Controller impact**: `Authentication::Base` is included via `Authentication::User`,
`Authentication::Staff`, `Authentication::Customer`, and `Authentication::Viewer`. The activation
should be called from each of those sub-concerns' activation methods (see below).

#### 3.1.2: `app/controllers/concerns/authentication/user.rb`

Lines 17-23:

```ruby
# BEFORE
    included do
      helper_method :current_user, :logged_in?, :active_user?, :logged_in_user? if respond_to?(:helper_method)
      alias_method :current_user, :current_resource
      alias_method :authenticate_user!, :authenticate!
      alias_method :logged_in_user?, :logged_in?
      include ::AuthorizationAudit
    end

# AFTER
    class_methods do
      def activate_user_authentication
        activate_authentication_base

        helper_method :current_user, :logged_in?, :active_user?, :logged_in_user? if respond_to?(:helper_method)
        alias_method :current_user, :current_resource
        alias_method :authenticate_user!, :authenticate!
        alias_method :logged_in_user?, :logged_in?
        include ::AuthorizationAudit
      end
    end
```

**Controllers to update** (add `activate_user_authentication` after
`include ::Authentication::User`):

- `app/controllers/core/app/application_controller.rb` (line 10)
- `app/controllers/core/com/application_controller.rb`
- `app/controllers/apex/app/application_controller.rb`
- `app/controllers/sign/app/application_controller.rb`
- `app/controllers/docs/app/application_controller.rb`

Pattern:

```ruby
# BEFORE
include ::Authentication::User

# AFTER
include ::Authentication::User
activate_user_authentication
```

#### 3.1.3: `app/controllers/concerns/authentication/staff.rb`

Lines 17-27:

```ruby
# BEFORE
    included do
      helper_method :current_staff, :logged_in?, :active_staff?,
                    :logged_in_staff? if respond_to?(:helper_method)
      alias_method :current_staff, :current_resource
      alias_method :authenticate_staff!, :authenticate!
      alias_method :logged_in_staff?, :logged_in?
      before_action :transparent_refresh_access_token, unless: -> {
        request.format.json?
      } if respond_to?(:before_action)
      include ::AuthorizationAudit
    end

# AFTER
    class_methods do
      def activate_staff_authentication
        activate_authentication_base

        helper_method :current_staff, :logged_in?, :active_staff?,
                      :logged_in_staff? if respond_to?(:helper_method)
        alias_method :current_staff, :current_resource
        alias_method :authenticate_staff!, :authenticate!
        alias_method :logged_in_staff?, :logged_in?
        include ::AuthorizationAudit
      end
    end
```

**Note**: The `before_action :transparent_refresh_access_token` that was in `included do` is
**already declared explicitly** in the controllers that need it (e.g.,
`core/app/application_controller.rb` line 30, `sign/app/application_controller.rb` line 37). So it
does NOT need to be in the activation method. Removing it from the concern eliminates the duplicate
registration.

**Controllers to update** (add `activate_staff_authentication` after
`include ::Authentication::Staff`):

- `app/controllers/core/org/application_controller.rb`
- `app/controllers/apex/org/application_controller.rb`
- `app/controllers/sign/org/application_controller.rb`
- `app/controllers/docs/org/application_controller.rb`

#### 3.1.4: `app/controllers/concerns/authentication/customer.rb`

Lines 17-23:

```ruby
# BEFORE
    included do
      helper_method :current_customer, :logged_in?, :active_customer?,
                    :logged_in_customer? if respond_to?(:helper_method)
      alias_method :current_customer, :current_resource
      alias_method :authenticate_customer!, :authenticate!
      alias_method :logged_in_customer?, :logged_in?
      include ::AuthorizationAudit
    end

# AFTER
    class_methods do
      def activate_customer_authentication
        activate_authentication_base

        helper_method :current_customer, :logged_in?, :active_customer?,
                      :logged_in_customer? if respond_to?(:helper_method)
        alias_method :current_customer, :current_resource
        alias_method :authenticate_customer!, :authenticate!
        alias_method :logged_in_customer?, :logged_in?
        include ::AuthorizationAudit
      end
    end
```

**Controllers to update**:

- `app/controllers/sign/com/application_controller.rb`
- `app/controllers/apex/com/application_controller.rb`

#### 3.1.5: `app/controllers/concerns/authentication/viewer.rb`

Lines 10-16:

```ruby
# BEFORE
    included do
      helper_method :current_viewer, :logged_in?, :active_viewer?,
                    :logged_in_viewer? if respond_to?(:helper_method)
      alias_method :current_viewer, :current_resource
      alias_method :authenticate_viewer!, :authenticate!
      alias_method :logged_in_viewer?, :logged_in?
    end

# AFTER
    class_methods do
      def activate_viewer_authentication
        activate_authentication_base

        helper_method :current_viewer, :logged_in?, :active_viewer?,
                      :logged_in_viewer? if respond_to?(:helper_method)
        alias_method :current_viewer, :current_resource
        alias_method :authenticate_viewer!, :authenticate!
        alias_method :logged_in_viewer?, :logged_in?
      end
    end
```

**Controllers to update**:

- `app/controllers/docs/com/application_controller.rb`

### Batch 2: Sign Flow Concerns

#### 3.2.1: `app/controllers/concerns/sign/error_responses.rb`

```ruby
# BEFORE (lines 16-25)
    included do
      include Common::Redirect

      if respond_to?(:rescue_from)
        rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized if defined?(Pundit)
        rescue_from ApplicationError, with: :handle_application_error
        rescue_from ActionController::InvalidCrossOriginRequest, with: :handle_csrf_failure
      end
    end

# AFTER
    class_methods do
      def activate_error_responses
        include Common::Redirect

        if respond_to?(:rescue_from)
          rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized if defined?(Pundit)
          rescue_from ApplicationError, with: :handle_application_error
          rescue_from ActionController::InvalidCrossOriginRequest, with: :handle_csrf_failure
        end
      end
    end
```

**Note**: `Sign::ErrorResponses` is included from `Authentication::Base`'s
`activate_authentication_base`. Update `activate_authentication_base` to call
`activate_error_responses` after including:

```ruby
def activate_authentication_base
  include ::Sign::ErrorResponses
  activate_error_responses
  include ::SessionLimitGate
  # ... rest
end
```

#### 3.2.2: `app/controllers/concerns/sign/edge_v0_json_api.rb`

```ruby
# BEFORE (lines 8-11)
    included do
      before_action :ensure_json_request
      skip_before_action :set_region
    end

# AFTER
    class_methods do
      def activate_edge_v0_json_api
        before_action :ensure_json_request
        skip_before_action :set_region
      end
    end
```

Find all controllers that `include Sign::EdgeV0JsonApi` and add `activate_edge_v0_json_api`.

#### 3.2.3: `app/controllers/concerns/social_auth_concern.rb`

```ruby
# BEFORE (lines 31-34)
  included do
    rescue_from SocialAuth::BaseError, with: :handle_social_auth_error
    rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique
  end

# AFTER
  class_methods do
    def activate_social_auth_concern
      rescue_from SocialAuth::BaseError, with: :handle_social_auth_error
      rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique
    end
  end
```

Find all controllers that `include SocialAuthConcern` and add `activate_social_auth_concern`.

#### 3.2.4: `app/controllers/concerns/social_callback_guard.rb`

Find and replace `included do` block with activation class method. Same pattern.

#### 3.2.5: `app/controllers/concerns/sign/app_verification_base.rb`

Lines 23-40:

```ruby
# BEFORE
    included do
      include ::Preference::Global
      include Common::Otp
      include ::Verification::User
      include Sign::Webauthn
      include Sign::VerificationTiming
      include Sign::VerificationCommonBase
      include Sign::VerificationAuditAndCookie
      include Sign::VerificationReauthSessionStore
      include Sign::VerificationReauthLifecycle
      include Sign::VerificationPasskeyChecks
      include Sign::VerificationTotpChecks

      before_action :authenticate_user!
      before_action :set_actor_token
      before_action :require_ri!
      before_action :enforce_step_up_prereqs!
    end

# AFTER
    class_methods do
      def activate_app_verification_base
        include ::Preference::Global
        include Common::Otp
        include ::Verification::User
        include Sign::Webauthn
        include Sign::VerificationTiming
        include Sign::VerificationCommonBase
        include Sign::VerificationAuditAndCookie
        include Sign::VerificationReauthSessionStore
        include Sign::VerificationReauthLifecycle
        include Sign::VerificationPasskeyChecks
        include Sign::VerificationTotpChecks

        before_action :authenticate_user!
        before_action :set_actor_token
        before_action :require_ri!
        before_action :enforce_step_up_prereqs!
      end
    end
```

Apply the same pattern for `sign/org_verification_base.rb` and `sign/com_verification_base.rb`.

#### 3.2.6: Remaining Sign concerns

Apply the same `included do` -> `activate_*` pattern for:

- `sign/email_registrable.rb`
- `sign/email_registration_flow.rb`
- `sign/telephone_registrable.rb`

### Batch 3: Preference & Utility Concerns

#### 3.3.1: `app/controllers/concerns/authorization_audit.rb`

```ruby
# BEFORE (lines 9-15)
  included do
    include Common::Redirect

    if respond_to?(:rescue_from)
      rescue_from Pundit::NotAuthorizedError, with: :handle_authorization_error
    end
  end

# AFTER
  class_methods do
    def activate_authorization_audit
      include Common::Redirect

      if respond_to?(:rescue_from)
        rescue_from Pundit::NotAuthorizedError, with: :handle_authorization_error
      end
    end
  end
```

**Note**: `AuthorizationAudit` is included from `Authentication::User`, `Staff`, `Customer`
activation methods. Update those to call `activate_authorization_audit` after include:

```ruby
include ::AuthorizationAudit
activate_authorization_audit
```

#### 3.3.2: `app/controllers/concerns/minimum_response_budget.rb`

```ruby
# BEFORE (lines 7-10)
  included do
    before_action :start_minimum_response_budget
    after_action :enforce_minimum_response_budget
  end

# AFTER
  class_methods do
    def activate_minimum_response_budget
      before_action :start_minimum_response_budget
      after_action :enforce_minimum_response_budget
    end
  end
```

**Controllers to update** (3 passkey controllers):

- `app/controllers/sign/com/in/passkeys_controller.rb`
- `app/controllers/sign/app/in/passkeys_controller.rb`
- `app/controllers/sign/org/in/passkeys_controller.rb`

#### 3.3.3: `app/controllers/concerns/oidc/callback.rb`

Replace `included do; public_strict!; end` with:

```ruby
  class_methods do
    def activate_oidc_callback
      public_strict!
    end
  end
```

#### 3.3.4: Preference concerns

Apply the same pattern for each. Read each file first, then extract `included do` contents.

Priority files:

- `preference/regional.rb` (has 5 `before_action` + 1 `helper_method`)
- `preference/base.rb` (large file, inspect carefully)
- `preference/core.rb`
- `preference/edge.rb`
- `preference/global.rb`
- `preference/web_cookie_actions.rb`
- `preference/web_theme_actions.rb`

### Verification

After completing all batches:

```bash
bundle exec rails test
bundle exec rubocop app/controllers/concerns/ app/models/current.rb
```

Grep to verify no `included do` remains in controller concerns (except pure declarative ones):

```bash
grep -rn "included do" app/controllers/concerns/
```

---

## Phase 4: Dynamic Sitemap + Robots + Health Improvements

### 4A: `app/controllers/concerns/robots.rb`

```ruby
# BEFORE (entire file)
module Robots
  extend ActiveSupport::Concern

  private

  def show_plain_text
    render plain: robots_txt
  end

  def robots_txt
    "User-agent: *\nDisallow:\n"
  end
end

# AFTER
module Robots
  extend ActiveSupport::Concern

  private

  def show_plain_text
    response.set_header("Cache-Control", "public, max-age=3600, s-maxage=86400")
    render plain: robots_txt
  end

  def robots_txt
    case Current.surface
    when :org
      "User-agent: *\nDisallow: /\n"
    when :app
      "User-agent: *\nDisallow: /configuration\nDisallow: /api\nDisallow: /web\n"
    else
      "User-agent: *\nDisallow:\n"
    end
  end
end
```

### 4B: `app/controllers/concerns/sitemap.rb`

Add a helper method for building sitemap entries:

```ruby
# ADD after sitemap_urls method (line 27)

  def sitemap_entry(loc:, lastmod: nil, changefreq: nil, priority: nil)
    entry = { loc: loc }
    entry[:lastmod] = lastmod.iso8601 if lastmod.respond_to?(:iso8601)
    entry[:changefreq] = changefreq if changefreq
    entry[:priority] = priority if priority
    entry
  end
```

### 4C: `app/controllers/concerns/health.rb`

Fix the `show_json` destructuring bug on line 105:

```ruby
# BEFORE (line 105)
  def show_json
    @status, @body, @errors = get_status
    response_body = { status: @body, timestamp: Time.now.utc.iso8601, revision: @revision }

# AFTER
  def show_json
    @status, @body, @errors, @revision = get_status
    response_body = { status: @body, timestamp: Time.now.utc.iso8601, revision: @revision }
```

Add `Current.surface` to the JSON response (after line 107):

```ruby
# BEFORE
    response_body = { status: @body, timestamp: Time.now.utc.iso8601, revision: @revision }
    response_body[:errors] = @errors if @errors.present?

# AFTER
    response_body = { status: @body, timestamp: Time.now.utc.iso8601, revision: @revision, surface: Current.surface }
    response_body[:errors] = @errors if @errors.present?
```

---

## Phase 5: Rails.logger -> Rails.event Migration (Remaining Work)

### Status

Sections 5.1–5.5, 5.7, 5.9, and parts of 5.8/5.10 are **already complete**. The following 7 files,
17 calls remain. Complete these to finish Phase 5.

### Conversion Rules

| Original                            | Replacement                                                  |
| ----------------------------------- | ------------------------------------------------------------ |
| `Rails.logger.error("msg: #{val}")` | `Rails.event.error("namespace.event", message: val)`         |
| `Rails.logger.warn("msg")`          | `Rails.event.warn("namespace.event", message: "msg")`        |
| `Rails.logger.debug { "msg" }`      | `Rails.event.debug("namespace.event", <structured fields>)`  |
| `Rails.logger.info("msg")`          | `Rails.event.record("namespace.event", <structured fields>)` |
| error + backtrace 2-line pair       | Merge into 1 call with `backtrace: e.backtrace&.first(5)`    |

### 5A: `app/services/social_auth_service.rb` (6 calls)

Namespace: `social_auth.*`

```ruby
# BEFORE (lines 38-40)
    Rails.logger.debug do
      "[SocialAuth] handle_callback started - intent: #{@intent.inspect}, current_user: #{@current_user&.id}"
    end

# AFTER
    Rails.event.debug("social_auth.handle_callback.started", intent: @intent, current_user_id: @current_user&.id)
```

```ruby
# BEFORE (lines 49-52)
    Rails.logger.debug do
      "[SocialAuth] Extracted - provider: #{provider}, uid: #{uid&.first(8)}***, " \
        "identity_class: #{identity_class.name}"
    end

# AFTER
    Rails.event.debug("social_auth.handle_callback.extracted", provider: provider, uid_prefix: uid&.first(8), identity_class: identity_class.name)
```

```ruby
# BEFORE (line 58)
          Rails.logger.debug { "[SocialAuth] Processing login intent" }
# AFTER
          Rails.event.debug("social_auth.handle_callback.processing_intent", intent: "login")

# BEFORE (line 61)
          Rails.logger.debug { "[SocialAuth] Processing link intent" }
# AFTER
          Rails.event.debug("social_auth.handle_callback.processing_intent", intent: "link")

# BEFORE (line 64)
          Rails.logger.debug { "[SocialAuth] Processing reauth intent" }
# AFTER
          Rails.event.debug("social_auth.handle_callback.processing_intent", intent: "reauth")
```

```ruby
# BEFORE (lines 69-72)
    Rails.logger.debug do
      "[SocialAuth] handle_callback completed - user_id: #{result[:user]&.id}, " \
        "identity_id: #{result[:identity]&.id}"
    end

# AFTER
    Rails.event.debug("social_auth.handle_callback.completed", user_id: result[:user]&.id, identity_id: result[:identity]&.id)
```

### 5B: `app/services/auth/audit_writer.rb` (3 calls -> 2)

Namespace: `auth.audit.*`

```ruby
# BEFORE (line 31)
          Rails.logger.error("[Auth::AuditWriter] #{error_message}")

# AFTER
          Rails.event.error("auth.audit.save_failed", message: error_message)
```

```ruby
# BEFORE (lines 48-49) -- merge backtrace pair into single call
      Rails.logger.error("[Auth::AuditWriter] Audit write failed (best-effort): #{e.class}: #{e.message}")
      Rails.logger.error(e.backtrace.first(5).join("\n")) if e.backtrace

# AFTER
      Rails.event.error("auth.audit.write_failed", error_class: e.class.name, message: e.message, backtrace: e.backtrace&.first(5))
```

### 5C: `app/controllers/concerns/social_callback_guard.rb` (3 calls)

Namespace: `social_auth.callback_guard.*`

```ruby
# BEFORE (lines 328-331) -- note: info -> record (Rails.event has no info level)
    Rails.logger.info(
      "[SocialCallbackGuard] phase=callback provider=#{provider.inspect} " \
      "reason=source_observed details=#{source.inspect}",
    )

# AFTER
    Rails.event.record("social_auth.callback_guard.source_observed", provider: provider, source: source)
```

```ruby
# BEFORE (lines 337-339)
    Rails.logger.warn(
      "[SocialCallbackGuard] phase=callback provider=#{provider.inspect} reason=#{reason} details=#{details.inspect}",
    )

# AFTER
    Rails.event.warn("social_auth.callback_guard.rejected", provider: provider, reason: reason, details: details)
```

```ruby
# BEFORE (lines 392-394) -- class method
    Rails.logger.warn(
      "[SocialCallbackGuard] phase=#{phase} provider=#{provider.inspect} reason=#{reason} details=#{details.inspect}",
    )

# AFTER
    Rails.event.warn("social_auth.callback_guard.rejected_request_phase", phase: phase, provider: provider, reason: reason, details: details)
```

### 5D: `app/models/staff.rb` (2 calls -> 1)

Namespace: `staff.*`

```ruby
# BEFORE (lines 166-170) -- merge backtrace pair into single call
      Rails.logger.error(
        "[Staff] Failed to generate unique public_id after #{MAX_PUBLIC_ID_RETRIES} retries: " \
        "#{e.class}: #{e.message} (last public_id=#{public_id.inspect})",
      )
      Rails.logger.error(e.backtrace.first(5).join("\n")) if e.backtrace

# AFTER
      Rails.event.error(
        "staff.public_id_generation_failed",
        retries: MAX_PUBLIC_ID_RETRIES,
        error_class: e.class.name,
        message: e.message,
        last_public_id: public_id,
        backtrace: e.backtrace&.first(5),
      )
```

### 5E: `app/controllers/concerns/preference/core.rb` (1 call)

Namespace: `preference.*`

```ruby
# BEFORE (line 397)
    Rails.logger.error("log_preference_reset failed: #{e.class} - #{e.message}")

# AFTER
    Rails.event.error("preference.log_reset_failed", error_class: e.class.name, message: e.message)
```

### 5F: `app/services/jit/security/jwt/anomaly_reporter.rb` (1 call)

Namespace: `security.jwt.*`

```ruby
# BEFORE (line 90)
          Rails.logger.error("Jwt anomaly reporting failed: #{e.class}: #{e.message}")

# AFTER
          Rails.event.error("security.jwt.anomaly_report_failed", error_class: e.class.name, message: e.message)
```

### 5G: `app/controllers/sign/org/auth/omniauth_callbacks_controller.rb` (1 call)

Namespace: `social_auth.*`

```ruby
# BEFORE (lines 251-254)
          Rails.logger.warn(
            "[SocialCallbackGuard] org phase=callback provider=#{provider.inspect} " \
            "reason=#{reason} details=#{details.inspect}",
          )

# AFTER
          Rails.event.warn(
            "social_auth.callback_guard.org_rejected",
            provider: provider,
            reason: reason,
            details: details,
          )
```

### 5H: `app/models/application_push_device.rb` (comment only)

Line 5 contains a commented-out `Rails.logger.error`. Update the comment to use `Rails.event`:

```ruby
# BEFORE (line 5)
  # rescue_from (ActionPushNative::TokenError) { Rails.logger.error("Device #{id} token is invalid") }

# AFTER
  # rescue_from (ActionPushNative::TokenError) { Rails.event.error("push_device.invalid_token", device_id: id) }
```

### Verification

```bash
# Verify no Rails.logger remains in app/ (excluding comments)
grep -rn "Rails\.logger\." app/ --include="*.rb" | grep -v "^.*:#" | grep -v vendor | grep -v node_modules
```

Should return 0 results.

---

## Phase 6: Dead Code Investigation (Debride - Investigation Only)

### Goal

Run Debride and document findings. Do NOT delete any code.

### Steps

```bash
# Run with default targets
bin/debride > tmp/debride_report.txt 2>&1

# Run with additional targets
bin/debride app/lib >> tmp/debride_report.txt 2>&1
bin/debride app/controllers/concerns >> tmp/debride_report.txt 2>&1

# Verbose mode
DEBRIDE_VERBOSE=1 bin/debride >> tmp/debride_verbose.txt 2>&1
```

### Output

Save the full report to `tmp/debride_report.txt`. Do not modify any code based on results.

---

## Acceptance Criteria

- [ ] `Current.surface`, `Current.realm`, `Current.request_id`, `Current.boundary_key` work
      correctly
- [ ] Flash is discarded when crossing subdomain boundaries
- [ ] Allowed transitions (sign -> core/apex for same surface) preserve flash
- [ ] No `included do` blocks remain in controller concerns (except pure declarative:
      `public_strict!`, `enum`, `encrypts`)
- [ ] All controllers explicitly call `activate_*` methods after including concerns
- [ ] `robots.txt` returns surface-specific rules
- [ ] Health JSON endpoint includes `@revision` (bug fix) and `surface`
- [ ] Zero `Rails.logger.*` calls remain in `app/` (excluding comments)
- [ ] `bundle exec rails test` passes
- [ ] `bundle exec rubocop` passes (or only pre-existing violations)
- [ ] Debride report saved to `tmp/debride_report.txt`
