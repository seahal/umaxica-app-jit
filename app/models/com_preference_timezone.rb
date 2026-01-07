# == Schema Information
#
# Table name: com_preference_timezones
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_com_preference_timezones_on_option_id      (option_id)
#  index_com_preference_timezones_on_preference_id  (preference_id)
#

# frozen_string_literal: true

class ComPreferenceTimezone < PreferenceRecord
  belongs_to :preference, class_name: "ComPreference", inverse_of: :com_preference_timezone
  belongs_to :option,
             class_name: "ComPreferenceTimezoneOption",
             inverse_of: :com_preference_timezones,
             optional: true

  validates :preference_id, uniqueness: true
end
