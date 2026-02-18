# frozen_string_literal: true

require "test_helper"

class OutageServiceTest < ActiveSupport::TestCase
  SURFACE = "app"

  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @original_cache
  end

  test "raises error for invalid state" do
    error =
      assert_raises(OutageService::OutageError) do
        OutageService.update!(surface: SURFACE, state: "invalid", actor_id: 1, reason: "test")
      end
    assert_includes error.message, "Invalid state"
  end

  test "update! sets outage state" do
    result = OutageService.update!(
      surface: SURFACE,
      state: "maintenance",
      actor_id: 1,
      reason: "scheduled maintenance",
    )

    assert_equal "maintenance", result[:state]
    assert_equal 1, result[:actor_id]
    assert_equal "scheduled maintenance", result[:reason]
    assert_not_nil result[:started_at]
    assert_not_nil result[:expires_at]
  end

  test "state returns current state" do
    OutageService.update!(surface: SURFACE, state: "degraded", actor_id: 1, reason: "test")

    assert_equal "degraded", OutageService.state(SURFACE)
  end

  test "state returns operational when no outage" do
    assert_equal "operational", OutageService.state(SURFACE)
  end

  test "active? returns true for non-operational state" do
    OutageService.update!(surface: SURFACE, state: "maintenance", actor_id: 1, reason: "test")

    assert OutageService.active?(SURFACE)
  end

  test "active? returns false for operational state" do
    assert_not OutageService.active?(SURFACE)
  end

  test "maintenance? returns true for maintenance state" do
    OutageService.update!(surface: SURFACE, state: "maintenance", actor_id: 1, reason: "test")

    assert OutageService.maintenance?(SURFACE)
  end

  test "degraded? returns true for degraded state" do
    OutageService.update!(surface: SURFACE, state: "degraded", actor_id: 1, reason: "test")

    assert OutageService.degraded?(SURFACE)
  end

  test "operational? returns true when no outage" do
    assert OutageService.operational?(SURFACE)
  end

  test "allowed_during_outage? returns true for health paths" do
    assert OutageService.allowed_during_outage?("/up")
    assert OutageService.allowed_during_outage?("/health")
    assert OutageService.allowed_during_outage?("/edge/v1/health")
  end

  test "allowed_during_outage? returns false for other paths" do
    assert_not OutageService.allowed_during_outage?("/api/users")
    assert_not OutageService.allowed_during_outage?("/dashboard")
  end

  test "clear! removes outage state" do
    OutageService.update!(surface: SURFACE, state: "maintenance", actor_id: 1, reason: "test")

    OutageService.clear!(SURFACE, actor_id: 1, reason: "resolved")

    assert_equal "operational", OutageService.state(SURFACE)
  end

  test "current returns outage data" do
    OutageService.update!(surface: SURFACE, state: "maintenance", actor_id: 1, reason: "test")

    current = OutageService.current(SURFACE)

    assert_instance_of Hash, current
    assert_equal "maintenance", current[:state]
    assert_equal 1, current[:actor_id]
  end

  test "current returns nil when no outage" do
    assert_nil OutageService.current(SURFACE)
  end

  # ---------------------------------------------------------------------------
  # Custom duration
  # ---------------------------------------------------------------------------

  test "update! with custom duration sets expires_at accordingly" do
    before = Time.current
    result = OutageService.update!(
      surface: SURFACE,
      state: "maintenance",
      actor_id: 1,
      reason: "test",
      duration: 300, # 5 minutes in seconds
    )

    assert result[:expires_at] > before + 290.seconds
    assert result[:expires_at] < before + 310.seconds
  end

  # ---------------------------------------------------------------------------
  # Multi-surface independence
  # ---------------------------------------------------------------------------

  test "different surfaces are independent" do
    OutageService.update!(surface: "app", state: "maintenance", actor_id: 1, reason: "app down")
    OutageService.update!(surface: "org", state: "degraded", actor_id: 1, reason: "org slow")

    assert_equal "maintenance", OutageService.state("app")
    assert_equal "degraded",    OutageService.state("org")
    assert_equal "operational", OutageService.state("com")
  end

  test "clearing one surface does not affect another" do
    OutageService.update!(surface: "app", state: "maintenance", actor_id: 1, reason: "test")
    OutageService.update!(surface: "org", state: "maintenance", actor_id: 1, reason: "test")

    OutageService.clear!("app", actor_id: 1, reason: "resolved")

    assert_equal "operational", OutageService.state("app")
    assert_equal "maintenance", OutageService.state("org")
  end

  # ---------------------------------------------------------------------------
  # clear! return value
  # ---------------------------------------------------------------------------

  test "clear! returns true" do
    OutageService.update!(surface: SURFACE, state: "maintenance", actor_id: 1, reason: "test")
    result = OutageService.clear!(SURFACE, actor_id: 1, reason: "resolved")
    assert_equal true, result
  end

  test "clear! returns true even when no outage is active" do
    result = OutageService.clear!(SURFACE, actor_id: 1, reason: "noop")
    assert_equal true, result
  end

  # ---------------------------------------------------------------------------
  # private_class_method guards
  # ---------------------------------------------------------------------------

  test "outage_cache_key is not publicly callable" do
    assert_raises(NoMethodError) { OutageService.outage_cache_key("app") }
  end

  test "record_audit is not publicly callable" do
    assert_raises(NoMethodError) { OutageService.record_audit("app", {}) }
  end

  # ---------------------------------------------------------------------------
  # allowed_during_outage? sub-path matching
  # ---------------------------------------------------------------------------

  test "allowed_during_outage? matches sub-paths of allowed routes" do
    assert OutageService.allowed_during_outage?("/health/details")
    assert OutageService.allowed_during_outage?("/up/check")
  end
end
