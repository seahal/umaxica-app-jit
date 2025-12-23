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
