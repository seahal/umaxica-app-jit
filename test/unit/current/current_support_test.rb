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
    public :set_current_observability, :resolved_resource_preference
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
    Current.actor = "existing_actor"
    Current.domain = :app

    @host.set_current_observability

    assert_equal "existing_actor", Current.actor
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

  private

  # Temporarily define a top-level constant for the duration of the block.
  def stub_const(name, value)
    existed = Object.const_defined?(name)
    old_value = Object.const_get(name) if existed
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
end
