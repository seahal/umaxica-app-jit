# == Schema Information
#
# Table name: org_preference_region_options
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  position   :integer          not null
#
# Indexes
#
#  org_preference_region_options_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

class OrgPreferenceRegionOption < PreferenceRecord
  include StringPrimaryKey

  has_many :org_preference_regions,
           class_name: "OrgPreferenceRegion",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }

  self.primary_key = :id

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true
end
