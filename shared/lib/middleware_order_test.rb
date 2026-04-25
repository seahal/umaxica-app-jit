# typed: false
# frozen_string_literal: true

require "test_helper"

# Verify middleware/include/execution order for all ApplicationControllers
class MiddlewareOrderTest < ActiveSupport::TestCase
  CONTROLLERS = %w(
    Sign::App::ApplicationController
    Sign::Org::ApplicationController
    Base::App::ApplicationController
    Base::Org::ApplicationController
    Base::Com::ApplicationController
    Acme::App::ApplicationController
    Acme::Org::ApplicationController
    Acme::Com::ApplicationController
    Post::App::ApplicationController
    Post::Org::ApplicationController
    Post::Com::ApplicationController
  ).freeze

  CONTROLLER_CLASSES = {
    "Sign::App::ApplicationController" => Sign::App::ApplicationController,
    "Sign::Org::ApplicationController" => Sign::Org::ApplicationController,
    "Base::App::ApplicationController" => Base::App::ApplicationController,
    "Base::Org::ApplicationController" => Base::Org::ApplicationController,
    "Base::Com::ApplicationController" => Base::Com::ApplicationController,
    "Acme::App::ApplicationController" => Acme::App::ApplicationController,
    "Acme::Org::ApplicationController" => Acme::Org::ApplicationController,
    "Acme::Com::ApplicationController" => Acme::Com::ApplicationController,
    "Post::App::ApplicationController" => Post::App::ApplicationController,
    "Post::Org::ApplicationController" => Post::Org::ApplicationController,
    "Post::Com::ApplicationController" => Post::Com::ApplicationController,
  }.freeze

  DOMAIN_CONTROLLERS = {
    "Sign" => { "App" => Sign::App::ApplicationController,
                "Org" => Sign::Org::ApplicationController,
                "Com" => Sign::Com::ApplicationController, },
    "Core" => { "App" => Base::App::ApplicationController,
                "Org" => Base::Org::ApplicationController,
                "Com" => Base::Com::ApplicationController, },
    "Acme" => { "App" => Acme::App::ApplicationController,
                "Org" => Acme::Org::ApplicationController,
                "Com" => Acme::Com::ApplicationController, },
    "Docs" => { "App" => Post::App::ApplicationController,
                "Org" => Post::Org::ApplicationController,
                "Com" => Post::Com::ApplicationController, },
  }.freeze

  # expected include order (layer order)
  EXPECTED_INCLUDES = %w(
    RateLimit
    Authentication
    Authorization
    Verification
    Preference
    ActionPolicy::Controller
    Oidc::SsoInitiator
    CurrentSupport
    Finisher
  ).freeze

  # Expected before_action order (security layer order)
  EXPECTED_LAYER_ORDER = %w(
    RateLimit
    Preference
    AuthN
    AuthZ
    StepUp
    Finisher
  ).freeze

  # Actual callback names and their expected layer mappings
  CALLBACK_TO_LAYER = {
    set_preferences_cookie: "Preference",
    enforce_withdrawal_gate!: "AuthN",
    transparent_refresh_access_token: "AuthN",
    enforce_access_policy!: "AuthZ",
    enforce_verification_if_required: "StepUp",
    resolve_param_context: "Preference",
    set_region: "Preference",
    set_locale: "Preference",
    set_timezone: "Preference",
    set_color_theme: "Preference",
    set_current: "CurrentSupport",
    enforce_restricted_session_guard!: "AuthN",
    canonicalize_regional_params: "Preference",
    finish_request: "Finisher",
  }.freeze

  CONTROLLERS.each do |controller_class|
    test "#{controller_class} exists and inherits correctly" do
      klass = CONTROLLER_CLASSES[controller_class]

      assert_operator klass, :<, ActionController::Base
    end

    test "#{controller_class} has before callbacks in correct order" do
      klass = CONTROLLER_CLASSES[controller_class]
      callbacks = klass._process_action_callbacks
      before_filters = callbacks.select { |callback| callback.kind == :before }.map(&:filter)

      # Verify security layer order
      layer_sequence = before_filters.filter_map { |f| CALLBACK_TO_LAYER[f] }

      # Verify layers execute in expected order
      EXPECTED_LAYER_ORDER.each_cons(2) do |first_layer, second_layer|
        first_idx = layer_sequence.index(first_layer)
        second_idx = layer_sequence.index(second_layer)

        if first_idx && second_idx
          assert_operator first_idx, :<, second_idx,
                          "#{controller_class}: #{first_layer} should come before #{second_layer}"
        end
      end
    end
  end

  test "all controllers have required includes" do
    CONTROLLERS.each do |controller_class|
      klass = CONTROLLER_CLASSES[controller_class]

      ancestor_names = klass.ancestors.map(&:to_s)

      assert ancestor_names.any? { |name| name.include?("RateLimit") },
             "#{controller_class} should include RateLimit"
      assert ancestor_names.any? { |name| name.include?("Authentication") },
             "#{controller_class} should include Authentication"
      assert ancestor_names.any? { |name| name.include?("CurrentSupport") },
             "#{controller_class} should include CurrentSupport"
      assert ancestor_names.any? { |name| name.include?("Finisher") },
             "#{controller_class} should include Finisher"
    end
  end

  test "callback order is consistent across all app/org/com controllers" do
    DOMAIN_CONTROLLERS.each do |domain, controllers|
      app_controller = controllers["App"]
      org_controller = controllers["Org"]
      com_controller = controllers["Com"]

      next unless app_controller && org_controller

      app_callbacks = app_controller._process_action_callbacks.select { |c| c.kind == :before }.map(&:filter)
      org_callbacks = org_controller._process_action_callbacks.select { |c| c.kind == :before }.map(&:filter)

      # Verify Auth callback order matches
      auth_callbacks = %w(
        enforce_withdrawal_gate!
        transparent_refresh_access_token
        enforce_access_policy!
        enforce_verification_if_required
      )

      auth_callbacks.each_cons(2) do |first, second|
        app_first_idx = app_callbacks.index(first.to_sym)
        app_second_idx = app_callbacks.index(second.to_sym)
        org_first_idx = org_callbacks.index(first.to_sym)
        org_second_idx = org_callbacks.index(second.to_sym)

        # Verify only if callbacks exist in both controllers
        if app_first_idx && app_second_idx && org_first_idx && org_second_idx
          app_order = app_first_idx < app_second_idx
          org_order = org_first_idx < org_second_idx

          assert_equal app_order, org_order,
                       "#{domain}: #{first} -> #{second} order differs between app and org"
        end
      end

      # Also verify com_controller similarly
      if com_controller
        com_callbacks = com_controller._process_action_callbacks.select { |c| c.kind == :before }.map(&:filter)

        auth_callbacks.each_cons(2) do |first, second|
          app_first_idx = app_callbacks.index(first.to_sym)
          app_second_idx = app_callbacks.index(second.to_sym)
          com_first_idx = com_callbacks.index(first.to_sym)
          com_second_idx = com_callbacks.index(second.to_sym)

          if app_first_idx && app_second_idx && com_first_idx && com_second_idx
            app_order = app_first_idx < app_second_idx
            com_order = com_first_idx < com_second_idx

            assert_equal app_order, com_order,
                         "#{domain}: #{first} -> #{second} order differs between app and com"
          end
        end
      end
    end
  end
end
