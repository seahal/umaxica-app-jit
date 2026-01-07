# == Schema Information
#
# Table name: app_preference_regions
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :uuid
#
# Indexes
#
#  index_app_preference_regions_on_option_id      (option_id)
#  index_app_preference_regions_on_preference_id  (preference_id)
#

# frozen_string_literal: true

class AppPreferenceRegion < PreferenceRecord
  belongs_to :preference, class_name: "AppPreference", inverse_of: :app_preference_region
  belongs_to :option,
             class_name: "AppPreferenceRegionOption",
             inverse_of: :app_preference_regions,
             optional: true

  validates :preference_id, uniqueness: true
end
