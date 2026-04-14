# typed: false
# frozen_string_literal: true

# Map settings_preference_* fixture table names to their correct AR model classes.
#
# Rails infers the class from the fixture filename via `table_name.classify`, which
# singularizes before camelizing. That turns "settings_preference_statuses" into
# "SettingPreferenceStatus" (plural "Settings") -- not the actual class name
# "SettingPreferenceStatus". Without this mapping, fixture loading falls back to
# the primary DB connection and the tables are not found.
class ActiveSupport::TestCase
  self.fixture_class_names = fixture_class_names.merge(
    "settings_preference_statuses" => "SettingPreferenceStatus",
    "settings_preference_binding_methods" => "SettingPreferenceBindingMethod",
    "settings_preference_dbsc_statuses" => "SettingPreferenceDbscStatus",
    "settings_preference_language_options" => "SettingPreferenceLanguageOption",
    "settings_preference_region_options" => "SettingPreferenceRegionOption",
    "settings_preference_timezone_options" => "SettingPreferenceTimezoneOption",
    "settings_preference_colortheme_options" => "SettingPreferenceColorthemeOption",
  )
end
