# == Schema Information
#
# Table name: org_preference_timezone_options
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_preference_timezone_options_on_code  (code) UNIQUE
#

# frozen_string_literal: true

class OrgPreferenceTimezoneOption < PreferenceRecord
  include CodeIdentifiable

  self.primary_key = :id

  has_many :org_preference_timezones,
           class_name: "OrgPreferenceTimezone",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }
  before_validation { self.id = id&.downcase }

  private
end
