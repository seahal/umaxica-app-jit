# frozen_string_literal: true

class ZipOccurrenceStatus < UniversalRecord
  include UppercaseId

  has_many :zip_occurrences, foreign_key: :status_id, dependent: :restrict_with_error, inverse_of: :zip_occurrence_status

  # Status constants
  NONE = "NONE"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
