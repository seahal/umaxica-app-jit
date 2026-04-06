# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_preference_region_options
# Database name: principal
#
#  id :bigint           not null, primary key
#
class StaffPreferenceRegionOption < PrincipalRecord
  # Fixed IDs - do not modify these values
  NOTHING = 0
  US = 1
  JP = 2

  has_many :staff_preference_regions,
           class_name: "StaffPreferenceRegion",
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
    ids = default_ids
    return if ids.blank?

    existing_ids = where(id: ids).pluck(:id)
    missing_ids = ids - existing_ids
    return if missing_ids.empty?

    if defined?(Prosopite)
      Prosopite.pause { missing_ids.each { |id| create!(id: id) } }
    else
      missing_ids.each { |id| create!(id: id) }
    end
  end

  self.primary_key = :id
end
