# typed: false
# == Schema Information
#
# Table name: settings_preference_colortheme_options
# Database name: setting
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class SettingPreferenceColorthemeOption < SettingRecord
  self.table_name = "settings_preference_colortheme_options"
  # Fixed IDs - do not modify these values
  NOTHING = 0
  LIGHT = 1
  DARK = 2
  SYSTEM = 3
  DEFAULTS = [NOTHING, LIGHT, DARK, SYSTEM].freeze

  has_many :setting_preference_colorthemes,
           class_name: "SettingPreferenceColortheme",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  def name
    case id
    when LIGHT then "light"
    when DARK then "dark"
    when SYSTEM then "system"
    end
  end

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
