# == Schema Information
#
# Table name: com_preference_regions
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_com_preference_regions_on_option_id      (option_id)
#  index_com_preference_regions_on_preference_id  (preference_id) UNIQUE
#

# frozen_string_literal: true

class ComPreferenceRegion < PreferenceRecord
  before_validation :set_option_id

  belongs_to :preference, class_name: "ComPreference", inverse_of: :com_preference_region
  belongs_to :option,
             class_name: "ComPreferenceRegionOption",
             inverse_of: :com_preference_regions,
             optional: true

  validates :preference_id, uniqueness: true
  validates :option_id, presence: true

  private

  def set_option_id
    self.option_id ||= "JP"
  end
end
