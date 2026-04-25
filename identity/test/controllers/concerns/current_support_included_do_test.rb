# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentSupportIncludedDoTest < ActiveSupport::TestCase
  class CallbackHost < ApplicationController
    include CurrentSupport

    before_action :set_current
    after_action :_reset_current_state
  end

  test "controller can wire set_current and _reset_current_state callbacks" do
    before_actions = CallbackHost._process_action_callbacks.select { |callback| callback.kind == :before }.map(&:filter)
    after_actions = CallbackHost._process_action_callbacks.select { |callback| callback.kind == :after }.map(&:filter)

    assert_includes before_actions, :set_current
    assert_includes after_actions, :_reset_current_state
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
