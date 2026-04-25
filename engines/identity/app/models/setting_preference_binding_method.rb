# typed: false
# == Schema Information
#
# Table name: settings_preference_binding_methods
# Database name: setting
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class SettingPreferenceBindingMethod < SettingRecord
  self.table_name = "settings_preference_binding_methods"
  # Fixed IDs - do not modify these values
  NOTHING = 0
  DBSC = 1
  LEGACY = 2
  DEFAULTS = [NOTHING, DBSC, LEGACY].freeze

  has_many :setting_preferences,
           foreign_key: :binding_method_id,
           inverse_of: :setting_preference_binding_method,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
