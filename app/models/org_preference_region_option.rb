# == Schema Information
#
# Table name: org_preference_region_options
#
#  id :uuid             not null, primary key
#

# frozen_string_literal: true

class OrgPreferenceRegionOption < PreferenceRecord
  has_many :org_preference_regions,
           class_name: "OrgPreferenceRegion",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
end
