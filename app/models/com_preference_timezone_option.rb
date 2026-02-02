# == Schema Information
#
# Table name: com_preference_timezone_options
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_preference_timezone_options_on_code  (code) UNIQUE
#

# frozen_string_literal: true

class ComPreferenceTimezoneOption < PreferenceRecord
  include CodeIdentifiable

  self.primary_key = :id

  has_many :com_preference_timezones,
           class_name: "ComPreferenceTimezone",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }
end
