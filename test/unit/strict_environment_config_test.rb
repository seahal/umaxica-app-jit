# typed: false
# frozen_string_literal: true

require "test_helper"
require "strict_environment_config"

class StrictEnvironmentConfigTest < ActiveSupport::TestCase
  test "apply! enables fail-fast settings for active support and action controller" do
    config = build_config

    StrictEnvironmentConfig.apply!(config)

    assert_equal :raise, config.active_support.deprecation
    assert config.i18n.raise_on_missing_translations
    assert config.action_controller.raise_on_missing_callback_actions
    assert_equal :raise, config.action_controller.action_on_unpermitted_parameters
    assert_equal :raise, config.action_controller.action_on_open_redirect
  end

  test "apply! enables fail-fast settings for active record" do
    config = build_config

    StrictEnvironmentConfig.apply!(config)

    assert_equal :raise, config.active_record.db_warnings_action
    assert config.active_record.strict_loading_by_default
    assert_equal :n_plus_one_only, config.active_record.strict_loading_mode
    assert_equal :raise, config.active_record.action_on_strict_loading_violation
    assert_equal :disallowed, config.active_record.permanent_connection_checkout
    assert config.active_record.error_on_ignored_order
    assert config.active_record.raise_on_assign_to_attr_readonly
  end

  test "test environment uses raise for unpermitted parameters" do
    assert_equal :raise, Rails.application.config.action_controller.action_on_unpermitted_parameters
    assert_equal :raise, ActionController::Parameters.action_on_unpermitted_parameters
  end

  test "test environment raises on ignored order" do
    assert Rails.application.config.active_record.error_on_ignored_order
  end

  test "test environment raises exceptions instead of rendering rescuable pages" do
    assert_equal :none, Rails.application.config.action_dispatch.show_exceptions
  end

  test "test environment keeps forgery protection disabled" do
    assert_not ActionController::Base.allow_forgery_protection
  end

  private

  def build_config
    OpenStruct.new(
      active_support: OpenStruct.new,
      i18n: OpenStruct.new,
      active_record: OpenStruct.new,
      action_controller: OpenStruct.new,
    )
  end
end
