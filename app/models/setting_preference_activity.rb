# typed: false
# == Schema Information
#
# Table name: settings_preference_activities
# Database name: setting
#
#  id            :bigint           not null, primary key
#  action        :string           not null
#  actor_type    :string
#  metadata      :jsonb
#  created_at    :datetime         not null
#  actor_id      :bigint
#  preference_id :bigint           not null
#
# Indexes
#
#  index_settings_preference_activities_on_actor          (actor_type,actor_id)
#  index_settings_preference_activities_on_created_at     (created_at)
#  index_settings_preference_activities_on_preference_id  (preference_id)
#
# Foreign Keys
#
#  fk_settings_preference_activities_on_preference_id  (preference_id => settings_preferences.id)
#

# frozen_string_literal: true

class SettingPreferenceActivity < SettingRecord
  self.table_name = "settings_preference_activities"
  self.record_timestamps = false

  belongs_to :setting_preference,
             class_name: "SettingPreference",
             foreign_key: :preference_id,
             inverse_of: :setting_preference_activities

  validates :action, presence: true
  validates :created_at, presence: true
end
