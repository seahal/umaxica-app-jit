# == Schema Information
#
# Table name: app_preference_timezone_options
#
#  id :string           not null, primary key
#

# frozen_string_literal: true

class AppPreferenceTimezoneOption < PreferenceRecord
  self.primary_key = :id

  has_many :app_preference_timezones,
           class_name: "AppPreferenceTimezone",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
end
