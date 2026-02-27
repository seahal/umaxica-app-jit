# typed: false
# == Schema Information
#
# Table name: org_preference_region_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class OrgPreferenceRegionOption < PreferenceRecord
  # Fixed IDs - do not modify these values
  US = 1
  JP = 2

  has_many :org_preference_regions,
           class_name: "OrgPreferenceRegion",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { all }

  def name
    case id
    when US then "US"
    when JP then "JP"
    end
  end

  self.primary_key = :id
end
