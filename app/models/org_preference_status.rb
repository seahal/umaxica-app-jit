# == Schema Information
#
# Table name: org_preference_statuses
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  position   :integer          not null
#
# Indexes
#
#  org_preference_statuses_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

class OrgPreferenceStatus < PreferenceRecord
  include StringPrimaryKey

  scope :ordered, -> { order(:position, :id) }

  has_many :org_preferences,
           class_name: "OrgPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :org_preference_status,
           dependent: :restrict_with_error

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true

  before_validation { self.id = id&.upcase }
  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
end
