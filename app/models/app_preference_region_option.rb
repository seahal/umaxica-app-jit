# typed: false
# == Schema Information
#
# Table name: app_preference_region_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class AppPreferenceRegionOption < PreferenceRecord
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

  def self.ensure_defaults!
    ids = [NOTHING, US, JP]
    existing = where(id: ids).pluck(:id)
    (ids - existing).each { |id| create!(id: id) }
  end

  self.primary_key = :id
end
