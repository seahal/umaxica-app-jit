class StaffOccurrence < UniversalRecord
  include PublicId
  include Occurrence

  belongs_to :staff_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :staff_occurrences
end
