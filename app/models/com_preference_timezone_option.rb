# == Schema Information
#
# Table name: com_preference_timezone_options
#
#  id :string           not null, primary key
#

# frozen_string_literal: true

class ComPreferenceTimezoneOption < PreferenceRecord
  self.primary_key = :id

  has_many :com_preference_timezones,
           class_name: "ComPreferenceTimezone",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
end
