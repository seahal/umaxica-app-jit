# == Schema Information
#
# Table name: domain_occurrence_statuses
#
#  id         :string(255)      default("NONE"), not null, primary key
#  expires_at :datetime         not null
#
# Indexes
#
#  index_domain_occurrence_statuses_on_expires_at  (expires_at)
#

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
