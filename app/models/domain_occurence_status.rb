# frozen_string_literal: true

class DomainOccurenceStatus < UniversalRecord
  include UppercaseId

  has_many :domain_occurences, foreign_key: :status_id, dependent: :restrict_with_error, inverse_of: :domain_occurence_status

  # Status constants
  NONE = "NONE"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
