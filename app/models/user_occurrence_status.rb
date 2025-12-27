# frozen_string_literal: true

# == Schema Information
#
# Table name: user_occurrence_statuses
#
#  id         :string(255)      default("NONE"), not null, primary key
#  expires_at :datetime         not null
#
# Indexes
#
#  index_user_occurrence_statuses_on_expires_at  (expires_at)
#

class UserOccurrenceStatus < UniversalRecord
  include UppercaseId

  has_many :user_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                              inverse_of: :user_occurrence_status

  # Status constants
  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
