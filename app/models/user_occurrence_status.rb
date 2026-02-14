# frozen_string_literal: true

# == Schema Information
#
# Table name: user_occurrence_statuses
# Database name: occurrence
#
#  id   :bigint           not null, primary key
#  name :string           default(""), not null
#

class UserOccurrenceStatus < OccurrenceRecord
  # Fixed IDs - do not modify these values
  NEYO = 1
  ACTIVE = 2
  INACTIVE = 3
  DELETED = 4

  include OccurrenceStatus

  has_many :user_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                              inverse_of: :user_occurrence_status
end
