# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

class DomainOccurrenceStatus < OccurrenceRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  DELETED = 2
  INACTIVE = 3
  NEYO = 4
  PENDING = 5

  include OccurrenceStatus

  has_many :domain_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                                inverse_of: :domain_occurrence_status
end
