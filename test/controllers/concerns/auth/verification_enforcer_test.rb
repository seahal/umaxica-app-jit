# frozen_string_literal: true

require "test_helper"

class TestAuthVerificationEnforcerController < ApplicationController
  include Auth::VerificationEnforcer
end

module Auth
  class VerificationEnforcerTest < ActiveSupport::TestCase
    test "VerificationEnforcer is a module" do
      assert_kind_of Module, VerificationEnforcer
    end

    test "VerificationEnforcer includes Verification::Base" do
      assert_includes TestAuthVerificationEnforcerController.ancestors, Verification::Base
    end

    test "VerificationEnforcer includes Common::Redirect via Verification::Base" do
      assert_includes TestAuthVerificationEnforcerController.ancestors, Common::Redirect
    end

    test "controller has verification methods from Verification::Base" do
      controller = TestAuthVerificationEnforcerController.new

      assert_respond_to controller, :require_verification!
      assert_respond_to controller, :verification_required?
      assert_respond_to controller, :verification_satisfied?
      assert_respond_to controller, :clear_verification_requirement!
      assert_respond_to controller, :require_step_up!
      assert_respond_to controller, :step_up_satisfied?
    end

    test "STEP_UP_TTL constant is accessible" do
      assert_equal 15.minutes, Verification::Base::STEP_UP_TTL
    end

    test "REAUTH_REQUIRED_MESSAGE constant is accessible" do
      assert_kind_of String, Verification::Base::REAUTH_REQUIRED_MESSAGE
    end
  end
end
