# typed: false
# frozen_string_literal: true

require "test_helper"

module Concerns
  class ApplicationControllerCallbacksTest < ActiveSupport::TestCase
    def get_callbacks_for(controller_class)
      controller_class._process_action_callbacks
    end

    def extract_before_actions(callbacks)
      callbacks.select { |c| c.kind == :before }.map(&:filter)
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
      News::App
      News::Com
      News::Org
      Help::App
      Help::Com
      Help::Org
    ).freeze

    DOMAINS.each do |domain|
      controller_class_name = "#{domain}::ApplicationController"
      controller_class = controller_class_name.safe_constantize

      next unless controller_class

      test_method_name = "test_#{domain.underscore.gsub("/", "_")}_has_required_callbacks"

      define_method(test_method_name) do
        callbacks = get_callbacks_for(controller_class)
        before_actions = extract_before_actions(callbacks)
        after_actions = extract_after_actions(callbacks)

        assert_includes before_actions, :check_default_rate_limit,
                        "#{domain} should have check_default_rate_limit callback"

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

        rate_limit_index = before_actions.index(:check_default_rate_limit)

        assert rate_limit_index,
               "#{domain} should have check_default_rate_limit callback"

        access_policy_index = before_actions.index(:enforce_access_policy!)

        return unless access_policy_index

        assert_operator rate_limit_index, :<, access_policy_index,
                        "#{domain}: check_default_rate_limit should come before enforce_access_policy!"
      end

      auth_method = "test_#{domain.underscore.gsub("/", "_")}_auth_callback_order"
      define_method(auth_method) do
        callbacks = get_callbacks_for(controller_class)
        before_actions = extract_before_actions(callbacks)

        verification_index = before_actions.index(:enforce_verification_if_required)
        current_index = before_actions.index(:set_current)

        return unless verification_index && current_index

        assert_operator verification_index, :<, current_index,
                        "#{domain}: enforce_verification_if_required should come before set_current"
      end
    end
  end
end
