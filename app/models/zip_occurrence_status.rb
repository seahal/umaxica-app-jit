# == Schema Information
#
# Table name: zip_occurrence_statuses
#
#  id         :string(255)      default("NONE"), not null, primary key
#  expires_at :datetime         not null
#
# Indexes
#
#  index_zip_occurrence_statuses_on_expires_at  (expires_at)
#

class ZipOccurrenceStatus < UniversalRecord
  include UppercaseId

  has_many :zip_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                             inverse_of: :zip_occurrence_status

  # Status constants
  NONE = "NONE"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
end
