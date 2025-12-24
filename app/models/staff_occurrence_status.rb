# == Schema Information
#
# Table name: staff_occurrence_statuses
#
#  id         :string(255)      default("NONE"), not null, primary key
#  expires_at :datetime         not null
#
# Indexes
#
#  index_staff_occurrence_statuses_on_expires_at  (expires_at)
#

class StaffOccurrenceStatus < UniversalRecord
  include UppercaseId

  has_many :staff_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                               inverse_of: :staff_occurrence_status

  # Status constants
  NONE = "NONE"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
