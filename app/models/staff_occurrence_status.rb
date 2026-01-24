# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_occurrence_statuses
# Database name: occurrence
#
#  id :string(255)      default("NEYO"), not null, primary key
#
# Indexes
#
#  index_staff_occurrence_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class StaffOccurrenceStatus < OccurrenceRecord
  include StringPrimaryKey

  include OccurrenceStatus

  # Status constants
  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
  has_many :staff_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                               inverse_of: :staff_occurrence_status
  validates :id, uniqueness: { case_sensitive: false }
end
