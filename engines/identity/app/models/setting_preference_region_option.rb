# typed: false
# == Schema Information
#
# Table name: settings_preference_region_options
# Database name: setting
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class SettingPreferenceRegionOption < SettingRecord
  self.table_name = "settings_preference_region_options"
  # Fixed IDs - do not modify these values
  NOTHING = 0
  US = 1
  JP = 2
  DEFAULTS = [NOTHING, US, JP].freeze

  has_many :setting_preference_regions,
           class_name: "SettingPreferenceRegion",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  self.primary_key = :id

  def name
    case id
    when US then "US"
    when JP then "JP"
    end
  end

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
