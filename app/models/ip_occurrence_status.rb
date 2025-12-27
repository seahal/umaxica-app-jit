# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_occurrence_statuses
#
#  id         :string(255)      default("NONE"), not null, primary key
#  expires_at :datetime         not null
#
# Indexes
#
#  index_ip_occurrence_statuses_on_expires_at  (expires_at)
#

class IpOccurrenceStatus < UniversalRecord
  include UppercaseId

  has_many :ip_occurrences, foreign_key: :status_id, dependent: :restrict_with_error, inverse_of: :ip_occurrence_status

  # Status constants
  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
