class AreaOccurrenceStatus < UniversalRecord
  include UppercaseId

  has_many :area_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                              inverse_of: :area_occurrence_status

  # Status constants
  NONE = "NONE"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
