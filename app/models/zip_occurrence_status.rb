# frozen_string_literal: true

# == Schema Information
#
# Table name: zip_occurrence_statuses
# Database name: occurrence
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_zip_occurrence_statuses_on_code  (code) UNIQUE
#

class ZipOccurrenceStatus < OccurrenceRecord
  include CodeIdentifiable

  include OccurrenceStatus

  # Status constants
  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
  has_many :zip_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                             inverse_of: :zip_occurrence_status
end
