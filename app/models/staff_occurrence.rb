# == Schema Information
#
# Table name: staff_occurrences
#
#  id         :uuid             not null, primary key
#  body       :string(36)       default(""), not null
#  created_at :datetime         not null
#  expires_at :datetime         not null
#  memo       :string(1024)     default(""), not null
#  public_id  :string(21)       default(""), not null
#  status_id  :string(255)      default(""), not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_staff_occurrences_on_body        (body) UNIQUE
#  index_staff_occurrences_on_expires_at  (expires_at)
#  index_staff_occurrences_on_public_id   (public_id) UNIQUE
#  index_staff_occurrences_on_status_id   (status_id)
#

class StaffOccurrence < UniversalRecord
  include PublicId
  include Occurrence

  belongs_to :staff_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :staff_occurrences
end
