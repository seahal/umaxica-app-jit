# == Schema Information
#
# Table name: app_preference_timezone_options
# Database name: preference
#
#  id         :integer          not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  app_preference_timezone_options_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

class AppPreferenceTimezoneOption < PreferenceRecord
  include CodeIdentifiable

  has_many :app_preference_timezones,
           class_name: "AppPreferenceTimezone",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }

  self.primary_key = :id
                 format: { with: /\A[A-Za-z0-9_\/\-\+]+\z/ }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true
end
