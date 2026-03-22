# frozen_string_literal: true

class ValidatePreferenceBindingMethodsAndDbscStatusesForeignKeys < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(
      :app_preferences, :app_preference_binding_methods,
      name: "fk_app_preferences_on_binding_method_id",
    )
    validate_foreign_key(:app_preferences, :app_preference_dbsc_statuses, name: "fk_app_preferences_on_dbsc_status_id")
    validate_foreign_key(
      :org_preferences, :org_preference_binding_methods,
      name: "fk_org_preferences_on_binding_method_id",
    )
    validate_foreign_key(:org_preferences, :org_preference_dbsc_statuses, name: "fk_org_preferences_on_dbsc_status_id")
    validate_foreign_key(
      :com_preferences, :com_preference_binding_methods,
      name: "fk_com_preferences_on_binding_method_id",
    )
    validate_foreign_key(:com_preferences, :com_preference_dbsc_statuses, name: "fk_com_preferences_on_dbsc_status_id")
  end
end
