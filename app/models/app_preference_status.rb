# == Schema Information
#
# Table name: app_preference_statuses
# Database name: preference
#
#  id         :integer          default(0), not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  app_preference_statuses_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

class AppPreferenceStatus < PreferenceRecord
  include StringPrimaryKey

  has_many :app_preferences,
           class_name: "AppPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :app_preference_status,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true
end
