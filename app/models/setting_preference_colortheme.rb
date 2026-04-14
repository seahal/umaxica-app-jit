# typed: false
# == Schema Information
#
# Table name: settings_preference_colorthemes
# Database name: setting
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_settings_preference_colorthemes_on_option_id      (option_id)
#  index_settings_preference_colorthemes_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_settings_preference_colorthemes_on_option_id      (option_id => settings_preference_colortheme_options.id)
#  fk_settings_preference_colorthemes_on_preference_id  (preference_id => settings_preferences.id)
#

# frozen_string_literal: true

class SettingPreferenceColortheme < SettingRecord
  self.table_name = "settings_preference_colorthemes"
  belongs_to :preference, class_name: "SettingPreference", inverse_of: :setting_preference_colortheme
  belongs_to :option,
             class_name: "SettingPreferenceColorthemeOption",
             inverse_of: :setting_preference_colorthemes,
             optional: true
  validates :preference_id, uniqueness: true
  validates :option_id, presence: true
  before_validation :set_option_id

  private

  def set_option_id
    self.option_id ||= SettingPreferenceColorthemeOption::SYSTEM
  end
end
