# == Schema Information
#
# Table name: com_preference_timezone_options
# Database name: preference
#
#  id         :string           not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  com_preference_timezone_options_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

class ComPreferenceTimezoneOption < PreferenceRecord
  self.primary_key = :id

  has_many :com_preference_timezones,
           class_name: "ComPreferenceTimezone",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Za-z0-9_\/\-\+]+\z/ }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true
end
