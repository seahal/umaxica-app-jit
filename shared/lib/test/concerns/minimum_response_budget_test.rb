# typed: false
# frozen_string_literal: true

require "test_helper"

class MinimumResponseBudgetTest < ActiveSupport::TestCase
  test "enabled returns false by default" do
    controller = Class.new do
      include MinimumResponseBudget
    end.new

    assert_not controller.send(:minimum_response_budget_enabled?)
  end

  test "default budget is 150ms" do
    controller = Class.new do
      include MinimumResponseBudget
    end.new

    assert_in_delta 150.0, controller.send(:minimum_response_budget_ms)
  end

  test "default max sleep is 250ms" do
    controller = Class.new do
      include MinimumResponseBudget
    end.new

    assert_in_delta 250.0, controller.send(:minimum_response_budget_max_sleep_ms)
  end

  test "constants are defined" do
    assert_in_delta(150.0, Class.new { include MinimumResponseBudget }.new.send(:minimum_response_budget_ms))
    assert_in_delta(250.0, Class.new { include MinimumResponseBudget }.new.send(:minimum_response_budget_max_sleep_ms))
  end
end
