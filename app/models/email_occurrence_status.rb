# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: email_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

class EmailOccurrenceStatus < OccurrenceRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  NOTHING = 2
  include OccurrenceStatus

  has_many :email_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                               inverse_of: :email_occurrence_status
end
