# typed: false
# frozen_string_literal: true

require "test_helper"

module Concerns
  class ApplicationControllerConcernsTest < ActiveSupport::TestCase
    CONCERNS_BY_DOMAIN = {
      "Sign::App" => {
        includes: [
          ::RateLimit,
          ::Preference::Global,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          Pundit::Authorization,
          ::RestrictedSessionGuard,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
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
        parent: "Sign::App",
        includes: [],
        extra_includes: [
          Sign::Com::RouteAliasHelper,
        ],
        extra_before_actions: [
          :enforce_required_telephone_registration!,
        ],
      },
      "Sign::Org" => {
        includes: [
          ::RateLimit,
          ::Preference::Global,
          ::Authentication::Staff,
          ::Authorization::Staff,
          ::Verification::Staff,
          Pundit::Authorization,
          ::RestrictedSessionGuard,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
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
      "Core::App" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          enforce_withdrawal_gate!
          transparent_refresh_access_token
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: [],
      },
      "Core::Com" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          transparent_refresh_access_token
          enforce_access_policy!
          enforce_verification_if_required
          set_current
          enforce_withdrawal_gate!
        ),
        prepend_before_actions: [],
      },
      "Core::Org" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::Staff,
          ::Authorization::Staff,
          ::Verification::Staff,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: [],
      },
      "Apex::App" => {
        includes: [
          ::RateLimit,
          ::Preference::Global,
          ::Preference::Adoption,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
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
      "Apex::Com" => {
        includes: [
          ::RateLimit,
          ::Preference::Global,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
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
      "Apex::Org" => {
        includes: [
          ::RateLimit,
          ::Preference::Global,
          ::Preference::Adoption,
          ::Authentication::Staff,
          ::Authorization::Staff,
          ::Verification::Staff,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
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
      "Docs::App" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          transparent_refresh_access_token
          enforce_access_policy!
          enforce_verification_if_required
          set_current
          enforce_withdrawal_gate!
        ),
        prepend_before_actions: [],
      },
      "Docs::Com" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::Viewer,
          ::Authorization::Viewer,
          ::Verification::Viewer,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: [],
      },
      "Docs::Org" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::Staff,
          ::Authorization::Staff,
          ::Verification::Staff,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: [],
      },
      "News::App" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          enforce_withdrawal_gate!
          transparent_refresh_access_policy
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: %i(
          set_preferences_cookie
          canonicalize_regional_params
          set_locale
          set_timezone
          set_color_theme
        ),
      },
      "News::Com" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::Viewer,
          ::Authorization::Viewer,
          ::Verification::Viewer,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: %i(
          set_preferences_cookie
          canonicalize_regional_params
          set_locale
          set_timezone
          set_color_theme
        ),
      },
      "News::Org" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::Staff,
          ::Authorization::Staff,
          ::Verification::Staff,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: %i(
          set_preferences_cookie
          canonicalize_regional_params
          set_locale
          set_timezone
          set_color_theme
        ),
      },
      "Help::App" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::User,
          ::Authorization::User,
          ::Verification::User,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          enforce_withdrawal_gate!
          transparent_refresh_access_token
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: %i(
          set_preferences_cookie
          canonicalize_regional_params
          set_locale
          set_timezone
          set_color_theme
        ),
      },
      "Help::Com" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::Viewer,
          ::Authorization::Viewer,
          ::Verification::Viewer,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: %i(
          set_preferences_cookie
          canonicalize_regional_params
          set_locale
          set_timezone
          set_color_theme
        ),
      },
      "Help::Org" => {
        includes: [
          ::RateLimit,
          ::Preference::Regional,
          ::Authentication::Staff,
          ::Authorization::Staff,
          ::Verification::Staff,
          Pundit::Authorization,
          ::Oidc::SsoInitiator,
          ::CurrentSupport,
          ::Finisher,
        ],
        before_actions: %i(
          check_default_rate_limit
          enforce_access_policy!
          enforce_verification_if_required
          set_current
        ),
        prepend_before_actions: %i(
          set_preferences_cookie
          canonicalize_regional_params
          set_locale
          set_timezone
          set_color_theme
        ),
      },
    }.freeze

    CONCERNS_BY_DOMAIN.each do |domain, config|
      controller_class = "#{domain}::ApplicationController".safe_constantize

      next unless controller_class

      domain_test = "test_#{domain.underscore.gsub("/", "_")}_includes_expected_concerns"

      define_method(domain_test) do
        controller = controller_class.new

        if config[:parent]
          assert_equal "#{config[:parent]}::ApplicationController".safe_constantize, controller_class.superclass,
            "#{domain} should inherit from #{config[:parent]}"
        else
          expected = config[:includes] || []

          expected.each do |concern|
            assert_includes controller.class, concern, "#{domain} should include #{concern}"
          end
        end
      end

      if config[:parent]
        parent_class = "#{config[:parent]}::ApplicationController".safe_constantize
        if parent_class
          parent_test = "test_#{domain.underscore.gsub("/", "_")}_inherits_from_parent"

          define_method(parent_test) do
            assert_equal parent_class, controller_class.superclass,
                         "#{domain} should inherit from #{config[:parent]}"
          end
        end
      end
    end
  end
end
