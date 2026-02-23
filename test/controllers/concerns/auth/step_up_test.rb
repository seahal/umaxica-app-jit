# typed: false
# frozen_string_literal: true

require "test_helper"

class TestAuthStepUpController < ApplicationController
  include Auth::StepUp
end

module Auth
  class StepUpTest < ActiveSupport::TestCase
    test "StepUp is a module" do
      assert_kind_of Module, StepUp
    end

    test "StepUp includes Verification::Base" do
      assert_includes TestAuthStepUpController.ancestors, Verification::Base
    end

    test "StepUp includes Common::Redirect via Verification::Base" do
      assert_includes TestAuthStepUpController.ancestors, Common::Redirect
    end

    test "controller has step_up methods from Verification::Base" do
      controller = TestAuthStepUpController.new

      assert_respond_to controller, :require_step_up!
      assert_respond_to controller, :step_up_satisfied?
      assert_respond_to controller, :require_verification!
      assert_respond_to controller, :verification_required?
      assert_respond_to controller, :verification_satisfied?
    end

    test "STEP_UP_TTL is 15 minutes" do
      assert_equal 15.minutes, Verification::Base::STEP_UP_TTL
    end

    test "STEP_UP_REQUIRED_MESSAGE is defined" do
      assert_kind_of String, Verification::Base::STEP_UP_REQUIRED_MESSAGE
    end
  end
end
