# typed: false
# == Schema Information
#
# Table name: app_preference_region_options
# Database name: principal
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class AppPreferenceRegionOption < PrincipalRecord
  # Fixed IDs - do not modify these values
  NOTHING = 0
  US = 1
  JP = 2

  has_many :app_preference_regions,
           class_name: "AppPreferenceRegion",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  def name
    case id
    when US then "US"
    when JP then "JP"
    end
  end

  DEFAULTS = [NOTHING, US, JP].freeze

  def self.default_ids
    DEFAULTS
  end

  def self.ensure_defaults!
    return if default_ids.blank?

    existing_ids = where(id: default_ids).pluck(:id)
    missing_ids = default_ids - existing_ids
    return if missing_ids.empty?

    if defined?(Prosopite)
      Prosopite.pause { missing_ids.each { |id| create!(id: id) } }
    else
      missing_ids.each { |id| create!(id: id) }
    end
  end

  self.primary_key = :id
end
