# typed: false
# frozen_string_literal: true

module StrictEnvironmentConfig
  module_function

  def apply!(config)
    config.active_support.deprecation = :raise
    config.i18n.raise_on_missing_translations = true

    config.active_record.db_warnings_action = :raise
    config.active_record.strict_loading_by_default = true
    config.active_record.strict_loading_mode = :n_plus_one_only
    config.active_record.action_on_strict_loading_violation = :raise
    config.active_record.permanent_connection_checkout = :disallowed
    config.active_record.error_on_ignored_order = true
    config.active_record.raise_on_assign_to_attr_readonly = true

    config.action_controller.raise_on_missing_callback_actions = true
    config.action_controller.action_on_unpermitted_parameters = :raise
    config.action_controller.action_on_open_redirect = :raise
  end
end
