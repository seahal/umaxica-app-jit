# == Schema Information
#
# Table name: app_preference_region_options
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class AppPreferenceRegionOption < PreferenceRecord
  include StringPrimaryKey

  self.primary_key = :id

  has_many :app_preference_regions,
           class_name: "AppPreferenceRegion",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
end
