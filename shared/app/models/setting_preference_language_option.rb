# typed: false
# == Schema Information
#
# Table name: settings_preference_language_options
# Database name: setting
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class SettingPreferenceLanguageOption < SettingRecord
  self.table_name = "settings_preference_language_options"
  # Fixed IDs - do not modify these values
  NOTHING = 0
  JA = 1
  EN = 2
  DEFAULTS = [NOTHING, JA, EN].freeze

  has_many :setting_preference_languages,
           class_name: "SettingPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  self.primary_key = :id

  def name
    case id
    when JA then "ja"
    when EN then "en"
    end
  end

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
