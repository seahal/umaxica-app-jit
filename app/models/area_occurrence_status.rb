# frozen_string_literal: true

# == Schema Information
#
# Table name: area_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

class AreaOccurrenceStatus < OccurrenceRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  NEYO = 2

  include OccurrenceStatus

  has_many :area_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                              inverse_of: :area_occurrence_status
end
