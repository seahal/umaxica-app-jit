# frozen_string_literal: true

class EmailOccurrenceStatus < UniversalRecord
  include UppercaseId

  has_many :email_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                               inverse_of: :email_occurrence_status

  # Status constants
  NONE = "NONE"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
