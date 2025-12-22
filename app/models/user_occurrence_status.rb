class UserOccurrenceStatus < UniversalRecord
  include UppercaseId

  has_many :user_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                              inverse_of: :user_occurrence_status

  # Status constants
  NONE = "NONE"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
