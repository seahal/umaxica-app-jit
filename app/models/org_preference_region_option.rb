# typed: false
# == Schema Information
#
# Table name: org_preference_region_options
# Database name: operator
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class OrgPreferenceRegionOption < OperatorRecord
  # Fixed IDs - do not modify these values
  US = 1
  JP = 2

  has_many :org_preference_regions,
           class_name: "OrgPreferenceRegion",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  def name
    case id
    when US then "US"
    when JP then "JP"
    end
  end

  DEFAULTS = [US, JP].freeze

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
