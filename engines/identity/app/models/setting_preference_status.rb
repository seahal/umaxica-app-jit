# typed: false
# == Schema Information
#
# Table name: settings_preference_statuses
# Database name: setting
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class SettingPreferenceStatus < SettingRecord
  self.table_name = "settings_preference_statuses"
  # Fixed IDs - do not modify these values
  NOTHING = 0
  DELETED = 1
  LEGACY_NOTHING = 2
  DEFAULTS = [NOTHING, DELETED, LEGACY_NOTHING].freeze

  has_many :setting_preferences,
           class_name: "SettingPreference",
           foreign_key: :status_id,
           primary_key: :id,
           inverse_of: :setting_preference_status,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
