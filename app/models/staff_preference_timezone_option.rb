# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_preference_timezone_options
# Database name: principal
#
#  id :bigint           not null, primary key
#
class StaffPreferenceTimezoneOption < PrincipalRecord
  # Fixed IDs - do not modify these values
  ETC_UTC = 1
  ASIA_TOKYO = 2

  has_many :staff_preference_timezones,
           class_name: "StaffPreferenceTimezone",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  def name
    case id
    when ETC_UTC then "Etc/UTC"
    when ASIA_TOKYO then "Asia/Tokyo"
    end
  end

  DEFAULTS = [ETC_UTC, ASIA_TOKYO].freeze

  def self.ensure_defaults!
    return if DEFAULTS.blank?

    existing_ids = where(id: DEFAULTS).pluck(:id)
    missing_ids = DEFAULTS - existing_ids
    return if missing_ids.empty?

    if defined?(Prosopite)
      Prosopite.pause { missing_ids.each { |id| create!(id: id) } }
    else
      missing_ids.each { |id| create!(id: id) }
    end
  end

  self.primary_key = :id
end
