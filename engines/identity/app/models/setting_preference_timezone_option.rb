# typed: false
# == Schema Information
#
# Table name: settings_preference_timezone_options
# Database name: setting
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class SettingPreferenceTimezoneOption < SettingRecord
  self.table_name = "settings_preference_timezone_options"
  # Fixed IDs - do not modify these values
  NOTHING = 0
  ETC_UTC = 1
  ASIA_TOKYO = 2
  DEFAULTS = [NOTHING, ETC_UTC, ASIA_TOKYO].freeze

  has_many :setting_preference_timezones,
           class_name: "SettingPreferenceTimezone",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  self.primary_key = :id

  def name
    case id
    when ETC_UTC then "Etc/UTC"
    when ASIA_TOKYO then "Asia/Tokyo"
    end
  end

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
