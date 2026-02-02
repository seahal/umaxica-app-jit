# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_occurrence_statuses
# Database name: occurrence
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_domain_occurrence_statuses_on_code  (code) UNIQUE
#

class DomainOccurrenceStatus < OccurrenceRecord
  include CodeIdentifiable

  include OccurrenceStatus

  # Status constants
  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
  has_many :domain_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                                inverse_of: :domain_occurrence_status
end
