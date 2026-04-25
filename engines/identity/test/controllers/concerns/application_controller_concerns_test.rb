# typed: false
# frozen_string_literal: true

require "test_helper"

module Concerns
  class ApplicationControllerConcernsTest < ActiveSupport::TestCase
    test "dummy test to satisfy Minitest/NoTestCases" do
      assert_kind_of Hash, CONCERNS_BY_DOMAIN
    end
    CONTROLLER_CLASSES = {
      "Jit::Identity::Sign::App" => Jit::Identity::Sign::App::ApplicationController,
      "Jit::Identity::Sign::Com" => Jit::Identity::Sign::Com::ApplicationController,
      "Jit::Identity::Sign::Org" => Jit::Identity::Sign::Org::ApplicationController,
      "Jit::Foundation::Base::App" => Jit::Foundation::Base::App::ApplicationController,
      "Jit::Foundation::Base::Com" => Jit::Foundation::Base::Com::ApplicationController,
      "Jit::Foundation::Base::Org" => Jit::Foundation::Base::Org::ApplicationController,
      "Jit::Zenith::Acme::App" => Jit::Zenith::Acme::App::ApplicationController,
      "Jit::Zenith::Acme::Com" => Jit::Zenith::Acme::Com::ApplicationController,
      "Jit::Zenith::Acme::Org" => Jit::Zenith::Acme::Org::ApplicationController,
      "Jit::Distributor::Post::App" => Jit::Distributor::Post::App::ApplicationController,
      "Jit::Distributor::Post::Com" => Jit::Distributor::Post::Com::ApplicationController,
      "Jit::Distributor::Post::Org" => Jit::Distributor::Post::Org::ApplicationController,
    }.freeze

    PARENT_CLASSES = {
      "Jit::Identity::Sign::Org" => Jit::Identity::Sign::App::ApplicationController,
      "Jit::Foundation::Base::Com" => Jit::Foundation::Base::App::ApplicationController,
      "Jit::Foundation::Base::Org" => Jit::Foundation::Base::App::ApplicationController,
      "Jit::Zenith::Acme::Com" => Jit::Zenith::Acme::App::ApplicationController,
      "Jit::Zenith::Acme::Org" => Jit::Zenith::Acme::App::ApplicationController,
      "Jit::Distributor::Post::Com" => Jit::Distributor::Post::App::ApplicationController,
      "Jit::Distributor::Post::Org" => Jit::Distributor::Post::App::ApplicationController,
    }.freeze

    CONCERNS_BY_DOMAIN = {
      "Jit::Identity::Sign::App" => {
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
      "Jit::Identity::Sign::Com" => {
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
          Jit::Identity::Sign::Com::RouteAliasHelper,
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
      "Jit::Identity::Sign::Org" => {
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
      "Jit::Foundation::Base::App" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Regional,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          ActionPolicy::Controller,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          enforce_withdrawal_gate!
          transparent_refresh_access_token
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: [],
      },
      "Jit::Foundation::Base::Com" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Regional,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          ActionPolicy::Controller,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          transparent_refresh_access_token
          enforce_access_policy!
          enforce_verification_if_required
          set_current
          enforce_withdrawal_gate!
        ),
        prepend_before_actions: [],
      },
      "Jit::Foundation::Base::Org" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Regional,
          ::Authentication::Staff,
          ::Authorization::Staff,
          ::Verification::Staff,
          ActionPolicy::Controller,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: [],
      },
      "Jit::Zenith::Acme::App" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Global,
          ::Preference::Adoption,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          ActionPolicy::Controller,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          enforce_withdrawal_gate!
          transparent_refresh_access_token
          enforce_access_policy!
          enforce_verification_if_required
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
      "Jit::Zenith::Acme::Com" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Global,
          ::Authentication::Customer,
          ::Authorization::Customer,
          ::Verification::Customer,
          ActionPolicy::Controller,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          enforce_withdrawal_gate!
          transparent_refresh_access_token
          enforce_access_policy!
          enforce_verification_if_required
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
      "Jit::Zenith::Acme::Org" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Global,
          ::Preference::Adoption,
          ::Authentication::Staff,
          ::Authorization::Staff,
          ::Verification::Staff,
          ActionPolicy::Controller,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          transparent_refresh_access_token
          enforce_access_policy!
          enforce_verification_if_required
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
      "Jit::Distributor::Post::App" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Regional,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          ActionPolicy::Controller,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          transparent_refresh_access_token
          enforce_access_policy!
          enforce_verification_if_required
          set_current
          enforce_withdrawal_gate!
        ),
        prepend_before_actions: [],
      },
      "Jit::Distributor::Post::Com" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Regional,
          ::Authentication::Viewer,
          ::Authorization::Viewer,
          ::Verification::Viewer,
          ActionPolicy::Controller,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: [],
      },
      "Jit::Distributor::Post::Org" => {
        includes: [
          ::RateLimit,
          ::Session,
          ::Preference::Regional,
          ::Authentication::Staff,
          ::Authorization::Staff,
          ::Verification::Staff,
          ActionPolicy::Controller,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          rate_limit
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: [],
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
