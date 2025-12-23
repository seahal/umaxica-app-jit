class DomainOccurrenceStatus < UniversalRecord
  include UppercaseId

  has_many :domain_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                                inverse_of: :domain_occurrence_status

  # Status constants
  NONE = "NONE"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
