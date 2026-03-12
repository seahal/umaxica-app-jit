# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: jwt_occurrence_statuses
# Database name: occurrence
#
#  id   :bigint           not null, primary key
#  name :string           default(""), not null
#
class JwtOccurrenceStatus < OccurrenceRecord
  # Fixed IDs - do not modify these values
  NOTHING = 1
  ACTIVE = 2
  INACTIVE = 3
  DELETED = 4

  include OccurrenceStatus

  has_many :jwt_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                             inverse_of: :jwt_occurrence_status
end
