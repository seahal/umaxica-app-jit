# frozen_string_literal: true

# == Schema Information
#
# Table name: telephone_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

class TelephoneOccurrenceStatus < OccurrenceRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  NEYO = 2

  include OccurrenceStatus

  has_many :telephone_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                                   inverse_of: :telephone_occurrence_status
end
