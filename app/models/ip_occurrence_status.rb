# frozen_string_literal: true

class IpOccurrenceStatus < UniversalRecord
  include UppercaseId

  has_many :ip_occurrences, foreign_key: :status_id, dependent: :restrict_with_error, inverse_of: :ip_occurrence_status

  # Status constants
  NONE = "NONE"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
