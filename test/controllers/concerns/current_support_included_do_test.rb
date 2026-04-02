# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentSupportIncludedDoTest < ActiveSupport::TestCase
  test "included do registers after_action callback" do
    skip "after_action callback verification requires integration test"
  end

  test "set_current method exists in module" do
    assert_includes CurrentSupport.private_instance_methods(false), :set_current
  end

  test "_reset_current_state method exists in module" do
    assert_includes CurrentSupport.private_instance_methods(false), :_reset_current_state
  end

  test "resolved_current_domain method exists in module" do
    assert_includes CurrentSupport.private_instance_methods(false), :resolved_current_domain
  end
end
