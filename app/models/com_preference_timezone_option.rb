# == Schema Information
#
# Table name: com_preference_timezone_options
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class ComPreferenceTimezoneOption < PreferenceRecord
  self.primary_key = :id

  scope :ordered, -> { order(:position, :id) }

  has_many :com_preference_timezones,
           class_name: "ComPreferenceTimezone",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Za-z0-9_\/\-\+]+\z/ }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true
end
