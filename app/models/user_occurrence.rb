class UserOccurrence < UniversalRecord
  include PublicId
  include Occurrence

  belongs_to :user_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :user_occurrences
end
