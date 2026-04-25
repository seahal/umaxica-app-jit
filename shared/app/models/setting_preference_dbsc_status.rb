# typed: false
# == Schema Information
#
# Table name: settings_preference_dbsc_statuses
# Database name: setting
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class SettingPreferenceDbscStatus < SettingRecord
  self.table_name = "settings_preference_dbsc_statuses"
  # Fixed IDs - do not modify these values
  NOTHING = 0
  ACTIVE = 1
  PENDING = 2
  FAILED = 3
  REVOKE = 4
  DEFAULTS = [NOTHING, ACTIVE, PENDING, FAILED, REVOKE].freeze

  has_many :setting_preferences,
           foreign_key: :dbsc_status_id,
           inverse_of: :setting_preference_dbsc_status,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
