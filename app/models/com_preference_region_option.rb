# == Schema Information
#
# Table name: com_preference_region_options
#
#  id :uuid             not null, primary key
#

# frozen_string_literal: true

class ComPreferenceRegionOption < PreferenceRecord
  has_many :com_preference_regions,
           class_name: "ComPreferenceRegion",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
end
