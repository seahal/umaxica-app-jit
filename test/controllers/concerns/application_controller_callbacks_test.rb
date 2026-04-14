# typed: false
# frozen_string_literal: true

require "test_helper"

module Concerns
  class ApplicationControllerCallbacksTest < ActiveSupport::TestCase
    test "dummy test to satisfy Minitest/NoTestCases" do
      assert_kind_of Array, DOMAINS
    end
    def get_callbacks_for(controller_class)
      controller_class._process_action_callbacks
    end

    def extract_before_actions(callbacks)
      callbacks.select { |c| c.kind == :before }.map(&:filter)
    end

    def rate_limit_callback_index(before_actions)
      before_actions.index do |filter|
        filter.is_a?(Proc) &&
          filter.source_location&.first&.include?("/action_controller/metal/rate_limiting.rb")
      end
    end

    def extract_prepend_before_actions(callbacks)
      callbacks.select { |c| c.kind == :before && c.options[:prepend] }.map(&:filter)
    end

    def extract_after_actions(callbacks)
      callbacks.select { |c| c.kind == :after }.map(&:filter)
    end

    DOMAINS = %w(
      Sign::App
      Sign::Com
      Sign::Org
      Core::App
      Core::Com
      Core::Org
      Apex::App
      Apex::Com
      Apex::Org
      Docs::App
      Docs::Com
      Docs::Org
    ).freeze

    CONTROLLER_CLASSES = {
      "Sign::App" => Sign::App::ApplicationController,
      "Sign::Com" => Sign::Com::ApplicationController,
      "Sign::Org" => Sign::Org::ApplicationController,
      "Core::App" => Core::App::ApplicationController,
      "Core::Com" => Core::Com::ApplicationController,
      "Core::Org" => Core::Org::ApplicationController,
      "Apex::App" => Apex::App::ApplicationController,
      "Apex::Com" => Apex::Com::ApplicationController,
      "Apex::Org" => Apex::Org::ApplicationController,
      "Docs::App" => Docs::App::ApplicationController,
      "Docs::Com" => Docs::Com::ApplicationController,
      "Docs::Org" => Docs::Org::ApplicationController,
    }.freeze

    DOMAINS.each do |domain|
      controller_class = CONTROLLER_CLASSES[domain]

      next unless controller_class

      test_method_name = "test_#{domain.underscore.gsub("/", "_")}_has_required_callbacks"

      define_method(test_method_name) do
        callbacks = get_callbacks_for(controller_class)
        before_actions = extract_before_actions(callbacks)
        after_actions = extract_after_actions(callbacks)
        rate_limit_index = rate_limit_callback_index(before_actions)

        assert rate_limit_index,
               "#{domain} should have a rate limit callback"

        validate_flash_boundary_index = before_actions.index(:validate_flash_boundary)

        assert validate_flash_boundary_index,
               "#{domain} should have validate_flash_boundary callback"

        assert_operator rate_limit_index, :<, validate_flash_boundary_index,
                        "#{domain}: rate limit should come before validate_flash_boundary"

        assert_includes before_actions, :enforce_access_policy!,
                        "#{domain} should have enforce_access_policy! callback"

        assert_includes before_actions, :enforce_verification_if_required,
                        "#{domain} should have enforce_verification_if_required callback"

        assert_includes before_actions, :set_current,
                        "#{domain} should have set_current callback"

        assert_includes after_actions, :purge_current,
                        "#{domain} should have purge_current callback"
      end

      rate_limit_method = "test_#{domain.underscore.gsub("/", "_")}_rate_limit_callback"
      define_method(rate_limit_method) do
        callbacks = get_callbacks_for(controller_class)
        before_actions = extract_before_actions(callbacks)

        rate_limit_index = rate_limit_callback_index(before_actions)

        assert rate_limit_index,
               "#{domain} should have a rate limit callback"

        validate_flash_boundary_index = before_actions.index(:validate_flash_boundary)

        assert validate_flash_boundary_index,
               "#{domain} should have validate_flash_boundary callback"

        access_policy_index = before_actions.index(:enforce_access_policy!)

        return unless access_policy_index

        assert_operator rate_limit_index, :<, validate_flash_boundary_index,
                        "#{domain}: rate limit should come before validate_flash_boundary"
        assert_operator validate_flash_boundary_index, :<, access_policy_index,
                        "#{domain}: validate_flash_boundary should come before enforce_access_policy!"
      end

      auth_method = "test_#{domain.underscore.gsub("/", "_")}_auth_callback_order"
      define_method(auth_method) do
        callbacks = get_callbacks_for(controller_class)
        before_actions = extract_before_actions(callbacks)

        verification_index = before_actions.index(:enforce_verification_if_required)
        current_index = before_actions.index(:set_current)

        skip "Callbacks not found" unless verification_index && current_index

        assert_operator verification_index, :<, current_index,
                        "#{domain}: enforce_verification_if_required should come before set_current"
      end
    end
  end
end
