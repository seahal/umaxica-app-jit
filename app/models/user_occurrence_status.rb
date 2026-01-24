# frozen_string_literal: true

# == Schema Information
#
# Table name: user_occurrence_statuses
# Database name: occurrence
#
#  id :string(255)      default("NEYO"), not null, primary key
#
# Indexes
#
#  index_user_occurrence_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class UserOccurrenceStatus < OccurrenceRecord
  include StringPrimaryKey

  include OccurrenceStatus

  # Status constants
  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
  has_many :user_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                              inverse_of: :user_occurrence_status
  validates :id, uniqueness: { case_sensitive: false }
end
