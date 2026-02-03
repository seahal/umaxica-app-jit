# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

class IpOccurrenceStatus < OccurrenceRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  NEYO = 2

  include OccurrenceStatus

  has_many :ip_occurrences, foreign_key: :status_id, dependent: :restrict_with_error, inverse_of: :ip_occurrence_status
end
