# typed: false
# frozen_string_literal: true

require "test_helper"

module Concerns
  class ApplicationControllerConcernsTest < ActiveSupport::TestCase
    test "dummy test to satisfy Minitest/NoTestCases" do
      assert_kind_of Hash, CONCERNS_BY_DOMAIN
    end
    CONTROLLER_CLASSES = {
      "Sign::App" => Sign::App::ApplicationController,
      "Sign::Com" => Sign::Com::ApplicationController,
      "Sign::Org" => Sign::Org::ApplicationController,
    }.freeze

    PARENT_CLASSES = {
      "Sign::Org" => Sign::App::ApplicationController,
    }.freeze

    CONCERNS_BY_DOMAIN = {
      "Sign::App" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Global,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          ActionPolicy::Controller,
          ::RestrictedSessionGuard,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          set_preferences_cookie
          enforce_restricted_session_guard!
          resolve_param_context
          set_region
          set_locale
          set_timezone
          set_color_theme
          enforce_withdrawal_gate!
          transparent_refresh_access_token
          enforce_access_policy!
          enforce_verification_if_required
        ),
        prepend_before_actions: %i(
          set_preferences_cookie
          enforce_restricted_session_guard!
          resolve_param_context
          set_region
          set_locale
          set_timezone
          set_color_theme
        ),
      },
      "Sign::Com" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Global,
          ::Preference::Adoption,
          ::Authentication::Customer,
          ::Authorization::Customer,
          ::Verification::Customer,
          ActionPolicy::Controller,
          ::CurrentSupport,
          Sign::Com::RouteAliasHelper,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          enforce_required_telephone_registration!
          enforce_verification_if_required
          enforce_access_policy!
          set_current
        ),
        prepend_before_actions: %i(
          set_preferences_cookie
          resolve_param_context
          set_region
          set_locale
          set_timezone
          set_color_theme
        ),
      },
      "Sign::Org" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Global,
          ::Authentication::Staff,
          ::Authorization::Staff,
          ::Verification::Staff,
          ActionPolicy::Controller,
          ::RestrictedSessionGuard,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          set_preferences_cookie
          resolve_param_context
          set_region
          set_locale
          set_timezone
          set_color_theme
          enforce_restricted_session_guard!
          enforce_access_policy!
          enforce_verification_if_required
        ),
        prepend_before_actions: %i(
          set_preferences_cookie
          resolve_param_context
          set_region
          set_locale
          set_timezone
          set_color_theme
        ),
      },
    }.freeze

    CONCERNS_BY_DOMAIN.each do |domain, config|
      controller_class = CONTROLLER_CLASSES[domain]

      next unless controller_class

      domain_test = "test_#{domain.underscore.tr("/", "_")}_includes_expected_concerns"

      define_method(domain_test) do
        controller = controller_class.new

        if config[:parent]
          assert_equal PARENT_CLASSES[domain], controller_class.superclass,
                       "#{domain} should inherit from #{config[:parent]}"
        else
          expected = config[:includes] || []

          expected.each do |concern|
            assert_includes controller.class, concern, "#{domain} should include #{concern}"
          end
        end
      end

      if config[:parent]
        parent_class = PARENT_CLASSES[domain]
        if parent_class
          parent_test = "test_#{domain.underscore.tr("/", "_")}_inherits_from_parent"

          define_method(parent_test) do
            assert_equal parent_class, controller_class.superclass,
                         "#{domain} should inherit from #{config[:parent]}"
          end
        end
      end
    end
  end
end
