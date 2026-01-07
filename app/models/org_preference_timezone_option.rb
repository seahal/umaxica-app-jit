# == Schema Information
#
# Table name: org_preference_timezone_options
#
#  id :uuid             not null, primary key
#

# frozen_string_literal: true

class OrgPreferenceTimezoneOption < PreferenceRecord
  has_many :org_preference_timezones,
           class_name: "OrgPreferenceTimezone",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
end
