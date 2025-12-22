class TelephoneOccurrenceStatus < UniversalRecord
  include UppercaseId

  has_many :telephone_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                                   inverse_of: :telephone_occurrence_status

  # Status constants
  NONE = "NONE"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
