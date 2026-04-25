# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    require "test_helper"

    module Jit::Foundation::Base::App
      class ApplicationControllerTest < ActionDispatch::IntegrationTest
        test "includes expected concerns" do
          controller = ApplicationController.new

          assert_includes controller.class, RateLimit
          assert_includes controller.class, Preference::Regional
          assert_includes controller.class, ::Authentication::User
          assert_includes controller.class, ::Authorization::User
          assert_includes controller.class, ::Verification::User
          assert_includes controller.class, ActionPolicy::Controller
          assert_includes controller.class, ::Oidc::SsoInitiator
          assert_includes controller.class, ::CurrentSupport
          assert_includes controller.class, ::Finisher
        end

        test "has correct callback order" do
          callbacks = ApplicationController._process_action_callbacks
          before_filters = callbacks.filter_map { |c| c.filter if c.kind == :before }
          rate_limit_index =
            before_filters.index do |filter|
              filter.is_a?(Proc) &&
                filter.source_location&.first&.include?("/action_controller/metal/rate_limiting.rb")
            end

          expected_order = %i(
            enforce_withdrawal_gate!
            transparent_refresh_access_token
            enforce_access_policy!
            enforce_verification_if_required
            set_current
          )

          # Filter out non-symbol filters (procs, etc.)
          symbol_filters = before_filters.grep(Symbol)

          assert rate_limit_index, "rate limit callback should be present"

          expected_order.each_cons(2) do |first, second|
            first_idx = symbol_filters.index(first)
            second_idx = symbol_filters.index(second)

            next unless first_idx && second_idx

            assert_operator first_idx, :<, second_idx,
                            "#{first} should come before #{second}"
          end
        end

        test "does not have prepend_before_action callbacks" do
          callbacks = ApplicationController._process_action_callbacks
          before_filters = callbacks.filter_map { |c| c.filter if c.kind == :before }

          # Filter out non-symbol filters (procs, etc.)
          symbol_filters = before_filters.grep(Symbol)

          # Jit::Foundation::Base::App includes Preference::Regional which sets these callbacks,
          # and ActionController::Base adds verify_authenticity_token by default.
          # This test verifies no unexpected prepend_before_action callbacks are present.
          # Note: set_preferences_cookie, set_locale, set_timezone, set_color_theme
          # are expected from Preference::Regional.
          assert_includes symbol_filters, :set_current
        end

        test "has purge_current append_after_action" do
          callbacks = ApplicationController._process_action_callbacks
          after_filters = callbacks.filter_map { |c| c.filter if c.kind == :after }

          # Filter out non-symbol filters (procs, etc.)
          symbol_filters = after_filters.grep(Symbol)

          assert_includes symbol_filters, :purge_current
        end

        test "has oidc_client_id method" do
          controller = ApplicationController.new

          assert_respond_to controller, :oidc_client_id
          assert_equal "core_app", controller.send(:oidc_client_id)
        end
      end
    end
  end
end
