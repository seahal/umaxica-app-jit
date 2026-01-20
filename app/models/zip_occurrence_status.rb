# frozen_string_literal: true

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

class ZipOccurrenceStatus < OccurrenceRecord
  include StringPrimaryKey

  include OccurrenceStatus

  # Status constants
  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  BLOCKED = "BLOCKED"
  has_many :zip_occurrences, foreign_key: :status_id, dependent: :restrict_with_error,
                             inverse_of: :zip_occurrence_status
  validates :id, uniqueness: { case_sensitive: false }
end
