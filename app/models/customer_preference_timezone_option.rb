# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_preference_timezone_options
# Database name: guest
#
#  id :bigint           not null, primary key
#
class CustomerPreferenceTimezoneOption < GuestRecord
  ETC_UTC = 1
  ASIA_TOKYO = 2

  has_many :customer_preference_timezones,
           class_name: "CustomerPreferenceTimezone",
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

  def self.default_ids
    DEFAULTS
  end

  def self.ensure_defaults!
    ids = default_ids
    return if ids.blank?

    existing_ids = where(id: ids).pluck(:id)
    missing_ids = ids - existing_ids
    return if missing_ids.empty?

    missing_ids.each { |id| create!(id: id) }
  end

  self.primary_key = :id
end
