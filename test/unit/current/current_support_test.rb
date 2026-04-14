# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentSupportTest < ActiveSupport::TestCase
  # Minimal test host that includes the concern, simulating a controller.
  class Host
    include ActiveSupport::Callbacks

    define_callbacks :action

    # Stub controller callback macros expected by CurrentSupport.
    def self.after_action(*, **) = nil

    def self.before_action(*, **) = nil

    def self.prepend_before_action(*, **) = nil

    include CurrentSupport

    # Expose private methods for testing.
    public :set_current_observability, :resolved_resource_preference,
           :resolved_current_token, :resolved_current_actor_type,
           :resolved_current_preference, :current_analytics_consent,
           :current_optional_analytics_allowed?, :current_targeting_allowed?
  end

  setup do
    Current.reset
    @host = Host.new
  end

  teardown { Current.reset }

  # --- set_current_observability ---

  test "set_current_observability is no-op when OpenTelemetry is not loaded" do
    @host.set_current_observability

    assert_nil Current.trace_id
    assert_nil Current.span_id
  end

  test "set_current_observability does not mutate unrelated Current attributes" do
    user = users(:one)
    Current.actor = user
    Current.domain = :app

    @host.set_current_observability

    assert_equal user, Current.actor
    assert_equal :app, Current.domain
  end

  test "set_current_observability skips when performant cookie is not consented" do
    # Default preference has performant? == false
    assert_not Current.preference.cookie.performant?

    hex_trace_id = "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4"
    hex_span_id  = "f1e2d3c4b5a6f1e2"

    span_context = Minitest::Mock.new
    span_context.expect(:valid?, true)
    span_context.expect(:hex_trace_id, hex_trace_id)
    span_context.expect(:hex_span_id, hex_span_id)

    span = Minitest::Mock.new
    span.expect(:context, span_context)

    otel_trace = Module.new
    otel_trace.define_singleton_method(:current_span) { span }

    stub_const(:OpenTelemetry, Module.new { const_set(:Trace, otel_trace) }) do
      @host.set_current_observability
    end

    assert_nil Current.trace_id, "trace_id must not be set without performant consent"
    assert_nil Current.span_id, "span_id must not be set without performant consent"
  end

  test "set_current_observability sets trace_id and span_id when performant is consented" do
    cookie = Current::Preference::Cookie.new(
      consented: true, functional: true, performant: true,
      targetable: false, consent_version: "1", consented_at: Time.current,
    )
    Current.preference = Current::Preference.new(cookie: cookie)

    hex_trace_id = "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4"
    hex_span_id  = "f1e2d3c4b5a6f1e2"

    span_context = Minitest::Mock.new
    span_context.expect(:valid?, true)
    span_context.expect(:hex_trace_id, hex_trace_id)
    span_context.expect(:hex_span_id, hex_span_id)

    span = Minitest::Mock.new
    span.expect(:context, span_context)

    otel_trace = Module.new
    otel_trace.define_singleton_method(:current_span) { span }

    stub_const(:OpenTelemetry, Module.new { const_set(:Trace, otel_trace) }) do
      @host.set_current_observability
    end

    assert_equal hex_trace_id, Current.trace_id
    assert_equal hex_span_id, Current.span_id

    span_context.verify
    span.verify
  end

  test "set_current_observability skips when span context is invalid" do
    cookie = Current::Preference::Cookie.new(
      consented: true, functional: true, performant: true,
      targetable: false, consent_version: "1", consented_at: Time.current,
    )
    Current.preference = Current::Preference.new(cookie: cookie)

    span_context = Minitest::Mock.new
    span_context.expect(:valid?, false)

    span = Minitest::Mock.new
    span.expect(:context, span_context)

    otel_trace = Module.new
    otel_trace.define_singleton_method(:current_span) { span }

    stub_const(:OpenTelemetry, Module.new { const_set(:Trace, otel_trace) }) do
      @host.set_current_observability
    end

    assert_nil Current.trace_id
    assert_nil Current.span_id

    span_context.verify
    span.verify
  end

  test "set_current_observability can be overridden by subclass" do
    custom_host_class =
      Class.new(Host) do
        define_method(:set_current_observability) do
          Current.trace_id = "custom_trace"
        end
      end

    custom_host_class.new.set_current_observability

    assert_equal "custom_trace", Current.trace_id
  end

  test "current analytics consent reflects current preference cookie" do
    cookie = Current::Preference::Cookie.new(
      consented: true, functional: true, performant: true,
      targetable: false, consent_version: "1", consented_at: Time.current,
    )
    Current.preference = Current::Preference.new(cookie: cookie)

    assert_equal cookie, @host.current_analytics_consent
    assert_predicate @host, :current_optional_analytics_allowed?
    assert_not @host.current_targeting_allowed?
  end

  test "current analytics consent defaults to disabled state" do
    assert_not_predicate @host, :current_optional_analytics_allowed?
    assert_not_predicate @host, :current_targeting_allowed?
  end

  # --- resolved_resource_preference does NOT call set_current_observability ---

  test "resolved_resource_preference does not call set_current_observability" do
    called = false
    host_class =
      Class.new(Host) do
        define_method(:set_current_observability) do
          called = true
        end
      end

    resource = Object.new
    resource.define_singleton_method(:user_preference) { nil }

    host_class.new.resolved_resource_preference(resource)

    assert_not called, "set_current_observability must not be called during preference resolution"
  end

  test "safe_current_resource resolves controller resource when current actor is unauthenticated singleton" do
    host_class =
      Class.new(Host) do
        define_method(:current_resource) do
          :resolved_resource
        end

        public :safe_current_resource
      end

    Current.actor = Unauthenticated.instance

    assert_equal :resolved_resource, host_class.new.safe_current_resource
  end

  test "safe_current_resource keeps existing authenticated actor" do
    host_class =
      Class.new(Host) do
        define_method(:current_resource) do
          :resolved_resource
        end

        public :safe_current_resource
      end

    user = users(:one)
    Current.actor = user
    Current.actor_type = :user

    assert_equal user, host_class.new.safe_current_resource
  end

  test "resolved_current_token prefers access_token_payload hash" do
    host_class =
      Class.new(Host) do
        define_method(:access_token_payload) { { "sid" => "from-access" } }
        define_method(:load_access_token_payload) { { "sid" => "from-loader" } }
      end

    assert_equal({ "sid" => "from-access" }, host_class.new.resolved_current_token)
  end

  test "resolved_current_token uses load_access_token_payload when access_token_payload is nil" do
    host_class =
      Class.new(Host) do
        define_method(:access_token_payload) { nil }
        define_method(:load_access_token_payload) { { "sid" => "from-loader" } }
      end

    assert_equal({ "sid" => "from-loader" }, host_class.new.resolved_current_token)
  end

  test "resolved_current_token ignores non hash payloads" do
    host_class =
      Class.new(Host) do
        define_method(:access_token_payload) { "not-a-hash" }
        define_method(:load_access_token_payload) { nil }
      end

    assert_nil host_class.new.resolved_current_token
  end

  test "resolved_current_token returns nil when payload resolution raises" do
    host_class =
      Class.new(Host) do
        define_method(:access_token_payload) { raise RuntimeError, "boom" }
      end

    assert_nil host_class.new.resolved_current_token
  end

  test "resolved_current_actor_type detects staff resource" do
    assert_equal :staff, @host.resolved_current_actor_type(staffs(:one))
  end

  test "resolved_current_actor_type detects customer resource" do
    assert_equal :customer, @host.resolved_current_actor_type(customers(:one))
  end

  test "resolved_current_actor_type detects user resource" do
    assert_equal :user, @host.resolved_current_actor_type(users(:one))
  end

  test "resolved_current_actor_type returns unauthenticated for nil resource" do
    assert_equal :unauthenticated, @host.resolved_current_actor_type(nil)
  end

  test "resolved_current_actor_type preserves already assigned Current actor type" do
    Current.actor_type = :staff

    assert_equal :staff, @host.resolved_current_actor_type(users(:one))
  end

  test "resolved_current_preference uses DB-backed preference before JWT fallback" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)
    preference = UserPreference.create!(
      user: user,
      language: "en",
      region: "us",
      timezone: "Etc/UTC",
      theme: "dr",
      consented: true,
      functional: true,
      performant: true,
      targetable: false,
      consent_version: SecureRandom.uuid,
      consented_at: Time.current,
    )

    resolved = @host.resolved_current_preference(user)

    assert_equal preference.language, resolved.language
    assert_equal preference.region, resolved.region
    assert_equal preference.timezone, resolved.timezone
    assert_equal preference.theme, resolved.theme
    assert_predicate resolved.cookie, :consented?
    assert_predicate resolved.cookie, :performant?
  end

  test "resolved_current_preference falls back to JWT claim with cookie payload" do
    host_class =
      Class.new(Host) do
        define_method(:access_token_payload) do
          { "prf" => { "lx" => "en", "ri" => "us", "tz" => "Etc/UTC", "ct" => "li" } }
        end

        define_method(:preference_payload_preferences) do
          { "consented" => true, "functional" => false, "performant" => true, "targetable" => false }
        end
      end

    resolved = host_class.new.resolved_current_preference(nil)

    assert_equal "en", resolved.language
    assert_equal "us", resolved.region
    assert_equal "Etc/UTC", resolved.timezone
    assert_equal "li", resolved.theme
    assert_predicate resolved.cookie, :consented?
    assert_predicate resolved.cookie, :performant?
    assert_not resolved.cookie.functional?
  end

  test "resolved_current_preference returns null preference with safe defaults when no sources exist" do
    resolved = @host.resolved_current_preference(nil)

    assert_predicate resolved, :null?
    assert_equal "ja", resolved.language
    assert_equal "jp", resolved.region
    assert_equal "Asia/Tokyo", resolved.timezone
    assert_equal "sy", resolved.theme
    assert_not resolved.cookie.consented?
  end

  private

  # Temporarily define a top-level constant for the duration of the block.
  def stub_const(name, value)
    existed = Object.const_defined?(name)
    old_value = existed ? resolve_const(name) : nil
    Object.const_set(name, value)
    yield
  ensure
    if existed
      Object.send(:remove_const, name)
      Object.const_set(name, old_value)
    else
      Object.send(:remove_const, name)
    end
  end

  def resolve_const(name)
    case name
    when :OpenTelemetry then OpenTelemetry
    end
  end
end
