# == Schema Information
#
# Table name: com_preference_statuses
# Database name: preference
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  com_preference_statuses_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

class ComPreferenceStatus < PreferenceRecord
  include StringPrimaryKey

  has_many :com_preferences,
           class_name: "ComPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :com_preference_status,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
  before_validation { self.id = id&.upcase }
end
