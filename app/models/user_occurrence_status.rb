# frozen_string_literal: true

# == Schema Information
#
# Table name: user_occurrence_statuses
# Database name: occurrence
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_occurrence_statuses_on_code  (code) UNIQUE
#

class UserOccurrenceStatus < OccurrenceRecord
  include CodeIdentifiable

  include OccurrenceStatus

  # Status constants
  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
  has_many :user_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                              inverse_of: :user_occurrence_status
end
