# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: zip_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

class ZipOccurrenceStatus < OccurrenceRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  NOTHING = 2
  include OccurrenceStatus

  has_many :zip_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                             inverse_of: :zip_occurrence_status
end
