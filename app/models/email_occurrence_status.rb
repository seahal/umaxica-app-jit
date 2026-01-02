# frozen_string_literal: true

# == Schema Information
#
# Table name: email_occurrence_statuses
#
#  id         :string(255)      default("NONE"), not null, primary key
#  expires_at :datetime         not null
#
# Indexes
#
#  index_email_occurrence_statuses_on_expires_at  (expires_at)
#

class EmailOccurrenceStatus < UniversalRecord
  include UppercaseId
  include OccurrenceStatus

  has_many :email_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                               inverse_of: :email_occurrence_status

  # Status constants
  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
