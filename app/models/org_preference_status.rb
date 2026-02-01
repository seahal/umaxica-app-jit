# == Schema Information
#
# Table name: org_preference_statuses
# Database name: preference
#
#  id         :integer          default(0), not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  org_preference_statuses_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

class OrgPreferenceStatus < PreferenceRecord
  include CodeIdentifiable

  has_many :org_preferences,
           class_name: "OrgPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :org_preference_status,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true
                 format: { with: /\A[A-Z0-9_]+\z/ }
  before_validation { self.id = id&.upcase }
end
