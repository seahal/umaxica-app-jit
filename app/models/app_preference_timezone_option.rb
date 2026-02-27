# typed: false
# == Schema Information
#
# Table name: app_preference_timezone_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class AppPreferenceTimezoneOption < PreferenceRecord
  # Fixed IDs - do not modify these values
  ETC_UTC = 1
  ASIA_TOKYO = 2

  has_many :app_preference_timezones,
           class_name: "AppPreferenceTimezone",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  def name
    case id
    when ETC_UTC then "Etc/UTC"
    when ASIA_TOKYO then "Asia/Tokyo"
    end
  end

  def self.ensure_defaults!
    ids = [ETC_UTC, ASIA_TOKYO]
    existing = where(id: ids).pluck(:id)
    (ids - existing).each { |id| create!(id: id) }
  end

  self.primary_key = :id
end
