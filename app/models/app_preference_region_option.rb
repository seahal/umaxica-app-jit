# == Schema Information
#
# Table name: app_preference_region_options
#
#  id :string           not null, primary key
#

# frozen_string_literal: true

class AppPreferenceRegionOption < PreferenceRecord
  self.primary_key = :id

  has_many :app_preference_regions,
           class_name: "AppPreferenceRegion",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
end
