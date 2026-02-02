# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_occurrence_statuses
# Database name: occurrence
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_ip_occurrence_statuses_on_code  (code) UNIQUE
#

class IpOccurrenceStatus < OccurrenceRecord
  include CodeIdentifiable

  include OccurrenceStatus

  # Status constants
  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
  has_many :ip_occurrences, foreign_key: :status_id, dependent: :restrict_with_error, inverse_of: :ip_occurrence_status
end
