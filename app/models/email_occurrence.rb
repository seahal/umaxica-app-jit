# frozen_string_literal: true

class EmailOccurrence < UniversalRecord
  belongs_to :email_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :email_occurrences
end
